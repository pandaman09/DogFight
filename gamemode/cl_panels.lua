
local W = ScrW()
local H = ScrH()

local PANEL = {}

MENU = nil

local OPENED = false

CreateClientConVar( "df_spawnmenu", 1, true, false)

function PANEL:Init()
	MENU = self
	local size_x = 800
	local size_y = 600
	self:SetSize(size_x,size_y)
	self:SetPos(ScrW() / 2 - (size_x / 2),ScrH() / 2 - (size_y / 2))
	self:SetTitle( "DogFight Menu" )
	if !OPENED && GetConVarNumber( "df_spawnmenu" ) == 1 then
		self:ShowCloseButton(true)
		--timer.Simple(4, self.ShowCloseButton, self,true)
		timer.Simple(4, function() self.ShowCloseButton(true) end)
		OPENED = true
	end
	self:MakePopup()
	self.Prop = vgui.Create( "DPropertySheet", self )
	self.Prop:AddSheet("Help", vgui.Create( "df_help", self ))
	self.Prop:AddSheet("Settings/Commands", vgui.Create( "df_settings", self ))
	self.Prop:AddSheet("Shop", vgui.Create( "df_unlocks", self ))
	self.Prop:AddSheet("Stats", vgui.Create( "df_stats", self ))
	self.Prop:AddSheet("Hanger", vgui.Create( "df_unlocks_manage", self ))
	if LocalPlayer():CheckGroup({"T", "A","S"}) then
		self.Prop:AddSheet("Admin", vgui.Create( "df_admin", self ))
	end
end

function PANEL:PerformLayout( )

	self.Prop:StretchToParent( 4, 26, 4, 4 )

	DFrame.PerformLayout( self )

end

vgui.Register( "df_menu", PANEL, "DFrame" )

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------COLUMN 172
local HELP = {}
HELP[1] = {"Welcome!",
		   "Hi welcome to DogFight!",
		   "DogFight is an attack/defense plane flying gamemode where you must destroy the other teams target. However whilst you are destroying theirs you must also",
		   "defend yours because if you lose then no one in your team gets any target damage money (A maximum of 80 credits!). So get ready to take off and kill some",
		   "bad guys!",
		   "",
		   "Conman420 - Lead Developer and Programmer",
		   "",
		   "P.S To get this menu back up press F1 or type gm_showhelp into the console.",
		  }
HELP[2] = {"How do you fly?!",
		   "The controls for flying are simple to learn but difficult to master. You aren't going to become the Red Baron in 10 minutes of playing so if you can't seem",
		   "to get any money don't panic! Just stick at it and soon you will be on your way to new upgrades and glory!",
		   "",
		   "The flying controls as said above are very simple:",
		   "   >BACKWARD to go up.",
		   "   >FORWARD to go down.",
		   "   >LEFT to turn left.",
		   "   >RIGHT to turn right.",
		   "   >SPRINT to speed up",
		   "   >CROUCH to slow down",
		   "   >PRIMARY FIRE to shoot!",
	       "",
		   "You can also turn on manual roll with your Qmenu and Use keys in the settings tab.",
		   }
HELP[3] = {"How do I get money?",
		   "Making money can be difficult if you are new but as you pick up the basics of flying you should be on your way to your first upgrade. New players should go",
		   "for the target as it is an effective way of making money because if your team wins and you do a lot of damage to the target you can earn up to 80C a round!",
		   "you will NOT recieve target damage money if your team loses so be sure to make sure that doesn't happen.",
		   "",
		   "If you find you are good at aiming then killing players is also an excellent method of making money. Kill money is done in a similar way to target damage",
		   "money, if you do half the damage to a player and they die then you get around 5 money and if you do all the damage then you will get 10 money. That way",
		   "kill stealing is impossible",
		   "",
		   "There is one way to lose money though if you crash into somethign then you lose 3 credits and get double respawn, the reason for this is people would just",
		   "crash if they were going to get killed so there must be some sort of penalty involved, the only advice I can give you is just try not to crash!",
		   }
HELP[4] = {"Anything else I should know?",
		   "    >You can land on your OWN teams runway to recharge your ammo and repair your plane",
		   "    >Enemy planes do not have a box around them",
		   "    >Crashing into the target does NO DAMAGE",
		   "    >Upgrades, things like bombs, colours and extra ammo, can be bought at the shop",
		   "    >All your progress will be saved and you will keep your upgrades and money FOREVER",
		   }
HELP[5] = {"Credits",
		   "    >BennyG - Models and Textures",
		   "    >Scooby - Server Hoster and Profile Saving",
		   "    >ReaperSWE - Altitude bar and other HUD elements",
		   "    >Capsadmin - Gun sounds",
		   }
HELP[6] = {"Community",
		   "DogFight is hosted by Faintlink a small but growing garrysmod community which hosts a variety of gamemodes for example Flood Mod and Onslaught Evolved.",
		   "Faintlink was set up by 'ScOoby' and he has helped me get DogFight to the success it is by hosting here and getting the profile saving working",
		   "Please visit www.faintlink.com to show your support and discuss dogfight and other gamemodes like Flood and Onslaught.",
		   }
HELP[7] = {"Donators",
		   "You can donate towards keeping these servers up and running. To show our gratitude you will be given donator status accross ALL the FL servers and the",
		   "special privelages that come with that. For DogFight Donators will recieve 50% more money for killing and target damage and will be given access to the",
		   "donator unlocks (ALL FREE). Please be aware that the donator unlocks are an unfinished feature and MANY more will be added soon. You do not have to give",
		   "us any more money if we add more unlocks as soon as a new one comes out it is yours",
		   "",
		   "To donate please visit the link below you are what keeps these servers up!",
		   "http://faintlink.com/forum/donate.php",
		   "",
		   "To gain access to the trails options press F2!",
		  }
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------COLUMN 172

local PANEL = {}

function PANEL:Init()
	self.list = vgui.Create( "DPanelList", self )
	self.list:SetPadding(4)
	self.list:EnableVerticalScrollbar( true )
	self:SetSize(self:GetParent():GetSize())
	for k,v in pairs(HELP) do
		local cat = vgui.Create( "DCollapsibleCategory", self )
		cat:SetLabel(v[1])
		local list = vgui.Create("DPanelList",cat)
		list:SetPadding(10)
		for k2,v2 in pairs(v) do
			if k2 != 1 then
				local lab = vgui.Create("DLabel", list)
				lab:SetText(v2)
				lab:SizeToContents()
				list:AddItem(lab)
			end
		end
		list:SetSize(700, 14 * #v)
		cat:SetContents(list)
		cat:SizeToContents()
		cat:InvalidateLayout()
		if k != 1 then
			cat:SetExpanded(false)
		end
		self.list:AddItem(cat)
	end
	self:InvalidateLayout()
end

function PANEL:PerformLayout()
	self.list:StretchToParent( 4, 4, 4, 4 )
end

vgui.Register( "df_help", PANEL, "DPanel" )

CreateClientConVar( "df_inverse", 1, true, true )

--CreateClientConVar( "df_mouse_pitch", 0, true, true )

CreateClientConVar( "df_roll_on", 0, true, true )

CreateClientConVar( "df_chatbeep", 1, true, false )

CreateClientConVar( "df_thirdperson", 0, true, false )

CreateClientConVar( "df_forward", 0, true, false )

CreateClientConVar( "df_film", 0, true, true )

local PANEL = { }

local bCursorEnter = function( b )
	if b.m_colTextHovered then DLabel.ApplySchemeSettings( self ) end
end

local bCursorExit = function( b )
	if b.m_colTextHovered then DLabel.ApplySchemeSettings( self ) end
end

function PANEL:Init( )
	self.Checks = {}
	local chk = vgui.Create( "DCheckBoxLabel" , self )
	chk:SetText( "Inverse pitch - W for Down and S for Up" )
	chk:SetConVar( "df_inverse" )
	chk:SetTextColor( Color(255,255,255,255) )
	chk:SetValue( GetConVarNumber( "df_inverse" ) )
	chk:SizeToContents()
	table.insert(self.Checks, chk)
	local chk = vgui.Create( "DCheckBoxLabel" , self )
	chk:SetText( "Beep when new chat message is recieved." )
	chk:SetConVar( "df_chatbeep" )
	chk:SetTextColor( Color(255,255,255,255) )
	chk:SetValue( GetConVarNumber( "df_inverse" ) )
	chk:SizeToContents()
	table.insert(self.Checks, chk)
	--[[
	local chk = vgui.Create( "DCheckBoxLabel" , self )
	chk:SetText( "When shooting have the mouse control the pitch. (EXPERIMENTAL)" )
	chk:SetConVar( "df_mouse_pitch" )
	chk:SetTextColor( Color(255,255,255,255) )
	chk:SetValue( GetConVarNumber( "df_mouse_pitch" ) )
	chk:SizeToContents()
	table.insert(self.Checks, chk)
	]]--
	local chk = vgui.Create( "DCheckBoxLabel" , self )
	chk:SetText( "Third person flying (EXPERIMENTAL)" )
	chk:SetConVar( "df_thirdperson" )
	chk:SetTextColor( Color(255,255,255,255) )
	chk:SetValue( GetConVarNumber( "df_thirdperson" ) )
	chk:SizeToContents()
	table.insert(self.Checks, chk)
	local chk = vgui.Create( "DCheckBoxLabel" , self )
	chk:SetText( "Enable Roll controls with Q Menu (Q) and Use (E)" )
	chk:SetConVar( "df_roll_on" )
	chk:SetTextColor( Color(255,255,255,255) )
	chk:SetValue( GetConVarNumber( "df_roll_on" ) )
	chk:SizeToContents()
	table.insert(self.Checks, chk)
	local chk = vgui.Create( "DCheckBoxLabel" , self )
	chk:SetText( "Force view to face front." )
	chk:SetConVar( "df_forward" )
	chk:SetTextColor( Color(255,255,255,255) )
	chk:SetValue( GetConVarNumber( "df_forward" ) )
	chk:SizeToContents()
	table.insert(self.Checks, chk)
	local chk = vgui.Create( "DCheckBoxLabel" , self )
	chk:SetText( "Filming mode. (Requires suicide for full functionality)" )
	chk:SetConVar( "df_film" )
	chk:SetTextColor( Color(255,255,255,255) )
	chk:SetValue( GetConVarNumber( "df_film" ) )
	chk:SizeToContents()
	table.insert(self.Checks, chk)
	local but = vgui.Create( "DButton" , self )
	but:SetTooltip( "Some commands may need to be sent to the server. Press this after changing settings." )
	but:SetText( "Update" )
	but.DoClick = function() RunConsoleCommand("df_update") end
	but:SetSize(750,40)
	table.insert(self.Checks, but)
end

function PANEL:Paint()
end

function PANEL:PerformLayout( )
	self:StretchToParent( 2, 24, 2, 2 )
	for k,v in pairs(self.Checks) do
		v:SetPos(10,(k * 20))
	end
end

vgui.Register( "df_settings", PANEL, "DPanel" )

local PANEL = {}

function PANEL:Init()
	self.ctrls = {}
	self.ctrls_list = vgui.Create("DPanelList", self)
	self.ctrls_list:EnableVerticalScrollbar( true )
	self.unlocks = {}
	self.ctrls_list:SetPadding(5)
	for k,v in pairs(UNLOCK_GROUPS) do
	 	self.ctrls[k] = vgui.Create( "DCollapsibleCategory", self )
		self.ctrls[k]:SetLabel( v )
		self.ctrls[k]:SetSize( 300, 300 )
		self.ctrls[k]:SetPadding( 5 )
		self.ctrls[k].LIST = vgui.Create("DPanelList", self)
		self.ctrls[k]:SetContents(self.ctrls[k].LIST)
		self.ctrls_list:AddItem(self.ctrls[k])
	end
	self.ULS = {}
	for k,v in pairs(UNLOCKS) do
		if !v.HIDE then
			local unlock = vgui.Create("df_ul", self)
			unlock:SetUnlock(k,v)
			self.ctrls[v.CATEGORY].LIST:AddItem(unlock)
			self.ctrls[v.CATEGORY]:SetContents(self.ctrls[v.CATEGORY].LIST)
			table.insert(self.ULS, unlock)
		end
	end
	self:InvalidateLayout()
end

function PANEL:PerformLayout( )
	self:StretchToParent(2,26,2,2)
	self.ctrls_list:StretchToParent(2,26,2,2)
	for k,v in pairs(self.ctrls) do
		v:StretchToParent( 2, 2, 2, 2 )
		v:SetSize(300,300)
		v.LIST:SizeToContents()
		v.LIST:InvalidateLayout()
	end
end

vgui.Register( "df_unlocks", PANEL, "DPanel")

local PANEL = {}

function PANEL:Init()
	self.unlock = nil
	self:InvalidateLayout()
end

function PANEL:SetUnlock(ID, UL)
	self.unlock = UL
	self.ID = ID
	local lab = vgui.Create("DLabel", self)
	lab:SetText(self.unlock.NAME)
	lab:SizeToContents()
	lab:SetPos(78,10)
	local lab = vgui.Create("DLabel", self)
	lab:SetText(self.unlock.DESCR)
	lab:SizeToContents()
	lab:SetPos(78,25)
	local lab = vgui.Create("DLabel", self)
	local cost = self.unlock.COST.."C"
	if self.unlock.COST == 0 then
		cost = "FREE!"
	end
	lab:SetText("Cost: "..cost)
	lab:SizeToContents()
	lab:SetPos(78,40)
	local but = vgui.Create("DButton", self)
	but:SetText("BUY")
	but:SetPos(5,5)
	but:SetSize(65,55)
	but.DoClick = function ()
					RunConsoleCommand("buy_unlock", ID)
						if LocalPlayer():GetNWInt("money", 0) >= self.unlock.COST then
							but:SetDisabled(false)
						end
					end
	if LocalPlayer().UNLOCKS != {} && LocalPlayer().UNLOCKS != nil then
		for k,v in pairs(LocalPlayer().UNLOCKS) do
			if v.ID == ID then
				but:SetDisabled(true)
			end
		end
	end
	self:InvalidateLayout()
end

function PANEL:Paint()
	if self.unlock.COL then
		surface.SetDrawColor( self.unlock.COL )
		surface.DrawRect( 0, 0,self:GetWide(), self:GetTall() )
		surface.SetDrawColor(Color(0,0,0,255))
		surface.DrawOutlinedRect(0, 0,self:GetWide(), self:GetTall())
	else
		surface.SetDrawColor( Color(100,100,100,255) )
		surface.DrawRect( 0, 0,self:GetWide(), self:GetTall() )
		surface.SetDrawColor(Color(0,0,0,255))
		surface.DrawOutlinedRect(0, 0,self:GetWide(), self:GetTall())
	end
end

local num = 0
local ID = 0

function Start_UL(length, client)
	LocalPlayer().UNLOCKS = {}
	num = net.ReadInt(16)
end

--usermessage.Hook("ul_start", Start_UL)

net.Receive("ul_start", Start_UL)

function End_UL(length, client)
	print("Unlocks have sent")
	if HANGAR && HANGAR.Refresh then
		HANGAR:Refresh()
	end
end

--usermessage.Hook("ul_end", End_UL)

net.Receive("ul_end", End_UL)

function Update_UL(length, client)
	if num == 0 then return end
	local t = {}
	t.ID = net.ReadString()
	t.EN = net.ReadInt(16)
	table.insert(LocalPlayer().UNLOCKS, t)
end

--usermessage.Hook("ul_chunk", Update_UL)

net.Receive("ul_chunk", Update_UL)

function StatsLoad(length, client)
	LocalPlayer().tot_crash = net.ReadInt(32)
	LocalPlayer().tot_targ_damage = net.ReadInt(32)
end

--usermessage.Hook("stats", StatsLoad)

net.Receive("stats", StatsLoad)

function PANEL:PerformLayout()
	self:SizeToContents()
	self:SetHeight(64)
end

vgui.Register( "df_ul", PANEL, "DPanel")

local PANEL = {}

function PANEL:Init()
	self.list = vgui.Create("DListView", self)
	self.list:AddColumn("Stats")
	self.list:AddLine("Total Kills: "..LocalPlayer():GetNWInt("kills", 0))
	self.list:AddLine("Total Deaths: "..LocalPlayer():GetNWInt("deaths", 0))
	self.list:AddLine("Total Target Damage: "..(LocalPlayer().tot_targ_damage or 0))
	self.list:AddLine("Total Crashes: "..(LocalPlayer().tot_crash or 0))
	self:InvalidateLayout()
end

function PANEL:PerformLayout()
	self:StretchToParent(2,26,2,2)
	self.list:StretchToParent(2,2,2,2)
end

vgui.Register( "df_stats", PANEL, "DPanel")

HANGAR = nil

local PANEL = {}

function PANEL:Init()
	HANGAR = self
	self.list = vgui.Create("DListView", self)
	self.list:AddColumn("Active")
	self.list2 = vgui.Create("DListView", self)
	self.list2:AddColumn("Disabled")
	if LocalPlayer().UNLOCKS then
		for k,v in pairs(LocalPlayer().UNLOCKS) do
			if UNLOCKS[v.ID] then
				if v.EN == 1 then
					self.list:AddLine(UNLOCKS[v.ID].NAME)
				elseif v.EN == 0 then
					self.list2:AddLine(UNLOCKS[v.ID].NAME)
				end
			end
		end
	end
	function self.list.DoDoubleClick( list, rowid, row )
		RunConsoleCommand( "disable_ul", row:GetColumnText( 1 ) )
		self.list2:AddLine(row:GetColumnText( 1 ))
		self.list:RemoveLine(rowid)
	end
	function self.list2.DoDoubleClick( list, rowid, row )
		RunConsoleCommand( "enable_ul", row:GetColumnText( 1 ) )
		self.list:AddLine(row:GetColumnText( 1 ))
		self.list2:RemoveLine(rowid)
	end
	self:InvalidateLayout()
end

function PANEL:Refresh()
	self.list2:Remove()
	self.list:Remove()
	self:Init()
end

function PANEL:PerformLayout()
	self:StretchToParent(2,26,2,2)
	self.list:StretchToParent(2,2,400,2)
	self.list2:StretchToParent(400,2,2,2)
end

vgui.Register( "df_unlocks_manage", PANEL, "DPanel")

local PANEL = {}

function PANEL:Init()
	local kick_reasons = {"none","Read the fucking manual", "Voice spam", "Flaming", "Exploiting", "Chat Spam", "Too young"}
	local ban_times = {"5","10","30","60","120", "1440", "0"}
	self.list = vgui.Create("DListView", self)
	self.list:AddColumn("Players")
	for k,v in pairs(player.GetAll()) do
		self.list:AddLine(v:Nick())
	end
	self.list:SortByColumn( 1, false )
	self.lab = vgui.Create("DLabel",self)
	self.lab:SetText("Reason:")
	self.lab:SetPos(10,482.5)
	self.lab:SizeToContents()
	self.lab:SetTextColor(Color(0,0,0,255))
	self.banlabel = vgui.Create("DLabel",self)
	self.banlabel:SetText("Ban Time(minutes):")
	self.banlabel:SetPos(10,517.5)
	self.banlabel:SizeToContents()
	self.banlabel:SetTextColor(Color(0,0,0,255))
	self.reason = vgui.Create( "DMultiChoice", self )
	self.reason:SetPos(55,480)
	self.reason:SetSize(645,20)
	self.reason:SizeToContents()
 	self.reason:SetEditable( true )
	for k,v in pairs(kick_reasons) do
		self.reason:AddChoice(v)
	end
	self.bantime = vgui.Create( "DMultiChoice", self )
	self.bantime:SetPos(110,515)
	self.bantime:SetSize(590,20)
	self.bantime:SizeToContents()
 	self.bantime:SetEditable( true )
	for k,v in pairs(ban_times) do
		self.bantime:AddChoice(v)
	end
	self.banbut = vgui.Create("DButton",self)
	self.banbut:SetText("Ban")
	self.banbut:SetPos(702,515)
	self.banbut:SetSize(80,20)
	self.banbut.DoClick = function ()
								local nick = self.list:GetSelected()[1]
								if !nick then return end
								nick = nick:GetValue(1)
								for k,v in pairs(player.GetAll()) do
									if v:Nick() == nick then
										local time = self.bantime:GetValue()
										local reason = self.reason.TextEntry:GetValue()
										RunConsoleCommand("df_banid",v:UserID( ),time)
										RunConsoleCommand("df_kickid",v:UserID( ),"Banned for "..time.." minute(s) for "..reason)
										--timer.Simple(0.2, self.Refresh,self)
										timer.Simple(0.2, function() self.Refresh() end)
									end
								end
						  end
	self.kickbut = vgui.Create("DButton",self)
	self.kickbut:SetText("Kick")
	self.kickbut:SetPos(702,480)
	self.kickbut:SetSize(80,20)
	self.kickbut.DoClick = function ()
								local pan = self.list:GetSelected()[1]
								if !pan then return end
								local nick = pan:GetValue(1)
								for k,v in pairs(player.GetAll()) do
									if v:Nick() == nick then
										local reason = self.reason.TextEntry:GetValue()
																				print(reason)
										RunConsoleCommand("df_kickid",v:UserID( ),reason)
										--timer.Simple(0.2, self.Refresh,self)
										timer.Simple(0.2, function() self.Refresh() end)
									end
								end
						  end
	self.list:SelectFirstItem( )
end

function PANEL:Refresh()
	self.list:Clear()
	for k,v in pairs(player.GetAll()) do
		self.list:AddLine(v:Nick())
	end
end

function PANEL:PerformLayout()
	self:StretchToParent(2,26,2,2)
	self.list:StretchToParent(2,2,2,70)
end

vgui.Register( "df_admin", PANEL, "DPanel")

MAPS = nil

local PANEL = {}

function PANEL:Init()
	MAP = self
	self:SetTitle("Votemap")
	self:SetSize(300,400)
	self:SetPos(200,200)
	self:MakePopup()
	self.list = vgui.Create("DListView", self)
	self.list:AddColumn("Maps")
	self:ShowCloseButton( false )
	function self.list.DoDoubleClick( list, rowid, row )
		RunConsoleCommand( "votemap", row:GetColumnText( 1 ) )
		self:Close( )
	end
	timer.Simple(0.5, function() RunConsoleCommand("getmaps") end)
	self:InvalidateLayout()
end

function PANEL:PerformLayout()
	self:SizeToContents()
	self.list:StretchToParent(2,26,2,2)
end

function GetMaps(length, client)
	local AM = net.ReadInt(16)
	if AM == 0 then
		MAP.list:AddLine("No maps!")
		return
	else
		for i=1, AM do
			MAP.list:AddLine(net.ReadString())
		end
	end
end

--usermessage.Hook("sendmaps", GetMaps)

net.Receive("sendmaps", GetMaps)


vgui.Register( "df_maps", PANEL, "DFrame")

function StartMapVote(length, client)
	MAP = vgui.Create("df_maps")
end

--usermessage.Hook("mapvote", StartMapVote)

net.Receive("mapvote", StartMapVote)

--if TEAM_BASED then
local PANEL = {}

function PANEL:Init()
	self:SetTitle("Choose Team")
	self:SetSize(200,200)
	self:SetPos(ScrW() / 2 + 100, ScrH() / 2 + 100)
	self.but1 = vgui.Create("DButton", self)
	self.but1:SetText("GBU")
	self.but1:SetSize(45,45)
	self.but1:SetPos(5,5)
	self.but2 = vgui.Create("DButton", self)
	self.but2:SetText("IDC")
	self.but2:SetSize(45,45)
	self.but2:SetPos(105,5)
end

vgui.Register("df_teamchose", PANEL, "DFrame")

function open_tem(ply,cmd,args)
	vgui.Create("df_teamchose")
end

concommand.Add("df_team_menu", open_tem)

--end

local SONGS = {}
SONGS[1] = {NAME = "We Interupt This Programme", ARTIST = "Coburn", URL = "http://www.youtube.com/watch?v=O7uJjY62WLc"}
SONGS[2] = {NAME = "Sweet Child O Mine", ARTIST = "Guns N Roses", URL = "http://www.youtube.com/watch?v=P-AYAv0IoWI"}
SONGS[3] = {NAME = "Propane Nightmares", ARTIST = "Pendulum", URL = "http://www.youtube.com/watch?v=YZBQMJlVXyc"}
SONGS[4] = {NAME = "Slam", ARTIST = "Pendulum", URL = "http://www.youtube.com/watch?v=64Vt3GKqBVQ"}
SONGS[5] = {NAME = "Spitfire", ARTIST = "Prodigy", URL = "http://www.youtube.com/watch?v=iwFSklgSLvk"}
SONGS[6] = {NAME = "Breathe", ARTIST = "Prodigy", URL = "http://www.youtube.com/watch?v=WpGsE1k7bXE"}
SONGS[7] = {NAME = "Voodoo People (Pendulum Remix)", ARTIST = "Prodigy", URL = "http://www.youtube.com/watch?v=zkqYYFFgY3E"}
SONGS[8] = {NAME = "What is love?", ARTIST = "Haddaway", URL = "http://www.youtube.com/watch?v=nsCXZczTQXo"}
SONGS[9] = {NAME = "Through the Fire and the Flames", ARTIST = "Dragonforce", URL = "http://www.youtube.com/watch?v=5nVSYt3c0jw"}
SONGS[10] = {NAME = "The Ride of the Valkyries", ARTIST = "Richard Wagner", URL = "http://www.youtube.com/watch?v=V92OBNsQgxU"}
SONGS[11] = {NAME = "Radio 1 Dance Mix", ARTIST = "RADIO", URL = "http://www.bbc.co.uk/iplayer/console/b00h8t0c"}
SONGS[12] = {NAME = "Radio 1 Indie/Rock", ARTIST = "RADIO", URL = "http://www.bbc.co.uk/iplayer/console/b00hg6wy"}
SONGS[13] = {NAME = "Radio 1 HipHop", ARTIST = "RADIO", URL = "http://www.bbc.co.uk/iplayer/console/b00hg6dg"}
SONGS[14] = {NAME = "I'm on a boat", ARTIST = "The Lonely Island", URL = "http://www.youtube.com/watch?v=R7yfISlGLNU"}
SONGS[15] = {NAME = "Kerrang Radio!", ARTIST = "RADIO", URL = "http://www.whatson.com/kerrang/"}
SONGS[16] = {NAME = "Learn to fly", ARTIST = "Foo Fighters", URL = "http://www.youtube.com/watch?v=zdX-RX5IHAU"}
SONGS[17] = {NAME = "Omen", ARTIST = "Prodigy", URL = "http://www.youtube.com/watch?v=uVefPPr69NU"}
SONGS[18] = {NAME = "The Device has been modified", ARTIST = "The Cyber Cat", URL = "http://www.youtube.com/watch?v=8IGS9qY7xko"}
SONGS[19] = {NAME = "Aces High", ARTIST = "Iron Maiden", URL = "http://www.youtube.com/watch?v=v69yX3qZUZQ"}

DF_RADIO = nil

local PANEL = {}

function PANEL:Init()
	DF_RADIO = self
	self:SetSize(400,470)
	self:SetTitle("Radio")
	self:MakePopup()
	self.list = vgui.Create("DPanelList", self)
	self.list:SetPadding(2)
	self.list:EnableVerticalScrollbar( true )
	self.buts = {}
	self.HTML = vgui.Create("HTML",self)
	local lab = vgui.Create("DLabel", self)
	lab:SetText("Click on a song to play it!")
	lab:SetPos(6,26)
	lab:SizeToContents()
	for k,v in pairs(SONGS) do
		local but = vgui.Create("DButton", self)
		but.txt = "["..k.."]"..v.NAME.." - "..v.ARTIST
		but:SetText(but.txt)
		but.DoClick = function() if self.HTML.BUT then self.HTML.BUT:SetText(self.HTML.BUT.txt) end self.HTML:OpenURL(v.URL) self.HTML.BUT = but but:SetText("LOADING - "..but.txt.." - LOADING") end
		self.list:AddItem(but)
		table.insert(self.buts, but)
	end
	local stop = vgui.Create("DButton", self)
	stop:SetText("Stop")
	stop.DoClick = function() self.HTML:OpenURL("http://www.google.com") self.HTML.BUT:SetText(self.HTML.BUT.txt) self.HTML.BUT = nil end
	self.list:AddItem(stop)
	self.HTML:SetPos(5,80)
	self.HTML:SetSize(1,1)
	self.HTML:OpenURL("http://www.google.com")
	self.HTML:SetMouseInputEnabled(false)
	self.HTML:SetKeyboardInputEnabled(false)
	self.HTML:SetVisible( false )
	function self.HTML:ProgressChanged( progress )
		if !self.BUT then return end
		local progress = math.Clamp(math.ceil(progress * 100),0,100)
		if progress == 100 then
			self.BUT:SetText("PLAYING - "..self.BUT.txt.." - PLAYING")
		else
			self.BUT:SetText("%"..progress.." - "..self.BUT.txt.." - "..progress.."%")
		end
    end
	self.all = vgui.Create( "DMultiChoice", self )
	self.all:SizeToContents()
 	self.all:SetEditable( false )
	for k,v in pairs(SONGS) do
		self.all:AddChoice(k)
	end
	local allbut = vgui.Create("DButton", self)
	allbut:SetText("Play For All!")
	allbut:SetPos(302,438)
	allbut:SetSize(93,25)
	allbut.DoClick = function () RunConsoleCommand("df_radio_play_all", self.all.TextEntry:GetValue()) end
	self:InvalidateLayout()
	self.BaseClass.PerformLayout( self )
	self.list:InvalidateLayout()
end

function LoadSong(ply,cmd,args)
	local song = SONGS[tonumber(args[1])]
	if !song then return end
	if !DF_RADIO then
		vgui.Create("df_radio")
		DF_RADIO:Close()
	end
	DF_RADIO.buts[tonumber(args[1])].DoClick()
end

concommand.Add("df_radio_song", LoadSong)

function PANEL:PerformLayout()
	self.list:StretchToParent(5,40,5,40)
	self.all:StretchToParent(5,437,100,5)
end

function PANEL:Close()
	self:SetVisible(false)
end

vgui.Register("df_radio", PANEL, "DFrame")

function Radio(ply,cmd,args)
	if !DF_RADIO then
		vgui.Create("df_radio")
	else
		DF_RADIO:SetVisible(true)
	end
end

concommand.Add("df_radio", Radio)

------------SCOOBY F2 MENU

local r = CreateClientConVar( "df_trail_r", 255, true, false )
local g = CreateClientConVar( "df_trail_g", 255, true, false )
local b = CreateClientConVar( "df_trail_b", 255, true, false )
local mat = CreateClientConVar("df_trail_mat", "trails/plasma", true, false)

local PANEL = {}

Trails = {}
Trails["Plasma"] 	= "trails/plasma"
Trails["Tube"] 		= "trails/tube"
Trails["Electric"] 	= "trails/electric"
Trails["Smoke"]  	= "trails/smoke"
Trails["Laser"]  	= "trails/laser"
Trails["PhysBeam"] 	= "trails/physbeam"
Trails["Love"] 		= "trails/love"
Trails["LoL"]  		= "trails/lol"

function PANEL:Init()
    self:SetPos( ScrW() / 2 - (400 / 2),ScrH() / 2 - (250 / 2))
    self:SetSize( 400,250 )
	self:SetTitle( "Trail Selection" )
	self:MakePopup()
	self:ShowCloseButton(false)
	local lab = vgui.Create("DLabel", self)
	lab:SetText("Material")
	lab:SetPos(12,20)
	self.TrailCombo = vgui.Create("DComboBox", self)
	self.TrailCombo:SetPos( 10, 37 )
	self.TrailCombo:SetSize( self:GetWide() * 0.2, self:GetTall() * 0.8 )
	self.TrailCombo:SetMultiple(false)

	for k,v in pairs(Trails) do
		local Name = string.Trim(k)
		TrailMat = v
		self.TrailCombo:AddItem(Name)
	end

	self.ChangeTrail = vgui.Create("DButton", self)
	self.ChangeTrail:SetText( "Change Trail" )
	self.ChangeTrail:SetPos( 95, 160 )
	self.ChangeTrail:SetSize( 300, 80 )
	function self.ChangeTrail.DoClick()
		local Table = self.TrailCombo:GetSelectedItems()[1]
		if !Table then
			self:Close()
			return
		end
		RunConsoleCommand("df_trail_mat", Trails[Table:GetValue()])
		RunConsoleCommand("SetTrail", Trails[Table:GetValue()], r:GetInt(),g:GetInt(),b:GetInt())
		self:Close()
	end
	self.color = vgui.Create("CtrlColor", self)
	self.color:SetConVarR("df_trail_r")
	self.color:SetConVarG("df_trail_g")
	self.color:SetConVarB("df_trail_b")
	self.color:SetPos( 100, 10 )
end

function PANEL:PerformLayout()
	self.color:StretchToParent(95,40,5,5)
end

vgui.Register("df_trails", PANEL, "DFrame")

function SendTrail()
	if LocalPlayer():CheckGroup({"P","G", "S"}) then
		RunConsoleCommand("SetTrail", mat:GetString(), r:GetInt(),g:GetInt(),b:GetInt())
	end
end

timer.Simple(10, SendTrail )

function Trail()
	if LocalPlayer():CheckGroup({"G", "P","S"}) then
		vgui.Create("df_trails")
	else
		LocalPlayer():ChatPrint("You can't set your trails you are not a donator")
	end
end

--usermessage.Hook("team", Trail)

net.Receive("team", Trail)

 local PANEL = {}

 AccessorFunc( PANEL, "m_ConVarR", 				"ConVarR" )
 AccessorFunc( PANEL, "m_ConVarG", 				"ConVarG" )
 AccessorFunc( PANEL, "m_ConVarB", 				"ConVarB" )
 AccessorFunc( PANEL, "m_ConVarA", 				"ConVarA" )

 /*---------------------------------------------------------
    Name: Init
 ---------------------------------------------------------*/
 function PANEL:Init()

 	self.Mixer = vgui.Create( "DColorMixer", self )

 	self.txtR = vgui.Create( "DNumberWang", self )
 	self.txtR:SetDecimals( 0 )
 	self.txtR:SetMinMax( 0, 255 )
 	self.txtG = vgui.Create( "DNumberWang", self )
 	self.txtG:SetDecimals( 0 )
 	self.txtG:SetMinMax( 0, 255 )
 	self.txtB = vgui.Create( "DNumberWang", self )
 	self.txtB:SetDecimals( 0 )
 	self.txtB:SetMinMax( 0, 255 )
 	self.txtA = vgui.Create( "DNumberWang", self )
 	self.txtA:SetDecimals( 0 )
 	self.txtA:SetMinMax( 0, 255 )
 	self.txtA:SetVisible( false )

 end

 /*---------------------------------------------------------
    Name: ConVarR
 ---------------------------------------------------------*/
 function PANEL:SetConVarR( cvar )
 	self.Mixer:SetConVarR( cvar )
 	self.txtR:SetConVar( cvar )
 end

 /*---------------------------------------------------------
    Name: ConVarG
 ---------------------------------------------------------*/
 function PANEL:SetConVarG( cvar )
 	self.Mixer:SetConVarG( cvar )
 	self.txtG:SetConVar( cvar )
 end

 /*---------------------------------------------------------
    Name: ConVarB
 ---------------------------------------------------------*/
 function PANEL:SetConVarB( cvar )
 	self.Mixer:SetConVarB( cvar )
 	self.txtB:SetConVar( cvar )
 end

 /*---------------------------------------------------------
    Name: ConVarA
 ---------------------------------------------------------*/
 function PANEL:SetConVarA( cvar )

 	if ( cvar ) then self.txtA:SetVisible( true ) end
 	self.Mixer:SetConVarA( cvar )
 	self.txtA:SetConVar( cvar )

 end

 /*---------------------------------------------------------
    Name: Init
 ---------------------------------------------------------*/
 function PANEL:PerformLayout()

 	local y =  0 //self.Label1:GetTall() + 5

 	self:SetTall( 110 )

 	self.Mixer:SetSize( 150, 100 )
 	self.Mixer:Center()
 	self.Mixer:AlignLeft( 5 )

 	self.txtR:SizeToContents()
 	self.txtG:SizeToContents()
 	self.txtB:SizeToContents()
 	self.txtA:SizeToContents()

 	self.txtR:AlignRight( 5 )
 	self.txtR:AlignTop( 5 )
 		self.txtG:CopyBounds( self.txtR )
 		self.txtG:CenterVertical( 0.375 )
 			self.txtB:CopyBounds( self.txtG )
 			self.txtB:CenterVertical( 0.625 )
 				self.txtA:CopyBounds( self.txtB )
 				self.txtA:AlignBottom( 5 )

 end



 vgui.Register( "CtrlColor", PANEL, "DPanel" )

