
local matGlow = Material( "sprites/light_glow02" )

function EFFECT:Init( data )
	self.pos = data:GetOrigin()
	self.emitter = ParticleEmitter(self.pos)
	self.cur = CurTime()
	self.PixVis = util.GetPixelVisibleHandle()
end

local gibs = {"models/props_junk/wood_pallet001a_chunka.mdl", "models/props_junk/wood_pallet001a_chunka1.mdl"}

function EFFECT:Think()
   	if self.cur + 1 <= CurTime() then
		self.emitter:Finish( )
		return false
	end
	if !self.stage then
		self:EmitSound("ambient/explosions/explode_1.wav", 150, 70)
		for i=0, 50 do
			local p = self.emitter:Add("modulus/particles/Fire"..math.random(1,6), self.pos)
			if p then
				local Speed = 100 * i
				local x = math.sin(i) * Speed
				local y = math.cos(i) * Speed
				local vel = Vector(x,y,math.random(2000,3000))
				p:SetVelocity( vel )
				p:SetDieTime( math.Rand( 1,1.5) )
				p:SetGravity( Vector( 0, 0, -200 ) )
				p:SetStartSize(math.Rand(150,160))
				p:SetEndSize(math.Rand(200,250))
				p:SetRoll(math.Rand( -10, 10 ))
				p:SetStartAlpha( math.Rand( 200, 255 ) )
				p:SetAirResistance( 400 )
				p:SetEndAlpha( 0 )
				p:SetColor(255,255,255,math.random(180,250))
			end
		end
		for i=0,10 do
			local p = self.emitter:Add( "sprites/heatwave", self.pos)
			if p then
				local vel = VectorRand() * math.random(1000,1300)
				p:SetVelocity( vel )
				p:SetDieTime( math.Rand( 3,4) )
				p:SetGravity( Vector( 0, 0, 20 ) )
				p:SetStartSize(math.Rand(400,800))
				p:SetEndSize(math.Rand(700,1000))
				p:SetRoll(math.Rand( -5, 5 ))
				p:SetRollDelta(math.Rand(-10,10))
				p:SetStartAlpha( math.Rand( 255, 255 ) )
				p:SetAirResistance( 500 )
				p:SetEndAlpha( 0 )
				p:SetColor(100,100,100)
			end
		end
		self.stage = 1
	end
	if self.stage == 1 && self.cur + 0.05 <= CurTime() then
		for i=0, 100 do
			local p = self.emitter:Add("modulus/particles/Smoke"..math.random(1,6), self.pos)
			if p then
				local vel = VectorRand() * math.random(1000,1500)
				p:SetVelocity( vel )
				p:SetDieTime( math.Rand( 4,6) )
				p:SetGravity( Vector( 0, 0, 50) + VectorRand() * 5)
				p:SetStartSize(math.Rand(200,250))
				p:SetEndSize(math.Rand(200,250))
				p:SetRoll(math.Rand( -10, 10 ))
				p:SetStartAlpha( math.Rand( 200, 255 ) )
				p:SetAirResistance( 150 )
				p:SetEndAlpha( 0 )
				p:SetColor(100,100,100,math.random(180,250))
			end
		end
		self.stage = 2
		for i = 1, 100 do
			local p = self.emitter:Add("modulus/particles/Smoke"..math.random(1,6), self.pos)
			if p then
				local vel = Vector(math.random(-350,350), math.random(-350,350), math.random(500,600) * i / 20)
				p:SetVelocity( vel )
				p:SetDieTime( math.Rand( 5,7) )
				p:SetGravity( Vector( 0, 0, 50 ) )
				p:SetStartSize(math.Rand(200,250))
				p:SetEndSize(math.Rand(200,250))
				p:SetRoll(math.Rand( -10, 10 ))
				p:SetStartAlpha( math.Rand( 200, 255 ) )
				p:SetAirResistance( 150 )
				p:SetEndAlpha( 0 )
				p:SetColor(100,100,100,math.random(180,250))
			end
		end
	end
	if self.cur + 0.7 <= CurTime() then
		for i=0, 60 do
			local p = self.emitter:Add("modulus/particles/Smoke"..math.random(1,6), self.pos + Vector(0,0,900))
			if p then
				local vel = Vector(math.random(-200,200), math.random(-200,200), math.random(-20,10))
				p:SetVelocity( vel )
				p:SetDieTime( math.Rand( 5,7) )
				p:SetGravity( Vector( 0, 0, 50 ) )
				p:SetStartSize(math.Rand(300,320))
				p:SetEndSize(math.Rand(360,370))
				p:SetRoll(math.Rand( -10, 10 ))
				p:SetStartAlpha( math.Rand( 200, 255 ) )
				p:SetAirResistance( 15 )
				p:SetEndAlpha( 0 )
				p:SetColor(100,100,100,math.random(180,250))
			end
		end
		return false
	end
	return true
 end

 function EFFECT:Render()
 	local visible = util.PixelVisible( self.pos, 50, self.PixVis )
	if not visible or visible < 0.15 then return end

	local scale = ( 1 - CurTime() ) / 0.8

	-- Blright flash
	render.SetMaterial( matGlow )
	render.DrawSprite( self.pos, 7000 * visible, 7000 * visible, Color( 255, 255, 255, 220 * scale ) )
 end
