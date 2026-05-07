AddCSLuaFile()
DEFINE_BASECLASS("weapon_zs_basemelee")

SWEP.PrintName = "Keyboard"
SWEP.Description = "Instantly kills knocked-down zombies. Each zombie kill grants a damage stack that persists while held. Nail and unnail props with SECONDARY FIRE and RELOAD."

if CLIENT then
	SWEP.ViewModelFOV = 55
	SWEP.ViewModelFlip = false

	SWEP.ShowViewModel = false
	SWEP.ShowWorldModel = false

	SWEP.ViewModelBoneMods = {
		["ValveBiped.Bip01_R_Finger02"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, -45.715, 0) },
		["ValveBiped.Bip01_R_Finger01"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, -49.524, 0) }
	}
	SWEP.VElements = {
		["base"] = { type = "Model", model = "models/props_c17/computer01_keyboard.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(4.091, 4.4, -7.728), angle = Angle(180, -82.842, 80.794), size = Vector(0.75, 0.75, 0.75), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
	SWEP.WElements = {
		["base"] = { type = "Model", model = "models/props_c17/computer01_keyboard.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(5, 4.091, -8.636), angle = Angle(180, -60.341, 90), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
end

SWEP.Base = "weapon_zs_basemelee"

SWEP.HoldType = "melee"

SWEP.DamageType = DMG_CLUB

SWEP.ViewModel = "models/weapons/c_stunstick.mdl"
SWEP.WorldModel = "models/props_c17/computer01_keyboard.mdl"
SWEP.UseHands = true

SWEP.MeleeDamage = 40
SWEP.m_BaseDamage = 40
SWEP.MeleeRange = 52
SWEP.MeleeSize = 1.25

SWEP.Primary.Delay = 0.75

SWEP.SwingTime = 0.3
SWEP.SwingRotation = Angle(30, -30, -30)
SWEP.SwingOffset = Vector(0, -30, 0)
SWEP.SwingHoldType = "grenade"

SWEP.AllowQualityWeapons = true
SWEP.DismantleDiv = 2

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

GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_FIRE_DELAY, -0.075)

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

function SWEP:PlayHitSound()
	self:EmitSound("weapons/melee/keyboard/keyboard_hit-0"..math.random(4)..".ogg")
end

if SERVER then
	BUILDING_WEAPON_MIXIN.ApplyServer(SWEP)

	function SWEP:Deploy()
		local owner = self:GetOwner()
		if IsValid(owner) then
			for _, wep in ipairs(owner:GetWeapons()) do
				if wep ~= self and (wep.BaseQuality or wep:GetClass()) == "weapon_zs_keyboard" then
					self:SetKillStacks(wep:GetKillStacks())
					break
				end
			end
		end
		return BaseClass.Deploy(self)
	end

	hook.Add("PostHumanKilledZombie", "KeyboardKillStacks", function(pl, attacker, inflictor, dmginfo, assistpl, assistamount, headshot)
		if not attacker:IsValid() or not attacker:IsPlayer() then return end
		local wep = attacker:GetActiveWeapon()
		if not wep:IsValid() then return end
		if (wep.BaseQuality or wep:GetClass()) ~= "weapon_zs_keyboard" then return end
		wep:SetKillStacks(wep:GetKillStacks() + 1)
	end)
end

if CLIENT then
	BUILDING_WEAPON_MIXIN.ApplyClient(SWEP)
end
