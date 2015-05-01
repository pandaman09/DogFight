
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

AccessorFunc(ENT,"ePlane", "Plane")
AccessorFunc(ENT,"iNextFire", "NextFire", NUMBER)

function ENT:Initialize()
	self:SetOwner(self:GetPlane())
	self.Entity:SetModel("models/weapons/W_missile_launch.mdl")
	self.Entity:SetMoveType( MOVETYPE_NONE)
	self.Entity:SetSolid( SOLID_NONE )
	self.Entity:SetNoDraw(true)
	self:SetPos(self:GetPlane():GetPos() + (self:GetPlane():GetForward() * 15) + (self:GetPlane():GetRight() * 15))
	self:SetAngles(self:GetPlane():GetAngles())
	self:SetParent(self:GetPlane())
	self:SetNextFire(0);
	self.fire_from = -1;
end

function ENT:ShouldUse(driver, plane)
	if IsValid(driver:GetTarget()) and driver:GetTarget():GetDamage() > 50 then
		return true
	end
	return false
end

function ENT:CanAttack()
	if self:GetPlane():GetHasFuelPod() then return false end
	if self:GetNextFire() > CurTime() then return false end
	if self:GetAmmo() <=  0 then return false end
	return true
end

function ENT:ResetAmmo()
	self:SetAmmo(self:GetAmmo() + self.DefaultAmmo)
end

function ENT:FireGun()
	if !self:CanAttack() then return end
	self:SetAmmo(self:GetAmmo() - 1)
	local missile = ents.Create("wep_projectile_missile")
	missile:SetPlane(self:GetPlane())
	missile:SetType(2)
	missile:SetPos(self:GetPlane():GetPos() + (self:GetPlane():GetForward() * 10) + (self:GetPlane():GetRight() * (15 * self.fire_from)))
	self.fire_from = self.fire_from * -1;
	missile:Spawn()
	self:SetNextFire(CurTime() + 0.1)
end

function ENT:Think()
	if self:GetAmmo() <= 0 then
		self:Remove()
	end
	self:NextThink(CurTime() + 1)
	return true
end

function ENT:OnRemove()
end






