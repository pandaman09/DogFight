include('shared.lua')

--surface.CreateFont ( "coolvetica", 40, 400, true, false, "CV20", true )
surface.CreateFont ("CV20", {
	font = "Arial",
	size = 20,
	weight = 400,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = true,
} )

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

team_names = {
	[0]="FALLBACK",
	[1]="IDC",
	[2]="GBU",
	[3]="FFA",
}
team_nums = {
	["IDC"]=1,
	["GBU"]=2,
	["FFA"]=3,
}

function ENT:Draw()
	self:DrawModel()

	local ent = self
	local tdang = LocalPlayer():EyeAngles()
	local tdpos = self:GetPos() + Vector(0,0,100) + tdang:Up()

	tdang:RotateAroundAxis( tdang:Forward(), 90 )
	tdang:RotateAroundAxis( tdang:Right(), 90 )

	local team = team_names[self:GetNWInt("team_name_boat", 0)]
	if team=="" or team==nil then team="NO STRING!" end

	local pos = self:GetPos()
	local pos_tbl = string.Explode(" ",tostring(pos))
	local nice_pos = ""
	for k,v in pairs(pos_tbl) do
		local max = string.len(v)-4
		local trim = string.sub(v,1,max)
		if k==3 then
			nice_pos = nice_pos..trim
		else
			nice_pos = nice_pos..trim..","
		end
	end
	local ang = self:GetAngles()
	local ang_tbl = string.Explode(" ",tostring(ang))
	local nice_ang = ""
	for k,v in pairs(ang_tbl) do
		local max = string.len(v)-4
		local trim = string.sub(v,1,max)
		if k==3 then
			nice_ang = nice_ang..trim
		else
			nice_ang = nice_ang..trim..","
		end
	end

	cam.Start3D2D( tdpos, Angle( 0, tdang.y, 90 ), 0.25 )
		draw.RoundedBox( 6, -150, -20, 300, 80, Color(0,0,0,255) )
		draw.DrawText( team.." SPAWN", "CV20", 0, 0, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
		draw.DrawText( "Position: ["..nice_pos.."]", "CV20", 0, 20, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
		draw.DrawText( "Angle: ["..nice_ang.."]", "CV20", 0, 40, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
		if LocalPlayer():GetEyeTrace( ).Entity == self then
			draw.DrawText( "Press E to modify!", "CV20", 0, -20, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
		end
	cam.End3D2D()
	if LocalPlayer():GetEyeTrace( ).Entity == ent and input.IsKeyDown( KEY_E ) and !ent.ispressed and !gui.IsGameUIVisible( ) and !gui.IsConsoleVisible() then
		ent.ispressed = true

		settings = vgui.Create("DFrame")
		local H = ScrH()
		local W = ScrW()
		settings:SetPos((W/2)-150,(H/2)-200)
		settings:SetSize(300,400)
		settings:SetTitle("Settings")
		settings:SetVisible(true)
		settings:SetDraggable(true)
		settings:ShowCloseButton(true)
		settings:MakePopup()
		settings.OnClose = function()
			ent.ispressed = false
		end
		
		local team_select = vgui.Create( "DComboBox", settings )
		team_select:SetPos( 100, 35 )
		team_select:SetSize( 100, 20 )
		team_select:SetValue( "Team Name" )
		team_select:AddChoice( "IDC" )
		team_select:AddChoice( "GBU" )
		team_select:AddChoice( "FFA" )
		team_select.OnSelect = function( panel, index, value)
			ent:SetNWInt( "team_name_boat", team_nums[value] )
		end

		local world_x_min = ent:GetNWInt("world_x_min", -10000 )
		local world_x_max = ent:GetNWInt("world_x_max", 10000 )
		local world_y_min = ent:GetNWInt("world_y_min", -10000 )
		local world_y_max = ent:GetNWInt("world_y_max", 10000 )
		local world_z_min = ent:GetNWInt("world_z_min", -10000 )
		local world_z_max = ent:GetNWInt("world_z_max", 10000 )
		--[[
		local world_x_select = vgui.Create( "DNumSlider", settings )
		world_x_select:SetPos( 10, 40 )
		world_x_select:SetSize( 300, 100 )
		world_x_select:SetText( "Position X" )
		world_x_select:SetMin( world_x_min )
		world_x_select:SetMax( world_x_max )
		world_x_select:SetDecimals( 0 )
		world_x_select:UpdateNotches()
		world_x_select.OnValueChanged = function ( val )
			local new_pos = Vector( val , pos.y , pos.z )
			self:SetPos(new_pos)
		end

		local world_y_select = vgui.Create( "DNumSlider", settings )
		world_y_select:SetPos( 10, 60 )
		world_y_select:SetSize( 300, 100 )
		world_y_select:SetText( "Position Y" )
		world_y_select:SetMin( world_y_min )
		world_y_select:SetMax( world_y_max )
		world_y_select:SetDecimals( 0 )
		world_y_select:UpdateNotches()
		world_y_select.OnValueChanged = function ( val )
			local new_pos = Vector( pos.x , val , pos.z )
			self:SetPos(new_pos)
		end

		local world_z_select = vgui.Create( "DNumSlider", settings )
		world_z_select:SetPos( 10, 80 )
		world_z_select:SetSize( 300, 100 )
		world_z_select:SetText( "Position Z" )
		world_z_select:SetMin( world_z_min )
		world_z_select:SetMax( world_z_max )
		world_z_select:SetDecimals( 0 )
		world_z_select:UpdateNotches()
		world_z_select.OnValueChanged = function ( val )
			local new_pos = Vector( pos.x, pos.y , val )
			self:SetPos(new_pos)
		end
		]]
		local world_x_label = vgui.Create( "DLabel", settings )
		world_x_label:SetPos( 50, 60 )
		world_x_label:SetText( "Position X" )
		local world_x_select = vgui.Create( "DTextEntry", settings )	-- create the form as a child of frame
		world_x_select:SetPos( 150, 60 )
		world_x_select:SetSize( 100, 25 )
		world_x_select:SetNumeric( true )
		world_x_select:SetText( pos.x )
		world_x_select.OnEnter = function( self )
			local new_pos = Vector( self:GetFloat() , ent:GetPos().y , ent:GetPos().z )
			ent:SetPos(new_pos)
		end

		local world_y_label = vgui.Create( "DLabel", settings )
		world_y_label:SetPos( 50, 90 )
		world_y_label:SetText( "Position Y" )
		local world_y_select = vgui.Create( "DTextEntry", settings )	-- create the form as a child of frame
		world_y_select:SetPos( 150, 90 )
		world_y_select:SetSize( 100, 25 )
		world_y_select:SetNumeric( true )
		world_y_select:SetText( pos.y )
		world_y_select.OnEnter = function( self )
			local new_pos = Vector( ent:GetPos().x , self:GetFloat() , ent:GetPos().z )
			ent:SetPos(new_pos)
		end

		local world_z_label = vgui.Create( "DLabel", settings )
		world_z_label:SetPos( 50, 120 )
		world_z_label:SetText( "Position Z" )
		local world_z_select = vgui.Create( "DTextEntry", settings )	-- create the form as a child of frame
		world_z_select:SetPos( 150, 120 )
		world_z_select:SetSize( 100, 25 )
		world_z_select:SetNumeric( true )
		world_z_select:SetText( pos.z )
		world_z_select.OnEnter = function( self )
			local new_pos = Vector( ent:GetPos().x , ent:GetPos().y , self:GetFloat() )
			ent:SetPos(new_pos)
		end

		local angle_pitch_label = vgui.Create( "DLabel", settings )
		angle_pitch_label:SetPos( 50, 150 )
		angle_pitch_label:SetText( "Angle Pitch" )
		local angle_pitch_select = vgui.Create( "DTextEntry", settings )	-- create the form as a child of frame
		angle_pitch_select:SetPos( 150, 150 )
		angle_pitch_select:SetSize( 100, 25 )
		angle_pitch_select:SetNumeric( true )
		angle_pitch_select:SetText( ang.p )
		angle_pitch_select.OnEnter = function( self )
			local new_ang = Angle( self:GetFloat() , ent:GetAngles().y , ent:GetAngles().r )
			ent:SetAngles(new_ang)
		end

		local angle_yaw_label = vgui.Create( "DLabel", settings )
		angle_yaw_label:SetPos( 50, 180 )
		angle_yaw_label:SetText( "Angle Yaw" )
		local angle_yaw_select = vgui.Create( "DTextEntry", settings )	-- create the form as a child of frame
		angle_yaw_select:SetPos( 150, 180 )
		angle_yaw_select:SetSize( 100, 25 )
		angle_yaw_select:SetNumeric( true )
		angle_yaw_select:SetText( ang.y )
		angle_yaw_select.OnEnter = function( self )
			local new_ang = Angle( ent:GetAngles().p , self:GetFloat() , ent:GetAngles().r )
			ent:SetAngles(new_ang)
		end

		local angle_roll_label = vgui.Create( "DLabel", settings )
		angle_roll_label:SetPos( 50, 210 )
		angle_roll_label:SetText( "Angle Roll" )
		local angle_roll_select = vgui.Create( "DTextEntry", settings )	-- create the form as a child of frame
		angle_roll_select:SetPos( 150, 210 )
		angle_roll_select:SetSize( 100, 25 )
		angle_roll_select:SetNumeric( true )
		angle_roll_select:SetText( ang.r )
		angle_roll_select.OnEnter = function( self )
			local new_ang = Angle( ent:GetAngles().p , ent:GetAngles().y , self:GetFloat() )
			ent:SetAngles(new_ang)
		end

	end
end

function ENT:Use( ply )
	MsgN("derp")
end