
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

AccessorFunc(ENT,"ePlane", "Plane")
AccessorFunc(ENT,"bType", "Type")

TYPE_HOMING = 1
TYPE_HEATSEAK = 2
TYPE_DUMBFIRE = 3

ENT.ShadowParams = {}
ENT.ShadowParams.secondstoarrive = 1.3
ENT.ShadowParams.maxangular = 10000
ENT.ShadowParams.maxangulardamp = 10
ENT.ShadowParams.maxspeed = 14
ENT.ShadowParams.maxspeeddamp = 10
ENT.ShadowParams.dampfactor = 0.8
ENT.ShadowParams.teleportdistance = 0

function ENT:Initialize()
	self.Entity:SetModel("models/weapons/W_missile_launch.mdl")
	local size = 10
	if self:GetType() == TYPE_DUMBFIRE then
		size = 20
	end
	self.Entity:PhysicsInitBox(Vector(-size,-size,-size), Vector(size,size,size))
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS  )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
	self:SetAngles(self:GetPlane():GetAngles())
	self:SetOwner(self:GetPlane())
	self:GetPhysicsObject():SetVelocity(self:GetPlane():GetVelocity() * 0.3)
	self:GetPhysicsObject():Wake()
	self:StartMotionController()
	self.Credit = self:GetPlane():GetDriver()
	self.DidTarget = false
	self:GetPhysicsObject():EnableGravity(false)
	self.DieTime = CurTime() + self.LifeTime

	self.GiveDodgePoints = false //whether the target should get points f0r dodging us (1f we got close)
	
	self:EmitSound("weapons/mortar/mortar_shell_incomming1.wav",100,100)
	if self:GetType() == TYPE_DUMBFIRE then
		self.ShadowParams.maxspeed = 30
	end
end

function ENT:Think()
	if !GAMEMODE:InRound() then
		self:Remove()
	end
	if self.DieTime + self.LifeTime < CurTime() then self:Remove() end
	if self:GetType() != TYPE_DUMBFIRE then
		if !IsValid(self:GetTarget()) and !self.DidTarget then
			for k,v in pairs(ents.FindByClass("df_plane")) do
				if IsValid(v) and IsValid(self:GetPlane()) then
					if v != self:GetPlane() and (!GAMEMODE.TeamBased || v:GetTeam() != self:GetPlane():GetTeam()) then
						if !v:GetCloaked() and ((self:GetType() == TYPE_HEATSEAK and v:GetDamage() > 50) or (self:GetType() == TYPE_HOMING)) then
							local dist = self:GetPos():Distance(v:GetPos())
							local m_pos = self:GetPos() + (self:GetForward() * dist)
							local should_target = (m_pos:Distance(v:GetPos()) < 1024)
							if should_target then
								self:SetTarget(v)
								self.DidTarget = true //No targetting twice!
								self.alarm = CreateSound(self, "npc/attack_helicopter/aheli_crash_alert2.wav")
								self.alarm:PlayEx(80, 50)
								v:GetDriver():ShowTip("MissileLocked")
							end
						end
					end
				end
			end
		elseif IsValid(self:GetTarget()) then
			if (self:GetType() == TYPE_HEATSEAK and self:GetTarget():GetDamage() > 50) or (self:GetType() == TYPE_HOMING) then
				local dist = self:GetPos():Distance(self:GetTarget():GetPos())
				local pitch = 50
				if dist < 250 then
					pitch = 150
				elseif dist < 350 then
					pitch = 100
					self.GiveDodgePoints = true
				else
					pitch = 50
				end
				self.alarm:PlayEx(80, pitch)
			end
		end
	end
	self:NextThink(CurTime() + 1)
	return true
end

function ENT:PhysicsCollide(data)
	if data.Entity != self:GetPlane() then
		if data.HitEntity:GetClass() == "df_plane" then
			if data.HitEntity:GetTeam() != self:GetPlane():GetTeam() then
				data.HitEntity:GetDriver().Killer = self.Credit
			else
				return
			end
		end
	end
	self:Remove()
end

function ENT:GetHomingFactor()
	if !IsValid(self:GetTarget()) then return 0 end
	if self:GetTarget():GetCloaked() then return 0 end
	local factor = 0
	if self:GetType() == TYPE_HEATSEAK then
		local dmg = self:GetTarget():GetDamage()
		if dmg < 50 then
			factor = (dmg * 0.0005)
		else
			factor = (dmg * 0.02)
		end
	elseif self:GetType() == TYPE_HOMING then
		factor = 1 - (self:GetPos():Distance(self:GetTarget():GetPos()) / 4096)
	end
	if self:GetTarget():GetTrickRunning() then
		factor = factor * 0.25
	end
	return math.Clamp(factor,0,0.8)
end

function ENT:PhysicsSimulate(p,d)
	if !p:IsValid() then return end
	if util.TraceLine({start=self:GetPos(),endpos=self:GetPos()-Vector(0,0,10),filter=self,mask=MASK_WATER}).Hit then
		//HACK waterlevel isnt working properly so doing a trace
		//Also when these missiles touch water = instant crash.
		self:Remove()
	end
	if self.DieTime < CurTime() or (IsValid(self:GetTarget()) and self:GetTarget().flared) then
		self:StopMotionController()
		if self.GiveDodgePoints then
			if IsValid(self:GetTarget():GetDriver()) then
				self:GetTarget():GetDriver():ScoringEvent("missiledodge")
			end
		end
		self:SetTarget(nil)
		self:GetPhysicsObject():EnableGravity(true)
		if self.alarm then
			self.alarm:Stop()
		end
		return
	end
	local targ_pos = Vector(0,0,0)
	if !IsValid(self:GetTarget()) then
		targ_pos = self:GetPos() + (self:GetForward() * 50)
		if self.alarm then
			self.alarm:Stop()
		end
	else
		targ_pos = Lerp(self:GetHomingFactor(),self:GetPos() + (self:GetForward() * 30) + Vector(0,0,6), self:GetTarget():GetPos())
	end
	self.ShadowParams.angle = (targ_pos - self:GetPos()):Angle()
	if self:GetType() == TYPE_DUMBFIRE then
		targ_pos = targ_pos + (VectorRand() * 5)
	end
	self.ShadowParams.pos = targ_pos
	p:ComputeShadowControl(self.ShadowParams) 
end

function ENT:OnRemove()
	local ED = EffectData()
	ED:SetOrigin(self:GetPos())
	util.Effect("explosion", ED)
	if self.alarm then
		self.alarm:Stop()
	end
end






