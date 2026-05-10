local PANEL = {}

local matGlow = Material("sprites/glow04_noz")
local texDownEdge = surface.GetTextureID("gui/gradient_down")
local colHealth = Color(0, 0, 0, 240)
local matGradientLeft = CreateMaterial("gradient-l", "UnlitGeneric", { ["$basetexture"] = "vgui/gradient-l", ["$vertexalpha"] = "1", ["$vertexcolor"] = "1", ["$ignorez"] = "1", ["$nomip"] = "1" })

local function ShouldUseOriginalHUD()
	return GAMEMODE and GAMEMODE.OriginalHUD
end

local function DrawMetallicFrame(x, y, w, h)
	-- Outer/inner rims for a steel-like edge.
	surface.SetDrawColor(60, 62, 68, 230)
	surface.DrawOutlinedRect(x, y, w, h, 1)
	surface.SetDrawColor(160, 164, 172, 210)
	surface.DrawOutlinedRect(x + 1, y + 1, w - 2, h - 2, 1)

	-- Top highlight and bottom shadow to add depth.
	surface.SetDrawColor(230, 230, 230, 90)
	surface.DrawRect(x + 2, y + 2, w - 4, 1)
	surface.SetDrawColor(16, 16, 20, 120)
	surface.DrawRect(x + 2, y + h - 3, w - 4, 1)

	-- Soft directional sheen across the frame.
	surface.SetMaterial(matGradientLeft)
	surface.SetDrawColor(255, 255, 255, 35)
	surface.DrawTexturedRect(x + 1, y + 1, w - 2, h - 2)
	surface.SetDrawColor(0, 0, 0, 45)
	surface.DrawTexturedRectUV(x + 1, y + 1, w - 2, h - 2, 1, 0, 0, 1)

	-- Subtle brushed-metal striping.
	surface.SetDrawColor(205, 205, 205, 20)
	for sx = x + 2, x + w - 3, 6 do
		surface.DrawRect(sx, y + 2, 2, h - 4)
	end
end

local function DrawLeftToRightFillGradient(x, y, w, h, rightCol)
	if w <= 0 or h <= 0 then
		return
	end

	for i = 0, w - 1 do
		local frac = i / math.max(1, w - 1)
		local r = Lerp(frac, 255, rightCol.r)
		local g = Lerp(frac, 255, rightCol.g)
		local b = Lerp(frac, 255, rightCol.b)
		local a = Lerp(frac, 34, 72)
		surface.SetDrawColor(r, g, b, a)
		surface.DrawRect(x + i, y, 1, h)
	end
end

local function DrawClassicBar(x, y, w, h, fillw, barCol, bgCol)
	surface.SetDrawColor(0, 0, 0, 200)
	surface.DrawRect(x, y, w, h)
	surface.SetDrawColor(bgCol.r, bgCol.g, bgCol.b, math.min(bgCol.a or 160, 180))
	surface.DrawRect(x + 1, y + 1, w - 2, h - 2)

	if fillw > 2 then
		surface.SetDrawColor(barCol.r, barCol.g, barCol.b, 225)
		surface.DrawRect(x + 2, y + 2, math.max(fillw - 4, 0), h - 4)
	end

	surface.SetDrawColor(255, 255, 255, 18)
	surface.DrawRect(x + 2, y + 2, w - 4, 1)
	surface.SetDrawColor(0, 0, 0, 120)
	surface.DrawOutlinedRect(x, y, w, h, 1)
end

-- Draw animated ECG-style flatline wave fill
local function DrawWaveBar(x, y, w, h, col)
	local waveSpeed = RealTime() * 60  -- pixels per second scroll speed
	local centerY = y + h * 0.5
	local spikeWidth = 14  -- width of one full spike cycle in pixels
	local cycleWidth = spikeWidth * 8  -- total cycle length; larger = more flat line between beats
	local amp = h * 0.42   -- spike height

	-- ECG shape over one cycle (normalized 0..1 -> offset)
	local function ecgOffset(phase)
		phase = phase % 1
		if phase < 0.35 then
			return 0
		elseif phase < 0.45 then
			-- sharp upward spike
			local t = (phase - 0.35) / 0.1
			return -amp * math.sin(t * math.pi)
		elseif phase < 0.55 then
			-- sharp downward dip
			local t = (phase - 0.45) / 0.1
			return amp * 0.5 * math.sin(t * math.pi)
		elseif phase < 0.65 then
			-- recovery bump
			local t = (phase - 0.55) / 0.1
			return -amp * 0.25 * math.sin(t * math.pi)
		else
			return 0
		end
	end

	-- Draw ECG line
	surface.SetDrawColor(255, 255, 255, 235)
	for i = 0, w - 1 do
		local phase = ((i + waveSpeed) % cycleWidth) / cycleWidth
		local nextPhase = ((i + 1 + waveSpeed) % cycleWidth) / cycleWidth
		surface.DrawLine(x + i, centerY + ecgOffset(phase), x + i + 1, centerY + ecgOffset(nextPhase))
	end

	-- Fill area under the wave
	surface.SetDrawColor(255, 255, 255, 60)
	for i = 0, w - 1, 2 do
		local phase = ((i + waveSpeed) % cycleWidth) / cycleWidth
		local offset = ecgOffset(phase)
		if offset < 0 then
			surface.DrawRect(x + i, centerY + offset, 2, -offset)
		end
	end
end

local function ContentsPaint(self, w, h)
	local lp = MySelf
	if lp:IsValid() then
		local screenscale = BetterScreenScale()

		if ShouldUseOriginalHUD() then
			local health = math.max(lp:Health(), 0)
			local healthperc = math.Clamp(health / lp:GetMaxHealthEx(), 0, 1)
			local wid, hei = 300 * screenscale, 18 * screenscale

			colHealth.r = (1 - healthperc) * 180
			colHealth.g = healthperc * 180
			colHealth.b = 0

			local x = 18 * screenscale
			local y = 115 * screenscale

			local subwidth = healthperc * wid

			draw.SimpleTextBlurry(health, "ZSHUDFont", x + wid + 12 * screenscale, y + 8 * screenscale, colHealth, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

			surface.SetDrawColor(0, 0, 0, 230)
			surface.DrawRect(x, y, wid, hei)

			surface.SetDrawColor(colHealth.r * 0.6, colHealth.g * 0.6, colHealth.b, 160)
			surface.SetTexture(texDownEdge)
			surface.DrawTexturedRect(x + 2, y + 1, subwidth - 4, hei - 2)
			surface.SetDrawColor(colHealth.r * 0.6, colHealth.g * 0.6, colHealth.b, 30)
			surface.DrawRect(x + 2, y + 1, subwidth - 4, hei - 2)

			surface.SetMaterial(matGlow)
			surface.SetDrawColor(255, 255, 255, 255)
			surface.DrawTexturedRect(x + 2 + subwidth - 6, y + 1 - hei/2, 4, hei * 2)

			local phantomhealth = math.max(lp:GetPhantomHealth(), 0)
			healthperc = math.Clamp(phantomhealth / lp:GetMaxHealthEx(), 0, 1)

			colHealth.r = 100
			colHealth.g = 90
			colHealth.b = 80
			local phantomwidth = healthperc * wid

			surface.SetDrawColor(colHealth.r, colHealth.g, colHealth.b, 160)
			surface.SetTexture(texDownEdge)
			surface.DrawTexturedRect(x + 2 + subwidth - 4, y + 1, phantomwidth, hei - 2)
			surface.SetDrawColor(colHealth.r, colHealth.g, colHealth.b, 30)
			surface.DrawRect(x + 2 + subwidth - 4, y + 1, phantomwidth, hei - 2)

			if lp:Team() == TEAM_HUMAN then
				local bloodarmor = lp:GetBloodArmor()
				if bloodarmor > 0 then
					x = 78 * screenscale
					y = 142 * screenscale
					wid, hei = 240 * screenscale, 14 * screenscale

					healthperc = math.Clamp(bloodarmor / (lp.MaxBloodArmor or 10), 0, 1)
					colHealth.r = 50 + healthperc * 205
					colHealth.g = 0
					colHealth.b = (1 - healthperc) * 50

					subwidth = healthperc * wid

					draw.SimpleTextBlurry(bloodarmor, "ZSHUDFontSmall", x + wid + 12 * screenscale, y + 8 * screenscale, colHealth, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

					surface.SetDrawColor(0, 0, 0, 230)
					surface.DrawRect(x, y, wid, hei)

					surface.SetDrawColor(colHealth.r * 0.6, colHealth.g * 0.6, colHealth.b, 160)
					surface.SetTexture(texDownEdge)
					surface.DrawTexturedRect(x + 2, y + 1, subwidth - 4, hei - 2)
					surface.SetDrawColor(colHealth.r * 0.5, colHealth.g * 0.5, colHealth.b, 30)
					surface.DrawRect(x + 2, y + 1, subwidth - 4, hei - 2)

					surface.SetMaterial(matGlow)
					surface.SetDrawColor(255, 255, 255, 255)
					surface.DrawTexturedRect(x + 2 + subwidth - 6, y + 1 - hei/2, 4, hei * 2)
				end
			end

			return
		end

		local health = math.max(lp:Health(), 0)
		local maxHealth = lp:GetMaxHealthEx() or 1
		local healthperc = math.Clamp(health / maxHealth, 0, 1)
		local wid, hei = 320 * screenscale, 44 * screenscale

		colHealth.r = 110
		colHealth.g = 190
		colHealth.b = 255

		local x = 4 * screenscale
		local y = 100 * screenscale
		local bgColor = GAMEMODE.HealthBarBackgroundColor or color_black_alpha220
		local numberColor = Color(bgColor.r, bgColor.g, bgColor.b, 255)

		local subwidth = healthperc * wid

		draw.SimpleTextBlurry(health, "ZSHUDFont", x + wid + 12 * screenscale, y + hei * 0.5, numberColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

		surface.SetDrawColor(bgColor.r, bgColor.g, bgColor.b, bgColor.a)
		surface.DrawRect(x, y, wid, hei)
		DrawMetallicFrame(x, y, wid, hei)

		DrawWaveBar(x + 2, y + 1, subwidth - 4, hei - 2, colHealth)
		DrawLeftToRightFillGradient(x + 2, y + 1, subwidth - 4, hei - 2, bgColor)

		surface.SetMaterial(matGlow)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawTexturedRect(x + 2 + subwidth - 6, y + 1 - hei/2, 4, hei * 2)

		local phantomhealth = math.max(lp:GetPhantomHealth(), 0)
		local maxHealth = lp:GetMaxHealthEx() or 1
		healthperc = math.Clamp(phantomhealth / maxHealth, 0, 1)

		colHealth.r = 100
		colHealth.g = 90
		colHealth.b = 80
		local phantomwidth = healthperc * wid

		DrawWaveBar(x + 2 + subwidth - 4, y + 1, phantomwidth, hei - 2, colHealth)
		surface.SetDrawColor(colHealth.r, colHealth.g, colHealth.b, 30)
		surface.DrawRect(x + 2 + subwidth - 4, y + 1, phantomwidth, hei - 2)

		if lp:Team() == TEAM_HUMAN then
			local bloodarmor = lp:GetBloodArmor()
			if bloodarmor > 0 then
				x = 4 * screenscale
				y = 148 * screenscale
				wid, hei = 260 * screenscale, 30 * screenscale

				   healthperc = math.Clamp(bloodarmor / (lp.MaxBloodArmor or 10), 0, 1)
				colHealth.r = 50 + healthperc * 205
				colHealth.g = 0
				colHealth.b = (1 - healthperc) * 50

				subwidth = healthperc * wid

				draw.SimpleTextBlurry(bloodarmor, "ZSHUDFontSmall", x + wid + 12 * screenscale, y + hei * 0.5, colHealth, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

				surface.SetDrawColor(bgColor.r, bgColor.g, bgColor.b, bgColor.a)
				surface.DrawRect(x, y, wid, hei)
				DrawMetallicFrame(x, y, wid, hei)

				DrawWaveBar(x + 2, y + 1, subwidth - 4, hei - 2, colHealth)
				surface.SetDrawColor(colHealth.r * 0.5, colHealth.g * 0.5, colHealth.b, 30)
				surface.DrawRect(x + 2, y + 1, subwidth - 4, hei - 2)

				surface.SetMaterial(matGlow)
				surface.SetDrawColor(255, 255, 255, 255)
				surface.DrawTexturedRect(x + 2 + subwidth - 6, y + 1 - hei/2, 4, hei * 2)
			end
		end
	end
end

function PANEL:Init()
	self:DockMargin(0, 0, 0, 0)
	self:DockPadding(0, 0, 0, 0)

	local contents = vgui.Create("Panel", self)
	contents:Dock(FILL)
	contents.Paint = ContentsPaint

	self:ParentToHUD()
	self:InvalidateLayout()
end

function PANEL:PerformLayout()
	local screenscale = BetterScreenScale()

	if ShouldUseOriginalHUD() then
		self:SetSize(screenscale * 500, screenscale * 168)
	else
		self:SetSize(screenscale * 540, screenscale * 210)
	end

	self:AlignLeft()
	self:AlignBottom()
end

function PANEL:Paint(w, h)
	if ShouldUseOriginalHUD() then
		local y = h * 0.6
		h = h - y

		surface.SetDrawColor(0, 0, 0, 180)
		surface.DrawRect(0, y, w * 0.4, h + 1)
		surface.SetMaterial(matGradientLeft)
		surface.DrawTexturedRect(w * 0.4, y, w * 0.6, h + 1)

		surface.SetDrawColor(0, 0, 0, 250)
		surface.SetMaterial(matGradientLeft)
		surface.DrawTexturedRect(0, y, w, 1)
	end

	return true
end

vgui.Register("ZSHealthArea", PANEL, "Panel")
