
function EFFECT:Init( data ) 
   
	self.pos = data:GetOrigin()
	self.emitter = ParticleEmitter( self.pos )
   
 end

 
function EFFECT:Think()
	for i=0, 3 do
		local p = self.emitter:Add("modulus/particles/Smoke"..math.random(1,6), self.pos )
		if p then
			local vel = VectorRand() * 5
			p:SetVelocity( vel )
			p:SetDieTime( math.Rand( 1,2) )
			p:SetGravity( Vector( 0, 0, -5 ) )
			p:SetStartSize(math.Rand(300,320))
			p:SetEndSize(math.Rand(320,330))
			p:SetStartAlpha( math.Rand( 200, 255 ) )
			p:SetAirResistance( 10 )
			p:SetEndAlpha( 0 )
			p:SetRoll(math.Rand(-10,10))
			p:SetColor(100,100,100)
		end
	end
	return false
 end
 
 function EFFECT:Render()
 
 end
