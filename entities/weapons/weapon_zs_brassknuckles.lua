AddCSLuaFile()

SWEP.Base = "weapon_zs_fists"

SWEP.PrintName = "Brass Knuckles"
SWEP.Description = "Landing a hit with one hand charges up the opposite hand for a lightning-fast follow-up. Kills grant a burst of movement speed."

if CLIENT then
	SWEP.ViewModelFOV = 52
	SWEP.ViewModelFlip = false

	SWEP.ShowViewModel = false
	SWEP.ShowWorldModel = false

	SWEP.VElements = {
		["base"] = { type = "Model", model = "models/props_c17/utilityconnecter005.mdl", bone = "ValveBiped.Bip01_R_Finger2", rel = "", pos = Vector(1.129, -0.087, 0.4), angle = Angle(0, 15.421, 94.749), size = Vector(0.458, 0.349, 0.395), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["base+"] = { type = "Model", model = "models/props_c17/utilityconnecter005.mdl", bone = "ValveBiped.Bip01_L_Finger2", rel = "", pos = Vector(1.238, 0.136, -0.399), angle = Angle(2.473, 1.322, 83.697), size = Vector(0.458, 0.349, 0.395), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}

	SWEP.WElements = {
		["base"] = { type = "Model", model = "models/props_c17/utilityconnecter005.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(4.021, 1.006, 0), angle = Angle(0, -93.675, 100), size = Vector(0.458, 0.349, 0.395), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["base+"] = { type = "Model", model = "models/props_c17/utilityconnecter005.mdl", bone = "ValveBiped.Bip01_L_Hand", rel = "", pos = Vector(4.085, 0.674, 0), angle = Angle(0, -99.708, 82.794), size = Vector(0.458, 0.349, 0.395), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
end

SWEP.WalkSpeed = SPEED_FASTEST

SWEP.ViewModel = "models/weapons/c_arms_citizen.mdl"
SWEP.WorldModel	= "models/weapons/w_grenade.mdl"

SWEP.Weight = 4

SWEP.MeleeDamage = 40

SWEP.Unarmed = false

SWEP.Undroppable = false
SWEP.NoPickupNotification = false
SWEP.NoDismantle = false

SWEP.NoGlassWeapons = false

SWEP.AllowQualityWeapons = true
SWEP.QualityDescs = {
	"On kill: +20% speed for 9 seconds.",
	"On kill: +30% speed for 11 seconds.",
	"On kill: +40% speed for 13 seconds.",
}

GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_FIRE_DELAY, -0.06)

-- Hitting with M1 makes the next M2 instant (and vice versa).
-- Stored as m_FastNextHand: true = right hand gets bonus, false = left hand gets bonus.
function SWEP:OnKnuckleHit(isRight, hitent)
	if not hitent:IsValid() then return end
	-- Grant speed bonus to opposite hand
	self.m_FastNextHand = not isRight
end

-- Speed buff values: additive walk speed per tier (SPEED_NORMAL = 200)
local SPEED_BONUS  = {40, 60, 80, 100}
local BUFF_DURATION = {7, 9, 11, 13}

if SERVER then
	hook.Add("PostHumanKilledZombie", "BrassKnucklesSpeedBoost", function(pl, attacker, inflictor)
		if not attacker:IsValid() or not attacker:IsPlayer() then return end
		local wep = attacker:GetActiveWeapon()
		if not wep:IsValid() then return end
		if (wep.BaseQuality or wep:GetClass()) ~= "weapon_zs_brassknuckles" then return end
		local tier = wep.QualityTier or 0
		local boost = attacker:GiveStatus("adrenalineamp", BUFF_DURATION[tier + 1])
		if boost and boost:IsValid() then
			boost:SetSpeed(SPEED_BONUS[tier + 1])
		end
	end)
end
