AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()
	--self.Entity:SetModel("models/Bennyg/plane/re_airboat2.mdl")
	self.Entity:SetModel("models/airboat.mdl")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_NONE )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	local world_size = game.GetWorld():GetPhysicsObject():GetAABB()
	self:SetNWInt("world_x_min", world_size[1] )
	self:SetNWInt("world_x_max", world_size[4] )
	self:SetNWInt("world_y_min", world_size[2] )
	self:SetNWInt("world_y_max", world_size[5] )
	self:SetNWInt("world_z_min", world_size[3] )
	self:SetNWInt("world_z_max", world_size[6] )

	self.Modifier = NULL
end

function ENT:SetTeam(team)
	self:SetNWInt("team_name_boat", tonumber(team) )
end

util.AddNetworkString("Spawner_OpenMenu")
function ENT:Use(pl, caller)
	self.Modifier = pl:SteamID()

	net.Start("Spawner_OpenMenu")
	end.Send(pl)
end
