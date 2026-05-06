AddCSLuaFile()
DEFINE_BASECLASS("weapon_zs_basemelee")

SWEP.PrintName = "Crowbar"
SWEP.Description = "Instantly kills headcrabs on hit and reduces damage taken from headcrabs. Higher tiers increase headcrab damage resistance and nail/unnail speed."

if CLIENT then
	SWEP.ViewModelFOV = 65
end

SWEP.Base = "weapon_zs_basemelee"

SWEP.ViewModel = "models/weapons/c_crowbar.mdl"
SWEP.WorldModel = "models/weapons/w_crowbar.mdl"
SWEP.UseHands = true

SWEP.HoldType = "melee"

SWEP.DamageType = DMG_CLUB

SWEP.MeleeDamage = 56
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
	"Reduces headcrab damage by 40%. Nail/unnail 20% faster.",
	"Reduces headcrab damage by 60%. Nail/unnail 40% faster.",
	"Reduces headcrab damage by 80%. Nail/unnail 60% faster.",
}

SWEP.NailDelay   = 0.5
SWEP.UnnailDelay = 1.0

BUILDING_WEAPON_MIXIN.ApplyShared(SWEP)

GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MELEE_RANGE, 3)

function SWEP:Initialize()
	BaseClass.Initialize(self)
	local tier  = self.QualityTier or 0
	local speed = 1 - tier * 0.20
	self.NailDelay   = 0.5 * speed
	self.UnnailDelay = 1.0 * speed
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
	BUILDING_WEAPON_MIXIN.ApplyServer(SWEP)

	hook.Add("EntityTakeDamage", "CrowbarHeadcrabResistance", function(victim, dmginfo)
		if not victim:IsValid() or not victim:IsPlayer() or not victim:Alive() or victim:Team() ~= TEAM_HUMAN then return end
		local attacker = dmginfo:GetAttacker()
		if not attacker:IsValid() or not attacker:IsPlayer() or attacker:Team() ~= TEAM_UNDEAD or not attacker:IsHeadcrab() then return end
		local wep = victim:GetActiveWeapon()
		if not wep:IsValid() then return end
		if (wep.BaseQuality or wep:GetClass()) ~= "weapon_zs_crowbar" then return end
		local tier = wep.QualityTier or 0
		local reduction = (tier + 1) * 0.20
		dmginfo:SetDamage(dmginfo:GetDamage() * (1 - reduction))
	end)
end

if CLIENT then
	BUILDING_WEAPON_MIXIN.ApplyClient(SWEP)
end
