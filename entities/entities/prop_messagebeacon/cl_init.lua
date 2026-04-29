INC_CLIENT()

local BeaconHintRange = 400
local TEXT_ALIGN_CENTER = TEXT_ALIGN_CENTER
local TEAM_HUMAN = TEAM_HUMAN
local team_GetColor = team.GetColor
local math_max = math.max

local colOwner = Color(255, 255, 255, 255)
local colDeadOwner = Color(255, 0, 0, 220)

function ENT:Initialize()
	self:SetModelScale(0.333, 0)
end

function ENT:SetMessageID(id)
	self:SetDTInt(0, id)
end

function ENT:Draw()
	self:DrawModel()

	if not MySelf:IsValid() or MySelf:Team() ~= TEAM_HUMAN or not GAMEMODE.MessageBeaconShow then return end

	local owner = self:GetObjectOwner()
	if not owner:IsValid() or not owner:IsPlayer() then return end

	local pos = self:GetPos()
	local eyepos = EyePos()
	if pos:DistToSqr(eyepos) > BeaconHintRange * BeaconHintRange then return end

	local ang = (eyepos - pos):Angle()
	ang:RotateAroundAxis(ang:Right(), 270)
	ang:RotateAroundAxis(ang:Up(), 90)

	local scale = math_max(250, eyepos:Distance(pos)) * 0.0005
	local ownerText = owner:ClippedName()
	local ownerColor = colDeadOwner
	if owner:Team() == TEAM_HUMAN and owner:Alive() then
		local humanColor = team_GetColor(TEAM_HUMAN)
		colOwner.r = humanColor.r
		colOwner.g = humanColor.g
		colOwner.b = humanColor.b
		colOwner.a = 220
		ownerColor = colOwner
	else
		ownerText = ownerText .. " (dead)"
	end

	cam.IgnoreZ(true)
	cam.Start3D2D(pos, ang, scale)
		draw.SimpleText(ownerText, "ZS3D2DFont2Small", 0, -44, ownerColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	cam.End3D2D()
	cam.IgnoreZ(false)
end
