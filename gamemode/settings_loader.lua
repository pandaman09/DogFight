-- These are the default settings for the game mode

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
};

