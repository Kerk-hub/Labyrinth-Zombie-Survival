INC_SERVER()

function ENT:Initialize()
	self.DieTime = CurTime() + 30
	self.Damage = 30

	self:SetModel("models/props_junk/rock001a.mdl")

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	local phys = self:GetPhysicsObject()

	if IsValid(phys) then
		phys:Wake()
		phys:SetMass(5)

		-- Remove any possible crazy spin
		phys:SetAngleVelocity(Vector(0, 0, 0))
	end
end


function ENT:Think()
	if self.DieTime <= CurTime() then
		self:Remove()
		return
	end

	self:NextThink(CurTime())
	return true
end


function ENT:PhysicsCollide(data, phys)
	if IsValid(phys) then
		phys:SetVelocity(Vector(0,0,0))
		phys:SetAngleVelocity(Vector(0,0,0))
	end

	-- Remove after touching anything
	self:Remove()
end


function ENT:StartTouch(ent)
	if not IsValid(ent) then return end

	print("STONE TOUCH:", ent:GetClass())

	if ent:IsValidLivingPlayer() then
		local owner = self:GetOwner()

		if not IsValid(owner) then
			owner = self
		end

		if ent ~= owner then
			ent:TakeSpecialDamage(
				self.Damage,
				DMG_CLUB,
				owner,
				self,
				nil
			)
		end
	end

	self:Remove()
end