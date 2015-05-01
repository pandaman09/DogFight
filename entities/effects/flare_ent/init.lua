
local explode_glow = Material( "sprites/light_glow02" )
explode_glow:SetInt( "$spriterendermode", RENDERMODE_GLOW )

function EFFECT:Init( data )
	self.plane = data:GetEntity()
	if IsValid(self.plane) then
		self.pixel_vis = util.GetPixelVisibleHandle()
		self:SetPos(self.plane:GetPos())
		self.emitter = ParticleEmitter( self.plane:GetPos(), false )
		self.start = CurTime()
		self.Entity:PhysicsInitBox( Vector(-2,-2,-2), Vector(2,2,2) )
		self.Entity:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
		self.Entity:SetCollisionBounds( Vector(-2,-2,-2), Vector(2,2,2) )
		self.life_time = 5
		local phys = self.Entity:GetPhysicsObject()
		if ( phys && phys:IsValid() ) then
			phys:SetDamping(3,0)
			phys:Wake()
			phys:SetAngle( Angle( math.Rand(0,360), math.Rand(0,360), math.Rand(0,360) ) )
			phys:SetVelocity(Vector(math.random(-100,100),math.random(-100,100), 250) + self.plane:GetVelocity())
			phys:EnableGravity(false)
			phys:AddAngleVelocity(Vector(math.Rand(-30,30),math.Rand(-30,30), math.Rand(-30,30)))
		end
	end
 end
 
function EFFECT:Think()
	if !IsValid(self.plane) then return false end
	if self.start + self.life_time < CurTime() then return false end
	if self.start + self.life_time*0.1 < CurTime() then self:GetPhysicsObject():EnableGravity(true) end
	local p = self.emitter:Add( "particle/particle_smokegrenade", self:GetPos() + VectorRand() * 10 )
	p:SetDieTime(3)
	p:SetGravity(Vector(0,0,10))
	p:SetVelocity(self:GetVelocity() + VectorRand() * 10)
	p:SetAirResistance(10)
	p:SetStartSize(5)
	p:SetEndSize(math.Rand(10,20))
	p:SetRoll(math.Rand(-5,5))
	p:SetColor(100,100,100,255)
	p:SetEndAlpha( 0 )
	return true
end
 
function EFFECT:Render()
	if IsValid(self.plane) then
		local vis = util.PixelVisible( self.plane:GetPos(), 50, self.pixel_vis)
		render.SetMaterial(explode_glow)
		local size = 50
		render.DrawSprite(self:GetPos(), size,  size, Color(255,200,200,255 * vis))
	end
end
