--[[
	Player mode Enums
	MODE_FLY is for normal play
	MODE_FILM is for df_film
	MODE_ESPAWN is for spawn editor
]]
MODE_FLY = 0
MODE_FILM = 1
MODE_ESPAWN = 2

--[[
	Spawn editor stuff!
]]

game_spawns = game_spawns or {}
spawnEditorEnabled = false
spawnEditors = {}

function StartEditor(ply)
	if !IsValid(ply) or !ply:IsAdmin() or !ply:IsSuperAdmin() or !(ply.Mode==MODE_ESPAWN) then return end
	table.insert(spawnEditors,ply:SteamID())
	if spawnEditorEnabled==true then ply:ChatPrint("Props already spawned. Editing enabled.") return end
	spawnEditorEnabled = true

	if table.Count(game_spawns)>0 then
		GetMaxSID( function(max)
			for k,v in pairs(game_spawns) do
				local team = v["team"]
				local spawnpoint = v["spawn"]
				local spawn = ents.Create("spawnpoint_vis")
				local Location = spawnpoint:GetPos()
				local Angle = spawnpoint:GetAngles()
				if max > k then
					max = max + 1
					spawn:SetPos( Location )
					spawn:SetAngles( Angle )
					spawn:Spawn()
					spawn:SetTeam(team)
					spawn:SetSID(max)
					spawn:SetRenderMode( RENDERMODE_TRANSALPHA )
					spawn:SetColor( Color(255,255,255,200) )
				else
					spawn:SetPos( Location )
					spawn:SetAngles( Angle )
					spawn:Spawn()
					spawn:SetTeam(team)
					spawn:SetSID(k)
					spawn:SetRenderMode( RENDERMODE_TRANSALPHA )
					spawn:SetColor( Color(255,255,255,200) )
				end

				v["prop"]=spawn
			end
		end)
	end
end

function ClearEditorSpawns()
	local removed = 0
	if table.Count(game_spawns)>0 then
		for k,v in pairs(game_spawns) do
			local prop = v["prop"]
			if IsValid(prop) then
				prop:Remove()
			end
			game_spawns[k]["prop"] = nil
		end
	end
end


function CreateSpawn(server_id, team, pos, ang, table_use)
	MsgN("Creating new spawn at [",pos,"] angles of [",ang,"]")
	local spawn
	if team == 1 then
		spawn = ents.Create("df_spawn_idc")
	elseif team == 2 then 
		spawn = ents.Create("df_spawn_gbu")
	elseif team == 3 then 
		spawn = ents.Create("info_player_start")
	end
	spawn:SetPos( pos )
	spawn:SetAngles( ang )
	spawn:Spawn()
	spawn:SetRenderMode( RENDERMODE_TRANSALPHA )
	spawn:SetColor( Color(255,255,255,200) )
	
	table_use[server_id] = table_use[server_id] or {}
	table_use[server_id]["spawn"]=spawn
	table_use[server_id]["team"]=spawn
end

function CreateSpawnProp(server_id, team, pos, ang, table_use)
	MsgN("Creating new spawn prop at [",pos,"] angles of [",ang,"]")
	local spawn = ents.Create("spawnpoint_vis")
	spawn:SetPos( pos )
	spawn:SetAngles( ang )
	spawn:Spawn()
	spawn:SetTeam(team)
	spawn:SetSID(server_id)
	spawn:SetRenderMode( RENDERMODE_TRANSALPHA )
	spawn:SetColor( Color(255,255,255,200) )

	table_use[server_id] = table_use[server_id] or {}
	table_use[server_id]["prop"]=spawn
end

function UpdateEditorSpawns( server_id, team, pos, ang, delete )
	if game_spawns[server_id] and IsValid(game_spawns[server_id]["prop"]) then
		local ent = game_spawns[server_id]["prop"]
		if !IsValid(ent) then MsgN("No prop with this id!") end
		game_spawns[server_id]["team"]=spawn
		if isvector(pos) and util.IsInWorld(pos) then
			ent:SetPos(pos)
		end
		if isangle(ang) and (ent:GetAngles()!=ang) then
			ent:SetAngles(ang)
		end
		if delete==true then
			ent:Remove()
			MsgN("GBU SPAWN PROP - ID: "..server_id.." WAS REMOVED!")
		end
	else
		CreateSpawnProp(server_id, team, pos, ang, game_spawns)
	end
	if game_spawns[server_id] and IsValid(game_spawns[server_id]["spawn"]) then
		local ent = game_spawns[server_id]["spawn"]
		if !IsValid(ent) then MsgN("No spawn with this id!") end
		if isvector(pos) and util.IsInWorld(pos) then
			ent:SetPos(pos)
		end
		if isangle(ang) and (ent:GetAngles()!=ang) then
			ent:SetAngles(ang)
		end
		if delete==true then
			ent:Remove()
			MsgN("GBU SPAWN - ID: "..server_id.." WAS REMOVED!")
		end
	else
		CreateSpawn(server_id, team, pos, ang, game_spawns)
	end
	UpdateSpawns(server_id, team, pos, ang, delete, function(data) PrintTable(data) end)
end

net.Receive("updatespawn", function(len, ply)
	if !IsValid(ply) or !ply:IsAdmin() or !ply:IsSuperAdmin() or !(ply.Mode==MODE_ESPAWN) then return end
	--id
	local server_id = net.ReadInt(32)
	--spawn_team
	local team = net.ReadInt(16)
	--spawn_pos
	local pos_tbl = net.ReadTable()
	local pos = Vector( pos_tbl[1], pos_tbl[2], pos_tbl[3] )
	--spawn_angle
	local ang_tbl = net.ReadTable()
	local ang = Angle( ang_tbl[1], ang_tbl[2], ang_tbl[3] )
	--spawn_deleted
	local delete = tobool(net.ReadBit())
	UpdateEditorSpawns( server_id, team, pos, ang, delete )
end)

net.Receive("createspawn", function(len, ply)
	if !IsValid(ply) or !ply:IsAdmin() or !ply:IsSuperAdmin() or !(ply.Mode==MODE_ESPAWN) then return end

	local team = net.ReadInt(16)
	local pos_tbl = net.ReadTable()
	local pos = Vector( pos_tbl[1], pos_tbl[2], pos_tbl[3] )
	local ang_tbl = net.ReadTable()
	local ang = Angle( ang_tbl[1], ang_tbl[2], ang_tbl[3] )
	GetMaxSID( function(server_id)
		next_id = server_id + 1
		UpdateEditorSpawns( next_id, team, pos, ang, false )
	end)
end)

function NewSpawnPoint(ply, cmd, args)
	if !IsValid(ply) or !ply:IsAdmin() or !ply:IsSuperAdmin() or !(ply.Mode==MODE_ESPAWN) then return end
	net.Start("spawnpoint_create_derma")
	net.Send(ply)
end
concommand.Add("df_newspawn" , NewSpawnPoint )