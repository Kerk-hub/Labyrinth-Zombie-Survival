local PANEL = {}
PANEL.m_Team = 0
PANEL.NextRefresh = 0
PANEL.RefreshTime = 2

surface.CreateFont("ZSTeamHeadingSymbol", {
	font = "Segoe UI Symbol",
	size = 34,
	weight = 1000,
	antialias = true
})

function PANEL:Init()
	self.m_TeamNameLabel = EasyLabel(self, " ", "ZSScoreBoardHeading", color_black)
	self.m_TeamCountLabel = EasyLabel(self, " ", "ZSScoreBoardHeading", color_black)

	self.m_Icon = vgui.Create("DImage", self)
	self.m_Icon:SetVisible(false)
	self.m_Icon:NoClipping(true)

	self.m_Symbol = vgui.Create("DLabel", self)
	self.m_Symbol:SetFont("ZSTeamHeadingSymbol")
	self.m_Symbol:SetText("☣")
	self.m_Symbol:SetTextColor(Color(245, 245, 245))
	self.m_Symbol:SetVisible(false)
	self.m_Symbol:NoClipping(true)

	self:InvalidateLayout()
end

function PANEL:Think()
	if RealTime() >= self.NextRefresh then
		self.NextRefresh = RealTime() + self.RefreshTime
		self:RefreshContents()
	end
end

function PANEL:PerformLayout()
	self.m_TeamNameLabel:Center()

	self.m_TeamCountLabel:AlignRight(16)
	self.m_TeamCountLabel:CenterVertical()

	local iconSize = math.floor(self:GetTall() * (self.m_Team == TEAM_HUMAN and 0.65 or 0.78))
	self.m_Icon:SetSize(iconSize, iconSize)
	self.m_Icon:SetPos(6, math.floor((self:GetTall() - iconSize) * 0.5))

	self.m_Symbol:SizeToContents()
	self.m_Symbol:AlignLeft(4)
	self.m_Symbol:CenterVertical()
end

function PANEL:RefreshContents()
	local teamid = self:GetTeam()

	self.m_TeamNameLabel:SetText(team.GetName(teamid))
	self.m_TeamNameLabel:SizeToContents()

	self.m_TeamCountLabel:SetText(team.NumPlayers(teamid))
	self.m_TeamCountLabel:SizeToContents()

	self:InvalidateLayout()
end

function PANEL:Paint()
	local wid, hei = self:GetWide(), self:GetTall()

	surface.SetDrawColor(130, 130, 130, 180)
	surface.DrawRect(0, 0, wid, hei)
	surface.SetDrawColor(60, 60, 60, 180)
	surface.DrawOutlinedRect(0, 0, wid, hei)

	return true
end

function PANEL:SetTeam(teamid)
	self.m_Team = teamid

	if teamid == TEAM_HUMAN then
		self.m_Icon:SetVisible(true)
		self.m_Symbol:SetVisible(false)
		self.m_Icon:SetImage("zombiesurvival/personsymbol2")
		self.m_Icon:SizeToContents()
		self:InvalidateLayout()
	elseif teamid == TEAM_UNDEAD then
		self.m_Icon:SetVisible(true)
		self.m_Symbol:SetVisible(false)
		self.m_Icon:SetImage("zombiesurvival/zombiehead")
		self.m_Icon:SizeToContents()
		self:InvalidateLayout()
	else
		self.m_Icon:SetVisible(false)
		self.m_Symbol:SetVisible(false)
	end
end
function PANEL:GetTeam() return self.m_Team end

vgui.Register("DTeamHeading", PANEL, "Panel")
