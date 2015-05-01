
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

AccessorFunc(ENT,"ePlane", "Plane")
AccessorFunc(ENT,"sTask", "Task")
AccessorFunc(ENT,"eTarget", "Target")

local EmergencyAlt = 750
function ENT:Initialize()
	if !IsValid(self:GetPlane()) then return end // No plane no gain
	self.last_damages = {}
	self:SetNoDraw(true)
	self:SetPos(self:GetPlane():GetPos())
	self:SetParent(self:GetPlane())
	
	self.wander_targ_pos = Vector(0,0,0)
	self.last_reposition = 0
	self:GetPlane().y_diff = 0
	self:GetPlane().p_diff = 0
	if math.random(1,2) == 1 then
		self.emergency_turn_dir = -1
	else
		self.emergency_turn_dir = 1
	end
	if math.random(1,3) == 1 then
		self.go_for_fuel = true
	end
	self.trace_filter = {self, self:GetPlane()}
	self.last_target_seek = CurTime()
end

function ENT:RunTask(tsk_id)
	self[tsk_id]()
end

function ENT:Think()
	if (!IsValid(self:GetPlane())) then return end
	self:DecideTask()
	self:NextThink(CurTime() + 0.2)
	return true
end

function ENT:OnPlaneTakeDamage(atk_pln)
	if self:GetPlane():GetHasFuelPod() then
		for k,v in pairs(ents.FindByClass("df_plane")) do
			if v:GetTeam() == self:GetPlane():GetTeam() and IsValid(v:GetAIDriver()) and v != self:GetPlane() then
				self:Debug("Informing freindlies!")
				v:GetAIDriver():SetTarget(atk_pln)
			end
		end
	end
	if math.random(1,10) == 1 then self:SetTarget(atk_pln) end
end

function ENT:Debug(txt)
	//Entity(1):ChatPrint(self:GetPlane():GetDriver():Nick()..": "..txt)
end

function ENT:OnRemove()
end

//BEGIN TASKS

//Here the entity decides what task we should be doing
function ENT:DecideTask()
	self:GetPlane().y_diff = 0
	self:GetPlane().p_diff = 0
	if IsValid(self:GetPlane():GetDriver():GetCurrentWeapon()) then
		if self:GetPlane():GetDriver():GetCurrentWeapon():ShouldUse(self, self:GetPlane()) then
			self:GetPlane().in_attack2 = true
		else
			self:GetPlane().in_attack2 = false
		end
	end
	if self:GetPlane():GetHasFuelPod() or (IsValid(GAMEMODE:GetFuelPod((self:GetPlane():GetTeam() * -1) + 3)) and self.go_for_fuel) then
		self:GetFuel()
		return
	end
	if IsValid(self:GetTarget()) then
		self:ChaseEnemy()
		return
	end
	if !IsValid(self:GetTarget()) and self.last_target_seek + 2 < CurTime() then
		self:LocateEnemy()
		self.last_target_seek = CurTime()
		return
	end
	self:Wander()
end

function ENT:GetFuel()
	local targ_pos = Vector(0,0,0)
	if self:GetPlane():GetHasFuelPod() then
		local rocket = nil
		local climb = false
		local rocket = GAMEMODE:GetRocket(self:GetPlane():GetTeam())
		local targ_pos = rocket:LocalToWorld(rocket:OBBCenter()) + Vector(0,100,500)
		local targ_ang = targ_pos - self:GetPos()
		targ_ang = targ_ang:Angle()
		self:GetPlane().y_diff = math.NormalizeAngle(targ_ang.y - self:GetPlane():GetAngles().y)
		self:GetPlane().p_diff = math.NormalizeAngle(targ_ang.p + 10 - self:GetPlane():GetAngles().p)
		local m_xy = self:GetPos()
		m_xy.z = 0
		local r_xy = rocket:GetPos()
		r_xy.z = 0
		if m_xy:Distance(r_xy) > 5000 then
			self:GetPlane().p_diff = math.Clamp(self:GetPlane().p_diff, -5,10)
		end
	
		local tr = {start=self:GetPos(),endpos=targ_pos + Vector(0,0,1000),filter=self.trace_filter}
		tr = util.TraceLine(tr)
		if tr.HitWorld then
			self:Debug("EMERGENCY FUEL CLIMB")
			self:GetPlane().p_diff = -12
			self:GetPlane().y_diff = math.Clamp(self:GetPlane().y_diff, -10,10)
		end
		self:CheckAlt()
	else
		local fuel = GAMEMODE:GetFuelPod((self:GetPlane():GetTeam() * -1) + 3)
		if IsValid(fuel.dt.OwnerPlane) then self.go_for_fuel = false end
		local tr = util.TraceLine({start=self:GetPos(),endpos=fuel:GetPos(),filter=self.trace_filter})
		targ_pos = self:GetPos() + self:GetForward() * 100
		if !tr.HitWorld then
			targ_pos = fuel:GetPos()
			local targ_ang = targ_pos - self:GetPos()
			targ_ang = targ_ang:Angle()
		
			self:GetPlane().y_diff = math.NormalizeAngle(targ_ang.y - self:GetPlane():GetAngles().y)
			self:GetPlane().p_diff = math.NormalizeAngle(targ_ang.p + 10 - self:GetPlane():GetAngles().p)
		else
			self:Wander()
		end
	end
end

function ENT:FindPowerup()
	self:Debug("Finding powerup")
	local powerups = ents.FindByClass("df_powerup")
	local targ_pos = Vector(0,0,0)
	local near_dist = 9999
	for k,v in pairs(powerups) do
		local tr = {start=self:GetPos(),endpos=v:GetPos() + Vector(0,0,v.height - 10),filter=self.trace_filter}
		tr = util.TraceLine(tr)
		local dist = v:GetPos():Distance(self:GetPos())
		if !tr.HitWorld and dist < near_dist and v.dt.PoweredUp and (self:GetPos().z - v:GetPos().z) < 3000 then
			targ_pos = v:GetPos() + Vector(0,0,v.height - 10)
			near_dist = dist
		end
	end
	if targ_pos == Vector(0,0,0) then self.fetch_power = false return end
	debugoverlay.Cross(  targ_pos,  16,  0.2, team.GetColor(self:GetPlane():GetTeam()) )
	local targ_ang = targ_pos - self:GetPos()
	targ_ang = targ_ang:Angle()
	
	self:GetPlane().driv_view_angs = targ_ang
end

//If we are in the situation where we need to find an enemy locate the best one
//Uses a basic heirarchy: Opposite team, our current target is nearly dead, We can see them, distance
function ENT:LocateEnemy()
	local planes = ents.FindByClass("df_plane")
	self.emergency_turn_dir = self.emergency_turn_dir * -1
	for k,v in pairs(planes) do
		if v:GetTeam() != self:GetPlane():GetTeam() then //not on our team
			local t_pos = v:GetPos()
			local m_pos = self:GetPlane():GetPos()
			local dist = t_pos:Distance(m_pos)
			local m_dmg = self:GetPlane():GetDamage()
			local t_dmg = v:GetDamage()
			
			//Dont d0 anything when our target is dieing
			if (IsValid(self:GetTarget()) and self:GetTarget():GetDamage() > 65) then return end //stick with him
			
			if v:GetHasFuelPod() then self:SetTarget(ent) return end
			
			local ext_pos = m_pos + (self:GetPlane():GetForward() * dist)
			if (ext_pos:Distance(t_pos) < (dist * 0.8)) then
				//We can see the bugger
				if IsValid(self:GetTarget()) then
					if m_pos:Distance(self:GetTarget()) > dist then
						self:SetTarget(v)
						self:Debug("Targetting "..tostring(v:GetDriver():Nick()))
					end
				else
					self:SetTarget(v)
				end
			end
		end
	end
	if !IsValid(self:GetTarget()) then
		self:Wander()
	end
end

function ENT:Wander()
	local fuel_pos = ents.FindByClass("df_map_center")[1]:GetPos()
	local targ_pos = Vector(0,0,0)
	if CurTime() > self.last_reposition + 10 then
		self.wander_targ_pos = fuel_pos + Vector(math.random(-2048,2048), math.random(-2048,2048), math.random(1024,2024))
		self.last_reposition = CurTime()
		--[[if math.random(1,2) == 1 then //roll for funsies
			self:GetPlane():GetTrick().QFUNCPRESS(self:GetPlane():GetDriver())
		else
			self:GetPlane():GetTrick().EFUNCPRESS(self:GetPlane():GetDriver())
		end]]
		if math.random(1,5) == 1 then
			local fuel = GAMEMODE:GetFuelPod((self:GetPlane():GetTeam() * -1) + 3)
			if IsValid(fuel) and !IsValid(fuel.dt.OwnerPlane) then self.go_for_fuel = true end
		end
	end
	targ_pos = self.wander_targ_pos
	debugoverlay.Cross(  targ_pos,  16,  1, team.GetColor(self:GetPlane():GetTeam()) )
	
	local targ_ang = targ_pos - self:GetPos()
	targ_ang = targ_ang:Angle()
	self:GetPlane().y_diff = math.NormalizeAngle(targ_ang.y - self:GetPlane():GetAngles().y)
	self:GetPlane().p_diff = math.NormalizeAngle(targ_ang.p + 10- self:GetPlane():GetAngles().p)
	
	self:CheckAlt()
end

function ENT:CanSee(pos)
	local dist = pos:Distance(self:GetPos())
	local ext_pos = self:GetPos() + (self:GetPlane():GetForward() * dist)
	if (ext_pos:Distance(pos) < (dist * 0.3)) then return true end
	return false
end

--[[
	self.driv_view_angs = self:GetDriver():GetAimVector():Angle()
	self.in_speed = self:GetDriver():KeyDown(IN_SPEED) 
	self.in_duck = self:GetDriver():KeyDown(IN_DUCK)
	self.in_attack = self:GetDriver():KeyDown(IN_ATTACK)
	self.in_attack2 = self:GetDriver():KeyDown(IN_ATTACK2)]]

function ENT:CheckAlt()
	local tr = util.TraceLine({start=self:GetPos(),endpos=self:GetPos() - Vector(0,0,EmergencyAlt) + (self:GetVelocity() * 2),filter=self.trace_filter})
	if tr.HitWorld then //Altitude protection
		debugoverlay.Cross( tr.HitPos ,  16,  1 )
		self:Debug("EMERGENCY CLIMB CHASE".. (1 - tr.Fraction) * -40)
		self:GetPlane().p_diff = ((1 - tr.Fraction) * -40) + 5
		self:GetPlane().y_diff = math.Clamp(self:GetPlane().y_diff, -10 * tr.Fraction,10 * tr.Fraction)
	end
end
	
//Simplest of tasks. If we have a valid enemy plane chase it th3n attack it.
function ENT:ChaseEnemy()
	local target = self:GetTarget()
	local targ_pos = target:GetPos()
	local dist = self:GetPlane():GetPos():Distance(target:GetPos())
	local m_pos = self:GetPos() + (self:GetForward() * dist)
	local should_fire = (m_pos:Distance(target:GetPos()) < dist * 0.5)
	debugoverlay.Cross(  targ_pos,  16,  1, team.GetColor(self:GetPlane():GetTeam()) )
	local targ_ang = targ_pos - self:GetPos()
	targ_ang = targ_ang:Angle()
	self:GetPlane().y_diff = math.NormalizeAngle(targ_ang.y - self:GetPlane():GetAngles().y)
	self:GetPlane().p_diff = math.NormalizeAngle(targ_ang.p + 10 - self:GetPlane():GetAngles().p)
	
	if dist < 4500 then
		self:GetPlane().in_attack = should_fire
	end
	if dist < 600 and self:CanSee(targ_pos) then
		self:GetPlane().y_diff = 40 * self.emergency_turn_dir
		self:Debug("EMERGENCY TURN")
	end
	self:CheckAlt()
end

--[[
function ENT:TransportFuel()
	local rocket = nil
	local climb = false
	local y_diff = 0
	local p_diff = 0
	local bot = self:GetDriver():IsBot()
	if !bot then
		local driv_view_angs = self:GetDriver():GetAimVector():Angle()
		y_diff = math.NormalizeAngle(driv_view_angs.y - self.ang.y)
		p_diff = math.NormalizeAngle(driv_view_angs.p - self.ang.p)
	end
	if self:GetTeam() == TEAM_RED then
		rocket = GAMEMODE:GetRocket(TEAM_RED)
	else
		rocket = GAMEMODE:GetRocket(TEAM_BLUE)
	end
	local pos = rocket:LocalToWorld(rocket:OBBCenter()) + Vector(0,100,400)
	local tr = {start=self:GetPos(),endpos=pos,filter=self}
	tr = util.TraceLine(tr)
	if tr.HitWorld then
		climb = true
	end
	if bot then
		local targ_ang = pos - self:GetPos()
		targ_ang = targ_ang:Angle()
		y_diff = math.NormalizeAngle(targ_ang.y - self.ang.y)
		p_diff = math.NormalizeAngle(targ_ang.p - self.ang.p)
		local m_xy = self:GetPos()
		m_xy.z = 0
		local r_xy = rocket:GetPos()
		r_xy.z = 0
		if m_xy:Distance(r_xy) > 5000 then
			p_diff = math.Clamp(p_diff, -5,10)
		end
		if climb then
			p_diff = -5
			y_diff = math.Clamp(y_diff, -10,10)
		end
	end
	if util.TraceLine({start=self:GetPos(),endpos=self:GetPos() - Vector(0,0,128),filter=self}).HitWorld then
		p_diff = -2
		y_diff = math.Clamp(y_diff, -10,10)
	end
end]]





