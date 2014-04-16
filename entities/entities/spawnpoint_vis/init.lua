
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()
	self:SetModel("models/Bennyg/plane/re_airboat2.mdl")
	--self.Entity:SetModel("models/airboat.mdl")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetRenderMode( RENDERMODE_TRANSALPHA )
	self:SetColor( Color(255,255,255,200) )
	self:SetUseType(SIMPLE_USE)
	
	self:SetNWInt("server_id", 0 ) --fallback info
	self:SetNWInt("team_id", 0 ) --fallback info
end

function ENT:SetTeam(team)
	self:SetNWInt("team_id", team )
end

function ENT:GetTeam()
	return self:GetNWInt("team_id", 0 )
end

function ENT:SetSID(SID)
	self:SetNWInt("server_id", SID )
end

function ENT:GetSID()
	return self:GetNWInt("server_id", 0 )
end

function ENT:Use( a, c )
	net.Start("spawnpoint_edit_derma")
		net.WriteEntity(self)
	net.Send(a)
end