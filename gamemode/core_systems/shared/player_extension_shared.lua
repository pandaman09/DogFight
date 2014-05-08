local Pmeta = FindMetaTable( "Player" )

--helper function
local function advRound( val, d )
	d = d or 0
	return math.Round( val * (10 ^ d) ) / (10 ^ d)
end

function Pmeta:CalcKD()
	local _deaths
	local kl = self:GetNWInt("kills", 0)
	local dt = self:GetNWInt("deaths",0)
	if kl == 0 && dt == 0 then
		_deaths = 0
	else
		if dt == 0 then
			_deaths = kl
		else
			_deaths = advRound(kl / dt, 2)
		end
	end
	return _deaths
end

function Pmeta:CheckGroup(groups )
	self.Flags = self.Flags or "U"
	for k,v in pairs(groups) do
		if string.find(string.lower(self.Flags), string.lower(v)) then
			return true
		end
	end
	return false
end