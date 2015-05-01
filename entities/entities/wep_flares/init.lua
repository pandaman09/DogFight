AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

AccessorFunc(ENT,"ePlane", "Plane")
AccessorFunc(ENT,"iNextFire", "NextFire", NUMBER)

function ENT:Initialize()
	self:SetNextFire(0)
	self:SetParent(self:GetPlane())
end

function ENT:CanAttack()
	if self:GetNextFire() > CurTime() then return false end
	if self:GetAmmo() <=  0 then return false end
	return true
end

function ENT:ResetAmmo()
	self:SetAmmo(self:GetAmmo() + self.DefaultAmmo)
end

function ENT:ShouldUse(driver,plane)
	for k,v in pairs(ents.FindByClass("wep_projectile_missile")) do
		if IsValid(v:GetTarget()) and v:GetTarget() == plane then
			return true
		end
	end
	return false
end

function ENT:FireGun()
	if !self:CanAttack() then return end
	self:SetAmmo(self:GetAmmo() - 1)
	local ED = EffectData()
	ED:SetEntity(self:GetPlane())
	util.Effect("flare_spawner", ED)
	for k,v in pairs(ents.FindByClass("wep_projectile_missile")) do //stop all flares from targetting us
		if IsValid(v:GetTarget()) and v:GetTarget() == self:GetPlane() then
			if v.alarm then v.alarm:Stop() end
			v:SetTarget(nil)
		end
	end
	self:SetNextFire(CurTime() + 1)
end

function ENT:Think()
	if self:GetAmmo() <= 0 then self:Remove() end
	self:NextThink(CurTime() + 0.5)
	return true
end

function ENT:OnRemove()
end






