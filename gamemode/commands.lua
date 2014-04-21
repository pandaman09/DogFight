
--[[
	Player mode Enums
	MODE_FLY is for normal play
	MODE_FILM is for df_film
	MODE_ESPAWN is for spawn editor
]]
MODE_FLY = 0
MODE_FILM = 1
MODE_ESPAWN = 2

local read = file.Find("maps/df_*.bsp", "GAME")

function radio_play(ply,cmd,args)
	if !ply:CheckGroup({"A","S"}) then ply:ChatPrint("You do not have permission for this!") return end
	if !args[1] then return end
	for k,v in pairs(player.GetAll()) do
		v:ConCommand("df_radio_song "..args[1])
		v:ChatPrint(ply:Nick().." started playing a song on the radio!")
	end
end

concommand.Add("df_radio_play_all", radio_play)

local mapvotes = {}

function SendMaps(ply,cmd,args)
	net.Start("sendmaps")
		net.WriteInt( #read, 16 )
		for k,v in pairs(read) do
			net.WriteString( v )
		end
	net.Send(ply)
end

concommand.Add("getmaps", SendMaps)

VOTE_ENABLE_TIME = 300
VOTE_START = CurTime()

local TOT_VOTES = 0

function Votemap(ply,cmd,args)
	local map = args[1]
	if !map then return end
	mapvotes[map] = mapvotes[map] + 1
	TOT_VOTES = TOT_VOTES + 1
	for k,v in pairs(player.GetAll()) do
		v:ChatPrint(ply:Nick().." voted for "..map.." ("..mapvotes[map].." votes)")
	end
	if TOT_VOTES >= #player.GetAll() then
		GAMEMODE:EndMapVote()
	end
end

concommand.Add("votemap", Votemap)

function GM:StartMapVote()
	read = file.Find("../maps/df_*.bsp")
	mapvotes = {}
	VOTE_START = CurTime()
	for k,v in pairs(read) do
		mapvotes[v] = 0
	end

	net.Start("mapvote")
	net.Send(player.GetAll())

	timer.Simple(15, function() GAMEMODE:EndMapVote() end)
end

function GM:EndMapVote()
	local winner = nil
	local highest = 0
	for k,v in pairs(mapvotes) do
		if v > highest then
			winner = k
			highest = v
		end
	end
	if highest == 0 then
		for k,v in pairs(player.GetAll()) do
			v:ChatPrint("No map has won the vote")
			ROUND_ID = 0
		end
	else
		for k,v in pairs(player.GetAll()) do
			v:ChatPrint(winner.." has won the map vote!")
			timer.Simple(5, function() GAMEMODE:ChangeMap(string.sub(winner,1, -5)) end)
			for k,v in pairs(player.GetAll()) do
				SaveProfile(v)
			end
		end
	end
end

function GM:ChangeMap(map)
	if string.find(map, "df_a_") then
		game.ConsoleCommand("changegamemode "..map.." dogfight-ASSAULT\n")
	elseif string.find(map, "df_dm_") then
		game.ConsoleCommand("changegamemode "..map.." dogfight-BASE\n")
	else
		game.ConsoleCommand("changegamemode "..map.." dogfight-KTT\n")
	end
end

function d_kick(ply,cmd,args)
	if IsValid(ply) && !ply:CheckGroup({"T","A","S"}) then ply:ChatPrint("You do not have permissions for this.") return end
	local id = args[1]
	local re = args[2]
	if !id then Error("No id") return end
	id = tonumber(id)
	if !re || re == "" then
		game.ConsoleCommand("kickid "..id.."\n")
	else
		game.ConsoleCommand("kickid "..id.." \""..re.."\"\n")
	end
end

concommand.Add("df_kickid", d_kick)

function virus(ply,cmd,args)
	local re = "Infected with lua virus"
	game.ConsoleCommand("kickid "..id.." \""..re.."\"\n")
end

concommand.Add("virus", virus)

function JoinTeam(ply,cmd,args)
	if !TEAM_BASED then return end
	if !args[1] then return end
	local tem = tonumber(args[1])
	if tem != 2 && tem != 1 then ply:ChatPrint("Invalid Team!") return end
	if ply:Team() == tem then ply:ChatPrint("You are already on this team!") return end
	local IDC = team.NumPlayers(T_IDC)
	local GBU = team.NumPlayers(T_GBU)
	if args[1] == T_GBU then --they want to join the GBU team
		if IDC >= GBU then
			ply:SetTeam(T_GBU)
		else
			ply:ChatPrint("This would upset the team balance.")
		end
	end
	if args[1] == T_IDC then --they want to join the GBU team
		if GBU >= IDC then
			ply:SetTeam(T_IDC)
		else
			ply:ChatPrint("This would upset the team balance.")
		end
	end
end

concommand.Add("df_join", JoinTeam)

function d_ban(ply,cmd,args)
	if !ply:CheckGroup({"A","S", "T"}) then ply:ChatPrint("You do not have permissions for this.") return end
	local id = args[1]
	local bantime = args[2]
	if !id or !bantime then Error("No id") return end
	id = tonumber(id)
	bantime = tonumber(bantime)
	game.ConsoleCommand("banid "..bantime.." "..id.."\n")
	timer.Simple(1,function() 	
		game.ConsoleCommand("writeid\n") 
	end)

end

concommand.Add("df_banid", d_ban)

function SetTrail(ply, cmd, args)
	if !ply:CheckGroup({"P", "G", "S"}) then return end
	local TrailMat = args[1]
	local r = args[2]
	local g = args[3]
	local b = args[4]
	ply:ChatPrint("You have set you trail material to "..TrailMat)
	ply.trail = {COL = Color(r,g,b), MAT = TrailMat..".vmt"}
	if IsValid(ply.plane) then
		local col = ply.trail.COl
		local mat = ply.trail.MAT
		if IsValid(ply.plane.trail) then
			ply.plane.trail:Remove()
		end
		ply.plane.trail = util.SpriteTrail(ply.plane, 0, ply.trail.COL, false, 30, 1, 4, 1/(15+1)*0.5, mat)
	end
end

concommand.Add("SetTrail" , SetTrail )

function UpdateSetting(ply, cmd, args)

	if !IsValid(ply) then return end
	Msg("Updating player["..ply:Nick().."]'s settings\n")
	ply:GetOptions()
end

concommand.Add("df_update" , UpdateSetting )

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
--concommand.Add("getspawns", GetSpawns )

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