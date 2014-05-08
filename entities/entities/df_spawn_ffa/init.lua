
ENT.Base = "base_point"
ENT.Type = "point"

function ENT:CSetAngles(ang)
	if not isangle(ang) then ErrorNoHalt("IDC spawn point tried to set 'angles' with wrong data type.") end
	self.angles = ang
end

function ENT:CGetAngles()
	return self.angles or Angle(0,0,0)
end