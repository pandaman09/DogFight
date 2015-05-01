
function EFFECT:Init( data )
	self.plane = data:GetEntity()
	self.emitter = ParticleEmitter( self.plane:GetPos(), false )
	self.start = CurTime()
	self.die_time = CurTime() + data:GetScale()
 end

 
function EFFECT:Think()
	if !IsValid(self.plane) || self.die_time < CurTime() then return false end
	for i=0, 360, 8 do
		local circle_size = 35
		local radi = math.rad(i)
		local pos = self.plane:GetPos() + Vector(0,0,5) + (self.plane:GetRight() * math.sin(radi) * circle_size) + (self.plane:GetUp() * math.cos(radi) * circle_size) + (self.plane:GetForward() * math.sin(CurTime() * 2) * 40)
		local p = self.emitter:Add( "sprites/light_glow02_add", pos)
		p:SetDieTime(math.Rand(0.1,0.15))
		p:SetGravity( VectorRand() * 10 )
		p:SetVelocity(VectorRand() * 10)
		p:SetAirResistance(40)
		p:SetStartSize(math.Rand(20,24))
		p:SetEndSize(math.Rand(26,30))
		p:SetRoll(math.Rand(-5,5))
		local col = team.GetColor(self.plane:GetTeam())
		p:SetColor(col.r,col.g,col.b,255)
		p:SetEndAlpha( 0 )
	end
	return true
end
 
function EFFECT:Render()
end
