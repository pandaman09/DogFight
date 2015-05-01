--require("datastream")

local CENTER_HEIGHT = 250
local PANEL = {}

/*---------------------------------------------------------
   Init
---------------------------------------------------------*/
function PANEL:Init()

	self:SetText( "" )
	self.Buttons = {}
	self.BottomButtons = {}
	self:SetSkin( GAMEMODE.HudSkin )
	
	self.pnlButtons = vgui.Create( "DPanelList", self )
	self.pnlButtons:SetPadding( 10 )
	self.pnlButtons:SetSpacing( 10 )
	self.pnlButtons:SetDrawBackground( false )
	self.pnlButtons:EnableVerticalScrollbar()

	self.lblMain = vgui.Create( "DLabel", self )
		self.lblMain:SetText( GAMEMODE.Name )
		self.lblMain:SetFont( "FRETTA_HUGE" )
		self.lblMain:SetColor( color_white )
		
	self.pnlMain = vgui.Create( "DPanelList", self )
		self.pnlMain:SetNoSizing( true )
		self.pnlMain:SetDrawBackground( false )
		self.pnlMain:EnableVerticalScrollbar()
		
	self.btnCancel = vgui.Create( "DButton", self )
		self.btnCancel:SetText( "#Close" )
		self.btnCancel:SetSize( 100, 30 )
		self.btnCancel:SetFGColor( Color( 0, 0, 0, 200 ) )
		self.btnCancel:SetFont( "FRETTA_SMALL" )
		self.btnCancel.DoClick = function() self:Remove() end
		self.btnCancel:SetVisible( false )
		
		Derma_Hook( self.btnCancel, "Paint", 				"Paint", 		"CancelButton" )
		Derma_Hook( self.btnCancel, "PaintOver", 			"PaintOver", 	"CancelButton" )
		Derma_Hook( self.btnCancel, "ApplySchemeSettings", 	"Scheme", 		"CancelButton" )
		Derma_Hook( self.btnCancel, "PerformLayout", 		"Layout", 		"CancelButton" )
		
	self.lblHoverText = vgui.Create( "DLabel", self )
		self.lblHoverText:SetText( "" )
		self.lblHoverText:SetFont( "FRETTA_MEDIUM" )
		self.lblHoverText:SetColor( color_white )
		self.lblHoverText:SetContentAlignment( 8 )
		self.lblHoverText:SetWrap( true )
		
	self.lblFooterText = vgui.Create( "DLabel", self )
		self.lblFooterText:SetText( "" )
		self.lblFooterText:SetFont( "FRETTA_MEDIUM" )
		self.lblFooterText:SetColor( color_white )
		self.lblFooterText:SetContentAlignment( 8 )
		self.lblFooterText:SetWrap( false )
		
	self.pnlMain:AddItem( self.lblHoverText )
		
	self:PerformLayout()
	
	self.OpenTime = SysTime()
	
end

function PANEL:NoFadeIn()
	self.OpenTime = 0
end

/*---------------------------------------------------------
   AddPanelButton
---------------------------------------------------------*/
function PANEL:AddPanelButton( icon, title, pnlfnc )

	local btn = vgui.Create( "DImageButton", self )
		btn:SetImage( icon )
		btn:SetTooltip( title )
		btn:SetSize( 30, 30 )
		btn:SetVisible( true )
		btn.pPanelFnc = pnlfnc
		btn.pPanel = nil
		btn:SetStretchToFit( false )
	
	Derma_Hook( btn, "Paint", 				"Paint", 		"PanelButton" )
	Derma_Hook( btn, "PaintOver",			"PaintOver", 	"PanelButton" )
	//Derma_Hook( btn, "ApplySchemeSettings", "Scheme", 		"PanelButton" )
	//Derma_Hook( btn, "PerformLayout", 		"Layout", 		"PanelButton" )
	
	local fnClick = function()
		
		if ( !btn.pPanel ) then
			btn.pPanel = btn.pPanelFnc()
			btn.pPanel:SetParent( self.pnlMain )
			btn.pPanel:SetVisible( false )
			btn.pPanelFnc = nil
		end
	
		// Toggle off
		if ( btn.m_bSelected ) then self:ClearSelectedPanel() return end 
		
		self:ClearSelectedPanel()
		
		btn.m_bSelected = true
		
		self.pnlMain:Clear()
		btn.pPanel:SetVisible( true )
		self.pnlMain:AddItem( btn.pPanel )
	
	end
	btn.DoClick = fnClick
		
	table.insert( self.BottomButtons, btn )
	
	return btn

end

function PANEL:ClearSelectedPanel()

	self.pnlMain:Clear()
	self.pnlMain:AddItem( self.lblHoverText )

	for k, btn in pairs( self.BottomButtons ) do
	
		btn.m_bSelected = false
		if ( IsValid( btn.pPanel ) ) then
			btn.pPanel:SetVisible( false )
		end
	
	end

end

/*---------------------------------------------------------
   SetHeaderText
---------------------------------------------------------*/
function PANEL:SetHeaderText( strName )

	self.lblMain:SetText( strName )

end

/*---------------------------------------------------------
   SetHeaderText
---------------------------------------------------------*/
function PANEL:SetHoverText( strName )

	self.lblHoverText:SetText( strName or "" )

end

/*---------------------------------------------------------
   SetHeaderText
---------------------------------------------------------*/
function PANEL:GetHoverText( strName )

	return self.lblHoverText:GetValue()

end

/*---------------------------------------------------------
  AddSelectButton
---------------------------------------------------------*/
function PANEL:AddSelectButton( strName, fnFunction, txt )

	local btn = vgui.Create( "DButton", self.pnlButtons )
	btn:SetText( strName )
	btn:SetSize( 200, 30 )
	btn.DoClick = function() fnFunction() surface.PlaySound( Sound("buttons/lightswitch2.wav") ) self:Remove() end
	
	Derma_Hook( btn, "Paint", 				"Paint", 		"SelectButton" )
	Derma_Hook( btn, "PaintOver",			"PaintOver", 	"SelectButton" )
	Derma_Hook( btn, "ApplySchemeSettings", "Scheme", 		"SelectButton" )
	Derma_Hook( btn, "PerformLayout", 		"Layout", 		"SelectButton" )
	
	if ( txt ) then
		btn.OnCursorEntered = function() self.OldHoverText = self:GetHoverText() self:SetHoverText( txt ) end
		btn.OnCursorExited = function() self:SetHoverText( self.OldHoverText ) self.OldHoverText = nil end
	end
	
	self.pnlButtons:AddItem( btn )
	
	table.insert( self.Buttons, btn )
	return btn
	
end

/*---------------------------------------------------------
   SetHeaderText
---------------------------------------------------------*/
function PANEL:AddSpacer( h )

	local btn = vgui.Create( "Panel", self )
	btn:SetSize( 200, h )
	table.insert( self.Buttons, btn )
	return btn
	
end

/*---------------------------------------------------------
   SetHeaderText
---------------------------------------------------------*/
function PANEL:AddCancelButton()

	self.btnCancel:SetVisible( true )
	
end

/*---------------------------------------------------------
   PerformLayout
---------------------------------------------------------*/
function PANEL:PerformLayout()

	self:SetSize( ScrW(), ScrH() )
	
	local CenterY = ScrH() / 2.0
	local CenterX = ScrW() / 2.0
	local InnerWidth = 640
	
	self.lblMain:SizeToContents()
	self.lblMain:SetPos( ScrW() * 0.5 - self.lblMain:GetWide() * 0.5, CenterY - CENTER_HEIGHT - self.lblMain:GetTall() * 1.2 )
	
	self.pnlButtons:SetPos( ScrW() * 0.5 - InnerWidth * 0.5, (CenterY - CENTER_HEIGHT) + 20 )
	self.pnlButtons:SetSize( 210, (CENTER_HEIGHT * 2) - self.btnCancel:GetTall() - 20 - 20 - 20 )
	
	self.btnCancel:SetPos( ScrW() * 0.5 + InnerWidth * 0.5 - self.btnCancel:GetWide(), CenterY + CENTER_HEIGHT - self.btnCancel:GetTall() - 20 )
	
	self.lblHoverText:SetPos( ScrW() * 0.5 - InnerWidth * 0.5 + 50, (CenterY - 150) )
	self.lblHoverText:SetSize( 300, 300 )
	
	self.pnlMain:SetPos( self.pnlButtons.x + self.pnlButtons:GetWide() + 10, self.pnlButtons.y )
	self.pnlMain:SetSize( InnerWidth - self.pnlButtons:GetWide() - 10, 400 )
	
	self.lblFooterText:SetSize( ScrW(), 30 )
	self.lblFooterText:SetPos( 0, CenterY + CENTER_HEIGHT + 10 )
	
	local x = self.pnlButtons.x
	for k, btn in pairs( self.BottomButtons ) do
	
		btn:SetPos( x, CenterY + CENTER_HEIGHT - btn:GetTall() - 20 )
		x = x + btn:GetWide() + 8
	
	end
		
end

/*---------------------------------------------------------
   Paint
---------------------------------------------------------*/
function PANEL:Paint()

	Derma_DrawBackgroundBlur( self, self.OpenTime )
		
	local CenterY = ScrH() / 2.0
	local CenterX = ScrW() / 2.0
	
	surface.SetDrawColor( 0, 0, 0, 200 );
	surface.DrawRect( 0, CenterY - CENTER_HEIGHT, ScrW(), CENTER_HEIGHT * 2 );
	surface.DrawRect( 0, CenterY - CENTER_HEIGHT - 4, ScrW(), 2 );
	surface.DrawRect( 0, CenterY + CENTER_HEIGHT + 2, ScrW(), 2 );

	GAMEMODE:PaintSplashScreen( self:GetWide(), self:GetTall() )

end

vgui_Splash = vgui.RegisterTable( PANEL, "DPanel" )
local TeamPanel = nil

function GM:ShowTeam()

	if ( !IsValid( TeamPanel ) ) then 
	
		TeamPanel = vgui.CreateFromTable( vgui_Splash )
		TeamPanel:SetHeaderText( "Choose Team" )

		local AllTeams = team.GetAllTeams()
		for ID, TeamInfo in SortedPairs ( AllTeams ) do
		
			if ( ID != TEAM_CONNECTING && ID != TEAM_UNASSIGNED && ( ID != TEAM_SPECTATOR || GAMEMODE.AllowSpectating ) && team.Joinable(ID) ) then
			
				if ( ID == TEAM_SPECTATOR ) then
					TeamPanel:AddSpacer( 10 )
				end
			
				local strName = TeamInfo.Name
				local func = function() RunConsoleCommand( "changeteam", ID ) end
			
				local btn = TeamPanel:AddSelectButton( strName, func )
				btn.m_colBackground = TeamInfo.Color
				btn.Think = function( self ) 
								self:SetText( Format( "%s (%i)", strName, team.NumPlayers( ID ) ))
								self:SetDisabled( GAMEMODE:TeamHasEnoughPlayers( ID ) ) 
							end
				
				if (  IsValid( LocalPlayer() ) && LocalPlayer():Team() == ID ) then
					btn:SetDisabled( true )
				end
				
			end
			
		end
		
		TeamPanel:AddCancelButton()
		
	end
	
	TeamPanel:MakePopup()

end

local SettingsPanel = nil

function GM:ShowSettings()

	if ( !IsValid( SettingsPanel ) ) then 
	
		SettingsPanel = vgui.CreateFromTable( vgui_Splash )
		SettingsPanel:SetHeaderText( "Settings" )
		
		local slid = vgui.Create("DNumSlider", SettingsPanel)
		slid:SetText("Camera Movement")
		slid:SetConVar("df_cammove")
		slid:SetMin(0)
		slid:SetMax(15)
		slid:SetPos(100,200)
		slid:SetSize(250,50)
		
		local slid = vgui.Create("DNumSlider", SettingsPanel)
		slid:SetText("Camera Distance")
		slid:SetConVar("df_camdist")
		slid:SetMin(100)
		slid:SetMax(300)
		slid:SetPos(100,250)
		slid:SetSize(250,50)
		
		local slid = vgui.Create("DNumSlider", SettingsPanel)
		slid:SetText("Tree Density (SOME MAPS ONLY)")
		slid:SetConVar("df_treedense")
		slid:SetMin(1)
		slid:SetMax(10)
		slid:SetPos(100,300)
		slid:SetSize(250,50)
		
		
		local chk = vgui.Create( "DCheckBoxLabel", SettingsPanel )
		chk:SetPos( 100, 350 )
		chk:SetText( "Show Wing Trails" )
		chk:SetConVar( "df_showtrails" )
		chk:SetValue( 1 )
		chk:SizeToContents()
		
		local chk = vgui.Create( "DCheckBoxLabel", SettingsPanel )
		chk:SetPos( 100, 380 )
		chk:SetText( "Show Tips" )
		chk:SetValue( GetConVarNumber("df_showtips") )
		chk:SetConVar( "df_showtips" )
		chk:SizeToContents()
		
		local chk = vgui.Create( "DCheckBoxLabel", SettingsPanel )
		chk:SetPos( 100, 410 )
		chk:SetText( "Inverse Y" )
		chk:SetValue( GetConVarNumber("df_inverse") )
		chk:SetConVar( "df_inverse" )
		chk:SizeToContents()
		
		
		SettingsPanel:AddCancelButton()

	end
	
	SettingsPanel:MakePopup()

end

local LeaderBoardPanel = nil

function GM:ShowLeaderBoard()
	if !IsValid(LeaderBoardPanel) then
		LeaderBoardPanel = vgui.CreateFromTable(vgui_Splash)
		LeaderBoardPanel:SetHeaderText( "Leaderboard")
		
		local prop = vgui.Create("DPropertySheet", LeaderBoardPanel)
		local CenterY = ScrH() / 2.0
		local CenterX = ScrW() / 2.0
		local InnerWidth = 640
		
		--[[
		self.lblMain:SizeToContents()
		self.lblMain:SetPos( ScrW() * 0.5 - self.lblMain:GetWide() * 0.5, CenterY - CENTER_HEIGHT - self.lblMain:GetTall() * 1.2 )
	
		self.pnlButtons:SetPos( ScrW() * 0.5 - InnerWidth * 0.5, (CenterY - CENTER_HEIGHT) + 20 )
		self.pnlButtons:SetSize( 210, (CENTER_HEIGHT * 2) - self.btnCancel:GetTall() - 20 - 20 - 20 )
	
		self.btnCancel:SetPos( ScrW() * 0.5 + InnerWidth * 0.5 - self.btnCancel:GetWide(), CenterY + CENTER_HEIGHT - self.btnCancel:GetTall() - 20 )
		
		]]
		prop:SetPos(ScrW() * 0.1, CenterY - CENTER_HEIGHT + 20)
		prop:SetSkin( GAMEMODE.HudSkin )
		prop:SetSize(ScrW() * 0.8, (CENTER_HEIGHT * 2) - 100)
		
		local score_tab = vgui.Create("lead_tab", prop)
		score_tab:SetLeaderColumn("score")
		prop:AddSheet("Score", score_tab, "gui/silkicons/user", false, false, "Sort by Score")
		
		local kills_tab = vgui.Create("lead_tab", prop)
		kills_tab:SetLeaderColumn("kills")
		prop:AddSheet( "Kills", kills_tab, "gui/silkicons/user", false, false, "Sort by Kills" )
		
		local kd_tab = vgui.Create("lead_tab", prop)
		kd_tab:SetLeaderColumn("kd")
		prop:AddSheet( "K:D", kd_tab, "gui/silkicons/user", false, false, "Sort by Kill Death Ratio" )
		
		local cap_tab = vgui.Create("lead_tab", prop)
		cap_tab:SetLeaderColumn("captures")
		prop:AddSheet( "Captures", cap_tab, "gui/silkicons/user", false, false, "Sort by Captures" )
		LeaderBoardPanel:AddCancelButton()
	end

	LeaderBoardPanel:MakePopup()
end

local PANEL = {}

local RecievedTable = {}

function PANEL:Init()
	self:SetSkin( GAMEMODE.HudSkin )
	self.list = vgui.Create("DPanelList", self)
	self.list:SetPadding(5)
	self.list:SetSpacing(5)
	self.list:EnableVerticalScrollbar(true)
	
	local tits = {name="Name", score = "Score", kd = "K:D", kills="Kills", deaths="Deaths", captures="Captures",time="Time Played"}
	local titles = vgui.Create("lead_tab_player")
	titles:SetDetails("Position", tits, true)
	self.list:AddItem(titles)
end

function PANEL:PerformLayout()
	self:StretchToParent(2,26,2,2)
	self.list:StretchToParent(2,2,2,2)
end

function PANEL:SetLeaderColumn(col)
	RunConsoleCommand("df_leaderboard_fetch", col)
	self.Waiting = true
	self.col = col
	datastream.Hook("LeaderSend_"..col, 	function(handle, id, enc, dec)
												self.Board = dec
												for k,v in pairs(self.Board) do
													local item = vgui.Create("lead_tab_player")
													item:SetDetails(k,v, false)
													self.list:AddItem(item)
												end
											end)
									
end

function PANEL:Paint()
 //Dont
end

vgui.Register("lead_tab", PANEL, "DPanel")

local PANEL = {}

function PANEL:Init()
	local x_pos = 25
	self.pos = vgui.Create("DLabel", self)
	self.pos:SetText("#")
	self.pos:SetPos(x_pos,3)
	self.pos:SizeToContents()
	
	x_pos = x_pos + 75
	
	self.name = vgui.Create("DLabel", self)
	self.name:SetText("LOADING")
	self.name:SetPos(x_pos,3)
	self.name:SizeToContents()
	
	x_pos = x_pos + 200
	
	self.score = vgui.Create("DLabel", self)
	self.score:SetText("LOADING")
	self.score:SetPos(x_pos,3)
	self.score:SizeToContents()
	
	x_pos = x_pos + 75
	
	self.kills = vgui.Create("DLabel", self)
	self.kills:SetText("LOADING")
	self.kills:SetPos(x_pos,3)
	self.kills:SizeToContents()
	
	x_pos = x_pos + 75
	
	self.deaths = vgui.Create("DLabel", self)
	self.deaths:SetText("LOADING")
	self.deaths:SetPos(x_pos,3)
	self.deaths:SizeToContents()
	
	x_pos = x_pos + 75
	
	self.kd = vgui.Create("DLabel", self)
	self.kd:SetText("LOADING")
	self.kd:SetPos(x_pos,3)
	self.kd:SizeToContents()
	
	x_pos = x_pos + 75
	
	self.caps = vgui.Create("DLabel", self)
	self.caps:SetText("LOADING")
	self.caps:SetPos(x_pos,3)
	self.caps:SizeToContents()
	
	x_pos = x_pos + 75
	
	self.time = vgui.Create("DLabel", self)
	self.time:SetText("LOADING")
	self.time:SetPos(x_pos,3)
	self.time:SizeToContents()
end

function PANEL:Paint()
	surface.SetDrawColor(0,0,0,200)
	surface.DrawRect(0,0,self:GetWide(),self:GetTall())
	surface.SetDrawColor(0,0,0,255)
	surface.DrawOutlinedRect(0,0,self:GetWide(),self:GetTall())
end

function PANEL:SetDetails(pos,tab, titles)
	self.pos:SetText(pos)
	//Stupid SQL escape
	local name_proc = ""
	if !titles then
		name_proc = string.Right(tab["name"],string.len(tab["name"]) - 1)
		name_proc = string.Left(name_proc,string.len(name_proc) - 1)
	else
		name_proc = tab["name"]
	end
	self.name:SetText(name_proc)
	self.score:SetText(tab["score"])
	self.kills:SetText(tab["kills"])
	if !titles then
		self.kd:SetText(math.Round(tonumber(tab["kd"]) * 100) / 100)
	else
		self.kd:SetText(tab["kd"])
	end
	self.deaths:SetText(tab["deaths"])
	self.caps:SetText(tab["captures"])
	local time_proc = tab["time"]
	if !titles then
		time_proc = string.FormattedTime( tonumber(tab["time"]), "%02i:%02i:%02i")
	end
	self.time:SetText(time_proc)
end

function PANEL:PerformLayout()
	self:SetSize(self:GetParent():GetWide() - 10, 20)
	self.pos:SizeToContents()
	self.name:SizeToContents()
	self.score:SizeToContents()
	self.kd:SizeToContents()
	self.kills:SizeToContents()
	self.deaths:SizeToContents()
	self.caps:SizeToContents()
	self.time:SizeToContents()
end

vgui.Register("lead_tab_player", PANEL, "DPanel")
