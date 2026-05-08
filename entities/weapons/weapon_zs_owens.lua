AddCSLuaFile()

SWEP.PrintName = "'Owens' Handgun"
SWEP.Description = "Fires two shots per trigger pull. Gains one additional shot per quality tier."

SWEP.Slot = 1
SWEP.SlotPos = 0

if CLIENT then
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 60

	SWEP.HUD3DBone = "ValveBiped.square"
	SWEP.HUD3DPos = Vector(1.1, 0.25, -2)
	SWEP.HUD3DScale = 0.015
end

SWEP.Base = "weapon_zs_base"

SWEP.HoldType = "pistol"

SWEP.ViewModel = "models/weapons/c_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_pistol.mdl"
SWEP.UseHands = true

SWEP.CSMuzzleFlashes = false

SWEP.ReloadSound = Sound("Weapon_Pistol.Reload")
SWEP.Primary.Sound = Sound("Weapon_Pistol.NPC_Single")
SWEP.Primary.Damage = 14
SWEP.Primary.NumShots = 2
SWEP.Primary.Delay = 0.28

SWEP.Primary.ClipSize = 10
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "pistol"
SWEP.Primary.ClipMultiplier = 12/10
GAMEMODE:SetupDefaultClip(SWEP.Primary)

SWEP.ReloadSpeed = 0.5

SWEP.ConeMax = 4
SWEP.ConeMin = 2

SWEP.IronSightsPos = Vector(-5.95, 3, 2.75)
SWEP.IronSightsAng = Vector(-0.15, -1, 2)

GAMEMODE:SetPrimaryWeaponModifier(SWEP, WEAPON_MODIFIER_SHOT_COUNT, 1)
