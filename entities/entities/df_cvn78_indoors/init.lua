
ENT.Base = "base_entity"
ENT.Type = "brush"

function ENT:Initialize()
end

function ENT:StartTouch(ent)
	ent:SetNWBool("CVN78Indoors", true)
end

function ENT:Touch(ent)
	ent:SetNWBool("CVN78Indoors", true)
end

function ENT:EndTouch(ent)
	ent:SetNWBool("CVN78Indoors", false)
end
