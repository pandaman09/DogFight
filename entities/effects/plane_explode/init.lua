
local explode_glow = Material( "sprites/light_glow02" )
explode_glow:SetInt( "$spriterendermode", RENDERMODE_GLOW )

local explode_snd = Sound( "weapons/explode3.wav" )

function EFFECT:Init( data )
	self.pos = data:GetOrigin()
	self.pixel_vis = util.GetPixelVisibleHandle()
	self.emitter = ParticleEmitter( self.pos, false )
	self.start = CurTime()
	for i=0,30 do
		local p = self.emitter:Add( "effects/muzzleflash"..math.random( 1, 4 ), self.pos )
		p:SetDieTime(math.Rand(1.3,2.3))
		p:SetGravity( VectorRand() * 200 )
		p:SetVelocity(VectorRand() * 1000)
		p:SetAirResistance(400)
		p:SetStartSize(math.Rand(70,150))
		p:SetEndSize(math.Rand(160,180))
		p:SetRoll(math.Rand(-10,10))
		p:SetColor(100,100,100,255)
		p:SetEndAlpha( 0 )
	end
	for i=0,15 do
		local p = self.emitter:Add( "particle/particle_smokegrenade", self.pos )
		p:SetDieTime(math.Rand(4,6))
		p:SetGravity(Vector(0,0,300))
		p:SetVelocity(VectorRand() * 1000)
		p:SetAirResistance(500)
		p:SetStartSize(math.Rand(50,70))
		p:SetEndSize(math.Rand(90,100))
		p:SetRoll(math.Rand(-5,5))
		p:SetColor(150,150,150,255)
	end
	for i=1,4 do
		local ED = EffectData()
		ED:SetOrigin(self.pos)
		ED:SetStart(data:GetStart())
		ED:SetScale(i)
		util.Effect("plane_gib", ED)
	end
	//self:EmitSound(explode_snd)
 end

 
function EFFECT:Think()
	if self.start + 1 < CurTime() then
		return false
	else
		return true
	end
end
 
function EFFECT:Render()
	local vis = util.PixelVisible( self.pos, 64, self.pixel_vis)
	render.SetMaterial(explode_glow)
	local size = vis * (self.start + 1 - CurTime()) * 400
	render.DrawSprite(self.pos, size,  size, Color(255,150,150,255 * vis))
end
