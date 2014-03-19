
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

ENT.plane = nil
ENT.ON_SPEED = 0.5

function ENT:Initialize()
	self.Entity:SetModel("models/props_c17/FurnitureBoiler001a.mdl")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	if !self.plane then print("OH NO!......................") self:Remove() end
	self:SetPos(self.plane:GetPos() + (self.plane:GetRight() * 120) + Vector(0,0,80))
	self:SetAngles(self:GetAngles() + Angle(0,180,270))
	self:SetParent(self.plane)
	self.charge = CreateSound(self.plane, "npc/attack_helicopter/aheli_crashing_loop1.wav")
end

function ENT:Think()
	if self.plane then
		local ply = self.plane.ply
		if !ValidEntity(ply) then self:Remove() end
		if ply:KeyDown(IN_ATTACK2) then
			self:TurnOn()
		end
	end
	self:NextThink(CurTime() + 0.1)
	return true
end

function ENT:TurnOn()
	if !self.On then
		self.charge:Play()
	end
	self.pitch = self.pitch or 100
	self.pitch = math.Approach(self.pitch, 151, 1)
	self.charge:ChangePitch(self.pitch)
	print("PITCH", self.pitch)
	if self.pitch >= 150 then
		self:Boost()
	end
end

function ENT:Boost()
	if !self.plane.ply:KeyDown(IN_ATTACK2) then
		self:TurnOff()
	end
	if !self.On then
		self:EmitSound("weapons/underwater_explode3.wav",300,100)
		self.plane.SPEED_MOD = self.ON_SPEED
		self.On = true
		self.charge:Stop()
	end
end

function ENT:TurnOff()
	self.On = false
	self.pitch = 100
	self.plane.SPEED_MOD = 5.6
	self.charge:Stop()
end

function ENT:PhysicsCollide(data)

end

function ENT:OnRemove()
	self.charge:Stop()
end






