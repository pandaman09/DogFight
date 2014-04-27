local Pmeta = FindMetaTable( "Player" )

--helper function
local function math.AdvRound( val, d )
	d = d or 0;
	return math.Round( val * (10 ^ d) ) / (10 ^ d);
end

function Pmeta:SendMessage(txt, chat)
	if IsValid(self) then return end
	if self.IsBot then return end
	if !chat then chat = false end

	net.Start("message")
		net.WriteString(txt)
		net.WriteBit(chat)
	net.Send(self)
end

function Pmeta:StartCrashCam(kl)
	net.Start("spec")
		net.WriteEntity(kl)
	net.Send(self)
end

function Pmeta:StartNormalSpec(kl)
	if #ents.FindByClass("plane") == 0 then return end

	net.Start("norm_spec")
	net.Send(self)
end

function Pmeta:SendNextSpawn(tme)
	net.Start("nextspawn")
		net.WriteInt(tme,32)
	net.Send(self)
end

function Pmeta:SendUnlocks()
	if self.UNLOCKS then
		net.Start("send_ul")
			net.WriteInt(#self.UNLOCKS, 16)
			for k,v in pairs(self.UNLOCKS) do
				net.WriteString(v)
			end
		net.Send(self)
	end
end

function Pmeta:AddMoney(num)
	self:SetNWInt("money", self:GetNWInt("money") + num)
end

function Pmeta:TakeMoney(num)
	self:SetNWInt("money", self:GetNWInt("money") - num)
	if self:GetNWInt("money") < 0 then self:SetNWInt("money", 0) end
end

function Pmeta:GetOptions()
	local inver = tonumber(self:GetInfo("df_inverse"))
	local particles = tonumber(self:GetInfo("df_particles"))
	if inver == 0 then
		self.UPKEY = IN_FORWARD
		self.DOWNKEY = IN_BACK
	else
		self.UPKEY = IN_BACK
		self.DOWNKEY = IN_FORWARD
	end
	self.MOUSE_PITCH = util.tobool(self:GetInfo("df_mouse_pitch"))
	self.ROLL_ON = util.tobool(self:GetInfo("df_roll_on"))
end

function Pmeta:SendStats( ply )
	if !IsValid(ply) then return end
	if !ply.tot_crash then
		Error("Player does not have tot_crash yet\n")
	end
	if !ply.tot_targ_damage then
		Error("Player does not have tot_targ_damage yet\n")
	end

	net.Start("stats")
		net.WriteInt(ply.tot_crash, 32)
		net.WriteInt(ply.tot_targ_damage, 32)
	net.Send(ply)
end

function Pmeta:MoneyMessage(txt, color)
	local txt = txt or ""
	local col = ""..(color.r or "255" ).." "..(color.g or "255" ).." "..(color.b or "255" )..""
	
	net.Start("monmsg")
		net.WriteString(txt)
		net.WriteString(col)
	net.Send(self)
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
			_deaths = math.AdvRound(kl / dt, 2)
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