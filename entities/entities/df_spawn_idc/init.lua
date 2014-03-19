
ENT.Base = "base_point"
ENT.Type = "point"

function ENT:KeyValue(key, val)
	if key == "angles" then
		local data = string.Explode(" ", val)
		self.ANG = Angle(0,tonumber(data[2] or data[1]),0)
	end
end
