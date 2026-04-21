ENT.Type = "anim"

ENT.CleanupPriority = 1

util.PrecacheModel("models/Gibs/HGIBS.mdl")

function ENT:IsValidBrainCollector(pl)
	return pl:IsValidLivingZombie() and not pl:GetZombieClassTable().Boss
end
