include('shared.lua')

ENT.scale = 3

function ENT:Initialize()

end

function ENT:Draw()
	self.Entity:DrawModel()
	self:SetModelScale(self.scale,0)
	local ang = self:GetAngles()
	if IsValid(self.dt.OwnerPlane) then
		local own_ang = self.dt.OwnerPlane:GetAngles()
		self:SetAngles(own_ang)
		self.scale = math.Approach(self.scale, 0, 0.1)
	else
		self.scale = math.Approach(self.scale, 3, 0.1)
		ang.y = ang.y + 1
		self:SetAngles(ang)
		EasySunbeams(self:GetPos(), 2048, 0.1, 0.1)
	end
end


