INC_CLIENT()
include("shared.lua")

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

local matGlow = Material("Sprites/light_glow02_add_noz")
local colBrain = Color(255, 110, 165, 220)

function ENT:Draw()
	if self:IsValidBrainCollector(MySelf) then
		self:DrawModel()
	end
end

function ENT:DrawTranslucent()
	if not self:IsValidBrainCollector(MySelf) then
		return
	end

	self:DrawModel()

	if not GAMEMODE.m_ZombieVision or not MySelf:IsValidZombie() then
		return
	end

	local pos = self:WorldSpaceCenter()
	local pulse = math.sin(GAMEMODE.HeartBeatTime + self:EntIndex()) * 36 - 12

	render.SetMaterial(matGlow)
	cam.IgnoreZ(true)
		render.DrawSprite(pos, 12, 12, colBrain)
		if pulse > 0 then
			render.DrawSprite(pos, pulse * 1.35, pulse, colBrain)
			render.DrawSprite(pos, pulse, pulse * 1.35, colBrain)
		end
	cam.IgnoreZ(false)
end
