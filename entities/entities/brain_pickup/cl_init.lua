INC_CLIENT()
include("shared.lua")

function ENT:Draw()
	if self:IsValidBrainCollector(MySelf) then
		self:DrawModel()
	end
end
