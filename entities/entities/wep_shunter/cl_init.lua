include('shared.lua')

local tex = surface.GetTextureID("DFHUD/powerup_booster")

function ENT:GetIconMaterial()
	return tex
end

function ENT:Draw()
	if IsValid(self:GetPlane()) then
		self:SetPos(self:GetPlane():GetPos() + (self:GetPlane():GetForward() * 20) + (self:GetPlane():GetUp() * 5))
		
		--Use Matrix instead of 'modelscale' for scaling
		local mat = Matrix()
		mat:Scale( Vector(0.25,0.6,0.25) )
		self:EnableMatrix( "RenderMultiply", mat )
		
		self:DrawModel()
	end
end


