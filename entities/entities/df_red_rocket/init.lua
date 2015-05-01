
ENT.Type = "point"

function ENT:Initialize()
	local rocket = ents.Create("df_rocket")
	--rocket:SetTeam(TEAM_RED)
	rocket.Team = TEAM_RED
	rocket:SetPos(self:GetPos())
	rocket:Spawn()
end

