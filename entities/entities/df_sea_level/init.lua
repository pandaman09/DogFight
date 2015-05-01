
ENT.Type = "point"

function ENT:Initialize()
	SetGlobalInt("sea_level", self:GetPos().z)
end
