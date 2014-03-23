require( "mysqloo" )

--tmysql.initialize("127.0.0.1", "gameserver1337", "r5vmH2wrrzCzjsbf", "faintlink", 3306, 5, 6)
--tmysql.initialize("91.192.210.79", "connor", "sexeh1337", "faintlink", 3306, 11, 10)

local db = mysqloo.connect( "127.0.0.1", "root", "" , "dogfight", 3306)

function db:onConnectionFailed( errorMessage )
	Msg("There was an error connecting to the database!\n")
	Msg(errorMessage .. "\n")
end
function db:onConnected( )
	Msg("Database Connected!\n")
end

function dbquery( query, callback )
	local q = db:query( query )
	function q:onSuccess( data )
		--stuff
		if callback then
			callback(data)
		end
	end
	function q:onError( error, sql)
		if db:status()==mysqloo.DATABASE_NOT_CONNECTED then
			print("Database is not connected\n")
		end
		print("SQL error: " .. tostring(error) .. "\n")
	end

	q:start()

end

function SetAllOffline()

	--tmysql.query("UPDATE clients SET server = 0 WHERE server = 27025 ", function(setalloffline,status,error)
	--	if (error != 0) then print(tostring(error) .. "\n") Error(tostring(error) .. "\n")  return end
	--end)

	dbquery("UPDATE clients SET server = 0 WHERE server = 27025 ")

end
hook.Add( "ShutDown", "ShuttingDown", SetAllOffline )
hook.Add( "Initialize", "StartingUp", SetAllOffline )

 --[[
U = User
G = Gold
P = Platinum
T = Trial Admin
A = Admin
S = Super Admin
]]

local FLS = {}
FLS["u"] = "User"
FLS["g"] = "Gold Member"
FLS["p"] = "Platinum"
FLS["t"] = "Temp. Admin"
FLS["a"] = "Admin"
FLS["s"] = "Superadmin"

function TranslateFlags(ply)
	if !ply.Flags then return end
	local t = string.ToTable(string.lower(ply.Flags))
	local out = {}
	for k,v in pairs(t) do
		table.insert(out, FLS[v])
	end
	return string.Implode(" ", out)
end

function Groups(ply)
	if not ply:IsValid() then return end

	local steamid = ply:SteamID()

		--[[tmysql.query("SELECT groups FROM clients WHERE steamid ='" ..steamid.."'", function(groups,status,error)

		ply.Flags = tostring(groups[1][1])
		ply:ChatPrint("Your flags have loaded! You are in the "..TranslateFlags(ply).." groups!")
		--umsg.Start("sendflags", ply)
		--umsg.String(ply.Flags)
		--umsg.End()

		net.Start("sendflags")
			net.WriteString(ply.Flags)
		net.Send(ply)

		if (error != 0) then print(tostring(error) .. "\n") Error(tostring(error) .. "\n")  return end

		end)]]--

	dbquery("SELECT groups FROM clients WHERE steamid ='" ..steamid.."'", function(groups)
		ply.Flags = tostring(groups[1][1])
		ply:ChatPrint("Your flags have loaded! You are in the "..TranslateFlags(ply).." groups!")

		net.Start("sendflags")
			net.WriteString(ply.Flags)
		net.Send(ply)
	end)

end

function StatusOnline(ply)
	if not ply:IsValid() then return end

  	local steamid = ply:SteamID()

	--tmysql.query("UPDATE clients SET server = 27025 WHERE steamid ='" ..steamid.."'", function(statusonline,status,error)
	--	if (error != 0) then print(tostring(error) .. "\n") Error(tostring(error) .. "\n")  return end
	--end)

	dbquery("UPDATE clients SET server = 27025 WHERE steamid ='" ..steamid.."'")
end

function StatusOffline(ply)
	if not ply:IsValid() then return end

	SaveProfile(ply)
  	local steamid = ply:SteamID()
	local TimeOnline = tonumber(math.Round(TimePlayed + TIME))

	--tmysql.query("UPDATE clients SET timeplayed = "..TimeOnline.." WHERE steamid ='" ..steamid.."'", function(results,status,error)
	--	if (error != 0) then print(tostring(error) .. "\n") Error(tostring(error) .. "\n")  return end
	--end)

	dbquery("UPDATE clients SET timeplayed = "..TimeOnline.." WHERE steamid ='" ..steamid.."'")

	--tmysql.query("UPDATE clients SET server = 0 WHERE steamid ='" ..steamid.."'", function(checkprofile,status,error)
	--	if (error != 0) then print(tostring(error) .. "\n") Error(tostring(error) .. "\n")  return end
	--end)

	dbquery("UPDATE clients SET server = 0 WHERE steamid ='" ..steamid.."'")

end
hook.Add("PlayerDisconnected", "PlayerOffline", StatusOffline)

function LoadUnlocks(ply)
	if not ply:IsValid() then return end

	local steamid = ply:SteamID()
	--[[tmysql.query("SELECT unlocks FROM dogfight WHERE steamid ='" ..steamid.."'", function(loadunlocks,status,error)

			if (error != 0) then print(tostring(error) .. "\n") Error(tostring(error) .. "\n")  return end

	if (loadunlocks[1] == nil) or (loadunlocks[1][1] == nil) then
		ply.Allow = true
	return end

	ply.UNLOCKS = {}
	local str = loadunlocks[1][1]
	local new = ""
	if string.sub(str,1,1) == "," then
		str = string.sub(str,1,string.len(str))
		local tab = string.Explode(",", str)
		for k,v in pairs(tab) do
			if v != "" and v != nil then
				new = new..v..",1,"
			end
		end
		new = string.sub(new,1,string.len(new) - 1)
	end
	if new != "" then
		str = new
	end
	local tab = string.Explode(",", str)
	local t = {}
	for k,v in pairs(tab) do
		print(v)
		if v == "1" or v == "0" then
			t.EN = tonumber(v)
			table.insert(ply.UNLOCKS, t)
			t = {}
		else
			t.ID = v
		end
	end
	ply.Allow = true
	end)]]--

	dbquery("SELECT unlocks FROM dogfight WHERE steamid ='" ..steamid.."'", function(loadunlocks)
		if (loadunlocks[1] == nil) or (loadunlocks[1][1] == nil) then
			ply.Allow = true
			return
		end

		ply.UNLOCKS = {}
		local str = loadunlocks[1][1]
		local new = ""
		if string.sub(str,1,1) == "," then
			str = string.sub(str,1,string.len(str))
			local tab = string.Explode(",", str)
			for k,v in pairs(tab) do
				if v != "" and v != nil then
					new = new..v..",1,"
				end
			end
			new = string.sub(new,1,string.len(new) - 1)
		end
		if new != "" then
			str = new
		end
		local tab = string.Explode(",", str)
		local t = {}
		for k,v in pairs(tab) do
			print(v)
			if v == "1" or v == "0" then
				t.EN = tonumber(v)
				table.insert(ply.UNLOCKS, t)
				t = {}
			else
				t.ID = v
			end
		end
		ply.Allow = true
	end)

end

function LoadProfiles(ply)
	if not IsValid(ply) then return end

	ply.Save = CurTime()
	ply.Allow = false

	local steamid = ply:SteamID()
	local name = ply:Nick()

	--[[tmysql.query("SELECT steamid FROM clients WHERE steamid ='" ..steamid.."'", function(checkprofile,status,error)
		if (error != 0) then print(tostring(error) .. "\n") Error(tostring(error) .. "\n")  return end
		if ( checkprofile[1] == nil ) or ( checkprofile[1][1] == nil ) then
			tmysql.query("INSERT INTO clients (steamid,name) VALUES('"..steamid.."','"..tmysql.escape(name).."')", function(newplayer,status,error)
				if (error != 0) then print(tostring(error) .. "\n") Error(tostring(error) .. "\n")  return end
			end)
		else
			tmysql.query("UPDATE clients SET name ='"..tmysql.escape(name).."' WHERE steamid ='" ..steamid.."'", function(setname,status,error)
				if (error != 0) then print(tostring(error) .. "\n") Error(tostring(error) .. "\n")  return end
			end)
		end
	end)]]--

	dbquery("SELECT steamid FROM clients WHERE steamid ='" ..steamid.."'", function(checkprofile)
		if ( checkprofile[1] == nil ) or ( checkprofile[1][1] == nil ) then
			tmysql.query("INSERT INTO clients (steamid,name) VALUES('"..steamid.."','"..tmysql.escape(name).."')", function(newplayer,status,error)
				if (error != 0) then print(tostring(error) .. "\n") Error(tostring(error) .. "\n")  return end
			end)
		else
			tmysql.query("UPDATE clients SET name ='"..tmysql.escape(name).."' WHERE steamid ='" ..steamid.."'", function(setname,status,error)
				if (error != 0) then print(tostring(error) .. "\n") Error(tostring(error) .. "\n")  return end
			end)
		end
	end)

	--[[tmysql.query("SELECT kills,deaths,money,tc,ttd FROM dogfight WHERE steamid ='" ..steamid.."'", function(loadstuff,status,error)

		if ( loadstuff[1] == nil )  then

			tmysql.query("INSERT INTO dogfight (steamid,kills,deaths,money,tc,ttd,unlocks) VALUES('"..steamid.."',0,0,0,0,0,'DEFAULT_UNLOCK,1')", function(newdf,status,error)
				if (error != 0) then print(tostring(error) .. "\n") Error(tostring(error) .. "\n")  return end
			end)

			ply.tot_targ_damage = 0
			ply.tot_crash = 0
			kills = 0
			deaths = 0
			money = 0
		else
			ply.tot_crash = tonumber(loadstuff[1][4])
			ply.tot_targ_damage = tonumber(loadstuff[1][5])
			kills = tonumber(loadstuff[1][1])
			deaths = tonumber(loadstuff[1][2])
			money = tonumber(loadstuff[1][3])
		end
		ply:SetNWInt("kills", kills )
		ply:SetNWInt("deaths", deaths )
		ply:SetNWInt("money", money )

		timer.Simple(1,ply,SendStats,ply)
		LoadUnlocks(ply)

		timer.Simple(3, function()
			Groups(ply)
			StatusOnline(ply)
		end)

	end)]]--

	dbquery("SELECT kills,deaths,money,tc,ttd FROM dogfight WHERE steamid ='" ..steamid.."'", function(loadstuff)
		if ( loadstuff[1] == nil )  then

			dbquery("INSERT INTO dogfight (steamid,kills,deaths,money,tc,ttd,unlocks) VALUES('"..steamid.."',0,0,0,0,0,'DEFAULT_UNLOCK,1')")

			ply.tot_targ_damage = 0
			ply.tot_crash = 0
			kills = 0
			deaths = 0
			money = 0
		else
			ply.tot_crash = tonumber(loadstuff[1][4])
			ply.tot_targ_damage = tonumber(loadstuff[1][5])
			kills = tonumber(loadstuff[1][1])
			deaths = tonumber(loadstuff[1][2])
			money = tonumber(loadstuff[1][3])
		end
		ply:SetNWInt("kills", kills )
		ply:SetNWInt("deaths", deaths )
		ply:SetNWInt("money", money )

		timer.Simple(1,ply,SendStats,ply)
		LoadUnlocks(ply)

		timer.Simple(3, function()
			Groups(ply)
			StatusOnline(ply)
		end)
	end)

end

hook.Add("PlayerInitialSpawn", "PlayerLoading", LoadProfiles)

function ImplodeTable(Sep,Tab)
	local Out = ""
	for k,v in pairs(Tab) do
		Out = Out..Sep..v.ID..Sep..v.EN
	end
	Out = string.sub(Out, 2, string.len(Out))
	return Out;
end

function SaveUnlocks(ply)
	if not ply:IsValid() then return end
	if ply.UNLOCKS == nil || ply.UNLOCKS == {} then return end
	local steamid = ply:SteamID()
	local OUT = ImplodeTable(",",ply.UNLOCKS)
	if ply.Allow then
		--tmysql.query("UPDATE dogfight SET unlocks = '"..OUT.."' WHERE steamid ='" ..steamid.."'", function(saveunlocks,status,error)
		--	if (error != 0) then print(tostring(error) .. "\n") Error(tostring(error) .. "\n")  return end
		--end)

		dbquery("UPDATE dogfight SET unlocks = '"..OUT.."' WHERE steamid ='" ..steamid.."'")

	end
end

function SaveProfile(ply)
	if not ply:IsValid() then return end
	local steamid = ply:SteamID()
	local kills = ply:GetNWInt("kills")
	local deaths = ply:GetNWInt("deaths")
	local money = ply:GetNWInt("money")

	if ply.Allow then
		--tmysql.query("UPDATE dogfight SET kills = "..kills..", deaths = "..deaths..", money = "..money..", tc = "..ply.tot_crash..", ttd = "..ply.tot_targ_damage.." WHERE steamid ='" ..steamid.."'", function(savemoney,status,error)
		--	if (error != 0) then print(tostring(error) .. "\n") Error(tostring(error) .. "\n")  return end
		--end)

		dbquery("UPDATE dogfight SET kills = "..kills..", deaths = "..deaths..", money = "..money..", tc = "..ply.tot_crash..", ttd = "..ply.tot_targ_damage.." WHERE steamid ='" ..steamid.."'")

	else
		ply:ChatPrint("Your profile hasn't saved, your profile hasn't loaded!")
	end
end

db:connect() --calling this last just in case