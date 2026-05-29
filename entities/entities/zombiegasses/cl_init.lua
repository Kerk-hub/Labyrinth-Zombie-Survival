-- Z-gas volunteer timer HUD logic
local VolunteerTimer = 0
local VolunteerTimerEnd = 0

net.Receive("zs_zgas_volunteertimer", function()
	local ply = net.ReadEntity()
	local timeleft = net.ReadFloat()
	if ply == LocalPlayer() then
		if timeleft > 0 then
			VolunteerTimer = timeleft
			VolunteerTimerEnd = CurTime() + timeleft
		else
			VolunteerTimer = 0
			VolunteerTimerEnd = 0
		end
	end
end)

hook.Add("HUDPaint", "ZS_ZGasVolunteerWarning", function()
	if VolunteerTimer > 0 and CurTime() < VolunteerTimerEnd then
		local w, h = ScrW(), ScrH()
		local msg = "YOU WILL VOLUNTEER FOR ZOMBIE TEAM SOON!"
		local font = "ZSHUDFontBig"
		local color = Color(220, 0, 0, 255)
		local timeleft = math.ceil(VolunteerTimerEnd - CurTime())
		draw.SimpleTextBlur(msg, font, w/2, h*0.3, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleTextBlur("("..timeleft.."s)", font, w/2, h*0.3+48, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end)

INC_CLIENT()
if not zs_zgas_volunteer_net_registered then
	zs_zgas_volunteer_net_registered = true
	if pcall(function() return util end) and util and util.AddNetworkString then
		util.AddNetworkString("zs_zgas_volunteertimer")
	end
end


ENT.NextGas = 0
ENT.NextSound = 0

local function BlendColor(col1, col2, frac)
	return Color(
		Lerp(frac, col1.r, col2.r),
		Lerp(frac, col1.g, col2.g),
		Lerp(frac, col1.b, col2.b),
		Lerp(frac, col1.a or 255, col2.a or 255)
	)
end

local function ShouldDrawWireZone(ent)
	if not MySelf:IsValid() or not MySelf:Alive() then
		return false
	end

	local pos = ent:GetPos()
	local radius = ent:GetRadius()
	local dist = MySelf:NearestPoint(pos):Distance(pos)

	return dist <= radius + 150
end

function ENT:Think()
	if GAMEMODE.ZombieEscape then return end

	if self.NextSound <= CurTime() then
		self.NextSound = CurTime() + math.Rand(4, 6)

		if 0 < GAMEMODE:GetWave() and MySelf:IsValid() and MySelf:Team() == TEAM_HUMAN and MySelf:Alive() then
			local mypos = self:GetPos()
			local eyepos = MySelf:NearestPoint(mypos)
			local radius = self:GetRadius()
			if eyepos:DistToSqr(mypos) <= radius * radius + 5184 and WorldVisible(eyepos, mypos) then
				MySelf:EmitSound("ambient/voices/cough"..math.random(4)..".wav")
			end
		end
	end
end

local particleTable = {
	[ 1 ] = { particle = "particle/smokesprites_0001", sizeStart = 0, sizeEnd = 96, airRecis = 90, startAlpha = 180, endAlpha = 0, randXY = 76, randZMin = 34, randZMax = 72, color = Color( 0, 80, 0 ), rotRate = 0.9, lifeTimeMin = 1.8, lifeTimeMax = 2.9 },
	[ 2 ] = { particle = "particle/smokesprites_0002", sizeStart = 0, sizeEnd = 90, airRecis = 76, startAlpha = 110, endAlpha = 0, randXY = 54, randZMin = 24, randZMax = 62, color = Color( 0, 120, 0 ), rotRate = 0.6, lifeTimeMin = 1.6, lifeTimeMax = 2.2 },
	[ 3 ] = { particle = "particle/smokesprites_0003", sizeStart = 0, sizeEnd = 140, airRecis = 49, startAlpha = 130, endAlpha = 0,randXY = 66, randZMin = 39, randZMax = 42, color = Color( 0, 90, 0 ), rotRate = 0.6, lifeTimeMin = 1.8, lifeTimeMax = 2.4 },
	[ 4 ] = { particle = "particle/smokesprites_0004", sizeStart = 0, sizeEnd = 100, airRecis = 59, startAlpha = 160, endAlpha = 0,randXY = 72, randZMin = 31, randZMax = 68, color = Color( 0, 60, 0 ), rotRate = 0.2, lifeTimeMin = 1.6, lifeTimeMax = 2.9 },
	[ 5 ] = { particle = "particle/smokesprites_0007", sizeStart = 0, sizeEnd = 160, airRecis = 79, startAlpha = 180, endAlpha = 0,randXY = 76, randZMin = 16, randZMax = 56, color = Color( 0, 70, 0 ), rotRate = 1.4, lifeTimeMin = 1.6, lifeTimeMax = 2.2 },
	[ 6 ] = { particle = "particle/smokesprites_0008", sizeStart = 0, sizeEnd = 60, airRecis = 46, startAlpha = 190, endAlpha = 0,randXY = 79, randZMin = 12, randZMax = 48, color = Color( 0, 90, 0 ), rotRate = 1, lifeTimeMin = 1.7, lifeTimeMax = 2.4 },
	[ 7 ] = { particle = "particle/particle_glow_03", sizeStart = 0, sizeEnd = 4, airRecis = 4, startAlpha = 255, endAlpha = 0,randXY = 59, randZMin = 16, randZMax = 64, color = Color( 0, 255, 0 ), rotRate = 0, lifeTimeMin = 1.5, lifeTimeMax = 2.8 },
}

function ENT:Draw()
	if GAMEMODE.ZombieEscape then return end

	local pos = self:GetPos()
	local radius = self:GetRadius()
	local showwire = ShouldDrawWireZone(self)

	if showwire then
		render.DrawWireframeSphere(pos, radius, 24, 16, Color(0, 180, 0, 255), true)
	end

	if CurTime() < self.NextGas then return end
	self.NextGas = CurTime() + math.Rand( 0.05, 0.25 )

	local vecRan = VectorRand()
	vecRan:Normalize()
	local particledata = particleTable[math.random(7)]
	vecRan = vecRan * math.Rand( 20, 40 )
	vecRan.z = math.Rand( 10, 60 )

	local emitter = ParticleEmitter( pos )
	emitter:SetNearClip( 48, 64 )

	local radiusmul = self:GetRadius() / 170
	local particlecolor = showwire and BlendColor(particledata.color, Color(10, 95, 10), 0.9) or particledata.color

	local particle = emitter:Add( particledata.particle, pos + vecRan )
	particle:SetVelocity( Vector( math.Rand(-particledata.randXY, particledata.randXY) * radiusmul * 2, math.Rand(-particledata.randXY, particledata.randXY) * radiusmul * 2, math.Rand(particledata.randZMin, particledata.randZMax) * radiusmul ))
	particle:SetColor( particlecolor.r, particlecolor.g, particlecolor.b )
	particle:SetAirResistance( particledata.airRecis )
	particle:SetCollide( true )
	particle:SetDieTime( math.Rand( particledata.lifeTimeMin , particledata.lifeTimeMax ) )
	particle:SetStartAlpha( particledata.startAlpha )
	particle:SetEndAlpha( particledata.endAlpha )
	particle:SetStartSize( particledata.sizeStart )
	particle:SetEndSize( particledata.sizeEnd )
	particle:SetRollDelta( math.Rand( -particledata.rotRate, particledata.rotRate ) )

	emitter:Finish() emitter = nil collectgarbage("step", 64)
end
