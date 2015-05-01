
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

AccessorFunc(ENT,"ePlane", "Plane")
AccessorFunc(ENT,"iNextFire", "NextFire", NUMBER)

ENT.Life = 15

function ENT:Initialize()
	self:SetOwner(self:GetPlane())
	self.Entity:SetModel("models/weapons/W_missile_launch.mdl")
	self.Entity:SetMoveType( MOVETYPE_NONE)
	self.Entity:SetSolid( SOLID_NONE )
	self.Entity:SetNoDraw(true)
	self:SetParent(self:GetPlane())
	self:SetNextFire(0);
	self.sound = CreateSound(self:GetPlane(),"ambient/energy/force_field_loop1.wav")
end

function ENT:ShouldUse(driver, plane)
	if plane:GetDamage() > 1 then
		return true
	end
	return false
end

function ENT:CanAttack()
	if self:GetPlane():GetHasFuelPod() then return false end
	if self:GetNextFire() > CurTime() then return false end
	if self:GetAmmo() <=  0 then return false end
	if self:GetPlane():GetCloaked() then return false end
	return true
end

function ENT:ResetAmmo()
	self:SetAmmo(self:GetAmmo() + self.DefaultAmmo)
end

function ENT:End()
	self:SetAmmo(self:GetAmmo() - 1)
	self.sound:Stop()
	self:GetPlane():SetCloaked(false)
	self:GetPlane():SetMaterial(nil)
	self:GetPlane().Engine_Sound:ChangeVolume(1.5)
end

function ENT:FireGun()
	if !self:CanAttack() then return end
	self.sound:PlayEx(0.7,100)
	self:GetPlane():SetMaterial("models/shadertest/predator")
	self:GetPlane():SetCloaked(true)
	self.fire_start = CurTime()
	self:GetPlane().Engine_Sound:ChangeVolume(0.1)
	timer.Simple(self.Life, function(en) if IsValid(en) then en:End() end end, self)
end

function ENT:Think()
	if self:GetAmmo() <= 0 then
		self:Remove()
	end
	if self:GetPlane():GetCloaked() and self:GetPlane():GetHasFuelPod() then
		self:End()
	end
	self:NextThink(CurTime() + 1)
	return true
end

function ENT:OnRemove()
	self:GetPlane().Engine_Sound:ChangeVolume(1.5)
	self.sound:Stop()
end






