ENT.Type = "anim"  
ENT.Base = "base_anim"

ENT.PrintName = "Cloak"
ENT.DefaultAmmo = 1
ENT.iAmmo = ENT.DefaultAmmo
ENT.PowerupWeight = 6
ENT.Tip = "Makes you silent and invisible."

function ENT:SetAmmo(num)
	self:SetNWInt("iAmmo", num)
end

function ENT:GetAmmo()
	return self:GetNWInt("iAmmo", self.DefaultAmmo)
end

function ENT:SetupDataTables()
end

RegisterPowerup(ENT, "wep_stealth")