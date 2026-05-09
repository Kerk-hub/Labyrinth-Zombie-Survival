AddCSLuaFile()
DEFINE_BASECLASS("weapon_zs_basemelee")

SWEP.PrintName = "Grave Shovel"
SWEP.Description = "Instantly kills knocked-down zombies. Each zombie kill grants a damage stack that persists while held. Nail and unnail props with SECONDARY FIRE and RELOAD."

if CLIENT then
	SWEP.ViewModelFOV = 60

	SWEP.ShowViewModel = false
	SWEP.ShowWorldModel = false

	SWEP.VElements = {
		["base"] = { type = "Model", model = "models/props_junk/shovel01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(1.363, 1.363, -7.728), angle = Angle(0, 0, 0), size = Vector(0.899, 0.899, 0.899), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
	SWEP.WElements = {
		["base"] = { type = "Model", model = "models/props_junk/shovel01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(5, 1.363, -15), angle = Angle(-3, 180, 0), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
end

SWEP.Base = "weapon_zs_basemelee"

SWEP.HoldType = "melee2"

SWEP.DamageType = DMG_CLUB

SWEP.ViewModel = "models/weapons/c_crowbar.mdl"
SWEP.WorldModel = "models/props_junk/shovel01a.mdl"
SWEP.UseHands = true

SWEP.MeleeDamage = 45
SWEP.m_BaseDamage = 45
SWEP.MeleeRange = 68
SWEP.MeleeSize = 1.5
SWEP.MeleeKnockBack = 200

SWEP.Primary.Delay = 1.2

SWEP.Tier = 2

SWEP.WalkSpeed = SPEED_SLOWER

SWEP.SwingRotation = Angle(0, -90, -60)
SWEP.SwingOffset = Vector(0, 30, -40)
SWEP.SwingTime = 0.65
SWEP.SwingHoldType = "melee"

SWEP.AllowQualityWeapons = true
SWEP.QualityDescs = {
	"Each kill grants a damage stack. Each stack adds 4 damage.",
	"Each kill grants a damage stack. Each stack adds 6 damage.",
	"Each kill grants a damage stack. Each stack adds 8 damage.",
}

SWEP.NailDelay   = 1.0
SWEP.UnnailDelay = 1.5

-- DTInt(2): kill stack count
function SWEP:SetKillStacks(v) self:SetDTInt(2, v) end
function SWEP:GetKillStacks() return self:GetDTInt(2) end

local DAMAGE_PER_STACK = {2, 4, 6, 8}

BUILDING_WEAPON_MIXIN.ApplyShared(SWEP)

GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_FIRE_DELAY, -0.09, 1)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MELEE_IMPACT_DELAY, -0.06, 1)

function SWEP:Think()
	local tier = self.QualityTier or 0
	self.MeleeDamage = self.m_BaseDamage + self:GetKillStacks() * DAMAGE_PER_STACK[tier + 1]
	BaseClass.Think(self)
end

function SWEP:PostOnMeleeHit(hitent, hitflesh, tr)
	if hitent:IsValid() and hitent:IsPlayer() and hitent.Revive and hitent.Revive:IsValid() and gamemode.Call("PlayerShouldTakeDamage", hitent, self:GetOwner()) then
		hitent:TakeSpecialDamage(hitent:Health(), DMG_DIRECT, self:GetOwner(), self, tr.HitPos)
	end
end

function SWEP:PlaySwingSound()
	self:EmitSound("weapons/iceaxe/iceaxe_swing1.wav", 75, math.random(65, 70))
end

function SWEP:PlayHitSound()
	self:EmitSound("weapons/melee/shovel/shovel_hit-0"..math.random(4)..".ogg")
end

function SWEP:PlayHitFleshSound()
	self:EmitSound("physics/body/body_medium_break"..math.random(2, 4)..".wav")
end

if SERVER then
	BUILDING_WEAPON_MIXIN.ApplyServer(SWEP)

	function SWEP:Deploy()
		local owner = self:GetOwner()
		if IsValid(owner) then
			for _, wep in ipairs(owner:GetWeapons()) do
				if wep ~= self and (wep.BaseQuality or wep:GetClass()) == "weapon_zs_graveshovel" then
					self:SetKillStacks(wep:GetKillStacks())
					break
				end
			end
		end
		return BaseClass.Deploy(self)
	end

	hook.Add("PostHumanKilledZombie", "GraveShovelKillStacks", function(pl, attacker, inflictor, dmginfo, assistpl, assistamount, headshot)
		if not attacker:IsValid() or not attacker:IsPlayer() then return end
		local wep = attacker:GetActiveWeapon()
		if not wep:IsValid() then return end
		if (wep.BaseQuality or wep:GetClass()) ~= "weapon_zs_graveshovel" then return end
		wep:SetKillStacks(wep:GetKillStacks() + 1)
	end)
end

if CLIENT then
	BUILDING_WEAPON_MIXIN.ApplyClient(SWEP)
end
