AddCSLuaFile()

SWEP.PrintName = "'Peashooter' Handgun"
SWEP.Description = "A fast-firing pistol. Killing a zombie refunds 1 bullet to the clip."

SWEP.Slot = 1
SWEP.SlotPos = 0

if CLIENT then
	SWEP.ViewModelFOV = 60
	SWEP.ViewModelFlip = false

	SWEP.HUD3DBone = "v_weapon.p228_Slide"
	SWEP.HUD3DPos = Vector(-0.88, 0.35, 1)
	SWEP.HUD3DAng = Angle(0, 0, 0)
	SWEP.HUD3DScale = 0.015
end

SWEP.Base = "weapon_zs_base"

SWEP.HoldType = "pistol"

SWEP.ViewModel = "models/weapons/cstrike/c_pist_p228.mdl"
SWEP.WorldModel = "models/weapons/w_pist_p228.mdl"
SWEP.UseHands = true

SWEP.Primary.Sound = Sound("Weapon_P228.Single")
SWEP.Primary.Damage = 18
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.18

SWEP.Primary.ClipSize = 14
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "pistol"
GAMEMODE:SetupDefaultClip(SWEP.Primary)

SWEP.ConeMax = 2.5
SWEP.ConeMin = 1

GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_FIRE_DELAY, -0.009, 1)

SWEP.QualityDescs = {
	"Refunds 4 bullets on zombie kill",
	"Refunds 7 bullets on zombie kill",
	"Refunds 10 bullets on zombie kill"
}

SWEP.IronSightsPos = Vector(-6, -1, 2.25)

if SERVER then
	function SWEP:OnZombieKilled(zombie)
		local qt = self.QualityTier or 0
		local refund = 1 + qt * 3
		local clip = self:Clip1()
		self:SetClip1(math.min(clip + refund, self.Primary.ClipSize))
	end
end
