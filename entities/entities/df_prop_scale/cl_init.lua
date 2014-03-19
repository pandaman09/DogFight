include('shared.lua')

function ENT:Draw()
	self.Entity:DrawModel()
	self:SetModelScale(Vector(0.5,0.5,0.5))
end
