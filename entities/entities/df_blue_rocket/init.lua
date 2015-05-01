
ENT.Type = "point"

function ENT:Initialize()
	local rocket = ents.Create("df_rocket")
	--rocket:SetTeam(TEAM_BLUE)
	rocket.Team = TEAM_BLUE
	rocket:SetPos(self:GetPos())
	rocket:Spawn()
end
