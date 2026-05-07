DEFINE_BASECLASS("weapon_zs_basemelee")

SWEP.Base = "weapon_zs_basemelee"

SWEP.PrintName = "Carpenter's Hammer"
SWEP.Description = "Eliminates movement speed penalty from carrying props. When your nailed props are destroyed, you recover nails. Higher tiers increase nail and unnail speed and nails recovered. Can nail and unnail props with SECONDARY FIRE and RELOAD."

SWEP.DamageType = DMG_CLUB

SWEP.ViewModel = "models/weapons/v_hammer/c_hammer.mdl"
SWEP.WorldModel = "models/weapons/w_hammer.mdl"
SWEP.UseHands = true

SWEP.Primary.ClipSize = 1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "GaussEnergy"
SWEP.Primary.Delay = 1
SWEP.Primary.DefaultClip = 16

SWEP.Secondary.ClipSize = 1
SWEP.Secondary.DefaultClip = 1
SWEP.Secondary.Ammo = "dummy"

SWEP.MeleeDamage = 34
SWEP.MeleeRange = 50
SWEP.MeleeSize = 0.875

SWEP.UseMelee1 = true
SWEP.AutoBuyAmmoOnSecondary = true

SWEP.NoPropThrowing = true

SWEP.HitGesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE
SWEP.MissGesture = SWEP.HitGesture

SWEP.HealStrength = 1

SWEP.NoHolsterOnCarry = true

SWEP.NoGlassWeapons = true

SWEP.AllowQualityWeapons = true
SWEP.QualityDescs = {
	"Nail/unnail 20% faster. Owned props breaking return 2 nails.",
	"Nail/unnail 40% faster. Owned props breaking return 3 nails.",
	"Nail/unnail 60% faster. Owned props breaking return 4 nails.",
}

SWEP.NailDelay   = 0.5
SWEP.UnnailDelay = 1.0

function SWEP:Initialize()
	BaseClass.Initialize(self)
	local tier = self.QualityTier or 0
	local speed = 1 - tier * 0.20
	self.NailDelay   = 0.5 * speed
	self.UnnailDelay = 1.0 * speed
end

GAMEMODE:SetPrimaryWeaponModifier(SWEP, WEAPON_MODIFIER_FIRE_DELAY, -0.04)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MELEE_RANGE, 3, 1)

function SWEP:SetNextAttack()
	local owner = self:GetOwner()
	local armdelay = owner:GetMeleeSpeedMul()
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay * (owner.HammerSwingDelayMul or 1) * armdelay)
end

function SWEP:PlayHitSound()
	self:EmitSound("weapons/melee/crowbar/crowbar_hit-" .. math.random(4) .. ".ogg", 75, math.random(110, 115))
end

function SWEP:PlayRepairSound(hitent)
	hitent:EmitSound("npc/dog/dog_servo" .. math.random(7, 8) .. ".wav", 70, math.random(100, 105))
end
