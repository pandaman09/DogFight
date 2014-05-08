--[[
	List of netmessages along with location and uses
	Infomation:
		util.AddNetworkString( "string" )
		-- send location
		-- retrieve location
		-- variable information
		-- notes
]]

util.AddNetworkString( "up" )
-- entities/plane/init./lua ~281
-- cl_init.lua ~104
-- update hud variables HUD.SPEED_T (int), HUD.AMMO_T (int)
-- 

util.AddNetworkString( "spec" )
-- player_extenstion.lua ~17
-- cl_init.lua ~294
-- updates spectator varables SPEC.ENT (entity)
-- starts client sided spectator

util.AddNetworkString( "stop_spec" )
-- init.lua ~360
-- cl_init.lua ~303
-- no variables
-- stops client sided spectator

util.AddNetworkString( "norm_spec" )
-- player_extenstion.lua ~25
-- cl_init.lua ~314
-- no variables
-- starts client sided spectator on a random plane

util.AddNetworkString( "message" )
-- player_extenstion.lua ~10
-- cl_init.lua ~334
-- updates chat values txt (string)
-- puts a message in the local players chat

util.AddNetworkString( "help" )
-- init.lua ~224
-- cl_init.lua ~340
-- no variables
-- creates df_menu vgui (help menu)

util.AddNetworkString( "update_ammo" )
-- unlocks.lua ~382
-- cl_init.lua ~346
-- updates plane variable PLANE.MAX_AMMO (int)
-- sets maximum ammo variables

util.AddNetworkString( "nextspawn" )
-- player_extenstion.lua ~30
-- cl_init.lua ~352
-- updates local player variable LocalPlayer().NextSpawn (int)
-- don't know if this actually does anything

util.AddNetworkString( "sendflags" )
-- mysql.lua ~212
-- cl_init.lua ~359
-- updates local player variable LocalPlayer().Flags (string)
-- player flags (user/admin/superadmin/etc.)

util.AddNetworkString( "killmsg" )
-- init.lua ~447
-- cl_init.lua ~641
-- updates killmsg variables typ (int), tem (int), txt (string), ico (string)
-- inserts kill infomation into K_MSG (table)

util.AddNetworkString( "monmsg" )
-- player_extenstion.lua ~98
-- cl_init.lua ~676
-- updates monmsg variables txt (string), col (string)
-- inserts money information into M_MSG (table)



util.AddNetworkString( "ul_start" )
-- no sender?
-- cl_panels.lua ~373
-- clears local player variable LocalPlayer().UNLOCKS (table), and updates local file variable num (int)
-- start of unlocks message - why not have one net message?

util.AddNetworkString( "ul_end" )
-- no sender?
-- cl_panels.lua ~382
-- calls HANGAR:Refresh()
-- end of unlock message

util.AddNetworkString( "ul_chunk" )
-- no sender?
-- cl_panels.lua ~392
-- updates unlock message variables t.ID (string), t.EN (int)
-- inserts unlock table into LocalPlayer().UNLOCKS (table)

util.AddNetworkString( "stats" )
-- player_extenstion.lua ~88
-- cl_panels.lua ~399
-- updates local player variables LocalPlayer().tot_crash (int), LocalPlayer().tot_targ_damage (int)
--

util.AddNetworkString( "sendmaps" )
-- commands.lua ~28
-- cl_panels.lua ~604
-- updates map vote variables AM (int), map_s (string)
-- updates maps for mapvote

util.AddNetworkString( "mapvote" )
-- command.lua ~66
-- cl_panels.lua ~614
-- no variables
-- creates df_maps - opens map vote panel

util.AddNetworkString( "team" )
-- no sender?
-- cl_panels.lua ~846
-- no variables
-- checks group flags and creates df_trails if user can have trails

util.AddNetworkString( "send_ul" )
-- player_extension.lua ~37
-- no reciever?
-- 
-- 



util.AddNetworkString( "updatespawn" )
-- entities/spawnpoint_vis/cl_init.lua ~79
-- commands.lua ~335
-- updates spawnpoint variables server_id (int), team (int), pos_tbl (table), ang_tbl (table), delete (bool)
-- calls function UpdateEditorSpawns with the values - used for modifying or deleting spawnpoints - Client to Server

util.AddNetworkString( "spawnpoint_edit_derma" )
-- entities/spawnpoint_vis/init.lua ~38
-- entities/spawnpoint_vis/cl_init.lua ~93
-- updates spawnpoint variables ent (entity)
-- opens spawnpoint edit derma menu - used for modifying or deleting spawnpoints - Client to Server

util.AddNetworkString( "createspawn" )
-- entities/spawnpoint_vis/cl_init.lua ~300
-- commands.lua ~352
-- updates spawnpoint variables team (int), pos_tbl (table), ang_tbl (table)
-- used for creating spawnpoints - Client to Server

util.AddNetworkString( "spawnpoint_create_derma" )
-- commands.lua ~368
-- entities/spawnpoint_vis/cl_init.lua ~209
-- updates spawnpoint no variables
-- opens spawnpoint create derma menu - used for creating spawnpoints - Client to Server