
ENT.Base = "base_point"
ENT.Type = "point"

function ENT:KeyValue(key, val)
	if key == "Angles" then
		local data = string.Explode(" ", val)
		self.ANG = Angle(data[1],data[2],data[3])
	end
end
