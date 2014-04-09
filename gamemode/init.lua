AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "cl_panels.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_scoreboard.lua" )
AddCSLuaFile( "unlocks.lua")


include( "player_extension.lua" )
include( "shared.lua" )
include("mysql.lua")
include( "commands.lua" )

--[[
	List of net messages used in the gamemode.
]]
util.AddNetworkString( "up" ) -- cl_init.lua line ~104
util.AddNetworkString( "spec" ) -- cl_init.lua line ~289
util.AddNetworkString( "stop_spec" ) -- cl_init.lua line ~300
util.AddNetworkString( "norm_spec" ) -- cl_init.lua line ~313
util.AddNetworkString( "message" ) -- cl_init.lua line ~413
util.AddNetworkString( "help" ) -- cl_init.lua line ~421
util.AddNetworkString( "update_ammo" ) -- cl_init.lua line ~430
util.AddNetworkString( "nextspawn" ) -- cl_init.lua line ~438
util.AddNetworkString( "sendflags" ) -- cl_init.lua line ~447
util.AddNetworkString( "killmsg" ) -- cl_init.lua line ~727
util.AddNetworkString( "monmsg" ) -- cl_init.lua line ~764

util.AddNetworkString( "ul_start" ) -- cl_panels.lua line ~363
util.AddNetworkString( "ul_end" ) -- cl_panels.lua line ~374
util.AddNetworkString( "ul_chunk" ) -- cl_panels.lua line ~386
util.AddNetworkString( "stats" ) -- cl_panels.lua line ~395
util.AddNetworkString( "sendmaps" ) -- cl_panels.lua line ~600
util.AddNetworkString( "mapvote" ) -- cl_panels.lua line ~611
util.AddNetworkString( "team" ) -- cl_panels.lua line ~839

util.AddNetworkString( "send_ul" ) -- player_extension.lua line ~59
util.AddNetworkString( "send_ul" ) -- unlocks.lua

--[[
	Resource Table
]]
local ResourceLocations = {
	"materials/modulus/particles/",
	"materials/DFHUD/crosshair.vtf",
	"materials/bennyg/cannon_1/",
	"materials/models/airboat/",
	"models/Bennyg/Cannons/",
	"materials/bennyg/radar/",
	"models/Bennyg/Radar/",
	"models/Bennyg/plane/",
	"sound/df/"
}

--[[
	Create spawnpoints
]]
gamemode.SpawnPoints = {}		
gamemode.SpawnPoints.maps = {}

-- Incase we couldn't get custom map spawns.
gamemode.SpawnPoints.Fallbacks = {
	Vector(308.807587, -823.679688, 4000),
	Vector(-604.365051, -121.023193, 4000),
	Vector(-99.311798, -563.050171, 4000)
}

--	dfa_rsi
gamemode.SpawnPoints.maps[ "dfa_rsi" ] = {
	FreeForAll = {
		Vector(308.807587, -823.679688, 4000),
		Vector(-604.365051, -121.023193, 4000),
		Vector(-99.311798, -563.050171, 4000)	
	},

	TeamBased = {
		[1] = {
			Vector(7791.807587, -6489.679688, 3000),
			Vector(7591.807587, -6489.679688, 3000),
			Vector(7891.807587, -6489.679688, 3000),
		},
		[2] = {
			Vector(800.807587, -823.679688, 4000),
			Vector(-800.365051, -121.023193, 4000),
			Vector(-800.311798, -563.050171, 4000)
		}
	}
}

--[[
	Desc: Load all the needed resources using ResourceLocations
]]
for key, dir in pairs( ResourceLocations ) do
	local files, dirs = file.Find( dir .. "*", "GAME" )
	if( not files ) then continue end
	for _, fileName in pairs( files ) do
		resource.AddFile(dir .. fileName)
		if( UL_DEBUG ) then
			Msg( "[DF] Adding resource: " .. dir .. fileName .. "\n" )
		end
	end
end

--[[
	Remove spawn points and use the new spawn system.
]]						
function GM:InitPostEntity()
	for _,v in pairs( ents.FindByClass( "info_player_start" )) do
		v:Remove();
	end

	local Spawns = gamemode.SpawnPoints

	-- Create the spawns if it's team based.
	local map = game.GetMap()
	local mapHasSpawns = ( IsValid(Spawns.maps[map]) and Count(Spawns.maps[map])>0 )
	if !IsValid(Spawns.maps[map]) or Count(Spawns.maps[map])==0 then
		Msg("No Spawn points for this map! Please create some.\n")
	--	return
	end

	if( mapHasSpawns and TEAM_BASED ) then
		local TeamSpawns = Spawns.maps[map].TeamBased
		for _, Location in pairs( TeamSpawns[1] ) do
			print( "SPAWNING POINT df_spawn_idc" )
			local SpawnPoint = ents.Create( "df_spawn_idc" )
			SpawnPoint:SetPos( Location )
			SpawnPoint:Spawn()				
		end
		for _, Location in pairs( TeamSpawns[2] ) do
			print( "SPAWNING POINT df_spawn_gbu" )
			local SpawnPoint = ents.Create( "df_spawn_gbu" )
			SpawnPoint:SetPos( Location )
			SpawnPoint:Spawn()
		end
		return
		
	elseif( mapHasSpawns and not TEAM_BASED) then	-- Otherwise create the free for all points.
			for _, Location in pairs( Spawns.maps[map].FreeForAll ) do
				local SpawnPoint = ents.Create( "info_player_start" )
				SpawnPoint:SetPos( Location )
				SpawnPoint:Spawn()			
			end
		return
	end

	-- The map data doesnt exist. Creating fallbacks.
	for _, Location in pairs( Spawns.Fallbacks ) do
		local SpawnPoint = ents.Create( "info_player_start" )
		SpawnPoint:SetPos( Location )
		SpawnPoint:Spawn()
	end
end

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
	Func: GM:ChooseTeam
	Desc: Decide what team to put the player in.
	Params: player ply
]]
function GM:ChooseTeam(ply)
	if( TEAM_BASED ) then
		local Team = team.BestAutoJoinTeam( )		
		-- If the random team selection fails, we'll have to guess. 

		if( math.abs(team.NumPlayers( 1 ) - team.NumPlayers( 2 ) ) <= 1 ) then return end

		if( not Team or Team == TEAM_UNASSIGNED ) then
			ply:SetTeam( math.random( 1, 2 ) )
			return
		end
		ply:SetTeam( Team )
		return
	end
	-- Free for all, add them to the same team.
	ply:SetTeam( 1 )
end

--[[
	Func: GM:CanPlayerSuicide
	Desc: Allow the player to suicide if they're not moving( Landed ) or in film mode.
	Params: player ply
]]
function GM:CanPlayerSuicide ( ply )
	if( IsValid(ply.plane) and ply.plane:GetVelocity():Length() <= 100 ) then return true end
	if( tonumber(ply:GetInfo("df_film")) == 1 or IsValid(ply.plane) ) then return true end
	return false
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

	-- What is the point? A simple anti-ESP? i'll leave it here anyway...
	ply:SendLua([[
	local oh = hook.Add

	function hook.Add(h,n,f)
		if n == "HUD" && h == "HUDShouldDraw" then oh(h,n,f) return end
		if n == "READY" && h == "Think" then oh(h,n,f) return end
		return
	end
	]])
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
		
		if( ply:Team() == T_IDC ) then
			SearchEntity = "df_spawn_idc"
		else 
			SearchEntity = "df_spawn_gbu" 
		end
		
		local SpawnPoints = ents.FindByClass( SearchEntity )
		local SpawnCount = table.Count(SpawnPoints)
		if( not (SpawnCount>0) ) then return Vector( 0,0,1500 ) end
		return SpawnPoints[math.random( 1, SpawnCount ) ]:GetPos() or Vector( 0, 0, 0 )
	end
	return ents.FindByClass( SearchEntity )[math.random( 1, #ents.FindByClass( SearchEntity ) )]:GetPos()
end

--[[
	Func: GM:BalanceTeams
	Desc: Balance the teams to make them even as possible. 
	NOTE: Only called if in a team based game.
]]
function GM:BalancePlayer( ply )
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
		return
	end

	local spawnpoint = self:SelectSpawn(ply)
	ply:SetPos(spawnpoint)

	ply:SetAngles(Angle(0,0,0))
	ply:SetModel("models/player/Group03/male_08.mdl")

	if( !IsValid(ply.plane) )then
		ply.plane = ents.Create("plane")
	end

	ply.plane:SetPos(ply:GetPos())
	ply.plane:SetAngles(Angle(0,0,0))
	ply.plane:Spawn()
	ply:SetMoveType(MOVETYPE_OBSERVER)
	ply.plane:AddPilot(ply)
	ply:SetNWEntity("plane", ply.plane)	
end
hook.Add( "MYSQL.PlayerLoaded", "InitializePlayer", function(ply) ply:Spawn() end )

function GM:DoPlayerDeath()
end

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
				self:KillMessage(killer,name.." killed "..ply:Nick(), KILL_TYPE_KILL)
			else
				self:KillMessage(ply,ply:Nick().." crashed.", KILL_TYPE_CRASH)
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
		
			self:KillMessage(ply,ply:Nick().." crashed.", KILL_TYPE_CRASH)
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

--[[
	Func: GM:ModifySpawnTime
	Desc: Allow the use of custom spawn times.
	Params: player ply, player killer, number time
]]
function GM:ModifySpawnTime(ply,killer, time )
	return time
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
					aw = aw * P_DONATOR_MONEY
				elseif ent:CheckGroup({"G"}) then
					aw = aw * G_DONATOR_MONEY
				end
				ent:AddMoney(aw)
				ent:MoneyMessage("Damaged "..ply:Nick().." (+"..aw.."C)", Color(100,255,100,255))
			end
		end
	end
end

--[[
	Func: GM:ScalePlaneDamage
	Desc: Determine damage scale for unlock && other bonuses. 
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

--[[
	Func: GM:PlayerDisconnected
	Desc: Remove the players plane, if it exists.
	NOTE: removed profile saving because mysql.lua handles this already.
]]
function GM:PlayerDisconnected(ply)
	if IsValid(ply.plane) then
		ply.plane:Remove()
	end
end

function SpectateOff(ply)
	if !IsValid(ply) then return end
	ply:KillSilent( )
	ply:SendNextSpawn(CurTime()+1)
	ply:SetObserverMode(OBS_MODE_CHASE)
	ply:SetMoveType(MOVETYPE_OBSERVER)
end

function GM:KeyPress(ply, key)
	if IsValid(ply) and !ply:Alive() and ply:GetObserverMode( )!=6 then
		ply.respawnNow = true
	end
	if ply:GetObserverMode( )==6 and tonumber(ply:GetInfo("df_film")) == 0 then
		SpectateOff(ply)
	end
end