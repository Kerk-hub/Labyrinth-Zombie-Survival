DEFINE_BASECLASS("weapon_zs_poisonzombie")

SWEP.PrintName = "Wild Poison Zombie"

SWEP.MeleeDamage = 45

SWEP.PoisonThrowSpeed = 420
-- Removed invalid CLASS usage. If you want to hide/disable this weapon, use SWEP.Hidden or SWEP.Disabled if supported by your codebase.

function SWEP:PlayAttackSound()
	self:EmitSound("npc/zombie_poison/pz_warn"..math.random(2)..".wav", 74, math.random(88, 95), 0.5, CHAN_AUTO)
	self:EmitSound("npc/antlion_guard/angry"..math.random(3)..".wav", 74, math.random(112, 115), 0.5, CHAN_AUTO)
end
