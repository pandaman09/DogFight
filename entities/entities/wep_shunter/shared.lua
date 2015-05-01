ENT.Type = "anim"  
ENT.Base = "base_anim"

ENT.PrintName = "Shunter"
ENT.DefaultAmmo = 1
ENT.iAmmo = ENT.DefaultAmmo

--AccessorFuncNW(ENT,"ePlane", "Plane")

function ENT:SetAmmo(num)
	self:SetNWInt("iAmmo", num)
end

function ENT:GetAmmo()
	return self:GetNWInt("iAmmo", self.DefaultAmmo)
end

function ENT:SetupDataTables()
	self:NetworkVar("Entity",0,"Plane")
end

//RegisterPowerup(ENT, "wep_shunter")