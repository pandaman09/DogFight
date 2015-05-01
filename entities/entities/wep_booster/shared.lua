ENT.Type = "anim"  
ENT.Base = "base_anim"

ENT.PrintName = "Speed Boost"
ENT.DefaultAmmo = 1
ENT.iAmmo = ENT.DefaultAmmo
ENT.PowerupWeight = 4
ENT.Life = 8
ENT.Tip = "8 second long boost."

function ENT:SetAmmo(num)
	self:SetNWInt("iAmmo", num)
end

function ENT:GetAmmo()
	return self:GetNWInt("iAmmo", self.DefaultAmmo)
end

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "Boosting")
end

RegisterPowerup(ENT, "wep_booster")