
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
	self:SetParent(self:GetPlane())
	self:SetNextFire(0);
end

function ENT:ShouldUse(driver, plane)
	if plane:GetDamage() > 50 then
		return true
	end
	return false
end

function ENT:CanAttack()
	if self.fire_start then return false end
	if self:GetNextFire() > CurTime() then return false end
	if self:GetAmmo() <=  0 then return false end
	return true
end

function ENT:ResetAmmo()
	self:SetAmmo(self:GetAmmo() + self.DefaultAmmo)
end

function ENT:FireGun()
	if !self:CanAttack() then return end
	self.fire_start = CurTime()
	local ED = EffectData()
	ED:SetEntity(self:GetPlane())
	ED:SetScale(5)
	util.Effect("nanites",ED)
end

function ENT:Think()
	if self.fire_start then
		if self.fire_start + 5 > CurTime() then
			self:GetPlane():EmitSound("npc/dog/dog_servo"..math.random(1,3)..".wav",120,100)
			self:GetPlane():SetLastDamage(0) //Begin health regeneration
		else
			self:SetAmmo(self:GetAmmo() - 1)
			self.fire_start = nil
		end
	end
	if self:GetAmmo() <= 0 then
		self:Remove()
	end
	self:NextThink(CurTime() + 1)
	return true
end

function ENT:OnRemove()
end






