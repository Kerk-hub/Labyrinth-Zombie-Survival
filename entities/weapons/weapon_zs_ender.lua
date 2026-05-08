AddCSLuaFile()

SWEP.PrintName = "'Ender' Automatic Shotgun"
SWEP.Description = "Automatic clip-fed shotgun. Pellets ricochet off walls for bonus damage."

SWEP.Slot = 1
SWEP.SlotPos = 0

if CLIENT then
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 60

	SWEP.HUD3DBone = "v_weapon.galil"
	SWEP.HUD3DPos = Vector(1, 0, 6)
	SWEP.HUD3DScale = 0.015
end

SWEP.Base = "weapon_zs_base"

SWEP.HoldType = "shotgun"

SWEP.ViewModel = "models/weapons/cstrike/c_rif_galil.mdl"
SWEP.WorldModel = "models/weapons/w_rif_galil.mdl"
SWEP.UseHands = true

SWEP.Primary.Sound = Sound("Weapon_Galil.Single")
SWEP.Primary.Damage = 5.2
SWEP.Primary.NumShots = 8
SWEP.Primary.Delay = 0.4

SWEP.Primary.ClipSize = 8
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "buckshot"
GAMEMODE:SetupDefaultClip(SWEP.Primary)

SWEP.ConeMax = 4
SWEP.ConeMin = 4

SWEP.WalkSpeed = SPEED_SLOWER

SWEP.BounceMulti = 1.5

-- Ricochet count scales with remantle tier (QualityTier)
SWEP.QualityDescs = {
	"Bounces twice",
	"Bounces 3 times",
	"Bounces 4 times"
}

local function DoRicochet(attacker, hitpos, hitnormal, normal, damage, bouncesLeft)
	attacker.RicochetBullet = true
	if attacker:IsValid() then
		attacker:FireBulletsLua(hitpos, 2 * hitnormal * hitnormal:Dot(normal * -1) + normal, 0, 1, damage, nil, nil, "tracer_rico", function(att, tr, dmginfo)
			if SERVER and tr.HitWorld and not tr.HitSky and bouncesLeft > 0 then
				local hp, hn, n, dmg = tr.HitPos, tr.HitNormal, tr.Normal, dmginfo:GetDamage() * (IsValid(att:GetActiveWeapon()) and att:GetActiveWeapon().BounceMulti or 1.5)
				timer.Simple(0, function() DoRicochet(att, hp, hn, n, dmg, bouncesLeft - 1) end)
			end
		end, nil, nil, nil, nil, attacker:GetActiveWeapon())
	end
	attacker.RicochetBullet = nil
end

function SWEP.BulletCallback(attacker, tr, dmginfo)
	if SERVER and not attacker.RicochetBullet and tr.HitWorld and not tr.HitSky then
		local wep = attacker:GetActiveWeapon()
		local bouncesLeft = (IsValid(wep) and wep.QualityTier or 0)
		local hitpos, hitnormal, normal, dmg = tr.HitPos, tr.HitNormal, tr.Normal, dmginfo:GetDamage() * (IsValid(wep) and wep.BounceMulti or 1.5)
		timer.Simple(0, function() DoRicochet(attacker, hitpos, hitnormal, normal, dmg, bouncesLeft) end)
	end
end

--[[GAMEMODE:AddNewRemantleBranch(SWEP, 1, "'Ender' Automatic Slug Rifle", "Single accurate slug round, less total damage", function(wept)
	wept.Primary.Damage = wept.Primary.Damage * 5.5
	wept.Primary.NumShots = 1
	wept.ConeMin = wept.ConeMin * 0.15
	wept.ConeMax = wept.ConeMax * 0.3
end)]]--

function SWEP:SecondaryAttack()
end
