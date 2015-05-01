
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("player_extension.lua")
--AddCSLuaFile("cl_panels.lua")--doesnt exist?
AddCSLuaFile("powerup.lua")
AddCSLuaFile("vgui/vgui_rockets.lua")
AddCSLuaFile("vgui/vgui_powerup.lua")
AddCSLuaFile("cl_selectscreen.lua")
AddCSLuaFile("cl_help.lua")
AddCSLuaFile("cl_tips.lua")

include("shared.lua")
include("player_extension.lua")
include("round_controller.lua")
include("leaderboards.lua")

resource.AddFile("models/Bennyg/plane/re_airboat2.mdl")
resource.AddFile("models/Bennyg/plane/re_airboat_pallet2.mdl")
resource.AddFile("models/Bennyg/plane/re_airboat_tail2.mdl")
resource.AddFile("models/Bennyg/dogfight/airboat.mdl")

resource.AddFile("models/props_dogfight/tree_dogfight.mdl")
resource.AddFile("models/props_dogfight/tree_cluster_dogfight.mdl")

resource.AddFile("materials/models/props_dogfight/dog_tree.vmt")
resource.AddFile("materials/models/props_dogfight/dog_tree.vtf")

resource.AddFile("materials/DFHUD/crosshair2.vmt");
resource.AddFile("materials/DFHUD/crosshair2.vtf");
resource.AddFile("materials/DFHUD/airspeed_meter2.vmt")
resource.AddFile("materials/DFHUD/airspeed_meter2.vtf")
resource.AddFile("materials/DFHUD/alt_meter2.vtf")
resource.AddFile("materials/DFHUD/alt_meter2.vmt")
resource.AddFile("materials/DFHUD/alt_meter_arrow_small.vtf")	
resource.AddFile("materials/DFHUD/alt_meter_arrow_small.vmt")
resource.AddFile("materials/DFHUD/rocket_outline.vmt")
resource.AddFile("materials/DFHUD/rocket_outline.vtf")
resource.AddFile("materials/DFHUD/rocket_fill.vmt")
resource.AddFile("materials/DFHUD/rocket_fill.vtf")
resource.AddFile("materials/DFHUD/fuel_status.vtf")
resource.AddFile("materials/DFHUD/fuel_status.vmt")
resource.AddFile("materials/DFHUD/fuel_status_ok.vtf")
resource.AddFile("materials/DFHUD/fuel_status_ok.vmt")
resource.AddFile("materials/DFHUD/fuel_status_warning.vtf")
resource.AddFile("materials/DFHUD/fuel_status_warning.vmt")
resource.AddFile("materials/DFHUD/fuel_status_waiting.vtf")
resource.AddFile("materials/DFHUD/fuel_status_waiting.vmt")

resource.AddFile("materials/DFHUD/rocket_arrow_blue.vmt")
resource.AddFile("materials/DFHUD/rocket_arrow_red.vmt")
resource.AddFile("materials/DFHUD/rocket_arrow.vtf")

resource.AddFile("materials/DFHUD/powerup_booster.vtf")
resource.AddFile("materials/DFHUD/powerup_booster.vmt")
resource.AddFile("materials/DFHUD/powerup_stealth.vtf")
resource.AddFile("materials/DFHUD/powerup_stealth.vmt")
resource.AddFile("materials/DFHUD/powerup_missile_home.vtf")
resource.AddFile("materials/DFHUD/powerup_missile_home.vmt")
resource.AddFile("materials/DFHUD/powerup_missile_heat.vtf")
resource.AddFile("materials/DFHUD/powerup_missile_heat.vmt")
resource.AddFile("materials/DFHUD/powerup_nanites.vtf")
resource.AddFile("materials/DFHUD/powerup_nanites.vmt")
resource.AddFile("materials/DFHUD/powerup_flares.vtf")
resource.AddFile("materials/DFHUD/powerup_flares.vmt")
resource.AddFile("materials/DFHUD/powerup_mines.vtf")
resource.AddFile("materials/DFHUD/powerup_mines.vmt")
resource.AddFile("materials/DFHUD/powerup_swarm.vtf")
resource.AddFile("materials/DFHUD/powerup_swarm.vmt")
resource.AddFile("materials/DFHUD/powerup_harpoon.vtf")
resource.AddFile("materials/DFHUD/powerup_harpoon.vmt")

resource.AddFile("materials/nature/blend_dirtgrass_df.vmt")

resource.AddFile("materials/models/props_dogfight/white_fuel.vmt")
resource.AddFile("materials/models/props_dogfight/white_fuel.vtf")

resource.AddFile("materials/modulus/particles/fire1.vmt")
resource.AddFile("materials/modulus/particles/fire1.vtf")
resource.AddFile("materials/modulus/particles/fire2.vmt")
resource.AddFile("materials/modulus/particles/fire2.vtf")
resource.AddFile("materials/modulus/particles/smoke1.vmt")
resource.AddFile("materials/modulus/particles/smoke1.vtf")
resource.AddFile("materials/modulus/particles/smoke2.vmt")
resource.AddFile("materials/modulus/particles/smoke2.vtf")

resource.AddFile("materials/models/airboat/dock01a.vmt")
//resource.AddFile("materials/models/airboat/dock01a.vtf")
resource.AddFile("materials/models/airboat/metalwall001a.vmt")
resource.AddFile("materials/models/airboat/Wood_PalletCrate001a.vmt")

DF_FIRST_BLOOD = true // Set the flag for first blood

--TEMP---------------------------------------
local gmode = GM or GAMEMODE
local team_based = gmode.TEAM_BASED
local spawn_time = gmode.SPAWN_TIME
local crash_fine = gmode.CRASH_FINE

gmode.SpawnPoints = {}
gmode.SpawnPoints.Fallbacks = { -- Incase we couldn't get custom map spawns.
	[1]={
		["type"]="df_spawn_ffa",
		["vec"]=Vector(-108, -100, 2000),
		["ang"]=Angle(0,0,0)
	},
	[2]={
		["type"]="df_spawn_gbu",
		["vec"]=Vector(0, 0, 2000),
		["ang"]=Angle(0,0,0)
	},
	[3]={
		["type"]="df_spawn_idc",
		["vec"]=Vector(100, 100, 2000),
		["ang"]=Angle(0,0,0)
	}
}
--END TEMP-----------------------------------


function FillWithBots(ply,cmd,args)
	if IsValid(ply) and !ply:IsAdmin() then return false end
	if !args[1] then args[1] = 4 end
	local num = tonumber(args[1])
	for i=1, num do
		RunConsoleCommand("bot")
	end
end

concommand.Add("df_bot_add", FillWithBots)

function SetBotName(ply)
	if !ply:IsBot() then return end
	while ply.botnick == nil do
		ply.botnick = table.Random(DF_BOT_NAMES)
		for k,v in pairs(player.GetBots( )) do
			if v != ply then
				if v.botnick == ply.botnick then ply.botnick = nil end
			end
		end
	end
	ply:SetNWString("botnick", ply.botnick)
end

hook.Add("PlayerInitialSpawn", "BotNameInitial", SetBotName)

function GiveWeap(ply,cmd,args)
	if !ply:IsAdmin() then return false end
	if !args[1] then return end
	ply:GiveWeapon(args[1])
end

concommand.Add("df_give", GiveWeap)

function GM:PlayerSpawn( pl ) 

	pl:UpdateNameColor()

	// The player never spawns straight into the game in Fretta
	// They spawn as a spectator first (during the splash screen and team picking screens)
	if ( pl.m_bFirstSpawn ) then
	
		pl.m_bFirstSpawn = nil
		
		if ( pl:IsBot() ) then
		
			GAMEMODE:AutoTeam( pl )
			
			// The bot doesn't send back the 'seen splash' command, so fake it.
			if ( !GAMEMODE.TeamBased && !GAMEMODE.NoAutomaticSpawning ) then
				pl:Spawn()
			end
	
		else
		
			pl:StripWeapons()
			GAMEMODE:PlayerSpawnAsSpectator( pl )
			
			pl:SetPos(gmode.SpawnPoints.Fallbacks[2]["vec"])
			
		end
	
		return
		
	end
		
	pl:CheckPlayerClassOnSpawn()
		
	if ( GAMEMODE.TeamBased && ( pl:Team() == TEAM_SPECTATOR || pl:Team() == TEAM_UNASSIGNED ) ) then

		GAMEMODE:PlayerSpawnAsSpectator( pl )
		return
	
	end
	
	// Stop observer mode
	//pl:UnSpectate() //DF: Breaking stuff.

	// Call item loadout function
	hook.Call( "PlayerLoadout", GAMEMODE, pl )
	
	// Set player model
	hook.Call( "PlayerSetModel", GAMEMODE, pl )
	
	// Call class function
	pl:OnSpawn()
	
end

function GM:Initialize()
	self.BaseClass:Initialize()
	RunConsoleCommand("bot_mimic", 0)
end

function GM:InitPostEntity()
	if game.GetMap() == "dfa_mountains" then
		local tree_spawner = ents.Create("df_trees")
		tree_spawner:SetPos(Vector(-9931.0928, -9990.5293, -749.6655))
		tree_spawner:Spawn()
	end
end

function GM:PlayerSelectSpawn(ply)
	if !self.TeamBased then
		local spawns = ents.FindByClass( "df_plane_spawn" ) //obselete
		return spawns[math.random(1,#spawns)]
	else
		if ply:Team() == TEAM_RED then
			return self:GetRocket(TEAM_RED)
		end
		if ply:Team() == TEAM_BLUE then
			return self:GetRocket(TEAM_BLUE)
		end
	end
end

function GM:GetCenter() //Get Center position (defined by mapper)
	local center = gmode.SpawnPoints.Fallbacks[2]["vec"]
	if !IsValid(center) then return Vector(0,0,0) end
	return center
end

function GM:Think()
	self.BaseClass:Think()
	if self.TeamBased then
		if TEAM_BLUE_WAVE < CurTime() then
			TEAM_BLUE_WAVE = CurTime() + self.RespawnWaveTime
		end
		if TEAM_RED_WAVE < CurTime() then
			TEAM_RED_WAVE = CurTime() + self.RespawnWaveTime
		end
	end
end

function GM:DoPlayerDeath( ply, attacker, dmginfo ) //I know I shouldnt be doing this but fretta doesnt like the way kills are registered
	attacker = ply.Killer or attacker //attacker is always wrong
	self.BaseClass:DoPlayerDeath(ply, attacker, dmginfo)
end

function GM:PlayerDeath( Victim, Inflictor, Attacker )
	Attacker = Victim.Killer or Attacker
	if Victim:Team() != Attacker:Team() then
		if DF_FIRST_BLOOD then
			Attacker:ScoringEvent("firstblood")
			DF_FIRST_BLOOD = false
		end
		Attacker:ScoringEvent("kill", Victim:Nick())
		if Attacker.lb then
			Attacker.lb_kills = Attacker.lb_kills + 1
		end
	end
	if Victim.lb then
		Victim.lb_deaths = Victim.lb_deaths + 1
	end
	Victim:SetRespawnTime(TEAM_RED_WAVE + self.RespawnWaveTime - CurTime())
	self.BaseClass:PlayerDeath(Victim, Inflictor, Attacker)
end

function GM:PlayerDeathThink( pl )

	pl.DeathTime = pl.DeathTime or CurTime()
	local timeDead = CurTime() - pl.DeathTime
	
	// If we're in deathcam mode, promote to a generic spectator mode
	if ( GAMEMODE.DeathLingerTime > 0 && timeDead > GAMEMODE.DeathLingerTime) and !pl:IsObserver() then
		GAMEMODE:BecomeObserver( pl )
	end
	
	// If we're in a round based game, player NEVER spawns in death think
	if ( GAMEMODE.NoAutomaticSpawning ) then return end
	
	// The gamemode is holding the player from respawning.
	// Probably because they have to choose a class..
	if ( !pl:CanRespawn() ) then return end

	// Don't respawn yet - wait for minimum time...
	if self.TeamBased then
		local RespawnTime = 0
		if pl:Team() == TEAM_RED then
			RespawnTime = TEAM_RED_WAVE + self.RespawnWaveTime
		else
			RespawnTime = TEAM_BLUE_WAVE + self.RespawnWaveTime
		end
		pl:SetNWFloat( "RespawnTime", pl.DeathTime + pl:GetRespawnTime() )
		
		if ( timeDead < pl:GetRespawnTime() ) then
			return
		end
	else
		if ( GAMEMODE.MinimumDeathLength ) then 
		
			pl:SetNWFloat( "RespawnTime", pl.DeathTime + pl:GetRespawnTime() )
			
			if ( timeDead < pl:GetRespawnTime() ) then
				return
			end
		end
		// Force respawn
		if ( pl:GetRespawnTime() != 0 && GAMEMODE.MaximumDeathLength != 0 && timeDead > GAMEMODE.MaximumDeathLength ) then
			pl:Spawn()
			return
		end
	end

	pl:Spawn()
end

