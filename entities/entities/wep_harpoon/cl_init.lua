include('shared.lua')

local tex = surface.GetTextureID("DFHUD/powerup_harpoon")

function ENT:GetIconMaterial()
	return tex
end

function ENT:DrawWeaponHUD()
end

function ENT:Draw()
end


