--require("datastream")

LeaderBoard = {}

//TABLE LAYOUT: STEAMID : NAME : SCORE : KILLS : DEATHS : KD : CAPTURES : TIME PLAYED

function LeaderBoard.CheckTables()
    if sql.TableExists("df_leaderboard") then
		print("[DF LEADERBOARDS] TABLE EXISTS")
    else
		local query = "CREATE TABLE df_leaderboard ( steamid varchar(255), name varchar(100), score int, kills int, deaths int, kd decimal(4,2), captures int, time int )"
		local result = sql.Query(query)
		if (sql.TableExists("player_info")) then
			print("[DF LEADERBOARDS] PLAYER TABLE CREATED")
		else
			print("[DF LEADERBOARDS] ERROR CREATING LEADERBOARDS")
			print(sql.LastError( result ))
		end
    end
end

hook.Add("Initialize", "LeaderBoard Init", LeaderBoard.CheckTables)

function ResetLeaders(ply,cmd,args)
	if !ply:IsSuperAdmin() and args[1] != "password" then return end --Just to stop someone accidently doing it 0r something.
	sql.Query("DROP TABLE df_leaderboard") //farewell 
	local query = "CREATE TABLE df_leaderboard ( steamid varchar(255), name varchar(100), score int, kills int, deaths int, kd decimal(4,2), captures int, time int )"
	local result = sql.Query(query)
	if (sql.TableExists("player_info")) then
		print("[DF LEADERBOARDS] PLAYER TABLE CREATED")
	else
		print("[DF LEADERBOARDS] ERROR CREATING LEADERBOARDS")
		print(sql.LastError( result ))
	end
end

concommand.Add("df_reset_db", ResetLeaders)

local LeaderArgs = {}
LeaderArgs["score"] = "DESC"
LeaderArgs["kills"] = "DESC"
LeaderArgs["kd"] = "DESC"
LeaderArgs["captures"] = "DESC"

function LeaderBoard.GetTopPlayers(ply,cmd,args)
	if !args[1] then print("missing column arg") return end
	local order = LeaderArgs[args[1]]
	if !order then return end
	local res = sql.Query("SELECT * FROM df_leaderboard WHERE kills > "..GAMEMODE.KillsForRank.." ORDER BY "..args[1].." "..order.." LIMIT 50")
	if res then
		datastream.StreamToClients( ply, "LeaderSend_"..args[1],res )
	else
		print(sql.LastError( res ))
	end
end

concommand.Add("df_leaderboard_fetch", LeaderBoard.GetTopPlayers)

//TABLE LAYOUT: STEAMID : NAME : SCORE : KILLS : DEATHS : KD : CAPTURES : TIME PLAYED
function LeaderBoard.LoadStuff(ply, res)
	print("[DF LEADERBOARDS] FOUND RECORD FOR PLAYER "..ply:Nick())
	local kills = res[1]["kills"]
	local deaths = res[1]["deaths"]
	local kd = res[1]["kd"]
	local caps = res[1]["captures"]
	local score = res[1]["score"]
	local time_played = res[1]["time"]
	//PrintTable(res[1])
	ply.lb_kills = tonumber(kills)
	ply.lb_deaths = tonumber(deaths)
	ply.lb_kd = tonumber(kd)
	ply.lb_captures = tonumber(caps)
	ply.lb_score = tonumber(score)
	ply.lb_time = tonumber(time_played)
	ply.lb = true
end

//TABLE LAYOUT: STEAMID : NAME : SCORE : KILLS : DEATHS : KD : CAPTURES : TIME PLAYED
function LeaderBoard.SaveRecord(ply)
	if ply:IsBot() or !IsValid(ply) then return end
	local steamid = ply:SteamID()
	local name = SQLStr(ply:Nick())
	local kills = ply.lb_kills
	local score = ply.lb_score
	local deaths = ply.lb_deaths
	local kd = 0
	if deaths > 0 then
		kd = kills / deaths --Divided by Zero protect
	end
	local caps = ply.lb_captures
	local time_played = ply.lb_time
	sql.Query("UPDATE df_leaderboard SET name = '"..name.."', score = "..score..", kills = "..kills..", deaths = "..deaths..", kd = "..kd..", captures = "..caps..", time = "..time_played.." WHERE steamid ='" ..steamid.."'")
	print("[DF LEADERBOARDS] UPDATED PLAYER RECORD FOR "..ply:Nick())
end

local save_delay = 300
LeaderBoard.LastAllSave = save_delay

function LeaderBoard.Think()
	sql.Begin()
	if LeaderBoard.LastAllSave + save_delay < CurTime() then
		for k,v in pairs(player.GetHumans()) do
			if v.lb then
				v.lb_time = v.lb_time + (save_delay / 60)
				LeaderBoard.SaveRecord(v)
			end
		end
		LeaderBoard.LastAllSave = CurTime()
	end
	sql.Commit()
end

hook.Add("Think", "LeaderBoard Think", LeaderBoard.Think)

function LeaderBoard.PlayerLeft(ply)
	if not ply:IsValid() then return end
	LeaderBoard.SaveRecord(ply)
end

hook.Add("PlayerDisconnected", "PlayerGone", LeaderBoard.PlayerLeft)

//TABLE LAYOUT: STEAMID : NAME : SCORE : KILLS : DEATHS : KD : CAPTURES : TIME PLAYED
function LeaderBoard.InitialSpawn(ply)
	if ply:IsBot() then return end //No loving for the bots
	if !IsValid(ply) then return end
	timer.Simple(1, function()
						local steamid = ply:SteamID()
						local res = sql.Query("SELECT steamid, name, score, kills, deaths, kd, captures, time FROM df_leaderboard WHERE steamid ='" ..steamid.."'")
						if res then
							LeaderBoard.LoadStuff(ply,res)
						else
							local res = sql.Query("INSERT INTO df_leaderboard (steamid,name,score,kills,deaths,kd,captures,time) VALUES('"..steamid.."', '"..sql.SQLStr(ply:Nick()).."',0,0,0,0,0,0)")
							ply.lb_kills = 0
							ply.lb_deaths = 0
							ply.lb_score = 0
							ply.lb_captures = 0
							ply.lb_kd = 0
							ply.lb_time = 0
							ply.lb = true
						end
					end)
end

hook.Add("PlayerInitialSpawn", "LeaderBoard InitSpawn", LeaderBoard.InitialSpawn)
