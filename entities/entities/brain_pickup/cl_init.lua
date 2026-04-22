INC_CLIENT()
include("shared.lua")

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

local matGlow = Material("Sprites/light_glow02_add_noz")
local matPink = Material("models/debug/debugwhite")
local colBrain = Color(255, 110, 165, 220)
local pinkColorMod = {
	1,
	0.72,
	0.84,
}

local function DrawPinkBrain(ent)
	render.ModelMaterialOverride(matPink)
	render.SetColorModulation(pinkColorMod[1], pinkColorMod[2], pinkColorMod[3])
	render.SuppressEngineLighting(true)
	ent:DrawModel()
	render.SuppressEngineLighting(false)
	render.SetColorModulation(1, 1, 1)
	render.ModelMaterialOverride()
end

function ENT:Draw()
	if self:CanSeeBrainPickup(MySelf) then
		DrawPinkBrain(self)
	end
end

function ENT:DrawTranslucent()
	if not self:CanSeeBrainPickup(MySelf) then
		return
	end

	DrawPinkBrain(self)

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
