
ENT.Base = "base_entity"
ENT.Type = "brush"

function ENT:Initialize()
end

function ENT:KeyValue(k,v)
end

function ENT:Touch(ent)
end

function ENT:StartTouch(ent)
	if ent:GetClass() == "plane" && ent.ply:Team() == T_GBU then
		ent:Explode()
	end
end

function ENT:EndTouch(ent)
end

function ENT:Think()

end
