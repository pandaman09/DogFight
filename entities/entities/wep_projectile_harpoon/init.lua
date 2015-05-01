
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

AccessorFunc(ENT,"ePlane", "Plane")

ENT.ShadowParams = {}
ENT.ShadowParams.secondstoarrive = 1.3
ENT.ShadowParams.maxangular = 10000
ENT.ShadowParams.maxangulardamp = 10
ENT.ShadowParams.maxspeed = 14
ENT.ShadowParams.maxspeeddamp = 10
ENT.ShadowParams.dampfactor = 0.8
ENT.ShadowParams.teleportdistance = 0

function ENT:Initialize()
	self.Entity:SetModel("models/props_junk/harpoon002a.mdl")
	local hitsize = 20
	self.Entity:PhysicsInitBox(Vector(-hitsize,-hitsize,-hitsize), Vector(hitsize,hitsize, hitsize))
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS)
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
	
	self:SetAngles(self:GetPlane():GetAngles())
	self:SetOwner(self:GetPlane())
	self:SetPos(self:GetPlane():GetPos() + self:GetPlane():GetForward() * 100)
	
	self.elastic = constraint.Elastic(  self,  self:GetPlane(),  0, 0,  Vector(0,0,0), Vector(20,0,0),  0,  1,  1,  "cable/rope",  2,  true)
	
	self.vel = self:GetPlane():GetVelocity() * 7
	self.vel = self.vel + Vector(0,0,250)
	
	self:GetPhysicsObject():Wake()
	self:GetPhysicsObject():EnableMotion(true)
	self:GetPhysicsObject():SetVelocity(self.vel)
	self:SetGravity( 0.05 )
	
	self.Credit = self:GetPlane():GetDriver()
	self.DieTime = CurTime() + 1
	self.ShootSound = CreateSound(self, "weapons/tripwire/ropeshoot.wav")
	self.ShootSound:Play()
end

function ENT:Think()
	if !GAMEMODE:InRound() then
		self:Remove()
	end
	if IsValid(self.weld_entity) then
		self.ShootSound:Stop()
		if !IsValid(self.cannon) then self:Remove() return end
		self.cannon:SetAmmo(self.cannon:GetAmmo() - 1)
		self:SetPos(self.weld_entity:GetPos() + (self.weld_entity:GetForward() * -30))
		constraint.Weld(  self,  self.weld_entity,  0, 0,  -1, true )
		self.elastic:Remove()
		
		//          constraint.Rope(  Ent1,  Ent2,          Bone1,Bone2, LPos1,           LPos2,                            length,                            addlength,forcelimit,width,material,rigid )
		self.rope = constraint.Rope(  self,  self:GetPlane(),  0,  0,  Vector(0,0,0),  Vector(30,0,0),  self.weld_entity:GetPos():Distance(self:GetPlane():GetPos()),  -5,  0,  2, "cable/rope",  false )
		
		self.DieTime = CurTime() + 15
		self.harpooned = self.weld_entity
		self.weld_entity = nil
	end
	if !IsValid(self.harpooned) and self.rope then
		self:Remove()
	end
	if self.DieTime < CurTime() then self:Remove() end
	//self:GetPhysicsObject():SetVelocity(self.vel)
	self:NextThink(CurTime() + 0.1)
	return true
end

function ENT:PhysicsCollide(data)
	if data.Entity != self:GetPlane() and !IsValid(self.harpooned) then
		if data.HitEntity:GetClass() == "df_plane" and data.HitEntity:GetTeam() != self:GetPlane():GetTeam() then
			self:EmitSound("weapons/tripwire/hook.wav",100,100)
			self.weld_entity = data.HitEntity
		end
	end
end

function ENT:OnRemove()
	self.ShootSound:Stop()
end






