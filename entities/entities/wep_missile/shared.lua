ENT.Type = "anim"  
ENT.Base = "base_anim"

ENT.PrintName = "Heat Seeking Missile"
ENT.DefaultAmmo = 2
ENT.iAmmo = ENT.DefaultAmmo
ENT.PowerupWeight = 5
ENT.Tip = "Locks onto flaming planes only."

function ENT:SetAmmo(num)
	self:SetNWInt("iAmmo", num)
end

function ENT:GetAmmo()
	return self:GetNWInt("iAmmo", self.DefaultAmmo)
end

function ENT:SetupDataTables()
end

RegisterPowerup(ENT, "wep_missile")