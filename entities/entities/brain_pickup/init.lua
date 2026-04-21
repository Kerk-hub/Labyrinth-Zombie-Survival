INC_SERVER()
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

local BrainPickupColor = Color(255, 175, 215)

function ENT:Initialize()
	self:SetModel("models/Gibs/HGIBS.mdl")
	self:SetModelScale(2, 0)
	self:SetMaterial("models/flesh")
	self:SetColor(BrainPickupColor)
	self:SetRenderMode(RENDERMODE_TRANSCOLOR)
	self:DrawShadow(false)

	self:PhysicsInitSphere(10)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetTrigger(true)
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:SetMaterial("zombieflesh")
		phys:SetMass(20)
		phys:Wake()
	end
end

function ENT:GiveToPlayer(pl)
	if self.Removing or not self:IsValidBrainCollector(pl) then
		return
	end

	self.Removing = true
	pl:AddBrains(1)
	pl:AddLifeBrainsEaten(1)

	local classtab = pl:GetZombieClassTable()
	if classtab and classtab.Name then
		GAMEMODE.StatTracking:IncreaseElementKV(STATTRACK_TYPE_ZOMBIECLASS, classtab.Name, "BrainsEaten", 1)
	end

	pl:EmitSound("physics/flesh/flesh_squishy_impact_hard1.wav", 70, 120)
	self:Remove()
end

function ENT:StartTouch(ent)
	if ent:IsPlayer() then
		self:GiveToPlayer(ent)
	end
end

function ENT:Use(activator, caller)
	self:GiveToPlayer(activator)
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end
