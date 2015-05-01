
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

AccessorFunc(ENT,"iNextFire", "NextFire", NUMBER)

ENT.Life = 15

function ENT:Initialize()
	self.Entity:SetModel("models/props_trainstation/mount_connection001a.mdl")
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	local size = 15
	self:PhysicsInitBox(Vector(-size,-size,-size),Vector(size,size,size))
	self:SetPos(self:GetPlane():GetPos() + (self:GetPlane():GetForward() * 20) + (self:GetPlane():GetUp() * 25))
	self:SetOwner(self:GetPlane())
	self:SetAngles(self:GetPlane():GetAngles() + Angle(0,0,180))
	self:SetParent(self:GetPlane())
	self:SetNextFire(0)
	self:SetNoDraw(true)
	self.nodraw = true
	self.die_time = CurTime() + self.Life
end

function ENT:CanAttack()
	if self:GetNextFire() > CurTime() then return false end
	if self:GetAmmo() <=  0 then return false end
	if self.nodraw then return false end
	return true
end

function ENT:ResetAmmo()
	self:SetAmmo(self:GetAmmo() + self.DefaultAmmo)
end

function ENT:FireGun()
	if !self:CanAttack() then return end
	self:GetPlane():SetPhysicsDamage(0.05)
	self:SetNoDraw(false)
	self.nodraw = false
end

function ENT:Think()
	if self:GetAmmo() <= 0 then
		self:Remove()
	end
	if self.die_time < CurTime() then
		self:SetAmmo(self:GetAmmo() - 1)
		self:SetNoDraw(true)
		self.nodraw = true
		self:GetPlane():SetPhysicsDamage(1)
	end
	self:NextThink(CurTime() + 1)
	return true
end

function ENT:StartTouch(ent)
	if ent:GetClass() == "df_plane" and ent != self:GetPlane() then
		ent.Killer = self:GetPlane():GetDriver()
		ent:Explode()
		self:SetAmmo(self:GetAmmo() - 1)
		self:GetPlane():SetPhysicsDamage(1)
		self:SetNoDraw(true)
		self.nodraw = true
	end
end

function ENT:OnRemove()
end






