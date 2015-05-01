include('shared.lua')

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

local parts = { "sprites/light_glow02_add" }

local m_color = Color(150,150,255,255)
local m_color2 = Color(255,150,150,255)
local white = Color(255,255,255,255)

function ENT:Initialize()
	self.emitter = ParticleEmitter( self:GetPos())
	self.pixel_vis = util.GetPixelVisibleHandle()
	local mins = self:OBBMins()
	local maxs = self:OBBMaxs()
	mins.z = 0
	maxs.z = 0
	self.p_size = 80
	self.range = mins:Distance(maxs) * 0.35
	self.last_blob = 0
	self.last_particle = 0;
	self:SetModelScale(1,0)
end

function ENT:Think()
	local p_size_start = 10
	local p_size_end = 25
	if self.last_particle + 0.2 < CurTime() then
		for i = 0, 360, 90 do
			local radi = math.rad(i)
			local offset = Vector(math.sin(radi) * self.range,math.cos(radi) * self.range, 0)
			local p = self.emitter:Add( table.Random(parts), self:GetPos() + offset)
			local dir = (self:GetPos() + offset) - (self:GetPos() + Vector(0,0,self.height))
			local Ndir = dir:Normalize()
			if !p then print(dir) p=true end
			--p:SetVelocity(Ndir * -50)
			p:SetDieTime( 1.8 )
			p:SetGravity( Vector(0,0,0))
			p:SetStartSize( p_size_start )
			p:SetEndSize( p_size_end )
			if self.dt.PoweredUp then
				p:SetColor(m_color.r,m_color.g,m_color.b)
			else
				p:SetColor(m_color2.r,m_color2.g,m_color2.b)
			end
			p:SetStartAlpha( 255 )
			p:SetAirResistance( 0 )
			p:SetEndAlpha( 0 )
		end
		self.last_particle = CurTime()
	end
	if self.dt.PoweredUp then
		local p = self.emitter:Add( parts[1], self:GetPos() + Vector(0,0,self.height - 4) )
		p:SetVelocity(VectorRand() * 150)
		p:SetDieTime(0.2)
		p:SetColor(m_color.r,m_color.g,m_color.b)
		p:SetStartSize(60)
		p:SetEndSize(0)
		for i=1,2 do		
			local v = VectorRand()
			local particle = self.emitter:Add("effects/blueflare1",self:GetPos() + Vector(0,0,self.height - 4))
			particle:SetDieTime(.3)
			particle:SetStartLength(0)
			particle:SetEndLength(50)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			particle:SetStartSize(45)
			particle:SetEndSize(0)
			particle:SetGravity(v)
		end	
	end
	self:NextThink(CurTime() + 0.1)
	return true
end

function ENT:Draw()
	self.Entity:DrawModel()
end


