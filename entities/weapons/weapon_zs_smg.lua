AddCSLuaFile()

SWEP.PrintName = "'Shredder' SMG"
SWEP.Description = "Bullets pierce through zombies, continuing with reduced damage. Inaccurate at range."

SWEP.Slot = 1
SWEP.SlotPos = 0

if CLIENT then
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 50

	SWEP.HUD3DBone = "v_weapon.MP5_Parent"
	SWEP.HUD3DPos = Vector(-1, -3, -6)
	SWEP.HUD3DAng = Angle(0, 0, 0)
	SWEP.HUD3DScale = 0.015
end

SWEP.Base = "weapon_zs_base"

SWEP.HoldType = "shotgun"

SWEP.ViewModel = "models/weapons/cstrike/c_smg_mp5.mdl"
SWEP.WorldModel = "models/weapons/w_smg_mp5.mdl"
SWEP.UseHands = true

SWEP.Primary.Sound = Sound("Weapon_MP5Navy.Single")
SWEP.Primary.Damage = 15.5
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.133

SWEP.Primary.ClipSize = 19
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "smg1"
GAMEMODE:SetupDefaultClip(SWEP.Primary)

SWEP.Primary.Gesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_SHOTGUN
SWEP.ReloadGesture = ACT_HL2MP_GESTURE_RELOAD_SMG1

SWEP.ConeMax = 5.5
SWEP.ConeMin = 2.5

SWEP.WalkSpeed = SPEED_NORMAL

SWEP.IronSightsAng = Vector(0.8, 0, 0)
SWEP.IronSightsPos = Vector(-5.33, 7, 1.8)

local function DoPierce(attacker, startpos, dir, damage)
	attacker.PierceBullet = true
	if attacker:IsValid() then
		attacker:FireBulletsLua(startpos, dir, 0, 1, damage, nil, nil, nil, nil, nil, nil, nil, nil, attacker:GetActiveWeapon())
	end
	attacker.PierceBullet = nil
end

function SWEP.BulletCallback(attacker, tr, dmginfo)
	if SERVER and not attacker.PierceBullet and tr.Entity:IsValidLivingZombie() then
		local hitpos, normal, dmg = tr.HitPos, tr.Normal, dmginfo:GetDamage() * 0.6
		timer.Simple(0, function() DoPierce(attacker, hitpos, normal, dmg) end)
	end
end

GAMEMODE:AddNewRemantleBranch(SWEP, 1, "'Smasher' SMG", "Additional damage to skeletal enemies, inflicts force, but fires and reloads slower", function(wept)
	wept.Primary.Delay = 0.15
	wept.ReloadSpeed = 0.9

	wept.BulletCallback = function(attacker, tr, dmginfo)
		local trent = tr.Entity

		if SERVER and trent and trent:IsValidZombie() then
			if trent:GetZombieClassTable().Skeletal then
				dmginfo:SetDamage(dmginfo:GetDamage() * 1.2)
			end

			if math.random(6) == 1 then
				trent:ThrowFromPositionSetZ(tr.StartPos, 150, nil, true)
			end
		end
	end
end)
