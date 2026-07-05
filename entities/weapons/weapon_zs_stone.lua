AddCSLuaFile()

SWEP.PrintName = "Stone"
SWEP.Description = "A simple stone found laying pretty much anywhere. \nPress PRIMARY ATTACK to hit. \nPress SECONDARY ATTACK to throw."

if CLIENT then
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 50
	SWEP.ShowViewModel = true
	SWEP.ShowWorldModel = false

	SWEP.ViewModelBoneMods = {
		["ValveBiped.cube1"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
		["ValveBiped.cube2"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
		["ValveBiped.cube3"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
		["ValveBiped.cube"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) }
	}

	SWEP.VElements = {
		["base"] = {
			type = "Model",
			model = "models/props_junk/rock001a.mdl",
			bone = "ValveBiped.Bip01_R_Hand",
			pos = Vector(4.091, 3.181, -0.456),
			angle = Angle(-54.206, 58.294, -50.114),
			size = Vector(0.492, 0.492, 0.492),
			color = Color(255, 255, 255, 255)
		}
	}

	SWEP.WElements = {
		["base"] = {
			type = "Model",
			model = "models/props_junk/rock001a.mdl",
			bone = "ValveBiped.Bip01_R_Hand",
			pos = Vector(3.181, 2.273, -0.456),
			angle = Angle(-43.978, 27.614, 70.568),
			size = Vector(0.379, 0.379, 0.379),
			color = Color(255, 255, 255, 255)
		}
	}
end

SWEP.Base = "weapon_zs_basemelee"
DEFINE_BASECLASS("weapon_zs_basemelee")

SWEP.ViewModel = "models/weapons/c_bugbait.mdl"
SWEP.WorldModel = "models/props_junk/rock001a.mdl"
SWEP.UseHands = true

SWEP.DamageType = DMG_CLUB

SWEP.MeleeDamage = 30
SWEP.MeleeRange = 50
SWEP.MeleeSize = 1.2
SWEP.Primary.Delay = 0.6
SWEP.MaxStock = 10

SWEP.ThrowVel = 700
SWEP.ThrowAngVel = 360

if SERVER then

	function SWEP:ThrowStone()
		local owner = self:GetOwner()
		if not IsValid(owner) then return end

		local ent = ents.Create("projectile_stone")
		if IsValid(ent) then
			ent:SetPos(owner:GetShootPos())
			ent:SetOwner(owner)
			ent:Spawn()

			local phys = ent:GetPhysicsObject()
			if IsValid(phys) then
				phys:Wake()
				phys:AddAngleVelocity(VectorRand() * self.ThrowAngVel)
				phys:SetVelocityInstantaneous(owner:GetAimVector() * self.ThrowVel)
			end
			ent.OwnerWeapon = self
		end
		owner:DoAnimationEvent(ACT_HL2MP_GESTURE_RANGE_ATTACK_GRENADE)
		self:SendWeaponAnim(ACT_VM_THROW)

		timer.Simple(0, function()
			if IsValid(owner) then
				owner:StripWeapon(self:GetClass())
			end
		end)
	end
	function SWEP:Think()
		self.BaseClass.Think(self)
		local owner = self:GetOwner()
		if not IsValid(owner) then return end

		if owner:KeyPressed(IN_ATTACK2) and self == owner:GetActiveWeapon() then
			self:ThrowStone()
		end
	end
end