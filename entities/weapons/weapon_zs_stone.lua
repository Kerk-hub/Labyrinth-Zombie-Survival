AddCSLuaFile()

SWEP.PrintName = "Stone"
SWEP.Description = "A heavy stone used for bashing and nailing props. Hold SHIFT to hurl it at zombies — it returns to you after a few seconds. You cannot nail or unnail props while the stone is in flight."

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
		["base"] = { type = "Model", model = "models/props_junk/rock001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(4.091, 3.181, -0.456), angle = Angle(-54.206, 58.294, -50.114), size = Vector(0.492, 0.492, 0.492), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}

	SWEP.WElements = {
		["base"] = { type = "Model", model = "models/props_junk/rock001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3.181, 2.273, -0.456), angle = Angle(-43.978, 27.614, 70.568), size = Vector(0.379, 0.379, 0.379), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
end

SWEP.Base = "weapon_zs_basemelee"
DEFINE_BASECLASS("weapon_zs_basemelee")

SWEP.ViewModel = "models/weapons/c_bugbait.mdl"
SWEP.WorldModel = "models/props_junk/rock001a.mdl"
SWEP.UseHands = true

SWEP.DamageType = DMG_CLUB

SWEP.MeleeDamage = 100
SWEP.MeleeRange = 55
SWEP.MeleeSize = 1.2
SWEP.Primary.Delay = 1.0

SWEP.ThrowAngVel = 360
SWEP.ThrowVel = 900

SWEP.AllowQualityWeapons = true

BUILDING_WEAPON_MIXIN.ApplyShared(SWEP)

if SERVER then
	BUILDING_WEAPON_MIXIN.ApplyServer(SWEP)

	-- Wrap mixin nail/unnail to block while stone is airborne
	local mixinNail   = SWEP.SecondaryAttack
	local mixinUnnail = SWEP.Reload

	function SWEP:SecondaryAttack()
		if self.StoneInFlight then return end
		mixinNail(self)
	end

	function SWEP:Reload()
		if self.StoneInFlight then return end
		mixinUnnail(self)
	end

	function SWEP:PrimaryAttack()
		if self.StoneInFlight then return end
		self.BaseClass.PrimaryAttack(self)
	end

	function SWEP:ThrowStone()
		if self.StoneInFlight then return end
		if CurTime() < self:GetNextPrimaryFire() then return end

		local owner = self:GetOwner()
		if not owner:IsValid() then return end

		self.StoneInFlight = true
		self:SetNextPrimaryFire(CurTime() + 0.5)

		local ent = ents.Create("projectile_stone")
		if ent:IsValid() then
			ent:SetPos(owner:GetShootPos())
			ent:SetOwner(owner)
			ent:Spawn()
			ent.Team = owner:Team()

			local phys = ent:GetPhysicsObject()
			if phys:IsValid() then
				phys:Wake()
				phys:AddAngleVelocity(VectorRand() * self.ThrowAngVel)
				phys:SetVelocityInstantaneous(owner:GetAimVector() * self.ThrowVel * (owner.ObjectThrowStrengthMul or 1))
			end

			ent:SetPhysicsAttacker(owner)
			self.ThrownStone = ent
		end

		owner:DoAnimationEvent(ACT_HL2MP_GESTURE_RANGE_ATTACK_GRENADE)
		self:SendWeaponAnim(ACT_VM_THROW)
	end

	function SWEP:Think()
		if self.BaseClass.Think then
			self.BaseClass.Think(self)
		end

		local owner = self:GetOwner()
		if not owner:IsValid() then return end

		-- Shift key throw
		if owner:KeyPressed(IN_SPEED) and self == owner:GetActiveWeapon() then
			self:ThrowStone()
		end

		-- Track stone and handle return
		if self.StoneInFlight then
			if self.ThrownStone and not self.ThrownStone:IsValid() then
				self.ThrownStone = nil
				self.StoneReturnTime = CurTime() + 3
			end

			if self.StoneReturnTime and CurTime() >= self.StoneReturnTime then
				self.StoneInFlight = false
				self.StoneReturnTime = nil
			end
		end
	end
end

if CLIENT then
	BUILDING_WEAPON_MIXIN.ApplyClient(SWEP)
end