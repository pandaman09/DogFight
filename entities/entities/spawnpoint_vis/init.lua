
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()
	self:SetModel("models/Bennyg/plane/re_airboat2.mdl")
	--self.Entity:SetModel("models/airboat.mdl")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then	
		phys:SetMass( 1 )
		phys:Wake()
		phys:EnableGravity( false )		
	end	
	self:SetRenderMode( RENDERMODE_TRANSALPHA )
	self:SetColor( Color(255,255,255,200) )
	self:SetUseType(SIMPLE_USE)
	
	self:SetNWInt("UID", 999 ) --fallback info
	self:SetNWInt("team_name", 0 ) --fallback info
end

function ENT:SetTeam(team)
	self:SetNWInt("team_name", team )
end

function ENT:GetTeam()
	return self:GetNWInt("team_name", 0 )
end

function ENT:SetID(id)
	self:SetNWInt("UID", id )
end

function ENT:GetID()
	return self:GetNWInt("UID", 999 )
end

function ENT:Use( a, c )
	net.Start("spawnpoint_edit_derma")
		net.WriteEntity(self)
	net.Send(a)
end