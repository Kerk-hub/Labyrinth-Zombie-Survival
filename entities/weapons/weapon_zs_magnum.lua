AddCSLuaFile()
DEFINE_BASECLASS("weapon_zs_base")

SWEP.PrintName = "'Ricochete' Magnum"
SWEP.Description = "Bullets bounce off walls and deal bonus damage. Each wall bounce hit shortens your next reload."
SWEP.Slot = 1
SWEP.SlotPos = 0

if CLIENT then
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 60

	SWEP.HUD3DBone = "Python"
	SWEP.HUD3DPos = Vector(0.85, 0, -2.5)
	SWEP.HUD3DScale = 0.015
end

SWEP.Base = "weapon_zs_base"

SWEP.HoldType = "revolver"

SWEP.ViewModel = "models/weapons/c_357.mdl"
SWEP.WorldModel = "models/weapons/w_357.mdl"
SWEP.UseHands = true

SWEP.CSMuzzleFlashes = false

SWEP.Primary.Sound = Sound("Weapon_357.Single")
SWEP.Primary.Delay = 0.7
SWEP.Primary.Damage = 72
SWEP.Primary.NumShots = 1

SWEP.Primary.ClipSize = 6
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "pistol"
SWEP.Primary.Gesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_PISTOL
GAMEMODE:SetupDefaultClip(SWEP.Primary)

SWEP.Tier = 2

SWEP.ConeMax = 2.5
SWEP.ConeMin = 1
SWEP.BounceMulti = 1.5
SWEP.BounceReloadStacks = 0

SWEP.IronSightsPos = Vector(-4.65, 4, 0.25)
SWEP.IronSightsAng = Vector(0, 0, 1)

SWEP.ReloadSpeed = 1.0

GAMEMODE:SetPrimaryWeaponModifier(SWEP, WEAPON_MODIFIER_RELOAD_SPEED, -0.05)

SWEP.QualityDescs = {
	"Bounces twice, 5% faster reload",
	"Bounces 3 times, 10% faster reload",
	"Bounces 4 times, 15% faster reload"
}

function SWEP:GetReloadSpeedMultiplier()
	local base = BaseClass.GetReloadSpeedMultiplier and BaseClass.GetReloadSpeedMultiplier(self) or 1
	local stacks = self.BounceReloadStacks or 0
	return base * (1 + stacks * 0.2)
end

function SWEP:FinishReload()
	self.BounceReloadStacks = 0
	BaseClass.FinishReload(self)
end
local function DoRicochet(attacker, hitpos, hitnormal, normal, damage, bouncesLeft)
	local RicoCallback = function(att, tr, dmginfo)
		local ent = tr.Entity
		local wep = att:GetActiveWeapon()
		if IsValid(wep) and ent:IsValidLivingZombie() then
			wep.BounceReloadStacks = math.min((wep.BounceReloadStacks or 0) + 1, 5)
		end
		if SERVER and tr.HitWorld and not tr.HitSky and bouncesLeft > 0 then
			local hp, hn, n, dmg = tr.HitPos, tr.HitNormal, tr.Normal, dmginfo:GetDamage() * wep.BounceMulti
			timer.Simple(0, function() DoRicochet(att, hp, hn, n, dmg, bouncesLeft - 1) end)
		end
	end

	attacker.RicochetBullet = true
	if attacker:IsValid() then
		attacker:FireBulletsLua(hitpos, 2 * hitnormal * hitnormal:Dot(normal * -1) + normal, 0, 1, damage, nil, nil, "tracer_rico", RicoCallback, nil, nil, nil, nil, attacker:GetActiveWeapon())
	end
	attacker.RicochetBullet = nil
end
function SWEP.BulletCallback(attacker, tr, dmginfo)
	local ent = tr.Entity
	if SERVER and tr.HitWorld and not tr.HitSky then
		local wep = attacker:GetActiveWeapon()
		local bouncesLeft = wep.QualityTier or 0
		local hitpos, hitnormal, normal, dmg = tr.HitPos, tr.HitNormal, tr.Normal, dmginfo:GetDamage() * wep.BounceMulti
		timer.Simple(0, function() DoRicochet(attacker, hitpos, hitnormal, normal, dmg, bouncesLeft) end)
	end
end
