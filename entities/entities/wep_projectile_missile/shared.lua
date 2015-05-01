ENT.Type = "anim"  
ENT.Base = "base_anim"
ENT.PrintName = "Gun"
ENT.Author = "conman420"
ENT.Contact = ""
ENT.Purpose = "neawww"
ENT.Instructions = "spawn it"
 
ENT.Spawnable = true
ENT.AdminSpawnable = false

ENT.LifeTime = 8

--NetworkVar(ENT,"eTarget", "Target")

function ENT:SetupDataTables()
	self:NetworkVar("Entity",0,"Target")
end