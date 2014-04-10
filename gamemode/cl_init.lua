include( "shared.lua" )
include( "cl_panels.lua" )
include( "cl_scoreboard.lua")

local Color_Icon = Color( 255, 80, 0, 255 )
killicon.AddFont( "gun", 		"HL2MPTypeDeath", 	"/",	Color_Icon )

local rm = false

PLANE = {}
PLANE.MAX_DAMAGE = 100
PLANE.MAX_SPEED = 50
PLANE.MAX_AMMO = 500

HUD = {}
HUD.DAMAGE = 0
HUD.SPEED = 0
HUD.AMMO = PLANE.MAX_AMMO
HUD.AMMO_T = PLANE.MAX_AMMO
HUD.SPEED_T = 0
HUD.PLANE_POS = Vector(0,0,0)

function GM:Initialize()
	local H = ScrH()
	local W = ScrW()
surface.CreateFont( "TID",
                    {
                    font    = "Tahoma",
                    size    = W / 80,
                    weight  = 1000,
                    antialias = true,
                    shadow = false
            })
surface.CreateFont( "Hud Lab",
                    {
                    font    = "Tahoma",
                    size    = W / 144,
                    weight  = 1000,
                    antialias = true,
                    shadow = false
            })
surface.CreateFont( "message",
                    {
                    font    = "Tahoma",
                    size    = W / 96,
                    weight  = 1000,
                    antialias = true,
                    shadow = false
            })
surface.CreateFont( "ScoreboardHead",
                    {
                    font    = "coolvetica",
                    size    = W / 30,
                    weight  = 500,
                    antialias = true,
                    shadow = false
            })
surface.CreateFont( "ScoreboardSub",
                    {
                    font    = "coolvetica",
                    size    = W / 60,
                    weight  = 500,
                    antialias = true,
                    shadow = false
            })
surface.CreateFont( "ScoreboardText",
                    {
                    font    = "Tahoma",
                    size    = W / 90,
                    weight  = 1000,
                    antialias = true,
                    shadow = false
            })
	for k,v in pairs(hook.GetTable()) do
		if k == "HUDPaint" || k == "HUDPaintBackground" || k == "CreateMove" then
			for kay,vay in pairs(v) do
				--print("Blocked hook (Type 1)! Running on "..k.." with name "..kay)
				hook.Remove(k,kay)
			end
		end
	end
end

function GM:UpdateValues() -- lovely and smooth  :D
	local plane = LocalPlayer():GetNWEntity("plane")
	LocalPlayer().plane = plane
	HUD.DAMAGE = plane:GetNWInt("dmg",0)
	HUD.SPEED = math.Approach(HUD.SPEED, HUD.SPEED_T, 0.5)
	if HUD.AMMO < HUD.AMMO_T then
		HUD.AMMO = HUD.AMMO_T
	else
		HUD.AMMO = math.Approach(HUD.AMMO, HUD.AMMO_T, 1)
	end
	if IsValid(plane) then
		HUD.PLANE_POS = plane:GetPos()
	end
end

function Plinfo(length, client)
	HUD.SPEED_T = net.ReadInt(16)
	HUD.AMMO_T = net.ReadInt(16)
end

--usermessage.Hook("up", Plinfo)

net.Receive("up", Plinfo)

function GM:Think()
end

local SPEC = {}
	  SPEC.STAGE = nil
	  SPEC.ENT   = nil
	  SPEC.POS = Vector(0,0,0)
	  SPEC.CUR = CurTime()

function STAGE(st)
	SPEC.STAGE = st
end

function ready()
	if IsValid(LocalPlayer()) && LocalPlayer():Alive() then
		RunConsoleCommand("ready")
		ready_removed = true
		hook.Remove( "Think", "READY" )
	end
end

hook.Add("Think", "READY", ready)

local FILM_POS = nil
local FILM_ENT = nil

function GM:CalcView(ply, origin, angles, fov)
	if GetConVarNumber( "df_film") == 1 then
		local trace = {}
		trace.start = origin
		trace.endpos = origin + (ply:GetAimVector() * 20000)
		trace.filter = ply
		local tr = util.TraceLine(trace)
		if IsValid(FILM_ENT) then
			FILM_POS = FILM_ENT:GetPos()
		end
		if ply:KeyDown(IN_USE) && !FILM_POS then
			if IsValid(tr.Entity) && tr.Entity:GetClass() == "plane" then
				FILM_ENT = tr.Entity
				FILM_POS = FILM_ENT:GetPos()
			else
				FILM_POS = tr.HitPos
			end
		elseif !ply:KeyDown(IN_USE) then
			FILM_POS = nil
			FILM_ENT = nil
		end
		if FILM_POS then
			local aim = FILM_POS - origin
			aim:Normalize()
			ply:SetEyeAngles(aim:Angle())
			local view = {}
			view.origin = origin
			view.angles = aim:Angle()
			return view
		end
	end
	if SPEC.STAGE then
		if SPEC.STAGE == 1 then
			if IsValid(LocalPlayer().plane) then
				--timer.Simple(0.5,STAGE,2)
				timer.Simple(0.5, function() STAGE(2) end)
			end
			local aim = HUD.PLANE_POS - SPEC.POS
			aim:Normalize()
			local view = {}
			view.origin = SPEC.POS
			view.angles = aim:Angle()
			return view
		end
		if SPEC.STAGE == 2 then
			local ENT = SPEC.ENT
			if IsValid(ENT) then
				SPEC.STAGE = nil
			end
			if ENT:GetClass() == "player" then
				ENT = ENT:GetNWEntity("plane")
			end
			if IsValid(ENT) then
				SPEC.STAGE = nil
			else
				local pln_pos = ENT:GetPos()
				local aim = ENT:GetPos() - SPEC.POS
				local aim_ang = aim:Angle()
				if pln_pos:Distance(SPEC.POS) > 200 then
					SPEC.POS = SPEC.POS + aim_ang:Forward() * 100
				else
					SPEC.STAGE = 3
					SPEC.CUR = CurTime()
				end
				local view = {}
				view.origin = SPEC.POS
				view.angles = aim_ang
				return view
			end
		end
		if SPEC.STAGE == 3 then
			if SPEC.CUR + 3 <= CurTime() then
				SPEC.STAGE = 4
			end
		end
		if SPEC.STAGE == 4 then
			local ENT = SPEC.ENT
			if IsValid(ENT) then
				SPEC.STAGE = nil
			else
				if IsValid(ENT) and ENT:GetClass() == "player" then
					ENT = ENT:GetNWEntity("plane")
				end
			end
			if !IsValid(ENT) then
				local all = ents.FindByClass("plane")
				if #all == 0 then return end
				SPEC.ENT = all[math.random(1,#all)]
			else
				local pln_pos = ENT:GetPos()
				local aim = ENT:GetPos() - SPEC.POS
				local aim_ang = aim:Angle()
				local dist = pln_pos:Distance(SPEC.POS)
				if dist > 250 then
					math.Clamp((2000 - dist) / 10, 10, 100)
					SPEC.POS = SPEC.POS + aim_ang:Forward() * 10
				end
				local view = {}
				view.origin = SPEC.POS
				view.angles = aim_ang
				return view
			end
		end
	elseif IsValid(LocalPlayer().plane) then
		if GetConVarNumber( "df_thirdperson" ) == 1 then
			local view = {}
			view.origin = HUD.PLANE_POS + (LocalPlayer():GetAimVector() * -300)
			view.angles = angles
			return view
		elseif GetConVarNumber( "df_forward") == 1 && IsValid(LocalPlayer().plane) then
			local view = {}
			view.origin = LocalPlayer().plane:GetPos() + (LocalPlayer().plane:GetUp() * 32) + LocalPlayer().plane:GetForward() * 2
			local ang = (LocalPlayer().plane:GetForward()) + LocalPlayer().plane:GetUp() * -0.1
			ang = ang:Angle()
			view.angles = ang
			return view
		else
			local view = {}
			view.origin = LocalPlayer().plane:GetPos() + (LocalPlayer().plane:GetUp() * 32) + LocalPlayer().plane:GetForward() * 2
			view.angles = angles
			return view
		end
	end
end

local HIDE = {
	CHudHealth    = true,
	CHudBattery   = true,
	CHudCrosshair = true,
}

function huddraw(name)
	if ( HIDE[ name ] ) then
		return false
	end
	if GetConVarNumber( "df_film" ) == 1 then
		if name == "CHudChat" || name == "CHudGMod" then
			return false
		end
	end
	if (SPEC.STAGE && SPEC.STAGE < 4) then
		if name == "CHudChat" then
			return false
		end
	end
end

hook.Add("HUDShouldDraw", "HUD", huddraw)

function GM:RenderScreenspaceEffects()
	if SPEC.STAGE == 3 then
		DrawMotionBlur( 0,1,0.5 )
	end
end

function StartSpec(length, client)
	SPEC.STAGE = 1
	SPEC.ENT   = net.ReadEntity()
	SPEC.POS   = HUD.PLANE_POS
	SPEC.CUR   = CurTime()
end

--usermessage.Hook("spec", StartSpec)

net.Receive("spec", StartSpec)

function EndSpec(length, client)
	SPEC.STAGE = nil
	SPEC.ENT   = nil
	SPEC.POS = Vector(0,0,0)
	SPEC.CUR = CurTime()
end

--usermessage.Hook("stop_spec", EndSpec)

net.Receive("stop_spec", EndSpec)

function StartNormalSpec(length, client)
	local all = ents.FindByClass("plane")
	if #all == 0 then return end
	SPEC.STAGE = 4
	SPEC.ENT   = all[math.random(1,#all)]
	SPEC.POS   = HUD.PLANE_POS
	SPEC.CUR   = CurTime()
end

--usermessage.Hook("norm_spec", StartNormalSpec)

net.Receive("norm_spec", StartNormalSpec)

--[[
local CHAT_OPEN = false
local CHAT_TEXT = ""

function GM:ChatTextChanged(txt)
	if string.len(txt) <= 70 then
		CHAT_TEXT = txt
	end
end

function GM:StartChat()
	CHAT_OPEN = true
	return true
end

function GM:FinishChat()
	CHAT_OPEN = false
	return true
end


function GM:ChatText(id, name, text, type)
	local add = text
	local chat = false
	if name != "Console" then
		add = name..": "..text
		chat = true
		if GetConVarNumber("df_chatbeep") == 1 && name != LocalPlayer():Nick() then
			surface.PlaySound("buttons/blip1.wav")
		end
	end
	print("[CHAT] "..add)
	AddMessage(nil, add, chat)
end
]]--
function GM:OnSpawnMenuClose( )
	RunConsoleCommand("-roll_l")
end

function GM:OnSpawnMenuOpen( )
	RunConsoleCommand("+roll_l")
end

MSGS = {}

local LastFlash = CurTime()
local Dmg_red = true

function AddMessage(um, ovrde, chat)
	local W = ScrW()
	local H = ScrH()
	local txt = ""
	if !um then
		txt = ovrde
	else
		txt = net.ReadString()
		chat = net.ReadBit()
	end
	LocalPlayer():ChatPrint(txt)
	return
end
--[[
	local col = Color(255,255,255,255)
	if !chat then
		col = Color(255,50,50,255)
	end
	surface.SetFont("message")
	if surface.GetTextSize( txt ) >= W * 0.26 then
		local txt1 = string.sub(txt,1,37)
		local txt2 = string.sub(txt,38,85)
		local t = {}
		t.txt = txt1
		t.cur = CurTime()
		t.alp = 255
		t.col = col
		table.insert(MSGS,1, t)
		local t = {}
		t.txt = txt2
		t.cur = CurTime()
		t.alp = 255
		t.col = col
		table.insert(MSGS,1, t)
	else
		local t = {}
		t.txt = txt
		t.cur = CurTime()
		t.alp = 255
		t.col = col
		table.insert(MSGS,1, t)
	end
	if #MSGS >= 30 then
		table.remove(MSGS, #MSGS)
	end
end
]]--

--usermessage.Hook("message", AddMessage)

net.Receive("message", AddMessage)

function Help()
	vgui.Create("df_menu")
end

--usermessage.Hook("help", Help)

net.Receive("help", Help)

function Ammo(length, client)
	local ammo = net.ReadInt(32)
	PLANE.MAX_AMMO = ammo
end

--usermessage.Hook("update_ammo", Ammo)

net.Receive("update_ammo", Ammo)

function NextSpawn(length, client)
	LocalPlayer().NextSpawn = net.ReadInt(32)
end

--usermessage.Hook("nextspawn", NextSpawn)

net.Receive("nextspawn", NextSpawn)

function GetFlags(length, client)
	LocalPlayer().Flags = net.ReadString()
	print("FLAGS LOADED", LocalPlayer().Flags)
end

--usermessage.Hook("sendflags", GetFlags)

net.Receive("sendflags", GetFlags)

local HT = 0
local M_alpha = 200

function GM:DoNotifyBox()
	local W = ScrW()
	local H = ScrH()
	local TGT_HT = 10 + (18 * #MSGS)
	if TGT_HT > HT then
		HT = TGT_HT
	elseif TGT_HT < HT then
		local rate = (HT - TGT_HT) / 10
		HT = math.Approach(HT, TGT_HT, 0.5)
	end
	if #MSGS == 0 then
		M_alpha = math.Approach(M_alpha, 0, 1)
	end
	if CHAT_OPEN || #MSGS > 0 then
		M_alpha = math.Approach(M_alpha, 200, 2)
	end
	local max_h = 100
	draw.SimpleText( "Messages", "TID", W * 0.05 + W * 0.2, (H * 0.6) + max_h - HT - 18 , Color(255,255,255,M_alpha) )
	surface.SetDrawColor(30,30,100,M_alpha)
	surface.DrawRect(W * 0.05, (H * 0.6) - HT + max_h, W * 0.27 , HT)
	surface.SetDrawColor(0,0,0,M_alpha)
	surface.DrawOutlinedRect(W * 0.05, (H * 0.6) - HT + max_h, W * 0.27 , HT)
	if CHAT_OPEN then
		surface.SetFont("message")
		local C_HT = 20
		local C_TXT = CHAT_TEXT
		if surface.GetTextSize( "Say: "..CHAT_TEXT ) >= W * 0.26 then
			local len = string.len(CHAT_TEXT)
			C_TXT = string.sub(CHAT_TEXT,44 - len, len)
		end
		surface.SetDrawColor(0,0,0,200)
		surface.DrawOutlinedRect(W * 0.05, (H * 0.6) - 20 + max_h + 20, W * 0.27 , C_HT)
		surface.SetDrawColor(0,0,0,200)
		surface.DrawOutlinedRect(W * 0.05, (H * 0.6) - 20 + max_h + 20, W * 0.27 , C_HT)
		draw.SimpleText( "Say: "..C_TXT, "message", W * 0.05 + 5, (H * 0.6) + max_h + 2, Color(255,255,255,255) )
	end
	for k,v in pairs(MSGS) do
		if CurTime() - v.cur >= 10 then
			v.alp = v.alp - 1
		end
		if v.alp <= 0 then
			table.remove(MSGS, k)
		end
		draw.SimpleText( v.txt, "message", W * 0.052, (H * 0.6) + max_h - (k * 18) , Color(v.col.r,v.col.g,v.col.b,v.alp), 0 )
	end
end

local tex = surface.GetTextureID("DFHUD/crosshair2")

local CRS = 24

LOADED = false

function GM:DrawFreezeCamHUD(W,H)
	local ent = SPEC.ENT
	local name = ""
	if ent:GetClass() == "player" then
		name = ent:Nick()
	else
		name = "Flak Cannon"
	end
	name = string.upper(name)
	draw.SimpleText( "YOU WERE KILLED BY "..name, "TID", W / 2, H * 0.75, Color(255,50,50,255), 1,1)
end

function GM:DrawPlaneHUD(W,H)
	--DAMAGE BAR
	surface.SetDrawColor(255,50,50,200)
	local ht = math.floor(math.Clamp(HUD.DAMAGE,0,PLANE.MAX_DAMAGE))
	if HUD.DAMAGE >= 80 then
		if LastFlash + 1 <= CurTime() then
			Dmg_red = not Dmg_red
			LastFlash = CurTime()
		end
		if Dmg_red then
			surface.SetDrawColor(255,50,50,200)
		else
			surface.SetDrawColor(255,0,0,200)
		end
	end
	surface.DrawRect(W * 0.1, H * 0.8 - ht + 100, W * 0.04, ht)
	surface.SetDrawColor(0,0,0,255)
	surface.DrawOutlinedRect(W * 0.1, H * 0.8, W * 0.04, 100)
	draw.SimpleText( "DAMAGE", "Hud Lab", W * 0.107, H * 0.93, Color(255,255,255,255) )
	draw.SimpleText( math.floor(HUD.DAMAGE), "TID", W * 0.12, H * 0.85, Color(255,255,255,255), 1, 1 )
	--THROTTLE BAR
	local ht = math.Clamp(HUD.SPEED * 2,0,PLANE.MAX_SPEED * 2)
	surface.SetDrawColor(100,255,100,200)
	surface.DrawRect(W * 0.05, H * 0.8 - ht + 100, W * 0.04, ht)
	surface.SetDrawColor(0,0,0,255)
	surface.DrawOutlinedRect(W * 0.05, H * 0.8, W * 0.04, 100)
	draw.SimpleText( "THROTTLE", "Hud Lab", W * 0.054, H * 0.93, Color(255,255,255,255) )
	draw.SimpleText( math.floor(HUD.SPEED), "TID", W * 0.07, H * 0.85, Color(255,255,255,255), 1, 1 )
	--SPEED
	local vel = Vector(0,0,0)
	local vel_X = Vector(0,0,0)
	if IsValid(LocalPlayer().plane) then
		vel = LocalPlayer().plane:GetVelocity()
		vel_X = LocalPlayer().plane:WorldToLocal(LocalPlayer().plane:GetVelocity()+LocalPlayer().plane:GetPos()) -- thanks wiremod
	end
	local ht = math.Clamp((vel.z / -500) * 100,-50,50)
	local ht_x = math.floor(math.Clamp((vel_X.x / 1500) * 100, 0,100))
	surface.SetDrawColor(50,50,255,200)
	surface.DrawRect(W * 0.2, H * 0.8 - ht_x + 100, W * 0.04, ht_x)
	surface.SetDrawColor(255,0,0,255)
	if vel.z > 0 then
		surface.SetDrawColor(0,255,0,255)
	end
	surface.DrawRect(W * 0.2, (H * 0.8) + 50 + ht - H * 0.00025, W * 0.04, H * 0.005)
	surface.SetDrawColor(0,0,0,255)
	surface.DrawOutlinedRect(W * 0.2, H * 0.8, W * 0.04, 100)
	surface.DrawLine( W * 0.2, H * 0.8 + 50, W * 0.2 + W * 0.04, H * 0.8 + 50 )
	draw.SimpleText( "SPEED", "Hud Lab", W * 0.21, H * 0.93, Color(255,255,255,255) )
	draw.SimpleText( math.floor(vel_X.x / 17.6) * 2, "TID", W * 0.22, H * 0.85, Color(255,255,255,255), 1, 1 )
	--AMMO BAR
	local am = math.floor(HUD.AMMO / PLANE.MAX_AMMO * 100)
	local ht = math.Clamp(am,0,100)
	surface.SetDrawColor(221,255,0,200)
	surface.DrawRect(W * 0.15, H * 0.8 - ht + 100, W * 0.04, ht)
	surface.SetDrawColor(0,0,0,255)
	surface.DrawOutlinedRect(W * 0.15, H * 0.8, W * 0.04, 100)
	draw.SimpleText( "AMMO", "Hud Lab", W * 0.159, H * 0.93, Color(255,255,255,255) )
	draw.SimpleText( HUD.AMMO, "TID", W * 0.17, H * 0.85, Color(255,255,255,255), 1, 1 )
	--ALTITUDE REAPER
	local altitude = 0
	if IsValid(LocalPlayer().plane) then
		local pl = LocalPlayer().plane
		local ipos = pl:GetPos()
		local traceup = util.TraceLine({
	 					start = ipos,
	 					endpos = ipos+Vector(0,0,102400),
	 					filter = pl,
						mask = (MASK_NPCWORLDSTATIC || MASK_WATER )
	 				  })
		local tracedn = util.TraceLine({
	 					start = ipos,
	 					endpos = ipos-Vector(0,0,102400),
	 					filter = pl,
						mask = ( MASK_NPCWORLDSTATIC || MASK_WATER )
	 				  })
		altitude = ipos.z -tracedn.HitPos.z
		local max = traceup.HitPos.z - tracedn.HitPos.z
		altitude = math.Round(altitude)
		max = math.Round(max)
		local x = math.Round((altitude / max) *100)
		local x2 = altitude - math.floor(altitude/1000)*1000
		x2 = math.Round((x2/1000)*100)
		surface.SetDrawColor(255,100,255,200)
		surface.DrawRect(W * 0.25, H * 0.8 - x + 100, W * 0.035, x)
		surface.DrawRect(W * 0.285, H * 0.8 - x2 + 100, W * 0.005, x2)
	end
	surface.SetDrawColor(0,0,0,255)
	surface.DrawOutlinedRect(W * 0.25, H * 0.8, W * 0.035, 100)
	surface.DrawOutlinedRect(W * 0.25, H * 0.8, W * 0.04, 100)
	draw.SimpleText( "ALTITUDE", "Hud Lab", W * 0.25, H * 0.93, Color(255,255,255,255) )
	draw.SimpleText( math.floor(altitude/10) .."", "TID", W * 0.27, H * 0.85, Color(255,255,255,255), 1, 1 )
end

function GM:DrawTopBar(W,H)
	local team_col = team.GetColor(LocalPlayer():Team())
	surface.SetDrawColor(team_col)
	surface.DrawRect(0, 0, W, H * 0.03)
	surface.SetDrawColor(Color(0,0,0,255))
	surface.DrawOutlinedRect(0, 0, W, H * 0.03)
	local ns = LocalPlayer().NextSpawn or CurTime() + SPAWN_TIME
	local timeleft = math.ceil(math.Clamp(ns - CurTime(), 0, 30))
	local text = ""
	if !LocalPlayer():Alive() then
		if timeleft <= 0 then
			text = "Press Mouse1 to spawn"
		else
			text = "You will spawn in "..timeleft.." seconds."
		end
		if team_col == Color(255,255,255,255) then
			draw.SimpleTextOutlined( text, "TID", W * 0.5, H * 0.01, Color(0,0,0,255),1,1, 1, Color(255,255,255,255))
		else
			draw.SimpleText( text, "TID", W * 0.5, H * 0.01, Color(255,255,255,255),1,1)
		end
	else
		if type(HELP_TEXT) == "string" then
			text = HELP_TEXT
			draw.SimpleTextOutlined( text, "TID", W * 0.5, H * 0.01, Color(0,0,0,255),1,1, 1, Color(255,255,255,255))
		else
			text = HELP_TEXT[LocalPlayer():Team()]
			draw.SimpleText( text, "TID", W * 0.5, H * 0.01, Color(255,255,255,255),1,1)
		end
	end
end

function GM:DrawESP(W,H)
	local All_planes = ents.FindByClass("plane")
	for k,v in pairs(All_planes) do
		local ply = v:GetNWEntity("ply")
		if IsValid(ply) then
			local Nick = ply:Nick()
			local teamcol = team.GetColor(ply:Team())
			if ply != LocalPlayer() && ply:Team() == LocalPlayer():Team() then
				local pos = v:GetPos()
				if LOADED then
					local dist = pos:Distance(HUD.PLANE_POS)
					local size = math.Clamp((20000 - dist) / 300,0,100)
					local scr = pos:ToScreen()
					if size >= 10 then
						if size >= 45 then
							local health = math.Clamp(100 - v:GetNWInt("dmg",0),0,PLANE.MAX_DAMAGE)
							surface.SetDrawColor(50,255,50,200)
							surface.DrawRect(scr.x - (size / 2) , scr.y - (size / 2), (health / 100) * size, size / 20)
							surface.SetDrawColor(0,0,0,255)
							surface.DrawOutlinedRect( scr.x - (size / 2), scr.y - (size / 2), size, size / 20 )
						end
						draw.SimpleText( Nick, "TID",scr.x, scr.y + (size / 2) -10, teamcol,1,1 )
						surface.SetDrawColor(0,0,0,255)
						surface.DrawOutlinedRect( scr.x - (size / 2), scr.y - (size / 2), size, size )
					end
				end
			end
		end
	end
end

function GM:HUDPaint()
	self:UpdateValues()
	local W = ScrW()
	local H = ScrH()
	local editspawns = (GetConVarNumber( "df_editspawns" )==1)
	if SPEC.STAGE && SPEC.STAGE == 3 and !editspawns then
		self:DrawFreezeCamHUD(W,H)
	end
	if (SPEC.STAGE && SPEC.STAGE >= 4) || !SPEC.STAGE and !editspawns then
			--self:DoNotifyBox()
			if IsValid(LocalPlayer().plane) && !SPEC.STAGE then
				local pos = HUD.PLANE_POS + LocalPlayer().plane:GetForward() * 1000 + LocalPlayer().plane:GetUp() * 20
				local pos = pos:ToScreen()
				surface.SetTexture(tex)
				surface.SetDrawColor(255,255,255,255)
				surface.DrawTexturedRect( pos.x - CRS / 2, pos.y - CRS / 2, CRS, CRS )
				LOADED = true
			elseif !LOADED then
				draw.SimpleText( "LOADING", "TID",W / 2, H / 2 , Color(255,255,255,255),1,1 )
			end
		self:DrawTopBar(W,H)
		self:DrawGameHUD(W,H)
		self:DrawKillMessages()
		self:DrawMoney()
		if LOADED then
			self:DrawESP(W,H)
			self:DrawPlaneHUD(W,H)
		end
	end
	if editspawns then
		self:DrawSpawnEditor(W,H)
	end
end

local K_MSG = {}

function KillMessage(length, client)
	local typ = net.ReadInt(16)
	local tem = net.ReadInt(16)
	local txt = net.ReadString()
	local ico = net.ReadString()
	print(txt)
	local t = {}
	t.cur = CurTime()
	t.txt = txt
	t.type = typ
	t.tem = tem
	t.alp = 255
	t.speed = 20
	if typ == KILL_TYPE_KILL then
		t.ico = "gun"
	else
		t.ico = "suicide"
	end
	table.insert(K_MSG, 1, t)
end

--usermessage.Hook("killmsg", KillMessage)

net.Receive("killmsg", KillMessage)

function GM:DrawKillMessages()
	local W = ScrW()
	local H = ScrH()
	for k,v in pairs(K_MSG) do
		local c = team.GetColor(v.tem)
		local x = W * 0.95
		local y = H * 0.9 - (k * 28)
		local w,h = killicon.GetSize( v.ico )
		draw.SimpleTextOutlined(v.txt, "TID", x - (w/2) - 16, y, Color(c.r,c.g,c.b,v.alp) , TEXT_ALIGN_RIGHT, 0, 2, Color(0,0,0,v.alp))
		killicon.Draw( x, y, v.ico, v.alp )
		if CurTime() - v.cur > 5 then
			v.alp = v.alp - 1
			if v.alp <= 0 then
				table.remove(K_MSG, k)
			end
		end
	end
end

local M_MSG = {}

function MoneyMessage(txt, col)
	col = string.Explode(" ", col)
	local t = {}
	t.txt = txt
	t.col = Color(col[1],col[2],col[3],255)
	t.alp = 255
	t.x = 20
	table.insert(M_MSG, 1, t)
end

--usermessage.Hook("monmsg", MoneyMessage)

net.Receive("monmsg", function() 
	local txt = net.ReadString()
	local col = net.ReadString()
	MoneyMessage(txt,col)
end)

function GM:DrawMoney()
	local W = ScrW()
	local H = ScrH()
	local msg = M_MSG[#M_MSG]
	local col = Color(255,255,255,255)
	local x = W * 0.1
	local y = H * 0.96
	surface.SetDrawColor(50,50,50,255)
	surface.DrawRect(W * 0.045 , H * 0.945, W * 0.25, H * 0.03)
	surface.SetDrawColor(0,0,0,255)
	surface.DrawOutlinedRect(W * 0.045 , H * 0.945, W * 0.25, H * 0.03)
	if msg then
		col = Color(msg.col.r, msg.col.g,msg.col.b, msg.alp)
		draw.SimpleTextOutlined(msg.txt, "TID", x + msg.x, y, col , TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 2, Color(0,0,0,msg.alp))
		msg.x = msg.x + (msg.x^2 / 5000)
		if msg.x >= W + 200 then
			table.remove(M_MSG, #M_MSG)
		end
	end
	draw.SimpleText("MONEY: "..LocalPlayer():GetNWInt("money",0), "TID", W * 0.05,y, col, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

function GM:DrawGameHUD(W,H)

end

idc_spawns = idc_spawns or {}
gbu_spawns = gbu_spawns or {}
ffa_spawns = ffa_spawns or {}
idc_spawns_props = idc_spawns_props or {}
gbu_spawns_props = gbu_spawns_props or {}
ffa_spawns_props = ffa_spawns_props or {}


function GM:DrawSpawnEditor(W,H)
	if table.Count(idc_spawns_props)>0 then
		for k,v in pairs(idc_spawns_props) do
			local pos = v:GetPos()
			local dist = pos:Distance(LocalPlayer():GetPos())
			local size = math.Clamp((20000 - dist) / 300,0,100)
			local scr = pos:ToScreen()
			draw.SimpleTextOutlined( "IDC Spawn", "TID", scr.x, scr.y + (size / 2) - 10 , Color( 255, 0, 0, 255 ), 1, 1, 2, Color(0,0,0,255) )
			draw.SimpleTextOutlined( "Pos: ["..tostring(v:GetPos()).."]", "TID", scr.x, scr.y + (size / 2) + 10, Color( 255, 0, 0, 255 ), 1, 1, 2, Color(0,0,0,255) )
			draw.SimpleTextOutlined( "Ang: ["..tostring(v:GetAngles()).."]", "TID", scr.x, scr.y + (size / 2) + 30, Color( 255, 0, 0, 255 ), 1, 1, 2, Color(0,0,0,255) )
		end
	end
	if table.Count(gbu_spawns_props)>0 then
		for k,v in pairs(gbu_spawns_props) do
			local pos = v:GetPos()
			local dist = pos:Distance(LocalPlayer():GetPos())
			local size = math.Clamp((20000 - dist) / 300,0,100)
			local scr = pos:ToScreen()

			draw.SimpleTextOutlined( "GBU Spawn", "TID", scr.x, scr.y + (size / 2) - 10 , Color( 255, 0, 0, 255 ), 1, 1, 2, Color(0,0,0,255) )
			draw.SimpleTextOutlined( "Pos: ["..tostring(v:GetPos()).."]", "TID", scr.x, scr.y + (size / 2) + 10, Color( 255, 0, 0, 255 ), 1, 1, 2, Color(0,0,0,255) )
			draw.SimpleTextOutlined( "Ang: ["..tostring(v:GetAngles()).."]", "TID", scr.x, scr.y + (size / 2) + 30, Color( 255, 0, 0, 255 ), 1, 1, 2, Color(0,0,0,255) )
		end
	end
	if table.Count(ffa_spawns_props)>0 then
		for k,v in pairs(ffa_spawns_props) do
			local pos = v:GetPos()
			local dist = pos:Distance(LocalPlayer():GetPos())
			local size = math.Clamp((20000 - dist) / 300,0,100)
			local scr = pos:ToScreen()
			if dist < 2000 then
				draw.SimpleTextOutlined( "FFA Spawn", "TID", scr.x, scr.y + (size / 2) - 10 , Color( 255, 0, 0, 255 ), 1, 1, 2, Color(0,0,0,255) )
				draw.SimpleTextOutlined( "Pos: ["..tostring(v:GetPos()).."]", "TID", scr.x, scr.y + (size / 2) + 10, Color( 255, 0, 0, 255 ), 1, 1, 2, Color(0,0,0,255) )
				draw.SimpleTextOutlined( "Ang: ["..tostring(v:GetAngles()).."]", "TID", scr.x, scr.y + (size / 2) + 30, Color( 255, 0, 0, 255 ), 1, 1, 2, Color(0,0,0,255) )
				draw.SimpleTextOutlined( "Dist: ["..tostring(dist).."]", "TID", scr.x, scr.y + (size / 2) + 50, Color( 255, 0, 0, 255 ), 1, 1, 2, Color(0,0,0,255) )
			end
		end
	end
end

function CheckSpawnEditor(enable,clear)
	if !IsValid(LocalPlayer()) or LocalPlayer()==nil then return end
	if clear then
		local removed = 0
		if table.Count(idc_spawns_props)>0 then
			for k,v in pairs(idc_spawns_props) do
				v:Remove()
				table.remove(idc_spawns_props,k)
				removed = removed+1
			end
		end
		if table.Count(gbu_spawns_props)>0 then
			for k,v in pairs(gbu_spawns_props) do
				v:Remove()
				table.remove(gbu_spawns_props,k)
				removed = removed+1
			end
		end
		if table.Count(ffa_spawns_props)>0 then
			for k,v in pairs(ffa_spawns_props) do
				v:Remove()
				table.remove(ffa_spawns_props,k)
				removed = removed+1
			end
		end
		LocalPlayer():ChatPrint("Cleared "..removed.." props!")
	end
	if !LocalPlayer():IsAdmin() or !LocalPlayer():IsSuperAdmin() then
		RunConsoleCommand("df_editspawns", "0")
		LocalPlayer():ChatPrint("Did not pass admin check")
		return
	end
	if enable == true then
		LocalPlayer():ConCommand("getspawns")
	end
end

net.Receive("spawnpointeditor", function() 
	local enable = tobool(net.ReadBit())
	local clear = tobool(net.ReadBit())
	CheckSpawnEditor(enable,clear)
end)

function SpawnpointEditorToggle(tbl)
	if !IsValid(LocalPlayer()) or LocalPlayer()==nil then return end

	LocalPlayer():ChatPrint("Spawning props for editor")

	if table.Count(tbl) > 0 then
		for k,v in pairs(tbl) do
			if k=="idc" then
				if table.Count(v) > 0 then
					table.insert(idc_spawns,v)
				end
			elseif k=="gbu" then
				if table.Count(v) > 0 then
					table.insert(gbu_spawns,v)
				end
			elseif k=="ffa" then
				if table.Count(v) > 0 then
					table.insert(ffa_spawns,v)
				end
			end
		end
	end

	if table.Count(idc_spawns)>0 then
		for k,v in pairs(idc_spawns) do
			for key, data in pairs(v) do
				local Location = data.vec
				local Angle = data.ang
				local spawn = ents.CreateClientProp()
				table.insert(idc_spawns_props,spawn)
				spawn:SetPos( Location )
				spawn:SetAngles( Angle )
				spawn:SetModel("models/Bennyg/plane/re_airboat2.mdl")
				spawn:Spawn()
			end
		end
	end
	
	if table.Count(gbu_spawns)>0 then
		for k,v in pairs(gbu_spawns) do
			for key, data in pairs(v) do
				local Location = data.vec
				local Angle = data.ang
				local spawn = ents.CreateClientProp()
				table.insert(gbu_spawns_props,spawn)
				spawn:SetPos( Location )
				spawn:SetAngles( Angle )
				spawn:SetModel("models/Bennyg/plane/re_airboat2.mdl")
				spawn:Spawn()
			end
		end
	end
	
	if table.Count(ffa_spawns)>0 then
		for k,v in pairs(ffa_spawns) do
			for key, data in pairs(v) do
				local Location = data.vec
				local Angle = data.ang
				local spawn = ents.CreateClientProp()
				table.insert(ffa_spawns_props,spawn)
				spawn:SetPos( Location )
				spawn:SetAngles( Angle )
				spawn:SetModel("models/Bennyg/plane/re_airboat2.mdl")
				spawn:Spawn()
			end
		end
	end
end

net.Receive("sendspawns", function() 
	local spawns = net.ReadTable()
	SpawnpointEditorToggle(spawns)
end)