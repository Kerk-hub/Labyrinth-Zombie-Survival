local PROPSEARCH_BEACON_DISTANCE = 360
local PROPSEARCH_BEACON_DISTANCE_SQR = PROPSEARCH_BEACON_DISTANCE * PROPSEARCH_BEACON_DISTANCE
local PROPSEARCH_SCRAP_REWARD = {
	Name = "1 scrap",
	Callback = function(pl)
		pl:GiveAmmo(1, "Scrap", true)
	end
}

local function GetZSGameMode()
	return GAMEMODE or GM
end

local function GetPropSearchItemPools()
	local gm = GetZSGameMode()
	if not gm then
		return {
			{PROPSEARCH_SCRAP_REWARD}
		}
	end

	gm.PropSearchItemPools = gm.PropSearchItemPools or {
		{PROPSEARCH_SCRAP_REWARD}
	}

	return gm.PropSearchItemPools
end

local function ClearPropSearch(pl)
	if not pl:IsValid() then return end

	pl.PropSearchTarget = nil
	pl.PropSearchStartTime = nil
	pl.PropSearchEndTime = nil
	pl:SetNWFloat("zs_propsearch_start", 0)
	pl:SetNWFloat("zs_propsearch_end", 0)
end

local function GiveSearchItem(pl, itemtab)
	local gm = GetZSGameMode()
	if not gm or not itemtab then
		return false
	end

	if itemtab.Callback then
		itemtab.Callback(pl)
		return true
	end

	if not itemtab.SWEP then
		return false
	end

	if string.sub(itemtab.SWEP, 1, 6) ~= "weapon" then
		if gm:GetInventoryItemType(itemtab.SWEP) == INVCAT_TRINKETS and pl:HasInventoryItem(itemtab.SWEP) then
			local ent = ents.Create("prop_invitem")
			if ent:IsValid() then
				ent:SetPos(pl:GetShootPos())
				ent:SetAngles(pl:GetAngles())
				ent:SetInventoryItemType(itemtab.SWEP)
				ent:Spawn()
			end
		else
			pl:AddInventoryItem(itemtab.SWEP)
		end

		return true
	end

	if pl:HasWeapon(itemtab.SWEP) then
		local stored = weapons.Get(itemtab.SWEP)
		if stored and stored.AmmoIfHas then
			pl:GiveAmmo(stored.Primary.DefaultClip, stored.Primary.Ammo)
		else
			local ent = ents.Create("prop_weapon")
			if ent:IsValid() then
				ent:SetPos(pl:GetShootPos())
				ent:SetAngles(pl:GetAngles())
				ent:SetWeaponType(itemtab.SWEP)
				ent:SetShouldRemoveAmmo(true)
				ent:Spawn()
			end
		end

		return true
	end

	local wep = pl:Give(itemtab.SWEP)
	if wep and wep:IsValid() and wep.EmptyWhenPurchased and wep:GetOwner():IsValid() then
		if wep.Primary then
			local primary = wep:ValidPrimaryAmmo()
			if primary then
				pl:RemoveAmmo(math.max(0, wep.Primary.DefaultClip - wep.Primary.ClipSize), primary)
			end
		end

		if wep.Secondary then
			local secondary = wep:ValidSecondaryAmmo()
			if secondary then
				pl:RemoveAmmo(math.max(0, wep.Secondary.DefaultClip - wep.Secondary.ClipSize), secondary)
			end
		end
	end

	return wep and wep:IsValid() or false
end

local function GiveRandomPropSearchReward(pl)
	local gm = GetZSGameMode()
	if not gm then return end

	local pools = GetPropSearchItemPools()
	if #pools == 0 then return end

	local pool = pools[math.random(#pools)]
	if not pool or #pool == 0 then return end

	local reward = pool[math.random(#pool)]
	local itemtab = isstring(reward) and gm.Items and gm.Items[reward] or reward
	if not itemtab then return end

	if not GiveSearchItem(pl, itemtab) then return end

	pl:SendLua('surface.PlaySound("items/ammo_pickup.wav")')
	pl:CenterNotify(COLOR_PURPLE, translate.ClientGet(pl, "arsenal_upgraded") .. ": ", color_white, itemtab.Name or "Reward")
end

local function IsBeaconVisibleToHeldProp(pl, held, beacon)
	if not (pl:IsValid() and held:IsValid() and beacon:IsValid()) then
		return false
	end

	local heldcenter = held:WorldSpaceCenter()
	local beaconcenter = beacon:WorldSpaceCenter()
	local distancesqr = heldcenter:DistToSqr(beaconcenter)

	if distancesqr > PROPSEARCH_BEACON_DISTANCE_SQR then
		return false
	end

	local tr = util.TraceLine({
		start = heldcenter,
		endpos = beaconcenter,
		filter = {pl, held, beacon}
	})

	return not tr.HitWorld
end

local function FindSearchBeacon(pl, held)
	for _, beacon in ipairs(ents.FindByClass("prop_messagebeacon")) do
		if IsBeaconVisibleToHeldProp(pl, held, beacon) then
			return beacon
		end
	end
end

local function MarkBeaconProtectedProp(pl, prop)
	if not (prop and prop:IsValid()) or prop:IsWorld() then
		return false
	end

	if FindSearchBeacon(pl, prop) then
		prop.ZSBeaconProtected = true
		prop:SetNWBool("zs_beacon_protected", true)
		return true
	end

	return false
end

local function TryRewardPropSearch(pl, prop)
	if not (pl and pl:IsValid() and pl:Alive() and pl:Team() == TEAM_HUMAN and prop and prop:IsValid()) or prop:IsWorld() then
		return false
	end

	if prop.PropSearchRewarded or prop:GetNWBool("zs_prop_searched", false) then
		return false
	end

	if not MarkBeaconProtectedProp(pl, prop) then
		return false
	end

	prop.PropSearchRewarded = true
	prop:SetNWBool("zs_prop_searched", true)

	if pl.PropSearchTarget == prop then
		ClearPropSearch(pl)
	end

	GiveRandomPropSearchReward(pl)
	return true
end

function GM:TryRewardPropSearch(pl, prop)
	return TryRewardPropSearch(pl, prop)
end

function GM:IsBeaconProtectedProp(prop, pl)
	if not (prop and prop:IsValid()) or prop:IsWorld() then
		return false
	end

	if prop.ZSBeaconProtected or prop:GetNWBool("zs_beacon_protected", false) then
		return true
	end

	return MarkBeaconProtectedProp(pl, prop)
end

hook.Add("Think", "ZSPropSearchThink", function()
	for _, pl in ipairs(player.GetAll()) do
		if not pl:IsValid() then continue end

		if not pl:Alive() or pl:Team() ~= TEAM_HUMAN then
			if pl.PropSearchTarget then
				ClearPropSearch(pl)
			end
			continue
		end

		local held = pl:GetHolding()
		if not held:IsValid() or held.PropSearchRewarded or held:GetNWBool("zs_prop_searched", false) then
			if pl.PropSearchTarget then
				ClearPropSearch(pl)
			end
			continue
		end

		if pl.PropSearchTarget ~= held then
			pl.PropSearchTarget = held
		end

		TryRewardPropSearch(pl, held)
	end
end)

hook.Add("PlayerDeath", "ZSPropSearchCleanup", function(pl)
	ClearPropSearch(pl)
end)

hook.Add("PlayerDisconnected", "ZSPropSearchCleanup", function(pl)
	ClearPropSearch(pl)
end)
