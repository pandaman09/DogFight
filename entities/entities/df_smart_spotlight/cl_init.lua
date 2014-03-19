include("shared.lua")

--[[

ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.PrintName    = "Smart Spotlight"
ENT.Author       = "Olivier 'LuaPinapple' Hamel"
ENT.Contact      = "evilpineapple@cox.net"
ENT.Purpose      = "GAH! THE LIGHT!"
ENT.Instructions = "Bahhh"

ENT.Spawnable      = false
ENT.AdminSpawnable = true

local BaseModel = "models/props_wasteland/light_spotlight01_base.mdl"
local MainModel = "models/props_wasteland/light_spotlight01_lamp.mdl"

local VecZero  = Vector(0, 0, 0)
local UpOffset = Vector(0, 0, 14)

local STATE_IDLE        = 1
local STATE_TRACKING    = 2
local STATE_LOST_TARGET = 3
local STATE_DAMAGED     = 4

local IDLE_ROTATE_CW   = 1 -- Rotate Clockwise
local IDLE_ROTATE_CCW  = 2 -- Rotate Counter Clockwise
local IDLE_PANNING_L2R = 3 -- Panning Left  -> Right
local IDLE_PANNING_R2L = 4 -- Panning Right -> Left
local IDLE_UP_FACING   = 5 -- Going to face upwards

function ENT:Initialize()
	self.Entity:SetModel(MainModel)
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	
	self.Entity:SetCollisionGroup(COLLISION_GROUP_NONE)
	
	self.Position    = self:GetPos() + UpOffset
	self.Orientation = self:GetAngles()
	
	self.TrailingVector    = VecZero
	self.LastKnownPosition = self.Position
	
	self.State = STATE_IDLE
	self.Range = self.Range or 1024
	
	self.StartIdledAt = CurTime()
	
	if CLIENT then
		self.BaseMdl = ClientsideModel(BaseModel)
	else
		return self:StartMotionController()
	end
end

function ENT:Think()
	local phys = self:GetPhysicsObject()
	
	if phys and phys:IsValid() then
		phys:Wake()
	end
	
	self:PickTarget()
	
	if CLIENT then
		if self.BaseMdl and self.BaseMdl.IsValid and self.BaseMdl:IsValid() then
			local pos = self:GetPos() + (self:GetUp() * -4)
			local ang = self:GetAngles()
			ang.p = 0
			
			self.BaseMdl:SetPos(pos)
			self.BaseMdl:SetAngles(ang)
		end
		
		self.Range = self:GetNWFloat("Range", 1024)
		self.State = self:GetNWInt("State", STATE_LOST_TARGET)
		
		return self:NextThink(CurTime() + .25)
	end
	
	return self:NextThink(CurTime() + .5)
end

function ENT:Idlify()
	if CLIENT then return end
	
	if self and self:IsValid() then
		if self.State == STATE_LOST_TARGET then
			self.StartIdledAt = CurTime()
			
			self.SubIdle = math.random(IDLE_ROTATE_CW, IDLE_UP_FACING)
		else
			
		end
		
		self:SetNWInt("State", STATE_IDLE)
		self.State   = STATE_IDLE
		
	end
end

function ENT:PickTarget()
	local selfpos = self:GetPos()
	
	if self.State == STATE_LOST_TARGET then
		return self:DoLostTarget(selfpos)
	elseif self.Target then
		if self.Target:IsValid() and (self.Target:GetPos():Distance(selfpos) <= self.Range) then
			self.LastKnownPosition = self.Target:GetPos() + self.Target:OBBCenter()
			self.TrailingVector    = self.Target:GetVelocity()
		else
			self:SetNWInt("State", STATE_LOST_TARGET)
			self.State = STATE_LOST_TARGET
			Msg("Lost: ", self.Target, "\n")
			self.Target = nil
			
			return timer.Simple(3, self.Idlify, self)
		end
	else
		for k, v in pairs(ents.FindByClass("prop_vehicle")) do
			if v:GetPos():Distance(selfpos) > self.Range then
				self.Target = v
				
				break
			end
		end
	end
	
	return self:StabilizeAim()
end

function ENT:StabilizeAim()
	if CLIENT then return end
	
	self.Orientation = ((selfpos or self:GetPos()) - self.LastKnownPosition):Angle()
end

function ENT:DoLostTarget(selfpos)
	if CLIENT then return end
	
	self.LastKnownPosition = self.LastKnownPosition + self.TrailingVector
	
	self.Orientation = ((selfpos or self:GetPos()) - self.LastKnownPosition):Angle()
end

function ENT:OnRemove()
	if CLIENT then
		return self.BaseMdl:Remove()
	else
		-- ?
	end
end
--]]