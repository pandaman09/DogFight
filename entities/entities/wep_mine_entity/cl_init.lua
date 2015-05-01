include('shared.lua')

local glow_mat = Material("trails/physbeam")
glow_mat:SetInt( "$spriterendermode", RENDERMODE_GLOW )

function ENT:Initialize()
end

function ENT:Draw()
	self.Entity:DrawModel()
	
	if self.dt.Primed then
		local iat_start = self:LookupAttachment(tostring(math.random(0,11)))
		local iat_end = self:LookupAttachment(tostring(math.random(0,11)))
		for i=0,5 do //5 tries will Do
			if iat_start == iat_end then
				iat_start = self:LookupAttachment(tostring(math.random(0,11))) // Just to make sure!
				iat_end = self:LookupAttachment(tostring(math.random(0,11)))
			else
				break
			end
		end
		
		local at_start = self:GetAttachment( iat_start)
		local at_end = self:GetAttachment( iat_end)
		if !at_start then return end //The entities model isnt the spikes one!
		
		local dist = at_start.Pos:Distance(at_end.Pos)
		
		render.SetMaterial(glow_mat)
		render.StartBeam(dist)
		local dir = (at_start.Pos - at_end.Pos):Normalize()
		
		for i=0, dist do
			local pos = at_start.Pos + (dir * -i)
			if i != 1 and i != dist then
				pos = pos + VectorRand()
			end
			render.AddBeam(
			pos, // Start position
			10, // Width
			CurTime(), // Texture coordinate
			Color( 255, 255, 255, 255 ) // Color
			)
		end
		render.EndBeam()
	end
end


