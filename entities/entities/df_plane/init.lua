
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

AccessorFunc(ENT,"iRolling", "Rolling", NUMBER)
AccessorFunc(ENT,"iAmmo", "Ammo",NUMBER)
AccessorFunc(ENT,"TrickTab", "Trick")
AccessorFunc(ENT,"bTricking", "TrickRunning", BOOL)
AccessorFunc(ENT,"bRollCorrect", "RollCorrect", BOOL)
AccessorFunc(ENT,"bStallProtect", "StallProtection", BOOL)
AccessorFunc(ENT,"iLastDamage", "LastDamage", NUMBER)
AccessorFunc(ENT,"iWingEfficency", "WingPower", NUMBER)
AccessorFunc(ENT,"iThrottleEffic", "ThrottlePower", NUMBER)
AccessorFunc(ENT,"iTurnPow", "TurnPower", NUMBER)
AccessorFunc(ENT,"bHasFuelPod", "HasFuelPod", BOOL)
AccessorFunc(ENT,"eAIDriver", "AIDriver")
AccessorFunc(ENT,"iPhysicsDamage", "PhysicsDamage")
AccessorFunc(ENT,"iMaxTurn", "MaxTurn", NUMBER)

AccessorFunc(ENT,"iThrottle","Throttle")

local explode_snd = Sound( "weapons/explode3.wav" )

local EmergencyAlt = 2048

ENT.AutomaticFrameAdvance = true 

function ENT:Initialize()
	self.Entity:SetModel("models/Bennyg/dogfight/airboat.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS)
	self.Entity:SetSolid( SOLID_VPHYSICS )
	
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:SetMaterial("ice")
		phys:SetMass(10000) //I dont think mass actually affects much best keep it as it is.
	end
	
	self.WINGS = {}
	
	self:GetPhysicsObject():SetDamping( 0, 0.5 )  

	--VECTOR(FORWARD, LEFT/RIGHT, UP)
	self.WINGS[1] = {AREA = 8.4, OFFSET = Vector(20,0,0)} //Set up each wing which is to be simulated.												
	//self.WINGS[2] = {AREA = 4.2, OFFSET = Vector(20,-50,0)} //These are pretty much perfect right now.								
	self.WINGS[2] = {AREA = 1.5, OFFSET = Vector(-100,0,40)}

	self.Engine_Sound = CreateSound(self, "vehicles/Airboat/fan_blade_fullthrottle_loop1.wav")	
			
	self:SetThrottle(0)
	self:SetRollCorrect(true)
	self:SetStallProtection(true)
	self.COF = 0.7
	self:SetRolling(0)
	self:SetDamage(0)
	self:SetMaxTurn(60)
	self:SetLastDamage(CurTime())
	self.gun = nil
	self.NextTrick = CurTime() //When you can d0 a trick.
	
	self:SetThrottlePower(1)
	self:SetWingPower(1)
	self:SetTurnPower(1)
	self:SetPhysicsDamage(1)
	
	self.LastCollide = CurTime()
	
	self.prop_anim = self:LookupSequence("propellor_rotate")
	self:ResetSequence(self.prop_anim)
	self.prop_anim_dur = self:SequenceDuration()
	self:SetPlaybackRate(2)
	
	//BOT DEFINITIONS
	self.target_alt = 0
	self.last_near_center = 0
	self.target = nil
	self.last_seek_target = 0
end

function ENT:SetTrick(name)
	self.tricktab = DF_AEROBATICS[name]
	self.tricktab.INIT(self:GetDriver())
end

function ENT:GetTrick()
	return self.tricktab
end

function ENT:SetWeapon(class)
	if self.gun && self.gun:GetClass() == class then return end // no need
	self.gun = ents.Create(class)
	if !IsValid(self.gun) then return end //class name shit
	self.gun:SetPlane(self)
	self.gun:Spawn()
end

function ENT:GetWeapon()
	return self.gun
end

function ENT:OnLockOn(missile) //When a missile locks onto the plane
	umsg.Start("df_on_missile_lock", self:GetDriver())
	umsg.Entity(missile)
	umsg.End()
end

ENT.MAX_SPEED = 400 //Max throttle
ENT.MIN_SPEED = 50
ENT.THROTTLE_SPEED = 10 //Throttle speed

function ENT:Think()
	local p = self:GetPhysicsObject()
	if IsValid(self:GetDriver()) and self:GetDriver():Alive() and self:GetDriver():Team() != TEAM_SPECTATOR then
		if self:GetDriver():IsFrozen() || !GAMEMODE:InRound() then
			p:EnableMotion(false) 
		else
			p:EnableMotion(true)
			p:Wake()
			//Throttle controls
			if self.in_speed then
				self:SetThrottle(math.Approach(self:GetThrottle(), self.MAX_SPEED, self.THROTTLE_SPEED))
			elseif self.in_duck then
				self:SetThrottle(math.Approach(self:GetThrottle(), self.MIN_SPEED, self.THROTTLE_SPEED))
			end
			if self:GetThrottle() > self.MAX_SPEED then self:SetThrottle(self:GetThrottle() - 2) end
			
			//Primary weapon
			if self.in_attack then
				if IsValid(self:GetWeapon()) then
					self:GetWeapon():FireGun()
				end
			end
			
			//Primary weapon
			if self.in_attack2 then
				if IsValid(self:GetDriver():GetCurrentWeapon()) then
					if self:GetHasFuelPod() then self:GetDriver():ShowTip("NoWepGotFuel") return end
					self:GetDriver():GetCurrentWeapon():FireGun()
				end
			end
			
			local vel = self:WorldToLocal(self:GetVelocity()+self:GetPos())
			self.Engine_Sound:ChangePitch(math.Clamp((self:GetThrottle() * 0.2) + (vel.x / 135)^3,20,250),0)
			self:SetPlaybackRate(self:GetThrottle() / self.MAX_SPEED * 0.5)
			if self:GetLastDamage() + 10 < CurTime() and self:GetDamage() > 0 then
				self:SetDamage(self:GetDamage() - 1)
			end
		end
	else
		self:Remove();
	end
	self:NextThink(CurTime() + 0.1)
	return true
end

function ENT:AddDriver(driv)
	driv:SetPlane(self);
	self:SetDriver(driv);
	driv:Spectate(OBS_MODE_CHASE)
	driv:SpectateEntity(self)
	driv:SetMoveType(MOVETYPE_OBSERVER)
	driv:StripWeapons()
	self:StartMotionController()
	self.Engine_Sound:PlayEx( 1.5, 50 )
	driv:CrosshairDisable();
	self:SetTrick("barrel_roll")
	self:SetWeapon("wep_default")
	self:SetTrickRunning(false)
	self:SetAmmo(5000);
	self:SetTeam(driv:Team())
	if self:GetDriver():IsBot() then
		self:CreateAIDriver()
	end
end

function ENT:CreateAIDriver()
	//Create the AI driver entity
	local drv = ents.Create("df_planedriver")
	drv:SetPlane(self)
	drv:Spawn()
	self:SetAIDriver(drv)
end

function Q_DOWN(ply) //Do a barrel roll!
	if !IsValid(ply:GetPlane()) || CurTime() < ply:GetPlane().NextTrick then return end
	ply:GetPlane():GetTrick().QFUNCPRESS(ply)
end

concommand.Add("+roll_l", Q_DOWN)

function Q_UP(ply)
	if !IsValid(ply:GetPlane()) then return end
	ply:GetPlane():GetTrick().QFUNCRELEASE(ply)
end

concommand.Add("-roll_l", Q_UP)

function RollRightPress(ply, key)
	if key == IN_USE then
		if !IsValid(ply:GetPlane()) || CurTime() < ply:GetPlane().NextTrick then return end
		ply:GetPlane():GetTrick().EFUNCPRESS(ply)
	end
end
 
hook.Add( "KeyPress", "RollRightPress", RollRightPress )

function RollRightRelease(ply,key)
	if key == IN_USE then
		if !IsValid(ply:GetPlane()) then return end
		ply:GetPlane():GetTrick().EFUNCRELEASE(ply)
	end
end

hook.Add("KeyRelease", "RollRightPress", RollRightRelease)

//This func grabs the keyboard inputs seperatately from the simulate
function ENT:GrabInput()
	if IsValid(self:GetAIDriver()) then //Bot dirver does this for us
		return
	end
	//Mouse Control
	local driv_view_angs = self:GetDriver():GetAimVector():Angle()
	self.y_diff = math.NormalizeAngle(driv_view_angs.y - self:GetAngles().y)
	if self:GetDriver():GetInfo("df_inverse") == "1" then
		self.p_diff = math.NormalizeAngle((driv_view_angs.p * -1) + 10 - self:GetAngles().p)
	else
		self.p_diff = math.NormalizeAngle(driv_view_angs.p + 10 - self:GetAngles().p)
	end
	if self:GetAngles().p < -82 and !self:GetTrickRunning() then 
		self:SetTrick("loop")
		self:SetTrickRunning(true)
	end
	if self:GetLanded() then
		self.p_diff = Lerp(0.5,(1 - self:GetLanded()) * -30, self.p_diff)
	end
	self.in_speed = self:GetDriver():KeyDown(IN_SPEED) 
	self.in_duck = self:GetDriver():KeyDown(IN_DUCK)
	self.in_attack = self:GetDriver():KeyDown(IN_ATTACK)
	self.in_attack2 = self:GetDriver():KeyDown(IN_ATTACK2)
end

function ENT:PhysicsSimulate(p,d)
	self.F_ang = Vector(0,0,0)
	self.F_lin = Vector(0,0,0)
	if !IsValid(self:GetDriver()) then
		return SIM_NOTHING
	end
	
	self:GrabInput()	
	
	if self:WaterLevel() > 0.1 then self:Explode() return SIM_NOTHING end
	
	local forward = self:GetForward()
	local right = self:GetRight()
	local up = self:GetUp()
	local pos = self:GetPos()
	
	local ply = self:GetDriver()
	self.l_vel = self.Entity:WorldToLocal(self.Entity:GetVelocity()+self.Entity:GetPos()) * 4 //Local velocity
	self.vel = self:GetVelocity() * 4 //Global vel 
	self.vel_ang = self.vel:Angle() //Velocity expressed as an angle
	self.ang = self:GetAngles() //Angles of the plane
	self.ang_vel = p:GetAngleVelocity() //Angle velocity
	
	local forward_vel = self.l_vel.x * 0.04 //Convert to FPS This is the global forward velocity of the fuselage
	for k,v in pairs(self.WINGS) do
		local l_forward_vel = self.l_vel.x //+ (math.rad(self.ang_vel.z) * (v.OFFSET.y * -0.5))
		l_forward_vel = math.Clamp(l_forward_vel * 0.02, 0, 50)
		local LIFT = self.COF * (0.45 * (0.1 * l_forward_vel^2)) * v.AREA * self:GetWingPower()
		local forcelinear, forceangular = p:CalculateForceOffset(up * LIFT , self:LocalToWorld(v.OFFSET)) //Apply upward and angular force
		self.F_lin = self.F_lin + forcelinear
		self.F_ang = self.F_ang + forceangular
	end
	
	local ctrl = math.Clamp((math.abs(self.l_vel.x ^ 2) / 2000000) * 10,0,12) * self:GetTurnPower() //How much influence the controls have
	
	if !IsValid(self:GetAIDriver()) then
		if math.abs(self.y_diff) < 5 then self.y_diff = self.y_diff * 0.6 end
	end
	self.y_diff = math.Clamp(self.y_diff, -self:GetMaxTurn(), self:GetMaxTurn());
	if !IsValid(self:GetAIDriver()) then
		if math.abs(self.p_diff) < 5 then self.p_diff = self.p_diff * 0.6 end
	end
	self.p_diff = math.Clamp(self.p_diff, -40, 40);
	
	if self:GetTrickRunning() then
		self:GetTrick().SIM(self)
	end
	if self:GetRollCorrect() then
		local rollforce = (right * (self.ang.r + self.y_diff)) * -ctrl * 5
		//rollforce = rollforce + (up * math.abs(self.ang.r) * -ctrl * -20)
		local forcelinear, forceangular = p:CalculateForceOffset(rollforce, pos + (up * 50))
		self.F_ang = self.F_ang + forceangular
	end
	
	local turn_force = (right * self.y_diff * ctrl) + (up * self.p_diff * ctrl * 1.75)
	
	local forcelinear, forceangular = p:CalculateForceOffset(turn_force, pos + forward * -100)
	//self.F_lin = self.F_lin + forcelinear
	self.F_ang = self.F_ang + forceangular
	
	//FORWARDING
	local forcelinear, forceangular = p:CalculateForceOffset(forward * self:GetThrottle() * 2.1 * self:GetThrottlePower(), pos)
	self.F_lin = self.F_lin + forcelinear
	self.F_ang = self.F_ang + forceangular
	
	local drag = up * -self.l_vel.z * 2
	drag = drag + (right * self.l_vel.y * 2)
	drag = drag + (forward * forward_vel^2 * -0.12)
	
	local forcelinear, forceangular = p:CalculateForceOffset(drag, pos)
	self.F_lin = self.F_lin + forcelinear
	
	local turn_damp = self.ang_vel * -10 * (forward_vel / 20) //Turn damping
	self.F_ang = self.F_ang + turn_damp

	return self.F_ang, self.F_lin, SIM_GLOBAL_ACCELERATION
end

function ENT:OnTakeDamage(dmg)
	local inf = dmg:GetInflictor()
	if inf:GetClass() == "wep_default" || inf:GetClass() == "prop_dynamic" then
		if GAMEMODE.TeamBased and inf:GetPlane():GetTeam() != self:GetTeam() then
			if self:GetDriver():IsBot() then //inform our driver aswell
				self:GetAIDriver():OnPlaneTakeDamage(inf:GetPlane())
			end
			local iDmg = dmg:GetDamage()
			if self:GetPos():Distance(inf:GetPlane():GetPos()) > 3000 then
				iDmg = iDmg * 0.3
			end
			self:SetDamage(self:GetDamage() + iDmg)
			self:SetLastDamage(CurTime())
			if self:GetDamage() > 100 then
				self:GetDriver().Killer = inf:GetPlane():GetDriver()
				if self:GetHasFuelPod() then
					self:GetDriver().Killer:ScoringEvent("fuelrescue")
				end
				self:Explode()
			end
		end
	end
end

function ENT:PhysicsCollide( data, physobj )
	if self.LastCollide + 0.5 > CurTime() then return end //Sometimes it calls this two or three times.
	if data.Speed < 100 then return end
	if data.HitEntity:GetClass() == "df_plane" then
		if data.HitEntity:GetTeam() == self:GetTeam() then return end
	elseif data.HitEntity:GetClass() == "wep_projectile_missile" || data.HitEntity:GetClass() == "wep_mine_entity"  then
		if data.HitEntity:GetPlane():GetTeam() == self:GetTeam() then return end
	elseif data.HitEntity:GetClass() == "wep_projectile_harpoon" then
		return
	end
	local dmg = data.Speed * 0.5
	dmg = dmg * self:GetPhysicsDamage()
	if data.HitEntity:GetClass() == "df_plane" || data.HitEntity:GetClass() == "worldspawn" then
		dmg = math.Clamp(dmg, 0, 80)
	end
	if dmg > 50 then
		self:EmitSound("physics/metal/metal_sheet_impact_hard"..math.random(6,8)..".wav",100,100)
	elseif dmg > 25 then
		self:EmitSound("physics/metal/metal_barrel_impact_soft"..math.random(1,4)..".wav",100,100)
	end
	self:SetDamage(self:GetDamage() + dmg)
	self:SetLastDamage(CurTime())
	if self:GetDamage() > 100 then
		if !data.HitEntity then
			self:GetDriver().Killer = self:GetDriver() //suicide
		end
		self:Explode()
	end
	self.LastCollide = CurTime()
end

function ENT:Explode()
	local ED = EffectData()
	ED:SetOrigin(self:GetPos())
	ED:SetStart(self:GetVelocity())
	util.Effect("plane_explode", ED)
	self:EmitSound("weapons/explode3.wav", 80,100)
	self:Remove()
end

function ENT:GetLanded()
	local trc = {start=self:GetPos(),endpos=self:GetPos() - Vector(0,0, 20) + self:GetVelocity(),filter=self}
	debugoverlay.Cross(  self:GetPos() - Vector(0,0,20) + self:GetVelocity(),  16,  0.2 )
	local tr = util.TraceLine(trc)
	if tr.Hit then return tr.Fraction end
	return false
end

function ENT:OnRemove()
	if IsValid(self:GetDriver()) && self:GetDriver():Alive() then
		self:GetDriver():Kill()
	end
	if IsValid(self.ePod) then
		self.ePod:SetParent(NULL)
		self.ePod:SetPos(self:GetPos())
		self.ePod:OnDrop()
		self.ePod.dt.OwnerPlane = nil
	end
	self.Engine_Sound:Stop()
end

function math.VectorToRadian(vec)
	local n_vec = Vector()
	n_vec.x = math.rad(vec.x)
	n_vec.y = math.rad(vec.y)
	n_vec.z = math.rad(vec.z)
	return n_vec
end





