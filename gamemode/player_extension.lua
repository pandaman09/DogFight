
local Pmeta = FindMetaTable( "Player" )
local Emeta = FindMetaTable( "Entity")
local ply = LocalPlayer()

function Pmeta:SendMessage(txt, chat)
	if IsValid(self) then return end
	if self.IsBot then return end
	if !chat then chat = false end
	--umsg.Start("message", self)
	--umsg.String(txt)
	--umsg.Bool(chat)
	--umsg.End()

	net.Start("message")
		net.WriteString(txt)
		net.WriteBit(chat)
	net.Send(self)
end

function Pmeta:StartCrashCam(kl)
	--umsg.Start("spec", self)
	--umsg.Entity(kl)
	--umsg.End()

	net.Start("spec")
		net.WriteEntity(kl)
	net.Send(self)
end

function Pmeta:StartNormalSpec(kl)
	if #ents.FindByClass("plane") == 0 then return end
	--umsg.Start("norm_spec", self)
	--umsg.End()

	net.Start("norm_spec")
	net.Send(self)
end

function Pmeta:SendNextSpawn(tme)
	--umsg.Start("nextspawn", self)
	--umsg.Long(tme)
	--umsg.End()

	net.Start("nextspawn")
		net.WriteInt(tme,32)
	net.Send(self)
end

function Pmeta:SendUnlocks()
	if self.UNLOCKS then
		--umsg.Start("send_ul", self)
		--umsg.Short(#self.UNLOCKS)
		--for k,v in pairs(self.UNLOCKS) do
		--	umsg.String(v)
		--end
		--umsg.End()

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

/*
function Pmeta:Save()
	local id = self:UniqueID()
	t = {}
	t.MONEY = self:GetNWInt("money",0)
	t.UNLOCKS = self.UNLOCKS
	file.Write( "dogfight/"..id..".txt", util.TableToKeyValues(t) )
end
*/

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
	if !ply.tot_crash || !ply.tot_targ_damage then Error("Player does not have this variable yet") end
	--umsg.Start("stats",self)
	--umsg.Long(ply.tot_crash)
	--umsg.Long(ply.tot_targ_damage)
	--umsg.End()

	net.Start("stats")
		net.WriteInt(ply.tot_crash, 32)
		net.WriteInt(ply.tot_targ_damage, 32)
	net.Send(self)
end

