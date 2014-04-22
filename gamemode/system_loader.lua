-- loading system by bboudreaux00, thanks <3

GM.Systems = {};

local SystemTemplate = nil;

function GM.SendSystemTemplate( template )
	MsgN("BLEH");
	if SystemTemplate == nil and template ~= nil then
		SystemTemplate = template;
		GM.SendSystemTemplate( template );
	else
		MsgN("System template loaded.");
	end
end

function GM.LoadSystemBase()
	include(GM.DIR .. "basic_system/system.lua");
	if SERVER then
		AddCSLuaFile( GM.DIR .. "basic_system/system.lua" );
	end
end

local SystemDirs = {};

--Function for detecting directories..
--This will load all the system directories into the loader.
function GM.FindDirectories()
	local _, dir = file.Find(GM.DIR .. "*", "LUA");
	SystemDirs = dir;
	PrintTable(SystemDirs);
end

--Function for loading init file inside of listed directories.
function GM.LoadSystemInits()
	if SystemDirs == nil then
		MsgN("System directories are empty!");
		return;
	else
		for _,v in pairs(SystemDirs) do
			if v ~= "basic_system" then
				include(GM.DIR .. v .. "/shared.lua");
				if SERVER then
					AddCSLuaFile(GM.DIR .. v .. "/shared.lua");
				end
			end
		end
	end
end

function GM.RequestSystemTemplate()
	return SystemTemplate;
end

GM.LoadSystemBase();
GM.FindDirectories();
GM.LoadSystemInits();