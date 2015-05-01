
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()
	self.Entity:SetModel("models/props_trainstation/trainstation_clock001.mdl")
	self:SetColor(255,255,255,254)
	self.Entity:SetMoveType(MOVETYPE_NONE)
	self.Entity:SetSolid(SOLID_BBOX)
	self:SetMaterial("models/props_pipes/pipeset_metal")
	self:SetCollisionGroup( COLLISION_GROUP_WORLD )
	self:SetCollisionBounds(Vector(-30,-30,0),Vector(30,30,self.height + 10))
	self:SetAngles(Angle(-90,0,0))
	self:SetTrigger(true)
	self.dt.PoweredUp = false
	self:Powerup()
end

function ENT:Powerup()
	local pwp = GetRandomPowerup()
	self.PowerTab = pwp
	self.dt.PoweredUp = true
end

function ENT:Think()
	debugoverlay.Box(self:GetPos(), Vector(-30,-30,0),Vector(60,60,self.height), 1.1, Color(0,0,255), false)
	if !self.PowerTab then
		if self.NextPowerup < CurTime() then
			self:Powerup()
		end
	end
	self:NextThink(CurTime() + 1)
	return true
end

function ENT:StartTouch(ent)
	if self.PowerTab and ent:GetClass() == "df_plane" then
		ent:GetDriver():GiveWeapon(self.PowerTab.CLASS)
		self.PowerTab = nil
		self.dt.PoweredUp = false
		self.NextPowerup = CurTime() + self.DelayTime
	end
end

function ENT:OnRemove()
end






