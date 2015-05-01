
gib_models = {	"models/Bennyg/plane/re_airboat_pallet2.mdl",
				"models/Bennyg/plane/re_airboat_pallet2.mdl",
				"models/Bennyg/plane/re_airboat2.mdl",
				"models/Bennyg/plane/re_airboat_tail2.mdl"}

function EFFECT:Init( data )
	self.pos = data:GetOrigin()
	self.start = CurTime()
	self:SetModel(gib_models[data:GetScale()])
	self.Entity:PhysicsInitBox( self:OBBMins(), self:OBBMaxs()  )
	self.Entity:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
	self.Entity:SetCollisionBounds( self:OBBMins(), self:OBBMaxs() )
	self.gib_vel = data:GetStart()
	self.life_time = 30 * math.Clamp(1 - (#player.GetAll() / 32),0,1)
	local phys = self.Entity:GetPhysicsObject()
	if ( phys && phys:IsValid() ) then
		phys:SetDamping(3,0)
		phys:Wake()
		phys:SetAngles( Angle( math.Rand(0,360), math.Rand(0,360), math.Rand(0,360) ) )
		phys:SetVelocity( (VectorRand() * math.Rand( 100, 150 )) + (self.gib_vel * 2) )
		phys:AddAngleVelocity(Vector(math.Rand(-30,30),math.Rand(-30,30), math.Rand(-30,30)))
	end
	self.emitter = ParticleEmitter( self.pos, false )
 end

 
function EFFECT:Think()
	local alp = math.Clamp(self.start + self.life_time - CurTime(),0,1) * 255
	self:SetColor(255,255,255,alp)
	
	local vel = self:GetVelocity():Length()
	local die_time = math.Rand(1,2)
	if vel < 50 then
		die_time = math.Rand(1.5,2.5)
	end
	
	local p = self.emitter:Add( "particles/flamelet"..math.random(1,4), self:GetPos() )
	p:SetDieTime(die_time / 2)
	p:SetGravity(Vector(0,0,10))
	p:SetVelocity(Vector(math.random(-10,50),math.random(-10,50), math.random(10,20)))
	p:SetAirResistance(20)
	p:SetStartSize(math.Rand(5,10))
	p:SetEndSize(math.Rand(13,19))
	p:SetRoll(math.Rand(-5,5))
	p:SetColor(100,100,100,255)
	p:SetEndAlpha( 0 )
	local p = self.emitter:Add( "particle/particle_smokegrenade", self:GetPos() )
	p:SetDieTime(die_time)
	p:SetGravity(Vector(100,0,70))
	p:SetVelocity(Vector(math.random(-10,50),math.random(-10,50), 50))
	p:SetAirResistance(20)
	p:SetStartSize(0)
	p:SetEndSize(math.Rand(25,35))
	p:SetRoll(math.Rand(-5,5))
	p:SetColor(100,100,100,255)
	p:SetEndAlpha( 0 )
	if self.start + self.life_time < CurTime() then
		return false
	else
		return true
	end
end
 
function EFFECT:Render()
	self:DrawModel()
end
