-- New file loading system to keep stuff organised

--Require file
--include( "filename.lua" ); -add for server and client
--AddCSLuaFile( "filename.lua" ); -add for client

-- gamemode info
include( "gamemode.lua" )
AddCSLuaFile( "gamemode.lua" )

--precache net strings
include( "net_precache.lua" )

--gamemode settings
include( "settings.lua" )
AddCSLuaFile( "settings.lua" )

--system loading
include( "system_loader.lua" )
AddCSLuaFile( "system_loader.lua" )