-- These are the default settings for the game mode
if CLIENT then MsgN("NOT FOR CLIENT!!!") return end -- this here just in case someone decides to be stupid

--Gamemode information!
GM.Name = "Dogfight"
GM.Author = "Conman, Scooby, Kila, Pandaman"
GM.Email = ""
GM.Website = "https://github.com/kila58/DogFight"
GM.DIR = "dogfight/gamemode/"
GM.Version = "4-22-2014"

GM.USEMYSQL = true -- use mysql? If false, sqlite will be ran.
GM.OTHERDATABASE = "" --use a differnt database method? For example: tmysql use "tmysql" after adding the tmysql.lua file into gamemode/database/server/
GM.Mysql{
	"host" = "localhost",
	"port" = "3306",
	"username" = "root",
	"password" = "",
	"database" = "faintlink"
}

GM.FLAK_MAX_HEALTH = 500

GM.TEAM_BASED = true
GM.UL_DEBUG = false

GM.ROUND_ID = 0
--GM.MAP_VOTE_ROUND = 5 --not used?

GM.SPAWN_TIME = 5
GM.CRASH_FINE = 3

-- Save all MySQL Data every x seconds
GM.PLY_SAVE_DELAY = 300

GM.P_DONATOR_MONEY = 2
GM.G_DONATOR_MONEY = 1.5 

--GM.P_SPAWN_MULT = 0.5 --not used?
--GM.G_SPAWN_MUL = 0.75 --not used?

--GM.ADS = { "Got a bug? Report it to an admin or visit http://facepunch.com/showthread.php?t=137716",} --not used?
--GM.BOT_NAMES = { "Corporal Smith", "Corporal Abrahams", "Private Anderson", "Lieutenant Hughes", "Private Morgan", "Lieutenant Parker", "Private Weller" } --not used?