ENT.Type = "anim"  
ENT.Base = "base_anim"

ENT.PrintName = "Homing Missile"
ENT.DefaultAmmo = 1
ENT.iAmmo = ENT.DefaultAmmo
ENT.PowerupWeight = 2
ENT.Tip = "Locks onto all enemy planes."

function ENT:SetAmmo(num)
	self:SetNWInt("iAmmo", num)
end

function ENT:GetAmmo()
	return self:GetNWInt("iAmmo", self.DefaultAmmo)
end

function ENT:SetupDataTables()
end

RegisterPowerup(ENT, "wep_missile_homing")