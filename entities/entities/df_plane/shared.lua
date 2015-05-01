ENT.Type = "anim"  
ENT.Base = "base_anim"
ENT.PrintName = "Plane Shell"
ENT.Author = "conman420"
ENT.Contact = ""
ENT.Purpose = "neawww"
ENT.Instructions = "spawn it"
 
ENT.Spawnable = true
ENT.AdminSpawnable = false


//NetworkVar(ENT,"eDriver","Driver") //use GetDriver() or SetDriver() to return the ply
//NetworkVar(ENT,"iThrottle","Throttle")

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "Damage")
	self:NetworkVar("Int", 1, "Team")
	self:NetworkVar("Bool", 2, "Cloaked")
	self:NetworkVar("Entity", 3, "Driver")
end

function ENT:SetDriver(driv)
	if !IsValid(driv) or !driv:IsPlayer() then return end
	self.dt.Driver = driv
end

function ENT:GetDriver()
	return self.dt.Driver
end

function ENT:SetTeam(num)
	self.dt.Team = num
end

function ENT:GetTeam()
	return self.dt.Team
end

function ENT:SetCloaked(boo)
	self.dt.Cloaked = boo
end

function ENT:GetCloaked()
	return self.dt.Cloaked
end

function ENT:SetDamage(num)
	self.dt.Damage = num
end

function ENT:GetDamage()
	local dmg = self.dt.Damage or 0
	return dmg
end



