--[[ 
	Don't try and create MySql objects if we're not using them!
]]
require( "mysqloo" )

local gmode = GM or GAMEMODE
local sqlinfo = gmode.MYSQL
local db = mysqloo.connect( sqlinfo["host"], sqlinfo["username"], sqlinfo["password"] , sqlinfo["database"], sqlinfo["port"])

local function gotoFallback(query, callback, error)
	if gmode.USEMYSQL == false then return end
	-- warn the user that mysql is failing
	MsgN("Server [Database]: MySQL has failed, reverting to sqlite.")
	if error then
		MsgN("Server [Database]: MySQL error: "..error)
	end

    gmode.USEMYSQL = false
	--reload database system to fallback to sql
	MsgN("Server [Database]: Switching to SQLite Provider")
	MsgN("	-Including to server - Provider: SQLite")
	include(gmode.DIR .. "database/" .. "server/sqlite.lua")
	if query != "" then
		timer.Simple(0, function() DbQuery(query, callback) end) --recall the query!
	end
end

if( mysqloo ) then

	function db:onConnectionFailed( errorMessage )
		gotoFallback( "", nil, errorMessage )
	end

	function db:onConnected( )
		MsgN( "Database Connected!" )
	end
	db:connect()
else
	gotoFallback()
end

--[[
	Func: DbQuery
	Desc: Allows queries with callbacks.
	Args: string query, function callback
]]
function DbQuery( query, callback )

	local q = db:query( query )

 	if( not q ) then
		gotoFallback(query,callback)
		return
	end

	function q:onSuccess( data )
		if callback then
			callback(data)
		end
	end
	
	function q:onError( error, sql)
		if db:status()==mysqloo.DATABASE_NOT_CONNECTED then
			MsgN("Database is not connected\n")
		end
		MsgN("SQL error: " .. tostring(error) .. "\n")
		MsgN("SQL of: "..tostring(sql).."\n")
	end

	q:start()
end

--[[
	Func EscapeString
	Desc: Decides what escape function we're using.
	Args: string String
]]

function EscapeString( String )
	return db:escape( String )
end

-- Check if mysqloo was loaded, not sure if there is a better way to do this.
