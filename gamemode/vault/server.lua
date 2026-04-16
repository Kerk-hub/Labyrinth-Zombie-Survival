GM.VaultFolder = "zombiesurvival_vault"

function GM:ShouldSaveVault(pl)
	-- Always push accumulated points in to the vault if we have any.
	if pl:IsBot() then
		return false
	end

	if self.PointSaving > 0 and pl.PointsVault ~= nil then
		return true
	end

	if pl:GetZSXP() > 0 or pl:GetZSSPUsed() > 0 then
		return true
	end

	return false
end

function GM:ShouldLoadVault(pl)
	return not pl:IsBot()
end

--[[function GM:ShouldUseVault(pl)
	return not self.ZombieEscape and not self:IsClassicMode()
end]]

function GM:GetVaultFile(pl)
	local steamid = pl:SteamID64() or "invalid"

	return self.VaultFolder .. "/" .. steamid:sub(-2) .. "/" .. steamid .. ".txt"
end

function GM:SaveAllVaults()
	for _, pl in pairs(player.GetAll()) do
		self:SaveVault(pl)
	end
end

function GM:InitializeVault(pl)
	pl.PointsVault = 0
	pl:SetZSXP(0)
end

function GM:LoadVault(pl)
	if not self:ShouldLoadVault(pl) then
		return
	end

	local filename = self:GetVaultFile(pl)
	if file.Exists(filename, "DATA") then
		local contents = file.Read(filename, "DATA")
		if contents and #contents > 0 then
			contents = Deserialize(contents)
			if contents then
				pl.PointsVault = contents.Points

				if contents.XP then
					pl:SetZSXP(contents.XP)
				end
			end
		end
	end

	pl.PointsVault = pl.PointsVault or 0
end

function GM:PlayerReadyVault(pl)
	-- Skill system removed: no skill sync needed
end

function GM:SaveVault(pl)
	if not self:ShouldSaveVault(pl) then
		return
	end

	local tosave = {
		Points = math.floor(pl.PointsVault),
		XP = pl:GetZSXP(),
	}

	if tosave.Points and self.PointSavingLimit > 0 and tosave.Points > self.PointSavingLimit then
		tosave.Points = self.PointSavingLimit
	end

	local filename = self:GetVaultFile(pl)
	file.CreateDir(string.GetPathFromFilename(filename))
	file.Write(filename, Serialize(tosave))
end
