include('shared.lua')

local tex = surface.GetTextureID("DFHUD/powerup_swarm")

function ENT:GetIconMaterial()
	return tex
end

function ENT:Draw()
end


