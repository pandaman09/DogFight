local system = {}

system.FNAME = "concmd"
system.NAME = "Console Comands"
system.DIR = GM.DIR .. "concmd/"
system.svLoadFunction = function() 
	MsgN("Server ["..system.NAME.."]: ")
	--Server
	for _,v in pairs(file.Find(system.DIR .. "server/*.lua", "LUA")) do
		MsgN("	-Including to server - " .. v)
		include(system.DIR .. "server/" .. v)
	end
	
end
system.clLoadFunction = function() 
	--not used
end
system.UnloadFunction = function() MsgN("Unload function for this system has not been over-rided. Doing nothing...") end

GM.SendSystems(system)