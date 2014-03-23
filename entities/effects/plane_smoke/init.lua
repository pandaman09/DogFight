
function EFFECT:Init( data ) 
   
	self.plane = data:GetEntity()
 	if !IsValid(self.plane) then return end
	self.emitter = ParticleEmitter( self.plane:GetPos())
   
 end

 
function EFFECT:Think()
   	if not IsValid( self.plane ) then
		return false
	end
	self.pose = self.plane:GetPos() + (self.plane:GetUp() * 30) + (self.plane:GetForward() * -55)
	local dmg = self.plane:GetNWInt("dmg",15)
	local p = self.emitter:Add("modulus/particles/Smoke"..math.random(1,6), self.pose	)
	if p then
		local vel = (self.plane:GetVelocity() / 1.2) + Vector(0,0,math.random(5,20)) + (VectorRand() * 20)
		p:SetVelocity( vel )
		p:SetDieTime( math.Rand( 1,2) )
		p:SetGravity( Vector( 0, 0, -5 ) )
		p:SetStartSize( math.Rand( math.sqrt(dmg) + 3, math.sqrt(dmg) + 5) )
		p:SetEndSize(math.Rand( math.sqrt(dmg) + 5, math.sqrt(dmg) + 8))
		p:SetStartAlpha( math.Rand( 200, 255 ) )
		p:SetAirResistance( 10 )
		p:SetEndAlpha( 0 )
		p:SetColor(100,100,100,math.random(180,250))
	end
	if dmg >= 50 then
		local p = self.emitter:Add("modulus/particles/Fire"..math.random(1,8), self.pose)
		if p then
			local vel = (self.plane:GetVelocity() / 1.2) + Vector(0,0,math.random(5,20)) + (VectorRand() * 20)
			p:SetVelocity( vel )
			p:SetDieTime( math.Rand( 1,2) )
			p:SetGravity( Vector( 0, 0, -5 ) )
			p:SetStartSize( math.Rand( math.sqrt(dmg) + 3, math.sqrt(dmg) + 5) )
			p:SetEndSize(math.Rand( math.sqrt(dmg) + 5, math.sqrt(dmg) + 8))
			p:SetStartAlpha( math.Rand( 200, 255 ) )
			p:SetAirResistance( 10 )
			p:SetEndAlpha( 0 )
			p:SetColor(100,100,100,math.random(180,250))
		end
	end
	if dmg < 15 then return false end
	return true
 end
 
 function EFFECT:Render()
 
 end
