
local meta = FindMetaTable( "Player" )
if (!meta) then return end 

//BEGIN DOGFIGHT EXTENSTIONS
local old_nick = meta.Nick
local old_name = meta.Name

function meta:Nick()
	if self:GetNWString("botnick") and self:GetNWString("botnick") != ""  then
		return self:GetNWString("botnick")
	else
		return old_nick(self)
	end
end

function meta:Name()
	if self:GetNWString("botnick") and self:GetNWString("botnick") != ""  then
		return self:GetNWString("botnick")
	else
		return old_name(self)
	end
end

function meta:ShowTip(name)
	self:SendLua("GAMEMODE:AddTip([["..name.."]], 0.5)")
end

function meta:StopTip(name)
	self:SendLua("GAMEMODE:StopHint([["..name.."]])")
end

function meta:SetMainScore(iScore)
	self:SetNWInt("mainscore", iScore)
end

function meta:AddMainScore(iCount)
	self:SetNWInt("mainscore", self:GetMainScore() + iCount)
end

function meta:GetMainScore()
	return self:GetNWInt("mainscore",0)
end

function meta:SetPlane(ePlane)
	if CLIENT then return end
	if !IsValid(ePlane) && ePlane:GetClass() != "df_plane" then
		ErrorNoHalt("Error! Invalid entity sent to SetPlane()");
	else
		self.ePlane = ePlane;
		self:SetNWEntity("Plane", ePlane);
	end
end

function meta:ScoringEvent(name,...)
	local event = GAMEMODE.ScoreEvents[name]
	if !event then return end
	self:AddMainScore(event.Score)
	if self.lb then
		self.lb_score = self.lb_score + 1
	end
	local msg = event.Text
	local args = ...
	if args then
		msg = string.format(event.Text, args)
	end
	if event.Score > 0 then
		msg = msg.." (+"..event.Score..")"
	elseif event.Score < 0 then
		msg = msg.." ("..event.Score..")"
	end
	self:PrintCenter(msg, 1)
end

function meta:PrintCenter(text, showtime, urgency)
	umsg.Start("df_centertext", self)
	umsg.String(text) //send the event name not all this information the client has it to!
	umsg.Short(showtime)
	local urgent = urgency or 1
	umsg.Short(urgent)
	umsg.End()
end

function meta:GetPlane(ePlane)
	return self:GetNWEntity("Plane");
end

function meta:CreatePlane()
	if IsValid(self:GetPlane()) || (!self.m_bSeenSplashScreen && !self:IsBot()) then return end
	local rand = math.random(0,180)
	local pos = Vector(math.sin(rand) * 500, math.cos(rand) * 500, 3000)
	self:SetPos(self:GetPos() + pos)
	local pln = ents.Create("df_plane");
	pln:SetPos(self:GetPos());
	local center = GAMEMODE:GetCenter()
	local ang = nil
	if !center then
		ang = self:GetAngles()
	else
		ang = center - pln:GetPos()
		ang = ang:Angle()
		ang.p = 0
		ang.r = 0
	end
	self:SetAngles(ang)
	self:SetEyeAngles(ang)
	pln:Spawn();
	self:Spectate(OBS_MODE_CHASE)
	pln:AddDriver(self);
	pln:SetThrottle(pln.MAX_SPEED)
	pln:SetAngles(ang);
	self:Boost()
end

function meta:Boost()
	umsg.Start("df_boost", self)
	umsg.Float(1)
	umsg.End()
end

function meta:GiveWeapon(class)
	print("Attempting to give weapon: ".. ( class and class or "nope!") .."\n" )
	debug.Trace()
	print("\n")
	if SERVER then
		//Class is a string
		if !IsValid(self:GetPlane()) then return end
		if IsValid(self:GetWeaponEntity(class)) then self:GetWeaponEntity(class):ResetAmmo() self:SetCurrentWeapon(class) return end // dont  give two weapons twice
		local wep = ents.Create(class)
		wep:SetOwner(self)
		wep:SetPlane(self:GetPlane())
		wep:Spawn()
		table.insert(self.weapons_tab, wep)
		timer.Simple(0.1, function(ply,wep)
							umsg.Start("df_giveweapon", ply)
							umsg.Entity(wep)
							umsg.End()
						end, self,wep)
		//print("SERVER: Adding weapon", wep)		
		self:SetCurrentWeapon(class)
	else
		if !self.weapons_tab then self.weapons_tab = {} end
		//Class is an entity
		//print("CIENT: Adding weapon", class)
		if class.Tip then
			GAMEMODE:AddTip(class.PrintName..": "..class.Tip, 0.1, true)
		end
		table.insert(self.weapons_tab, class)
	end
end

function RecieveWeapon(um)
	local wep = um:ReadEntity()
	LocalPlayer():GiveWeapon(wep)
end

usermessage.Hook("df_giveweapon", RecieveWeapon)

function meta:GetWeaponEntity(class)
	for k,v in pairs(self:GetAllWeapons()) do
		if IsValid(v) and v:GetClass() == class then
			return v
		end
	end
end

if SERVER then
	function ChangeWeapon(ply,cmd,args)
		if !IsValid(ply:GetPlane()) then return end
		if !args[1] then return end
		local slot = tonumber(args[1])
		for k,v in pairs(ply:GetAllWeapons()) do
			if IsValid(v) and k == slot then
				ply:SetCurrentWeapon(v:GetClass())
			end
		end
	end

	concommand.Add("df_useslot", ChangeWeapon)
end

function meta:GetAllWeapons()
	if !self.weapons_tab then self.weapons_tab = {} end
	for k,v in pairs(self.weapons_tab) do //Clean out the table now
		if !IsValid(v) then
			table.remove(self.weapons_tab, k)
		end
	end
	return self.weapons_tab
end

function meta:SetCurrentWeapon(class)
	for k,v in pairs(self:GetAllWeapons()) do
		if IsValid(v) and v:GetClass() == class then
			self.current_weapon = v
			if SERVER then
				timer.Simple(0.1, function(ply,wep)
									umsg.Start("df_currentweapon", ply)
									umsg.Entity(v)
									umsg.End()
								end, self,wep)
			end
			return
		end
	end
	print("COULD NOT FIND WEAPON (SetCurrentWeapon)")
end

function RecieveCurWeapon(um)
	local ent = um:ReadEntity()
	if IsValid(ent) then
		LocalPlayer():SetCurrentWeapon(ent:GetClass())
	end
end

usermessage.Hook("df_currentweapon", RecieveCurWeapon)

function meta:GetCurrentWeapon(class)
	return self.current_weapon
end

//END DOGFIGHT EXTENSTIONS!

function meta:SetPlayerClass( strName )

	self:SetNWString( "Class", strName )
	
	local c = player_class.Get( strName )
	if ( !c ) then
		MsgN( "Warning: Player joined undefined class (", strName, ")" )
	end

end

function meta:GetPlayerClassName()

	return self:GetNWString( "Class", "Default" )

end


function meta:GetPlayerClass()

	// Class that has been set using SetClass
	local ClassName = self:GetPlayerClassName()
	local c = player_class.Get( ClassName )
	if ( c ) then return c end
	
	// Class based on their Team
	local c = player_class.Get( self:Team() )
	if ( c ) then return c end	
	
	// If all else fails, use the default
	local c = player_class.Get( "Default" )
	if ( c ) then return c end	

end

function meta:SetRandomClass()

	local Classes = team.GetClass( self:Team() )
	if ( Classes ) then
		local Class = table.Random( Classes )
		self:SetPlayerClass( Class )
		return
	end
	
end

function meta:CheckPlayerClassOnSpawn()

	local Classes = team.GetClass( self:Team() )

	// The player has requested to spawn as a new class
	
	if ( self.m_SpawnAsClass ) then

		self:SetPlayerClass( self.m_SpawnAsClass )
		self.m_SpawnAsClass = nil
		
	end
	
	// Make sure the player isn't using the wrong class
	
	if ( Classes && #Classes > 0 && !table.HasValue( Classes, self:GetPlayerClassName() ) ) then
		self:SetRandomClass()
	end
	
	// If the player is on a team with only one class, 
	// make sure we're that one when we spawn.
	
	if ( Classes && #Classes == 1 ) then
		self:SetPlayerClass( Classes[1] )
	end
	
	// No defined classes, use default class
	
	if ( !Classes || #Classes == 0 ) then
		self:SetPlayerClass( "Default" )
	end

end

function meta:OnSpawn()

	local Class = self:GetPlayerClass()
	if ( !Class ) then return end
	
	if ( Class.DuckSpeed ) then self:SetDuckSpeed( Class.DuckSpeed ) end
	if ( Class.WalkSpeed ) then self:SetWalkSpeed( Class.WalkSpeed ) end
	if ( Class.RunSpeed ) then self:SetRunSpeed( Class.RunSpeed ) end
	if ( Class.CrouchedWalkSpeed ) then self:SetCrouchedWalkSpeed( Class.CrouchedWalkSpeed ) end
	if ( Class.JumpPower ) then self:SetJumpPower( Class.JumpPower ) end
	if ( Class.DrawTeamRing ) then self:SetNWBool( "DrawRing", true ) else self:SetNWBool( "DrawRing", false ) end
	if ( Class.DrawViewModel == false ) then self:DrawViewModel( false ) else self:DrawViewModel( true ) end
	if ( Class.CanUseFlashlight != nil ) then self:AllowFlashlight( Class.CanUseFlashlight ) end
	if ( Class.StartHealth ) then self:SetHealth( Class.StartHealth ) end
	if ( Class.MaxHealth ) then self:SetMaxHealth( Class.MaxHealth ) end
	if ( Class.StartArmor ) then self:SetArmor( Class.StartArmor ) end
	if ( Class.RespawnTime ) then self:SetRespawnTime( Class.RespawnTime ) end
	if ( Class.DropWeaponOnDie != nil ) then self:ShouldDropWeapon( Class.DropWeaponOnDie ) end
	if ( Class.TeammateNoCollide != nil ) then self:SetNoCollideWithTeammates( Class.TeammateNoCollide ) end
	if ( Class.AvoidPlayers != nil ) then self:SetAvoidPlayers( Class.AvoidPlayers ) end
	if ( Class.FullRotation != nil ) then self:SetAllowFullRotation( Class.FullRotation ) end
	
	self:CallClassFunction( "OnSpawn" )

end

function meta:CallClassFunction( name, ... )

	local Class = self:GetPlayerClass()
	if ( !Class ) then return end
	if ( !Class[name] ) then return end
	
	//print( "Class Function: ", self:GetPlayerClassName(), name )
	
	return Class[name]( Class, self, ... )
	
end

function meta:OnLoadout()

	self:CallClassFunction( "Loadout" )

end

function meta:OnDeath()

end

function meta:OnPlayerModel()

	// If the class forces a player model, use that.. 
	// If not, use our preferred model..
	
	local Class = self:GetPlayerClass()
	if ( Class && Class.PlayerModel ) then 
	
		local mdl = Class.PlayerModel
		if( type( mdl ) == "table" ) then // table of models, set random
			mdl = table.Random( Class.PlayerModel );
		end
		
		util.PrecacheModel( mdl );
		self:SetModel( mdl );
		return
		
	end
	
	local cl_playermodel = self:GetInfo( "cl_playermodel" )
	local modelname = player_manager.TranslatePlayerModel( cl_playermodel )
	util.PrecacheModel( modelname )
	self:SetModel( modelname )

end

function meta:AllowFlashlight( bAble )

	self.m_bFlashlight = bAble

end

function meta:CanUseFlashlight()

	if self.m_bFlashlight == nil then
		return true // Default to true unless modified by the player class
	end

	return self.m_bFlashlight

end

function meta:SetRespawnTime( num )

	self.m_iSpawnTime = num

end

function meta:GetRespawnTime( num )

	if ( self.m_iSpawnTime == 0 || !self.m_iSpawnTime ) then
		return GAMEMODE.MinimumDeathLength
	end
	return self.m_iSpawnTime

end

function meta:DisableRespawn( strReason )

	self.m_bCanRespawn = false

end

function meta:EnableRespawn()

	self.m_bCanRespawn = true

end

function meta:CanRespawn()

	return self.m_bCanRespawn == nil || self.m_bCanRespawn == true

end

function meta:IsObserver()
	if IsValid(self:GetPlane()) then return false end
	return ( self:GetObserverMode() > OBS_MODE_NONE );
end

function meta:UpdateNameColor()

	if ( GAMEMODE.SelectColor ) then
		self:SetNWString( "NameColor", self:GetInfo( "cl_playercolor" ) )
	end

end
