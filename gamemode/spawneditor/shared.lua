local system = {}

system.FNAME = "spawneditor"
system.NAME = "Spawn Point Editor"
system.DIR = GM.DIR .. "spawneditor/"
system.svLoadFunction = function() 
	MsgN("Server ["..system.NAME.."]: ")
	--Client
	for _,v in pairs(file.Find(system.DIR .. "client/*.lua", "LUA")) do
		MsgN("	-Pushing to client - " .. v);
		AddCSLuaFile(system.DIR .. "client/" ..v);
	end
	--Server
	for _,v in pairs(file.Find(system.DIR .. "server/*.lua", "LUA")) do
		MsgN("	-Including to server - " .. v);
		include(system.DIR .. "server/" .. v);
	end
	--Shared
	for _,v in pairs(file.Find(system.DIR .. "shared/*.lua", "LUA")) do
		MsgN("	-Including to server and pushing to client - " .. v);
		include(system.DIR .. "shared/" .. v);
		AddCSLuaFile(system.DIR .. "shared/" .. v);
	end
end
system.clLoadFunction = function() 
	MsgN("Client ["..system.NAME.."]: ");
	--Client
	for _,v in pairs(file.Find(system.DIR .. "client/*.lua", "LUA")) do
		MsgN("	-Including to client - " .. v);
		include(system.DIR .. "client/" ..v);
	end
	--Shared
	for _,v in pairs(file.Find(system.DIR .. "shared/*.lua", "LUA")) do
		MsgN("	-Including to client - " .. v);
		include(system.DIR .. "shared/" .. v);
	end
end
system.UnloadFunction = function() MsgN("Unload function for this system has not been over-rided. Doing nothing...") end

GM.SendSystems(system)