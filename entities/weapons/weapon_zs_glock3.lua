AddCSLuaFile()

SWEP.PrintName = "'Crossfire' Glock 3"
SWEP.Description = "Each consecutive hit on a zombie within 1 second builds fire rate, up to 4 stacks. Missing or switching targets resets the chain."

SWEP.Slot = 1
SWEP.SlotPos = 0

if CLIENT then
	SWEP.ViewModelFOV = 50
	SWEP.ViewModelFlip = false

	SWEP.HUD3DBone = "v_weapon.Glock_Slide"
	SWEP.HUD3DPos = Vector(5, 0.25, -0.8)
	SWEP.HUD3DAng = Angle(90, 0, 0)
end

SWEP.Base = "weapon_zs_base"

SWEP.HoldType = "pistol"

SWEP.ViewModel = "models/weapons/cstrike/c_pist_glock18.mdl"
SWEP.WorldModel = "models/weapons/w_pist_glock18.mdl"
SWEP.UseHands = true

SWEP.Primary.Sound = Sound("Weapon_Glock.Single")
SWEP.Primary.Damage = 13
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.13

SWEP.Primary.ClipSize = 7
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "pistol"
GAMEMODE:SetupDefaultClip(SWEP.Primary)

SWEP.ConeMax = 2.5
SWEP.ConeMin = 1

SWEP.ReloadSpeed = 1.0

GAMEMODE:SetPrimaryWeaponModifier(SWEP, WEAPON_MODIFIER_CLIP_SIZE, 1)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_FIRE_DELAY, -0.0065, 1)

SWEP.CrossfireStacks = 0
SWEP.CrossfireLastHitTime = 0
SWEP.CrossfireLastTarget = nil

SWEP.IronSightsPos = Vector(-5.75, 10, 2.7)

if SERVER then
	function SWEP:BulletCallback(attacker, tr, dmginfo)
		local ent = tr.Entity
		if not IsValid(ent) or not ent:IsValidLivingZombie() then
			self.CrossfireStacks = 0
			self.CrossfireLastTarget = nil
			return
		end
		local now = CurTime()
		if now - self.CrossfireLastHitTime <= 1 and self.CrossfireLastTarget == ent then
			self.CrossfireStacks = math.min(self.CrossfireStacks + 1, 4)
		else
			self.CrossfireStacks = 1
		end
		self.CrossfireLastHitTime = now
		self.CrossfireLastTarget = ent
	end
end

function SWEP:GetFireDelay()
	local base = self.Primary.Delay
	local stacks = self.CrossfireStacks or 0
	return base / (1 + stacks * 0.15)
end
-- branches removed

