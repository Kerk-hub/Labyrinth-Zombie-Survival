AddCSLuaFile()
DEFINE_BASECLASS("weapon_zs_basemelee")

SWEP.PrintName = "Bust-on-a-stick"
SWEP.Description = "A Breen bust mounted on a stick. Taking hits from zombies builds narcissistic rage — each stack supercharges your next swing."

if CLIENT then
	SWEP.ViewModelFOV = 70
	SWEP.ViewModelFlip = false

	SWEP.ShowViewModel = true
	SWEP.ShowWorldModel = false

	SWEP.VElements = {
		["base"] = { type = "Model", model = "models/props_combine/breenbust.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(6, -2, -17), angle = Angle(180, 0, 0), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["stick"] = { type = "Model", model = "models/props_docks/dock01_pole01a_128.mdl", bone = "ValveBiped.Bip01", rel = "base", pos = Vector(3.25, 3.194, -20.932), angle = Angle(5, 0, 0), size = Vector(0.15, 0.15, 0.15), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}

	SWEP.WElements = {
		["base"] = { type = "Model", model = "models/props_combine/breenbust.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(0, 1, -20), angle = Angle(180, 270, 0), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["stick"] = { type = "Model", model = "models/props_docks/dock01_pole01a_128.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0, -3, -18), angle = Angle(0, 0, 0), size = Vector(0.1, 0.1, 0.1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
end

SWEP.Base = "weapon_zs_basemelee"

SWEP.DamageType = DMG_CLUB

SWEP.ViewModel = "models/weapons/c_crowbar.mdl"
SWEP.WorldModel = Model("models/props_combine/breenbust.mdl")
SWEP.UseHands = true

SWEP.MeleeDamage = 81
SWEP.MeleeRange = 50
SWEP.MeleeSize = 1.4

SWEP.UseMelee1 = false

SWEP.HitGesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE
SWEP.MissGesture = SWEP.HitGesture

SWEP.SwingRotation = Angle(30, -30, -30)
SWEP.SwingTime = 0.3
SWEP.SwingHoldType = "grenade"

SWEP.AllowQualityWeapons = true
SWEP.QualityDescs = {
	"Rage stacks grant +75% damage per stack on next swing.",
	"Rage stacks grant +100% damage per stack on next swing.",
	"Rage stacks grant +125% damage per stack on next swing.",
}

GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_FIRE_DELAY, -0.1, 1)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MELEE_RANGE, 2, 1)

SURVIVAL_WEAPON_MIXIN.Apply(SWEP)

SWEP.Tier = 2
SWEP.DismantleDiv = 2

-- Damage bonus per stack per tier (base = 50%, +25% per tier)
local DAMAGE_PER_STACK = {0.50, 0.75, 1.00, 1.25}
local STACK_CAP = 10

function SWEP:SetRageStacks(v) self:SetDTInt(2, v) end
function SWEP:GetRageStacks()  return self:GetDTInt(2) end

function SWEP:Initialize()
	self.m_BaseMeleeDamage = self.MeleeDamage
	BaseClass.Initialize(self)
end

function SWEP:MeleeSwing()
	if SERVER then
		local stacks = self:GetRageStacks()
		if stacks > 0 then
			local tier = self.QualityTier or 0
			self.MeleeDamage = self.m_BaseMeleeDamage * (1 + stacks * DAMAGE_PER_STACK[tier + 1])
			self:SetRageStacks(0)
		end
	end
	BaseClass.MeleeSwing(self)
	if SERVER then
		self.MeleeDamage = self.m_BaseMeleeDamage
	end
end

if SERVER then
	hook.Add("PlayerHurt", "BustNarcissisticRage", function(victim, attacker)
		if not victim:IsValid() or not victim:IsPlayer() then return end
		if victim:Team() ~= TEAM_HUMAN then return end
		if not attacker:IsValid() or not attacker:IsPlayer() then return end
		if attacker:Team() ~= TEAM_UNDEAD then return end
		local wep = victim:GetActiveWeapon()
		if not wep:IsValid() then return end
		if (wep.BaseQuality or wep:GetClass()) ~= "weapon_zs_bust" then return end
		wep:SetRageStacks(math.min(STACK_CAP, wep:GetRageStacks() + 1))
	end)
end

function SWEP:PlaySwingSound()
	self:EmitSound("weapons/iceaxe/iceaxe_swing1.wav", 75, math.Rand(35, 45))
end

function SWEP:PlayHitSound()
	self:EmitSound("physics/concrete/rock_impact_hard"..math.random(6)..".wav", 75, math.Rand(86, 90))
end

function SWEP:PlayHitFleshSound()
	self:EmitSound("physics/body/body_medium_break"..math.random(2, 4)..".wav", 75, math.Rand(86, 90))
end
