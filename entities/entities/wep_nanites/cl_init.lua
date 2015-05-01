include('shared.lua')

local tex = surface.GetTextureID("DFHUD/powerup_nanites")

function ENT:GetIconMaterial()
	return tex
end

function ENT:Draw()
end


