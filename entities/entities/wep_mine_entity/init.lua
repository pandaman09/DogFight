
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

AccessorFunc(ENT,"ePlane", "Plane")

ENT.ShadowParams = {}
ENT.ShadowParams.secondstoarrive = 0.5
ENT.ShadowParams.maxangular = 10000
ENT.ShadowParams.maxangulardamp = 10
ENT.ShadowParams.maxspeed = 30
ENT.ShadowParams.maxspeeddamp = 10
ENT.ShadowParams.dampfactor = 0.8
ENT.ShadowParams.teleportdistance = 0

ENT.range = 1500

ENT.PrimeDur = 5

function ENT:Initialize()
	self.Entity:SetModel("models/Roller.mdl")
	
	local size = 20
	self.Entity:PhysicsInitBox(Vector(-size,-size,-size), Vector(size,size,size))
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS  )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
	
	self:SetAngles(self:GetPlane():GetAngles())
	self:SetOwner(self:GetPlane())
	
	
	self.orig_pos = self:GetPos()
	
	self:GetPhysicsObject():SetVelocity(self:GetPlane():GetVelocity() + Vector(0,0,500))
	self:GetPhysicsObject():Wake()
	self:GetPhysicsObject():EnableGravity(false)
	self:StartMotionController()
	
	self.Credit = self:GetPlane():GetDriver()
	self.DieTime = CurTime() + self.LifeTime
	
	self.target = nil
	self.target_distance = nil
	
	self.PrimeTime = CurTime() + self.PrimeDur
	self.dt.Primed = false

	
	local trail = util.SpriteTrail(self, 0, Color(255,255,255), false, 10, 1, 2, 1/(10+1)*0.5, "trails/plasma.vmt")
	
	self:EmitSound("npc/scanner/scanner_siren1.wav",100,100)
end

function ENT:Think()
	if !GAMEMODE:InRound() then
		self:Remove()
	end
	if self.DieTime + self.LifeTime < CurTime() || !IsValid(self:GetPlane()) then self:Explode() end
	if util.TraceLine({start=self:GetPos(),endpos=self:GetPos()-Vector(0,0,10),filter=self,mask=MASK_WATER}).Hit then
		//HACK waterlevel isnt working properly so doing a trace
		self:Remove()
	end
	if self.PrimeTime < CurTime() then
		if self:GetModel() != "models/roller_spikes.mdl" then
			self:SetModel("models/roller_spikes.mdl")
		end
		self.dt.Primed = true
		self.target = nil
		self.target_distance = self.range
		local m_pos = self:GetPos()
		for k,v in pairs(ents.FindByClass("df_plane")) do
			if IsValid(v) and IsValid(self:GetPlane()) then
				local dist = v:GetPos():Distance(self:GetPos())
				local factor = math.Clamp(15 - (dist*0.003)^2,0,15)
				if v:GetTeam() != self:GetPlane():GetTeam() then
					local dist = m_pos:Distance(v:GetPos())
					if dist < self.target_distance then
						self.target = v
						self.target_distance = dist
					end
				end
			end
		end
	end
	self:NextThink(CurTime() + 0.2)
	return true
end

function ENT:PhysicsCollide(data)
	if data.Entity != self:GetPlane() then
		if data.HitEntity:GetClass() == "df_plane" and data.HitEntity:GetTeam() != self:GetPlane():GetTeam() then
			data.HitEntity:GetDriver().Killer = self.Credit
			self:Explode()
		end
	end
end

function ENT:OnTakeDamage(dmg)
	local inf = dmg:GetInflictor()
	if inf:GetClass() == "wep_default" || inf:GetClass() == "prop_dynamic" then
		if inf:GetPlane():GetTeam() != self:GetPlane():GetTeam() then
			self:Explode()
		end
	end
end

function ENT:Explode()
	local ED = EffectData()
	ED:SetOrigin(self:GetPos())
	util.Effect("explosion", ED)
	self:Remove()
end

function ENT:PhysicsSimulate(p,d)
	local targ_pos = self:GetPos()
	if IsValid(self.target) then
		local dist = self.target:GetPos():Distance(self:GetPos())
		local factor = math.Clamp(13.5 - (dist*0.003)^2,0.1,15)
		local dir = (self:GetPos() - self.target:GetPos()):Normalize()
		self.target:GetPhysicsObject():AddVelocity(dir * factor)
		if factor > 12 then
			targ_pos = Lerp(factor / 30, targ_pos, self.target:GetPos())
		end
	end
	targ_pos = targ_pos + (VectorRand() * 10)
	self.ShadowParams.pos = targ_pos
	p:ComputeShadowControl(self.ShadowParams) 
end

function ENT:OnRemove()
end






