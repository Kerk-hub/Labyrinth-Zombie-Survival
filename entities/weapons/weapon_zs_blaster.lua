AddCSLuaFile()

SWEP.Base = "weapon_zs_baseshotgun"

SWEP.PrintName = "'Blaster' Shotgun"
SWEP.Description = "A reliable pump shotgun. Solid close-range damage with no frills."
SWEP.Slot = 1

if CLIENT then
	SWEP.ViewModelFlip = false

	SWEP.HUD3DPos = Vector(4, -3.5, -1.2)
	SWEP.HUD3DAng = Angle(90, 0, -30)
	SWEP.HUD3DScale = 0.02
	SWEP.HUD3DBone = "SS.Grip.Dummy"
end

SWEP.HoldType = "shotgun"

SWEP.ViewModel = "models/weapons/v_supershorty/v_supershorty.mdl"
SWEP.WorldModel = "models/weapons/w_supershorty.mdl"
SWEP.UseHands = false

SWEP.ReloadDelay = 0.4

SWEP.Primary.Sound = Sound("Weapon_Shotgun.NPC_Single")
SWEP.Primary.Damage = 10
SWEP.Primary.NumShots = 8
SWEP.Primary.Delay = 0.8

SWEP.Primary.ClipSize = 5
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "buckshot"
GAMEMODE:SetupDefaultClip(SWEP.Primary)

SWEP.ConeMax = 4
SWEP.ConeMin = 4

SWEP.WalkSpeed = SPEED_SLOWER

SWEP.PumpSound = Sound("Weapon_M3.Pump")
SWEP.ReloadSound = Sound("Weapon_Shotgun.Reload")

SWEP.PumpActivity = ACT_SHOTGUN_PUMP

GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_CLIP_SIZE, 1, 1)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_FIRE_DELAY, -0.0175, 1)

function SWEP:SendWeaponAnimation()
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self:GetOwner():GetViewModel():SetPlaybackRate(self.FireAnimSpeed)

	timer.Simple(0.15, function()
		if IsValid(self) then
			self:SendWeaponAnim(ACT_SHOTGUN_PUMP)
			self:GetOwner():GetViewModel():SetPlaybackRate(self.FireAnimSpeed)

			if CLIENT and self:GetOwner() == MySelf then
				self:EmitSound("weapons/m3/m3_pump.wav", 65, 100, 0.4, CHAN_AUTO)
			end
		end
	end)
end
