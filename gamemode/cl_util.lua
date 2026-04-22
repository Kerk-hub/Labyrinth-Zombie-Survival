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
local lastforcereloadtime = 0

local deployableammotypes = {
    prop_ffemitter = "pulse",
    prop_repairfield = "pulse",
    prop_zapper = "pulse",
    prop_zapper_arc = "pulse",
    prop_gunturret = "smg1",
    prop_gunturret_rocket = "impactmine"
}

local function ResolveDeployableUseAmmoType(ent)
    if not IsValid(ent) then return end

    if ent:GetClass() == "prop_deployablehitbox" then
        ent = ent.GetParent and ent:GetParent() or NULL
        if not IsValid(ent) then return end
    end

    local ammotype = ent.AmmoType or deployableammotypes[ent:GetClass()]
    if not ammotype then return end

    ammotype = string.lower(ammotype)
    if not ammonames[ammotype] then return end

    if not (ent.GetAmmo and ent.MaxAmmo and ent.GetObjectOwner) then return end

    local owner = ent:GetObjectOwner()
    if not IsValid(owner) then return end

    if ent:GetAmmo() >= ent.MaxAmmo then return end

    return ammotype
end

local function CanProcessAutoAmmo(ply)
    if ply ~= LocalPlayer() then return false end
    if not GAMEMODE.AutoBuyAmmo then return false end

    if vgui.CursorVisible() then return false end
    if ply:Team() ~= TEAM_HUMAN or not ply:Alive() then return false end

    local wep = ply:GetActiveWeapon()
    if not IsValid(wep) then return false end

    local ammotype = wep:GetPrimaryAmmoType()
    if ammotype == -1 then return false end

    return true, wep, ammotype
end

local function ShouldSkipAutoReload(wep)
    local class = wep:GetClass()
    return class == "weapon_zs_hammer" or class == "weapon_zs_electrohammer" or wep.UseMelee1
end

local function ShouldAutoBuyOnSecondary(wep)
    return wep.AutoBuyAmmoOnSecondary
end

local function TryForceReloadFromAttack(ply)
    local ok, wep, ammotype = CanProcessAutoAmmo(ply)
    if not ok or ShouldSkipAutoReload(wep) then return false end
    if ply:KeyDown(IN_RELOAD) then return false end

    local clip = wep:Clip1()
    local reserve = ply:GetAmmoCount(ammotype)
    local totalammo = clip + reserve
    local magsize = wep.GetMaxClip1 and wep:GetMaxClip1() or -1
    if magsize <= 0 and wep.Primary then
        magsize = wep.Primary.ClipSize or -1
    end

    if wep.GetReloadFinish and wep:GetReloadFinish() > 0 then return false end
    if wep.CanReload and not wep:CanReload() then return false end
    if magsize <= 0 or clip ~= 0 or reserve <= 0 then return false end

    if totalammo < magsize and ply:GetPoints() >= 5 and CurTime() - lastautobuytime >= 1 then
        RunConsoleCommand("zs_quickbuyammo")
        lastautobuytime = CurTime()
    end

    if CurTime() - lastforcereloadtime < 0.5 then return true end

    RunConsoleCommand("+reload")
    timer.Simple(0, function()
        RunConsoleCommand("-reload")
    end)

    lastforcereloadtime = CurTime()
    return true
end

local function TryAutoBuyAmmo(ply, reloadcheck)
    local ok, wep, ammotype = CanProcessAutoAmmo(ply)
    if not ok then return end
    if reloadcheck and ShouldSkipAutoReload(wep) then return end

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

local function TryAutoBuyDeployableAmmo(ply)
    if ply ~= LocalPlayer() then return end
    if not GAMEMODE.AutoBuyAmmo then return end
    if vgui.CursorVisible() then return end
    if ply:Team() ~= TEAM_HUMAN or not ply:Alive() then return end
    if ply:GetPoints() < 5 then return end
    if CurTime() - lastautobuytime < 1 then return end

    local tr = ply:GetEyeTrace()
    local ammotype = tr and ResolveDeployableUseAmmoType(tr.Entity)
    if not ammotype then return end
    if ply:GetAmmoCount(ammotype) > 0 then return end

    RunConsoleCommand("zs_pointsshopbuy", "ps_"..ammonames[ammotype])
    lastautobuytime = CurTime()
end

hook.Add("PlayerButtonDown", "AutoBuyAmmo", function(ply, button)
    if button == KEY_R then
        TryAutoBuyAmmo(ply, true)
    elseif button == KEY_E then
        TryAutoBuyDeployableAmmo(ply)
    elseif button == MOUSE_LEFT then
        local wep = ply:GetActiveWeapon()
        if IsValid(wep) and ShouldAutoBuyOnSecondary(wep) then return end

        if not TryForceReloadFromAttack(ply) then
            TryAutoBuyAmmo(ply, false)
        end
    elseif button == MOUSE_RIGHT then
        local wep = ply:GetActiveWeapon()
        if IsValid(wep) and ShouldAutoBuyOnSecondary(wep) then
            TryAutoBuyAmmo(ply, false)
        end
    end
end)

hook.Add("Think", "AutoBuyAmmoHoldAttack", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    local wep = ply:GetActiveWeapon()
    if not IsValid(wep) then return end

    if ShouldAutoBuyOnSecondary(wep) then
        if ply:KeyDown(IN_ATTACK2) then
            TryAutoBuyAmmo(ply, false)
        end

        return
    end

    if ply:KeyDown(IN_ATTACK) then
        if not TryForceReloadFromAttack(ply) then
            TryAutoBuyAmmo(ply, false)
        end
    end
end)

hook.Add("PlayerBindPress", "AutoBuyAmmoReloadBind", function(ply, bind, pressed)
    if not pressed then return end

    bind = string.lower(bind)
    if string.find(bind, "+reload", 1, true) then
        TryAutoBuyAmmo(ply, true)
    end
end)
