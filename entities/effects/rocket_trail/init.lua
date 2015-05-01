

local mats = {"modulus/particles/Fire1","modulus/particles/Fire2", "modulus/particles/Smoke1", "modulus/particles/Smoke1"}

local explode_glow = Material( "sprites/light_glow02" )
explode_glow:SetInt( "$spriterendermode", RENDERMODE_GLOW )

function EFFECT:Init( data ) 
	self.rocket = data:GetEntity()
	self.pixel_vis = util.GetPixelVisibleHandle()
 	if !IsValid(self.rocket) then return end
	self.emitter = ParticleEmitter( self.rocket:GetPos())
	self:SetRenderBounds( Vector(-10000,-10000,-10000),  Vector(10000,10000,10000))
	self.start = CurTime()
	self.stage = 1
	self.fake_scale = 1
	self.rocket:SetModelScale(self.fake_scale, 0)
	self:EmitSound("ambient/levels/launch/rockettakeoffblast.wav", 100, 100)
end

function EFFECT:Think()
   	if not IsValid( self.rocket) or self.start + GAMEMODE.RoundPostLength + 1 < CurTime() then
		self.rocket:SetModelScale(1,0)
		return false
	end
	local xy_rand = 50 * self.fake_scale
	self.p_pos = self.rocket:GetPos() + Vector(math.random(-xy_rand, xy_rand),math.random(-xy_rand, xy_rand), 0)
	local die_time = 10
	local p = self.emitter:Add("modulus/particles/Smoke"..math.random(1,2), self.p_pos	)
	if p then
		local vel =	self.rocket:GetVelocity() + (self.rocket:GetUp() * -2000) + (VectorRand() * 150)
		p:SetVelocity( vel * self.fake_scale )
		p:SetDieTime( math.Rand(die_time -1, die_time + 1) )
		p:SetGravity( Vector( 0, 0, 5 ) )
		p:SetStartSize(math.random(100,120) * self.fake_scale)
		p:SetEndSize(math.random(180,200) * self.fake_scale)
		p:SetStartAlpha( math.Rand( 200, 255 ) )
		p:SetAirResistance( 100 )
		p:SetEndAlpha( 0 )
		p:SetRoll(math.random(-30,30))
		local col = math.random(150,200)
		p:SetColor(col,col,col,math.random(180,250))
	end
	if self.stage == 1 then
		self.p_pos = self.rocket:GetPos() + Vector(math.random(-xy_rand, xy_rand),math.random(-xy_rand, xy_rand), math.random(-100,0))
		self.p_pos.z = self.p_pos.z * self.fake_scale
		local p = self.emitter:Add("modulus/particles/Smoke"..math.random(1,2), self.p_pos	)
		if p then
			local vel =	VectorRand() * 1500
			vel.z = 0
			p:SetVelocity( vel )
			p:SetDieTime( math.Rand(die_time * 0.5, die_time * 0.5) )
			p:SetGravity( Vector( 0, 0, 100 ) )
			p:SetStartSize(math.random(250,300))
			p:SetEndSize(math.random(350,400))
			p:SetStartAlpha( math.Rand( 200, 255 ) )
			p:SetAirResistance( 100 )
			p:SetEndAlpha( 0 )
			p:SetRoll(math.random(-30,30))
			local col = math.random(150,200)
			p:SetColor(col,col,col,math.random(180,250))
			if self.start + 4 < CurTime() then self.stage = 2 end
		end
	end
	if self.start + 16 < CurTime() then
		self.fake_scale = math.Approach(self.fake_scale, 0.1, 0.003)
		self.rocket:SetModelScale(self.fake_scale,0)
	end
	return true
end
 
function EFFECT:Render()
	local glow_pos = self.rocket:GetPos() + (self.rocket:GetUp() * -100)
	local vis = util.PixelVisible( glow_pos, 512, self.pixel_vis)
	vis = self.fake_scale
	
	render.SetMaterial(explode_glow)
	local size = vis * (self.start + 1 - CurTime()) * 200
	render.DrawSprite(glow_pos, size,  size, Color(255,150,150,255 * vis))

	local position = glow_pos
	local distance = 25000
	local amount = 0.1
	local size = (math.sin(CurTime() * 100) + 2)
	local dotProduct = math.Clamp(EyeVector():DotProduct((position-EyePos()):Normalize())-0.5, 0, 1) * 2
	local distance = math.Clamp((position-EyePos()):Length() / -distance + 1, 0, 1)
	local screenPos = position:ToScreen()
	DrawSunbeams( 0, (amount*dotProduct*vis)*distance, size*math.abs(distance*-1+1), screenPos.x / ScrW(), screenPos.y / ScrH()) 
end

