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
	header:SetTall(58)
	header:DockMargin(14, 14, 14, 0)
	header.Paint = function(self, w, h)
		draw.RoundedBox(8, 0, 0, w, h, Color(30, 22, 22, 235))
		surface.SetDrawColor(colorOptionAccent)
		surface.DrawRect(0, h - 4, w, 4)
		draw.SimpleText("Preference Matrix", "ZSMenuHeaderFontFixed", 16, 12, colorOptionText, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	end

	local list = vgui.Create("DPanelList", content)
	list:EnableVerticalScrollbar()
	list:EnableHorizontal(false)
	list:Dock(FILL)
	list:DockMargin(14, 12, 14, 14)
	list:SetPadding(10)
	list:SetSpacing(8)
	list.Paint = function(self, w, h)
		draw.RoundedBox(8, 0, 0, w, h, Color(16, 18, 22, 220))
	end
	StyleOptionsScrollbar(list.VBar)

	local baseAddItem = list.AddItem
	function list:AddItem(item)
		StyleOptionsItem(item)
		baseAddItem(self, item)
	end

	gamemode.Call("AddExtraOptions", list, Window)

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
	list:AddItem(check)

	check = vgui.Create("DCheckBoxLabel", Window)
	check:SetText("Don't show point floaters")
	check:SetConVar("labyrinth_zs_nofloatingscore")
	check:SizeToContents()
	list:AddItem(check)

	check = vgui.Create("DCheckBoxLabel", Window)
	check:SetText("Don't hide arsenal and resupply packs")
	check:SetConVar("labyrinth_zs_hidepacks")
	check:SizeToContents()
	list:AddItem(check)

	check = vgui.Create("DCheckBoxLabel", Window)
	check:SetText("Don't hide friends via transparency")
	check:SetConVar("labyrinth_zs_showfriends")
	check:SizeToContents()
	list:AddItem(check)

	check = vgui.Create("DCheckBoxLabel", Window)
	check:SetText("Draw crosshair in ironsights.")
	check:SetConVar("labyrinth_zs_ironsightscrosshair")
	check:SizeToContents()
	list:AddItem(check)

	check = vgui.Create("DCheckBoxLabel", Window)
	check:SetText("Enable ambient music")
	check:SetConVar("labyrinth_zs_beats")
	check:SizeToContents()
	list:AddItem(check)

	check = vgui.Create("DCheckBoxLabel", Window)
	check:SetText("Enable last human music")
	check:SetConVar("labyrinth_zs_playmusic")
	check:SizeToContents()
	list:AddItem(check)

	check = vgui.Create("DCheckBoxLabel", Window)
	check:SetText("Enable post processing")
	check:SetConVar("labyrinth_zs_postprocessing")
	check:SizeToContents()
	list:AddItem(check)

	check = vgui.Create("DCheckBoxLabel", Window)
	check:SetText("Enable film grain")
	check:SetConVar("labyrinth_zs_filmgrain")
	check:SizeToContents()
	list:AddItem(check)

	check = vgui.Create("DCheckBoxLabel", Window)
	check:SetText("Enable Color Mod")
	check:SetConVar("labyrinth_zs_colormod")
	check:SizeToContents()
	list:AddItem(check)

	check = vgui.Create("DCheckBoxLabel", Window)
	check:SetText("Enable pain flashes")
	check:SetConVar("labyrinth_zs_drawpainflash")
	check:SizeToContents()
	list:AddItem(check)

	check = vgui.Create("DCheckBoxLabel", Window)
	check:SetText("Enable font effects")
	check:SetConVar("labyrinth_zs_fonteffects")
	check:SizeToContents()
	list:AddItem(check)

	check = vgui.Create("DCheckBoxLabel", Window)
	check:SetText("Use Shelten for standard ZS HUD font")
	check:SetConVar("labyrinth_zs_hudfontshelten")
	check:SizeToContents()
	list:AddItem(check)

	check = vgui.Create("DCheckBoxLabel", Window)
	check:SetText("Enable human health auras")
	check:SetConVar("labyrinth_zs_auras")
	check:SizeToContents()
	list:AddItem(check)

	check = vgui.Create("DCheckBoxLabel", Window)
	check:SetText("Enable damage indicators")
	check:SetConVar("labyrinth_zs_damagefloaters")
	check:SizeToContents()
	list:AddItem(check)

	check = vgui.Create("DCheckBoxLabel", Window)
	check:SetText("Enable movement view roll")
	check:SetConVar("labyrinth_zs_movementviewroll")
	check:SizeToContents()
	list:AddItem(check)

	check = vgui.Create("DCheckBoxLabel", Window)
	check:SetText("Enable message beacon visibility")
	check:SetConVar("labyrinth_zs_messagebeaconshow")
	check:SizeToContents()
	list:AddItem(check)

	check = vgui.Create("DCheckBoxLabel", Window)
	check:SetText("Film Mode (disable most of the HUD)")
	check:SetConVar("labyrinth_zs_filmmode")
	check:SizeToContents()
	list:AddItem(check)

	check = vgui.Create("DCheckBoxLabel", Window)
	check:SetText("Hide view models")
	check:SetConVar("labyrinth_zs_hideviewmodels")
	check:SizeToContents()
	list:AddItem(check)

	check = vgui.Create("DCheckBoxLabel", Window)
	check:SetText("Prevent being picked as a boss zombie")
	check:SetConVar("labyrinth_zs_nobosspick")
	check:SizeToContents()
	list:AddItem(check)

	check = vgui.Create("DCheckBoxLabel", Window)
	check:SetText("Show damage indicators through walls")
	check:SetConVar("labyrinth_zs_damagefloaterswalls")
	check:SizeToContents()
	list:AddItem(check)

	list:AddItem(EasyLabel(Window, "Weapon HUD display style", "DefaultFontSmall", color_white))
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
	list:AddItem(dropdown)

	list:AddItem(EasyLabel(Window, "Health target display style", "DefaultFontSmall", color_white))
	dropdown = vgui.Create("DComboBox", Window)
	dropdown:SetMouseInputEnabled(true)
	dropdown:AddChoice("% of health")
	dropdown:AddChoice("Health amount")
	dropdown.OnSelect = function(me, index, value, data)
		RunConsoleCommand("labyrinth_zs_healthtargetdisplay", value == "Health amount" and 1 or 0)
	end
	dropdown:SetText(GAMEMODE.HealthTargetDisplay == 1 and "Health amount" or "% of health")
	dropdown:SetTextColor(color_black)
	list:AddItem(dropdown)

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

	list:AddItem(EasyLabel(Window, "Human ambient beat set", "DefaultFontSmall", color_white))
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
	list:AddItem(dropdown)

	list:AddItem(EasyLabel(Window, "Zombie ambient beat set", "DefaultFontSmall", color_white))
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
	list:AddItem(dropdown)

	local slider = vgui.Create("DNumSlider", Window)
	slider:SetDecimals(0)
	slider:SetMinMax(2, 8)
	slider:SetConVar("labyrinth_zs_crosshairlines")
	slider:SetText("Crosshair lines")
	slider:SizeToContents()
	list:AddItem(slider)

	slider = vgui.Create("DNumSlider", Window)
	slider:SetDecimals(0)
	slider:SetMinMax(0, 90)
	slider:SetConVar("labyrinth_zs_crosshairoffset")
	slider:SetText("Crosshair offset")
	slider:SizeToContents()
	list:AddItem(slider)

	slider = vgui.Create("DNumSlider", Window)
	slider:SetDecimals(1)
	slider:SetMinMax(0.5, 2)
	slider:SetConVar("labyrinth_zs_crosshairthickness")
	slider:SetText("Crosshair thickness")
	slider:SizeToContents()
	list:AddItem(slider)

	slider = vgui.Create("DNumSlider", Window)
	slider:SetDecimals(1)
	slider:SetMinMax(0.5, 2)
	slider:SetConVar("labyrinth_zs_dmgnumberscale")
	slider:SetText("Damage number size")
	slider:SizeToContents()
	list:AddItem(slider)

	slider = vgui.Create("DNumSlider", Window)
	slider:SetDecimals(1)
	slider:SetMinMax(0, 1)
	slider:SetConVar("labyrinth_zs_dmgnumberspeed")
	slider:SetText("Damage number speed")
	slider:SizeToContents()
	list:AddItem(slider)

	slider = vgui.Create("DNumSlider", Window)
	slider:SetDecimals(1)
	slider:SetMinMax(0.2, 1.5)
	slider:SetConVar("labyrinth_zs_dmgnumberlife")
	slider:SetText("Damage number lifetime")
	slider:SizeToContents()
	list:AddItem(slider)

	slider = vgui.Create("DNumSlider", Window)
	slider:SetDecimals(1)
	slider:SetMinMax(0, 255)
	slider:SetConVar("labyrinth_zs_filmgrainopacity")
	slider:SetText("Film grain")
	slider:SizeToContents()
	list:AddItem(slider)

	slider = vgui.Create("DNumSlider", Window)
	slider:SetDecimals(1)
	slider:SetMinMax(0.7, 1.6)
	slider:SetConVar("labyrinth_zs_interfacesize")
	slider:SetText("Interface/HUD scale")
	slider:SizeToContents()
	list:AddItem(slider)

	slider = vgui.Create("DNumSlider", Window)
	slider:SetDecimals(2)
	slider:SetMinMax(0, 1)
	slider:SetConVar("labyrinth_zs_ironsightzoom")
	slider:SetText("Ironsight zoom scale")
	slider:SizeToContents()
	list:AddItem(slider)

	slider = vgui.Create("DNumSlider", Window)
	slider:SetDecimals(0)
	slider:SetMinMax(0, 100)
	slider:SetConVar("labyrinth_zs_beatsvolume")
	slider:SetText("Music volume")
	slider:SizeToContents()
	list:AddItem(slider)

	slider = vgui.Create("DNumSlider", Window)
	slider:SetDecimals(1)
	slider:SetMinMax(0.1, 4)
	slider:SetConVar("labyrinth_zs_proprotationsens")
	slider:SetText("Prop rotation sensitivity")
	slider:SizeToContents()
	list:AddItem(slider)

	slider = vgui.Create("DNumSlider", Window)
	slider:SetDecimals(0)
	slider:SetMinMax(0, GAMEMODE.TransparencyRadiusMax)
	slider:SetConVar("labyrinth_zs_transparencyradius")
	slider:SetText("Transparency radius")
	slider:SizeToContents()
	list:AddItem(slider)

	slider = vgui.Create("DNumSlider", Window)
	slider:SetDecimals(0)
	slider:SetMinMax(0, GAMEMODE.TransparencyRadiusMax)
	slider:SetConVar("labyrinth_zs_transparencyradius3p")
	slider:SetText("Transparency radius in third person")
	slider:SizeToContents()
	list:AddItem(slider)

	list:AddItem(EasyLabel(Window, "Crosshair primary color"))
	local colpicker = vgui.Create("DColorMixer", Window)
	colpicker:SetAlphaBar(true)
	colpicker:SetPalette(false)
	colpicker:SetConVarR("labyrinth_zs_crosshair_colr")
	colpicker:SetConVarG("labyrinth_zs_crosshair_colg")
	colpicker:SetConVarB("labyrinth_zs_crosshair_colb")
	colpicker:SetConVarA("labyrinth_zs_crosshair_cola")
	colpicker:SetTall(72)
	list:AddItem(colpicker)

	list:AddItem(EasyLabel(Window, "Crosshair secondary color"))
	colpicker = vgui.Create("DColorMixer", Window)
	colpicker:SetAlphaBar(true)
	colpicker:SetPalette(false)
	colpicker:SetConVarR("labyrinth_zs_crosshair_colr2")
	colpicker:SetConVarG("labyrinth_zs_crosshair_colg2")
	colpicker:SetConVarB("labyrinth_zs_crosshair_colb2")
	colpicker:SetConVarA("labyrinth_zs_crosshair_cola2")
	colpicker:SetTall(72)
	list:AddItem(colpicker)

	list:AddItem(EasyLabel(Window, "Health aura color - Full health"))
	colpicker = vgui.Create("DColorMixer", Window)
	colpicker:SetAlphaBar(false)
	colpicker:SetPalette(false)
	colpicker:SetConVarR("labyrinth_zs_auracolor_full_r")
	colpicker:SetConVarG("labyrinth_zs_auracolor_full_g")
	colpicker:SetConVarB("labyrinth_zs_auracolor_full_b")
	colpicker:SetTall(72)
	list:AddItem(colpicker)

	list:AddItem(EasyLabel(Window, "Health aura color - No health"))
	colpicker = vgui.Create("DColorMixer", Window)
	colpicker:SetAlphaBar(false)
	colpicker:SetPalette(false)
	colpicker:SetConVarR("labyrinth_zs_auracolor_empty_r")
	colpicker:SetConVarG("labyrinth_zs_auracolor_empty_g")
	colpicker:SetConVarB("labyrinth_zs_auracolor_empty_b")
	colpicker:SetTall(72)
	list:AddItem(colpicker)

	Window:SetAlpha(0)
	Window:AlphaTo(255, 0.15, 0)
	Window:MakePopup()
end
