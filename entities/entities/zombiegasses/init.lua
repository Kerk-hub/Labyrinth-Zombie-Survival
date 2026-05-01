INC_SERVER()


ENT.TickTime = 0.5
ENT.VolunteerTime = 8
ENT.PlayerTimers = ENT.PlayerTimers or {}

util.AddNetworkString("zs_zgas_volunteertimer")

function ENT:Initialize()
	self:DrawShadow(false)
	self:Fire("attack", "", self.TickTime)

	if self:GetRadius() == 0 then self:SetRadius(400) end
end

function ENT:KeyValue(key, value)
	key = string.lower(key)
	if key == "radius" then
		self:SetRadius(tonumber(value))
	end
end

function ENT:AcceptInput(name, activator, caller, arg)
	if name ~= "attack" then return end

	if GAMEMODE.ZombieEscape then
		return true
	end

	self:Fire("attack", "", self.TickTime)

	local vPos = self:GetPos()

	-- Check if there are any Z-mains (ZombieVolunteers)
	local hasZMain = false
	if GAMEMODE.ZombieVolunteers and #GAMEMODE.ZombieVolunteers > 0 then
		hasZMain = true
	end

	local playersInGas = {}
	local zombiesInGas = {}
	for _, ent in pairs(ents.FindInSphere(vPos, self:GetRadius())) do
		if ent and ent:IsValidLivingPlayer() and WorldVisible(vPos, ent:WorldSpaceCenter()) then
			if ent:Team() == TEAM_UNDEAD then
				if CurTime() >= (ent.LastRangedAttack or 0) + 3 then
					ent:GiveStatus("zombiespawnbuff", -1) -- -1 means indefinite
					table.insert(zombiesInGas, ent)
				end
			elseif GAMEMODE:GetWave() ~= 0 then
				ent:GiveStatus("spawnslow", self.TickTime + 0.1)
				if not hasZMain then
					table.insert(playersInGas, ent)
				end
			end
		end
	end

	-- Check all zombies with the buff and remove it if they are within 600 units or in line of sight of a valid living human
	for _, zombie in ipairs(player.GetAll()) do
		if zombie:Team() == TEAM_UNDEAD and zombie:GetStatus("zombiespawnbuff") then
			local shouldRemove = false
			for _, human in ipairs(player.GetAll()) do
				if human:Team() == TEAM_HUMAN and human:Alive() then
					local dist = zombie:GetPos():Distance(human:GetPos())
					if dist <= 600 or WorldVisible(zombie:WorldSpaceCenter(), human:EyePos()) then
						shouldRemove = true
						break
					end
				end
			end
			if shouldRemove then
				zombie:RemoveStatus("zombiespawnbuff", false, true)
			end
		end
	end

	-- Handle volunteer timer logic only if there are no Z-mains
	if not hasZMain then
		self.PlayerTimers = self.PlayerTimers or {}
		local now = CurTime()
		local updatedTimers = {}

		for _, ply in ipairs(playersInGas) do
			local id = ply:SteamID64() or ply:EntIndex()
			if not self.PlayerTimers[id] then
				self.PlayerTimers[id] = {start = now, ply = ply}
			end
			updatedTimers[id] = true

			local elapsed = now - self.PlayerTimers[id].start
			-- Network timer state to client
			net.Start("zs_zgas_volunteertimer")
				net.WriteEntity(ply)
				net.WriteFloat(math.Clamp(self.VolunteerTime - elapsed, 0, self.VolunteerTime))
			net.Send(ply)

			if elapsed >= self.VolunteerTime then
				-- Volunteer this player for Z-main
				if not table.HasValue(GAMEMODE.ZombieVolunteers, ply) then
					table.insert(GAMEMODE.ZombieVolunteers, ply)
					-- You may want to call any additional logic here for volunteering
				end
				self.PlayerTimers[id] = nil
			end
		end

		-- Remove timers for players who left the gas
		for id, data in pairs(self.PlayerTimers) do
			if not updatedTimers[id] or not data.ply:IsValid() or data.ply:Team() ~= TEAM_HUMAN then
				self.PlayerTimers[id] = nil
				-- Also clear client HUD
				net.Start("zs_zgas_volunteertimer")
					net.WriteEntity(data.ply)
					net.WriteFloat(0)
				net.Send(data.ply)
			end
		end
	else
		-- If there are Z-mains, clear all timers and HUDs
		if self.PlayerTimers then
			for id, data in pairs(self.PlayerTimers) do
				if data.ply and data.ply:IsValid() then
					net.Start("zs_zgas_volunteertimer")
					net.WriteEntity(data.ply)
					net.WriteFloat(0)
					net.Send(data.ply)
				end
			end
		end
		self.PlayerTimers = {}
	end

	return true
end
