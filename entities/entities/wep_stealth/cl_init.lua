include('shared.lua')

local tex = surface.GetTextureID("DFHUD/powerup_stealth")

function ENT:GetIconMaterial()
	return tex
end

function ENT:Draw()
end


