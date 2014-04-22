--This file will act as the basics for system stuctures.

local system = {};

system.FNAME = "basic_system";
system.NAME = "Basic System";
system.DIR = GM.DIR .. "basic_system/";
system.svLoadFunction = function() 
	MsgN("Server ["..system.NAME.."]: ");

	--Client
	for _,v in pairs(file.Find(system.DIR .. "cl/*.lua", "LUA")) do
		MsgN("	-Pushing to client - " .. v);
		AddCSLuaFile(system.DIR .. "cl/" ..v);
	end
	--Server
	for _,v in pairs(file.Find(system.DIR .. "sv/*.lua", "LUA")) do
		MsgN("	-Including to server - " .. v);
		include(system.DIR .. "sv/" .. v);
	end
	--Shared
	for _,v in pairs(file.Find(system.DIR .. "sh/*.lua", "LUA")) do
		MsgN("	-Including to server and pushing to client - " .. v);
		include(system.DIR .. "sh/" .. v);
		AddCSLuaFile(system.DIR .. "sh/" .. v);
	end
end
system.clLoadFunction = function() 
	MsgN("Client ["..system.NAME.."]: ");

	--Client
	for _,v in pairs(file.Find(system.DIR .. "cl/*.lua", "LUA")) do
		MsgN("	-Including to client - " .. v);
		include(system.DIR .. "cl/" ..v);
	end
	--Shared
	for _,v in pairs(file.Find(system.DIR .. "sh/*.lua", "LUA")) do
		MsgN("	-Including to client - " .. v);
		include(system.DIR .. "sh/" .. v);
	end
end
system.UnloadFunction = function() MsgN("Unload function for this system has not been over-rided. Doing nothing..."); end


GM.SendSystemTemplate(system);