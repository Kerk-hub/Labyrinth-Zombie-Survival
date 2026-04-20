local PANEL = {}

local colorStateMatte = Color(6, 10, 12, 235)
local colorStateMatteInner = Color(10, 18, 20, 242)
local colorStateSteelDark = Color(24, 50, 52, 235)
local colorStateSteelLight = Color(120, 220, 205, 110)
local colorStateReadout = Color(184, 255, 244)
local colorStateReadoutSoft = Color(126, 235, 220)
local colorStateWarning = Color(255, 204, 122)
local colorStateAlert = Color(255, 116, 116)

surface.CreateFont("ZSMedMonitorHeader", {
	font = "Tahoma",
	size = 11,
	weight = 900,
	antialias = true
})

local function ShouldUseOriginalHUD()
	return GAMEMODE and GAMEMODE.OriginalHUD
end

local function GetMonitorReadoutColors()
	if ShouldUseOriginalHUD() then
		return Color(170, 255, 170), Color(110, 235, 110), Color(40, 170, 40, 90)
	end

	local baseCol = GAMEMODE and GAMEMODE.GameStatePanelColor or colorStateMatte
	local readoutCol = Color(
		math.Clamp(baseCol.r + 150, 125, 255),
		math.Clamp(baseCol.g + 150, 125, 255),
		math.Clamp(baseCol.b + 150, 125, 255),
		255
	)
	local readoutSoftCol = Color(
		math.Clamp(baseCol.r + 110, 105, 245),
		math.Clamp(baseCol.g + 110, 105, 245),
		math.Clamp(baseCol.b + 110, 105, 245),
		235
	)
	local accentCol = Color(
		math.Clamp(baseCol.r + 75, 80, 235),
		math.Clamp(baseCol.g + 85, 80, 235),
		math.Clamp(baseCol.b + 85, 80, 235),
		110
	)

	return readoutCol, readoutSoftCol, accentCol
end

local function DrawMedicalMonitorFrame(w, h)
	local baseCol = GAMEMODE and GAMEMODE.GameStatePanelColor or colorStateMatte
	local readoutCol, readoutSoftCol, accentCol = GetMonitorReadoutColors()
	local frameAlpha = math.Clamp((baseCol.a or 230) - 28, 130, 220)
	local pad = math.max(8, math.floor(math.min(w, h) * 0.07))
	local headerH = math.max(13, math.floor(h * 0.12))
	local gridTop = pad + headerH + 5
	local gridBottom = h - pad

	if ShouldUseOriginalHUD() then
		local lineCol = Color(60, 200, 60, 34)
		local borderCol = Color(20, 110, 20, 170)
		local dividerX = 42
		draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, 180))
		draw.RoundedBox(4, 2, 2, w - 4, h - 4, Color(8, 18, 8, 125))
		surface.SetDrawColor(borderCol)
		surface.DrawOutlinedRect(0, 0, w, h, 1)
		surface.DrawOutlinedRect(1, 1, w - 2, h - 2, 1)
		surface.SetDrawColor(lineCol)
		surface.DrawLine(dividerX, 6, dividerX, h - 6)
		surface.DrawLine(dividerX + 4, 26, w - 8, 26)
		surface.DrawLine(dividerX + 4, 50, w - 8, 50)
		return
	end

	local bezelCol = Color(math.max(baseCol.r - 12, 0), math.max(baseCol.g - 10, 0), math.max(baseCol.b - 8, 0), math.min(frameAlpha + 10, 230))
	local frameCol = Color(baseCol.r, baseCol.g, baseCol.b, frameAlpha)
	local innerCol = Color(math.min(baseCol.r + 6, 255), math.min(baseCol.g + 12, 255), math.min(baseCol.b + 10, 255), math.max(frameAlpha - 6, 120))
	local screenCol = Color(6, 20, 18, math.max(frameAlpha - 12, 115))
	local headerCol = Color(math.max(baseCol.r - 4, 0), math.min(baseCol.g + 16, 255), math.min(baseCol.b + 12, 255), math.min(frameAlpha + 4, 210))
	local glowCol = Color(accentCol.r, accentCol.g, accentCol.b, 16)

	draw.RoundedBox(10, 0, 0, w, h, bezelCol)
	draw.RoundedBox(8, 2, 2, w - 4, h - 4, frameCol)
	draw.RoundedBox(8, 4, 4, w - 8, h - 8, innerCol)
	draw.RoundedBox(6, pad, pad, w - pad * 2, h - pad * 2, screenCol)

	draw.RoundedBox(4, pad + 2, pad, w - (pad + 2) * 2, headerH, headerCol)
	draw.SimpleText("PATIENT VITALS", "ZSMedMonitorHeader", pad + 8, pad + 2, readoutSoftCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	draw.SimpleText("ONLINE", "ZSMedMonitorHeader", w - pad - 8, pad + 2, readoutSoftCol, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)

	surface.SetDrawColor(colorStateSteelDark)
	surface.DrawOutlinedRect(0, 0, w, h, 1)
	surface.SetDrawColor(accentCol.r, accentCol.g, accentCol.b, 90)
	surface.DrawOutlinedRect(1, 1, w - 2, h - 2, 1)
	surface.SetDrawColor(readoutCol.r, readoutCol.g, readoutCol.b, 12)
	surface.DrawRect(pad + 4, pad + 2, w - (pad + 4) * 2, 1)

	surface.SetDrawColor(glowCol)
	surface.DrawRect(pad + 2, gridTop, w - (pad + 2) * 2, gridBottom - gridTop)

	surface.SetDrawColor(accentCol.r, accentCol.g, accentCol.b, 28)
	for x = pad + 4, w - pad - 4, math.max(14, math.floor(w * 0.043)) do
		surface.DrawLine(x, gridTop, x, gridBottom)
	end

	surface.SetDrawColor(accentCol.r, accentCol.g, accentCol.b, 20)
	for y = gridTop + 2, gridBottom, math.max(8, math.floor(h * 0.085)) do
		surface.DrawLine(pad + 2, y, w - pad - 2, y)
	end

	local dividerX = math.max(pad + 42, math.floor(w * 0.18))
	surface.SetDrawColor(readoutSoftCol.r, readoutSoftCol.g, readoutSoftCol.b, 90)
	surface.DrawLine(dividerX, gridTop, dividerX, gridBottom)
	surface.DrawLine(dividerX + 6, h * 0.40, w - pad - 2, h * 0.40)
	surface.DrawLine(dividerX + 6, h * 0.65, w - pad - 2, h * 0.65)

	local cx = w - math.max(92, math.floor(w * 0.28))
	local cy = pad + math.floor(headerH * 0.55)
	surface.SetDrawColor(readoutCol.r, readoutCol.g, readoutCol.b, 145)
	surface.DrawLine(cx, cy, cx + 10, cy)
	surface.DrawLine(cx + 10, cy, cx + 16, cy - 4)
	surface.DrawLine(cx + 16, cy - 4, cx + 22, cy + 6)
	surface.DrawLine(cx + 22, cy + 6, cx + 28, cy)
	surface.DrawLine(cx + 28, cy, cx + 42, cy)
end

function PANEL:Init()
	self.m_HumanCount = vgui.Create("DTeamCounter", self)
	self.m_HumanCount:SetTeam(TEAM_HUMAN)
	self.m_HumanCount:SetImage("zombiesurvival/humanhead")

	self.m_ZombieCount = vgui.Create("DTeamCounter", self)
	self.m_ZombieCount:SetTeam(TEAM_UNDEAD)
	self.m_ZombieCount:SetImage("zombiesurvival/zombiehead")

	self.m_Text1 = vgui.Create("DLabel", self)
	self.m_Text2 = vgui.Create("DLabel", self)
	self.m_Text3 = vgui.Create("DLabel", self)
	self:SetTextFont("ZSHUDFontTiny")

	self.m_Text1.Paint = self.Text1Paint
	self.m_Text2.Paint = self.Text2Paint
	self.m_Text3.Paint = self.Text3Paint

	self:InvalidateLayout()
end

function PANEL:SetTextFont(font)
	self.m_Text1.Font = font
	self.m_Text1:SetFont(font)
	self.m_Text2.Font = font
	self.m_Text2:SetFont(font)
	self.m_Text3.Font = font
	self.m_Text3:SetFont(font)

	self:InvalidateLayout()
end

function PANEL:PerformLayout()
	local w, h = self:GetWide(), self:GetTall()

	if ShouldUseOriginalHUD() then
		local hs = self:GetTall() * 0.5
		self.m_HumanCount:SetSize(hs, hs)
		self.m_ZombieCount:SetSize(hs, hs)
		self.m_ZombieCount:AlignTop(hs)

		self.m_Text1:SetWide(self:GetWide())
		self.m_Text1:SizeToContentsY()
		self.m_Text1:MoveRightOf(self.m_HumanCount, 12)
		self.m_Text1:AlignTop(4)
		self.m_Text2:SetWide(self:GetWide())
		self.m_Text2:SizeToContentsY()
		self.m_Text2:MoveRightOf(self.m_HumanCount, 12)
		self.m_Text2:CenterVertical()
		self.m_Text3:SetWide(self:GetWide())
		self.m_Text3:SizeToContentsY()
		self.m_Text3:MoveRightOf(self.m_HumanCount, 12)
		self.m_Text3:AlignBottom(4)
		return
	end

	local pad = math.max(8, math.floor(w * 0.02))
	local topy = math.max(26, math.floor(h * 0.28))
	local bottomPad = math.max(8, math.floor(h * 0.08))
	local gap = math.max(6, math.floor(h * 0.05))
	local iconColumnW = math.max(54, math.floor(w * 0.17))
	local textx = pad + iconColumnW + math.max(8, math.floor(w * 0.025))
	local usableh = h - topy - bottomPad
	local lineh = math.max(18, math.floor((usableh - gap * 2) / 3))
	local row1y = topy
	local row2y = row1y + lineh + gap
	local row3y = row2y + lineh + gap
	local hs = math.max(24, math.min(32, lineh + 8))
	local iconx = pad + math.floor((iconColumnW - hs) * 0.5)
	local iconOffset = math.max(0, math.floor((lineh - hs) * 0.5))

	self.m_HumanCount:SetSize(hs, hs)
	self.m_HumanCount:SetPos(iconx, row1y + iconOffset)

	self.m_ZombieCount:SetSize(hs, hs)
	self.m_ZombieCount:SetPos(iconx - 2, row2y + iconOffset + 1)

	self.m_Text1:SetSize(w - textx - pad, lineh + 4)
	self.m_Text1:SetPos(textx, row1y)

	self.m_Text2:SetSize(w - textx - pad, lineh + 4)
	self.m_Text2:SetPos(textx, row2y)

	self.m_Text3:SetSize(w - textx - pad, lineh + 6)
	self.m_Text3:SetPos(textx, row3y)
end

function PANEL:Text1Paint()
	local text
	local override = MySelf:IsValid() and GetGlobalString("hudoverride" .. MySelf:Team(), "")

	if override and #override > 0 then
		text = override
	else
		local wave = GAMEMODE:GetWave()
		if GAMEMODE:IsEscapeSequence() then
			text = translate.Get(
				MySelf:IsValid() and MySelf:Team() == TEAM_UNDEAD and "prop_obj_exit_z" or "prop_obj_exit_h"
			)
		elseif wave <= 0 then
			text = translate.Get("prepare_yourself")
		elseif GAMEMODE.ZombieEscape then
			text = translate.Get("zombie_escape")

			-- I'm gonna leave this as 2 for now, since it is 2 on NoX.
			--if GAMEMODE.RoundLimit > 0 then
			round = GAMEMODE.CurrentRound
			text = text .. " - " .. translate.Format("round_x_of_y", round, 2)
			--end
		else
			local maxwaves = GAMEMODE:GetNumberOfWaves()
			if maxwaves ~= -1 then
				text = translate.Format("wave_x_of_y", wave, maxwaves)
				if not GAMEMODE:GetWaveActive() then
					text = translate.Get("intermission") .. " - " .. text
				end
			elseif not GAMEMODE:GetWaveActive() then
				text = translate.Get("intermission")
			end
		end
	end

	if text then
		if ShouldUseOriginalHUD() then
			draw.SimpleText(text, self.Font, 0, 0, COLOR_GRAY)
		else
			local readoutCol = GetMonitorReadoutColors()
			draw.SimpleText(text, self.Font, 2, self:GetTall() * 0.52, readoutCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end
	end

	return true
end

function PANEL:Text2Paint()
	if ShouldUseOriginalHUD() then
		if GAMEMODE:GetWave() <= 0 then
			local col
			local timeleft = math.max(0, GAMEMODE:GetWaveStart() - CurTime())
			if timeleft < 10 then
				local glow = math.sin(RealTime() * 8) * 200 + 255
				col = Color(255, glow, glow)
			else
				col = COLOR_GRAY
			end

			draw.SimpleText(translate.Format("zombie_invasion_in_x", util.ToMinutesSecondsCD(timeleft)), self.Font, 0, 0, col)
		elseif GAMEMODE:GetWaveActive() then
			local waveend = GAMEMODE:GetWaveEnd()
			if waveend ~= -1 then
				local timeleft = math.max(0, waveend - CurTime())
				draw.SimpleText(translate.Format("wave_ends_in_x", util.ToMinutesSecondsCD(timeleft)), self.Font, 0, 0, 10 < timeleft and COLOR_GRAY or Color(255, 0, 0, math.abs(math.sin(RealTime() * 8)) * 180 + 40))
			end
		else
			local wavestart = GAMEMODE:GetWaveStart()
			if wavestart ~= -1 then
				local timeleft = math.max(0, wavestart - CurTime())
				draw.SimpleText(translate.Format("next_wave_in_x", util.ToMinutesSecondsCD(timeleft)), self.Font, 0, 0, 10 < timeleft and COLOR_GRAY or Color(255, 0, 0, math.abs(math.sin(RealTime() * 8)) * 180 + 40))
			end
		end

		return true
	end

	local readoutCol, readoutSoftCol = GetMonitorReadoutColors()

	if GAMEMODE:GetWave() <= 0 then
		local col
		local timeleft = math.max(0, GAMEMODE:GetWaveStart() - CurTime())
		if timeleft < 10 then
			col = Color(readoutCol.r, readoutCol.g, readoutCol.b, math.abs(math.sin(RealTime() * 8)) * 180 + 40)
		else
			col = readoutSoftCol
		end

		draw.SimpleText(
			translate.Format("zombie_invasion_in_x", util.ToMinutesSecondsCD(timeleft)),
			self.Font,
			2,
			self:GetTall() * 0.52,
			col,
			TEXT_ALIGN_LEFT,
			TEXT_ALIGN_CENTER
		)
	elseif GAMEMODE:GetWaveActive() then
		local waveend = GAMEMODE:GetWaveEnd()
		if waveend ~= -1 then
			local timeleft = math.max(0, waveend - CurTime())
			draw.SimpleText(
				translate.Format("wave_ends_in_x", util.ToMinutesSecondsCD(timeleft)),
				self.Font,
				2,
				self:GetTall() * 0.52,
				10 < timeleft and readoutSoftCol or Color(readoutCol.r, readoutCol.g, readoutCol.b, math.abs(math.sin(RealTime() * 8)) * 180 + 40),
				TEXT_ALIGN_LEFT,
				TEXT_ALIGN_CENTER
			)
		end
	else
		local wavestart = GAMEMODE:GetWaveStart()
		if wavestart ~= -1 then
			local timeleft = math.max(0, wavestart - CurTime())
			draw.SimpleText(
				translate.Format("next_wave_in_x", util.ToMinutesSecondsCD(timeleft)),
				self.Font,
				2,
				self:GetTall() * 0.52,
				10 < timeleft and readoutSoftCol or Color(readoutCol.r, readoutCol.g, readoutCol.b, math.abs(math.sin(RealTime() * 8)) * 180 + 40),
				TEXT_ALIGN_LEFT,
				TEXT_ALIGN_CENTER
			)
		end
	end

	return true
end

function PANEL:Text3Paint()
	if MySelf:IsValid() then
		if ShouldUseOriginalHUD() then
			if MySelf:Team() == TEAM_UNDEAD then
				local toredeem = GAMEMODE:GetRedeemBrains()
				if toredeem > 0 then
					draw.SimpleText(translate.Format("brains_eaten_x", MySelf:Frags().." / "..toredeem), self.Font, 0, 0, COLOR_SOFTRED)
				else
					draw.SimpleText(translate.Format("brains_eaten_x", MySelf:Frags()), self.Font, 0, 0, COLOR_SOFTRED)
				end
			else
				draw.SimpleText("Points: "..MySelf:GetPoints().."  Score: "..MySelf:Frags(), self.Font, 0, 0, COLOR_SOFTRED)
			end
		else
			local readoutCol, readoutSoftCol = GetMonitorReadoutColors()

			if MySelf:Team() == TEAM_UNDEAD then
				local toredeem = 2
				draw.SimpleText(
					translate.Format("brains_eaten_x", MySelf:Frags() .. " / " .. toredeem),
					self.Font,
					2,
					self:GetTall() * 0.52,
					readoutSoftCol,
					TEXT_ALIGN_LEFT,
					TEXT_ALIGN_CENTER
				)
			else
				--draw.SimpleText(translate.Format("points_x", MySelf:GetPoints()+" / "..MySelf:Frags()), self.Font, 0, 0, COLOR_DARKRED)
				draw.SimpleText(
					"PTS " .. MySelf:GetPoints() .. "   //   SCR " .. MySelf:Frags(),
					self.Font,
					2,
					self:GetTall() * 0.52,
					readoutCol,
					TEXT_ALIGN_LEFT,
					TEXT_ALIGN_CENTER
				)
			end
		end
	end

	return true
end

local matGradientLeft = CreateMaterial(
	"gradient-l",
	"UnlitGeneric",
	{
		["$basetexture"] = "vgui/gradient-l",
		["$vertexalpha"] = "1",
		["$vertexcolor"] = "1",
		["$ignorez"] = "1",
		["$nomip"] = "1",
	}
)
function PANEL:Paint(w, h)
	if ShouldUseOriginalHUD() then
		surface.SetDrawColor(0, 0, 0, 180)
		surface.DrawRect(0, 0, w * 0.4, h)
		surface.SetMaterial(matGradientLeft)
		surface.DrawTexturedRect(w * 0.4, 0, w * 0.6, h)
		surface.SetDrawColor(0, 0, 0, 250)
		surface.SetMaterial(matGradientLeft)
		surface.DrawTexturedRect(0, h - 1, w, 1)
		return true
	end

	DrawMedicalMonitorFrame(w, h)

	surface.SetMaterial(matGradientLeft)
	surface.SetDrawColor(110, 255, 230, 12)
	surface.DrawTexturedRect(8, 24, w - 16, h - 32)
	surface.SetDrawColor(0, 20, 18, 42)
	surface.DrawTexturedRectUV(8, 24, w - 16, h - 32, 1, 0, 0, 1)

	surface.SetDrawColor(170, 255, 240, 7)
	for y = 26, h - 10, 4 do
		surface.DrawLine(8, y, w - 8, y)
	end

	surface.SetDrawColor(255, 255, 255, 5)
	surface.DrawRect(10, 26, w - 20, math.max(10, h * 0.2))

	return true
end

vgui.Register("ZSGameState", PANEL, "DPanel")
