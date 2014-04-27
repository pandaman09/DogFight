--[[
	Player mode Enums
	mode_fly is for normal play
	mode_film is for df_film
	mode_espawn is for spawn editor
]]
local mode_fly = 0
local mode_film = 1
local mode_espawn = 2

--[[
	Helper functions
]]
local Pmeta = FindMetaTable("Player")
function Pmeta:IsInEditor()
	return !IsValid(ply) or !ply:IsAdmin() or !ply:IsSuperAdmin() or !(ply.Mode==mode_espawn)
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

--[[
	Spawn editor stuff!
]]
GAME_SPAWNS = GAME_SPAWNS or {}
spawnEditorEnabled = false
spawnEditors = {}

function EnableEditor(ply)
	if tonumber(ply:GetInfo("df_editspawns")) == 1 then
		if ply:IsAdmin() or ply:IsSuperAdmin() then
			ply:Spectate(OBS_MODE_ROAMING)
			ply.Mode = mode_espawn
			StartEditor(ply)
			ply:ChatPrint("Spawn Editor Enabled, Clearing props and spawning new ones!")
			return true --return something to stop the rest of the GM:PlayerSpawn hook from running!
		end	
		ply:ChatPrint("You are not an admin and cannot use the Spawnpoint Editor")
	end
end
hook.Add("PlayerSpawn","EnableEditor",EnableEditor)

function StartEditor(ply)
	if !ply:IsInEditor() then return end
	table.insert(spawnEditors,ply:SteamID())
	if spawnEditorEnabled==true then ply:ChatPrint("Props already spawned. Editing enabled.") return end
	spawnEditorEnabled = true

	if table.Count(GAME_SPAWNS)>0 then
		GetMaxSID( function(max)
			for k,v in pairs(GAME_SPAWNS) do
				local team = v["team"]
				local spawnpoint = v["spawn"]
				local spawn = ents.Create("spawnpoint_vis")
				local Location = spawnpoint:GetPos()
				local Angle = spawnpoint:GetAngles()
				local num = k
				if max > k then
					num = max + 1
				end
				CreateSpawnProp(num, team, Location, Angle, v)
			end
		end)
	end
end

function ClearEditorSpawns()
	local removed = 0
	if table.Count(GAME_SPAWNS)>0 then
		for k,v in pairs(GAME_SPAWNS) do
			local prop = v["prop"]
			if IsValid(prop) then
				prop:Remove()
			end
			GAME_SPAWNS[k]["prop"] = nil
		end
	end
end

function UpdateEditorSpawns( server_id, team, pos, ang, delete )
	if GAME_SPAWNS[server_id] and IsValid(GAME_SPAWNS[server_id]["prop"]) then
		local ent = GAME_SPAWNS[server_id]["prop"]
		if !IsValid(ent) then MsgN("No prop with this id!") end
		GAME_SPAWNS[server_id]["team"]=spawn
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
		CreateSpawnProp(server_id, team, pos, ang, GAME_SPAWNS)
	end
	if GAME_SPAWNS[server_id] and IsValid(GAME_SPAWNS[server_id]["spawn"]) then
		local ent = GAME_SPAWNS[server_id]["spawn"]
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
		CreateSpawn(server_id, team, pos, ang, GAME_SPAWNS)
	end
	UpdateSpawns(server_id, team, pos, ang, delete, function(data) PrintTable(data) end)
end

net.Receive("updatespawn", function(len, ply)
	if !ply:IsInEditor() then return end
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
	if !ply:IsInEditor() then return end

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
	if !ply:IsInEditor() then return end
	net.Start("spawnpoint_create_derma")
	net.Send(ply)
end
concommand.Add("df_newspawn" , NewSpawnPoint )

--spawn editor stuff
function SpawnEditorOff(ply)
	if !IsValid(ply) then return end
	ply:KillSilent( )
	ply:SendNextSpawn(CurTime()+1)
	ply:SetObserverMode(OBS_MODE_CHASE)
	ply:SetMoveType(MOVETYPE_OBSERVER)
	ply:Spawn()
	CheckEditorStatus(ply)
end

local function checkKey(ply, key)
	if ply.Mode==mode_espawn and tonumber(ply:GetInfo("df_editspawns")) == 0 then
		SpawnEditorOff(ply)
	end
end
hook.Add("KeyPress","spawneditor_check_key",checkKey)

function CheckEditorStatus(ply)
	for k,v in pairs(spawnEditors) do 
		if v == ply:SteamID() then
			table.remove(spawnEditors,key)
		end
	end
	if not (table.Count(spawnEditors)>0) then
		ClearEditorSpawns()
	end
end