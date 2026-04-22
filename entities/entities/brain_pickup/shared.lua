ENT.Type = "anim"

ENT.CleanupPriority = 1

util.PrecacheModel("models/Gibs/HGIBS.mdl")

function ENT:CanSeeBrainPickup(pl)
	return pl:IsValidLivingZombie() and ((pl.IsZMain and pl:IsZMain()) or not pl:GetZombieClassTable().Boss)
end

function ENT:IsValidBrainCollector(pl)
	return self:CanSeeBrainPickup(pl) and not (pl.IsZMain and pl:IsZMain())
end
