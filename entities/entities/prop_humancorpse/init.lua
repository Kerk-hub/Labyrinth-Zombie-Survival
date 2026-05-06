INC_SERVER()

local function ResolveZombieDamager(dmginfo)
	local attacker = dmginfo:GetAttacker()
	if attacker:IsValidLivingZombie() then
		return attacker
	end

	if attacker.GetOwner then
		local owner = attacker:GetOwner()
		if owner:IsValidLivingZombie() then
			return owner
		end
	end

	local inflictor = dmginfo:GetInflictor()
	if inflictor:IsValidLivingZombie() then
		return inflictor
	end

	if inflictor.GetOwner then
		local owner = inflictor:GetOwner()
		if owner:IsValidLivingZombie() then
			return owner
		end
	end
end

local function ResolveHumanMeleeDamager(dmginfo)
	local dmgtype = dmginfo:GetDamageType()
	local inflictor = dmginfo:GetInflictor()
	if bit.band(dmgtype, DMG_SLASH) == 0 and bit.band(dmgtype, DMG_CLUB) == 0 and not (inflictor and inflictor.IsMelee) then
		return
	end

	local attacker = dmginfo:GetAttacker()
	if attacker:IsPlayer() and attacker:Team() == TEAM_HUMAN then
		return attacker
	end
end

local function GetBloodDirection(dmginfo)
	local force = dmginfo:GetDamageForce()
	if force:LengthSqr() > 0 then
		return -force:GetNormalized()
	end

	return Vector(0, 0, 1)
end

local function SpawnHitGib(pos, dir)
	local ent = ents.CreateLimited("prop_playergib")
	if not ent:IsValid() then
		return
	end

	ent:SetPos(pos)
	ent:SetAngles(AngleRand())
	ent:SetGibType(math.random(3, #GAMEMODE.HumanGibs))
	ent:Spawn()

	local phys = ent:GetPhysicsObject()
	if phys:IsValid() then
		phys:ApplyForceCenter(dir * math.Rand(400, 900) + VectorRand() * 250 + Vector(0, 0, 200))
		phys:AddAngleVelocity(VectorRand() * 220)
	end
end

function ENT:Initialize()
	self.ObjHealth = self.ObjHealth or 175

	self:DrawShadow(false)
	self:SetNoDraw(true)
	self:PhysicsInitBox(self.BoxMin, self.BoxMax)
	self:SetCollisionBounds(self.BoxMin, self.BoxMax)
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
	self:SetMoveType(MOVETYPE_NONE)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(false)
		phys:Wake()
	end

	local fakebody = ents.Create("fakedeath")
	if fakebody:IsValid() then
		fakebody:SetOwner(self)
		fakebody:SetModel(self.CorpseModel or "models/player/Group01/male_07.mdl")
		fakebody:SetSkin(self.CorpseSkin or 0)
		fakebody:SetColor(self.CorpseColor or color_white)
		fakebody:SetMaterial(self.CorpseMaterial or "")
		fakebody:SetPos(self:GetPos())
		fakebody:Spawn()
		fakebody:SetModelScale(self.CorpseModelScale or 1, 0)
		fakebody:SetDeathSequence(self.CorpseSequence or 0)
		fakebody:SetDeathAngles(self.CorpseAngles or self:GetAngles())
		fakebody:SetDeathSequenceLength(1)
		fakebody:SetDeathSequenceStart(0)
		fakebody:SetRemoveTime(-1)

		self.FakeBody = fakebody
		self:DeleteOnRemove(fakebody)
	end
end

function ENT:OnTakeDamage(dmginfo)
	if self.Destroyed or dmginfo:GetDamage() <= 0 then
		return
	end

	self:TakePhysicsDamage(dmginfo)

	local attacker = ResolveZombieDamager(dmginfo)
	if not attacker then
		attacker = ResolveHumanMeleeDamager(dmginfo)
		if not attacker then
			return
		end
		dmginfo:SetDamage(math.min(dmginfo:GetDamage(), 35))
	end

	local bloodpos = dmginfo:GetDamagePosition()
	if bloodpos == vector_origin then
		bloodpos = self:WorldSpaceCenter()
	end

	GAMEMODE:DamageFloater(attacker, self, bloodpos, dmginfo:GetDamage())

	local blooddir = GetBloodDirection(dmginfo)
	util.Blood(bloodpos, math.max(1, math.ceil(dmginfo:GetDamage() / 20)), blooddir, 100, true)
	SpawnHitGib(bloodpos, blooddir)

	self.ObjHealth = self.ObjHealth - dmginfo:GetDamage()
	if self.ObjHealth <= 0 then
		self:DestroyCorpse()
	end
end

function ENT:DestroyCorpse()
	if self.Destroyed then
		return
	end

	self.Destroyed = true

	if self.FakeBody and self.FakeBody:IsValid() then
		self.FakeBody:Remove()
	end

	local pos = self:WorldSpaceCenter()
	local brainpickup = ents.Create("brain_pickup")
	if brainpickup:IsValid() then
		brainpickup:SetPos(pos + Vector(0, 0, 12))
		brainpickup:SetAngles(AngleRand())
		brainpickup:Spawn()

		local phys = brainpickup:GetPhysicsObject()
		if phys:IsValid() then
			phys:ApplyForceCenter(VectorRand():GetNormalized() * math.Rand(300, 700) + Vector(0, 0, 500))
			phys:AddAngleVelocity(VectorRand() * 200)
		end
	end

	util.Blood(pos, 12, self:GetUp(), 256, true)
	GAMEMODE:CreateGibs(pos)

	self:Remove()
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end
