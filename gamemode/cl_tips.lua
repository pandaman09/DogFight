
//Works pretty much like sandboxes hint system.

CreateClientConVar( "df_showtips", "1", true, false )
CreateClientConVar( "df_tutorial", "1", true, false ) // show the initial stuff
--surface.CreateFont( "", 30, 600, true, false, "DFTips" )
surface.CreateFont( "DFTips", {
	font = "Verdana",
	size = 30,
	weight = 600,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

language.Add("Tips_Welcome", "Hello and welcome to Dogfight: Arcade Assault!")
language.Add("Tips_Welcome2", "The aim of the game is simple.")
language.Add("Tips_Welcome3", "Steal the enemies fuel!")
language.Add("Tips_Welcome4", "While defending yours.")

language.Add("Tips_Controls1", "The Controls are easy.")
language.Add("Tips_Controls2", "Use your mouse to steer.")
language.Add("Tips_Controls3", "Left-click to shoot your machine guns.")
language.Add("Tips_Controls4", "Right-click to fire your powerup.")
language.Add("Tips_Controls5", "Which can be collected at the glowing stations.")
language.Add("Tips_Controls6", "You can change powerup with the number keys.")
language.Add("Tips_Controls7", "Shift and Crouch for Throttle.")
language.Add("Tips_Controls8", "Q -Menu and Use for roll.")
language.Add("Tips_Controls9", "That's it! You're set to fly. Good luck!")

language.Add("Tips_TurnOff1", "You can turn these off by pressing F1 then settings.")

language.Add("Tips_FuelPickup", "You have the fuel! Take it back to your rocket.")
language.Add("Tips_NoWepGotFuel", "No powerups with the fuel. Ask a teammate to help!")

language.Add("Tips_WepSelect1", "You can select powerups with the number keys.")
language.Add("Tips_WepSelect2", "You can also select powerups with the mouse wheel.")

language.Add("Tips_BarrelRoll", "Remember, you can barrel roll with Q and E.")

language.Add("Tips_MissileLocked", "Missile Locked! Take Evasive Action!")

local ProcessedTips = {} //Tips we have already told the newbie about.

local TipDrawQ = {} //Tips we will draw soon.

function GoTip(name)
	//print("ADDING TIP: ", name)
	local tab = {}
	tab.Text = name
	//tab.Start = CurTime()
	tab.x_off = 0
	table.insert(TipDrawQ, tab)
end

function GM:AddTip(name, delay, str)
	if (ProcessedTips[ name ]) then return end
	if !str then --from language.add
		timer.Create("DFTips_"..name, delay, 1, function() GoTip("#Tips_"..name) end)
	else --string constant
		timer.Create("DFTips_"..name, delay, 1, function() GoTip(name) end)
	end
	
	ProcessedTips[name] = true
end

function GM:StopHint(name)
	//print("SUPRESSING HINT", name)
	timer.Destroy( "DFTips_"..name)
end

if GetConVarNumber("df_tutorial") == 1 then
	GM:AddTip("Welcome", 6)
	GM:AddTip("Welcome2", 6.1)
	GM:AddTip("Welcome3", 6.2)
	GM:AddTip("Welcome4", 6.3)

	GM:AddTip("Controls1", 6.4)
	GM:AddTip("Controls2", 6.5)
	GM:AddTip("Controls3", 6.6)
	GM:AddTip("Controls4", 6.7)
	GM:AddTip("Controls5", 6.8)
	GM:AddTip("Controls6", 6.9)
	GM:AddTip("Controls7", 7)
	GM:AddTip("Controls8", 7.1)
	GM:AddTip("Controls9", 7.2)
	timer.Simple(60, RunConsoleCommand, "df_tutorial", 0)
end	

GM:AddTip("WepSelect1", 80) //Remind them they can select powerups with the num keys
GM:AddTip("WepSelect2", 81) //Remind them they can select powerups with the num keys

GM:AddTip("BarrelRoll", 100) //Remind you can barrel roll with Q 'n E

GM:AddTip("TurnOff1", 60)

function DrawTips()
	local W = ScrW()
	local H = ScrH()
	if GetConVarNumber("df_showtips") != 1 then return end
	local v = TipDrawQ[1]
	if v and v.Text then
		if !v.Start then
			v.Start = CurTime()
			surface.PlaySound( "ambient/water/drip"..math.random(1, 4)..".wav" ) //Chose this sound because people will recognise it as tips from sandbox instantly
		end
		local pos = {}
		local plane = LocalPlayer():GetPlane()
		surface.SetFont("rocket_nums")
		local w,h = surface.GetTextSize(v.Text)
		--local w = 1000
		if IsValid(plane) then
			pos = plane:GetPos():ToScreen()
			pos.x = pos.x - 25
			pos.y = pos.y - 75
			
			draw.SimpleTextOutlined(   v.Text, "rocket_nums", pos.x + v.x_off, pos.y,  Color(251,200,37,255),  TEXT_ALIGN_RIGHT,  TEXT_ALIGN_CENTER,  2,  Color(10,10,10,255) )
			draw.SimpleTextOutlined(   "TIP: ", "rocket_nums", pos.x + v.x_off - w, pos.y - 28,  Color(251,200,37,255),  TEXT_ALIGN_LEFT,  TEXT_ALIGN_CENTER,  2,  Color(10,10,10,255) )
		else
			pos.x = W / 2
			pos.y = H / 2
			draw.SimpleTextOutlined(   "TIP: ", "rocket_nums", pos.x + v.x_off - w, pos.y - 28,  Color(251,200,37,255),  TEXT_ALIGN_CENTER,  TEXT_ALIGN_CENTER,  2,  Color(10,10,10,255) )
			draw.SimpleTextOutlined(   v.Text, "rocket_nums", pos.x + v.x_off, pos.y,  Color(251,200,37,255),  TEXT_ALIGN_CENTER,  TEXT_ALIGN_CENTER,  2,  Color(10,10,10,255) )
		end
		local text = tostring(v.Text)
		local delay = math.Clamp(w * 0.005, 0.4, 2)
		//print("DELAY FOR ", v.Text, delay)
		if CurTime() - v.Start > delay then
			v.x_off = v.x_off - ((CurTime() - v.Start - delay) * 3)^3
		end
		if pos.x + v.x_off < -100 then
			table.remove(TipDrawQ, 1)
		end
	end
end

hook.Add("HUDPaint", "DFTipsDraw", DrawTips)

