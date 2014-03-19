ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.PrintName    = "CVN78 Manager"
ENT.Author       = "Olivier 'LuaPineapple' Hamel"
ENT.Contact      = "evilpineapple@cox.net"
ENT.Purpose      = "Pff."
ENT.Instructions = ""

ENT.Spawnable      = false
ENT.AdminSpawnable = false

-- FIX THIS FIX THIS FIX THIS FIX THIS FIX THIS FIX THIS (maybe?)
if SERVER then
	print(game.GetMap())
	if game.GetMap() == "df_cvn78_b2" then
		for k, v in pairs(file.Find("sound/df/cvn78/*.mp3")) do
			resource.AddFile("sound/df/cvn78/" .. v)
			print("adding",v)
		end
		
		for k, v in pairs(file.Find("sound/df/cvn78/*.wav")) do
			resource.AddFile("sound/df/cvn78/" .. v)
		end
	end
end

local function Snd(filename, duration)
	local path = "df/cvn78/" .. filename .. ".mp3"
	
	Sound(path)
	
	return {path, duration}
end

local Wind = {Snd("wind_hit1", 2), -- Push
			  Snd("wind_hit2", 2)}

local WindGusts = {Snd("windgust",         6), -- Push hard
				   Snd("windgust_strong", 15)} -- Push real hard!

local function CVN78Message(msg)
	local subtype = msg:ReadChar()
	
	if subtype == 1 then
		--LocalPlayer():EmitSound(Wind[math.random(1, 3)][1])
	elseif subtype == 2 then
		LocalPlayer():EmitSound(WindGusts[1][1])
	elseif subtype == 3 then
		LocalPlayer():EmitSound(WindGusts[2][1])
	end
end
usermessage.Hook("df_cvn78_manager_gust", CVN78Message)

local function CVN78MessageThunder(msg)
	local fx = EffectData()
	fx:SetStart(msg:ReadVector())
	fx:SetOrigin(msg:ReadVector())
	util.Effect("df_cvn78_thunder", fx, true, true)
end
usermessage.Hook("df_cvn78_manager_thunder", CVN78MessageThunder)



