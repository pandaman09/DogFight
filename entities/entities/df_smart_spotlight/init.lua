AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local current_map_is_cvn78_b2 = (game.GetMap() == "df_cvn78_b2")

function ENT:SpawnFunction(ply, tr)
	if not tr.Hit then return end
	
	local ent = ents.Create("df_smart_spotlight")
	ent:SetPos(tr.HitPos)
	ent:Spawn()
	ent:Activate()
	
	return ent
end

ENT.PhysSimParameters = {maxspeed         = 1000000,
						 maxangular       = 1000000,
						 maxspeeddamp     = 1000000,
						 maxangulardamp   = 1000000,
						 dampfactor       = .8,
						 secondstoarrive  = .25,
						 teleportdistance = 0}

function ENT:PhysicsSimulate(phys, delta)
	self.PhysSimParameters.pos   = self.Position
	self.PhysSimParameters.angle = self.Orientation
	self.PhysSimParameters.deltatime = delta
	
	return phys:ComputeShadowControl(self.PhysSimParameters) 
end

function ENT:KeyValue(k, v)
	if k == "team" then
		self.IsTeamGBU = (v == "gbu")
	elseif k == "range" then
		self.Range = tonumber(v) or 2048
		
		return self:SetNWFloat("Range", self.Range)
	elseif k == "cluster" then
		self.ClusterGUID = self.ClusterGUID or v
		
		return self:SetName(v)
	elseif k == "dumb" then
		self.IsDumb = (v == "1")
	elseif current_map_is_cvn78_b2 then
		local pos = self:GetPos()
		
		local idc = ((pos.x <  10400) and (pos.x > 9700) and
		             (pos.y <  6200)  and (pos.y > 5900)  and
		             (pos.z < -400))
		
		if idc then -- It's actually cluster_idc_4!
			self.ClusterGUID = "cluster_idc_4"
			
			return self:SetName("cluster_idc_4")
		end
		
		local gbu = ((pos.x < -7900) and (pos.x > -8700) and
		             (pos.y < -5700) and (pos.y > -6000) and
		             (pos.z < -400))
		
		if gbu then -- It's actually cluster_gbu_4!
			Msg(self, " is cluster_gbu_4!\n")
			self.ClusterGUID = "cluster_gbu_4"
			
			return self:SetName("cluster_gbu_4")
		end
	end
end
