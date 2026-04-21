INC_CLIENT()

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

local matWhite = Material("models/debug/debugwhite")

local function IsZombieVisionCorpse(ent)
	local owner = ent:GetOwner()
	return owner:IsValid() and owner:GetClass() == "prop_humancorpse" and GAMEMODE.m_ZombieVision and MySelf:IsValidZombie()
end

function ENT:Initialize()
	self:SharedInitialize()
end

function ENT:DrawTranslucent()
	local cycle = math.Clamp((CurTime() - self.Created) * 0.8, 0, 1) * self:GetDeathSequenceLength() + self:GetDeathSequenceStart()
	local sequence = self:GetDeathSequence()

	if cycle == 1 then
		local idleseq = self:LookupSequence("zombie_slump_idle_01")
		if idleseq and idleseq > 0 then
			sequence = idleseq
		end
	end

	self:SetSequence(sequence)
	self:SetCycle(cycle)
	self:SetAngles(self:GetDeathAngles())

	local removetime = self:GetRemoveTime()
	local blend = removetime > 0 and math.Clamp(removetime - CurTime(), 0, 1) or 1

	cam.Start3D(EyePos() + Vector(0, 0, 4), EyeAngles())
		if IsZombieVisionCorpse(self) then
			cam.IgnoreZ(true)
			render.ModelMaterialOverride(matWhite)
			render.SetColorModulation(0.9, 0.15, 0.15)
			render.SuppressEngineLighting(true)
			render.SetBlend(0.8)
			self:DrawModel()
			render.SuppressEngineLighting(false)
			render.SetColorModulation(1, 1, 1)
			render.ModelMaterialOverride()
			cam.IgnoreZ(false)
		end

		render.SetBlend(blend)
		self:DrawModel()
		render.SetBlend(1)
	cam.End3D()
end
