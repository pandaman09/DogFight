-- loading system by bboudreaux00, thanks <3

GM.Systems = GM.Systems or {}

local gmode = GM or GAMEMODE
if table.Count(gmode.Systems)>0 then MsgN("no autorun") return end -- avoid auto reload

function GM.SendSystems( template )
	if template then
		table.insert(GM.Systems, template)
		if SERVER then
			template.svLoadFunction()
		elseif CLIENT then
			template.clLoadFunction()
		end
		MsgN("System ["..template.NAME.."] load complete.")
	else
		MsgN("No System to load")
	end
end

function GM.LoadCore()
	include(GM.DIR .. "core_systems/shared.lua");
	if SERVER then
		AddCSLuaFile( GM.DIR .. "core_systems/shared.lua" );
	end
end

local SystemDirs = {}
--Function for detecting directories..
--This will load all the system directories into the loader.
function GM.FindDirectories()
	local _, dir = file.Find(GM.DIR .. "*", "LUA")
	SystemDirs = dir
	--PrintTable(SystemDirs)
end

--Function for loading init file inside of listed directories.
function GM.LoadSystemInits()
	if SystemDirs == nil then
		MsgN("System directories are empty!")
		return
	else
		for _,v in pairs(SystemDirs) do
			if v ~= "core_systems" then
				include(GM.DIR .. v .. "/shared.lua");
				if SERVER then
					AddCSLuaFile(GM.DIR .. v .. "/shared.lua");
				end
			end
		end
	end
end

function GM.RequestSystemsLoaded()
	return GM.Systems
end

GM.LoadCore()
GM.FindDirectories()
GM.LoadSystemInits()