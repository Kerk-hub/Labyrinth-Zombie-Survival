AddCSLuaFile()
DEFINE_BASECLASS("weapon_zs_basemelee")

SWEP.PrintName = "Sledgehammer"
SWEP.Description = "Destroys your own nailed props at 20% health, converting them into armor stacks that reduce all damage taken while held. Stacks persist until dropped."

if CLIENT then
	SWEP.ViewModelFOV = 75
end

SWEP.Base = "weapon_zs_basemelee"

SWEP.HoldType = "melee2"

SWEP.DamageType = DMG_CLUB

SWEP.ViewModel = "models/weapons/v_sledgehammer/c_sledgehammer.mdl"
SWEP.WorldModel = "models/weapons/w_sledgehammer.mdl"
SWEP.UseHands = true

SWEP.MeleeDamage = 120
SWEP.MeleeRange = 64
SWEP.MeleeSize = 1.75
SWEP.MeleeKnockBack = 170

SWEP.Primary.Delay = 1.3

SWEP.Tier = 2

SWEP.WalkSpeed = SPEED_SLOWEST

SWEP.SwingRotation = Angle(60, 0, -80)
SWEP.SwingOffset = Vector(0, -30, 0)
SWEP.SwingTime = 0.75
SWEP.SwingHoldType = "melee"

SWEP.AllowQualityWeapons = true
SWEP.QualityDescs = {
	"Each armor stack gives 2% damage resistance.",
	"Each armor stack gives 3% damage resistance.",
	"Each armor stack gives 4% damage resistance.",
}

SWEP.NailDelay   = 1.5
SWEP.UnnailDelay = 2.0

-- DTInt(2): armor stack count
function SWEP:SetArmorStacks(v) self:SetDTInt(2, v) end
function SWEP:GetArmorStacks() return self:GetDTInt(2) end

local RESIST_PER_STACK = {0.01, 0.02, 0.03, 0.04}

BUILDING_WEAPON_MIXIN.ApplyShared(SWEP)

GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MELEE_IMPACT_DELAY, -0.1, 1)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_FIRE_DELAY, -0.1, 1)

function SWEP:MeleeSwing()
	local owner = self:GetOwner()

	owner:DoAttackEvent()
	self.IdleAnimation = CurTime() + self:SequenceDuration()

	local tr = owner:CompensatedMeleeTrace(self.MeleeRange * (owner.MeleeRangeMul or 1), self.MeleeSize)

	local damagemultiplier = owner:Team() == TEAM_HUMAN and owner.MeleeDamageMultiplier or 1
	if owner:IsSkillActive(SKILL_LASTSTAND) then
		if owner:Health() <= owner:GetMaxHealth() * 0.25 then
			damagemultiplier = damagemultiplier * 2
		else
			damagemultiplier = damagemultiplier * 0.85
		end
	end

	if not tr.Hit then
		self.IdleAnimation = CurTime() + self:SequenceDuration()
		self:PlaySwingSound()
		if owner.MeleePowerAttackMul and owner.MeleePowerAttackMul > 1 then
			self:SetPowerCombo(0)
		end
		if self.PostOnMeleeMiss then self:PostOnMeleeMiss(tr) end
		return
	end

	local hitent = tr.Entity
	local hitflesh = tr.MatType == MAT_FLESH or tr.MatType == MAT_BLOODYFLESH or tr.MatType == MAT_ANTLION or tr.MatType == MAT_ALIENFLESH

	self.IdleAnimation = CurTime() + self:SequenceDuration()

	if hitflesh then
		util.Decal(self.BloodDecal, tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)
		self:PlayHitFleshSound()
		if SERVER then
			self:ServerHitFleshEffects(hitent, tr, damagemultiplier)
		end
	else
		self:PlayHitSound()
	end

	if hitent and hitent:IsValid() then
		if SERVER then self:ServerMeleeHitEntity(tr, hitent, damagemultiplier) end
		self:MeleeHitEntity(tr, hitent, damagemultiplier)
		if SERVER then
			self:ServerMeleePostHitEntity(tr, hitent, damagemultiplier)

			-- Prop smash: only own nailed props at or below health threshold
			if not hitflesh and not hitent:IsPlayer() and not hitent:IsValidLivingZombie() then
				if hitent:IsNailed() then
					local maxhp = hitent:GetMaxBarricadeHealth()
					if maxhp > 0 then
						local isOwner = false
						for _, nail in ipairs(hitent:GetNails()) do
							if nail:GetOwner() == owner then
								isOwner = true
								break
							end
						end
						if isOwner then
							local hp = hitent:GetBarricadeHealth()
							if hp <= maxhp * 0.20 then
								local storedNails = hitent:GetNails()
								hitent:EmitSound("physics/metal/metal_canister_impact_hard1.wav", 75, math.random(60, 80))
								hitent:Remove()
								for _, nail in ipairs(storedNails) do
									if nail and nail:IsValid() then nail:Remove() end
								end
								self:SetArmorStacks(self:GetArmorStacks() + 1)
							end
						end
					end
				end
			end
		end
	end
end

function SWEP:PlaySwingSound()
	self:EmitSound("weapons/iceaxe/iceaxe_swing1.wav", 75, math.random(35, 45))
end

function SWEP:PlayHitSound()
	self:EmitSound("physics/metal/metal_canister_impact_hard"..math.random(3)..".wav", 75, math.Rand(86, 90))
end

function SWEP:PlayHitFleshSound()
	self:EmitSound("physics/body/body_medium_break"..math.random(2, 4)..".wav", 75, math.Rand(86, 90))
end

if SERVER then
	BUILDING_WEAPON_MIXIN.ApplyServer(SWEP)

	function SWEP:Deploy()
		-- When remantling, the old tier is still in inventory during Deploy.
		-- Transfer its stacks to this new weapon before it gets stripped.
		local owner = self:GetOwner()
		if IsValid(owner) then
			for _, wep in ipairs(owner:GetWeapons()) do
				if wep ~= self and (wep.BaseQuality or wep:GetClass()) == "weapon_zs_sledgehammer" then
					self:SetArmorStacks(wep:GetArmorStacks())
					break
				end
			end
		end
		return BaseClass.Deploy(self)
	end

	hook.Add("EntityTakeDamage", "SledgehammerArmorStacks", function(victim, dmginfo)
		if not victim:IsValid() or not victim:IsPlayer() or not victim:Alive() or victim:Team() ~= TEAM_HUMAN then return end
		local wep = victim:GetActiveWeapon()
		if not wep:IsValid() then return end
		if (wep.BaseQuality or wep:GetClass()) ~= "weapon_zs_sledgehammer" then return end
		local stacks = wep:GetArmorStacks()
		if stacks <= 0 then return end
		local tier = wep.QualityTier or 0
		local resist = math.min(stacks * RESIST_PER_STACK[tier + 1], 0.80)
		dmginfo:SetDamage(dmginfo:GetDamage() * (1 - resist))
	end)
end

if CLIENT then
	BUILDING_WEAPON_MIXIN.ApplyClient(SWEP)
end
