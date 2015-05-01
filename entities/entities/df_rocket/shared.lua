ENT.Type = "anim"  
ENT.Base = "base_anim"
ENT.PrintName = "Gun"
ENT.Author = "conman420"
ENT.Contact = ""
ENT.Purpose = "neawww"
ENT.Instructions = "spawn it"
 
ENT.Spawnable = true
ENT.AdminSpawnable = false 

--NetworkVar(ENT, "iTeam", "Team")

function ENT:SetupDataTables()
	self:NetworkVar("Int",0,"Fuel")
	self:NetworkVar("Int",1,"Team")
end
