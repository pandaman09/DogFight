
function EFFECT:Init( data ) 
   
	self.pos = data:GetOrigin()
	self.emitter = ParticleEmitter(self.pos)
	self.cur = CurTime()
	self.once = false
	
	local DynaLight = DynamicLight( self:EntIndex() )
	DynaLight.Pos = self.pos
	DynaLight.r = 255
	DynaLight.g = 150
	DynaLight.b = 160
	DynaLight.Brightness = 10
	DynaLight.Decay = 800
	DynaLight.Size = 500
	DynaLight.DieTime = CurTime() + 0.8
end

local gibs = {"models/props_junk/wood_pallet001a_chunka.mdl", "models/props_junk/wood_pallet001a_chunka1.mdl"}

function EFFECT:Think()
   	if self.cur + 1 <= CurTime() then
		self.emitter:Finish( )
		return false
	end
	self:EmitSound("ambient/explosions/explode_"..math.random(1,2)..".wav", 100, 70)
	for i=0, 100 do
		local p = self.emitter:Add("modulus/particles/Fire"..math.random(1,8), self.pos)
		if p then
			local vel = VectorRand() * math.random(1000,1300)
			p:SetVelocity( vel )
			p:SetDieTime( math.Rand( 0.1,0.3) )
			p:SetGravity( Vector( 0, 0, -50 ) )
			p:SetStartSize(math.Rand(50,70))
			p:SetEndSize(math.Rand(85,110))
			p:SetRoll(math.Rand( -5, 5 ))
			p:SetStartAlpha( math.Rand( 200, 255 ) )
			p:SetAirResistance( 1 )
			p:SetEndAlpha( 0 )
			p:SetColor(100,100,100,math.random(180,250))
		end
	end
	for i=0, 10 do
		local p = self.emitter:Add("modulus/particles/Smoke"..math.random(1,6), self.pos)
		if p then
			local vel = VectorRand() * math.random(600,700)
			p:SetVelocity( vel )
			p:SetDieTime( math.Rand( 3,5) )
			p:SetGravity( Vector( 0, 0, -20 ) )
			p:SetStartSize(math.Rand(150,160))
			p:SetEndSize(math.Rand(160,170))
			p:SetRoll(math.Rand( -10, 10 ))
			p:SetStartAlpha( math.Rand( 200, 255 ) )
			p:SetAirResistance( 400 )
			p:SetEndAlpha( 0 )
			p:SetColor(100,100,100,math.random(180,250))
		end
	end
	for i=0,10 do
		local p = self.emitter:Add( "sprites/heatwave", self.pos)
		if p then
			local vel = VectorRand() * math.random(1000,1300)
			p:SetVelocity( vel )
			p:SetDieTime( math.Rand( 0.2,0.4) )
			p:SetGravity( Vector( 0, 0, -50 ) )
			p:SetStartSize(math.Rand(70,100))
			p:SetEndSize(math.Rand(120,150))
			p:SetRoll(math.Rand( -5, 5 ))
			p:SetStartAlpha( math.Rand( 255, 255 ) )
			p:SetAirResistance( 1 )
			p:SetEndAlpha( 0 )
			p:SetColor(100,100,100)
		end
	end
	return false
 end
 
 function EFFECT:Render()
 
 end

 