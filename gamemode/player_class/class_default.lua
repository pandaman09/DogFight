
local CLASS = {}

CLASS.DisplayName			= "Pilot"
CLASS.DrawTeamRing			= false
CLASS.PlayerModel			= ""
CLASS.DrawViewModel			= false
CLASS.FullRotation			= true
CLASS.MaxHealth				= 100
CLASS.StartHealth			= 100
CLASS.StartArmor			= 0
CLASS.RespawnTime           = 0
CLASS.CanUseFlashlight      = false

function CLASS:Loadout( ply )
end

function CLASS:OnSpawn( ply )
	if !GAMEMODE.TeamBased then
		ply:SetTeam(TEAM_PILOTS)
	end
	ply:SetAllowFullRotation( true )
	if !IsValid(ply:GetPlane()) then
		ply:CreatePlane();
	end
	ply.weapons_tab = {}
	local pwp = GetRandomPowerup()
	if pwp then
		print("Found a random powerup:")
		PrintTable(pwp)
		print("END OF POWERUP")
		ply:GiveWeapon(pwp.CLASS)
	end
	ply.Killer = nil
end

function CLASS:OnDeath( ply, attacker, dmginfo )

end

function CLASS:CalcView( ply, origin, angles, fov )
	--[[local plane = ply:GetPlane();
	if !IsValid(plane) then return end;
	
	ply.LastAngs = ply.LastAngs or angles;
	
	local ang_plane = plane:GetAngles();
	ang_plane.p = math.NormalizeAngle(ply:GetPlane():GetAngles().p);
	ang_plane.y = math.NormalizeAngle(ply:GetPlane():GetAngles().y);
	ang_plane.r = math.NormalizeAngle(ply:GetPlane():GetAngles().r);

	local view = {}
	local p_diff = math.NormalizeAngle(angles.p - ang_plane.p)
	local y_diff = math.NormalizeAngle(angles.y - ang_plane.y)
	angles.y = angles.y - (y_diff * 1.2)
	angles.p = angles.p - (p_diff * 1.2)
	view.angles = angles
	view.origin = plane:GetPos() + (ang:Forward() * -200) + Vector(0,0,40);
	view.fov = 60
	ply.LastAngs = ang;
	return view]]
end

function CLASS:ShouldDrawLocalPlayer( ply )
	return false
end

function CLASS:InputMouseApply( ply, cmd, x, y, angle )
	local plane = ply:GetPlane()
	if !IsValid(plane) then return end
	if camera_free_movement then return end
	local ang = cmd:GetViewAngles()
	
	local ang_plane = plane:GetAngles();
	ang_plane.p = math.NormalizeAngle(ply:GetPlane():GetAngles().p);
	ang_plane.y = math.NormalizeAngle(ply:GetPlane():GetAngles().y);
	ang_plane.r = math.NormalizeAngle(ply:GetPlane():GetAngles().r);
	
	local p_diff = math.NormalizeAngle(ang.p - ang_plane.p)
	if GetConVarNumber("df_inverse") == 1 then
		p_diff = math.NormalizeAngle((ang.p * -1) - ang_plane.p)
	end
	local y_diff = math.NormalizeAngle(ang.y - ang_plane.y)
	if math.abs(y_diff) > 60 then
		ang.y = ang_plane.y + math.Clamp(y_diff, -60,60)
	end
	if math.abs(p_diff) > 50 then
		ang.p = ang_plane.p + math.Clamp(p_diff, -50,50)
	end
	if GetConVarNumber("df_xbox") == 1 then
		LocalPlayer().LastAngX = LocalPlayer().LastAngX or cmd:GetViewAngles()
		if ang.p == LocalPlayer().LastAngX.p then
			ang.p = math.ApproachAngle(ang.p, ply:GetPlane():GetAngles().p -3, 0.2)
		end
		if ang.y == LocalPlayer().LastAngX.y then
			ang.y = math.ApproachAngle(ang.y, ply:GetPlane():GetAngles().y, 0.2)
		end
		LocalPlayer().LastAngX = ang
	end
	cmd:SetViewAngles(ang)
end

player_class.Register( "Default", CLASS )

