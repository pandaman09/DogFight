ENT.Type = "anim"  
ENT.Base = "base_anim"

ENT.PrintName = "Missile Swarm"
ENT.DefaultAmmo = 1
ENT.iAmmo = ENT.DefaultAmmo
ENT.PowerupWeight = 4
ENT.Tip = "Large swarm of dumbfire missiles."

function ENT:SetAmmo(num)
	self:SetNWInt("iAmmo", num)
end

function ENT:GetAmmo()
	return self:GetNWInt("iAmmo", self.DefaultAmmo)
end

function ENT:SetupDataTables()
end

RegisterPowerup(ENT, "wep_missile_swarm")