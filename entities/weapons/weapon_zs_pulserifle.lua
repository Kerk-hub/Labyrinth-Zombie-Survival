AddCSLuaFile()
DEFINE_BASECLASS("weapon_zs_base")

SWEP.PrintName = "'Adonis' Pulse Rifle"
SWEP.Description = "A full-auto pulse rifle that slows targets on hit."

SWEP.Slot = 1
SWEP.SlotPos = 0

if CLIENT then
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 60

	SWEP.HUD3DBone = "Vent"
	SWEP.HUD3DPos = Vector(1, 0, 0)
	SWEP.HUD3DScale = 0.018
end

SWEP.Base = "weapon_zs_base"

SWEP.HoldType = "ar2"

SWEP.ViewModel = "models/weapons/c_irifle.mdl"
SWEP.WorldModel = "models/weapons/w_IRifle.mdl"
SWEP.UseHands = true

SWEP.CSMuzzleFlashes = false

SWEP.ReloadSound = Sound("Weapon_SMG1.Reload")
SWEP.Primary.Sound = Sound("Airboat.FireGunHeavy")
SWEP.Primary.Damage = 12.25
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.175

SWEP.Primary.ClipSize = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.ConeMax = 3
SWEP.ConeMin = 1

SWEP.WalkSpeed = SPEED_SLOW

SWEP.IronSightsPos = Vector(-3, 1, 1)

SWEP.PointsMultiplier = GAMEMODE.PulsePointsMultiplier

SWEP.TracerName = "AR2Tracer"

SWEP.FireAnimSpeed = 0.4
SWEP.LegDamage = 5.5

GAMEMODE:AddNewRemantleBranch(SWEP, 1, "'Servitor' Pulse Rifle", "Refreshes zapper cooldown on kill, more leg damage, reduced accuracy", function(wept)
	wept.ConeMin = 2.25
	wept.ConeMax = 3.75
	wept.ReloadSpeed = 0.85
	wept.LegDamage = 8

	wept.OnZombieKilled = function(self)
		local killer = self:GetOwner()

		if killer:IsValid() then
			for _,v in pairs(ents.FindByClass("prop_zapper*")) do
				if v:GetObjectOwner() == killer then
					v:SetNextZap(0)
				end
			end
		end
	end
end)

function SWEP.BulletCallback(attacker, tr, dmginfo)
	local ent = tr.Entity
	if ent:IsValidZombie() then
		local activ = attacker:GetActiveWeapon()
		ent:AddLegDamageExt(activ.LegDamage, attacker, activ, SLOWTYPE_PULSE)
	end
end
