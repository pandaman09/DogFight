
ENT.Type = "point"
ENT.Team = -1
ENT.pod_spawn_time = 0

AccessorFunc(ENT, "ePod", "Pod")

function ENT:KeyValue(k,v)
	if k == "team" then
		self.Team = tonumber(v)
	end
end

function ENT:Initialize()
	self.pod_spawn_time = 1000 //dont unless we are told
end

function ENT:Think()
	if self.pod_spawn_time < CurTime() and !IsValid(self:GetPod()) then
		self:SpawnPod()
	end
end

function ENT:OnPodCapture() //Enemy team caps our pod!
	self.pod_spawn_time = CurTime() + GAMEMODE.FuelSpawnDelay
	for k,v in pairs(player.GetAll()) do
		v:PrintCenter(self:GetPod().dt.OwnerPlane:GetDriver():Nick().." Captured the fuel pod!", 3)
		v:PrintCenter(self:GetPod():GetTeamText().." Fuel will spawn in "..GAMEMODE.FuelSpawnDelay.." seconds!",3)
	end
	self:GetPod():Remove()
end

function ENT:OnRoundStart()
	if IsValid(self:GetPod()) then self:GetPod():Remove() end
	self.pod_spawn_time = CurTime() + GAMEMODE.FuelSpawnDelay
end

function ENT:SpawnPod()
	self.ePod = ents.Create("df_fuel_pod")
	self.ePod:SetPos(self:GetPos())
	self.ePod:SetTeam(self.Team)
	self.ePod:SetNode(self)
	self.ePod:Spawn()
end
