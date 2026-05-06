AddCSLuaFile()

SWEP.PrintName = "'Silencer' SMG"
SWEP.Description = "Shrouds your aura, preventing aura bonuses from being given or received. High fire rate for sustained close-range damage."

SWEP.Slot = 1
SWEP.SlotPos = 0

if CLIENT then
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 60

	SWEP.HUD3DBone = "v_weapon.TMP_Parent"
	SWEP.HUD3DPos = Vector(-1, -3.5, -1)
	SWEP.HUD3DAng = Angle(0, 0, 0)
	SWEP.HUD3DScale = 0.015
end

SWEP.Base = "weapon_zs_base"

SWEP.HoldType = "pistol"

SWEP.ViewModel = "models/weapons/cstrike/c_smg_tmp.mdl"
SWEP.WorldModel = "models/weapons/w_smg_tmp.mdl"
SWEP.UseHands = true

SWEP.Primary.Sound = Sound("Weapon_TMP.Single")
SWEP.Primary.Damage = 8
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.074

SWEP.Primary.ClipSize = 27
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "smg1"
GAMEMODE:SetupDefaultClip(SWEP.Primary)

SWEP.ReloadSpeed = 0.72
SWEP.FireAnimSpeed = 3

SWEP.Primary.Gesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_SMG1
SWEP.ReloadGesture = ACT_HL2MP_GESTURE_RELOAD_SMG1

SWEP.ConeMax = 5.3
SWEP.ConeMin = 3.6

SWEP.WalkSpeed = SPEED_NORMAL

SWEP.IronSightsPos = Vector(-7, 3, 2.5)

function SWEP:GetAuraRange()
	return 0
end
