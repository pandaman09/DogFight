local system = {}

system.FNAME = "database"
system.NAME = "Database"
system.DIR = GM.DIR .. "database/"
system.svLoadFunction = function() 
	MsgN("Server ["..system.NAME.."]: ")
	--Server
	local useother = (!GM.USEMYSQL and (GM.OTHERDATABASE!=nil or GM.OTHERDATABASE!=""))
	if GM.USEMYSQL==true and useother==false then
		MsgN("	-Including to server - Provider: MySQL")
		include(system.DIR .. "server/mysql.lua")
	elseif GM.USEMYSQL==false and useother==true then
		MsgN("	-Including to server - Provider: "..GM.OTHERDATABASE..".lua")
		if file.Exists(system.DIR .. "server/"..GM.OTHERDATABASE..".lua", "LUA") then
			include(system.DIR .. "server/"..GM.OTHERDATABASE..".lua")
		else
			MsgN("The specificed database file ["..GM.OTHERDATABASE..".lua] does not exist! Using fallback")
			GM.USEMYSQL = false
			GM.OTHERDATABASE = ""
		end
	elseif GM.USEMYSQL==false and useother==false then
		MsgN("	-Including to server - Provider: SQLite")
		include(system.DIR .. "server/sqlite.lua")
	end
	MsgN("	-Including to server - database_core.lua")
	include("server/database_core.lua")
end
system.clLoadFunction = function() 
	-- nothing to load client sided
end
system.UnloadFunction = function() MsgN("Unload function for this system has not been over-rided. Doing nothing...") end

GM.SendSystems(system)