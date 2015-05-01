include('shared.lua')

local MAX_TREES = 2048
local TREE_COUNT = 0
local TREE_COUNT_PREDICTED = 0
local spread = 375
local randomness = 60

local tree_models = {"models/props_dogfight/tree_cluster_dogfight.mdl"}

local TREE_DEBUG = false

function ENT:Initialize()
	TREE_GENERATOR = self
	self.models = {}
	self.WaterRejects = {}
	TREE_COUNT = 0
	self:SpawnTrees()
	self.last_density_check = CurTime() + 3
end

function ENT:MakeTree(tr)
	if IsValid(self) then
		local ang = tr.HitNormal:Angle()
		ang = ang + Angle(90,0,0)
		ang.p = math.NormalizeAngle(ang.p)
		ang.r = math.NormalizeAngle(ang.r)
		local p_limit = 12
		if GetConVarNumber("df_treedense") > 7 then p_limit = 17 end
		if math.abs(ang.p) < p_limit then
			local m = ClientsideModel(table.Random(tree_models),RENDERGROUP_OPAQUE)
			m:SetPos(tr.HitPos + (tr.HitNormal * -5))
			m:SetAngles(ang)
			m:SetModelScale(0.7, 0)
			table.insert(self.models,m)
			TREE_COUNT = TREE_COUNT + 1
		end
	end
end

function ENT:SpawnTrees()
	spread = 700 - (math.Clamp(GetConVarNumber("df_treedense"),0,10) * 30)
	self.DenseSeed = math.Clamp(GetConVarNumber("df_treedense"),0,10)
	local tr = util.TraceLine({start=self:GetPos(), endpos = Vector(0,0,20000)})
	local sky_high = 0
	if tr.HitSky then
		sky_high = tr.HitPos.z
	end
	
	local spawnpos = self:GetPos()
	spawnpos.z = sky_high
	
	local trc = {start=spawnpos,endpos=spawnpos + Vector(20000,0,0),filter=self}
	local tr = util.TraceLine(trc)
	local map_x_len = tr.HitPos.x - self:GetPos().x
	
	local trc = {start=spawnpos,endpos=spawnpos + Vector(0,20000,0),filter=self}
	local tr = util.TraceLine(trc)
	local map_y_len = tr.HitPos.y - self:GetPos().y
	
	while TREE_COUNT < MAX_TREES and spawnpos.y - self:GetPos().y < map_y_len do
		local trc = {start=spawnpos,endpos=spawnpos - Vector(0,0,20000),filter=self, mask = MASK_NPCWORLDSTATIC + MASK_WATER }
		local tr = util.TraceLine(trc)
		if tr.MatType != 68 then
			table.insert(self.WaterRejects, tr.HitPos)
		end
		if tr.HitWorld and tr.MatType == 68 then
			debugoverlay.Line(trc.start, trc.endpos, 10, Color(0,255,0),false)
			if TREE_COUNT_PREDICTED % 2 == 0 then
				timer.Simple(0.001*TREE_COUNT_PREDICTED, function (ent,trace) if IsValid(ent) then ent:MakeTree(trace) end end, self,tr)
			else
				self:MakeTree(tr)
			end
			TREE_COUNT_PREDICTED = TREE_COUNT_PREDICTED + 1
		end
		spawnpos.x = spawnpos.x + spread
		if spawnpos.x - self:GetPos().x > map_x_len then
			spawnpos.x = self:GetPos().x
			spawnpos.y = spawnpos.y + spread
		end
	end
	timer.Simple((0.001 * TREE_COUNT_PREDICTED) + 1, self.PurgeTrees, self)
end

function ENT:Think()
	if self.last_density_check + 3 < CurTime() then
		if GetConVarNumber("df_treedense") != self.DenseSeed then
			self:Clear()
			self:SpawnTrees()
		end
		self.last_density_check = CurTime()
	end
end

function ENT:PurgeTrees()
	if TREE_DEBUG then
		print("------------------------------")
		print("TREE GENERATION FINISHED")
		print("TOTAL TREES: ", TREE_COUNT)
		print("------------------------------\n")
		print("--------------------------------")
		print("BEGIN PURGING BROKEN POSITIONS")
	end
	local total_purged = 0
	for k,v in pairs(self.models) do
		if IsValid(v) then
			if math.abs(v:GetAngles().p) < 5 then
				v:SetPos(v:GetPos() + Vector(math.random(-randomness,randomness), math.random(-randomness, randomness), 0))
			end
			local dist = v:GetPos():Distance(GAMEMODE:GetRocket(TEAM_RED):GetPos())
			if dist < 1024 then
				total_purged = total_purged + 1
				v:Remove()
			end
			local dist = v:GetPos():Distance(GAMEMODE:GetRocket(TEAM_BLUE):GetPos())
			if dist < 1024 then
				total_purged = total_purged + 1
				v:Remove()
			end
			for k2,v2 in pairs(ents.FindByClass("df_powerup")) do
				local dist = v:GetPos():Distance(v2:GetPos())
				if dist < 512 then
					total_purged = total_purged + 1
					v:Remove()
				end
			end
			for k2,v2 in pairs(self.WaterRejects) do
				if v2:Distance(v:GetPos()) < spread * 2 then
					total_purged = total_purged + 1
					v:Remove()
				end
			end
			if TREE_COUNT > 500 and GetConVarNumber("df_treedense") < 5 then
				if math.random(1,5) == 1 then v:Remove() end
			end
		end
	end
	if TREE_DEBUG then
		print("TREES PURGED SUCCESSFULLY")
		print("TOTAL TREES PURGED: ", total_purged)
		print("FINAL TREE COUNT: ", TREE_COUNT - total_purged)
		print("--------------------------------")
	end
end

function ENT:Draw()
end

function ENT:Clear()
	for k,v in pairs(self.models) do
		if IsValid(v) then
			v:Remove()
		end
	end
	self.models = {}
	self.WaterRejects = {}
	TREE_COUNT = 0
	TREE_COUNT_PREDICTED = 0
end

function ENT:OnRemove()
	self:Clear()
end
