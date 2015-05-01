ENT.Type = "anim"  
ENT.Base = "base_anim"

ENT.PrintName = "Magneto Mines"
ENT.DefaultAmmo = 3
ENT.iAmmo = ENT.DefaultAmmo
ENT.PowerupWeight = 3
ENT.Tip = "Attracts enemy planes and blows them up."

function ENT:SetAmmo(num)
	self:SetNWInt("iAmmo", num)
end

function ENT:GetAmmo()
	return self:GetNWInt("iAmmo", self.DefaultAmmo)
end

function ENT:SetupDataTables()
end

RegisterPowerup(ENT, "wep_mines")