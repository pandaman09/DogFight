
local ThunderBeam = Material("effects/laser1")

local function Snd(filename, duration)
	local path = "df/cvn78/" .. filename .. ".mp3"
	
	Sound(path)
	
	return {path, duration}
end

local ThunderFar = {Snd("thunder_far_away_1", 7),
					Snd("thunder_far_away_2", 11)}

local ThunderAmbient = {Snd("thunder_1", 8),
						Snd("thunder_2", 11),
						Snd("thunder_3", 8)}

local ThunderStrike = {Snd("lightning_strike_1", 15),
					   Snd("lightning_strike_2", 12),
					   Snd("lightning_strike_3", 15),
					   Snd("lightning_strike_4", 12)}

local function Thunder(ambient_strike, skybox)
	if not ambient_strike then
		return LocalPlayer():EmitSound(ThunderAmbient[math.random(1, 3)][1])
	elseif skybox then -- Not used for now...
		return LocalPlayer():EmitSound(ThunderFar[math.random(1, 2)][1])
	else
		return LocalPlayer():EmitSound(ThunderStrike[math.random(1, 4)][1])
	end
end

local Resolution = 25

local ColA = Color(0,     0, 255, 0)
local ColB = Color(255, 255, 255, 0)

local function RenderThunder(points, skybox, arcs, pass_2, alpha)
	local col  = a and ColB or ColA
	local wide = (skybox and 64 or 256) * (pass_2 and .5 or 1)
	
	col.a = alpha
	
	for i = 0, 24 do
		local perc = 1 - ((i / 24) * .5)
		
		render.AddBeam(points[i], wide * perc * (alpha / 255), 1)
	end
end

EFFECT.Alive = true

function EFFECT:Init(data)
	self.StartPos = data:GetOrigin()
	self.EndPos   = data:GetStart()
	
	self.AmbientStrike = (data:GetMagnitude() == 1)
	self.SkyboxVarient = (data:GetScale()     == 2)
	
	self:SetRenderBoundsWS(self.StartPos, self.EndPos)
	
	for i = 1, math.random(1, 3) do
		if i == 1 then
			self:Flash()
		else
			timer.Simple(.15 * i, self.Flash, self)
		end
	end
	
	timer.Simple(self.SkyboxVarient and math.Rand(0, 3) or 0, Thunder, self.AmbientStrike, self.SkyboxVarient)
	
	return timer.Simple(1, self.Die, self)
end

function EFFECT:BuildLightning()
	self.Points    = self.Points    or  {}
	self.Distance  = self.Distance  or  self.StartPos:Distance(self.EndPos)
	self.ArcLength = self.ArcLength or (self.Distance / 25)
	
	local Angle = (self.EndPos - self.StartPos):Normalize()
	
	local base = self.StartPos

	for j = 0, 23 do
		local n      = VectorRand() * (j / 24) * (self.SkyboxVarient and 32 or 256)
		local offset = Angle * self.ArcLength
		
		base = base + offset
		
		self.Points[j] = base + ((Angle.z >= 0) and n or (n * -1))
	end
	
	self.Points[24] = self.EndPos
	
	self.Alpha = 255
end

function EFFECT:Flash()
	if not (self and self.IsValid and self:IsValid()) then return end
	
	if self.StartPos:ToScreen().visible or self.EndPos:ToScreen().visible then
		g_CVN78_FlashTime = CurTime() + .2
		
		return self:BuildLightning()
	end
end

function EFFECT:Die()
	if self and self.IsValid and self:IsValid() then
		self.Alive = false
	end
end

function EFFECT:Think()
	self.Alpha = math.Clamp((self.Alpha or 255) - (FrameTime() * 512), 0, 255)
	
	return (self.Alpha ~= 0)
end

function EFFECT:Render()
	if not self.Points then return end
	
	render.SetMaterial(ThunderBeam)
	
	render.StartBeam(25)
		local ok, err = pcall(RenderThunder, self.Points, self.SkyboxVarient, 25, false, self.Alpha)
		
		if not ok then ErrorNoHalt(err, "\n") end
	render.EndBeam()
	
	render.StartBeam(25)
		local ok, err = pcall(RenderThunder, self.Points, self.SkyboxVarient, 25, true, self.Alpha)
		
		if not ok then ErrorNoHalt(err, "\n") end
	render.EndBeam()
end
