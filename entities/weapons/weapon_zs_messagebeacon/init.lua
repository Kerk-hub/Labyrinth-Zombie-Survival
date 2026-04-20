INC_SERVER()

local function HasDeployedBarricadeBeacon(owner)
	for _, ent in ipairs(ents.FindByClass("prop_messagebeacon")) do
		if ent:IsValid() and ent.GetObjectOwner and ent:GetObjectOwner() == owner then
			return true
		end
	end

	return false
end

function SWEP:Deploy()
	gamemode.Call("WeaponDeployed", self:GetOwner(), self)

	self:SpawnGhost()

	return true
end

function SWEP:OnRemove()
	self:RemoveGhost()
end

function SWEP:Holster()
	self:RemoveGhost()
	return true
end

function SWEP:SpawnGhost()
	local owner = self:GetOwner()
	if owner and owner:IsValid() then
		owner:GiveStatus("ghost_messagebeacon")
	end
end

function SWEP:RemoveGhost()
	local owner = self:GetOwner()
	if owner and owner:IsValid() then
		owner:RemoveStatus("ghost_messagebeacon", false, true)
	end
end

function SWEP:SecondaryAttack()
end

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end

	local owner = self:GetOwner()
	if HasDeployedBarricadeBeacon(owner) then
		owner:PrintMessage(HUD_PRINTCENTER, "You already have a Barricade Beacon deployed.")
		self:SetNextPrimaryAttack(CurTime() + 0.5)
		return
	end

	local status = owner.status_ghost_messagebeacon
	if not (status and status:IsValid()) then return end
	status:RecalculateValidity()
	if not status:GetValidPlacement() then return end

	local pos, ang = status:RecalculateValidity()
	if not pos or not ang then return end
	if GAMEMODE.FindConflictingBarricadeBeacon and GAMEMODE:FindConflictingBarricadeBeacon(pos, owner) then
		owner:PrintMessage(HUD_PRINTCENTER, "Another Barricade Beacon already covers this area.")
		self:SetNextPrimaryAttack(CurTime() + 0.5)
		return
	end

	self:SetNextPrimaryAttack(CurTime() + self.Primary.Delay)

	local ent = ents.Create("prop_messagebeacon")
	if ent:IsValid() then
		ent:SetPos(pos)
		ent:SetAngles(ang)
		ent:Spawn()

		ent:SetObjectOwner(owner)
		ent:SetMessageID(self.MessageID)

		ent:EmitSound("npc/dog/dog_servo12.wav")

		--ent:GhostAllPlayersInMe(5)

		self:TakePrimaryAmmo(1)

		local stored = owner:PopPackedItem(ent:GetClass())
		if stored then
			ent.ObjHealth = stored[1]
		end

		if self:GetPrimaryAmmoCount() <= 0 then
			owner:StripWeapon(self:GetClass())
		end
	end
end

function SWEP:Think()
	local count = self:GetPrimaryAmmoCount()
	if count ~= self:GetReplicatedAmmo() then
		self:SetReplicatedAmmo(count)
		self:GetOwner():ResetSpeed()
	end
end

SWEP.MessageID = 1
concommand.Add("setmessagebeaconmessage", function(sender, command, arguments)
	if not sender:IsValid() then return end

	local wep = sender:GetActiveWeapon()
	if wep:IsValid() and wep:GetClass() == "weapon_zs_messagebeacon" then
		wep.MessageID = math.Clamp(math.floor(tonumbersafe(arguments[1]) or 1), 1, #GAMEMODE.ValidBeaconMessages)
	end
end)
