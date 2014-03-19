include("shared.lua")

g_CVN78_FlashTime = 0

local function Snd(filename, duration)
	local path = "df/cvn78/" .. filename .. ".mp3"
	
	Sound(path)
	
	return {path, duration}
end

local ExitPointMarkers  = {
Vector(-6906, -8615, -712),
Vector(-7857, -7664, -685),
Vector(-8928, -6106, -685),
Vector( 8661,  8835, -707),
Vector( 9612,  7884, -680),
Vector( 10683, 6326, -680),
}

local UpperdeckSpeakers  = {
Vector(-6917, -7765, -121),
Vector(8790, 7763, 76),
--Vector(-6258, -7722, -281),
--Vector(-7384, -6819, -96),
--Vector(-7569, -6688, -131),
--Vector(-8282, -6152, -281),
--Vector(-9145, -6451, -281),
--Vector(-8406, -7230, -108),
--Vector(-8556, -7308, 160),
--Vector(-8490, -7337, 160),
--Vector(-8543, -7548, -179),
--Vector(-5483, -9008, -282),
--Vector(-6968, -9048, -281),
--Vector(-4745, -10594, -281),
}

--local LowerdeckSpeakers  = {
--Vector(-6836, -7620, -594),
--Vector(-7041, -8470, -658),
--Vector(-6762, -8749, -658),
--Vector(-6494, -9016, -672),
--Vector(-6028, -8984, -595),
--Vector(-5988, -8511, -674),
--Vector(-7712, -7799, -658),
--Vector(-7991, -7520, -658),
--Vector(-7917, -6580, -595),
--Vector(-8413, -6086, -623),
--Vector(-8665, -6365, -605),
--Vector(-8899, -6576, -624),
--}

function ENT:Initialize()
	g_CVN78Manager = self
	
	local fx = EffectData()
	util.Effect("df_cvn78_thunder_background", fx, true, true)
	
	self:SetColor(255, 255, 255, 0)
	
	local BackgroundWind = {Snd("wind_med1", 13), -- Backgroundish
							Snd("wind_med2", 16)}

	local function BackgroundWindFunc()
		local tbl = BackgroundWind[math.random(1, 2)]
		
		LocalPlayer():EmitSound(tbl[1])
		
		return timer.Simple(math.random(math.Clamp(tbl[2] + math.Rand(-3, 3), 0, 12), 20), BackgroundWindFunc)
	end

	timer.Simple(1, BackgroundWindFunc)
	
	local lp    = LocalPlayer()
	local storm = lp.CVN78StormLoop or CreateSound(lp, "df/cvn78/rain2_loop1.wav")
	lp.CVN78StormLoop = storm
	
	storm:PlayEx(0, 100)
	
	local function timer_callback_rain()
		if not ExitPointMarkers then
			--ErrorNoHalt("NO MARKERS!\n")
			
			return storm:ChangeVolume(.75)
		elseif LocalPlayer():GetNWBool("CVN78Indoors", true) then
			local eyepos = LocalPlayer():GetPos(sacv)
			local closest = 999999
			
			for k, v in pairs(ExitPointMarkers) do
				local dist = v:Distance(eyepos)
				
				if dist < closest then
					closest = dist
				end
			end
			
			return storm:ChangeVolume(math.Clamp(1 - (closest / 512), .35, 1) * .75)
		end
		
		return storm:ChangeVolume(.75)
	end
	
	timer.Create("CVN78ManagerRainSoundTimer", .25, 0, timer_callback_rain)
	
	
	if not string.find(string.gsub(ents.GetByIndex(0):GetModel(), "(%w*/)", ""), "df_cvn78") then return end -- Only for my map
	
	for k, v in pairs(UpperdeckSpeakers) do
		WorldSound("ambient/alarms/combine_bank_alarm_loop1.wav", v, 500, 100)
	end
	
	--for k, v in pairs(LowerdeckSpeakers) do
	--	WorldSound("ambient/alarms/alarm_citizen_loop1.wav", v, 75, 100)
	--end
end

