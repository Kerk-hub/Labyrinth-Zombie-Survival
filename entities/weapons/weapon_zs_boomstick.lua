AddCSLuaFile()

SWEP.Base = "weapon_zs_baseshotgun"

SWEP.PrintName = "Boom Stick"
SWEP.Description = "Fires one shell per shot with powerful self-knockback. Remantling fires more shells per pull for greater damage and knockback."
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
SWEP.Knockback = 80
SWEP.ShellsPerShot = 1

SWEP.PumpActivity = ACT_SHOTGUN_PUMP
SWEP.PumpSound = Sound("Weapon_Shotgun.Special1")
SWEP.ReloadSound = Sound("Weapon_Shotgun.Reload")

GAMEMODE:AddNewRemantleBranch(SWEP, 1, "Boom Stick Mk.II", "Fires 2 shells per shot for increased damage and knockback", function(wept)
	wept.ShellsPerShot = 2
end)
GAMEMODE:AddNewRemantleBranch(SWEP, 2, "Boom Stick Mk.III", "Fires 3 shells per shot for high damage and knockback", function(wept)
	wept.ShellsPerShot = 3
end)
GAMEMODE:AddNewRemantleBranch(SWEP, 3, "Boom Stick Mk.IV", "Fires all 4 shells at once for maximum damage and full self-knockback", function(wept)
	wept.ShellsPerShot = 4
end)

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end

	local owner = self:GetOwner()
	local shells = math.min(self.ShellsPerShot, self:Clip1())

	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:EmitSound(self.Primary.Sound)

	self:ShootBullets(self.Primary.Damage, self.Primary.NumShots * shells, self:GetCone())
	self:TakePrimaryAmmo(shells)

	owner:ViewPunch(shells * 0.5 * self.Recoil * Angle(math.Rand(-0.1, -0.1), math.Rand(-0.1, 0.1), 0))
	owner:SetGroundEntity(NULL)
	owner:SetVelocity(-self.Knockback * (shells / 4) * owner:GetAimVector())

	self.IdleAnimation = CurTime() + self:SequenceDuration()
end
