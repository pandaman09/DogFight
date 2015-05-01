
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

ENT.ShadowParams = {}
ENT.ShadowParams.secondstoarrive = 1
ENT.ShadowParams.maxangular = 10
ENT.ShadowParams.maxangulardamp = 8
ENT.ShadowParams.maxspeed = 21
ENT.ShadowParams.maxspeeddamp = 10
ENT.ShadowParams.dampfactor = 0.8
ENT.ShadowParams.teleportdistance = 0

local MaxSpeed = 5000

function ENT:Initialize()
	self.Entity:SetModel("models/props_silo/rocket_low.mdl")
	self.Entity:PhysicsInitBox(Vector(-70,-70, 10),Vector(70,70,1280))
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS  )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	local p = self:GetPhysicsObject()
	p:SetMass(50000)
	p:EnableMotion(false)
	GAMEMODE:SetRocket(self.Team, self)
	self.orig_pos = self:GetPos()
	self.speed = 5
end

function ENT:Think()
end

function ENT:Launch()
	local tr = {start=self:GetPos(),endpos=self:GetPos() + Vector(0,0,10000), filter=self}
	local trc = util.TraceLine(tr)
	if trc.HitSky then
		print("SKY TOO SHORT TO LAUNCH ROCKET SEE A MAPPER")
		return
	end
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)
	self.launch_stage = 1
	self.launch_start = CurTime()
	self:GetPhysicsObject():EnableMotion(true)
	self:GetPhysicsObject():Wake()
	self:StartMotionController()
	self:SetAngles(Angle(0,0,0))
	self.speed = 5
	local ED = EffectData()
	ED:SetEntity(self)
	util.Effect("rocket_trail", ED)
end

function ENT:Reset()
	self:SetPos(self.orig_pos)
	self:SetPos(Vector(0,0,0))
	self:SetAngles(Angle(0,0,0))
	self:GetPhysicsObject():EnableMotion(false)
	self:SetCollisionGroup(COLLISION_GROUP_NONE)
end

function ENT:PhysicsCollide(data)
end

function ENT:PhysicsSimulate(p,d)
	self.F_ang = Vector(0,0,0)
	self.F_lin = Vector(0,0,0)
	local m_pos = self:GetPos()
	local m_ang = self:GetAngles()
	local vel_ang = self:GetVelocity():Angle()
	local targ_pos = self:GetPos() + Vector(0,0,self.speed)
	self.speed = math.Approach(self.speed, MaxSpeed, 2)
	if self:GetVelocity():Length() < 400 then
		vel_ang = Angle(0,0,0)
	else
		vel_ang.p = vel_ang.p + 90
		targ_pos = targ_pos + (VectorRand() * 100)
		targ_pos = LerpVector(0.03, targ_pos, ents.FindByClass("df_map_center")[1]:GetPos())
	end
	local tr = util.TraceLine({start=self:GetPos(),endpos=self:GetPos() + Vector(0,0,2500),filter=self})
	if tr.HitSky and self.launch_stage == 1 then
		self.final_angs = vel_ang
		self.launch_stage = 2
	end
	if self.launch_stage == 2 then
		targ_pos = self:GetPos()
		vel_ang = self.final_angs
	end
	self.ShadowParams.pos = targ_pos
    self.ShadowParams.angle = vel_ang
	self.ShadowParams.deltatime = d
	p:ComputeShadowControl(self.ShadowParams) 
end


function ENT:OnRemove()
end






