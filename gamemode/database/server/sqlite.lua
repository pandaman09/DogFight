local sqlite_table_create_query = [[
CREATE TABLE IF NOT EXISTS clients (
		name TEXT,
		steamid TEXT PRIMARY KEY,
		server TEXT,
		groups TEXT,
		timeplayed INT
	);

CREATE TABLE IF NOT EXISTS dogfight (
	steamid TEXT PRIMARY KEY,
	kills INT,
	deaths INT,
	money INT,	
	unlocks TEXT,
	tc INT,
	ttd INT
);

CREATE TABLE IF NOT EXISTS mapspawns (
	server_id INTEGER PRIMARY KEY,
	map TEXT,
	team_id INT,
	position TEXT,
	angle TEXT
);
]]

--[[
	Func: DbQuery
	Desc: Allows queries with callbacks.
	Args: string query, function callback
]]
function DbQuery( query, callback )
	-- Perform the query.
	local ResultSet = sql.Query( query )
	
	-- False means error.
	if( ResultSet == false ) then
		MsgN("SQLite error: " .. tostring(sql.LastError()) .. "\n")
		MsgN("SQL of: "..tostring(query).."\n")
		return
	end

	if callback then
		callback(ResultSet)
	end		

end

--[[
	Func EscapeString
	Desc: Decides what escape function we're using.
	Args: string String
]]

function EscapeString( String )
	return string.Trim( sql.SQLStr( String ), "'" )	
end

--[[
	Make sure SQLLite tables exist.
]]
local function createSqliteTables()
	DbQuery( sqlite_table_create_query, function() end )
	
	MsgN( "Does Table 'clients' Exist: ", sql.TableExists( "clients" ) )
	MsgN( "Does Table 'dogfight' Exist: ", sql.TableExists( "dogfight" ) )
	MsgN( "Does Table 'mapspanws' Exist: ", sql.TableExists( "mapspawns" ) )
end
createSqliteTables() -- doing this anyways because mysql may fail at any time.
--hook.Add("Initialize", "SQLiteTableCreation", createSqliteTables )
concommand.Add( "SQLite_Check", createSqliteTables ) -- For debugging