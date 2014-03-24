DATABASE_IS_MYSQL = true

local SQLITE_TABLE_CREATE_QUERY = [[
	CREATE TABLE IF NOT EXISTS clients (
		name varchar(50),
		steamid varchar(25) primary key,
		server varchar(5),
		groups varchar(6),
		timeplayed int(100)
	);

	CREATE TABLE IF NOT EXISTS dogfight (
		steamid varchar(25) primary key,
		kills int(10),
		deaths int(10),
		money int(10),	
		unlocks varchar(500),
		tc int(50),
		ttd int(50)
	);
]]

--[[ 
	Don't try and create MySql objects if we're not using them!
]]

require( "mysqloo" )

local db

-- Check if mysqloo was loaded, not sure if there is a better way to do this.
if( mysqloo ) then
	db = mysqloo.connect( "127.0.0.1", "root", "test123" , "faintlink", 3306)

	function db:onConnectionFailed( errorMessage )
		Msg("There was an error connecting to the database!\n")
		Msg(errorMessage .. "\n")
	end

	function db:onConnected( )
		Msg("Database Connected!\n")
	end
	db:connect()
else
	-- Fallback to SQLite
	DATABASE_IS_MYSQL = false
end

--[[
	Func: dbquery
	Desc: Allows queries with callbacks.
	Args: string query, function callback
]]
function dbquery( query, callback )

	-- Simple SQLite management for people without MySQL. 
	if( DATABASE_IS_MYSQL ~= true ) then
		-- Perform the query.
		local ResultSet = sql.Query( query )
		
		-- False means error.
		if( ResultSet == false ) then
			print("SQLite error: " .. tostring(sql.LastError()) .. "\n")
			print("SQL of: "..tostring(query).."\n")
			return
		end

		if callback then
			callback(ResultSet)
			return
		end		

		-- Don't try to run Non SQLite functions.
		return
	end

	local q = db:query( query )
	if( not q ) then
		-- For some reason we were unable to create the query object. Maybe the database is down?
		-- Revert to SQLite
		DATABASE_IS_MYSQL = false
		return
	end

	function q:onSuccess( data )
		if callback then
			callback(data)
		end
	end
	
	function q:onError( error, sql)
		if db:status()==mysqloo.DATABASE_NOT_CONNECTED then
			print("Database is not connected\n")
		end
		print("SQL error: " .. tostring(error) .. "\n")
		print("SQL of: "..tostring(sql).."\n")
	end

	q:start()
end

--[[
	Func EscapeString
	Desc: Decides what escape function we're using.
	Args: string String
]]

local function EscapeString( String )
	if( DATABASE_IS_MYSQL == true ) then
		return db:escape( String )
	end
	return string.Trim( sql.SQLStr( String ), "'" )	
end

--[[
	Make sure SQLLite tables exist.
]]
local function CreateSQLiteTables()
	if( DATABASE_IS_MYSQL ) then return end
	dbquery( SQLITE_TABLE_CREATE_QUERY, function() end )
	
	print( "Does Table 'clients' Exist: ", sql.TableExists( "clients" ) )
	print( "Does Table 'dogfight' Exist: ", sql.TableExists( "dogfight" ) )
end
hook.Add("Initialize", "SQLiteTableCreation", CreateSQLiteTables )
concommand.Add( "SQLite_Check", CreateSQLiteTables ) -- For debugging

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

	dbquery( UserQuery, function(data) end)
	dbquery( DogFightQuery, function(data) end)

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
	dbquery( "SELECT * FROM clients WHERE steamid = '" .. steamid .. "'", function( PlyProfileData ) 
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
		dbquery( "SELECT * FROM dogfight WHERE steamid = '" .. steamid .. "'", function( PlyData ) 	
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
			
			ply:ChatPrint( "DogFight game data loaded." .. TranslateFlags(ply) )
		end)
	end)

	-- Set User Online
	timer.Simple( 5, function()
		dbquery("UPDATE clients SET server = 27025 WHERE steamid = '" .. steamid .. "' ")
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
		print( "Saving player data" )
		local timeplayed = tonumber(ply.timeplayed + ply:TimeConnected( ))
		
		print( "Timeconnected:", timeplayed )
	
		local Query = Format( "UPDATE clients SET name = %q, groups = %q, timeplayed = %i WHERE steamid = %q ", name, ply.Flags, math.Round(timeplayed) , steamid )
		dbquery( Query, function(callback) end)
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
		dbquery( Query, function(callback) end)
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
	dbquery( "UPDATE clients SET server = '0' WHERE steamid = '" .. ply:SteamID() .. "'", function(callback) end)
end
hook.Add("PlayerDisconnected", "PlayerOffline", SetOffline)

-- Save everyone on shutdown
hook.Add( "ShutDown", "ShuttingDown", function()
	for _, ply in pairs( player.GetAll() ) do
		SaveProfile(ply)
	end
end)

--[[
	Func: SetAllOffline
	Desc: Set everyone offline
	Args:
]]
local function SetAllOffline()
	dbquery("UPDATE clients SET server = 0 WHERE server = 27025 ")
end
hook.Add( "ShutDown", "ShuttingDown", SetAllOffline )
hook.Add( "Initialize", "StartingUp", function() 
	-- Stop the query from trying to run when the server hasnt initialized the MySQl object.
	timer.Simple( 1, SetAllOffline ) 
end)
