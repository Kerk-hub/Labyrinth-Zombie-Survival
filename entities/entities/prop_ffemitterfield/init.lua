INC_SERVER()

function ENT:Initialize()
	self:DrawShadow(false)
	self:SetModel("models/props_junk/TrashDumpster02b.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)

	self:SetCustomCollisionCheck(true)
	self:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(false)
		phys:Wake()
	end
end

function ENT:OnTakeDamage(dmginfo)
	local inflictor = dmginfo:GetInflictor():IsValid() and dmginfo:GetInflictor() or dmginfo:GetAttacker()
	if dmginfo:GetDamage() <= 0 or not inflictor:IsProjectile() then return end

	local attacker = dmginfo:GetAttacker()
	if not (attacker:IsValid() and attacker:IsPlayer() and attacker:Team() == TEAM_HUMAN) then
		local emitter = self:GetEmitter()

		if emitter and emitter:IsValid() and emitter:GetObjectHealth() > 0 then
			self:SetLastDamaged(CurTime())
			self:EmitSound("ambient/energy/weld2.wav", 65, 255, 0.6)
			local damage = dmginfo:GetDamage()

			emitter:SetObjectHealth(
				math.max(emitter:GetObjectHealth() - damage, 0)
			)
			local owner = emitter:GetObjectOwner()

			if owner:IsValidLivingHuman() then
				owner:AddPoints(damage * 0.02)
			end
		end
	end
end
