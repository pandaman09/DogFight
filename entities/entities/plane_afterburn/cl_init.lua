include('shared.lua')

function ENT:Draw()
	self:SetModelScale( Vector(2.5,2.5,2.5))
	self.Entity:DrawModel()
end
