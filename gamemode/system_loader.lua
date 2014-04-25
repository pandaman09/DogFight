-- loading system by bboudreaux00, thanks <3

GM.Systems = {}

local SystemsLoaded = {}

function GM.SendSystems( template )
	if template then
		table.insert(SystemsLoaded, template)
		template.svLoadFunction()
		template.clLoadFunction()
		MsgN("System ["..template.NAME.."] load complete.")
	else
		MsgN("No System to load")
	end
end

local SystemDirs = {}

--Function for detecting directories..
--This will load all the system directories into the loader.
function GM.FindDirectories()
	local _, dir = file.Find(GM.DIR .. "*", "LUA")
	SystemDirs = dir
	PrintTable(SystemDirs)
end

--Function for loading init file inside of listed directories.
function GM.LoadSystemInits()
	if SystemDirs == nil then
		MsgN("System directories are empty!")
		return
	else
		for _,v in pairs(SystemDirs) do
			include(GM.DIR .. v .. "/shared.lua")
			if SERVER then
				AddCSLuaFile(GM.DIR .. v .. "/shared.lua")
			end
		end
	end
end

function GM.RequestSystemsLoaded()
	return SystemsLoaded
end

GM.LoadSystemBase()
GM.FindDirectories()
GM.LoadSystemInits()

