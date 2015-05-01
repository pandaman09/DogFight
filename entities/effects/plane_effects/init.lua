
local trail_mat = Material("trails/smoke")
trail_mat:SetInt( "$spriterendermode", RENDERMODE_GLOW )

function EFFECT:Init( data ) 
	self.plane = data:GetEntity()
 	if !IsValid(self.plane) then return end
	self.emitter = ParticleEmitter( self.plane:GetPos())
	self.last_plane_pos = self.plane:GetPos()
	self.last_tree_check = 0
	self.last_contrail_add = CurTime()
	self:SetRenderBounds( Vector(-1000,-1000,-1000),  Vector(1000,1000,1000))
 end

 
function EFFECT:Think()
   	if not IsValid( self.plane ) then
		return false
	end
	self.last_plane_pos = self.plane:GetPos()
	if !self.plane:GetCloaked() then
		self:DoDamageEffects()
	end
	--[[local trc = {}
	trc.start = self.plane:GetPos()
	trc.endpos = self.plane:GetPos() - Vector(0,0,500)
	trc.filter = self.plane
	local tr = util.TraceLine(trc)
	if tr.HitWorld and self.last_tree_check + 1 < CurTime() then
		for k,v in pairs(TREE_GENERATOR.models) do
			if IsValid(v) then
				if v:GetPos():Distance(tr.HitPos) < 300 then
					WorldSound( "player/footsteps/grass"..math.random(1,4)..".wav", self.plane:GetPos(), 150, math.random(80,120) )
				end
			end
		end
		self.last_tree_check = CurTime()
	end]]
	return true
end
 
function EFFECT:DoWingVortex()
	self.wing_points = self.wing_points or {}
	self.wing_points2 = self.wing_points2 or {}
	
	render.SetMaterial(trail_mat)
	local max_points = 10
	local color = Color(255,255,255,70)
	if IsValid(self.plane:GetDriver()) then
		color = team.GetColor(self.plane:GetDriver():Team())
		color.a = 70
	end
	local size = 2
	if self.last_contrail_add + 0.15 < CurTime() then
		local pos = self.plane:GetPos() + (self.plane:GetRight() * 23) + (self.plane:GetForward() * -2) + (self.plane:GetUp() * 2)
		table.insert(self.wing_points, 1, pos)
		if #self.wing_points >= max_points then self.wing_points[#self.wing_points] = nil end
		
		local pos = self.plane:GetPos() + (self.plane:GetRight() * -23) + (self.plane:GetForward() * -2) + (self.plane:GetUp() * 2)
		table.insert(self.wing_points2, 1, pos)
		if #self.wing_points2 >= max_points then self.wing_points2[#self.wing_points2] = nil end
		
		self.last_contrail_add = CurTime()
	end
	render.StartBeam(#self.wing_points + 1)
	render.AddBeam(
				self.plane:GetPos() + (self.plane:GetRight() * 23) + (self.plane:GetForward() * -2) + (self.plane:GetUp() * 2),
				size,
				size,
				color
				);	
	for k,v in pairs(self.wing_points) do
		local width = (1 - (k / #self.wing_points)) * size
		render.AddBeam(
				v, // Start position
				width, // Width
				width, // Texture coordinate
				color // Color
				);	
	end
	render.EndBeam()
	
	//Left Wing
	render.StartBeam(#self.wing_points2 + 1)
	render.AddBeam(
				self.plane:GetPos() + (self.plane:GetRight() * -23) + (self.plane:GetForward() * -2) + (self.plane:GetUp() * 2),
				size,
				size,
				color
				);	
	for k,v in pairs(self.wing_points2) do
		local width = (1 - (k / #self.wing_points2)) * size
		render.AddBeam(
				v,
				width,
				width,
				color
				);	
	end
	render.EndBeam()
end
 
function EFFECT:DoDamageEffects()
 	self.pose = self.plane:GetPos() + (self.plane:GetUp() * 10) + (self.plane:GetForward() * -30)
	local dmg = self.plane:GetDamage()
	if dmg then
		if dmg > 20 then
			local p = self.emitter:Add("modulus/particles/Smoke"..math.random(1,2), self.pose	)
			if p then
				local vel = (self.plane:GetVelocity() / 1.2) + Vector(0,0,math.random(5,15)) + (VectorRand() * 20)
				p:SetVelocity( vel )
				p:SetDieTime( math.Rand( 0.8,1.5) )
				p:SetGravity( Vector( 0, 0, -5 ) )
				p:SetStartSize( math.Rand( math.sqrt(dmg) + 2, math.sqrt(dmg) + 4) )
				p:SetEndSize(math.Rand( math.sqrt(dmg) + 3, math.sqrt(dmg) + 6))
				p:SetStartAlpha( math.Rand( 200, 255 ) )
				p:SetAirResistance( 10 )
				p:SetEndAlpha( 0 )
				p:SetColor(170,170,170,math.random(180,250))
			end
		end
		if dmg >= 50 then
			local p = self.emitter:Add("modulus/particles/Fire"..math.random(1,2), self.pose)
			if p then
				local vel = (self.plane:GetVelocity() / 1.2) + Vector(0,0,math.random(5,15)) + (VectorRand() * 20)
				p:SetVelocity( vel )
				p:SetDieTime( math.Rand( 0.8,1.5) )
				p:SetGravity( Vector( 0, 0, -5 ) )
				p:SetStartSize( math.Rand( math.sqrt(dmg) + 2, math.sqrt(dmg) + 4) )
				p:SetEndSize(math.Rand( math.sqrt(dmg) + 3, math.sqrt(dmg) + 6))
				p:SetStartAlpha( math.Rand( 200, 255 ) )
				p:SetAirResistance( 10 )
				p:SetEndAlpha( 0 )
				p:SetColor(255,250,250,math.random(180,250))
			end
		end
	end
end
 
function EFFECT:Render()
	self:SetPos(self.plane:GetPos())
	if !self.plane:GetCloaked() and GetConVarNumber("df_showtrails") != 0 then
		self:DoWingVortex()
	else
		self.wing_points = {} //otherwise it the beam will skip not good!
		self.wing_points2 = {}
	end
 end
