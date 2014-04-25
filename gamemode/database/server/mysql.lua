--[[ 
	Don't try and create MySql objects if we're not using them!
]]
require( "mysqloo" )

local db

local function gotoFallback(error)
	-- warn the user that mysql is failing
	MsgN("Server [Database]: MySQL has failed, reverting to sqlite.")
	if error then
		MsgN("Server [Database]: MySQL error: "..error)
	end
	GM.USEMYSQL = false
	--reload database system to fallback to sql
	include(GM.DIR .. "database/" .. "server/sqlite.lua")
end

--[[
	Func: DbQuery
	Desc: Allows queries with callbacks.
	Args: string query, function callback
]]
function DbQuery( query, callback )

	local q = db:query( query )

	if( not q ) then
		gotoFallback()
	end

	local function q:onSuccess( data )
		if callback then
			callback(data)
		end
	end
	
	local function q:onError( error, sql)
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
if( mysqloo ) then
	local sqlinfo = GM.Mysql
	db = db or mysqloo.connect( sqlinfo["host"], sqlinfo["username"], sqlinfo["password"] , sqlinfo["database"], sqlinfo["port"])

	function db:onConnectionFailed( errorMessage )
		gotoFallback(errorMessage)
	end

	function db:onConnected( )
		MsgN( "Database Connected!" )
	end
	db:connect()
else
	gotoFallback()
end