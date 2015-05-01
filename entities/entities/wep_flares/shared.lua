ENT.Type = "anim"  
ENT.Base = "base_anim"

ENT.PrintName = "Missile Flares"
ENT.DefaultAmmo = 1
ENT.iAmmo = ENT.DefaultAmmo
ENT.PowerupWeight = 7
ENT.Tip = "Cancels missile locks."

function ENT:SetAmmo(num)
	self:SetNWInt("iAmmo", num)
end

function ENT:GetAmmo()
	return self:GetNWInt("iAmmo", self.DefaultAmmo)
end

function ENT:SetupDataTables()
end

RegisterPowerup(ENT, "wep_flares")

