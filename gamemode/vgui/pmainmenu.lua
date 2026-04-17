local function HelpMenuPaint(self)
	Derma_DrawBackgroundBlur(self, self.Created)
	Derma_DrawBackgroundBlur(self, self.Created)

	surface.SetDrawColor(8, 10, 14, 228)
	surface.DrawRect(0, 0, ScrW(), ScrH())

	local linecount = math.ceil(ScrH() / 54)
	for i = 0, linecount do
		local y = i * 54
		surface.SetDrawColor(60, 18, 18, i % 2 == 0 and 32 or 18)
		surface.DrawRect(0, y, ScrW(), 1)
	end
end

local texGradient = surface.GetTextureID("gui/gradient")

local function RunHelpMenuAction(menu, action)
	if menu and menu:IsValid() then
		menu:Remove()
	end

	timer.Simple(0, function()
		if action then
			action()
		end
	end)
end

local function CreateHelpMenuButton(parent, kicker, title, subtitle, accent, onclick)
	local button = vgui.Create("DButton", parent)
	button:SetText("")
	button:SetTall(math.max(62, BetterScreenScale() * 54))
	button.Kicker = kicker
	button.Title = title
	button.Accent = accent
	button.DoClick = onclick

	button.Paint = function(self, w, h)
		local hovered = self:IsHovered()
		local bg = hovered and Color(34, 26, 26, 246) or Color(18, 17, 20, 238)
		local border = hovered and Color(accent.r, accent.g, accent.b, 255) or Color(88, 73, 73, 220)

		draw.RoundedBox(8, 0, 0, w, h, bg)
		surface.SetDrawColor(0, 0, 0, 85)
		surface.SetTexture(texGradient)
		surface.DrawTexturedRect(0, 0, w, h)
		surface.SetDrawColor(border)
		surface.DrawOutlinedRect(0, 0, w, h, 1)
		surface.SetDrawColor(accent.r, accent.g, accent.b, hovered and 255 or 220)
		surface.DrawRect(0, 0, 8, h)
		surface.DrawRect(0, h - 3, w, 3)

		draw.SimpleText(self.Title, "ZSMenuHeaderFontSmallFixed", 22, h * 0.5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end

	return button
end

local function CreateHelpMenuTabButton(parent, title, onclick)
	local button = vgui.Create("DButton", parent)
	button:SetText("")
	button:SetTall(math.max(34, BetterScreenScale() * 30))
	button.Title = title
	button.DoClick = onclick

	button.Paint = function(self, w, h)
		local active = self.ActiveTab
		local hovered = self:IsHovered()
		local textcol = active and color_white or Color(170, 170, 178)
		local bg = active and Color(92, 31, 31, 245) or hovered and Color(48, 34, 34, 230) or Color(23, 21, 24, 220)

		draw.RoundedBox(6, 0, 0, w, h, bg)
		if active then
			surface.SetDrawColor(214, 84, 84, 255)
			surface.DrawRect(0, h - 4, w, 4)
		end

		draw.SimpleText(self.Title, "ZSMenuHeaderFontSmallFixed", w * 0.5, h * 0.5, textcol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	return button
end

local function ClearPanelChildren(panel)
	local target = panel.GetCanvas and panel:GetCanvas() or panel
	if not target or not target:IsValid() then
		return
	end

	for _, child in ipairs(target:GetChildren()) do
		child:Remove()
	end
end

local function AddHelpSection(parent, title, body)
	local titlelabel = EasyLabel(parent, title, "ZSMenuHeaderFontSmallFixed", color_white)
	titlelabel:Dock(TOP)
	titlelabel:DockMargin(0, 0, 0, 12)
end

local function PopulateGeneralTab(menu, parent)
	AddHelpSection(parent, "Command Deck", "Core references, account setup, and personal customization live here. This keeps the F1 panel as a fast hub instead of a dead-end list.")

	local buttons = {
		{
			kicker = "Guide",
			title = "Help",
			subtitle = "Open gameplay help and instructions.",
			accent = Color(97, 170, 255),
			action = function() RunHelpMenuAction(menu, MakepHelp) end
		},
		{
			kicker = "Config",
			title = "Options",
			subtitle = "Adjust client and gameplay settings.",
			accent = Color(255, 174, 88),
			action = function() RunHelpMenuAction(menu, MakepOptions) end
		},
		{
			kicker = "Style",
			title = "Player Model",
			subtitle = "Choose the model used for your human character.",
			accent = Color(103, 214, 166),
			action = function() RunHelpMenuAction(menu, MakepPlayerModel) end
		},
		{
			kicker = "Color",
			title = "Player Color",
			subtitle = "Tune player and weapon tint colors.",
			accent = Color(196, 126, 255),
			action = function() RunHelpMenuAction(menu, MakepPlayerColor) end
		},
		{
			kicker = "Intel",
			title = "Weapon Database",
			subtitle = "Browse weapon stats and information.",
			accent = Color(239, 101, 101),
			action = function() RunHelpMenuAction(menu, MakepWeapons) end
		},
		{
			kicker = "Progression",
			title = "Skills",
			subtitle = "Open the skill web and spend points.",
			accent = Color(90, 204, 216),
			action = function() RunHelpMenuAction(menu, function() GAMEMODE:ToggleSkillWeb() end) end
		},
		{
			kicker = "Archive",
			title = "Credits",
			subtitle = "View credits and project information.",
			accent = Color(246, 214, 92),
			action = function() RunHelpMenuAction(menu, MakepCredits) end
		}
	}

	for _, data in ipairs(buttons) do
		local button = CreateHelpMenuButton(parent, data.kicker, data.title, data.subtitle, data.accent, data.action)
		button:Dock(TOP)
		button:DockMargin(0, 0, 0, 10)
	end
end

local function PopulateHumanTab(gamemode, menu, parent)
	AddHelpSection(parent, "Survivor Actions", "This tab focuses on safe, direct survivor actions that do not rely on the inventory utility flow.")

	local wave = gamemode:GetWave()
	local livehuman = MySelf:Team() == TEAM_HUMAN and not gamemode.ZombieEscape
	local arsenalTitle = wave > 0 and "Arsenal" or "Worth Shop"
	local arsenalSubtitle = wave > 0 and "Open the arsenal purchase menu for live-round buying." or "Open the early-wave worth store."

	local actions = {
		{
			kicker = "Loadout",
			title = arsenalTitle,
			subtitle = arsenalSubtitle,
			accent = Color(225, 94, 94),
			enabled = livehuman,
			action = function()
				RunHelpMenuAction(menu, function()
					if wave > 0 then
						gamemode:OpenArsenalMenu()
					else
						MakepWorth()
					end
				end)
			end
		},
		{
			kicker = "Growth",
			title = "Skill Web",
			subtitle = "Jump straight into skills without leaving this hub.",
			accent = Color(118, 224, 202),
			enabled = true,
			action = function() RunHelpMenuAction(menu, function() gamemode:ToggleSkillWeb() end) end
		}
	}

	for _, data in ipairs(actions) do
		local button = CreateHelpMenuButton(parent, data.kicker, data.title, data.subtitle, data.accent, data.enabled and data.action or function() end)
		button:SetEnabled(data.enabled)
		if not data.enabled then
			button.PaintOver = function(self, w, h)
				surface.SetDrawColor(0, 0, 0, 130)
				surface.DrawRect(0, 0, w, h)
				draw.SimpleText("Unavailable in current state", "DefaultFont", w - 14, 14, Color(230, 230, 230, 180), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
			end
		end
		button:Dock(TOP)
		button:DockMargin(0, 0, 0, 10)
	end
end

local function PopulateUndeadTab(gamemode, menu, parent)
	AddHelpSection(parent, "Undead Actions", "Class selection and nest/baby spawn viewing sit here so zombie-side utilities are reachable from the same F1 hub.")

	local isundead = MySelf:Team() == TEAM_UNDEAD
	local canclass = isundead and not gamemode:ShouldUseAlternateDynamicSpawn()

	local actions = {
		{
			kicker = "Evolution",
			title = "Class Select",
			subtitle = canclass and "Open the zombie class selector." or "Class selection is disabled in the current spawn mode.",
			accent = Color(163, 112, 255),
			enabled = canclass,
			action = function() RunHelpMenuAction(menu, function() gamemode:OpenClassSelect() end) end
		},
		{
			kicker = "Spawn",
			title = "Zombie Spawn Menu",
			subtitle = "Open the spawn-side menu for nests and gore children.",
			accent = Color(102, 220, 126),
			enabled = not gamemode.ZombieEscape,
			action = function() RunHelpMenuAction(menu, function() gamemode:ZombieSpawnMenu() end) end
		},
		{
			kicker = "Vision",
			title = "Zombie Help",
			subtitle = "Use the general help pages while staying on the undead side.",
			accent = Color(233, 114, 114),
			enabled = true,
			action = function() RunHelpMenuAction(menu, MakepHelp) end
		}
	}

	for _, data in ipairs(actions) do
		local button = CreateHelpMenuButton(parent, data.kicker, data.title, data.subtitle, data.accent, data.enabled and data.action or function() end)
		button:SetEnabled(data.enabled)
		if not data.enabled then
			button.PaintOver = function(self, w, h)
				surface.SetDrawColor(0, 0, 0, 130)
				surface.DrawRect(0, 0, w, h)
				draw.SimpleText("Unavailable in current state", "DefaultFont", w - 14, 14, Color(230, 230, 230, 180), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
			end
		end
		button:Dock(TOP)
		button:DockMargin(0, 0, 0, 10)
	end
end

local pPlayerModel
local function SwitchPlayerModel(self)
	surface.PlaySound("buttons/button14.wav")
	RunConsoleCommand("cl_playermodel", self.m_ModelName)
	chat.AddText(COLOR_LIMEGREEN, "You've changed your desired player model to "..tostring(self.m_ModelName))

	pPlayerModel:Close()
end
function MakepPlayerModel()
	if pPlayerModel and pPlayerModel:IsValid() then pPlayerModel:Remove() end

	PlayMenuOpenSound()

	local numcols = 8
	local wid = numcols * 68 + 24
	local hei = 400

	pPlayerModel = vgui.Create("DFrame")
	pPlayerModel:SetSkin("Default")
	pPlayerModel:SetTitle("Player model selection")
	pPlayerModel:SetSize(wid, hei)
	pPlayerModel:Center()
	pPlayerModel:SetDeleteOnClose(true)

	local list = vgui.Create("DPanelList", pPlayerModel)
	list:StretchToParent(8, 24, 8, 8)
	list:EnableVerticalScrollbar()

	local grid = vgui.Create("DGrid", pPlayerModel)
	grid:SetCols(numcols)
	grid:SetColWide(68)
	grid:SetRowHeight(68)

	for name, mdl in pairs(player_manager.AllValidModels()) do
		local button = vgui.Create("SpawnIcon", grid)
		button:SetPos(0, 0)
		button:SetModel(mdl)
		button.m_ModelName = name
		button.OnMousePressed = SwitchPlayerModel
		grid:AddItem(button)
	end
	grid:SetSize(wid - 16, math.ceil(table.Count(player_manager.AllValidModels()) / numcols) * grid:GetRowHeight())

	list:AddItem(grid)

	pPlayerModel:SetSkin("Default")
	pPlayerModel:MakePopup()
end

function MakepPlayerColor()
	if pPlayerColor and pPlayerColor:IsValid() then pPlayerColor:Remove() end

	PlayMenuOpenSound()

	pPlayerColor = vgui.Create("DFrame")
	pPlayerColor:SetWide(math.min(ScrW(), 500))
	pPlayerColor:SetTitle(" ")
	pPlayerColor:SetDeleteOnClose(true)

	local y = 8

	local label = EasyLabel(pPlayerColor, "Colors", "ZSHUDFont", color_white)
	label:SetPos((pPlayerColor:GetWide() - label:GetWide()) / 2, y)
	y = y + label:GetTall() + 8

	local lab = EasyLabel(pPlayerColor, "Player color")
	lab:SetPos(8, y)
	y = y + lab:GetTall()

	local colpicker = vgui.Create("DColorMixer", pPlayerColor)
	colpicker:SetAlphaBar(false)
	colpicker:SetPalette(false)
	colpicker.UpdateConVars = function(me, color)
		me.NextConVarCheck = SysTime() + 0.2
		RunConsoleCommand("cl_playercolor", color.r / 100 .." ".. color.g / 100 .." ".. color.b / 100)
	end
	local r, g, b = string.match(GetConVar("cl_playercolor"):GetString(), "(%g+) (%g+) (%g+)")
	if r then
		colpicker:SetColor(Color(r * 100, g * 100, b * 100))
	end
	colpicker:SetSize(pPlayerColor:GetWide() - 16, 72)
	colpicker:SetPos(8, y)
	y = y + colpicker:GetTall()

	lab = EasyLabel(pPlayerColor, "Weapon color")
	lab:SetPos(8, y)
	y = y + lab:GetTall()

	colpicker = vgui.Create("DColorMixer", pPlayerColor)
	colpicker:SetAlphaBar(false)
	colpicker:SetPalette(false)
	colpicker.UpdateConVars = function(me, color)
		me.NextConVarCheck = SysTime() + 0.2
		RunConsoleCommand("cl_weaponcolor", color.r / 100 .." ".. color.g / 100 .." ".. color.b / 100)
	end
	r, g, b = string.match(GetConVar("cl_weaponcolor"):GetString(), "(%g+) (%g+) (%g+)")
	if r then
		colpicker:SetColor(Color(r * 100, g * 100, b * 100))
	end
	colpicker:SetSize(pPlayerColor:GetWide() - 16, 72)
	colpicker:SetPos(8, y)
	y = y + colpicker:GetTall()

	pPlayerColor:SetTall(y + 8)
	pPlayerColor:Center()
	pPlayerColor:MakePopup()
end

function GM:ShowHelp()
	if self.HelpMenu and self.HelpMenu:IsValid() then
		self.HelpMenu:Remove()
	end

	PlayMenuOpenSound()

	local screenscale = BetterScreenScale()
	local menu = vgui.Create("Panel")
	menu:SetSize(ScrW(), ScrH())
	menu:Center()
	menu.Paint = HelpMenuPaint
	menu.Created = SysTime()
	self.HelpMenu = menu

	local frame = vgui.Create("DEXRoundedFrame", menu)
	frame:SetSize(math.min(ScrW() - 48, screenscale * 820), math.min(ScrH() - 56, screenscale * 560))
	frame:Center()
	frame:SetTitle("Labyrinth Zombie Survival")
	if frame.lblTitle and frame.lblTitle:IsValid() then
		frame.lblTitle:SetFont("ZSMenuHeaderFontSmallFixed")
		frame.lblTitle:SizeToContents()
	end
	frame:SetColor(Color(10, 12, 16, 245))
	frame.OnRemove = function()
		if self.HelpMenu == menu then
			self.HelpMenu = nil
		end

		if menu and menu:IsValid() then
			menu:Remove()
		end
	end
	frame:MakePopup()

	menu.OnRemove = function()
		if self.HelpMenu == menu then
			self.HelpMenu = nil
		end

		if frame and frame:IsValid() then
			frame:Remove()
		end
	end

	local shell = vgui.Create("DPanel", frame)
	shell:Dock(FILL)
	shell:DockMargin(14, 34, 14, 14)
	shell.Paint = nil

	local sidebar = vgui.Create("DPanel", shell)
	sidebar:Dock(LEFT)
	sidebar:SetWide(math.min(frame:GetWide() * 0.34, screenscale * 250))
	sidebar.Paint = function(self, w, h)
		draw.RoundedBox(8, 0, 0, w, h, Color(18, 18, 22, 230))
		surface.SetDrawColor(170, 62, 62, 255)
		surface.DrawRect(0, 0, w, 6)
		surface.SetDrawColor(0, 0, 0, 110)
		surface.SetTexture(texGradient)
		surface.DrawTexturedRect(0, 0, w, h)
	end

	local contentwrap = vgui.Create("DPanel", shell)
	contentwrap:Dock(FILL)
	contentwrap:DockMargin(14, 0, 0, 0)
	contentwrap.Paint = function(self, w, h)
		draw.RoundedBox(8, 0, 0, w, h, Color(14, 14, 18, 230))
		surface.SetDrawColor(58, 28, 28, 140)
		surface.DrawOutlinedRect(0, 0, w, h, 1)
	end

	local headerbar = vgui.Create("DPanel", contentwrap)
	headerbar:Dock(TOP)
	headerbar:SetTall(62)
	headerbar:DockMargin(14, 14, 14, 0)
	headerbar.Paint = function(self, w, h)
		draw.RoundedBox(8, 0, 0, w, h, Color(22, 18, 18, 235))
		surface.SetDrawColor(166, 58, 58, 255)
		surface.DrawRect(0, h - 4, w, 4)
		draw.SimpleText("Operations Hub", "ZSMenuHeaderFontFixed", 16, 14, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	end

	local tabs = vgui.Create("DPanel", contentwrap)
	tabs:Dock(TOP)
	tabs:SetTall(42)
	tabs:DockMargin(14, 12, 14, 0)
	tabs.Paint = nil

	local content = vgui.Create("DScrollPanel", contentwrap)
	content:Dock(FILL)
	content:DockMargin(14, 12, 14, 14)

	local teamname = team.GetName(MySelf:Team()) or "Unassigned"
	local wave = self.GetWave and self:GetWave() or 0

	local title = EasyLabel(sidebar, self.Name, "ZSMenuHeaderFontFixed", color_white)
	title:Dock(TOP)
	title:DockMargin(18, 18, 18, 0)
	title:SetWrap(true)
	title:SetAutoStretchVertical(true)

	local status = vgui.Create("DPanel", sidebar)
	status:Dock(TOP)
	status:DockMargin(18, 18, 18, 0)
	status:SetTall(128)
	status.Paint = function(self, w, h)
		draw.RoundedBox(8, 0, 0, w, h, Color(28, 24, 26, 235))
		draw.SimpleText("Current Status", "ZSMenuHeaderFontSmallFixed", 12, 16, Color(232, 236, 241), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText("Team: "..teamname, "DefaultFont", 12, 50, Color(196, 201, 208), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText("Wave: "..tostring(wave), "DefaultFont", 12, 70, Color(196, 201, 208), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText("Alive: "..(MySelf:Alive() and "Yes" or "No"), "DefaultFont", 12, 90, Color(196, 201, 208), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		if GAMEMODE.ZombieEscape then
			draw.SimpleText("Mode: Zombie Escape", "DefaultFont", 12, 110, Color(196, 201, 208), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		else
			draw.SimpleText("Mode: Standard", "DefaultFont", 12, 110, Color(196, 201, 208), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		end
	end

	local closebutton = CreateHelpMenuTabButton(sidebar, "CLOSE", function() menu:Remove() end)
	closebutton:Dock(BOTTOM)
	closebutton:DockMargin(18, 18, 18, 18)

	local tabdefs = {
		{
			name = "Overview",
			populate = function() PopulateGeneralTab(menu, content) end
		},
		{
			name = "Survivor",
			populate = function() PopulateHumanTab(self, menu, content) end
		},
		{
			name = "Undead",
			populate = function() PopulateUndeadTab(self, menu, content) end
		}
	}

	local tabbuttons = {}
	local function SwitchTab(index)
		for buttonindex, button in ipairs(tabbuttons) do
			button.ActiveTab = buttonindex == index
		end

		ClearPanelChildren(content)
		tabdefs[index].populate()

		if content and content:IsValid() then
			content:InvalidateLayout(true)

			local canvas = content.GetCanvas and content:GetCanvas() or nil
			if canvas and canvas:IsValid() then
				canvas:InvalidateLayout(true)
			end

			if content.VBar and content.VBar:IsValid() then
				content.VBar:SetScroll(0)
			end
		end
	end

	for index, tab in ipairs(tabdefs) do
		local button = CreateHelpMenuTabButton(tabs, tab.name, function() SwitchTab(index) end)
		button:Dock(LEFT)
		button:DockMargin(0, 0, 10, 0)
		button:SetWide(math.max(112, screenscale * 100))
		table.insert(tabbuttons, button)
	end

	SwitchTab(1)
end
