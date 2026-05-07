AddCSLuaFile()

SWEP.PrintName = "Stun Baton"
SWEP.Description = "This baton has the ability to slow zombies and it gains +25% extra points. Hitting a zombie temporarily reduces the attack cooldown of all zappers you own by 30%, refreshed on each hit."

SWEP.QualityDescs = {
	"Increases zapper haste to 40%",
	"Increases zapper haste to 50%",
	"Increases zapper haste to 60%",
}

if CLIENT then
	SWEP.ViewModelFOV = 50
end

SWEP.Base = "weapon_zs_basemelee"

SWEP.ViewModel = "models/weapons/c_stunstick.mdl"
SWEP.WorldModel = "models/weapons/w_stunbaton.mdl"
SWEP.UseHands = true

SWEP.HoldType = "melee"

SWEP.MeleeDamage = 80
SWEP.LegDamage = 20
SWEP.MeleeRange = 49
SWEP.MeleeSize = 1.5
SWEP.Primary.Delay = 0.9

SWEP.SwingTime = 0.25
SWEP.SwingRotation = Angle(60, 0, 0)
SWEP.SwingOffset = Vector(0, -50, 0)
SWEP.SwingHoldType = "grenade"

SWEP.PointsMultiplier = GAMEMODE.PulsePointsMultiplier

SWEP.AllowQualityWeapons = true

GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_FIRE_DELAY, -0.09)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_LEG_DAMAGE, 2)

function SWEP:PlaySwingSound()
	self:EmitSound("Weapon_StunStick.Swing")
end

function SWEP:PlayHitSound()
	self:EmitSound("Weapon_StunStick.Melee_HitWorld")
end

function SWEP:PlayHitFleshSound()
	self:EmitSound("Weapon_StunStick.Melee_Hit")
end

local BATON_DELAY_MUL = {0.70, 0.60, 0.50, 0.40}
local BATON_BUFF_DURATION = 6

function SWEP:OnMeleeHit(hitent, hitflesh, tr)
	if hitent:IsValid() and hitent:IsPlayer() then
		hitent:AddLegDamageExt(self.LegDamage, self:GetOwner(), self, SLOWTYPE_PULSE)

		if SERVER then
			local owner = self:GetOwner()
			local mul = BATON_DELAY_MUL[(self.QualityTier or 0) + 1]
			local expiry = CurTime() + BATON_BUFF_DURATION
			for _, zapper in pairs(ents.FindByClass("prop_zapper*")) do
				if zapper:IsValid() and not zapper.Destroyed and zapper:GetObjectOwner() == owner then
					zapper.ZapBatonMul = mul
					zapper.ZapBatonExpiry = expiry
				end
			end
		end
	end
end
