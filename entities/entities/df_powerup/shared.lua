ENT.Type = "anim"  
ENT.Base = "base_anim"
ENT.PrintName = "Gun"
ENT.Author = "conman420"
ENT.Contact = ""
ENT.Purpose = "neawww"
ENT.Instructions = "spawn it"
 
ENT.Spawnable = true
ENT.AdminSpawnable = false

ENT.height = 135
ENT.DelayTime = 8

function ENT:SetupDataTables()
	self:NetworkVar("Bool",0,"PoweredUp")
end
