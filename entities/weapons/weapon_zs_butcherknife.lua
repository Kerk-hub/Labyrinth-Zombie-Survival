AddCSLuaFile()
DEFINE_BASECLASS("weapon_zs_basemelee")

SWEP.PrintName = "Butcher Knife"
SWEP.Description = "A culinary cleaver. Hits build attack speed up to a cap. Kills and gib destruction restore blood armor."

if CLIENT then
	SWEP.ViewModelFOV = 55
	SWEP.ViewModelFlip = false

	SWEP.ShowViewModel = false
	SWEP.ShowWorldModel = false
	SWEP.VElements = {
		["base"] = { type = "Model", model = "models/props_lab/cleaver.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3, 1, -1), angle = Angle(90, 0, 0), size = Vector(0.8, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
	SWEP.WElements = {
		["base"] = { type = "Model", model = "models/props_lab/cleaver.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3, 1, -3.182), angle = Angle(90, 0, 0), size = Vector(0.8, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
end

SWEP.Base = "weapon_zs_basemelee"

SWEP.DamageType = DMG_SLASH

SWEP.ViewModel = "models/weapons/c_crowbar.mdl"
SWEP.WorldModel = "models/weapons/w_crowbar.mdl"
SWEP.UseHands = true
SWEP.NoDroppedWorldModel = true
--[[SWEP.BoxPhysicsMax = Vector(8, 1, 4)
SWEP.BoxPhysicsMin = Vector(-8, -1, -4)]]

SWEP.MeleeDamage = 40
SWEP.MeleeRange = 48
SWEP.MeleeSize = 0.875
SWEP.Primary.Delay = 0.5

SWEP.WalkSpeed = SPEED_FAST

SWEP.UseMelee1 = true

SWEP.HitGesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE
SWEP.MissGesture = SWEP.HitGesture

SWEP.HitDecal = "Manhackcut"
SWEP.HitAnim = ACT_VM_MISSCENTER

SWEP.Tier = 2

SWEP.AllowQualityWeapons = true
SWEP.Culinary = true
SWEP.QualityDescs = {
	"Each hit adds 5% attack speed, capped at 50%. Resets after 2s without a hit.",
	"Each hit adds 10% attack speed, capped at 100%. Resets after 2s without a hit.",
	"Each hit adds 15% attack speed, capped at 150%. Resets after 2s without a hit.",
}

local STACK_PER_HIT = {0.03, 0.05, 0.10, 0.15}
local STACK_CAP    = {0.30, 0.50, 1.00, 1.50}
local RESET_TIME   = 2

function SWEP:SetSpeedStack(v)
	self:SetDTFloat(6, v)
end

function SWEP:GetSpeedStack()
	return self:GetDTFloat(6)
end

function SWEP:GetFireDelay()
	local base = self.Primary.Delay
	local frost = self:GetOwner():GetStatus("frost") and 0.7 or 1
	return (base / frost) / (1 + self:GetSpeedStack())
end

function SWEP:Think()
	if self:GetSpeedStack() > 0 then
		if self.m_LastHitTime and (CurTime() - self.m_LastHitTime) >= RESET_TIME then
			self:SetSpeedStack(0)
		end
	end
	BaseClass.Think(self)
end

function SWEP:PlaySwingSound()
	self:EmitSound("weapons/knife/knife_slash"..math.random(2)..".wav", 72, math.Rand(85, 95))
end

function SWEP:PlayHitSound()
	self:EmitSound("weapons/knife/knife_hitwall1.wav", 72, math.Rand(75, 85))
end

function SWEP:PlayHitFleshSound()
	self:EmitSound("physics/flesh/flesh_squishy_impact_hard"..math.random(4)..".wav")
	self:EmitSound("physics/body/body_medium_break"..math.random(2, 4)..".wav")
end

function SWEP:PostOnMeleeHit(hitent, hitflesh, tr)
	if SERVER and hitflesh and hitent:IsValid() and hitent:IsPlayer() then
		local tier = self.QualityTier or 0
		local step = STACK_PER_HIT[tier + 1]
		local cap  = STACK_CAP[tier + 1]
		local newstack = math.min(cap, self:GetSpeedStack() + step)
		self:SetSpeedStack(newstack)
		self.m_LastHitTime = CurTime()
	end
end
