include('shared.lua')

local tex = surface.GetTextureID("DFHUD/powerup_missile_home")

local cross_tex = surface.GetTextureID("DFHUD/crosshair2")

ENT.cross_angle = 0

function ENT:GetIconMaterial()
	return tex
end

function ENT:DrawWeaponHUD()
	local plane = LocalPlayer():GetPlane()
	for k,pln in pairs(ents.FindByClass("df_plane")) do
		if pln:GetTeam() != LocalPlayer():Team() and plane != pln then
			local dist = plane:GetPos():Distance(pln:GetPos())
			if dist < 5000 then
				surface.SetDrawColor(team.GetColor(pln:GetTeam()))
				local pos = pln:LocalToWorld(pln:OBBCenter()):ToScreen()
				local size = math.Clamp((20000 - dist) / 400,0,100)
				surface.SetTexture(cross_tex)
				surface.SetDrawColor(255,255,255,255)
				self.cross_angle = self.cross_angle + 5
				surface.DrawTexturedRect( pos.x - size * 0.5, pos.y - size * 0.5, size, size )
			end
		end
	end
end

function ENT:Draw()
end


