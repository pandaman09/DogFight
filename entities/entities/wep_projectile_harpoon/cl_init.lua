include('shared.lua')

function ENT:Initialize()
	self:SetModelScale(0.5, 0)
end

function ENT:Draw()
	self.Entity:DrawModel()
end


