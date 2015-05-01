
function EFFECT:Init( data )
	self.plane = data:GetEntity()
	self.emitter = ParticleEmitter( self.plane:GetPos(), false )
	self.start = CurTime()
	self.end_time = CurTime() + data:GetScale()
 end

 
function EFFECT:Think()
	if !IsValid(self.plane) then return false end
	if self.start + 0.4 < CurTime() and (self.end_time > CurTime() or (self.end_time < CurTime() and math.random(1,20) == 1)) then
		local p = self.emitter:Add( "effects/muzzleflash"..math.random( 1, 4 ), self.plane:GetPos() )
		p:SetDieTime(math.Rand(0.5,1))
		p:SetGravity( VectorRand() * 10 )
		p:SetVelocity(VectorRand() * 10)
		p:SetAirResistance(40)
		p:SetStartSize(math.Rand(20,25))
		p:SetEndSize(math.Rand(30,35))
		p:SetRoll(math.Rand(-5,5))
		p:SetColor(100,100,100,255)
		p:SetEndAlpha( 0 )
	end
	return true
end
 
function EFFECT:Render()
end
