local sqlite_table_create_query = [[
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

	CREATE TABLE IF NOT EXISTS mapspawns (
		server_id int(11) primary key AUTOINCREMENT,
		map varchar(50),
		team_id tinyint(4),
		position varchar(50),
		angle varchar(50)
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
hook.Add("Initialize", "SQLiteTableCreation", createSqliteTables )
concommand.Add( "SQLite_Check", createSqliteTables ) -- For debugging