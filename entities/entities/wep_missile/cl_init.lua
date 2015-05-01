include('shared.lua')

local tex = surface.GetTextureID("DFHUD/powerup_missile_heat")

local cross_tex = surface.GetTextureID("DFHUD/crosshair2")

ENT.cross_angle = 0

function ENT:GetIconMaterial()
	return tex
end

function ENT:DrawWeaponHUD()
	local plane = LocalPlayer():GetPlane()
	for k,pln in pairs(ents.FindByClass("df_plane")) do
		if pln:GetTeam() != LocalPlayer():Team() and plane != pln then
			if pln:GetDamage() and pln:GetDamage() > 50 then
				surface.SetDrawColor(team.GetColor(pln:GetTeam()))
				local pos = pln:LocalToWorld(pln:OBBCenter()):ToScreen()
				local dist = plane:GetPos():Distance(pln:GetPos())
				local size = math.Clamp((20000 - dist) / 400,0,100)
				surface.SetTexture(cross_tex)
				surface.SetDrawColor(255,255,255,255)
				self.cross_angle = self.cross_angle + 5
				local size = 38
				surface.DrawTexturedRectRotated( pos.x - (size / 2), pos.y - (size / 2), size, size, self.cross_angle )
			end
		end
	end
end

function ENT:Draw()
end


