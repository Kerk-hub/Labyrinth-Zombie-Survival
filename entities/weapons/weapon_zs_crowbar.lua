AddCSLuaFile()
DEFINE_BASECLASS("weapon_zs_basemelee")

SWEP.PrintName = "Crowbar"
SWEP.Description = "Destroys your own nailed props at 20% health, converting them into arsenal items.Instantly kills headcrabs on hit and reduces damage taken from headcrabs."

if CLIENT then
	SWEP.ViewModelFOV = 65
end

SWEP.Base = "weapon_zs_basemelee"

SWEP.ViewModel = "models/weapons/c_crowbar.mdl"
SWEP.WorldModel = "models/weapons/w_crowbar.mdl"
SWEP.UseHands = true

SWEP.HoldType = "melee"

SWEP.DamageType = DMG_CLUB

SWEP.MeleeDamage = 70
SWEP.OriginalMeleeDamage = SWEP.MeleeDamage
SWEP.MeleeRange = 55
SWEP.MeleeSize = 1.5
SWEP.MeleeKnockBack = 110

SWEP.Primary.Delay = 0.7

SWEP.SwingTime = 0.4
SWEP.SwingRotation = Angle(30, -30, -30)
SWEP.SwingHoldType = "grenade"

SWEP.AllowQualityWeapons = true

SWEP.QualityDescs = {
	"Reduces headcrab damage by 40%.",
	"Reduces headcrab damage by 60%.",
	"Reduces headcrab damage by 80%.",
}

SWEP.NailDelay   = 0.5
SWEP.UnnailDelay = 1.0

BUILDING_WEAPON_MIXIN.ApplyShared(SWEP)

GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MELEE_RANGE, 3)


function SWEP:Initialize()
	BaseClass.Initialize(self)
	self.NailDelay   = 0.5
	self.UnnailDelay = 1.0
end

function SWEP:PlaySwingSound()
	self:EmitSound("Weapon_Crowbar.Single")
end

function SWEP:PlayHitSound()
	self:EmitSound("Weapon_Crowbar.Melee_HitWorld")
end

function SWEP:PlayHitFleshSound()
	self:EmitSound("Weapon_Crowbar.Melee_Hit")
end


function SWEP:PostOnMeleeHit(hitent, hitflesh, tr)
	if hitent:IsValid() and hitent:IsPlayer() and hitent:Team() == TEAM_UNDEAD and hitent:IsHeadcrab() and gamemode.Call("PlayerShouldTakeDamage", hitent, self:GetOwner()) then
		hitent:TakeSpecialDamage(hitent:Health(), DMG_DIRECT, self:GetOwner(), self, tr.HitPos)
	end
end


if SERVER then
	-- Override the main attack logic to add prop destruction and reward, like sledgehammer
	local OldMeleeSwing = SWEP.MeleeSwing
	function SWEP:MeleeSwing()
		local owner = self:GetOwner()
		owner:DoAttackEvent()
		self.IdleAnimation = CurTime() + self:SequenceDuration()

		local tr = owner:CompensatedMeleeTrace(self.MeleeRange * (owner.MeleeRangeMul or 1), self.MeleeSize)
		local damagemultiplier = owner:Team() == TEAM_HUMAN and owner.MeleeDamageMultiplier or 1

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
					if hitent.IsNailed and hitent:IsNailed() then
						local maxhp = hitent.GetMaxBarricadeHealth and hitent:GetMaxBarricadeHealth() or 0
						if maxhp > 0 then
							local isOwner = false
							for _, nail in ipairs(hitent:GetNails()) do
								if nail:GetOwner() == owner then
									isOwner = true
									break
								end
							end
							if isOwner then
								local hp = hitent.GetBarricadeHealth and hitent:GetBarricadeHealth() or 0
								if hp <= maxhp * 0.2 then -- 20% threshold
									local storedNails = hitent:GetNails()
									hitent:EmitSound("physics/metal/metal_canister_impact_hard1.wav", 75, math.random(60, 80))
									hitent:Remove()
									for _, nail in ipairs(storedNails) do
										if nail and nail:IsValid() then nail:Remove() end
									end
									-- Grant a random arsenal item (excluding ammo), only from currently available arsenal menu items
									local items = {}
									for _, tab in ipairs(GAMEMODE.Items) do
										if tab.PointShop and tab.Category ~= ITEMS_AMMO and tab.SWEP and not tab.SkillRequirement and not tab.NoClassicMode then
											table.insert(items, tab)
										end
									end
									if #items > 0 then
										local item = items[math.random(#items)]
										if item.Callback then
											item.Callback(owner)
										elseif item.SWEP then
											owner:Give(item.SWEP)
										end
										owner:PrintMessage(HUD_PRINTTALK, "You received a free arsenal item: " .. (item.Name or item.SWEP or "?"))
									end
								end
							end
						end
					end
				end
			end
		end
	end
end

if SERVER then
	BUILDING_WEAPON_MIXIN.ApplyServer(SWEP)

	hook.Add("EntityTakeDamage", "CrowbarHeadcrabResistance", function(victim, dmginfo)
		if not victim:IsValid() or not victim:IsPlayer() or not victim:Alive() or victim:Team() ~= TEAM_HUMAN then return end
		local attacker = dmginfo:GetAttacker()
		if not attacker:IsValid() or not attacker:IsPlayer() or attacker:Team() ~= TEAM_UNDEAD or not attacker:IsHeadcrab() then return end
		local wep = victim:GetActiveWeapon()
		if not wep:IsValid() then return end
		if (wep.BaseQuality or wep:GetClass()) ~= "weapon_zs_crowbar" then return end
		local tier = wep.QualityTier or 0
		local reduction = (tier + 1) * 1
		dmginfo:SetDamage(dmginfo:GetDamage() * (1 - reduction))
	end)
end

if CLIENT then
	BUILDING_WEAPON_MIXIN.ApplyClient(SWEP)
end
