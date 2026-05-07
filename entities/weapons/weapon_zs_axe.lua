AddCSLuaFile()
DEFINE_BASECLASS("weapon_zs_basemelee")

SWEP.PrintName = "Axe"
SWEP.Description = "A balanced axe that cleaves through multiple targets. Smashes props below a health threshold, granting board ammo. Can nail and unnail props with SECONDARY FIRE and RELOAD."

if CLIENT then
	SWEP.ViewModelFOV = 55
	SWEP.ViewModelFlip = false

	SWEP.ShowViewModel = false
	SWEP.ShowWorldModel = false
	SWEP.VElements = {
		["base"] = { type = "Model", model = "models/props/cs_militia/axe.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3, 1.299, -4), angle = Angle(0, 0, 90), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
	SWEP.WElements = {
		["base"] = { type = "Model", model = "models/props/cs_militia/axe.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3, 1.399, -4), angle = Angle(0, 0, 90), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
end

SWEP.Base = "weapon_zs_basemelee"

SWEP.ViewModel = "models/weapons/c_stunstick.mdl"
SWEP.WorldModel = "models/props/cs_militia/axe.mdl"
SWEP.UseHands = true

SWEP.HoldType = "melee2"

SWEP.MeleeDamage = 90
SWEP.MeleeRange = 55
SWEP.MeleeSize = 1.5
SWEP.MeleeKnockBack = 125

SWEP.WalkSpeed = SPEED_FAST

SWEP.SwingTime = 0.6
SWEP.SwingRotation = Angle(0, -20, -40)
SWEP.SwingOffset = Vector(10, 0, 0)
SWEP.SwingHoldType = "melee"

SWEP.HitDecal = "Manhackcut"

SWEP.AllowQualityWeapons = true
SWEP.QualityDescs = {
	"Smashes props at or below 20% health, granting 2 board ammo.",
	"Smashes props at or below 20% health, granting 3 board ammo.",
	"Smashes props at or below 20% health, granting 4 board ammo.",
}

local AMMO_REWARD = {1, 2, 3, 4}

function SWEP:MeleeSwing()
	local owner = self:GetOwner()

	owner:DoAttackEvent()
	self:SendWeaponAnim(self.MissAnim)
	self.IdleAnimation = CurTime() + self:SequenceDuration()

	local traces = owner:CompensatedPenetratingMeleeTrace(self.MeleeRange * (owner.MeleeRangeMul or 1), self.MeleeSize)

	local damagemultiplier = owner:Team() == TEAM_HUMAN and owner.MeleeDamageMultiplier or 1
	if owner:IsSkillActive(SKILL_LASTSTAND) then
		if owner:Health() <= owner:GetMaxHealth() * 0.25 then
			damagemultiplier = damagemultiplier * 2
		else
			damagemultiplier = damagemultiplier * 0.85
		end
	end

	local hit = false
	for _, tr in ipairs(traces) do
		if not tr.Hit then continue end
		local ent = tr.Entity
		local hitflesh = tr.MatType == MAT_FLESH or tr.MatType == MAT_BLOODYFLESH or tr.MatType == MAT_ANTLION or tr.MatType == MAT_ALIENFLESH

		hit = true

		if hitflesh then
			util.Decal(self.BloodDecal, tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)
			if SERVER then self:ServerHitFleshEffects(ent, tr, damagemultiplier) end
		end

		if ent and ent:IsValid() then
			if SERVER then self:ServerMeleeHitEntity(tr, ent, damagemultiplier) end
			self:MeleeHitEntity(tr, ent, damagemultiplier)
			if SERVER then
				self:ServerMeleePostHitEntity(tr, ent, damagemultiplier)

				-- Prop smash ability: only nailed props owned by this player
				if not hitflesh and not ent:IsPlayer() and not ent:IsValidLivingZombie() then
					if ent:IsNailed() then
						local maxhp = ent:GetMaxBarricadeHealth()
						if maxhp > 0 then
							local isOwner = false
							for _, nail in ipairs(ent:GetNails()) do
								if nail:GetOwner() == owner then
									isOwner = true
									break
								end
							end
							if isOwner then
								local hp = ent:GetBarricadeHealth()
								if maxhp > 0 and hp <= maxhp * 0.20 then
									local tier = self.QualityTier or 0
									local storedNails = ent:GetNails()
									ent:EmitSound("physics/wood/wood_plank_break1.wav", 75, math.random(90, 110))
									ent:Remove()
									for _, nail in ipairs(storedNails) do
										if nail and nail:IsValid() then
											nail:Remove()
										end
									end
									owner:GiveAmmo(AMMO_REWARD[tier + 1], "SniperRound")
								end
							end
						end
					end
				end
			end

			if owner.GlassWeaponShouldBreak then break end
		end
	end

	if hit then
		self:PlayHitSound()
	else
		self:PlaySwingSound()
		if owner.MeleePowerAttackMul and owner.MeleePowerAttackMul > 1 then
			self:SetPowerCombo(0)
		end
	end
end

BUILDING_WEAPON_MIXIN.ApplyShared(SWEP)

GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MELEE_RANGE, 3)

function SWEP:PlaySwingSound()
	self:EmitSound("weapons/iceaxe/iceaxe_swing1.wav", 75, math.random(65, 70))
end

function SWEP:PlayHitSound()
	self:EmitSound("weapons/melee/golf club/golf_hit-0"..math.random(4)..".ogg")
end

function SWEP:PlayHitFleshSound()
	self:EmitSound("physics/body/body_medium_break"..math.random(2, 4)..".wav")
end

if SERVER then
	BUILDING_WEAPON_MIXIN.ApplyServer(SWEP)
end

if CLIENT then
	BUILDING_WEAPON_MIXIN.ApplyClient(SWEP)
end
