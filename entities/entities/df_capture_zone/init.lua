
ENT.Type = "brush"  
ENT.Base = "base_entity" 
ENT.Team = -1

function ENT:Initialize()
end

function ENT:KeyValue(k,v)
	if k == "team" then
		self.Team = tonumber(v)
	end
end

function ENT:StartTouch(ent)
	local rocket = GAMEMODE:GetRocket(self.Team)
	if ent:GetClass() == "df_plane" and ent:GetTeam() == self.Team and ent:GetHasFuelPod() then
		rocket.dt.Fuel = rocket.dt.Fuel + 1
		local pod = ent.ePod
		ent:GetDriver():ScoringEvent("capture")
		if ent:GetDriver().lb then
			ent:GetDriver().lb_captures = ent:GetDriver().lb_captures + 1
		end
		ent:SetHasFuelPod(false)
		ent.ePod = nil
		pod:GetNode():OnPodCapture() // tell it its pod has been capped
	end
end

