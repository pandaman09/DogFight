include('shared.lua')

local MatA  = Material("tripmine_laser")
local MatB = Material("models/props_combine/stasisshield_sheet")

function ENT:Draw()
	self.Entity:DrawModel()
	local pos = self.Entity:GetPos()
	local sphere_rad = self.Entity:GetNWInt("range", 0)
	if sphere_rad >= 1 then
		render.SetMaterial(MatB)
		render.DrawBeam(pos, pos+Vector(0,0,sphere_rad), 5, 0, 0, Color(255, 0, 0, 255))
        render.DrawBeam(pos, pos+Vector(0,sphere_rad,0), 5, 0, 0, Color(0, 255, 0, 255))
        render.DrawBeam(pos, pos+Vector(sphere_rad,0,0), 5, 0, 0, Color(0, 0, 255, 255))
		render.DrawBeam(pos, pos+Vector(0,0,sphere_rad/-1), 5, 0, 0, Color(255, 0, 0, 255))
        render.DrawBeam(pos, pos+Vector(0,sphere_rad/-1,0), 5, 0, 0, Color(0, 255, 0, 255))
        render.DrawBeam(pos, pos+Vector(sphere_rad/-1,0,0), 5, 0, 0, Color(0, 0, 255, 255))
		self:SetRenderBounds(Vector(sphere_rad,sphere_rad,sphere_rad), Vector(-sphere_rad,-sphere_rad,-sphere_rad))
	end
end
