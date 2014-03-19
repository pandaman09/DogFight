include("unlocks.lua")

GM.Name 	= "Dog Fight DM"
GM.Author 	= "Conman420"
GM.Email 	= ""
GM.Website 	= "Thread"

FLAK_MAX_HEALTH = 500

TEAM_BASED = false

UL_DEBUG = false

ROUND_ID = 0

MAP_VOTE_ROUND = 5

SPAWN_TIME = 5

CRASH_FINE = 3

PLY_SAVE_DELAY = 300

P_DONATOR_MONEY = 2

G_DONATOR_MONEY = 1.5

P_SPAWN_MULT = 0.5

G_SPAWN_MUL = 0.75

KILL_TYPE_CRASH = 1
KILL_TYPE_KILL = 2
KILL_TYPE_FLAK = 3

HELP_TEXT = "This is deathmatch kill all your opponents!"



if UL_DEBUG then
	SPAWN_TIME = 0
end

ADS = {"Got a bug? Report it to an admin or visit http://facepunch.com/showthread.php?t=137716",}

BOT_NAMES = {"Corporal Smith", "Corporal Abrahams", "Private Anderson", "Lieutenant Hughes", "Private Morgan", "Lieutenant Parker", "Private Weller"}

FLAKS = {}

 --[[
U = User
G = Gold
P = Platinum
T = Trial Admin
A = Admin
S = Super Admin
]]

local Pmeta = FindMetaTable( "Player" )

function Pmeta:CheckGroup(groups )
	self.Flags = self.Flags or "U"
	for k,v in pairs(groups) do
		if string.find(string.lower(self.Flags), string.lower(v)) then
			return true
		end
	end
	return false
end

-- WIKI
function math.AdvRound( val, d )
	d = d or 0;
	return math.Round( val * (10 ^ d) ) / (10 ^ d);
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

IDC_TARG = nil
GBU_TARG = nil

function GM:InitPostEntity()
	if SERVER then
		GBU_TARG = ents.FindByName("df_gbu_target")
		IDC_TARG = ents.FindByName("df_idc_target")
		GBU_TARG = GBU_TARG[1]
		IDC_TARG = IDC_TARG[1]
		if ValidEntity(GBU_TARG) then
			GBU_TARG:Remove()
		end
		if IsValid(IDC_TARG) then
			IDC_TARG:Remove()
		end
	end
end

for i=1, 25 do
	team.SetUp(i, "Team "..i, Color(255,255,255,255))
end

/*
team.SetUp( T_IDC, "International Destruction Corp", Color( 90, 60, 60, 255 ) )
team.SetUp( T_GBU, "Global Builders Union", Color( 60, 90, 60, 255 ) )
*/
