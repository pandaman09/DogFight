include("shared.lua")

local tex = surface.GetTextureID("DFHUD/powerup_booster")

function ENT:GetIconMaterial()
	return tex
end

local eng_mat = Material("trails/physbeam")
eng_mat:SetInt( "$spriterendermode", RENDERMODE_GLOW )
local eng_glow = Material("models/roller/rollermine_glow")

function ENT:Draw()
	self:DrawModel()
	
	--Use Matrix instead of 'modelscale' for scaling
	local scale = Matrix()
	mat:Scale( Vector(0.4,0.4,0.2) )
	self:EnableMatrix( "RenderMultiply", mat)
	
	self.eng_points = self.eng_points or {}
	if self.dt.Boosting then
		render.SetMaterial(eng_mat)
		local size = 15
		local pos = self:GetPos()
		table.insert(self.eng_points, 1, pos)
		render.StartBeam(#self.eng_points)
		if #self.eng_points >= 10 then self.eng_points[#self.eng_points] = nil end -- do it twice to make extra long trails fade not disappear
		for k,v in pairs(self.eng_points) do
			local width = (1 - (k / #self.eng_points)) * size
			render.AddBeam(
					v, // Start position
					width, // Width
					width, // Texture coordinate
					Color( 240, 240, 255, 255 ) // Color
					);	
		end
		render.EndBeam()
		render.SetMaterial(eng_glow)
		render.DrawSprite(pos, size * 1.2, size * 1.2, Color(255,255,255))
	end
end
