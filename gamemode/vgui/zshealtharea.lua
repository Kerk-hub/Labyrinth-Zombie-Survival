local PANEL = {}

local matGlow = Material("sprites/glow04_noz")
local colHealth = Color(0, 0, 0, 240)

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
	surface.SetDrawColor(col.r, col.g, col.b, 220)
	for i = 0, w - 1 do
		local phase = ((i + waveSpeed) % cycleWidth) / cycleWidth
		local nextPhase = ((i + 1 + waveSpeed) % cycleWidth) / cycleWidth
		surface.DrawLine(x + i, centerY + ecgOffset(phase), x + i + 1, centerY + ecgOffset(nextPhase))
	end

	-- Fill area under the wave
	surface.SetDrawColor(col.r * 0.6, col.g * 0.6, col.b * 0.6, 80)
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
		local health = math.max(lp:Health(), 0)
		local healthperc = math.Clamp(health / lp:GetMaxHealthEx(), 0, 1)
		local wid, hei = 320 * screenscale, 44 * screenscale

		colHealth.r = (1 - healthperc) * 180
		colHealth.g = healthperc * 180
		colHealth.b = 0

		local x = 18 * screenscale
		local y = 100 * screenscale

		local subwidth = healthperc * wid

		draw.SimpleTextBlurry(health, "ZSHUDFont", x + wid + 12 * screenscale, y + hei * 0.5, colHealth, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

		surface.SetDrawColor(0, 0, 0, 230)
		surface.DrawRect(x, y, wid, hei)

		-- Draw animated wave fill
		DrawWaveBar(x + 2, y + 1, subwidth - 4, hei - 2, colHealth)
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

		DrawWaveBar(x + 2 + subwidth - 4, y + 1, phantomwidth, hei - 2, colHealth)
		surface.SetDrawColor(colHealth.r, colHealth.g, colHealth.b, 30)
		surface.DrawRect(x + 2 + subwidth - 4, y + 1, phantomwidth, hei - 2)

		if lp:Team() == TEAM_HUMAN then
			local bloodarmor = lp:GetBloodArmor()
			if bloodarmor > 0 then
				x = 78 * screenscale
				y = 148 * screenscale
				wid, hei = 260 * screenscale, 30 * screenscale

				healthperc = math.Clamp(bloodarmor / (lp.MaxBloodArmor or 10), 0, 1)
				colHealth.r = 50 + healthperc * 205
				colHealth.g = 0
				colHealth.b = (1 - healthperc) * 50

				subwidth = healthperc * wid

				draw.SimpleTextBlurry(bloodarmor, "ZSHUDFontSmall", x + wid + 12 * screenscale, y + hei * 0.5, colHealth, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

				surface.SetDrawColor(0, 0, 0, 230)
				surface.DrawRect(x, y, wid, hei)

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

	self:SetSize(screenscale * 540, screenscale * 210)

	self:AlignLeft()
	self:AlignBottom()
end

local matGradientLeft = CreateMaterial("gradient-l", "UnlitGeneric", {["$basetexture"] = "vgui/gradient-l", ["$vertexalpha"] = "1", ["$vertexcolor"] = "1", ["$ignorez"] = "1", ["$nomip"] = "1"})
function PANEL:Paint(w, h)
	return true
end

vgui.Register("ZSHealthArea", PANEL, "Panel")
