
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
	self:SetPos(self:GetPlane():GetPos())
	self:SetAngles(self:GetPlane():GetAngles())
	self:SetParent(self:GetPlane())
	self:SetNextFire(0);
end

function ENT:ShouldUse(driver, plane)
	if IsValid(driver:GetTarget()) and plane:GetLastDamage() + 5 < CurTime() then
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
	local mine = ents.Create("wep_mine_entity")
	mine:SetPlane(self:GetPlane())
	mine:SetPos(self:GetPos())
	local col = team.GetColor(self:GetPlane():GetTeam())
	col.a = 255
	mine:SetColor(col.r,col.g,col.b,col.a)
	mine:Spawn()
	self:SetNextFire(CurTime() + 0.2)
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






