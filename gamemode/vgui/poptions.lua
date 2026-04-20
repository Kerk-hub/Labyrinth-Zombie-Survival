local colorOptionFrame = Color(12, 14, 18, 245)
local colorOptionPanel = Color(22, 24, 30, 235)
local colorOptionPanelAlt = Color(28, 20, 20, 230)
local colorOptionOutline = Color(76, 40, 40, 210)
local colorOptionAccent = Color(181, 72, 72)
local colorOptionText = Color(230, 234, 240)
local colorOptionSubtext = Color(188, 194, 202)

local function StyleOptionsScrollbar(vbar)
	if not vbar or not vbar:IsValid() then
		return
	end

	vbar:SetHideButtons(true)
	vbar.Paint = function(self, w, h)
		draw.RoundedBox(6, 2, 0, w - 4, h, Color(10, 12, 16, 200))
	end
	vbar.btnGrip.Paint = function(self, w, h)
		draw.RoundedBox(6, 1, 0, w - 2, h, Color(165, 76, 76, 235))
	end
end

local function StyleOptionsItem(item)
	if not item or not item:IsValid() then
		return
	end

	local classname = item.GetClassName and item:GetClassName() or ""

	if classname == "DCheckBoxLabel" then
		item:SetTextColor(colorOptionText)
		item:SetFont("DefaultFontLargeAA")
		item:SizeToContents()
		item:SetTall(math.max(item:GetTall(), 30))

		if item.Button and item.Button:IsValid() then
			item.Button.Paint = function(self, w, h)
				draw.RoundedBox(4, 0, 0, w, h, Color(14, 16, 20, 255))
				if self:GetChecked() then
					draw.RoundedBox(3, 4, 4, w - 8, h - 8, colorOptionAccent)
				end
				surface.SetDrawColor(colorOptionOutline)
				surface.DrawOutlinedRect(0, 0, w, h, 1)
			end
		end
	elseif classname == "DComboBox" then
		item:SetTall(36)
		item:SetTextColor(color_black)
		item:SetFont("DefaultFontLargeAA")
		item.Paint = function(self, w, h)
			draw.RoundedBox(6, 0, 0, w, h, Color(236, 239, 244, 245))
			surface.SetDrawColor(colorOptionAccent)
			surface.DrawOutlinedRect(0, 0, w, h, 1)
		end
	elseif classname == "DNumSlider" then
		if item.Label and item.Label:IsValid() then
			item.Label:SetTextColor(colorOptionText)
			item.Label:SetFont("DefaultFontLargeAA")
		end

		if item.TextArea and item.TextArea:IsValid() then
			item.TextArea:SetTextColor(color_black)
			item.TextArea.Paint = function(self, w, h)
				draw.RoundedBox(4, 0, 0, w, h, Color(236, 239, 244, 245))
				surface.SetDrawColor(colorOptionAccent)
				surface.DrawOutlinedRect(0, 0, w, h, 1)
				self:DrawTextEntryText(color_black, colorOptionAccent, color_black)
			end
		end

		if item.Slider and item.Slider:IsValid() then
			if item.Slider.Knob then
				item.Slider.Knob.Paint = function(self, w, h)
					draw.RoundedBox(6, 0, 0, w, h, colorOptionAccent)
				end
			end

			if item.Slider.Paint then
				item.Slider.Paint = function(self, w, h)
					draw.RoundedBox(4, 0, h * 0.5 - 3, w, 6, Color(57, 61, 70, 255))
				end
			end
		end
	elseif classname == "DColorMixer" then
		item:SetTall(math.max(item:GetTall(), 96))
		item.Paint = function(self, w, h)
			draw.RoundedBox(8, 0, 0, w, h, Color(18, 20, 24, 240))
			surface.SetDrawColor(colorOptionOutline)
			surface.DrawOutlinedRect(0, 0, w, h, 1)
		end
	elseif classname == "DLabel" then
		item:SetTextColor(colorOptionText)
		item:SetFont("DefaultFontLargeAA")
		item:SizeToContents()
	end
end

function MakepOptions()
	PlayMenuOpenSound()

	if pOptions and pOptions:IsValid() then
		pOptions:SetAlpha(0)
		pOptions:AlphaTo(255, 0.15, 0)
		pOptions:SetVisible(true)
		pOptions:MakePopup()
		return
	end

	pOptions = nil

	local Window = vgui.Create("DEXRoundedFrame")
	local wide = math.min(ScrW() - 48, math.max(760, BetterScreenScale() * 900))
	local tall = math.min(ScrH() - 48, math.max(720, BetterScreenScale() * 820))
	Window:SetSize(wide, tall)
	Window:Center()
	Window:SetTitle("Options")
	Window:SetColor(colorOptionFrame)
	Window.lblTitle:SetFont("ZSMenuHeaderFontSmallFixed")
	local oldlayout = Window.PerformLayout
	Window.PerformLayout = function(me, ...)
		oldlayout(me, ...)
		if me.lblTitle and me.lblTitle:IsValid() then
			me.lblTitle:SetPos(8, 6)
		end
	end
	Window:InvalidateLayout(true)
	Window:SetDeleteOnClose(false)
	pOptions = Window
	Window.OnClose = function()
		Window:SetVisible(false)
	end

	local shell = vgui.Create("DPanel", Window)
	shell:Dock(FILL)
	shell:DockMargin(14, 34, 14, 14)
	shell.Paint = nil

	local sidebar = vgui.Create("DPanel", shell)
	sidebar:Dock(LEFT)
	sidebar:SetWide(math.min(235, wide * 0.24))
	sidebar:DockMargin(0, 28, 0, 28)
	sidebar.Paint = function(self, w, h)
		draw.RoundedBox(8, 0, 0, w, h, colorOptionPanelAlt)
		surface.SetDrawColor(colorOptionAccent)
		surface.DrawRect(0, 0, w, 6)
	end

	local title = EasyLabel(sidebar, "Client Settings", "ZSMenuHeaderFontSmallFixed", color_white)
	title:Dock(TOP)
	title:DockMargin(12, 18, 12, 0)
	title:SetWrap(true)
	title:SetAutoStretchVertical(true)

	local content = vgui.Create("DPanel", shell)
	content:Dock(FILL)
	content:DockMargin(14, 0, 0, 0)
	content.Paint = function(self, w, h)
		draw.RoundedBox(8, 0, 0, w, h, colorOptionPanel)
		surface.SetDrawColor(colorOptionOutline)
		surface.DrawOutlinedRect(0, 0, w, h, 1)
	end

	local header = vgui.Create("DPanel", content)
	header:Dock(TOP)
	header:SetTall(50)
	header:DockMargin(14, 14, 14, 0)
	header.Paint = function(self, w, h)
		draw.RoundedBox(8, 0, 0, w, h, Color(30, 22, 22, 235))
		surface.SetDrawColor(colorOptionAccent)
		surface.DrawRect(0, h - 4, w, 4)
		draw.SimpleText("Preference Matrix", "ZSMenuHeaderFontFixed", 16, 10, colorOptionText, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	end

	local tabs = vgui.Create("DPropertySheet", content)
	tabs:Dock(FILL)
	tabs:DockMargin(14, 12, 14, 14)
	tabs.Paint = function(self, w, h)
		draw.RoundedBox(8, 0, 0, w, h, Color(16, 18, 22, 220))
	end
	if tabs.tabScroller and tabs.tabScroller:IsValid() then
		tabs.tabScroller:SetTall(0)
		tabs.tabScroller.Paint = nil
	end

	local function CreateCategoryList(name)
		local panel = vgui.Create("DPanel", tabs)
		panel:Dock(FILL)
		panel.Paint = nil

		local panellist = vgui.Create("DPanelList", panel)
		panellist:EnableVerticalScrollbar()
		panellist:EnableHorizontal(false)
		panellist:Dock(FILL)
		panellist:SetPadding(10)
		panellist:SetSpacing(8)
		panellist.Paint = nil
		StyleOptionsScrollbar(panellist.VBar)

		local baseAddItem = panellist.AddItem
		function panellist:AddItem(item)
			StyleOptionsItem(item)
			baseAddItem(self, item)
		end

		local sheet = tabs:AddSheet(name, panel)
		if sheet and sheet.Tab then
			sheet.Tab:SetVisible(false)
		end

		return panellist, sheet and sheet.Tab
	end

	local visualList, visualTab = CreateCategoryList("Visual")
	local gameplayList, gameplayTab = CreateCategoryList("Gameplay")
	local audioList, audioTab = CreateCategoryList("Audio")
	local list = gameplayList

	local tabNav = vgui.Create("DPanel", sidebar)
	tabNav:Dock(TOP)
	tabNav:DockMargin(10, 14, 10, 10)
	tabNav:SetTall(132)
	tabNav.Paint = nil

	local function AddSidebarTabButton(label, targetTab)
		local btn = vgui.Create("DButton", tabNav)
		btn:Dock(TOP)
		btn:DockMargin(0, 0, 0, 8)
		btn:SetTall(34)
		btn:SetText(label)
		btn:SetFont("DefaultFontLargeAA")
		btn:SetTextColor(colorOptionText)
		btn.Paint = function(self, w, h)
			local active = tabs:GetActiveTab() == targetTab
			draw.RoundedBox(6, 0, 0, w, h, active and Color(42, 28, 28, 245) or Color(20, 22, 28, 230))
			surface.SetDrawColor(active and colorOptionAccent or colorOptionOutline)
			surface.DrawOutlinedRect(0, 0, w, h, 1)
		end
		btn.DoClick = function()
			tabs:SetActiveTab(targetTab)
		end
		return btn
	end

	AddSidebarTabButton("Visual", visualTab)
	AddSidebarTabButton("Gameplay", gameplayTab)
	AddSidebarTabButton("Audio", audioTab)
	tabs:SetActiveTab(visualTab)

	local list = gameplayList

	gamemode.Call("AddExtraOptions", gameplayList, Window)

	local check = vgui.Create("DCheckBoxLabel", Window)
	check:SetText("Always display nail health")
	check:SetConVar("labyrinth_zs_alwaysshownails")
	check:SizeToContents()
	list:AddItem(check)

	check = vgui.Create("DCheckBoxLabel", Window)
	check:SetText("Always third person knockdown camera")
	check:SetConVar("labyrinth_zs_thirdpersonknockdown")
	check:SizeToContents()
	list:AddItem(check)

	check = vgui.Create("DCheckBoxLabel", Window)
	check:SetText("Always volunteer to start as a zombie")
	check:SetConVar("labyrinth_zs_alwaysvolunteer")
	check:SizeToContents()
	list:AddItem(check)

	check = vgui.Create("DCheckBoxLabel", Window)
	check:SetText("Always quick buy from arsenal and remantler")
	check:SetConVar("labyrinth_zs_alwaysquickbuy")
	check:SizeToContents()
	list:AddItem(check)

	check = vgui.Create("DCheckBoxLabel", Window)
	check:SetText("Automatic suicide when changing classes")
	check:SetConVar("labyrinth_zs_suicideonchange")
	check:SizeToContents()
	list:AddItem(check)

	check = vgui.Create("DCheckBoxLabel", Window)
	check:SetText("Disable automatic redeeming (next round)")
	check:SetConVar("labyrinth_zs_noredeem")
	check:SizeToContents()
	list:AddItem(check)

	check = vgui.Create("DCheckBoxLabel", Window)
	check:SetText("Disable pressing use to deposit ammo in deployables")
	check:SetConVar("labyrinth_zs_nousetodeposit")
	check:SizeToContents()
	list:AddItem(check)

	check = vgui.Create("DCheckBoxLabel", Window)
	check:SetText("Disable use to prop pickup (only pickup items)")
	check:SetConVar("labyrinth_zs_nopickupprops")
	check:SizeToContents()
	list:AddItem(check)

	check = vgui.Create("DCheckBoxLabel", Window)
	check:SetText("Disable iron sights view model translation")
	check:SetConVar("labyrinth_zs_noironsights")
	check:SizeToContents()
	list:AddItem(check)

	check = vgui.Create("DCheckBoxLabel", Window)
	check:SetText("Disable crosshair rotate")
	check:SetConVar("labyrinth_zs_nocrosshairrotate")
	check:SizeToContents()
	list:AddItem(check)

	check = vgui.Create("DCheckBoxLabel", Window)
	check:SetText("Disable ironsight scopes")
	check:SetConVar("labyrinth_zs_disablescopes")
	check:SizeToContents()
	list:AddItem(check)

	check = vgui.Create("DCheckBoxLabel", Window)
	check:SetText("Display experience")
	check:SetConVar("labyrinth_zs_drawxp")
	check:SizeToContents()
	visualList:AddItem(check)

	check = vgui.Create("DCheckBoxLabel", Window)
	check:SetText("Don't show point floaters")
	check:SetConVar("labyrinth_zs_nofloatingscore")
	check:SizeToContents()
	visualList:AddItem(check)

	check = vgui.Create("DCheckBoxLabel", Window)
	check:SetText("Don't hide arsenal and resupply packs")
	check:SetConVar("labyrinth_zs_hidepacks")
	check:SizeToContents()
	visualList:AddItem(check)

	check = vgui.Create("DCheckBoxLabel", Window)
	check:SetText("Don't hide friends via transparency")
	check:SetConVar("labyrinth_zs_showfriends")
	check:SizeToContents()
	visualList:AddItem(check)

	check = vgui.Create("DCheckBoxLabel", Window)
	check:SetText("Draw crosshair in ironsights.")
	check:SetConVar("labyrinth_zs_ironsightscrosshair")
	check:SizeToContents()
	visualList:AddItem(check)

	check = vgui.Create("DCheckBoxLabel", Window)
	check:SetText("Enable ambient music")
	check:SetConVar("labyrinth_zs_beats")
	check:SizeToContents()
	audioList:AddItem(check)

	check = vgui.Create("DCheckBoxLabel", Window)
	check:SetText("Enable last human music")
	check:SetConVar("labyrinth_zs_playmusic")
	check:SizeToContents()
	audioList:AddItem(check)

	check = vgui.Create("DCheckBoxLabel", Window)
	check:SetText("Enable post processing")
	check:SetConVar("labyrinth_zs_postprocessing")
	check:SizeToContents()
	visualList:AddItem(check)

	check = vgui.Create("DCheckBoxLabel", Window)
	check:SetText("Enable film grain")
	check:SetConVar("labyrinth_zs_filmgrain")
	check:SizeToContents()
	visualList:AddItem(check)

	check = vgui.Create("DCheckBoxLabel", Window)
	check:SetText("Enable Color Mod")
	check:SetConVar("labyrinth_zs_colormod")
	check:SizeToContents()
	visualList:AddItem(check)

	check = vgui.Create("DCheckBoxLabel", Window)
	check:SetText("Enable pain flashes")
	check:SetConVar("labyrinth_zs_drawpainflash")
	check:SizeToContents()
	visualList:AddItem(check)

	check = vgui.Create("DCheckBoxLabel", Window)
	check:SetText("Enable font effects")
	check:SetConVar("labyrinth_zs_fonteffects")
	check:SizeToContents()
	visualList:AddItem(check)

	check = vgui.Create("DCheckBoxLabel", Window)
	check:SetText("Use Shelten for standard ZS HUD font")
	check:SetConVar("labyrinth_zs_hudfontshelten")
	check:SizeToContents()
	visualList:AddItem(check)

	check = vgui.Create("DCheckBoxLabel", Window)
	check:SetText("Enable human health auras")
	check:SetConVar("labyrinth_zs_auras")
	check:SizeToContents()
	visualList:AddItem(check)

	check = vgui.Create("DCheckBoxLabel", Window)
	check:SetText("Enable damage indicators")
	check:SetConVar("labyrinth_zs_damagefloaters")
	check:SizeToContents()
	visualList:AddItem(check)

	check = vgui.Create("DCheckBoxLabel", Window)
	check:SetText("Enable movement view roll")
	check:SetConVar("labyrinth_zs_movementviewroll")
	check:SizeToContents()
	visualList:AddItem(check)

	check = vgui.Create("DCheckBoxLabel", Window)
	check:SetText("Enable message beacon visibility")
	check:SetConVar("labyrinth_zs_messagebeaconshow")
	check:SizeToContents()
	visualList:AddItem(check)

	check = vgui.Create("DCheckBoxLabel", Window)
	check:SetText("Film Mode (disable most of the HUD)")
	check:SetConVar("labyrinth_zs_filmmode")
	check:SizeToContents()
	visualList:AddItem(check)

	check = vgui.Create("DCheckBoxLabel", Window)
	check:SetText("Use Original ZS HUD")
	check:SetConVar("labyrinth_zs_originalhud")
	check:SizeToContents()
	visualList:AddItem(check)

	check = vgui.Create("DCheckBoxLabel", Window)
	check:SetText("Hide view models")
	check:SetConVar("labyrinth_zs_hideviewmodels")
	check:SizeToContents()
	visualList:AddItem(check)

	check = vgui.Create("DCheckBoxLabel", Window)
	check:SetText("Prevent being picked as a boss zombie")
	check:SetConVar("labyrinth_zs_nobosspick")
	check:SizeToContents()
	list:AddItem(check)

	check = vgui.Create("DCheckBoxLabel", Window)
	check:SetText("Show damage indicators through walls")
	check:SetConVar("labyrinth_zs_damagefloaterswalls")
	check:SizeToContents()
	visualList:AddItem(check)

	visualList:AddItem(EasyLabel(Window, "Weapon HUD display style", "DefaultFontSmall", color_white))
	local dropdown = vgui.Create("DComboBox", Window)
	dropdown:SetMouseInputEnabled(true)
	dropdown:AddChoice("Display in 3D")
	dropdown:AddChoice("Display in 2D")
	dropdown:AddChoice("Display both")
	dropdown.OnSelect = function(me, index, value, data)
		RunConsoleCommand(
			"labyrinth_zs_weaponhudmode",
			value == "Display both" and 2 or value == "Display in 2D" and 1 or 0
		)
	end
	dropdown:SetText(
		GAMEMODE.WeaponHUDMode == 2 and "Display both"
			or GAMEMODE.WeaponHUDMode == 1 and "Display in 2D"
			or "Display in 3D"
	)
	dropdown:SetTextColor(color_black)
	visualList:AddItem(dropdown)

	visualList:AddItem(EasyLabel(Window, "Health target display style", "DefaultFontSmall", color_white))
	dropdown = vgui.Create("DComboBox", Window)
	dropdown:SetMouseInputEnabled(true)
	dropdown:AddChoice("% of health")
	dropdown:AddChoice("Health amount")
	dropdown.OnSelect = function(me, index, value, data)
		RunConsoleCommand("labyrinth_zs_healthtargetdisplay", value == "Health amount" and 1 or 0)
	end
	dropdown:SetText(GAMEMODE.HealthTargetDisplay == 1 and "Health amount" or "% of health")
	dropdown:SetTextColor(color_black)
	visualList:AddItem(dropdown)

	list:AddItem(EasyLabel(Window, "Prop rotation snap angle", "DefaultFontSmall", color_white))
	dropdown = vgui.Create("DComboBox", Window)
	dropdown:SetMouseInputEnabled(true)
	dropdown:AddChoice("No snap")
	dropdown:AddChoice("15 degrees")
	dropdown:AddChoice("30 degrees")
	dropdown:AddChoice("45 degrees")
	dropdown.OnSelect = function(me, index, value, data)
		RunConsoleCommand(
			"labyrinth_zs_proprotationsnap",
			value == "15 degrees" and 15 or value == "30 degrees" and 30 or value == "45 degrees" and 45 or 0
		)
	end
	dropdown:SetText(
		GAMEMODE.PropRotationSnap == 15 and "15 degrees"
			or GAMEMODE.PropRotationSnap == 30 and "30 degrees"
			or GAMEMODE.PropRotationSnap == 45 and "45 degrees"
			or "No snap"
	)
	dropdown:SetTextColor(color_black)
	list:AddItem(dropdown)

	audioList:AddItem(EasyLabel(Window, "Human ambient beat set", "DefaultFontSmall", color_white))
	dropdown = vgui.Create("DComboBox", Window)
	dropdown:SetMouseInputEnabled(true)
	for setname in pairs(GAMEMODE.Beats) do
		if setname ~= GAMEMODE.BeatSetHumanDefualt then
			dropdown:AddChoice(setname)
		end
	end
	dropdown:AddChoice("none")
	dropdown:AddChoice("default")
	dropdown.OnSelect = function(me, index, value, data)
		RunConsoleCommand("labyrinth_zs_beatset_human", value)
	end
	dropdown:SetText(GAMEMODE.BeatSetHuman == GAMEMODE.BeatSetHumanDefault and "default" or GAMEMODE.BeatSetHuman)
	dropdown:SetTextColor(color_black)
	audioList:AddItem(dropdown)

	audioList:AddItem(EasyLabel(Window, "Zombie ambient beat set", "DefaultFontSmall", color_white))
	dropdown = vgui.Create("DComboBox", Window)
	dropdown:SetMouseInputEnabled(true)
	for setname in pairs(GAMEMODE.Beats) do
		if setname ~= GAMEMODE.BeatSetZombieDefualt then
			dropdown:AddChoice(setname)
		end
	end
	dropdown:AddChoice("none")
	dropdown:AddChoice("default")
	dropdown.OnSelect = function(me, index, value, data)
		RunConsoleCommand("labyrinth_zs_beatset_zombie", value)
	end
	dropdown:SetText(GAMEMODE.BeatSetZombie == GAMEMODE.BeatSetZombieDefault and "default" or GAMEMODE.BeatSetZombie)
	dropdown:SetTextColor(color_black)
	audioList:AddItem(dropdown)

	local slider = vgui.Create("DNumSlider", Window)
	slider:SetDecimals(0)
	slider:SetMinMax(2, 8)
	slider:SetConVar("labyrinth_zs_crosshairlines")
	slider:SetText("Crosshair lines")
	slider:SizeToContents()
	visualList:AddItem(slider)

	slider = vgui.Create("DNumSlider", Window)
	slider:SetDecimals(0)
	slider:SetMinMax(0, 90)
	slider:SetConVar("labyrinth_zs_crosshairoffset")
	slider:SetText("Crosshair offset")
	slider:SizeToContents()
	visualList:AddItem(slider)

	slider = vgui.Create("DNumSlider", Window)
	slider:SetDecimals(1)
	slider:SetMinMax(0.5, 2)
	slider:SetConVar("labyrinth_zs_crosshairthickness")
	slider:SetText("Crosshair thickness")
	slider:SizeToContents()
	visualList:AddItem(slider)

	slider = vgui.Create("DNumSlider", Window)
	slider:SetDecimals(1)
	slider:SetMinMax(0.5, 2)
	slider:SetConVar("labyrinth_zs_dmgnumberscale")
	slider:SetText("Damage number size")
	slider:SizeToContents()
	visualList:AddItem(slider)

	slider = vgui.Create("DNumSlider", Window)
	slider:SetDecimals(1)
	slider:SetMinMax(0, 1)
	slider:SetConVar("labyrinth_zs_dmgnumberspeed")
	slider:SetText("Damage number speed")
	slider:SizeToContents()
	visualList:AddItem(slider)

	slider = vgui.Create("DNumSlider", Window)
	slider:SetDecimals(1)
	slider:SetMinMax(0.2, 1.5)
	slider:SetConVar("labyrinth_zs_dmgnumberlife")
	slider:SetText("Damage number lifetime")
	slider:SizeToContents()
	visualList:AddItem(slider)

	slider = vgui.Create("DNumSlider", Window)
	slider:SetDecimals(1)
	slider:SetMinMax(0, 255)
	slider:SetConVar("labyrinth_zs_filmgrainopacity")
	slider:SetText("Film grain")
	slider:SizeToContents()
	visualList:AddItem(slider)

	slider = vgui.Create("DNumSlider", Window)
	slider:SetDecimals(1)
	slider:SetMinMax(0.7, 1.6)
	slider:SetConVar("labyrinth_zs_interfacesize")
	slider:SetText("Interface/HUD scale")
	slider:SizeToContents()
	visualList:AddItem(slider)

	slider = vgui.Create("DNumSlider", Window)
	slider:SetDecimals(2)
	slider:SetMinMax(0, 1)
	slider:SetConVar("labyrinth_zs_ironsightzoom")
	slider:SetText("Ironsight zoom scale")
	slider:SizeToContents()
	gameplayList:AddItem(slider)

	slider = vgui.Create("DNumSlider", Window)
	slider:SetDecimals(0)
	slider:SetMinMax(0, 100)
	slider:SetConVar("labyrinth_zs_beatsvolume")
	slider:SetText("Music volume")
	slider:SizeToContents()
	audioList:AddItem(slider)

	slider = vgui.Create("DNumSlider", Window)
	slider:SetDecimals(1)
	slider:SetMinMax(0.1, 4)
	slider:SetConVar("labyrinth_zs_proprotationsens")
	slider:SetText("Prop rotation sensitivity")
	slider:SizeToContents()
	gameplayList:AddItem(slider)

	slider = vgui.Create("DNumSlider", Window)
	slider:SetDecimals(0)
	slider:SetMinMax(0, GAMEMODE.TransparencyRadiusMax)
	slider:SetConVar("labyrinth_zs_transparencyradius")
	slider:SetText("Transparency radius")
	slider:SizeToContents()
	visualList:AddItem(slider)

	slider = vgui.Create("DNumSlider", Window)
	slider:SetDecimals(0)
	slider:SetMinMax(0, GAMEMODE.TransparencyRadiusMax)
	slider:SetConVar("labyrinth_zs_transparencyradius3p")
	slider:SetText("Transparency radius in third person")
	slider:SizeToContents()
	visualList:AddItem(slider)

	visualList:AddItem(EasyLabel(Window, "Crosshair primary color"))
	local colpicker = vgui.Create("DColorMixer", Window)
	colpicker:SetAlphaBar(true)
	colpicker:SetPalette(false)
	colpicker:SetConVarR("labyrinth_zs_crosshair_colr")
	colpicker:SetConVarG("labyrinth_zs_crosshair_colg")
	colpicker:SetConVarB("labyrinth_zs_crosshair_colb")
	colpicker:SetConVarA("labyrinth_zs_crosshair_cola")
	colpicker:SetTall(72)
	visualList:AddItem(colpicker)

	visualList:AddItem(EasyLabel(Window, "Crosshair secondary color"))
	colpicker = vgui.Create("DColorMixer", Window)
	colpicker:SetAlphaBar(true)
	colpicker:SetPalette(false)
	colpicker:SetConVarR("labyrinth_zs_crosshair_colr2")
	colpicker:SetConVarG("labyrinth_zs_crosshair_colg2")
	colpicker:SetConVarB("labyrinth_zs_crosshair_colb2")
	colpicker:SetConVarA("labyrinth_zs_crosshair_cola2")
	colpicker:SetTall(72)
	visualList:AddItem(colpicker)

	visualList:AddItem(EasyLabel(Window, "Hud Background Color"))
	colpicker = vgui.Create("DColorMixer", Window)
	colpicker:SetAlphaBar(true)
	colpicker:SetPalette(false)
	colpicker:SetConVarR("labyrinth_zs_healthbar_bg_colr")
	colpicker:SetConVarG("labyrinth_zs_healthbar_bg_colg")
	colpicker:SetConVarB("labyrinth_zs_healthbar_bg_colb")
	colpicker:SetConVarA("labyrinth_zs_healthbar_bg_cola")
	colpicker:SetTall(72)
	visualList:AddItem(colpicker)

	visualList:AddItem(EasyLabel(Window, "Health aura color - Full health"))
	colpicker = vgui.Create("DColorMixer", Window)
	colpicker:SetAlphaBar(false)
	colpicker:SetPalette(false)
	colpicker:SetConVarR("labyrinth_zs_auracolor_full_r")
	colpicker:SetConVarG("labyrinth_zs_auracolor_full_g")
	colpicker:SetConVarB("labyrinth_zs_auracolor_full_b")
	colpicker:SetTall(72)
	visualList:AddItem(colpicker)

	visualList:AddItem(EasyLabel(Window, "Health aura color - No health"))
	colpicker = vgui.Create("DColorMixer", Window)
	colpicker:SetAlphaBar(false)
	colpicker:SetPalette(false)
	colpicker:SetConVarR("labyrinth_zs_auracolor_empty_r")
	colpicker:SetConVarG("labyrinth_zs_auracolor_empty_g")
	colpicker:SetConVarB("labyrinth_zs_auracolor_empty_b")
	colpicker:SetTall(72)
	visualList:AddItem(colpicker)

	Window:SetAlpha(0)
	Window:AlphaTo(255, 0.15, 0)
	Window:MakePopup()
end
