--This file will act as the basics for system stuctures.

local system = {}

system.FNAME = "core_system"
system.NAME = "Core System"
system.DIR = GM.DIR .. "core_system/"
system.svLoadFunction = function() 
	MsgN("Server ["..system.NAME.."]: ")

	--Client
	for _,v in pairs(file.Find(system.DIR .. "client/*.lua", "LUA")) do
		MsgN("	-Pushing to client - " .. v)
		AddCSLuaFile(system.DIR .. "client/" ..v)
	end
	--Server
	for _,v in pairs(file.Find(system.DIR .. "server/*.lua", "LUA")) do
		MsgN("	-Including to server - " .. v)
		include(system.DIR .. "server/" .. v)
	end
	--Shared
	for _,v in pairs(file.Find(system.DIR .. "shared/*.lua", "LUA")) do
		MsgN("	-Including to server and pushing to client - " .. v)
		include(system.DIR .. "shared/" .. v)
		AddCSLuaFile(system.DIR .. "shared/" .. v)
	end
end
system.clLoadFunction = function() 
	MsgN("Client ["..system.NAME.."]: ")

	--Client
	for _,v in pairs(file.Find(system.DIR .. "client/*.lua", "LUA")) do
		MsgN("	-Including to client - " .. v)
		include(system.DIR .. "client/" ..v)
	end
	--Shared
	for _,v in pairs(file.Find(system.DIR .. "shared/*.lua", "LUA")) do
		MsgN("	-Including to client - " .. v)
		include(system.DIR .. "shared/" .. v)
	end
end
system.UnloadFunction = function() MsgN("Unload function for this system has not been overridden. Doing nothing...") end


GM.SendSystems(system)