AddCSLuaFile()

SWEP.PrintName = "Meat Hook"
SWEP.Description = "A culinary hook. Hits cause bleeding. Taking damage spawns a gib. Destroying gibs and kills restore blood armor."

if CLIENT then
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 60

	SWEP.ShowViewModel = false
	SWEP.ShowWorldModel = false

	SWEP.VElements = {
		["base"] = { type = "Model", model = "models/props_junk/meathook001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(5, 1.363, -5), angle = Angle(0, 90, 0), size = Vector(0.5, 0.5, 0.5), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
	SWEP.WElements = {
		["base"] = { type = "Model", model = "models/props_junk/meathook001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3.181, 4, -9), angle = Angle(0, 0, 0), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
end

SWEP.Base = "weapon_zs_basemelee"

SWEP.DamageType = DMG_SLASH

SWEP.ViewModel = "models/weapons/c_crowbar.mdl"
SWEP.WorldModel = "models/props_junk/meathook001a.mdl"
SWEP.UseHands = true

SWEP.MeleeDamage = 70
SWEP.MeleeRange = 50
SWEP.MeleeSize = 1.15

SWEP.HitGesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE
SWEP.MissGesture = SWEP.HitGesture

SWEP.SwingRotation = Angle(30, -30, -30)
SWEP.SwingTime = 0.75
SWEP.SwingHoldType = "grenade"

SWEP.NoGlassWeapons = true

SWEP.AllowQualityWeapons = true
SWEP.Culinary = true
SWEP.CulinaryNoKillArmor = true

local HOOK_ARMOR = {10, 15, 20, 20}

SWEP.QualityDescs = {
	"Kills and gib destruction restore 15 blood armor.",
	"Kills and gib destruction restore 20 blood armor.",
	"Kills and gib destruction restore 20 blood armor. Kills and gib destruction also restore 5 health.",
}

function SWEP:CulinaryGibReward(attacker)
	if not attacker:IsValid() then return end
	local armor = HOOK_ARMOR[(self.QualityTier or 0) + 1]
	if attacker.MaxBloodArmor and attacker.MaxBloodArmor > 0 then
		attacker:SetBloodArmor(math.min(attacker.MaxBloodArmor, attacker:GetBloodArmor() + armor))
	end
	if self.QualityTier == 3 then
		attacker:SetHealth(math.min(attacker:GetMaxHealth(), attacker:Health() + 5))
	end
end

if SERVER then
	function SWEP:OnZombieKilled(pl, totaldamage, dmginfo)
		local attacker = self:GetOwner()
		if not attacker:IsValid() then return end
		self:CulinaryGibReward(attacker)
	end
end

function SWEP:PlaySwingSound()
	self:EmitSound("weapons/iceaxe/iceaxe_swing1.wav", 75, math.random(95, 105))
end

function SWEP:PlayHitFleshSound()
	self:EmitSound("physics/body/body_medium_break"..math.random(2, 4)..".wav", 75, math.random(120, 130))
end

function SWEP:PlayHitSound()
	self:EmitSound("physics/metal/metal_sheet_impact_bullet"..math.random(2)..".wav")
end

if SERVER then
	function SWEP:OnMeleeHit(hitent, hitflesh, tr)
		if not hitflesh or not hitent:IsValid() or not hitent:IsPlayer() or hitent.SpawnProtection then return end
		local bleed = hitent:GiveStatus("bleed")
		if bleed and bleed:IsValid() then
			bleed:AddDamage(30)
			bleed.Damager = self:GetOwner()
		end
	end
end

if SERVER then
	hook.Add("PostEntityTakeDamage", "meathook_gib_on_damage", function(ent, dmginfo, wasDamageTaken)
		if not wasDamageTaken then return end
		if not ent:IsValid() or not ent:IsPlayer() or ent:Team() ~= TEAM_HUMAN then return end
		local wep = ent:GetActiveWeapon()
		if not IsValid(wep) or wep:GetClass() ~= "weapon_zs_hook" then return end
		local gib = ents.CreateLimited("prop_playergib")
		if gib:IsValid() then
			gib:SetPos(ent:GetPos() + VectorRand():GetNormalized() * math.Rand(1, 8))
			gib:SetAngles(VectorRand():Angle())
			gib:SetGibType(math.random(3, #GAMEMODE.HumanGibs))
			gib:Spawn()
		end
	end)
end
