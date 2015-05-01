
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

local MAX_TREES = 50

function ENT:Initialize()

end

function ENT:SpawnFunction( ply, tr)

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 1
	
	local ent = ents.Create( "trees" )
	
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	
	return ent
	
end

function ENT:OnRemove()
end





