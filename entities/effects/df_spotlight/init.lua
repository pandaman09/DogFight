
local Beam = Material("sprites/glow_test02.vmt")
local Glow = Material("sprites/light_glow03.vmt")

local VecZero = Vector(0, 0, 0)
local ColourA = Color(255, 255, 85, 255)

function EFFECT:Init(data)
	self.HostEnt   = data:GetEntity()
	
	self.Width     = 128
	self.Range     = 1024
	self.TraceData = {filter = {self.HostEnt, self.HostEnt.BaseMdl}}
	
	self:SetColor(255, 255, 255, 254)
	
	return self:SetParent(self.HostEnt)
end

function EFFECT:Think()
	if self.HostEnt and self.HostEnt.IsValid and self.HostEnt:IsValid() then
		local fwd = self.HostEnt:GetForward()
		local rng = self.HostEnt.Range or 1024
		
		self.TraceData.start  = self.HostEnt:GetPos() + (fwd * 4) + (self.HostEnt:GetUp() * 4)
		self.TraceData.endpos = self.TraceData.start  + (fwd * rng)
		
		local tr = util.TraceLine(self.TraceData)
		
		self.StartPos = self.TraceData.start
		self.EndPos   = tr.HitPos
		
		self.Forward  = fwd
		self.Fraction = tr.Hit and tr.Fraction or 1
		
		self.Range = rng * tr.Fraction
		self.Width = math.sqrt(self.Range) * 6
		
		self:SetRenderBoundsWS(self.StartPos, self.EndPos)
		
		return true
	end
	
	local DLight = DynamicLight(self:EntIndex()) -- Kill it.
	
	if DLight then
		DLight.Pos        = VecZero
		DLight.r          = 255
		DLight.g          = 255
		DLight.b          = 85
		DLight.Decay      = .1
		DLight.DieTime    = .1
		DLight.Size       = 0
		DLight.Brightness = 9
	end 
	
	return false
end

function EFFECT:Render()
	local base = 1 / 25
	local frac = self.Fraction
	
	local startp = self.StartPos
	local endp   = self.EndPos
	local endp2  = self.TraceData.endpos
	
	local endwidth = self.Width
	local endalpha = 255 * (1 - frac)
	
	local dot = self.Forward:Dot(EyeAngles():Forward()) * -1
	dot = (dot > 0) and dot or 0
	
	local glow_c = self.StartPos + self.Forward * 3
	
	if dot > 0 then
		render.SetMaterial(Glow)
		
		render.DrawSprite(glow_c, 256, 256, Color(255, 255, 85, 255 * dot))
	end
	
	local segments = math.ceil(self.Range / 40.96) + 1
	
	render.SetMaterial(Beam)
	
	local perc = 0
	
	render.StartBeam(segments + 0)
		render.AddBeam(startp, 128, 0, Color(255, 255, 85, 255 * math.Max(1 - dot, .25)))
		
		for i = 1, (segments - 1) do
			perc = base * i
			
			render.AddBeam(LerpVector(perc, startp, endp2), Lerp(perc, 128, endwidth), frac * perc, Color(255, 255, 85, Lerp(perc, 255, endalpha) * math.Max(1 - dot, .25)))
		end
	render.EndBeam()
	
	if self.Fraction < 1 then
		render.SetMaterial(Glow)
		
		render.DrawSprite(endp, 512, 512, Color(255, 255, 85, 255 - math.Max(endalpha - 64, 0)))
	end
	
	local DLight    = DynamicLight(self:EntIndex())
	local DLightPos = endp - (self.Forward * 10)
	
	if DLight then
		DLight.Pos        = DLightPos
		DLight.r          = 255
		DLight.g          = 255
		DLight.b          = 85
		DLight.Decay      = 1
		DLight.DieTime    = CurTime() + .33
		DLight.Size       = 256
		DLight.Brightness = 5 --(16 - (self.Width * .25)) * 0.0625
	end
end
