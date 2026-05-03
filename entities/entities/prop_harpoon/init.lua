INC_SERVER()

ENT.NextDamage = 0
ENT.TicksLeft = 10

function ENT:Initialize()
	self:SetModel("models/props_junk/harpoon002a.mdl")
	self:SetSolid(SOLID_NONE)
	self:SetMoveType(MOVETYPE_NONE)
	self:AddEFlags(EFL_SETTING_UP_BONES)
end

function ENT:Think()
	local parent = self:GetParent()
	if parent:IsValid() and parent:IsPlayer() then
		if parent:Alive() and parent:Team() == TEAM_UNDEAD and self.TicksLeft >= 1 and not parent.SpawnProtection then
			if CurTime() >= self.NextDamage then
				self.NextDamage = CurTime() + 0.35
				self.TicksLeft = self.TicksLeft - 1

				util.Blood((parent:NearestPoint(self:GetPos()) + parent:WorldSpaceCenter()) / 2, math.random(4, 9), Vector(0, 0, 1), 100)
				parent:TakeSpecialDamage(self.BleedPerTick, DMG_SLASH, self:GetOwner(), self)
			end
		else
			self:Remove()
		end
	else
		self:Remove()
	end
end
