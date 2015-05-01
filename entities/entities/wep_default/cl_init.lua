include('shared.lua')

function ENT:Draw()
	self.Entity:DrawModel()
	self:SetModelScale(0.2, 0)
end


