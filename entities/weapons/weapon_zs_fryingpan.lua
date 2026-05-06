AddCSLuaFile()

SWEP.PrintName = "Frying Pan"
SWEP.Description = "A heavy culinary pan. Hits ignite zombies. Hitting a burning zombie restores blood armor."

if CLIENT then
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 55

	SWEP.ShowViewModel = false
	SWEP.ShowWorldModel = false

	SWEP.VElements = {
		["base"] = { type = "Model", model = "models/props_c17/metalpot002a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(5, 1.368, -9), angle = Angle(-90, 90, -90), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
	SWEP.WElements = {
		["base"] = { type = "Model", model = "models/props_c17/metalpot002a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(5, 1.368, -9), angle = Angle(-90, 90, -90), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
end

SWEP.Base = "weapon_zs_basemelee"

SWEP.DamageType = DMG_CLUB

SWEP.ViewModel = "models/weapons/c_stunstick.mdl"
SWEP.WorldModel = "models/props_c17/metalpot002a.mdl"
SWEP.UseHands = true

SWEP.MeleeDamage = 90
SWEP.MeleeRange = 50
SWEP.MeleeSize = 1.15

SWEP.UseMelee1 = true

SWEP.HitGesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE
SWEP.MissGesture = SWEP.HitGesture

SWEP.SwingRotation = Angle(30, -30, -30)
SWEP.SwingTime = 0.3
SWEP.SwingHoldType = "grenade"

SWEP.AllowQualityWeapons = true
SWEP.Culinary = true
SWEP.CulinaryNoKillArmor = true
SWEP.QualityDescs = {
	"Blood armor on burning hit increased to 3.",
	"Blood armor on burning hit increased to 6.",
	"Blood armor on burning hit increased to 10.",
}

if SERVER then
	function SWEP:OnMeleeHit(hitent, hitflesh, tr)
		if not hitflesh or not hitent:IsValid() or hitent.SpawnProtection then return end
		local wasOnFire = hitent:IsOnFire()
		hitent:Ignite(3)
		if wasOnFire then
			local attacker = self:GetOwner()
			if attacker:IsValid() and attacker.MaxBloodArmor and attacker.MaxBloodArmor > 0 then
				local armorgain = ({1, 3, 6, 10})[(self.QualityTier or 0) + 1]
				attacker:SetBloodArmor(math.min(attacker.MaxBloodArmor, attacker:GetBloodArmor() + armorgain))
			end
		end
	end
end

function SWEP:PlayHitSound()
	self:EmitSound("weapons/melee/frying_pan/pan_hit-0"..math.random(4)..".ogg")
end
