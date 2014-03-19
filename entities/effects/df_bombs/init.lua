-- Note: This effect is pretty expensive... I wouldn't put more than 10 on a map at once

local matGlow = Material( "sprites/light_glow02" )

local sndBoom = Sound( "ambient/explosions/explode_4.wav" )
local sndBurn = Sound( "PropaneTank.Burst" )


local SmokeParticleUpdate = function( particle )

	if not particle.HasUpdated and particle:GetLifeTime() >= 0.5 * particle:GetDieTime() then
		particle:SetStartAlpha( particle:GetEndAlpha() )
		particle:SetEndAlpha( 0 )
		particle:SetNextThink( -1 )
		particle.HasUpdated = true
	else
		particle:SetNextThink( CurTime() + 0.1 )
	end

	return particle

end


function EFFECT:Init( data )

	self.Position = data:GetOrigin()
	self.Normal = data:GetNormal()

	self.Duration = 0.8 -- This controls how long the flash sprite lasts
	self.KillTime = CurTime() + self.Duration

	self.PixVis = util.GetPixelVisibleHandle()

	local emitter = ParticleEmitter( self.Position, false )
	emitter:SetNearClip( 64 ) -- This should prevent particles less than 64 units away from the player from drawing (I think)

	-- Lingering Heat-wave particles (expensive)
	for i = 1,3 do

		local norm = self.Normal + VectorRand()
		norm:Normalize()

		local pos = self.Position + norm * math.Rand( 30, 80 )

		local particle = emitter:Add( "sprites/heatwave", pos )
		particle:SetDieTime( math.Rand( 2.4, 3 ) )
		particle:SetVelocity( norm * math.Rand( 40, 150 ) + 40 * VectorRand() )
		particle:SetStartAlpha( 100 )
		particle:SetStartSize( math.Rand( 350, 400 ) )
		particle:SetEndSize( 5 )
		particle:SetRoll( math.Rand( -180, 180 ) )
		particle:SetRollDelta( math.Rand( -2, 2 ) )
		particle:SetColor( 255, 255, 255 )

	end


	--Lingering flame particles
	for i = 1,6 do

		local norm = self.Normal + VectorRand()
		norm:Normalize()

		local pos = self.Position + norm * math.Rand( 40, 80 )

		local particle = emitter:Add( "effects/muzzleflash"..math.random( 1, 4 ), pos )
		particle:SetDieTime( math.Rand( 2.5, 3.5 ) )
		particle:SetVelocity( norm * math.Rand( 50, 150 ) + 40 * VectorRand() )
		particle:SetStartAlpha( math.Rand( 100, 160 ) )
		particle:SetStartSize( math.Rand( 120, 150 ) )
		particle:SetEndSize( math.Rand( 230, 280 ) )
		particle:SetRoll( math.Rand( -180, 180 ) )
		particle:SetRollDelta( math.Rand( -1.2, 1.2 ) )
		particle:SetColor( math.Rand( 230, 255 ),  math.Rand( 230, 255 ),  math.Rand( 230, 255 ) )

	end

	--Lingering smoke particles
	for i = 1,6 do

		local norm = self.Normal + 0.8 * VectorRand()
		norm:Normalize()

		local pos = self.Position + norm * math.Rand( 60, 100 )
		local dietime = math.Rand( 2.5, 3.2 )

		local particle = emitter:Add( "particle/particle_smokegrenade", pos )
		particle:SetDieTime( dietime )
		particle:SetLifeTime( -0.3 )
		particle:SetVelocity( norm * math.Rand( 40, 240 ) + 50 * VectorRand() )
		particle:SetAirResistance( 5 )
		particle:SetStartAlpha( 0 )
		particle:SetEndAlpha( math.Rand( 120, 150 ) )
		particle:SetStartSize( math.Rand( 140, 180 ) )
		particle:SetEndSize( math.Rand( 220, 270 ) )
		particle:SetRoll( math.Rand( -180, 180 ) )
		particle:SetRollDelta( math.Rand( -1, 1 ) )
		particle:SetColor( 20, 20, 20 )
		particle.HasUpdated = false
		particle:SetThinkFunction( SmokeParticleUpdate )
		particle:SetNextThink( CurTime() + 0.49 * dietime )

	end


	--High-velocity flame particles
	for i = 1,15 do

		local norm = self.Normal:Cross( VectorRand() )
		norm:Normalize()

		local pos = self.Position + norm * math.Rand( 10, 40 )

		local particle = emitter:Add( "effects/muzzleflash"..math.random( 1, 4 ), pos )
		particle:SetDieTime( math.Rand( 2.3, 2.8 ) )
		particle:SetVelocity( norm * math.Rand( 1000, 1700 ) ) -- A big velocity makes it look more "explosive"
		particle:SetGravity( norm * 500 + VectorRand() * 300 ) -- Gravity makes the particles drift a bit even though they have a huge air resistance
		particle:SetAirResistance( 450 ) -- This prevents our particles from flying off from their big velocity
		particle:SetStartAlpha( math.Rand( 80, 140 ) )
		particle:SetStartSize( math.Rand( 100, 140 ) )
		particle:SetEndSize( math.Rand( 160, 220 ) )
		particle:SetRoll( math.Rand( -180, 180 ) )
		particle:SetRollDelta( math.Rand( -2.5, 2.5 ) )
		particle:SetColor( math.Rand( 230, 255 ),  math.Rand( 230, 255 ),  math.Rand( 230, 255 ) )

	end

	-- Glowing Embers
	for i = 1,15 do

		local norm = self.Normal + 0.4 * VectorRand()
		norm:Normalize()

		local pos = self.Position + norm * math.Rand( 70, 150 )

		local particle = emitter:Add( "effects/spark", pos )
		particle:SetDieTime( math.Rand( 6, 8 ) )
		particle:SetVelocity( norm * math.Rand( 600, 1000 ) + VectorRand() * math.Rand( 150, 400 ) )
		particle:SetGravity( Vector( 0, 0, -250 ) ) -- This makes the embers always float downwards
		particle:SetAirResistance( 50 )
		particle:SetCollide( true )
		particle:SetBounce( 0.9 )
		particle:SetStartSize( math.Rand( 4, 6 ) )
		particle:SetEndSize( 0 )
		particle:SetRoll( math.Rand( -180, 180 ) )
		particle:SetRollDelta( math.Rand( -1.5, 1.5 ) )
		particle:SetColor( 255, 220, 250 )

	end

	--Rising flame puff
	for i = 1,6 do

		local norm = self.Normal + 0.65 * VectorRand()
		norm:Normalize()

		local pos = self.Position + norm * math.Rand( 20, 80 )

		local particle = emitter:Add( "effects/muzzleflash"..math.random( 1, 4 ), pos )
		particle:SetDieTime( math.Rand( 3, 4 ) )
		particle:SetVelocity( norm * math.Rand( 300, 500 ) )
		particle:SetGravity( Vector( 0, 0, 300 ) ) -- This makes the cloud always billow upwards
		particle:SetAirResistance( 80 )
		particle:SetStartAlpha( math.Rand( 100, 160 ) )
		particle:SetStartSize( math.Rand( 120, 150 ) )
		particle:SetEndSize( math.Rand( 170, 240 ) )
		particle:SetRoll( math.Rand( -180, 180 ) )
		particle:SetRollDelta( math.Rand( -2, 2 ) )
		particle:SetColor( math.Rand( 230, 255 ),  math.Rand( 230, 255 ),  math.Rand( 230, 255 ) )

	end

	-- Rising smoke particles
	for i = -1,1,2 do

		local norm = self.Normal + 0.9 * VectorRand()
		norm:Normalize()

		local pos = self.Position + norm * math.Rand( 140, 180 )

		local particle = emitter:Add( "particle/particle_smokegrenade", pos )
		particle:SetDieTime( 4 )
		particle:SetLifeTime( -0.3 )
		particle:SetVelocity( self.Normal * math.Rand( 440, 550 ) )
		particle:SetGravity( Vector( 0, 0, 300 ) )
		particle:SetAirResistance( 80 )
		particle:SetStartAlpha( 0 )
		particle:SetEndAlpha( math.Rand( 100, 120 ) )
		particle:SetStartSize( math.Rand( 140, 180 ) )
		particle:SetEndSize( math.Rand( 250, 300 ) )
		particle:SetRoll( math.Rand( -180, 180 ) )
		particle:SetRollDelta( 0.7 * i )
		particle:SetColor( 20, 20, 20 )
		particle.HasUpdated = false
		particle:SetThinkFunction( SmokeParticleUpdate )
		particle:SetNextThink( CurTime() + 2 )

	end

	-- Rising glow particle
	local particle = emitter:Add( "sprites/light_glow02", self.Position + self.Normal * 80 )
	particle:SetDieTime( 3.5 )
	particle:SetVelocity( self.Normal * 300 )
	particle:SetGravity( Vector( 0, 0, 300 ) ) -- This makes the cloud always billow upwards
	particle:SetAirResistance( 80 )
	particle:SetStartAlpha( math.Rand( 200, 240 ) )
	particle:SetStartSize( 1600 )
	particle:SetEndSize( 1000 )
	particle:SetColor( 255, 50, 0 )

	-- Rising heatwave particle
	local particle = emitter:Add( "sprites/heatwave", self.Position + self.Normal * 80 )
	particle:SetDieTime( 3.5 )
	particle:SetGravity( Vector( 0, 0, 300 ) ) -- This makes the cloud always billow up
	particle:SetVelocity( self.Normal * 300 )
	particle:SetAirResistance( 80 )
	particle:SetStartAlpha( 100 )
	particle:SetStartSize( 500 )
	particle:SetEndSize( 5 )
	particle:SetColor( 255, 50, 0 )

	emitter:Finish()

	-- Sounds
	self:EmitSound( sndBoom )
	WorldSound( sndBurn, self.Position, 100, 100 )

	-- Dynamic light (laggy)
	local DynaLight = DynamicLight( self:EntIndex() )

	DynaLight.Pos = self.Position
	DynaLight.r = 255
	DynaLight.g = 210
	DynaLight.b = 200
	DynaLight.Brightness = 10
	DynaLight.Decay = 800
	DynaLight.Size = 500
	DynaLight.DieTime = CurTime() + self.Duration

end


function EFFECT:Think()
	return self.KillTime > CurTime()
end


function EFFECT:Render()

	-- This tells us about what percent of the pixels 50 units around self.Position are visible
	local visible = util.PixelVisible( self.Position, 50, self.PixVis )
	if not visible or visible < 0.15 then return end

	local scale = ( self.KillTime - CurTime() ) / self.Duration

	-- Blright flash
	render.SetMaterial( matGlow )
	render.DrawSprite( self.Position, 7000 * visible, 7000 * visible, Color( 255, 255, 255, 220 * scale ) )

end
