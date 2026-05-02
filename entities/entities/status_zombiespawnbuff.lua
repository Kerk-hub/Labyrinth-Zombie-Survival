AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "status__base"

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self.Seed = math.Rand(0, 10)
	local owner = self:GetOwner()
	if owner and owner:IsValid() then
		owner.SpawnProtection = true
		if SERVER then
			owner.ZS_OriginalSpeed = owner.ZS_OriginalSpeed or owner:GetWalkSpeed()
			owner:SetWalkSpeed(owner.ZS_OriginalSpeed * 3)
			owner:SetRunSpeed(owner.ZS_OriginalSpeed * 3)
		end
	end
end

function ENT:PlayerSet(pl)
	pl.SpawnProtection = true
	if SERVER then
		pl.ZS_OriginalSpeed = pl.ZS_OriginalSpeed or pl:GetWalkSpeed()
		pl:SetWalkSpeed(pl.ZS_OriginalSpeed * 3)
		pl:SetRunSpeed(pl.ZS_OriginalSpeed * 3)
	end
end

function ENT:OnRemove()
	self.BaseClass.OnRemove(self)
	local owner = self:GetOwner()
	if owner and owner:IsValid() then
		owner.SpawnProtection = false
		if SERVER and owner.ZS_OriginalSpeed then
			owner:SetWalkSpeed(owner.ZS_OriginalSpeed)
			owner:SetRunSpeed(owner.ZS_OriginalSpeed)
		end
	end
end

function ENT:SetDie(fTime)
	-- No timer-based expiration, indefinite until removed by logic
	self.DieTime = 999999999
end
