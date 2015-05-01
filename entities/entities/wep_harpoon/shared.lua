ENT.Type = "anim"  
ENT.Base = "base_anim"

ENT.PrintName = "Harpoon Cannon"
ENT.DefaultAmmo = 1
ENT.iAmmo = ENT.DefaultAmmo
ENT.PowerupWeight = 3
ENT.Tip = "Latches onto enemy planes."

function ENT:SetAmmo(num)
	self:SetNWInt("iAmmo", num)
end

function ENT:GetAmmo()
	return self:GetNWInt("iAmmo", self.DefaultAmmo)
end

function ENT:SetupDataTables()
end

RegisterPowerup(ENT, "wep_harpoon")