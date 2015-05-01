
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

ENT.ShadowParams = {}
ENT.ShadowParams.secondstoarrive = 1.3
ENT.ShadowParams.maxangular = 10000
ENT.ShadowParams.maxangulardamp = 10
ENT.ShadowParams.maxspeed = 14
ENT.ShadowParams.maxspeeddamp = 10
ENT.ShadowParams.dampfactor = 0.8
ENT.ShadowParams.teleportdistance = 0

ENT.MaxCharge = 100

--AccessorFunc(ENT, "eNode", "Node")


function ENT:Initialize()
	self.Entity:SetModel("models/props_junk/gascan001a.mdl")
	self:SetMaterial("models/props_dogfight/white_fuel")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS  )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self:SetCollisionGroup( COLLISION_GROUP_WORLD )
	local p = self:GetPhysicsObject()
	p:EnableMotion(false)
	GAMEMODE:SetFuelPod(self:GetTeam(), self)
	local col = team.GetColor(self:GetTeam())
	self:SetColor(col.r,col.g,col.b,col.a)
	self.dt.OwnerPlane = nil
	self:SetTrigger(true)
end

function ENT:Think()
	if self.return_time then
		if self.return_time < CurTime() then
			self:SetPos(self:GetNode():GetPos())
			for k,v in pairs(player.GetAll()) do
				v:PrintCenter(self:GetTeamText().." Fuel Returned!",1)
			end	
			self.return_time = nil
		end
	end
	self:NextThink(CurTime() + 0.1)
	return true
end

function ENT:GetTeamText()
	local team_txt = "Red"
	if self:GetTeam() == TEAM_BLUE then
		team_txt = "Blue"
	end
	return team_txt
end

function ENT:StartTouch(ent)
	if ent:GetClass() == "df_plane" && !IsValid(self.dt.OwnerPlane) and ent:GetTeam() != self:GetTeam() then
		self.dt.OwnerPlane = ent
		self:SetPos(ent:GetPos() + Vector(0,0,30))
		self:SetParent(ent)
		ent:SetHasFuelPod(true)
		ent.ePod = self
		ent:SetWingPower(1.5)
		ent:SetThrottlePower(0.7)
		ent:SetTurnPower(0.8)
		self.return_time = nil
		ent:GetDriver():ScoringEvent("pickup")
		ent:GetDriver():ShowTip("FuelPickup")
		for k,v in pairs(player.GetAll()) do
			if v:Team() == self:GetTeam() then
				v:PrintCenter(self:GetTeamText().." Fuel Taken!",3,3)
			else
				v:PrintCenter(self:GetTeamText().." Fuel Taken!",3,2)
			end
		end
	end
end

function ENT:PhysicsCollide(data)
end

function ENT:PhysicsSimulate(p,d)

end

function ENT:OnDrop()
	self.return_time = CurTime() + GAMEMODE.FuelReturnTime
	for k,v in pairs(player.GetAll()) do
		v:PrintCenter(self:GetTeamText().." Fuel Dropped!", 3)
		v:PrintCenter("Fuel returns in "..GAMEMODE.FuelReturnTime.." seconds!",3)
	end
	self:SetAngles(Angle(0,0,0))
	local trc = {}
	trc.start = self:GetPos()
	trc.endpos = self:GetPos() - Vector(0,0,200)
	trc.filter = self
	local tr = util.TraceLine(trc)
	if tr.HitWorld then
		self:SetPos(self:GetPos() + tr.HitNormal * (200 * (1 - tr.Fraction)))
	end
end

function ENT:OnRemove()
	if IsValid(self.dt.OwnerPlane) then
		self.dt.OwnerPlane:SetWingPower(1)
		self.dt.OwnerPlane:SetThrottlePower(1)
		self.dt.OwnerPlane:SetTurnPower(1)
	end
end






