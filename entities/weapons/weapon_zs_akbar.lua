AddCSLuaFile()

SWEP.PrintName = "'Akbar' Assault Rifle"
SWEP.Description = "Reliable assault rifle whose bullets penetrate through one target."

SWEP.Slot = 1
SWEP.SlotPos = 0

if CLIENT then
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 50

	SWEP.HUD3DBone = "v_weapon.AK47_Parent"
	SWEP.HUD3DPos = Vector(-1, -4.5, -4)
	SWEP.HUD3DAng = Angle(0, 0, 0)
	SWEP.HUD3DScale = 0.015
end

SWEP.Base = "weapon_zs_base"

SWEP.HoldType = "ar2"

SWEP.ViewModel = "models/weapons/cstrike/c_rif_ak47.mdl"
SWEP.WorldModel = "models/weapons/w_rif_ak47.mdl"
SWEP.UseHands = true

SWEP.ReloadSound = Sound("Weapon_AK47.Clipout")
SWEP.Primary.Sound = Sound("Weapon_AK47.Single")
SWEP.Primary.Damage = 15
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.15

SWEP.Primary.ClipSize = 30
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "ar2"
GAMEMODE:SetupDefaultClip(SWEP.Primary)

SWEP.ConeMax = 3
SWEP.ConeMin = 1

SWEP.WalkSpeed = SPEED_SLOW

SWEP.IronSightsPos = Vector(-6.6, 20, 3.1)

GAMEMODE:AddNewRemantleBranch(SWEP, 1, "'Akbar' Breacher Rifle", "Bullets penetrate through two targets at the cost of reduced damage per hit", function(wept)
	wept.PenetrationLayers = 2
	wept.PenetrationDamageMul = 0.65
end)

function SWEP.BulletCallback(attacker, tr, dmginfo)
	if SERVER and not attacker.PenetrationBullet then
		local wep = attacker:GetActiveWeapon()
		local layers = IsValid(wep) and (wep.PenetrationLayers or 1) or 1
		local dmgmul = IsValid(wep) and (wep.PenetrationDamageMul or 0.8) or 0.8
		local dir = tr.Normal
		attacker.PenetrationBullet = true
		attacker:FireBulletsLua(tr.HitPos + dir * 2, dir, 0, 1, dmginfo:GetDamage() * dmgmul, nil, nil, nil, layers > 1 and SWEP.BulletCallback or nil, nil, nil, nil, nil, wep)
		attacker.PenetrationBullet = nil
	end
end
