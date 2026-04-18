AddCSLuaFile()										-- make sure client gets this lua file

SWEP.PrintName = "'Battleaxe' Handgun"				-- weapon name and description
SWEP.Description = "An accurate, reliable pistol with considerable damage."
SWEP.Slot = 1										-- weapon item slot in weapon selection
SWEP.SlotPos = 0
SWEP.Base = "weapon_zs_base"						-- weapon base class
SWEP.HoldType = "pistol"							-- weapon animation properties
SWEP.ViewModel = "models/weapons/cstrike/c_pist_usp.mdl"
SWEP.WorldModel = "models/weapons/w_pist_usp.mdl"
SWEP.UseHands = true
SWEP.IronSightsPos = Vector(-5.9, 12, 2.3)
SWEP.ConeMax = 2.5
SWEP.ConeMin = 0.75
SWEP.Primary.Sound = Sound("Weapon_USP.Single")		-- weapon primary attack properties
SWEP.Primary.Damage = 24
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.2
SWEP.Primary.ClipSize = 12
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "pistol"
GAMEMODE:SetupDefaultClip(SWEP.Primary)				-- setup starting reserve ammo

-- client side view model settings
if CLIENT then
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 60
	SWEP.HUD3DPos = Vector(-0.95, 0, 1)
	SWEP.HUD3DAng = Angle(0, 0, 0)
	SWEP.HUD3DBone = "v_weapon.USP_Slide"
end

GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_CLIP_SIZE, 1, 1)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_FIRE_DELAY, -0.0175, 1)
