--[[
	init globals
]]
GAME_SPAWNS = GAME_SPAWNS or {}

--[[
	init locals
]]
local gamemode.SpawnPoints = {}
local gamemode.SpawnPoints.maps = {}
local gamemode.SpawnPoints.Fallbacks = { -- Incase we couldn't get custom map spawns.
	[1]={
		["vec"]=Vector(-108, -100, 2000),
		["ang"]=Angle(0,0,0)
	},
	[2]={
		["vec"]=Vector(0, 0, 2000),
		["ang"]=Angle(0,0,0)
	},
	[3]={
		["vec"]=Vector(100, 100, 2000),
		["ang"]=Angle(0,0,0)
	}
}
--workaround and faster because we are only looking up the global once
local TEAM_BASED = GM.TEAM_BASED
local SPAWN_TIME = GM.SPAWN_TIME
local CRASH_FINE = GM.CRASH_FINE

--[[
	Player mode Enums
	mode_fly is for normal play
	mode_film is for df_film
	mode_espawn is for spawn editor
]]
local mode_fly = 0
local mode_film = 1
local mode_espawn = 2

local team_nums = {
	["IDC"]=1,
	["GBU"]=2,
	["FFA"]=3,
}

local kill_type_crash = 1
local kill_type_kill = 2
local kill_type_flak = 3

--[[
	Resource Table
]]
local ResourceLocations = {
	"materials/modulus/particles/",
	"materials/DFHUD/crosshair2.vtf",
	"materials/bennyg/cannon_1/",
	"materials/models/airboat/",
	"models/Bennyg/Cannons/",
	"materials/bennyg/radar/",
	"models/Bennyg/Radar/",
	"models/Bennyg/plane/"
	--"sound/df/" -- no sounds :(
}
--[[
	Desc: Load all the needed resources using ResourceLocations
]]
for key, dir in pairs( ResourceLocations ) do
	local files, dirs = file.Find( dir .. "*", "GAME" )
	if( not files ) then continue end
	for _, fileName in pairs( files ) do
		resource.AddFile(dir .. fileName)
		if( GM.UL_DEBUG ) then
			Msg( "[DF] Adding resource: " .. dir .. fileName .. "\n" )
		end
	end
end

-- Spawn Point Functions
--[[
	Spawn point Creation
]]
--[[
	Remove spawn points and use the new spawn system.
]]	
function GM:InitPostEntity()
	for _,v in pairs( ents.FindByClass( "info_player_start" )) do
		v:Remove();
	end

	GetSpawns(function(data)
		self:CheckSpawns(data)
	end)
end
local function SpawnsForMode(tbl)
	for _,info in pairs(tbl) do
		local team = info.team_id
		if TEAM_BASED and ((team==1) or (team==2)) then
			return true
		end
		if !TEAM_BASED and (team==3) then
			return true
		end
	end
	return false
end
function GM:CheckSpawns(tbl)
	local spawns = tbl or {}
	
	local mapHasSpawns = ( spawns!=nil and spawns[1]!=nil )
	local mapSpawnsForMode = SpawnsForMode(spawns)
	local fallback = false

	if !mapHasSpawns or !mapSpawnsForMode then
		Msg("No Spawn points for this map or mode! Go to Settings menu and enable Spawnpoint Editing\n")
		fallback = true
	end
	
	self:CreateSpawns(fallback, tbl)

end
function GM:CreateSpawns(fallback, tbl)
	if !fallback and tbl then
		for _,info in pairs( tbl ) do
			local server_id = info.server_id
			local string_pos = string.Explode("_",info.position)
			local Location = Vector(string_pos[1],string_pos[2],string_pos[3])
			local string_ang = string.Explode("_",info.angle)
			local Angle = Angle(string_ang[1],string_ang[2],string_ang[3])
			local team_id = info.team_id
			local SpawnPoint

			if team_id == 1 then
				SpawnPoint = ents.Create( "df_spawn_idc" )
			elseif team_id == 2 then
				SpawnPoint = ents.Create( "df_spawn_gbu" )
			elseif team_id == 3 then
				SpawnPoint = ents.Create( "info_player_start" )
			end
			if !IsValid(SpawnPoint) then MsgN("No Spawn Point! - gamoemode/init.lua:138") return end
			GAME_SPAWNS[server_id] = {}
			GAME_SPAWNS[server_id]["spawn"] = SpawnPoint
			GAME_SPAWNS[server_id]["team"] = team_id
			SpawnPoint:SetPos( Location )
			--SpawnPoint:KeyValue("Angles", Angle )
			SpawnPoint:Spawn()
		end	
		return
	end
	
	-- The map data doesnt exist. Creating fallbacks.
	local Spawns = gamemode.SpawnPoints
	GetMaxSID( function(max)
		for server_id, info in pairs( Spawns.Fallbacks ) do
			local Location = info.vec
			local Angle = info.ang
			MsgN( "SPAWNING FALLBACK POINT info_player_start at [",Location,"]" )
			local SpawnPoint = ents.Create( "info_player_start" )
			SpawnPoint:SetPos( Location )
			--SpawnPoint:KeyValue("angles", Angle )
			SpawnPoint:Spawn()
			if max > server_id then
				max = max + 1
				GAME_SPAWNS[max] = {}
				GAME_SPAWNS[max]["spawn"] = SpawnPoint
			else
				GAME_SPAWNS[server_id] = {}
				GAME_SPAWNS[server_id]["spawn"] = SpawnPoint
			end
		end
	end)
end


-- Player Spawning
--[[
	Func: GM:ChooseTeam
	Desc: Decide what team to put the player in.
	Params: player ply
]]
function GM:ChooseTeam(ply)
	if( TEAM_BASED ) then
		local Team = team.BestAutoJoinTeam( )
		-- If the random team selection fails, we'll have to guess. 

		if ply:Team()==0 then
			ply:SetTeam( math.random( 1, 2 ) )
			return
		end
		
		--balance teams
		if ( math.abs(team.NumPlayers( 1 ) - team.NumPlayers( 2 ) ) <= 1 ) then return end

		ply:SetTeam( Team )
		return
	end
	-- Free for all, add them to the same team.
	ply:SetTeam( 1 )
end
--[[
	Func: GM:PlayerInitialSpawn
	Desc: Set the player up.
	Params: player ply
]]
function GM:PlayerInitialSpawn(ply)
	ply:SendNextSpawn(0)
	self:ChooseTeam(ply)

	ply.learnt = false
	ply.targ_damage = 0

	ply:GetOptions()

	-- Going to disable this because it's unneeded. Detouring is annoying and the server owners should worry about hackers not us.
	--ply:SendLua([[
	--local oh = hook.Add

	--function hook.Add(h,n,f)
	--	if n == "HUD" && h == "HUDShouldDraw" then oh(h,n,f) return end
	--	if n == "READY" && h == "Think" then oh(h,n,f) return end
	--	return
	--end
	--]])
end
--[[
	Func: PlayerSelectSpawn
	Desc: Select a spawn point depending on gametype
	Args: player ply
]]
function GM:SelectSpawn(ply)
	if( not IsValid( ply ) ) then return Vector( 0, 0, 0 ) end
	
	local SearchEntity = "info_player_start"
	local Team = ply:Team()
	
	-- Select a team based entity.
	if( TEAM_BASED ) then
		
		if( ply:Team() == team_nums["IDC"] ) then
			SearchEntity = "df_spawn_idc"
		else 
			SearchEntity = "df_spawn_gbu" 
		end
		
		local SpawnPoints = ents.FindByClass( SearchEntity )
		local SpawnCount = table.Count(SpawnPoints)
		if !(SpawnCount>0) then
			local FallbackPoints = ents.FindByClass( "info_player_start" )
			local FallbackCount = table.Count(FallbackPoints)
			if (FallbackCount>0) then
				local spawnpick = FallbackPoints[math.random( 1, FallbackCount ) ]
				return (spawnpick:GetPos() or Vector( 0, 0, 0 )), (spawnpick:GetAngles() or Angle( 0, 0, 0 ))
			else
				return Vector( 0, 0, 0 )
			end
		end
		local spawnpick = SpawnPoints[math.random( 1, SpawnCount ) ]
		return (spawnpick:GetPos() or Vector( 0, 0, 0 )), (spawnpick:GetAngles() or Angle( 0, 0, 0 ))
	end
	local spawnpick = ents.FindByClass( SearchEntity )[math.random( 1, #ents.FindByClass( SearchEntity ) )]
	return (spawnpick:GetPos() or Vector( 0, 0, 0 )), (spawnpick:GetAngles() or Angle( 0, 0, 0 ))
end
--[[
	Func: GM:ModifySpawnTime
	Desc: Allow the use of custom spawn times.
	Params: player ply, player killer, number time
	Note: pointless...
]]
function GM:ModifySpawnTime(ply, killer, time )
	return time
end
--[[
	Func: PlayerSpawn
	Desc: Create the player, set their position and create their plane. Removed server query spam for failed profile loads.
	Param: player ply
]]
function GM:PlayerSpawn(ply)
	if( not IsValid( ply ) or ply:IsBot() ) then return end
	if( not ply.Allow or ply.Allow == false ) then 
		ply:Spectate(OBS_MODE_ROAMING)
		return false
	end

	net.Start("stop_spec")
	net.Send(ply)

	if tonumber(ply:GetInfo("df_film")) == 1 then
		ply:Spectate(OBS_MODE_ROAMING)
		ply.Mode = mode_film
		return
	end

	if tonumber(ply:GetInfo("df_editspawns")) == 1 then
		if ply:IsAdmin() or ply:IsSuperAdmin() then
			ply:Spectate(OBS_MODE_ROAMING)
			ply.Mode = mode_espawn
			StartEditor(ply)
			ply:ChatPrint("Spawn Editor Enabled, Clearing props and spawning new ones!")
			return
		end	
		ply:ChatPrint("You are not an admin and cannot use the Spawnpoint Editor")
	end

	local spawnpos,spawnang = self:SelectSpawn(ply)

	ply:SetPos(spawnpos)

	ply:SetAngles(spawnang)
	ply:SetModel("models/player/Group03/male_08.mdl")

	if( !IsValid(ply.plane) )then
		ply.plane = ents.Create("plane")
	end

	ply.plane:SetPos(ply:GetPos())
	ply.plane:SetAngles(ply:GetAngles())
	ply.plane:Spawn()
	ply:SetMoveType(MOVETYPE_OBSERVER)
	ply.plane:AddPilot(ply)
	ply:SetNWEntity("plane", ply.plane)	

	ply.Mode = mode_fly
end
hook.Add( "MYSQL.PlayerLoaded", "InitializePlayer", function(ply) ply:Spawn() end )


-- Client Helper Functions
--[[
	Func: GM:ShowHelp
	Desc: Display the options menu to the player. (F1)
	Params: player ply
]]
function GM:ShowHelp(ply)
	net.Start("help")
	net.Send(ply)
end
--[[
	Func: GM:ShowTeam
	Desc: Display the team menu to the player (F2)
	Params: player ply
]]
function GM:ShowTeam(ply)
	net.Start("team")
	net.Send(ply)
end
--[[
	Func: GM:CanPlayerSuicide
	Desc: Allow the player to suicide if they're not moving( Landed ) or in film mode.
	Params: player ply
]]
function GM:CanPlayerSuicide ( ply )
	if( IsValid(ply.plane) and ply.plane:GetVelocity():Length() <= 100 ) then return true end
	if( tonumber(ply:GetInfo("df_film")) == 1 or IsValid(ply.plane) ) then return true end
	if( tonumber(ply:GetInfo("df_editspawns")) == 1 or IsValid(ply.plane) ) then return true end
	return false
end
--[[
	Func: GM:KillMessage
	Desc: Send player messages
	Params: player ply, string txt, number typ, string ico
]]
function GM:KillMessage(ply, txt, typ, ico)
	ico = ico or "suicide"
	net.Start("killmsg")
		net.WriteInt(typ, 16)
		net.WriteInt(ply:Team(), 16)
		net.WriteString(txt)
	net.Broadcast()
end


--Utility Functions
--[[
	Func: GM:MessageAll
	Desc: Message everyone on the server 
	Args: string Text, UNKNOW?
]]
function GM:MessageAll(txt, chat)
	for k,v in pairs(player.GetAll()) do
		v:ChatPrint(txt)
	end
end


--Player Death Functions
function GM:PlayerDeath( ply, pln, pln2)
	
	-- Check if we're in a team based game.
	if( TEAM_BASED ) then
		timer.Simple( 1, function() 
			self:ChooseTeam(ply)
		end)
	end

	local killer = ply.plane.killer
	if killer == "LOAD" then
		ply:SendNextSpawn(CurTime() + 1)
		return
	end

	if tonumber(ply:GetInfo("df_film")) == 1 then
		ply:SendNextSpawn(CurTime())
		return
	end

	if killer != "RESET" then
		local tme = SPAWN_TIME
		if ply.plane.killers != {} && ply.plane.killers != nil then
			local name = "ERROR"
			
			if IsValid(killer) then
				if killer:GetClass() == "player" then
					name = killer:Nick()
					killer:SetNWInt("kills", killer:GetNWInt("kills") + 1)
				elseif killer:GetClass() == "df_flak" then
					name = "Flak"
				end
				self:KillMessage(killer,name.." killed "..ply:Nick(), kill_type_kill)
			else
				self:KillMessage(ply,ply:Nick().." crashed.", kill_type_crash)
				tme = SPAWN_TIME * 2
				ply.tot_crash = ply.tot_crash or 0
				ply.tot_crash = ply.tot_crash + 1
				ply:MoneyMessage("Crashed (-"..math.ceil(CRASH_FINE * ply.skill).."C)", Color(255,100,100))
				ply:TakeMoney(math.ceil(CRASH_FINE * ply.skill))
				ply:StartNormalSpec()
			end

			ply:SetNWInt("deaths", ply:GetNWInt("deaths", 0) + 1)
			self:CalcDamageMoney(killer,ply)
		else
		
			self:KillMessage(ply,ply:Nick().." crashed.", kill_type_crash)
			tme = SPAWN_TIME * 2
			ply.tot_crash = ply.tot_crash or 0
			ply.tot_crash = ply.tot_crash + 1
			ply:MoneyMessage("Crashed (-"..math.ceil(CRASH_FINE * ply.skill).."C)", Color(255,100,100))
			ply:TakeMoney(math.ceil(CRASH_FINE * ply.skill))
			ply:StartNormalSpec()
			
		end
		
		tme = self:ModifySpawnTime(ply, killer, tme)
		ply:SendNextSpawn(CurTime() + tme)
	else
		ply:SendNextSpawn(CurTime() + 3)
	end
	
end
--[[
	Func: GM:CalcDamageMoney
	Desc: Manage the players money.
	Params: player killer, player ply
]]
function GM:CalcDamageMoney(killer, ply)
	for k, v in pairs(ply.plane.killers) do
		local ent = player.GetByUniqueID(k)
		if IsValid(ent) && ent != ply then
			local aw = v / ply.plane.MAX_DAMAGE * 10
			aw = math.ceil( math.Clamp(math.floor(aw),0, 10) * ply.plane.ARMOUR )
			if ent == killer then aw = aw + 5 end
			if aw > 1 then
				if ent:CheckGroup({"P"}) then
					aw = aw * GM.P_DONATOR_MONEY
				elseif ent:CheckGroup({"G"}) then
					aw = aw * GM.G_DONATOR_MONEY
				end
				ent:AddMoney(aw)
				ent:MoneyMessage("Damaged "..ply:Nick().." (+"..aw.."C)", Color(100,255,100,255))
			end
		end
	end
end
--[[
	Func: GM:PlayerDeathThink
	Desc: Respawn player if they press a button or if they exit df_film mode
	NOTE: removed profile saving because mysql.lua handles this already.
]]
function GM:PlayerDeathThink(ply)
	if !IsValid(ply) then return end
	if( not ply.Allow or ply.Allow == false ) then return end
	if tonumber(ply:GetInfo("df_film")) == 0 and ply:GetObserverMode( )!=5 then
		ply:Spawn()
	end
	if ply.respawnNow and ply.respawnNow == true then
		ply.respawnNow = false
		ply:Spawn()
	end
end


--Plane Functions
--[[
	Func: GM:ScalePlaneDamage
	Desc: Determine damage scale for unlock && other bonuses. 
	Note: useless
]]
function GM:ScalePlaneDamage(plane,dmg)
	return dmg
end
--[[
	Func: GM:PlayerShouldTakeDamage
	Desc: Make sure the player cannot be killed.
	Params: player ply
]]
function GM:PlayerShouldTakeDamage(ply)
	return false
end
--[[
	Func: GM:EntityTakeDamage
	Desc: Simulate damage on the plane.
	Params: entity entity, CTakeDamageInfo dmginfo
]]
function GM:EntityTakeDamage( entity, dmginfo )
	local DamageAmount = dmginfo:GetDamage( )
	local DamageInflictor = dmginfo:GetInflictor( )

	-- Check if our winds are being shot at. :D
	if entity:GetModel() == "models/props_junk/wood_pallet001a.mdl" then
		if( IsValid(entity.plane) and ( DamageInflictor:GetClass() == "plane_gun" or DamageInflictor:GetClass() == "df_flak") )  then
			entity.plane:TakeDamage( DamageAmount, DamageInflictor, DamageInflictor)
			if entity:Health() <= 10 then entity.plane:SetKiller(DamageInflictor.plane.ply, 1) end
			return true
		end
	end
	return false
end


--Player Disconnect Functions
--[[
	Func: GM:PlayerDisconnected
	Desc: Remove the players plane, if it exists. Check to see if the player was editing.
	NOTE: removed profile saving because mysql.lua handles this already.
]]
function GM:PlayerDisconnected(ply)
	if IsValid(ply.plane) then
		ply.plane:Remove()
	end
	CheckEditorStatus(ply)
end

function SpectateOff(ply)
	if !IsValid(ply) then return end
	ply:KillSilent( )
	ply:SendNextSpawn(CurTime()+1)
	ply:SetObserverMode(OBS_MODE_CHASE)
	ply:SetMoveType(MOVETYPE_OBSERVER)
	ply:Spawn()
end

--spawn editor stuff and death
function GM:KeyPress(ply, key)
	if IsValid(ply) and !ply:Alive() and ply.Mode==mode_fly then
		ply.respawnNow = true
	end
	if ply.Mode==mode_film and tonumber(ply:GetInfo("df_film")) == 0 then
		SpectateOff(ply)
	end
end