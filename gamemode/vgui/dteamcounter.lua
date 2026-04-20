local PANEL = {}

PANEL.m_Team = 0

PANEL.NextRefresh = 0

surface.CreateFont("ZSTeamCounterSymbol", {
	font = "Segoe UI Symbol",
	size = 42,
	weight = 1000,
	antialias = true
})

local function ImageThink(self)
	if GAMEMODE and GAMEMODE.OriginalHUD then
		self:SetRotation(math.sin((RealTime() + self.Seed) * 0.5) * 25)
	else
		self:SetRotation(0)
	end
	self:OldPaint()
end

function PANEL:Init()
	self.m_Image = vgui.Create("DEXRotatedImage", self)
	self.m_Image:SetImage("icon16/check_off.png")
	self.m_Image.Seed = math.Rand(0, 1000)
	self.m_Image.OldPaint = self.m_Image.Paint
	self.m_Image.Paint = ImageThink

	self.m_Symbol = vgui.Create("DLabel", self)
	self.m_Symbol:SetFont("ZSTeamCounterSymbol")
	self.m_Symbol:SetText("☣")
	self.m_Symbol:SetTextColor(Color(240, 245, 245))
	self.m_Symbol:SetContentAlignment(5)
	self.m_Symbol:SetVisible(false)

	self.m_Counter = vgui.Create("DLabel", self)
	self.m_Counter:SetFont("ZSHUDFontSmaller")

	self:RefreshContents()
end

function PANEL:Paint()
	return true
end

function PANEL:Think()
	if RealTime() >= self.NextRefresh then
		self.NextRefresh = RealTime() + 1
		self:RefreshContents()
	end
end

function PANEL:UpdateVisuals()
	local human = self.m_Team == TEAM_HUMAN
	local undead = self.m_Team == TEAM_UNDEAD
	local original = GAMEMODE and GAMEMODE.OriginalHUD

	if human then
		self.m_Image:SetVisible(true)
		self.m_Symbol:SetVisible(false)
		self.m_Image:SetImage(original and "zombiesurvival/humanhead" or "zombiesurvival/personsymbol2")
	elseif undead then
		if original then
			self.m_Image:SetVisible(true)
			self.m_Symbol:SetVisible(false)
			self.m_Image:SetImage("zombiesurvival/zombiehead")
		else
			self.m_Image:SetVisible(false)
			self.m_Symbol:SetVisible(true)
			self.m_Symbol:SetText("☣")
			self.m_Symbol:SetTextColor(Color(245, 245, 245))
			self.m_Symbol:SizeToContents()
		end
	else
		self.m_Image:SetVisible(true)
		self.m_Symbol:SetVisible(false)
	end
end

function PANEL:SetTeam(teamid)
	self.m_Team = teamid
	self.m_Counter:SetTextColor(team.GetColor(teamid))
	self:UpdateVisuals()
end

function PANEL:SetImage(mat)
	self.m_Image:SetImage(mat)
	self:UpdateVisuals()

	self:InvalidateLayout()
end

function PANEL:PerformLayout()
	if GAMEMODE and GAMEMODE.OriginalHUD then
		self.m_Image:SetPos(0, 0)
		self.m_Image:SetSize(self:GetWide(), self:GetTall())
	else
		if self.m_Team == TEAM_HUMAN then
			local yinset = math.floor(math.min(self:GetWide(), self:GetTall()) * 0.10)
			self.m_Image:SetPos(-1, yinset)
			self.m_Image:SetSize(self:GetWide() + 2, self:GetTall() - yinset * 2)
		else
			self.m_Image:SetPos(0, 0)
			self.m_Image:SetSize(self:GetWide(), self:GetTall())
		end
	end

	self.m_Symbol:SetSize(self:GetSize())
	self.m_Counter:AlignBottom()
	self.m_Counter:AlignRight()
end

function PANEL:RefreshContents()
	local numplayers = team.NumPlayers(self.m_Team)
	self.m_PrevPlayers = self.m_PrevPlayers or numplayers

	self.m_Counter:SetText(numplayers)
	self.m_Counter:SizeToContents()

	if self.m_PrevPlayers ~= numplayers then
		self.m_Counter:Stop()
		self.m_Counter:SetColor(numplayers > self.m_PrevPlayers and color_white or COLOR_RED)
		self.m_Counter:ColorTo(team.GetColor(self.m_Team), 2)

		self.m_PrevPlayers = numplayers
	end

	self:InvalidateLayout()
end

vgui.Register("DTeamCounter", PANEL, "DPanel")
