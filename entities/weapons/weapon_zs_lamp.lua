AddCSLuaFile()

SWEP.PrintName = "Lamp"

if CLIENT then
	SWEP.ViewModelFOV = 65
	SWEP.ViewModelFlip = false

	SWEP.ShowViewModel = false
	SWEP.ShowWorldModel = false
	SWEP.VElements = {
		["base"] = { type = "Model", model = "models/props_interiors/Furniture_Lamp01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3, 1.85, -8), angle = Angle(183, 0, 2), size = Vector(1.5, 1.5, 1.5), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
	SWEP.WElements = {
		["base"] = { type = "Model", model = "models/props_interiors/Furniture_Lamp01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(2.837, 1.638, -10), angle = Angle(180, 0, 0), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
end

SWEP.Base = "weapon_zs_basemelee"

SWEP.ViewModel = "models/weapons/c_stunstick.mdl"
SWEP.WorldModel = "models/props_interiors/Furniture_Lamp01a.mdl"
SWEP.UseHands = true

SWEP.HoldType = "melee2"

SWEP.DamageType = DMG_CLUB

SWEP.Description = "Long reach. Hits ignite the target, dealing half of the weapon's damage as burn over 3 seconds."

SWEP.MeleeDamage = 120
SWEP.MeleeRange = 120
SWEP.MeleeSize = 2

SWEP.Primary.Delay = 1.5

SWEP.WalkSpeed = SPEED_SLOW

SWEP.SwingRotation = Angle(0, -90, -60)
SWEP.SwingOffset = Vector(0, 30, -40)
SWEP.SwingTime = 0.4
SWEP.SwingHoldType = "melee"

SWEP.AllowQualityWeapons = true
SWEP.DismantleDiv = 2

if SERVER then
	function SWEP:OnMeleeHit(hitent, hitflesh, tr)
		if hitflesh and hitent:IsValid() and hitent:IsPlayer() and not hitent.SpawnProtection then
			local burnTotal = math.floor(self.MeleeDamage * 0.5)
			local attacker = self:GetOwner()
			hitent:Ignite(3)
			local timerName = "lamp_burn_" .. hitent:EntIndex()
			timer.Remove(timerName)
			local tickDmg = math.ceil(burnTotal / 6)
			local entRef = hitent
			timer.Create(timerName, 0.5, 6, function()
				if IsValid(entRef) and IsValid(attacker) then
					entRef:AddDamage(tickDmg, attacker, attacker)
				end
			end)
		end
	end
end

function SWEP:PlaySwingSound()
	self:EmitSound("weapons/iceaxe/iceaxe_swing1.wav", 80, math.Rand(65, 70))
end

function SWEP:PlayHitSound()
	self:EmitSound("physics/metal/metal_solid_impact_hard"..math.random(4, 5)..".wav")
end

function SWEP:PlayHitFleshSound()
	self:EmitSound("physics/body/body_medium_break"..math.random(2, 4)..".wav")
end
