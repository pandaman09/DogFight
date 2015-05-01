local function GetPlane() return nil end

include("shared.lua")
include("cl_tips.lua")
include("vgui/vgui_rockets.lua")
include("vgui/vgui_powerup.lua")

include("cl_help.lua")
include("cl_selectscreen.lua")

CreateClientConVar( "df_cammove", 5, true, false)
CreateClientConVar( "df_camdist", 200, true, false)
CreateClientConVar( "df_showtrails", 1, true, false)
CreateClientConVar( "df_treedense", 3, true, false)
CreateClientConVar( "df_xbox", 0, true, false) //experimental controls that auto center

CreateClientConVar( "df_inverse", 0, true, true) //Y axis should reverse? Buggy as hell

local cross_tex = surface.GetTextureID("DFHUD/crosshair2")
local alt_tex = surface.GetTextureID("DFHUD/alt_meter2")
local alt_tex_arrow = surface.GetTextureID("DFHUD/alt_meter_arrow_small")
local airspeed_tex = surface.GetTextureID("DFHUD/airspeed_meter2")
local power_tex = surface.GetTextureID("DFHUD/powerup_meter")

local fuel_stat_tex = surface.GetTextureID("DFHUD/fuel_status")
local fuel_warning_mat = Material("DFHUD/fuel_status_warning")
local fuel_ok_mat = Material("DFHUD/fuel_status_ok")
local fuel_wait_mat = Material("DFHUD/fuel_status_waiting")

local rocket_arrow_red = surface.GetTextureID("DFHUD/rocket_arrow_red")
local rocket_arrow_blue = surface.GetTextureID("DFHUD/rocket_arrow_blue")

local W = ScrW()
local H = ScrH()

local boost_start = 0

local default_camera_distance = 200
local camera_distance = 200
local target_camera_distance = 200

camera_free_movement = false

local SettingsPanel = nil

function GM:Initialize()
	--surface.CreateFont("akbar",25,400,false,false,"plane_hud")
	surface.CreateFont( "plane_hu", {
		font = "akbar",
		size = 25,
		weight = 400,
		blursize = 0,
		scanlines = 0,
		antialias = false,
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = false,
		additive = false,
		outline = false,
	} )
	--surface.CreateFont( "coolvetica", 30, 500, true, false, "rocket_nums" )
	surface.CreateFont( "rocket_nums", {
		font = "coolvetica",
		size = 30,
		weight = 500,
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
	camera_distance = GetConVarNumber("df_camdist")
	local rocket = vgui.Create("RocketIcon")
	rocket:SetTeam(TEAM_RED)
	local rocket = vgui.Create("RocketIcon")
	rocket:SetTeam(TEAM_BLUE)
	self.DrawHud = true
end

function GM:CreateScoreboard( ScoreBoard )

	ScoreBoard:ParentToHUD()
	
	ScoreBoard:SetRowHeight( 32 )

	ScoreBoard:SetAsBullshitTeam( TEAM_SPECTATOR )
	ScoreBoard:SetAsBullshitTeam( TEAM_CONNECTING )
	ScoreBoard:SetShowScoreboardHeaders( GAMEMODE.TeamBased )
	
	if ( GAMEMODE.TeamBased ) then
		ScoreBoard:SetAsBullshitTeam( TEAM_UNASSIGNED )
		ScoreBoard:SetHorizontal( true )	
	end

	ScoreBoard:SetSkin( GAMEMODE.HudSkin )

	self:AddScoreboardAvatar( ScoreBoard )		// 1
	self:AddScoreboardWantsChange( ScoreBoard )	// 2
	self:AddScoreboardName( ScoreBoard )		// 3
	self:AddScoreboardScore( ScoreBoard ) 		// 4
	self:AddScoreboardKills( ScoreBoard )		// 5
	self:AddScoreboardDeaths( ScoreBoard )		// 6
	self:AddScoreboardPing( ScoreBoard )		// 7
		
	// Here we soort by these columns (and descending), in this order. You can define up to 4
	ScoreBoard:SetSortColumns( { 4, true, 5, true, 6, false, 3, true} )

end

function GM:AddScoreboardScore( ScoreBoard )

	local f = function( ply ) return ply:GetMainScore() end
	ScoreBoard:AddColumn( "Score", 50, f, 0.1, nil, 6, 6 )

end

function GM:HUDPaint()
	if self.DrawHud then
		local pln = LocalPlayer():GetPlane()
		if GetConVarNumber("cl_drawhud") != 0 then
			if IsValid(pln) then
				self:DrawPlaneHUD()
			end
			self:DrawCenterMessages()
		end
	end
	self.BaseClass:HUDPaint()
end

local shake_factor = 0
local shake_speed = 550

local cam_roll = 0

function DoPlaneCam(ply,origin,angles,fov)
	local plane = ply:GetPlane();
	local view = {}
	//view.fov = 60
	view.origin = origin
	view.angles = angles
	if !IsValid(plane) then return view end;
	
	if camera_free_movement then
		view.origin = plane:GetPos() + (angles:Forward() * -camera_distance)
		view.angles = angles
		return view
	else
		local ang_plane = plane:GetAngles();
		ang_plane.p = math.NormalizeAngle(ply:GetPlane():GetAngles().p);
		ang_plane.y = math.NormalizeAngle(ply:GetPlane():GetAngles().y);
		ang_plane.r = math.NormalizeAngle(ply:GetPlane():GetAngles().r);
		local p_diff = math.NormalizeAngle(angles.p - ang_plane.p)
		local y_diff = math.NormalizeAngle(angles.y - ang_plane.y)
		local move = 1 + (GetConVarNumber( "df_cammove" ) * 0.01)
		angles.y = angles.y - (y_diff * move)
		angles.p = angles.p - (p_diff * move)
		if plane:GetVelocity():Length() > shake_speed then
			if plane.Wind_Sound then
				plane.Wind_Sound:Play()
			end
			plane.Wind_Sound:ChangeVolume(shake_factor * 500,0)
			local new_shake = math.Clamp(plane:GetVelocity():Length() / 650,0,0.8)
			shake_factor = math.Approach(shake_factor, new_shake, 0.001)
		else
			if plane.Wind_Sound then
				plane.Wind_Sound:Stop()
			end
			shake_factor = math.Approach(shake_factor, 0, 0.01)
		end
		if math.abs(ang_plane.r) > 170 then cam_roll = math.Approach(cam_roll, 180, 5) else cam_roll = math.Approach(cam_roll, ang_plane.r * 0.3, 5) end
		angles.p = angles.p + math.Rand(-(shake_factor^2),shake_factor^2)
		angles.y = angles.y + math.Rand(-(shake_factor^2),shake_factor^2)
		angles.r = cam_roll
		view.angles = angles
		camera_distance = math.Approach(camera_distance, target_camera_distance + (plane:GetVelocity():Length() * 0.01) - 25, (target_camera_distance - camera_distance) * 0.05)
		view.origin = plane:GetPos() + (angles:Forward() * -camera_distance) + Vector(0,0,40);
		view.fov = 60
		return view
	end
end

local rocket_cam = false
local rocket_cam_end = 0
local rocket_cam_pos = Vector(0,0,0)
local rocket_cam_team = TEAM_RED

function calc(ply,origin,angles,fov)
	if !rocket_cam then
		if ply:KeyDown(IN_RELOAD) then
			return DoRearCam(ply,origin,angles,fov)
		else
			return DoPlaneCam(ply,origin,angles,fov)
		end
	else
		return DoRocketCam(ply,origin,angles,fov)
	end
end

hook.Add("CalcView", "dfcalc", calc)

function DoRearCam(ply,origin,angles,fov)
	local plane = ply:GetPlane()
	if !IsValid(plane) then return end
	local view = {}
	angles.y = plane:GetAngles().y + 180
	angles.p = plane:GetAngles().p
	angles.r = 0
	view.origin = plane:GetPos() + (plane:GetForward() * default_camera_distance)
	view.angles = (plane:GetPos() - view.origin):Angle()
	return view
end

function DoRocketCam(ply,origin,angles,fov)
	if rocket_cam_end < CurTime() then
		rocket_cam = false
		GAMEMODE.DrawHud = true
		return
	end
	
	local rocket = GAMEMODE:GetRocket(rocket_cam_team)
	if !IsValid(rocket) then return end // dunno why this would happen but er
	
	GAMEMODE.DrawHud = false
	local look_pos = rocket:GetPos() + rocket:GetUp() * 100
	local view = {}
	view.origin = rocket_cam_pos + Vector(0,0,100)
	view.angles = (look_pos - view.origin):Angle()
	view.fov = 60
	return view
end

function StartRocketCam(um)
	rocket_cam = true
	rocket_cam_team = um:ReadShort()
	rocket_cam_pos = um:ReadVector()
	rocket_cam_end = CurTime() + GAMEMODE.RoundPostLength
end

usermessage.Hook("df_startrocketcam", StartRocketCam)

local CRS = 32
local cross_size = 4

local missile_flash_change = 5
local missile_flash_yellow = 0

local fuel_warning_text = "WARNING!"
local fuel_friend_text = "DEFEND!"

local powerup_control = nil

function GM:DrawPlaneHUD()
	
	if !ValidPanel(powerup_control) then
		powerup_control = vgui.Create("PowerupElement")
	end
	
	//Crosshair
	if CRS < 24 then CRS = math.Approach(CRS, 24,0.1) end
	local plane = LocalPlayer():GetPlane()
	local pos = plane:GetPos() + plane:GetForward() * 1000 + plane:GetUp() * 10
	pos = pos:ToScreen()
	surface.SetTexture(cross_tex)
	surface.SetDrawColor(255,255,255,255)
	surface.DrawTexturedRect( pos.x - CRS / 2, pos.y - CRS / 2, CRS, CRS )
	
	local entz = {}
	for k,v in pairs(ents.FindByClass("df_plane")) do
		if v:GetPos():Distance(plane:GetPos()) < 4000 and v != plane and !v:GetCloaked() then
			local ts = v:GetPos():ToScreen()
			local vts = Vector(ts.x,ts.y,0)
			if vts:Distance(Vector(W/2,H/2,0)) < 100 then
				table.insert(entz, v)
			end
		end
	end
	for k,ent in pairs(entz) do
		if IsValid(ent) and IsValid(ent:GetDriver()) then
			local col = team.GetColor(ent:GetTeam())
			surface.SetTextColor(col.r,col.g,col.b,200)
			surface.SetFont("ChatFont")
			local w,h = surface.GetTextSize(ent:GetDriver():Nick())
			local pos = (ent:GetPos() + Vector(0,0,50)):ToScreen()
			surface.SetTextPos(pos.x - w/2,pos.y + 10 - h/2)
			surface.DrawText(ent:GetDriver():Nick())
		end
	end
	
		//PLANE ESP
	local planes = ents.FindByClass("df_plane")
	for k,pln in pairs(planes) do
		if IsValid(pln) && pln != plane && pln:GetTeam() == LocalPlayer():Team() then
			surface.SetDrawColor(team.GetColor(pln:GetTeam()))
			local pos = pln:GetPos():ToScreen()
			local dist = plane:GetPos():Distance(pln:GetPos())
			local size = math.Clamp((20000 - dist) / 400,0,100)
			surface.DrawOutlinedRect(  pos.x - (size * 0.5),  pos.y - (size * 0.5),  size,  size )
		end
	end
	//HOMING MISSILE ESP
	local missiles = ents.FindByClass("wep_projectile_missile")
	target_camera_distance = GetConVarNumber("df_camdist")
	if #missiles > 0 then
		for k,mis in pairs(missiles) do
			if mis:GetTarget() == LocalPlayer():GetPlane() and mis.DieTime > CurTime() then
				local pos = mis:GetPos():ToScreen()
				local w,h = surface.GetTextSize("WARNING!")
				pos.x = math.Clamp(pos.x, w / 2, W - w / 2)
				pos.y = math.Clamp(pos.y, h / 2, H - h / 2)
				if missile_flash_yellow <= 0 then missile_flash_change = 5 end
				if missile_flash_yellow >= 255 then missile_flash_change = -5 end
				missile_flash_yellow = missile_flash_yellow + missile_flash_change
				local dist = mis:GetPos():Distance(LocalPlayer():GetPlane():GetPos())
				target_camera_distance = math.Clamp(dist * 1.1, GetConVarNumber("df_camdist") + 150, 1000)
				surface.SetTextColor(255,missile_flash_yellow,0,255)
				surface.SetFont("ChatFont")
				surface.SetTextPos(pos.x - (w*0.5),pos.y - (h* 0.5))
				surface.DrawText("WARNING!")
			end
		end
	end
	
	//Fuel pod arrow
	local got_fuel = false
	for k,fuel_pod in pairs(ents.FindByClass("df_fuel_pod")) do
		if IsValid(fuel_pod) then
			if IsValid(fuel_pod.dt.OwnerPlane) then
				local pos = fuel_pod.dt.OwnerPlane:GetPos() + Vector(0,0,64)
				pos = pos:ToScreen()
				pos.y = pos.y - 20
				if missile_flash_yellow <= 0 then missile_flash_change = 5 fuel_warning_text = "WARNING!" fuel_friend_text = "DEFEND!" end
				if missile_flash_yellow >= 255 then missile_flash_change = -5 fuel_warning_text = "ENEMY FUEL CARRIER!" fuel_friend_text = "FRIENDLY FUEL CARRIER!" end
				missile_flash_yellow = missile_flash_yellow + missile_flash_change
				surface.SetTextColor(255,missile_flash_yellow,0,255)
				if fuel_pod.dt.OwnerPlane:GetTeam() == LocalPlayer():GetPlane():GetTeam() then
					surface.SetFont("ChatFont")
					local w,h = surface.GetTextSize(fuel_friend_text)
					surface.SetTextPos(pos.x - (w*0.5),pos.y - (h* 0.5))
					surface.DrawText(fuel_friend_text)
				else
					surface.SetFont("ChatFont")
					local w,h = surface.GetTextSize(fuel_warning_text)
					surface.SetTextPos(pos.x - (w*0.5),pos.y - (h* 0.5))
					surface.DrawText(fuel_warning_text)
				end
				if LocalPlayer():GetPlane() == fuel_pod.dt.OwnerPlane then
					//FUEL CARRIER HUD
					got_fuel = true
					local pos = nil
					if LocalPlayer():Team() == TEAM_RED then
						pos = GAMEMODE:GetRocket(TEAM_RED):GetPos() + Vector(0,0,1500)
						pos = pos:ToScreen()
						surface.SetTexture(rocket_arrow_red)
					else
						pos = GAMEMODE:GetRocket(TEAM_BLUE):GetPos() + Vector(0,0,1500)
						pos = pos:ToScreen()
						surface.SetTexture(rocket_arrow_blue)
					end
					pos.y = pos.y + (math.sin(CurTime() * 5) * 2)
					surface.DrawTexturedRect(pos.x - 8,pos.y - 8, 16,16)
				end	
			else
				if LocalPlayer():GetPlane() != fuel_pod.dt.OwnerPlane and !got_fuel then
					local pos = (fuel_pod:GetPos() + Vector(0,0,32)):ToScreen()
					if fuel_pod:GetTeam() == TEAM_RED then
						surface.SetTexture(rocket_arrow_red)
					else
						surface.SetTexture(rocket_arrow_blue)
					end
					pos.y = pos.y + (math.sin(CurTime() * 5) * 2)
					surface.DrawTexturedRect(pos.x - 8,pos.y - 18, 16,16)
				end
			end
		end
	end
	
	//Target direction
	surface.SetDrawColor(0,0,0,255)
	local pos = plane:GetPos() + (LocalPlayer():GetAimVector() * 1090)
	pos = pos:ToScreen()
	surface.DrawLine(  pos.x - cross_size,  pos.y,  pos.x + cross_size,  pos.y )
	surface.DrawLine(  pos.x,  pos.y - cross_size,  pos.x,  pos.y + cross_size )
	
	//AIRSPEED METER
	local planespeed = plane:WorldToLocal(plane:GetVelocity()+plane:GetPos())
	planespeed.x = planespeed.x / 26 * 4
	local rot = 90 - (planespeed.x / 125) * 360
	if rot < -265 then rot = -265 + math.random(-5,5) end
	local x = W - 200
	local y = H - 200
	surface.SetTexture(airspeed_tex)
	surface.SetDrawColor(255,255,255,255)
	surface.DrawTexturedRect( x, y, 200, 200 )
	
	surface.SetTexture(alt_tex_arrow)
	surface.SetDrawColor(255,255,255,255)
	surface.DrawTexturedRectRotated( x + 100, y + 100, 200, 250, rot )
	
	x = 50
	//ALTITUDE METER
	surface.SetTexture(alt_tex)
	surface.DrawTexturedRect( x, y, 200, 200 )
	
	local sea = GetGlobalInt("sea_level",800)
	local alt = (plane:GetPos().z - sea) / 7
	local rot = 90 - alt
	surface.SetTexture(alt_tex_arrow)
	surface.DrawTexturedRectRotated( x + 100, y + 100, 200, 250, rot )
	
	rot = 90 - (alt / 7)
	surface.SetTexture(alt_tex_arrow)
	surface.DrawTexturedRectRotated( x + 100, y + 100, 160, 250, rot )

	
	//FUEL STATUS
	local pos_x = W/2 - 115
	local pos_y = 5
	surface.SetTexture(fuel_stat_tex)
	surface.SetDrawColor(255,255,255,255)
	surface.DrawTexturedRect( pos_x, pos_y, 230, 100 )
	
	surface.SetMaterial(fuel_warning_mat)
	for i=1,2 do
		local pod = self:GetFuelPod(i)
		local ok = true
		local waiting = false
		if IsValid(pod) then
			if IsValid(pod.dt.OwnerPlane) then ok = false end
		else
			waiting = true
		end
		local col = team.GetColor(i)
		fuel_warning_mat:SetVector("$color", Vector(col.r/255,col.g/255,col.b/255))
		fuel_ok_mat:SetVector("$color", Vector(col.r/255,col.g/255,col.b/255))
		fuel_wait_mat:SetVector("$color", Vector(col.r/255,col.g/255,col.b/255))
		local ico_size = 32
		local pos_x = (W/2) - 16
		if i == TEAM_RED then pos_x = pos_x - 30 else pos_x = pos_x + 30 end
		local pos_y = 14
		local ico_oscillate = (math.sin(CurTime() * 5) * 5)
		if waiting then
			surface.SetMaterial(fuel_wait_mat)
		elseif ok then
			surface.SetMaterial(fuel_ok_mat)
		else
			surface.SetMaterial(fuel_warning_mat)
			ico_size = ico_size + ico_oscillate
			pos_y = 14 - ico_oscillate * 0.5
			pos_x = pos_x - ico_oscillate * 0.5
		end
	
		surface.DrawTexturedRect( pos_x, pos_y, ico_size, ico_size )
	end
	
	if IsValid(LocalPlayer():GetCurrentWeapon()) and LocalPlayer():GetCurrentWeapon().DrawWeaponHUD then
		LocalPlayer():GetCurrentWeapon():DrawWeaponHUD()
	end
end

local CenterMessageList = {}

function GM:DrawCenterMessages()
	for k,event in pairs(CenterMessageList) do
		if k == 1 and !event.Start then event.Start = CurTime() end
		local alp = 0
		local time_passed = nil
		if k == 1 then
			if #CenterMessageList > 6 then event.Time = 0.25 end
			time_passed = event.Start + event.Time - CurTime()
			alp = math.Clamp(time_passed / event.Time,0,1) * 255
		else
			alp = 25
		end
		draw.SimpleTextOutlined( event.Text,  "rocket_nums",  W * 0.5,  150 + (k-1) * 30,  Color(251,200,37,alp),  TEXT_ALIGN_CENTER,  TEXT_ALIGN_CENTER,  2,  Color(10,10,10,alp) )
		if alp < 25 then
			table.remove(CenterMessageList,1)
		end
	end
end


function GM:CenterMessage(text, tim)
	print(text)
	if !text then return end
	local tab = {}
	tab.Start = nil
	tab.Text = text
	tab.Time = tim
	table.insert(CenterMessageList, tab)
end

function MessageCenter(um)
	local text = um:ReadString()
	if !text or text == "" then return end
	local showtime = um:ReadShort()
	if !showtime then showtime = 3 end
	local urgency = um:ReadShort()
	
	if urgency == 1 then
		surface.PlaySound("buttons/blip1.wav")
	elseif urgency == 2 then
		surface.PlaySound("ambient/alarms/warningbell1.wav")
	elseif urgency == 3 then
		surface.PlaySound("npc/attack_helicopter/aheli_megabomb_siren1.wav")
	end
			
	GAMEMODE:CenterMessage(text, showtime)
end

usermessage.Hook("df_centertext", MessageCenter)

function GM:PlayerBindPress(ply, bind, pressed)
	for i=1,10 do
		if bind == "slot"..i then	
			RunConsoleCommand("df_useslot", i)
			self:StopHint("WepSelect1")
			self:StopHint("WepSelect2")
		end
		if bind == "invnext" then
		local found = false
			local all_weps = LocalPlayer():GetAllWeapons()
			for k,v in pairs(all_weps) do
				if v == LocalPlayer():GetCurrentWeapon() then
					local slot = k + 1
					if slot > #all_weps then slot = 1 end
					RunConsoleCommand("df_useslot",slot)
					found = true
				end
			end
			if !found and #all_weps > 0 then
				RunConsoleCommand("df_useslot", 1) //try and get the first weapon
			end
		end
		if bind == "invprev" then
			local found = false
			local all_weps = LocalPlayer():GetAllWeapons()
			for k,v in pairs(all_weps) do
				if v == LocalPlayer():GetCurrentWeapon() then
					local slot = k - 1
					if slot <= 0 then slot = #all_weps end
					RunConsoleCommand("df_useslot",slot)
					found = true
				end
			end
			if !found and #all_weps > 0 then
				RunConsoleCommand("df_useslot", 1) //try and get the first weapon
			end
		end
	end
end

function OnBulletHit(um)
	CRS = 28
end

usermessage.Hook("df_bullet_hit", OnBulletHit)

local pixelvisible = util.GetPixelVisibleHandle()

//A million thanks to Capsadmin!
function EasySunbeams(position, distance, amount, size)
	if EyePos():Distance(position) > distance then return end
	local visible = util.PixelVisible(position, 150, pixelvisible)
	if visible > 0 then
		local dotProduct = math.Clamp(LocalPlayer():GetAimVector():DotProduct((position-EyePos()):Normalize())-0.5, 0, 1) * 2
		local distance = math.Clamp((position-EyePos()):Length() / -distance + 1, 0, 1)
		local screenPos = position:ToScreen()
		DrawSunbeams( 0, (amount*dotProduct*visible)*distance, size*math.abs(distance*-1+1), screenPos.x / ScrW(), screenPos.y / ScrH()) 
	end
end

--[[
local blur_amount = 0

function GM:RenderScreenspaceEffects()
	local am = math.Clamp(boost_start - CurTime(),0,5)
	local plane = LocalPlayer():GetPlane()
	if IsValid(plane) and plane:GetVelocity():Length() > shake_speed then
		am = am + (plane:GetVelocity():Length() * 0.001)
	end
	blur_amount = math.Approach(blur_amount, am, 0.01)
	print(blur_amount)
	DrawMotionBlur( blur_amount * 0.1, blur_amount, 0 )
end
]]

function GM:RenderScreenspaceEffects()
	local am = math.Clamp(boost_start - CurTime(),0,5)
	local plane = LocalPlayer():GetPlane()
	if IsValid(plane) and plane:GetVelocity():Length() > shake_speed then
		am = am + (plane:GetVelocity():Length() * 0.0001)
	end
	DrawMotionBlur( 0.1, am, 0 )
end

function start_boost(um)
	boost_start = CurTime() + um:ReadFloat()
end

usermessage.Hook("df_boost",start_boost) //Little boost from doing aerobatic events