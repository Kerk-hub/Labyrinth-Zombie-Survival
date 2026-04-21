INC_CLIENT()

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

local matGlow = Material("Sprites/light_glow02_add_noz")
local colCorpse = Color(220, 60, 60, 220)

function ENT:DrawTranslucent()
	if not GAMEMODE.m_ZombieVision or not MySelf:IsValidZombie() then
		return
	end

	local pos = self:WorldSpaceCenter()
	local pulse = math.sin(GAMEMODE.HeartBeatTime + self:EntIndex()) * 44 - 18

	render.SetMaterial(matGlow)
	cam.IgnoreZ(true)
		render.DrawSprite(pos, 14, 14, colCorpse)
		if pulse > 0 then
			render.DrawSprite(pos, pulse * 1.5, pulse, colCorpse)
			render.DrawSprite(pos, pulse, pulse * 1.5, colCorpse)
		end
	cam.IgnoreZ(false)
end