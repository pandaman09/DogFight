
ENT.Base = "base_entity"
ENT.Type = "brush"

function ENT:Initialize()
end

function ENT:KeyValue(k,v)
	if k == "team" then
		if v == "gbu" then
			self.team = T_GBU
		elseif v == "idc" then
			self.team = T_IDC
		end
	end
end

function ENT:Touch(ent)
	if ent:GetClass() == "plane" && self.team != ent.ply:Team() && ent:GetVelocity():Length() <= 100 then
		ent.Damage = ent.Damage + 1
	end
end

function ENT:StartTouch(ent)
	if ent:GetClass() == "plane" then
		if self.team == ent.ply:Team() || !GAMEMODE.TEAM_BASED then
			ent.OnRunway = true
			ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
			if IsValid(ent.wing1) then
				ent.wing1:SetCollisionGroup(COLLISION_GROUP_WORLD)
			end
			if IsValid(ent.wing2) then
				ent.wing2:SetCollisionGroup(COLLISION_GROUP_WORLD)
			end
			if IsValid(ent.tail1) then
				ent.tail1:SetCollisionGroup(COLLISION_GROUP_WORLD)
			end
		end
	end
end

function ENT:EndTouch(ent)
	if ent:GetClass() == "plane" then
		ent.OnRunway = false
		ent:SetCollisionGroup(0)
		if IsValid(ent.wing1) then
			ent.wing1:SetCollisionGroup(0)
		end
		if IsValid(ent.wing2) then
			ent.wing2:SetCollisionGroup(0)
		end
		if IsValid(ent.tail1) then
			ent.tail1:SetCollisionGroup(0)
		end
	end
end

function ENT:Think()

end
