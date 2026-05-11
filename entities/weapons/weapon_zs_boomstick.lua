
AddCSLuaFile()

SWEP.QualityDescs = {
	[1] = "+1 shell per shot (2 total)",
	[2] = "+2 shells per shot (3 total)",
	[3] = "+3 shells per shot (4 total)"
}

SWEP.Base = "weapon_zs_baseshotgun"

SWEP.PrintName = "Boom Stick"
SWEP.Description = "Fires one shell per shot with powerful self-knockback. Remantle path: +1 shell per tier (up to 4)."
SWEP.Slot = 1

if CLIENT then
	SWEP.HUD3DBone = "ValveBiped.Gun"
	SWEP.HUD3DPos = Vector(1.65, 0, -8)
	SWEP.HUD3DScale = 0.025

	SWEP.ViewModelFlip = false
end

SWEP.ViewModel = "models/weapons/c_shotgun.mdl"
SWEP.WorldModel = "models/weapons/w_shotgun.mdl"
SWEP.UseHands = true

SWEP.CSMuzzleFlashes = false

SWEP.ReloadDelay = 0.5

SWEP.Primary.Sound = Sound("weapons/shotgun/shotgun_dbl_fire.wav")
SWEP.Primary.Damage = 15
SWEP.Primary.NumShots = 6
SWEP.Primary.Delay = 0.9

SWEP.Recoil = 7.5

SWEP.Primary.ClipSize = 4
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "buckshot"
SWEP.Primary.DefaultClip = 28

SWEP.ConeMax = 4
SWEP.ConeMin = 4

SWEP.WalkSpeed = SPEED_SLOWER
SWEP.FireAnimSpeed = 0.4
SWEP.Knockback = 400
SWEP.ShellsPerShot = 1

SWEP.PumpActivity = ACT_SHOTGUN_PUMP
SWEP.PumpSound = Sound("Weapon_Shotgun.Special1")
SWEP.ReloadSound = Sound("Weapon_Shotgun.Reload")


function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end

	local owner = self:GetOwner()
	local qt = self.QualityTier or 0
	-- Shells per shot: 1 at tier0, 2 at tier1, 3 at tier2, 4 at tier3
	local shells = math.min(1 + qt, 4, self:Clip1())

	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:EmitSound(self.Primary.Sound)

	self:ShootBullets(self.Primary.Damage, self.Primary.NumShots * shells, self:GetCone())
	self:TakePrimaryAmmo(shells)

	owner:ViewPunch(shells * 0.1 * self.Recoil * Angle(math.Rand(-0.1, -0.1), math.Rand(-0.1, 0.1), 0))
	owner:SetGroundEntity(NULL)
	owner:SetVelocity(-self.Knockback * (shells / 4) * owner:GetAimVector())

	self.IdleAnimation = CurTime() + self:SequenceDuration()
end
