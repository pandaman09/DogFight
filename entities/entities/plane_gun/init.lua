
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

ENT.plane = nil
ENT.Ammo = nil
ENT.AI = false
ENT.acc = 0.02
ENT.bull = 1
ENT.LastFire = 0

function ENT:Initialize()
	self.Entity:SetModel("models/weapons/w_smg1.mdl")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	if !self.plane then self:Remove() end
	self:SetPos(self.plane:GetPos() + (self.plane:GetForward() * 30) + (self.plane:GetUp() * 5))
	self:SetParent(self.plane)
	self:SetAngles(self.plane:GetAngles())
	self.Ammo = self.plane.MAX_AMMO
	self.sound = CreateSound(self, "df/gun.wav")
	self.sound2 = CreateSound(self, "df/gun_empty.wav")
end

function ENT:SpawnFunction( ply, tr)

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16
	
	local ent = ents.Create( "plane_gun" )
	
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	return ent
	
end

ENT.FIRE_DELAY = 0.05

function ENT:FireGun()
	if self.Ammo >= 1 && self.FIRE_DELAY + self.LastFire <=CurTime() then
		self.Ammo = self.Ammo - self.bull
		local bullet = {}
		bullet.Num = 1
		bullet.Src = self:GetPos() + (self:GetForward() * 20)
		bullet.Dir = self:GetAngles():Forward()
		bullet.Tracer = 3 * self.bull
		bullet.Spread = Vector(self.acc,self.acc,0)
		bullet.Force = 2
		bullet.Damage = 13
		self:FireBullets(bullet)
		self.LastFire = CurTime()
	end	
end

function ENT:Think()
	if self.plane.ply:KeyDown(IN_ATTACK) then
		if self.Ammo > 0 then
			self.sound2:Stop()
			self.sound:PlayEx(1,100)
		else
			self.sound:Stop()
			self.sound2:PlayEx(1,100)
			self:EmitSound("weapons/shotgun/shotgun_empty.wav", 300,70)
		end
		self.playing = true
	else
		self.playing = false
		if self.Ammo > 0 then
			self.sound:Stop()
		else
			self.sound2:Stop()
		end
	end
	self:NextThink(CurTime() + 0.2)
	return true
end

function ENT:Regen()
	self.Ammo = self.plane.MAX_AMMO
end

function ENT:OnRemove()
self.sound:Stop()
end

/*
		local ply = self.plane.ply
	 	local trace = {} 
		local dir = ply:GetAimVector()
	 	trace.start = ply:EyePos()
	 	trace.endpos = trace.start + (dir * 4096 * 4) 
	 	trace.filter = {self.plane.cam, self.plane, self.plane.ply, self}
		local tr = util.TraceLine( trace )
		local ang = tr.HitPos - self:GetPos()

*/





