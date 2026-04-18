concommand.Add("printdxinfo", function()
	print("DX Level: "..tostring(render.GetDXLevel()))
	print("Supports HDR: "..tostring(render.SupportsHDR()))
	print("Supports Pixel Shaders 1.4: "..tostring(render.SupportsPixelShaders_1_4()))
	print("Supports Pixel Shaders 2.0: "..tostring(render.SupportsPixelShaders_2_0()))
	print("Supports Vertex Shaders 2.0: "..tostring(render.SupportsVertexShaders_2_0()))
end)

local ammonames = {
	["pistol"] = "pistolammo",
	["buckshot"] = "shotgunammo",
	["smg1"] = "smgammo",
	["ar2"] = "assaultrifleammo",
	["357"] = "rifleammo",
	["pulse"] = "pulseammo",
	["battery"] = "40mkit",
	["xbowbolt"] = "crossbowammo",
	["impactmine"] = "impactmine",
	["chemical"] = "chemical",
	["gaussenergy"] = "nail"
}

concommand.Add("zs_quickbuyammo", function()
	if ammonames[GAMEMODE.CachedResupplyAmmoType] then
		RunConsoleCommand("zs_pointsshopbuy", "ps_"..ammonames[GAMEMODE.CachedResupplyAmmoType])
	end
end)

local function GetViewModelPosition(self, pos, ang)
	return pos + ang:Forward() * -256, ang
end

function DontDrawViewModel()
	if SWEP then
		SWEP.GetViewModelPosition = GetViewModelPosition
	end
end

-- Scales the screen based around 1080p but doesn't make things TOO tiny on low resolutions.
function BetterScreenScale()
	return math.max(ScrH() / 1080, 0.851) * GAMEMODE.InterfaceSize
end

function render.GetLightRGB(pos)
	local vec = render.GetLightColor(pos)
	return vec.r, vec.g, vec.b
end

function EasyLabel(parent, text, font, textcolor)
	local dpanel = vgui.Create("DLabel", parent)
	if font then
		dpanel:SetFont(font or "DefaultFont")
	end
	dpanel:SetText(text)
	dpanel:SizeToContents()
	if textcolor then
		dpanel:SetTextColor(textcolor)
	end
	dpanel:SetKeyboardInputEnabled(false)
	dpanel:SetMouseInputEnabled(false)

	return dpanel
end

function EasyButton(parent, text, xpadding, ypadding)
	local dpanel = vgui.Create("DButton", parent)
	if textcolor then
		dpanel:SetFGColor(textcolor or color_white)
	end
	if text then
		dpanel:SetText(text)
	end
	dpanel:SizeToContents()

	if xpadding then
		dpanel:SetWide(dpanel:GetWide() + xpadding * 2)
	end

	if ypadding then
		dpanel:SetTall(dpanel:GetTall() + ypadding * 2)
	end

	return dpanel
end

local lastautobuytime = 0

local function TryAutoBuyAmmo(ply, reloadcheck)
    if ply ~= LocalPlayer() then return end
    if not GAMEMODE.AutoBuyAmmo then return end

    if vgui.CursorVisible() then return end
    if ply:Team() ~= TEAM_HUMAN or not ply:Alive() then return end

    local wep = ply:GetActiveWeapon()
    if not IsValid(wep) then return end

    local ammotype = wep:GetPrimaryAmmoType()
    if ammotype == -1 then return end

    local clip = wep:Clip1()
    local reserve = ply:GetAmmoCount(ammotype)

    if reloadcheck then
        local magsize = wep.GetMaxClip1 and wep:GetMaxClip1() or -1
        if magsize <= 0 and wep.Primary then
            magsize = wep.Primary.ClipSize or -1
        end

        if magsize <= 0 or clip + reserve >= magsize then return end
    else
        if clip + reserve > 0 then return end
    end

    if ply:GetPoints() < 5 then return end
    if CurTime() - lastautobuytime < 1 then return end

    RunConsoleCommand("zs_quickbuyammo")
    lastautobuytime = CurTime()
end

hook.Add("PlayerButtonDown", "AutoBuyAmmo", function(ply, button)
    if button == KEY_R then
        TryAutoBuyAmmo(ply, true)
    elseif button == MOUSE_LEFT or button == MOUSE_RIGHT or button == MOUSE_MIDDLE then
        TryAutoBuyAmmo(ply, false)
    end
end)

hook.Add("Think", "AutoBuyAmmoHoldAttack", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    if ply:KeyDown(IN_ATTACK) then
        TryAutoBuyAmmo(ply, false)
    end
end)

hook.Add("PlayerBindPress", "AutoBuyAmmoReloadBind", function(ply, bind, pressed)
    if not pressed then return end

    bind = string.lower(bind)
    if string.find(bind, "+reload", 1, true) then
        TryAutoBuyAmmo(ply, true)
    end
end)
