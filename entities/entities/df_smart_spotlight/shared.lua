
ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.PrintName    = "Smart Spotlight"
ENT.Author       = "Olivier 'LuaPinapple' Hamel"
ENT.Contact      = "evilpineapple@cox.net"
ENT.Purpose      = "GAH! THE LIGHT!"
ENT.Instructions = "..."

ENT.Spawnable      = false
ENT.AdminSpawnable = true

local BaseModel = "models/props_wasteland/light_spotlight01_base.mdl"
local MainModel = "models/props_wasteland/light_spotlight01_lamp.mdl"

local VecZero  = Vector(0, 0, 0)
local UpOffset = Vector(0, 0, 14)

local Up = Vector(0, 0, 1)

local STATE_IDLE        = 1
local STATE_TRACKING    = 2
local STATE_DAMAGED     = 3

local IDLE_ROTATE_CW   = 1 -- Rotate Clockwise
local IDLE_ROTATE_CCW  = 2 -- Rotate Counter Clockwise
local IDLE_PANNING_L2R = 3 -- Panning Left  -> Right
local IDLE_PANNING_R2L = 4 -- Panning Right -> Left
local IDLE_UP_FACING   = 5 -- Going to face upwards

ENT.IsASpotlight = true

local function Dud(self)
	return self:NextThink(CurTime() + 99999999)
end

function ENT:Initialize()
	self.Entity:SetModel(MainModel)
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	
	self.Entity:SetCollisionGroup(COLLISION_GROUP_NONE)
	
	self.Position    = self:GetPos() + UpOffset
	self.Orientation = self:GetAngles()
	
	self.IdlePitch   = math.random(-75, -15)
	self.RotateSpeed = math.random(15, 65) * ((math.Round(math.random(0, 1)) == 1) and -1 or 1)
	
	self.LostTrackingAt = 0
	
	self.State = STATE_IDLE
	self.Range = self.Range or 2048
	
	self.StartIdledAt = CurTime()
	
	if CLIENT then
		self.BaseMdl = ClientsideModel(BaseModel)
		
		local fx = EffectData()
		fx:SetEntity(self)
		--return util.Effect("df_spotlight", fx, true, true)
	else
		---[[
		local e = ents.Create("point_spotlight")
		e:SetKeyValue("spawnflags",      "3")
		e:SetKeyValue("rendercolor",     "255 255 185")
		e:SetKeyValue("spotlightlength", "1024")
		e:SetKeyValue("spotlightwidth",  "256")
		e:SetKeyValue("_cone", "45")
		e:SetKeyValue("_inner_cone", "30")
		e:SetPos(self:GetPos() + (self:GetForward() * 0) + (self:GetUp() * 4))
		e:SetAngles(self:GetAngles())
		e:Spawn()
		
		e:SetParent(self.Entity)
		
		self.Spotlight = e
		--]]
		
		self.team = self.IsTeamGBU and T_GBU or T_IDC
		
		if self.ClusterGUID and (not self.ClusterSlave) then
			self.ClusterMaster = true
			
			self.Cluster = {}
			self.Flaks   = {}
			---[[
			for k, v in pairs(ents.FindByClass("df_flak")) do
				if self.ClusterGUID == v.ClusterGUID then
					v.Think = Dud
					v.LastSpotlightGovernedFire = 0
					Msg(self, " now owns, ", v, "\n")
					self.Flaks[v] = v
				end
			end
			--]]
			for k, v in pairs(ents.FindByClass("df_smart_spotlight")) do
				if (self ~= v) and (self.ClusterGUID == v.ClusterGUID) then
					v.ClusterSlave = true
					Msg(self, " now owns, ", v, "\n")
					self.Cluster[v] = v
				end
			end
		end
		
		self.TraceData = {filter = self}
		
		local phys = self:GetPhysicsObject()
		
		if phys and phys:IsValid() then
			phys:Wake()
		end
		
		return self:StartMotionController()
	end
end

function ENT:Think()
	local phys = self:GetPhysicsObject()
	
	if CLIENT then
		if self.BaseMdl and self.BaseMdl.IsValid and self.BaseMdl:IsValid() then
			local pos = self:GetPos() + (self:GetUp() * -4)
			local ang = self:GetAngles()
			ang.p = 0
			
			local correction_factor = self.Orientation.p / -90
			
			self.BaseMdl:SetPos(pos - (self:GetUp() * correction_factor) + (Up * correction_factor * 1.5))
			self.BaseMdl:SetAngles(ang)
		end
		
		self.Range = self:GetNWFloat("Range", 2048)
	else
		self:PickTarget()
		
		local phys = self:GetPhysicsObject()
		
		if phys and phys:IsValid() then
			phys:Wake()
		end
	end
	
	return self:NextThink(CurTime() + 1)
end

function ENT:PickTarget()
	return EjkhsadhPickTarget(self)
end

function EjkhsadhPickTarget(self)
	local CTime = CurTime()
	
	local selfpos = self:GetPos()
	
	if self.IsDumb then
		self.RotateAngBase = self.RotateAngBase or self:GetAngles()
		
		self.Orientation = self.RotateAngBase * 1
		self.Orientation:RotateAroundAxis(Up, CTime * self.RotateSpeed)
		self.Orientation.p = Lerp(math.Clamp((self.LostTrackingAt - CTime) * .5, 0, 1), self.IdlePitch, self.Orientation.p)
		
		return
	end
	
	local target  = self.Target
	local targpos = (target and target:IsValid()) and target:GetPos() or nil
	targpos = (targpos and (targpos:Distance(selfpos) <= self.Range)) and targpos or nil
	
	if self.ClusterSlave then
		if targpos and (self.State == STATE_TRACKING) then
			self.Orientation = (targpos - selfpos):Angle()
		elseif self.State == STATE_IDLE then
			self.RotateAngBase = self.RotateAngBase or self:GetAngles()
			
			self.Orientation = self.RotateAngBase * 1
			self.Orientation:RotateAroundAxis(Up, CTime * self.RotateSpeed)
			self.Orientation.p = Lerp(math.Clamp((self.LostTrackingAt - CTime) * .5, 0, 1), self.IdlePitch, self.Orientation.p)
		end
		
		return
	end
	
	local orientation = nil
	
	if targpos then
		orientation = (targpos - selfpos):Angle()
	else
		--[[
		if targpos then
			oldtarget.LitBySpotlights = math.Clamp((target.LitBySpotlights or 0) - 1, 0, 9999)
		end
		--]]
		self.State   = STATE_IDLE
		local target = nil
		
		for k, v in pairs(ents.FindInSphere(selfpos, self.Range)) do
			if v.IsADamnPlane then
				targpos = v:GetPos()
				
				if (targpos.z >= selfpos.z) and ((v.Damage or 0) < 100) then
					self.TraceData.start  = selfpos
					self.TraceData.endpos = targpos
					
					local tr = util.TraceLine(self.TraceData)
					
					if (not tr.Hit) or (tr.Entity == v) then
						self.State = STATE_TRACKING
						target     = v
						
						self.RotateAngBase  = nil
						self.LostTrackingAt = CTime + 2
						
						--v.LitBySpotlights = (v.LitBySpotlights or 0) + 1
						
						break
					end
				end
			end
		end
		
		self.Target = target
		
		if self.ClusterMaster then
			local state     = self.State
			local ang       = target and nil
			local lostat    = self.LostTrackingAt
			
			for _, v in pairs(self.Cluster) do
				if v.IsASpotlight then
					v.State  = state
					v.Target = target
					
					v.RotateAngBase  = ang or v.RotateAngBase
					v.LostTrackingAt = lostat
					--[[
					if self.Target then
						v.LitBySpotlights = (v.LitBySpotlights or 0) + 1
					end
					
					if oldtarget then
						oldtarget.LitBySpotlights = math.Clamp((oldtarget.LitBySpotlights or 0) - 1, 0, 9999)
					end
					--]]
				end
			end
		end
	end
	
	if target and targpos and (self.State == STATE_TRACKING) then
		if self.ClusterMaster then
			local targetvel = target and target:GetVelocity():Length() or nil
			
			for _, v in pairs(self.Flaks) do
				local direction = (targpos - v:GetPos()):Angle()
				
				v:SetPoseParameter("aim_yaw",         direction.yaw)
				v:SetPoseParameter("aim_pitch", 360 - direction.pitch)
				
				if CTime > v.LastSpotlightGovernedFire then
					v:FireGun(targpos, targetvel)
					ErrorNoHalt(v, "\n")
					v.LastSpotlightGovernedFire = CTime + math.Rand(2.5, 3)
				end
			end
		end
		
		self.Orientation = orientation or (targpos - selfpos):Angle()
	else
		self.RotateAngBase = self.RotateAngBase or self:GetAngles()
		
		self.Orientation = self.RotateAngBase * 1
		self.Orientation:RotateAroundAxis(Up, CTime * self.RotateSpeed)
		self.Orientation.p = Lerp(math.Clamp((self.LostTrackingAt - CTime) * .5, 0, 1), self.IdlePitch, self.Orientation.p)
	end
end

function djasbhdkjaskdnmaskldnPickTarget(self)
	
end

function ENT:OnRemove()
	if CLIENT then
		return self.BaseMdl:Remove()
	else
		if self.Spotlight then
			self.Spotlight:Remove()
		end
	end
end
