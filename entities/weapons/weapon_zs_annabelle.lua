AddCSLuaFile()

SWEP.Base = "weapon_zs_baseshotgun"

SWEP.PrintName = "'Annabelle' Rifle"
SWEP.Description = "Tube-loaded rifle that loads one round at a time. Headshot kills build Reaper stacks."
SWEP.Slot = 1

if CLIENT then
	SWEP.ViewModelFlip = false

	SWEP.IronSightsPos = Vector(-8.8, 10, 4.32)
	SWEP.IronSightsAng = Vector(1.4, 0.1, 5)

	SWEP.HUD3DBone = "ValveBiped.Gun"
	SWEP.HUD3DPos = Vector(1.75, 1, -5)
	SWEP.HUD3DAng = Angle(180, 0, 0)
	SWEP.HUD3DScale = 0.015
end

SWEP.HoldType = "ar2"

SWEP.ViewModel = "models/weapons/c_annabelle.mdl"
SWEP.WorldModel = "models/weapons/w_annabelle.mdl"
SWEP.UseHands = true

SWEP.CSMuzzleFlashes = false

SWEP.Primary.Sound = Sound("Weapon_Shotgun.Single")
SWEP.Primary.Damage = 38
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.38

SWEP.ReloadDelay = 0.4

SWEP.Primary.ClipSize = 5
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "357"
SWEP.Primary.DefaultClip = 25

SWEP.ConeMax = 6
SWEP.ConeMin = 0

SWEP.HeadshotMulti = 3

SWEP.ReloadSound = Sound("Weapon_Shotgun.Reload")
SWEP.PumpSound = Sound("Weapon_Shotgun.Special1")

SWEP.WalkSpeed = SPEED_NORMAL
SWEP.PhaseEndTime = 0
SWEP.PhaseCooldown = 0

GAMEMODE:AddNewRemantleBranch(SWEP, 1, "'Annabelle' Birdshot Rifle", "Fires a spread of less accurate shots that deal more total damage", function(wept)
	wept.Primary.Damage = wept.Primary.Damage / 5
	wept.Primary.NumShots = 6
	wept.ConeMin = 4
	wept.ConeMax = 8
end)

function SWEP:IsPhasing()
	return CurTime() < self.PhaseEndTime
end

function SWEP:GetWalkSpeed()
	if self:IsPhasing() then
		return self.BaseClass.GetWalkSpeed(self) * 1.5
	end
	return self.BaseClass.GetWalkSpeed(self)
end

function SWEP:SecondaryAttack()
	if CurTime() < self.PhaseCooldown then return end
	self.PhaseEndTime = CurTime() + 3
	self.PhaseCooldown = CurTime() + 8
	self:GetOwner():ResetSpeed()
	self:EmitSound("npc/scanner/scanner_scan4.wav", 55, 130, 0.6)
end

function SWEP:EmitFireSound()
	self:EmitSound(self.Primary.Sound, 75, math.random(95, 103), 0.8)
	self:EmitSound("weapons/shotgun/shotgun_fire6.wav", 75, math.random(78, 81), 0.65, CHAN_WEAPON + 20)
end

function SWEP:Think()
	self.BaseClass.Think(self)
end
