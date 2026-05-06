AddCSLuaFile()
DEFINE_BASECLASS("weapon_zs_basemelee")

SWEP.PrintName = "Pot"
SWEP.Description = "A culinary pot. Kills and gib destruction restore blood armor and add food charges. Hold RMB to consume all charges and restore health."

if CLIENT then
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 55

	SWEP.ShowViewModel = false
	SWEP.ShowWorldModel = false

	SWEP.VElements = {
		["base"] = { type = "Model", model = "models/props_interiors/pot02a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(5, 1.363, -6.818), angle = Angle(0, 90, -90), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
	SWEP.WElements = {
		["base"] = { type = "Model", model = "models/props_interiors/pot02a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(5, 1.363, -6.818), angle = Angle(0, 90, -90), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
end

SWEP.Base = "weapon_zs_basemelee"

SWEP.DamageType = DMG_CLUB

SWEP.ViewModel = "models/weapons/c_stunstick.mdl"
SWEP.WorldModel = "models/props_interiors/pot02a.mdl"
SWEP.UseHands = true

SWEP.MeleeDamage = 90
SWEP.MeleeRange = 50
SWEP.MeleeSize = 1.15

SWEP.UseMelee1 = true

SWEP.HitGesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE
SWEP.MissGesture = SWEP.HitGesture

SWEP.SwingRotation = Angle(30, -30, -30)
SWEP.SwingTime = 0.3
SWEP.SwingHoldType = "grenade"

SWEP.AllowQualityWeapons = true
SWEP.Culinary = true
SWEP.CulinaryNoKillArmor = true
SWEP.QualityDescs = {
	"On kill and gib destruction: +10 blood armor, +1 charge. Charges restore 15 health each.",
	"On kill and gib destruction: +15 blood armor, +1 charge. Charges restore 20 health each.",
	"On kill and gib destruction: +20 blood armor, +1 charge. Charges restore 25 health each.",
}

local BLOOD_ARMOR      = {5, 10, 15, 20}
local HEALTH_PER_CHARGE = {10, 15, 20, 25}
local MAX_CHARGES       = 10
local EAT_COOLDOWN      = 1.2

function SWEP:SetCharges(v)
	self:SetDTInt(1, math.Clamp(v, 0, MAX_CHARGES))
end

function SWEP:GetCharges()
	return self:GetDTInt(1)
end

function SWEP:CulinaryGibReward(attacker)
	if not attacker:IsValid() then return end
	local tier = self.QualityTier or 0
	if attacker.MaxBloodArmor and attacker.MaxBloodArmor > 0 then
		attacker:SetBloodArmor(math.min(attacker.MaxBloodArmor, attacker:GetBloodArmor() + BLOOD_ARMOR[tier + 1]))
	end
	self:SetCharges(self:GetCharges() + 1)
end

function SWEP:OnZombieKilled()
	local owner = self:GetOwner()
	if not owner:IsValid() then return end
	local tier = self.QualityTier or 0
	if owner.MaxBloodArmor and owner.MaxBloodArmor > 0 then
		owner:SetBloodArmor(math.min(owner.MaxBloodArmor, owner:GetBloodArmor() + BLOOD_ARMOR[tier + 1]))
	end
	self:SetCharges(self:GetCharges() + 1)
end

function SWEP:SecondaryAttack()
	if self:GetCharges() <= 0 then return end
	if self:GetNextSecondaryFire() > CurTime() then return end

	local owner = self:GetOwner()
	if not owner:IsValid() then return end

	if SERVER then
		local tier = self.QualityTier or 0
		local heal = self:GetCharges() * HEALTH_PER_CHARGE[tier + 1]
		owner:SetHealth(math.min(owner:GetMaxHealth(), owner:Health() + heal))
		self:SetCharges(0)
	end

	self:EmitSound("items/medshot4.wav", 70, 80)
	self:SendWeaponAnim(ACT_VM_DRAW)
	self.IdleAnimation = CurTime() + EAT_COOLDOWN
	self:SetNextPrimaryFire(CurTime() + EAT_COOLDOWN)
	self:SetNextSecondaryFire(CurTime() + EAT_COOLDOWN)
end

function SWEP:PlayHitSound()
	self:EmitSound("weapons/melee/frying_pan/pan_hit-0"..math.random(4)..".ogg")
end
