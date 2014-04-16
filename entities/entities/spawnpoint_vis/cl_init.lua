include('shared.lua')

--surface.CreateFont ( "coolvetica", 40, 400, true, false, "CV20", true )
surface.CreateFont ("CV20", {
	font = "Arial",
	size = 20,
	weight = 400,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	outline = true
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
	local tdpos = self:GetPos() + Vector(0,0,40) + tdang:Up()

	tdang:RotateAroundAxis( tdang:Forward(), 90 )
	tdang:RotateAroundAxis( tdang:Right(), 90 )

	local team = team_names[self:GetNWInt("team_id", 0)]
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
end

function ENT:FullUpdate(pos, ang, delete)
	local ent = self
	net.Start("updatespawn")
		--server_id
		net.WriteInt(ent:GetNWInt( "server_id", 0 ),32)
		--team_id
		net.WriteInt(ent:GetNWInt( "team_id", 0 ),16)
		--spawn_pos
		net.WriteTable({pos.x,pos.y,pos.z})
		--spawn_angle
		net.WriteTable({ang.p,ang.y,ang.r})
		--spawn_deleted
		net.WriteBit(delete)
	net.SendToServer()
end

net.Receive("spawnpoint_edit_derma", function(len,ply)
	local ent = net.ReadEntity()
	local pos = ent:GetPos()
	local ang = ent:GetAngles()
	local oldteam = 0
	settings = vgui.Create("DFrame")
	local H = ScrH()
	local W = ScrW()
	settings:SetPos((W/2)-150,(H/2)-200)
	settings:SetSize(300,380)
	settings:SetTitle("Settings")
	settings:SetVisible(true)
	settings:SetDraggable(true)
	settings:ShowCloseButton(true)
	settings:MakePopup()
	settings.OnClose = function()
		ent.ispressed = false
	end
	
	local team_cur = ent:GetNWInt( "team_id", 0 )
	team_label = vgui.Create( "DLabel", settings )
	team_label:SetPos( 50, 35 )
	team_label:SetText( "Team: "..team_names[team_cur] )
	team_select = vgui.Create( "DComboBox", settings )
	team_select:SetPos( 150, 35 )
	team_select:SetSize( 100, 20 )
	team_select:SetValue( "Team Name" )
	team_select:AddChoice( "IDC" )
	team_select:AddChoice( "GBU" )
	team_select:AddChoice( "FFA" )
	team_select.OnSelect = function( panel, index, value)
		if IsValid(ent) then
			ent:SetNWInt( "team_id", team_nums[value] )
		end
	end

	local world_x_label = vgui.Create( "DLabel", settings )
	world_x_label:SetPos( 50, 60 )
	world_x_label:SetText( "Position X" )
	world_x_select = vgui.Create( "DTextEntry", settings )	-- create the form as a child of frame
	world_x_select:SetPos( 150, 60 )
	world_x_select:SetSize( 100, 25 )
	world_x_select:SetNumeric( true )
	world_x_select:SetText( pos.x )

	local world_y_label = vgui.Create( "DLabel", settings )
	world_y_label:SetPos( 50, 90 )
	world_y_label:SetText( "Position Y" )
	world_y_select = vgui.Create( "DTextEntry", settings )	-- create the form as a child of frame
	world_y_select:SetPos( 150, 90 )
	world_y_select:SetSize( 100, 25 )
	world_y_select:SetNumeric( true )
	world_y_select:SetText( pos.y )

	local world_z_label = vgui.Create( "DLabel", settings )
	world_z_label:SetPos( 50, 120 )
	world_z_label:SetText( "Position Z" )
	world_z_select = vgui.Create( "DTextEntry", settings )	-- create the form as a child of frame
	world_z_select:SetPos( 150, 120 )
	world_z_select:SetSize( 100, 25 )
	world_z_select:SetNumeric( true )
	world_z_select:SetText( pos.z )

	local angle_pitch_label = vgui.Create( "DLabel", settings )
	angle_pitch_label:SetPos( 50, 150 )
	angle_pitch_label:SetText( "Angle Pitch" )
	angle_pitch_select = vgui.Create( "DTextEntry", settings )	-- create the form as a child of frame
	angle_pitch_select:SetPos( 150, 150 )
	angle_pitch_select:SetSize( 100, 25 )
	angle_pitch_select:SetNumeric( true )
	angle_pitch_select:SetText( ang.p )

	local angle_yaw_label = vgui.Create( "DLabel", settings )
	angle_yaw_label:SetPos( 50, 180 )
	angle_yaw_label:SetText( "Angle Yaw" )
	angle_yaw_select = vgui.Create( "DTextEntry", settings )	-- create the form as a child of frame
	angle_yaw_select:SetPos( 150, 180 )
	angle_yaw_select:SetSize( 100, 25 )
	angle_yaw_select:SetNumeric( true )
	angle_yaw_select:SetText( ang.y )

	local angle_roll_label = vgui.Create( "DLabel", settings )
	angle_roll_label:SetPos( 50, 210 )
	angle_roll_label:SetText( "Angle Roll" )
	angle_roll_select = vgui.Create( "DTextEntry", settings )	-- create the form as a child of frame
	angle_roll_select:SetPos( 150, 210 )
	angle_roll_select:SetSize( 100, 25 )
	angle_roll_select:SetNumeric( true )
	angle_roll_select:SetText( ang.r )

	local spawn_update = vgui.Create( "DButton", settings)
	spawn_update:SetPos( 90, 240 )
	spawn_update:SetText( "Update Point" )
	spawn_update:SetSize( 120, 60 )
	spawn_update.DoClick = function()
	    if IsValid(ent) then
	    	team_label:SetText( "Team: "..ent:GetNWInt( "team_id", 0 ) )
	    	local new_pos = Vector(world_x_select:GetInt(), world_y_select:GetInt(), world_z_select:GetInt())
	    	local new_ang = Angle(angle_pitch_select:GetInt(), angle_yaw_select:GetInt(), angle_roll_select:GetInt())
			ent:FullUpdate(new_pos, new_ang, false)
		end
	end

	local spawn_remove = vgui.Create( "DButton", settings )
	spawn_remove:SetPos( 90, 310 )
	spawn_remove:SetText( "Remove Spawn!" )
	spawn_remove:SetSize( 120, 60 )
	spawn_remove.DoClick = function()
		if IsValid(ent) then
		    local new_pos = Vector(0,0,0)
		    local new_ang = Angle(0,0,0)
		    ent:FullUpdate(new_pos,new_ang, true)
		end
	end
end)

net.Receive("spawnpoint_create_derma", function(len,ply)
	local team_number = 0
	local pos = LocalPlayer():GetPos()
	local ang = LocalPlayer():EyeAngles()

	create_spawn = vgui.Create("DFrame")
	local H = ScrH()
	local W = ScrW()
	create_spawn:SetPos((W/2)-150,(H/2)-200)
	create_spawn:SetSize(300,330)
	create_spawn:SetTitle("New Spawn")
	create_spawn:SetVisible(true)
	create_spawn:SetDraggable(true)
	create_spawn:ShowCloseButton(true)
	create_spawn:MakePopup()
	
	create_team_label = vgui.Create( "DLabel", create_spawn )
	create_team_label:SetPos( 50, 35 )
	create_team_label:SetText( "Team: "..team_names[team_number] )
	create_team_select = vgui.Create( "DComboBox", create_spawn )
	create_team_select:SetPos( 150, 35 )
	create_team_select:SetSize( 100, 20 )
	create_team_select:SetValue( "Team Name" )
	create_team_select:AddChoice( "IDC" )
	create_team_select:AddChoice( "GBU" )
	create_team_select:AddChoice( "FFA" )
	create_team_select.OnSelect = function( panel, index, value)
		team_number = team_nums[value]
	end

	local world_x_label = vgui.Create( "DLabel", create_spawn )
	world_x_label:SetPos( 50, 60 )
	world_x_label:SetText( "Position X" )
	create_world_x_select = vgui.Create( "DTextEntry", create_spawn )	-- create the form as a child of frame
	create_world_x_select:SetPos( 150, 60 )
	create_world_x_select:SetSize( 100, 25 )
	create_world_x_select:SetNumeric( true )
	create_world_x_select:SetText( pos.x )

	local world_y_label = vgui.Create( "DLabel", create_spawn )
	world_y_label:SetPos( 50, 90 )
	world_y_label:SetText( "Position Y" )
	create_world_y_select = vgui.Create( "DTextEntry", create_spawn )	-- create the form as a child of frame
	create_world_y_select:SetPos( 150, 90 )
	create_world_y_select:SetSize( 100, 25 )
	create_world_y_select:SetNumeric( true )
	create_world_y_select:SetText( pos.y )

	local world_z_label = vgui.Create( "DLabel", create_spawn )
	world_z_label:SetPos( 50, 120 )
	world_z_label:SetText( "Position Z" )
	create_world_z_select = vgui.Create( "DTextEntry", create_spawn )	-- create the form as a child of frame
	create_world_z_select:SetPos( 150, 120 )
	create_world_z_select:SetSize( 100, 25 )
	create_world_z_select:SetNumeric( true )
	create_world_z_select:SetText( pos.z )

	local angle_pitch_label = vgui.Create( "DLabel", create_spawn )
	angle_pitch_label:SetPos( 50, 150 )
	angle_pitch_label:SetText( "Angle Pitch" )
	create_angle_pitch_select = vgui.Create( "DTextEntry", create_spawn )	-- create the form as a child of frame
	create_angle_pitch_select:SetPos( 150, 150 )
	create_angle_pitch_select:SetSize( 100, 25 )
	create_angle_pitch_select:SetNumeric( true )
	create_angle_pitch_select:SetText( ang.p )

	local angle_yaw_label = vgui.Create( "DLabel", create_spawn )
	angle_yaw_label:SetPos( 50, 180 )
	angle_yaw_label:SetText( "Angle Yaw" )
	create_angle_yaw_select = vgui.Create( "DTextEntry", create_spawn )	-- create the form as a child of frame
	create_angle_yaw_select:SetPos( 150, 180 )
	create_angle_yaw_select:SetSize( 100, 25 )
	create_angle_yaw_select:SetNumeric( true )
	create_angle_yaw_select:SetText( ang.y )

	local angle_roll_label = vgui.Create( "DLabel", create_spawn )
	angle_roll_label:SetPos( 50, 210 )
	angle_roll_label:SetText( "Angle Roll" )
	create_angle_roll_select = vgui.Create( "DTextEntry", create_spawn )	-- create the form as a child of frame
	create_angle_roll_select:SetPos( 150, 210 )
	create_angle_roll_select:SetSize( 100, 25 )
	create_angle_roll_select:SetNumeric( true )
	create_angle_roll_select:SetText( ang.r )

	local spawn_update = vgui.Create( "DButton", create_spawn)
	spawn_update:SetPos( 90, 240 )
	spawn_update:SetText( "Create Point" )
	spawn_update:SetSize( 120, 60 )
	spawn_update.DoClick = function()
		create_team_label:SetText( "Team: "..team_names[team_number] )
	    net.Start("createspawn")
			--server_id
			--net.WriteString(tostring(ent:GetNWInt("server_id", 0 )),32)
			--team_id
			net.WriteInt( team_number ,16)
			--spawn_pos
			net.WriteTable({create_world_x_select:GetInt(),create_world_y_select:GetInt(),create_world_z_select:GetInt()})
			--spawn_angle
			net.WriteTable({create_angle_pitch_select:GetInt(),create_angle_yaw_select:GetInt(),create_angle_roll_select:GetInt()})
		net.SendToServer()
	end
end)