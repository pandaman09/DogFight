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
	self:NetworkVar("Entity",0,"OwnerPlane");
	self:NetworkVar("Int",1,"Team");
	self:NetworkVar("Entity",2,"Node");
end