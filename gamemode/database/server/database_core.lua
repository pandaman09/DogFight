if not (DbQuery) then
	error("No query function, something went wrong loading a provider! Exiting the database check!\nCheck settings.lua and gamemode/database/server/ for proper configuration.", 0)
end

--[[--------------------------------------------------------------------------------------------------
	Data Management
]]

local FLS = {}
FLS["u"] = "User"
FLS["g"] = "Gold Member"
FLS["p"] = "Platinum"
FLS["t"] = "Temp. Admin"
FLS["a"] = "Admin"
FLS["s"] = "Superadmin"

--[[
	Func: TranslateFlags
	Desc: Formats the players flags.
	Args: player Player
]]
local function TranslateFlags( ply )
	if not ply.Flags then return end
	local t = string.ToTable(string.lower(ply.Flags))
	
	local FormattedGroups = {}
	for k,v in pairs(t) do
		table.insert(FormattedGroups, FLS[v])
	end		
	
	return string.Implode(" ", FormattedGroups) or "User"
end

--[[
	Func: CreateNewUser
	Desc: Create a new user profile and dogfight profile.
	Args: player Player
]]
function CreateNewUser(ply)
	if( not IsValid(ply) ) then return end
	
	local UserQuery = Format( "INSERT INTO `clients` VALUES( '%s', '%s', 0, 'U', 0 );", EscapeString(ply:Nick()), ply:SteamID(), ply:SteamID() )
	local DogFightQuery = Format( "INSERT INTO `dogfight` VALUES( '%s', 0, 0, 0, '[]', 0, 0 );", ply:SteamID() )

	DbQuery( UserQuery, function(data) end)
	DbQuery( DogFightQuery, function(data) end)

	return { [1] = { groups = "U", timeplayed = 0 } }
end

--[[
	Func: LoadProfiles
	Desc: Load the players profile and set them to online.
	Args: player Player
	Note: Merged with 
]]
function LoadProfiles(ply)
	if not IsValid(ply) then return end
	
	ply.Allow = false
	ply.DataWasLoaded = false 			-- Make sure game data was loaded
	ply.ProfileWasLoaded = false		-- Make sure profile data was loaded (Flags)

	local steamid = ply:SteamID()

	--
	-- Load User profile
	--
	DbQuery( "SELECT * FROM clients WHERE steamid = '" .. steamid .. "'", function( PlyProfileData ) 
		if( not PlyProfileData or PlyProfileData[1] == nil ) then
			PlyProfileData = CreateNewUser( ply )
		end	

		ply.timeplayed = PlyProfileData[1].timeplayed or 0
		ply.Flags = PlyProfileData[1].groups or "U"

		-- Send the flags to the player.		
		net.Start("sendflags")
			net.WriteString(ply.Flags)
		net.Send(ply)

		ply.ProfileWasLoaded = true
		ply.Allow = true
		
		ply:ChatPrint( "User profile was loaded and set to the groups " .. TranslateFlags(ply) )

		--
		--	Load Game stats. Nested to stop it from running before the first query completes.
		--
		DbQuery( "SELECT * FROM dogfight WHERE steamid = '" .. steamid .. "'", function( PlyData ) 	
			if( PlyData == nil or not PlyData[1] ) then return end

			ply.tot_crash = tonumber(PlyData[1].tc)
			ply.tot_targ_damage = tonumber(PlyData[1].ttd)

			local money  = PlyData[1].money
			local kills  = PlyData[1].kills
			local deaths = PlyData[1].deaths

			ply:SetNWInt("kills", kills )
			ply:SetNWInt("deaths", deaths )
			ply:SetNWInt("money", money )	

			ply.UNLOCKS = util.JSONToTable( PlyData[1].unlocks or { } )
			ply.Allow = true
			ply.DataWasLoaded = true
			ply:SendStats(ply)
			
			-- Tell the game we're reading to play. Stop the spamming of LoadProfiles()
			hook.Call( "MYSQL.PlayerLoaded", nil, ply )
			ply:ChatPrint( "DogFight game data loaded." .. TranslateFlags(ply) )
		end)
	end)

	-- Set User Online
	timer.Simple( 5, function()
		DbQuery("UPDATE clients SET server = 27025 WHERE steamid = '" .. steamid .. "' ")
	end)
end
hook.Add("PlayerInitialSpawn", "PlayerLoading", LoadProfiles )

--[[
	Func: SaveProfile
	Desc: Save the players profile and unlocks.
	Args: player Player
]]
function SaveProfile(ply)
	if not ply:IsValid() then return end

	local name = EscapeString( ply:Nick() )
	local steamid = ply:SteamID()

	if( not ply.Allow ) then
		ply:ChatPrint( "Your profile was never loaded, something went wrong!" )
		return false
	end

	-- Save user data
	-- Make sure we're not overriding valid data because we failed to load it the first time. :<
	if( ply.ProfileWasLoaded == true ) then
		MsgN( "Saving player data" )
		local timeplayed = tonumber(ply.timeplayed + ply:TimeConnected( ))
		
		MsgN( "Timeconnected:", timeplayed )
	
		local Query = Format( "UPDATE clients SET name = %q, groups = %q, timeplayed = %i WHERE steamid = %q ", name, ply.Flags, math.Round(timeplayed) , steamid )
		DbQuery( Query, function(callback) end)
	end

	-- Save game data
	-- Make sure we're not overriding valid data because we failed to load it the first time. :<
	if( ply.DataWasLoaded == true ) then
		local money = ply:GetNWInt("money")
		local kills = ply:GetNWInt("kills")
		local deaths = ply:GetNWInt("deaths")
		local crashes = ply.tot_crash
		local destoryed = ply.tot_targ_damage
		local unlocks = EscapeString( util.TableToJSON(ply.UNLOCKS) or "[]" )

		local Query = Format( "UPDATE dogfight SET money = %i, kills = %i, deaths = %i, tc = %i,  ttd = %i, unlocks = %q WHERE steamid = %q", money, kills, deaths, crashes, destoryed, unlocks, steamid ) 
		DbQuery( Query, function(callback) end)
	end
end
hook.Add("PlayerDisconnected", "PlayerOffline", SaveProfile)

--[[
	Func: SetOffline
	Desc: Set a user *offline*
	Args: player ply
]]
local function SetOffline( ply )
	if( not IsValid( ply ) ) then return end
	DbQuery( "UPDATE clients SET server = '0' WHERE steamid = '" .. ply:SteamID() .. "'", function(callback) end)
end
hook.Add("PlayerDisconnected", "PlayerOffline", SetOffline)

-- Save everyone on shutdown
local function SaveAllProfiles()
	for _, ply in pairs( player.GetAll() ) do
		SaveProfile(ply)
	end
end
hook.Add( "ShutDown", "ShuttingDown", SaveAllProfiles )
timer.Create( "MYSQLSaveAllProfiles", PLY_SAVE_DELAY, 0, function() SaveAllProfiles() end)

--[[
	Func: SetAllOffline
	Desc: Set everyone offline
	Args:
]]
local function SetAllOffline()
	DbQuery("UPDATE clients SET server = 0 WHERE server = 27025 ")
end
hook.Add( "ShutDown", "ShuttingDown", SetAllOffline )
hook.Add( "Initialize", "StartingUp", function() timer.Simple( 1, SetAllOffline ) end)

function GetSpawns(callback)
	local map = EscapeString(game.GetMap())
	local query = "SELECT * FROM mapspawns WHERE map = '" .. map .. "'"
	if callback then
		DbQuery( query, callback)
	else
		DbQuery( query )
	end
end

function UpdateSpawns(server_id, team, pos, ang, delete, callback)
	local minus = 0
	local query = ""
	local safe_pos = ""..pos.x.."_"..pos.y.."_"..pos.z..""
	local safe_ang = ""..ang.p.."_"..ang.y.."_"..ang.r..""
	local map = game.GetMap()
	if delete then
		query = "DELETE FROM mapspawns WHERE ctime = "..time.." AND map = '"..map.."'"
	else
		query = "INSERT INTO mapspawns (server_id, map, team_id, position, angle) VALUES ("..server_id..",'"..map.."',"..team..",'"..safe_pos.."','"..safe_ang.."') ON DUPLICATE KEY UPDATE team_id = "..team..", map = '"..map.."', position = '"..safe_pos.."', angle = '"..safe_ang.."'"
	end
	if callback then
		DbQuery( query, callback )
	else
		DbQuery( query )
	end
end

function GetMaxSID(callback)
	local query = "SELECT MAX(server_id) FROM mapspawns;"
	if !callback then MsgN("No callback - gamemode/mysql.lua:367") debug.Trace() end
	DbQuery( query, function(data)
		local max = data[1]["MAX(server_id)"]
		if !isnumber(max) then max = 0 end
		callback(max)
	end)
end
