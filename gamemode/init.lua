include("mysql.lua")

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "cl_panels.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_scoreboard.lua" )
AddCSLuaFile( "unlocks.lua")

include( "player_extension.lua" )
include( "shared.lua" )
include( "commands.lua" )

GBU_SPAWNS = {}
IDC_SPAWNS = {}

--Usermessages 'hooks' for net--

util.AddNetworkString( "up" ) -- cl_init.lua line ~104
util.AddNetworkString( "spec" ) -- cl_init.lua line ~289
util.AddNetworkString( "stop_spec" ) -- cl_init.lua line ~300
util.AddNetworkString( "norm_spec" ) -- cl_init.lua line ~313
util.AddNetworkString( "message" ) -- cl_init.lua line ~413
util.AddNetworkString( "help" ) -- cl_init.lua line ~421
util.AddNetworkString( "update_ammo" ) -- cl_init.lua line ~430
util.AddNetworkString( "nextspawn" ) -- cl_init.lua line ~438
util.AddNetworkString( "sendflags" ) -- cl_init.lua line ~447
util.AddNetworkString( "killmsg" ) -- cl_init.lua line ~727
util.AddNetworkString( "monmsg" ) -- cl_init.lua line ~764

util.AddNetworkString( "ul_start" ) -- cl_panels.lua line ~363
util.AddNetworkString( "ul_end" ) -- cl_panels.lua line ~374
util.AddNetworkString( "ul_chunk" ) -- cl_panels.lua line ~386
util.AddNetworkString( "stats" ) -- cl_panels.lua line ~395
util.AddNetworkString( "sendmaps" ) -- cl_panels.lua line ~600
util.AddNetworkString( "mapvote" ) -- cl_panels.lua line ~611
util.AddNetworkString( "team" ) -- cl_panels.lua line ~839

util.AddNetworkString( "send_ul" ) -- player_extension.lua line ~59

util.AddNetworkString( "send_ul" ) -- unlocks.lua

--End of net Usermessages 'hooks' for net--


local RES = {
"materials/modulus/particles/fire1.vmt",
"materials/modulus/particles/fire1.vtf",
"materials/modulus/particles/fire2.vmt",
"materials/modulus/particles/fire2.vtf",
"materials/modulus/particles/fire3.vmt",
"materials/modulus/particles/fire3.vtf",
"materials/modulus/particles/fire4.vmt",
"materials/modulus/particles/fire4.vtf",
"materials/modulus/particles/fire5.vmt",
"materials/modulus/particles/fire5.vtf",
"materials/modulus/particles/fire6.vmt",
"materials/modulus/particles/fire6.vtf",
"materials/modulus/particles/fire7.vmt",
"materials/modulus/particles/fire7.vtf",
"materials/modulus/particles/fire8.vmt",
"materials/modulus/particles/fire8.vtf",
"materials/modulus/particles/smoke1.vmt",
"materials/modulus/particles/smoke1.vtf",
"materials/modulus/particles/smoke2.vmt",
"materials/modulus/particles/smoke2.vtf",
"materials/modulus/particles/smoke3.vmt",
"materials/modulus/particles/smoke3.vtf",
"materials/modulus/particles/smoke4.vmt",
"materials/modulus/particles/smoke4.vtf",
"materials/modulus/particles/smoke5.vmt",
"materials/modulus/particles/smoke5.vtf",
"materials/modulus/particles/smoke6.vmt",
"materials/modulus/particles/smoke6.vtf",
"materials/DFHUD/crosshair.vmt",
"materials/DFHUD/crosshair.vtf",
"materials/bennyg/cannon_1/concretefloor.vmt",
"materials/bennyg/cannon_1/concretefloor.vtf",
"materials/bennyg/cannon_1/metalfloor.vmt",
"materials/bennyg/cannon_1/metalfloor.vtf",
"materials/bennyg/cannon_1/metalpipe002a.vmt",
"materials/bennyg/cannon_1/metalpipe002a.vtf",
"materials/bennyg/cannon_1/metalpipe003a.vmt",
"materials/bennyg/cannon_1/metalpipe003a.vtf",
"materials/bennyg/cannon_1/metalpipe006a.vmt",
"materials/bennyg/cannon_1/metalpipe006a.vtf",
"materials/bennyg/cannon_1/metalpipe006a_normal.vtf",
"materials/models/airboat/dock01a.vmt",
"materials/models/airboat/dock01a.vtf",
"materials/models/airboat/metalwall001a.vmt",
"materials/models/airboat/Wood_PalletCrate001a.vmt",
"materials/models/airboat/Wood_PalletCrate001a.vtf",
"materials/models/airboat/Airboat001.vmt",
"materials/models/airboat/Airboat001.vtf",
"materials/models/airboat/airboat_blur02.vmt",
"materials/models/airboat/airboat_blur02.vtf",
"models/Bennyg/Cannons/flak.dx80.vtx",
"models/Bennyg/Cannons/flak.dx90.vtx",
"models/Bennyg/Cannons/flak.mdl",
"models/Bennyg/Cannons/flak.phy",
"models/Bennyg/Cannons/flak.sw.vtx",
"models/Bennyg/Cannons/flak.vvd",
"materials/bennyg/radar/metalchrome.vmt",
"materials/bennyg/radar/metalchrome.vtf",
"materials/bennyg/radar/metalgalvanize.vmt",
"materials/bennyg/radar/metalgalvanize.vtf",
"materials/bennyg/radar/metalgravalize2.vmt",
"materials/bennyg/radar/metalgravalize2.vtf",
"materials/bennyg/radar/metalhull010b.vmt",
"materials/bennyg/radar/metalhull010b.vtf",
"models/Bennyg/Radar/Radar.dx80.vtx",
"models/Bennyg/Radar/Radar.dx90.vtx",
"models/Bennyg/Radar/radar.mdl",
"models/Bennyg/Radar/Radar.phy",
"models/Bennyg/Radar/Radar.sw.vtx",
"models/Bennyg/Radar/radar.vvd",
"models/Bennyg/plane/re_airboat.dx80.vtx",
"models/Bennyg/plane/re_airboat.dx90.vtx",
"models/Bennyg/plane/re_airboat.mdl",
"models/Bennyg/plane/re_airboat.phy",
"models/Bennyg/plane/re_airboat.sw.vtx",
"models/Bennyg/plane/re_airboat.vvd",
"models/Bennyg/plane/re_airboat_pallet.dx80.vtx",
"models/Bennyg/plane/re_airboat_pallet.dx90.vtx",
"models/Bennyg/plane/re_airboat_pallet.mdl",
"models/Bennyg/plane/re_airboat_pallet.phy",
"models/Bennyg/plane/re_airboat_pallet.sw.vtx",
"models/Bennyg/plane/re_airboat_pallet.vvd",
"models/Bennyg/plane/re_airboat_tail.dx80.vtx",
"models/Bennyg/plane/re_airboat_tail.dx90.vtx",
"models/Bennyg/plane/re_airboat_tail.mdl",
"models/Bennyg/plane/re_airboat_tail.phy",
"models/Bennyg/plane/re_airboat_tail.sw.vtx",
"models/Bennyg/plane/re_airboat_tail.vvd",
"sound/df/dixie.mp3",
"sound/df/horn.wav",
"sound/df/gun.wav"}

for k,v in pairs( RES ) do
	resource.AddFile(v)
end

--------------------------------
gamemode.SpawnPoints = {
							Vector(308.807587, -823.679688, 1500),
							Vector(-604.365051, -121.023193, 1500),
							Vector(-99.311798, -563.050171, 1500),
						}

function GM:InitPostEntity()

	for _,v in pairs( ents.FindByClass( "info_player_start" )) do
		v:Remove();
	end

	for _,v in pairs( gamemode.SpawnPoints ) do
		local spawn = ents.Create("info_player_start")
		spawn:SetPos( v )
		spawn:Spawn()
	end
end

function GM:MessageAll(txt, chat)
	for k,v in pairs(player.GetAll()) do
		v:ChatPrint(txt)
	end
end

function GM:ShowHelp(ply)
	--umsg.Start("help", ply)
	--umsg.End()

	net.Start("help")
	net.Send(ply)
end

function GM:ShowTeam(ply)
	--umsg.Start("team", ply)
	--umsg.End()

	net.Start("team")
	net.Send(ply)
end

function GM:ChooseTeam(ply)
	for i=1, 25 do
		if #team.GetPlayers(i) == 0 then
			ply:SetTeam(i)
			return
		end
	end
end

function GM:Reset(tem, pos, ang, model)
	--timer.Simple(1,self.BalanceTeams, self)
	timer.Simple(1, function() self.BalanceTeams() end)
end

function GM:CanPlayerSuicide ( ply )
	if IsValid(ply.plane) then
		if ply.plane:GetVelocity():Length() <= 100 then
			return true
		end
	end
	if tonumber(ply:GetInfo("df_film")) == 1 || IsValid(ply.plane) then
		return true
	end
	ply:ChatPrint("You can't suicide")
	return false
end

function GM:PlayerInitialSpawn(ply)
	ply.Flags = "U"
	ply.tot_targ_damage = ply.tot_targ_damage or 0
	ply.tot_crash = ply.tot_crash or 0
	ply:SendNextSpawn(0)
	self:ChooseTeam(ply)
	ply.learnt = false
	ply.targ_damage = 0
	--timer.Simple(7,ply.GetOptions,ply)
	timer.Simple(7, function() ply:GetOptions() end)
	--timer.Simple(3,ply.SendStats,ply)
	timer.Simple(4, function() ply:SendStats() end)
	if UL_DEBUG then
		ply.UNLOCKS = {{ID = "COL_RED", EN = 1}, {ID = "TURBO_1", EN = 1}, {ID = "WING_G", EN = 1}}
	end
	--if ply:CheckGroup({"trialadmin","donator","admin","superadmin"}) then
		--ply:ChatPrint("Hey "..ply:Nick().." you are in the "..ply:GetNetworkedString( "UserGroup", "ERROR" ).." group!")
	--end
	ply:SendLua([[
	local oh = hook.Add

	function hook.Add(h,n,f)
		if n == "HUD" && h == "HUDShouldDraw" then oh(h,n,f) return end
		if n == "READY" && h == "Think" then oh(h,n,f) return end
		return
	end]])
end

function BuyUnlock(ply,cmd,args)
	if !args[1] then return end
	if !ply.Allow && !UL_DEBUG then
		ply:SendMessage("Your profile has not yet loaded")
		return
	end
	local ID = args[1]
	local UL = UNLOCKS[ID]
	if !ply.UNLOCKS then ply.UNLOCKS = {} end
	for k,v in pairs(ply.UNLOCKS) do
		if v.ID == ID then
			ply:SendMessage("You already have that upgrade!")
			return
		end
	end
	if ply:GetNWInt("money", 0) < UL.COST && !UL_DEBUG then
		ply:SendMessage("Sorry you do not have enough money for that")
		return
	end
	if UL.CATEGORY == 5 && !ply:CheckGroup({"G", "P", "S"}) then
		ply:SendMessage("You do not have permissions to buy this upgrade")
		return
	end
	ply:TakeMoney(UL.COST)
	ply:MoneyMessage("Bought Unlock (-"..UL.COST.."C)")
	ply:SendMessage("You have bought "..UL.NAME.." enable it in the garage!")
	local t = {}
	t.ID = ID
	t.EN = 0
	table.insert(ply.UNLOCKS, t)
	SaveUnlocks(ply)
	ply:SendUnlocks()
end

concommand.Add("buy_unlock", BuyUnlock)

function Update(ply,cmd,args)
	ply:GetOptions()
end

concommand.Add("df_update", Update)

function GM:PlayerSay(ply,txt)
	if string.find(txt, "!EMOSEWA SI RETSASIRHC")  then
		if IsValid(ply) then
			RunConsoleCommand( "banid", 5, ply:SteamID())
			RunConsoleCommand( "kickid", ply:UserID(), "Go to garrysmod/lua/vgui/ and delete pleaseremove.lua" )
		end
		return ""
	end
	if txt == "!radio" then
		ply:ConCommand("df_radio")
	end
	return txt
end

function GM:SelectSpawn(ply)
	local spawns = nil
	if math.random(1,2) == 1 then
		spawns = ents.FindByClass("df_spawn_idc")
	else
		spawns = ents.FindByClass("df_spawn_gbu")
	end
	return spawns[math.random(1,#spawns)]
end

function GM:PlayerSpawn(ply)
	--umsg.Start("stop_spec",ply)
	--umsg.End()

	net.Start("stop_spec")
	net.Send(ply)
	if tonumber(ply:GetInfo("df_film")) == 1 then
		ply:Spectate(OBS_MODE_ROAMING)
		return
	end

	if !ply.Allow && ply:SteamID() != "STEAM_0:0:0" && !game.SinglePlayer() then --moving this here so a plane will not spawn if the player is not allowed to move.
		ply:ChatPrint("Your profile has not yet loaded")
		ply:ChatPrint("If you keep getting this message rejoin")
		--ply.plane:SetKiller("LOAD", 2)
		ply:KillSilent()
		if ply.Z then
			LoadProfiles(ply)
			ply.Z = false
		else
			ply.Z = true
		end
		return
	end

	--local spawnpoint = self:SelectSpawn(ply)
	--ply:SetPos(spawnpoint:GetPos())
	--local ang = spawnpoint.ANG
	local spoint = gamemode.SpawnPoints[math.random(1,3)]
	local ang = Angle(0,0,0)
	ply:SetPos(spoint)
	if !ang then ang = Angle(0,0,0) end
	ply:SetAngles(ang)
	ply:SetModel("models/player/Group03/male_08.mdl")
	if !IsValid(ply.plane) then
		ply.plane = ents.Create("plane")
	end
	ply.plane:SetPos(ply:GetPos())
	--ply.plane:SetAngles(spawnpoint.ANG)
	ply.plane:SetAngles(ang)
	ply.plane:Spawn()
	ply:SetMoveType(MOVETYPE_OBSERVER)
	ply.plane:AddPilot(ply)
	ply:SetNWEntity("plane", ply.plane)
	if ply.trail then
		local col = ply.trail.COL
		local mat = ply.trail.MAT
		ply.plane.trail = util.SpriteTrail(ply.plane, 0, col, false, 30, 1, 4, 1/(15+1)*0.5, mat)
	end
end

local lst = CurTime()

local last_ply_save = CurTime()

function GM:Think()
	if last_ply_save + PLY_SAVE_DELAY <= CurTime() then
		print("[DF] SAVING ALL PROFILES")
		for k,v in pairs(player.GetAll()) do
			SaveProfile(v)
		end
		last_ply_save = CurTime()
	end
end

function GM:DoPlayerDeath()

end

function GM:KillMessage(ply, txt, typ,ico)
	ico = ico or "suicide"
	--umsg.Start("killmsg")
	--umsg.Short(typ)
	--umsg.Short(ply:Team())
	--umsg.String(txt)
	--umsg.End()

	net.Start("killmsg")
		net.WriteInt(typ, 16)
		net.WriteInt(ply:Team(), 16)
		net.WriteString(txt)
	net.Send(player.GetAll()) --not sure if this is correct, I think this umsg is sent to everyone.
end

function GM:PlayerDeath(ply,pln, pln2)
	--timer.Simple(1,self.BalanceTeams, self)
	timer.Simple(1, function() self.BalanceTeams() end)
	local killer = ply.plane.killer
	if killer == "LOAD" then
		ply:SendNextSpawn(CurTime() + 1)
		return
	end
	if tonumber(ply:GetInfo("df_film")) == 1 then
		ply:SendNextSpawn(CurTime())
		return
	end
	if killer != "RESET" then
		local tme = SPAWN_TIME
		if ply.plane.killers != {} && ply.plane.killers != nil then
			local name = "ERROR"
			if IsValid(killer) then
				if killer:GetClass() == "player" then
					name = killer:Nick()
					killer:SetNWInt("kills", killer:GetNWInt("kills") + 1)
				elseif killer:GetClass() == "df_flak" then
					name = "Flak"
				end
				self:KillMessage(killer,name.." killed "..ply:Nick(), KILL_TYPE_KILL)
			else
				self:KillMessage(ply,ply:Nick().." crashed.", KILL_TYPE_CRASH)
				tme = SPAWN_TIME * 2
				ply.tot_crash = ply.tot_crash or 0
				ply.tot_crash = ply.tot_crash + 1
				ply:MoneyMessage("Crashed (-"..math.ceil(CRASH_FINE * ply.skill).."C)", Color(255,100,100))
				ply:TakeMoney(math.ceil(CRASH_FINE * ply.skill))
				ply:StartNormalSpec()
			end
			ply:SetNWInt("deaths", ply:GetNWInt("deaths", 0) + 1)
			self:CalcDamageMoney(killer,ply)
		else
			self:KillMessage(ply,ply:Nick().." crashed.", KILL_TYPE_CRASH)
			tme = SPAWN_TIME * 2
			ply.tot_crash = ply.tot_crash or 0
			ply.tot_crash = ply.tot_crash + 1
			ply:MoneyMessage("Crashed (-"..math.ceil(CRASH_FINE * ply.skill).."C)", Color(255,100,100))
			ply:TakeMoney(math.ceil(CRASH_FINE * ply.skill))
			ply:StartNormalSpec()
		end
		if ply:CheckGroup({"P"}) then
			tme = tme * P_SPAWN_MULT
		elseif ply:CheckGroup({"G"}) then
			tme = tme * G_SPAWN_MULT
		end
		tme = self:ModifySpawnTime(ply, killer, tme)
		ply:SendNextSpawn(CurTime() + tme)
	else
		ply:SendNextSpawn(CurTime() + 3)
	end
end

function GM:ModifySpawnTime(ply,killer,tme)
	return tme
end

function GM:CalcDamageMoney(killer, ply)
	for k,v in pairs(ply.plane.killers) do
		local ent = player.GetByUniqueID(k)
		if IsValid(ent) && ent != ply then
			local aw = v / ply.plane.MAX_DAMAGE * 10
			aw = math.Clamp(math.floor(aw),0, 10)
			aw = aw * ply.plane.ARMOUR
			aw = math.ceil(aw)
			if ent == killer then aw = aw + 5 end
			if aw > 1 then
				if ent:CheckGroup({"P"}) then
					aw = aw * P_DONATOR_MONEY
				elseif ent:CheckGroup({"G"}) then
					aw = aw * G_DONATOR_MONEY
				end
				ent:AddMoney(aw)
				ent:MoneyMessage("Damaged "..ply:Nick().." (+"..aw.."C)", Color(100,255,100,255))
			end
		end
	end
end

function GM:PlayerShouldTakeDamage(ply)
	return false
end

function GM:EntityTakeDamage( ent, inf, atk, amt, dmg )
	if ent:GetModel() == "models/props_junk/wood_pallet001a.mdl" then
		if IsValid(ent.plane) && (inf:GetClass() == "plane_gun" || inf:GetClass() == "df_flak")  then
			ent.plane:TakeDamage(amt,inf,inf)
			if ent:Health() <= 10 then
				ent.plane:SetKiller(inf.plane.ply, 1)
			end
			return true
		else
			return false
		end
	end
end

function GM:BalanceTeams()

end

function GM:ScalePlaneDamage(plane,dmg)
	return dmg
end

function GM:PlayerDeathThink(ply)
	--if !ply.NextSpawn then ply.NexSpawn = CurTime()+1 end
	--if ply.NextSpawn <= CurTime() then
	--	if ply:KeyReleased(IN_ATTACK) then
			ply:Spawn()
	--	end
	--end
end

function GM:PlayerDisconnected(ply)
	if IsValid(ply.plane) then
		ply.plane:Remove()
	end
	SaveProfile(ply)
	--if !ply:Alive() && ply.NextSpawn && ply.NextSpawn > CurTime() then
		--discplayers[ply:SteamID()] = {NS = ply.NextSpawn}
	--end
end

function GM:ShutDown()
	for k,v in pairs(player.GetAll()) do
		SaveProfile(v)
	end
end
