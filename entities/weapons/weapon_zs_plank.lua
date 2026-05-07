AddCSLuaFile()
DEFINE_BASECLASS("weapon_zs_basemelee")

SWEP.PrintName = "Plank"
SWEP.Description = "A plank of wood that builds momentum with each strike. Hits on zombies increase both attack speed and movement speed. Resets after a short pause. Right click to perform an extra jump (7s cooldown)."

if CLIENT then
	SWEP.ViewModelFOV = 55
	SWEP.ViewModelFlip = false

	SWEP.ShowViewModel = false
	SWEP.ShowWorldModel = false
	SWEP.VElements = {
		["base"] = { type = "Model", model = "models/props_debris/wood_chunk03a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(1.363, 1.363, -11.365), angle = Angle(180, 90, 0), size = Vector(0.5, 0.5, 0.5), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
	SWEP.WElements = {
		["base"] = { type = "Model", model = "models/props_debris/wood_chunk03a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(2.273, 1.363, -12.273), angle = Angle(180, 90, 0), size = Vector(0.5, 0.5, 0.5), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
end

SWEP.Base = "weapon_zs_basemelee"

SWEP.DamageType = DMG_CLUB

SWEP.ViewModel = "models/weapons/c_crowbar.mdl"
SWEP.WorldModel = "models/props_debris/wood_chunk03a.mdl"
SWEP.ModelScale = 0.5
SWEP.UseHands = true
SWEP.BoxPhysicsMin = Vector(-0.5764, -2.397225, -20.080572) * SWEP.ModelScale
SWEP.BoxPhysicsMax = Vector(0.70365, 2.501825, 19.973375) * SWEP.ModelScale

SWEP.MeleeDamage = 26
SWEP.MeleeRange = 48
SWEP.MeleeSize = 0.875
SWEP.Primary.Delay = 0.37

SWEP.WalkSpeed = SPEED_FASTER

SWEP.UseMelee1 = true

SWEP.HitGesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE
SWEP.MissGesture = SWEP.HitGesture

SWEP.AllowQualityWeapons = true
SWEP.QualityDescs = {
	"Each hit adds 5% attack and movement speed, capped at 50%. Resets after 2s without a hit.",
	"Each hit adds 10% attack and movement speed, capped at 100%. Resets after 2s without a hit.",
	"Each hit adds 15% attack and movement speed, capped at 150%. Resets after 2s without a hit.",
}

GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MELEE_RANGE, 4)

SURVIVAL_WEAPON_MIXIN.Apply(SWEP)

-- Remove any stale kill hook from a previous load
if SERVER then hook.Remove("PostHumanKilledZombie", "PlankMomentum") end

local STACK_PER_HIT = {0.03, 0.05, 0.10, 0.15}
local STACK_CAP    = {0.30, 0.50, 1.00, 1.50}
local RESET_TIME   = 2

function SWEP:SetSpeedStack(v) self:SetDTFloat(6, v) end
function SWEP:GetSpeedStack()  return self:GetDTFloat(6) end

function SWEP:GetWalkSpeed()
	return self.WalkSpeed * (1 + self:GetSpeedStack())
end

function SWEP:Initialize()
	self.m_BaseDelay = self.Primary.Delay
	BaseClass.Initialize(self)
end

function SWEP:Think()
	local stack = self:GetSpeedStack()
	self.Primary.Delay = self.m_BaseDelay / (1 + stack)

	if self.m_CachedStack ~= stack then
		self.m_CachedStack = stack
		local owner = self:GetOwner()
		if owner:IsValid() then owner:ResetSpeed() end
	end

	if stack > 0 and self.m_LastHitTime and (CurTime() - self.m_LastHitTime) >= RESET_TIME then
		if SERVER then self:SetSpeedStack(0) end
	end

	BaseClass.Think(self)
end

function SWEP:PlaySwingSound()
	self:EmitSound("weapons/knife/knife_slash"..math.random(2)..".wav")
end

function SWEP:PlayHitSound()
	self:EmitSound("physics/wood/wood_plank_impact_hard"..math.random(5)..".wav")
end

function SWEP:PlayHitFleshSound()
	self:EmitSound("physics/flesh/flesh_impact_bullet"..math.random(5)..".wav")
end

function SWEP:PostOnMeleeHit(hitent, hitflesh, tr)
	if SERVER and hitflesh and hitent:IsValid() and hitent:IsPlayer() then
		local tier = self.QualityTier or 0
		local cap  = STACK_CAP[tier + 1]
		self:SetSpeedStack(math.min(cap, self:GetSpeedStack() + STACK_PER_HIT[tier + 1]))
		self.m_LastHitTime = CurTime()
	end
end


