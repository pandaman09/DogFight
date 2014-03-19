
UNLOCKS = {}

UNLOCK_GROUPS = {}
UNLOCK_GROUPS[1] = "Colours"
UNLOCK_GROUPS[2] = "Weapons"
UNLOCK_GROUPS[3] = "Misc"
UNLOCK_GROUPS[4] = "Plane"
UNLOCK_GROUPS[5] = "Donator"

local function Register(name, TABLE)
	if UNLOCKS[name] then Error("WARNING UNLOCK REGISTERED TWICE ("..name..")") return end
	UNLOCKS[name] = TABLE
end

if SERVER then
function Disable_UL(ply,cmd,args)
	local UL = args[1]
	for k,v in pairs(UNLOCKS) do
	if v.NAME == UL then
			for k2,v2 in pairs(ply.UNLOCKS) do
				if v2.ID == k then
					v2.EN = 0
				end
			end
		end
	end
	ply:SendUnlocks()
	SaveUnlocks(ply)
end

concommand.Add("disable_ul", Disable_UL)

function Enable_UL(ply,cmd,args)
	local UL = args[1]
	for k,v in pairs(UNLOCKS) do
		if v.NAME == UL then
			for k2,v2 in pairs(ply.UNLOCKS) do
				if v2.ID == k then
					v2.EN = 1
				end
			end
		end
	end
	ply:SendUnlocks()
	SaveUnlocks(ply)
end

concommand.Add("enable_ul", Enable_UL)
end

local Pmeta = FindMetaTable( "Player" )

function Pmeta:GetUnlocks()
	if !self.UNLOCKS then self.UNLOCKS = {} return self.UNLOCKS end
	if self.UNLOCKS then return self.UNLOCKS end
end

local ALLCOLS = {"COL_RED", "COL_BLUE", "COL_GREEN", "COL_PINK", "COL_ORNG", "COL_BLAK", "COL_WHIT", "COL_YELO"}

local UL = {}

UL.NAME = "Red Paint Job"
UL.DESCR = "Paint your tail and wings red!"
UL.CATEGORY = 1
UL.COST = 100
UL.COL = Color(255,0,0,255)

function UL.FUNCTION(plane)
	plane.wing1:SetColor(255,0,0,255)
	plane.wing2:SetColor(255,0,0,255)
	plane.tail1:SetColor(255,0,0,255)
end

Register("COL_RED", UL)

local UL = {}

UL.NAME = "Blue Paint Job"
UL.DESCR = "Paint your tail and wings blue!"
UL.CATEGORY = 1
UL.COST = 100
UL.COL = Color(0,0,255,255)

function UL.FUNCTION(plane)
	plane.wing1:SetColor(0,0,255,255)
	plane.wing2:SetColor(0,0,255,255)
	plane.tail1:SetColor(0,0,255,255)
end

Register("COL_BLUE", UL)

local UL = {}

UL.NAME = "Green Paint Job"
UL.DESCR = "Paint your tail and wings green!"
UL.CATEGORY = 1
UL.COST = 100
UL.COL = Color(0,255,0,255)

function UL.FUNCTION(plane)
	plane.wing1:SetColor(0,255,0,255)
	plane.wing2:SetColor(0,255,0,255)
	plane.tail1:SetColor(0,255,0,255)
end

Register("COL_GREEN", UL)

local UL = {}

UL.NAME = "Dark Green Paint Job"
UL.DESCR = "Paint your tail and wings dark green!"
UL.CATEGORY = 1
UL.COST = 100
UL.COL = Color(0,150,0,255)

function UL.FUNCTION(plane)
	plane.wing1:SetColor(0,100,0,255)
	plane.wing2:SetColor(0,100,0,255)
	plane.tail1:SetColor(0,100,0,255)
end

Register("COL_D_GREEN", UL)

local UL = {}

UL.NAME = "Pink Paint Job"
UL.DESCR = "Paint your tail and wings pink!"
UL.CATEGORY = 1
UL.COST = 100
UL.COL = Color(255,105,180,255)

function UL.FUNCTION(plane)
	plane.wing1:SetColor(255,105,180,255)
	plane.wing2:SetColor(255,105,180,255)
	plane.tail1:SetColor(255,105,180,255)
end

Register("COL_PINK", UL)

local UL = {}

UL.NAME = "Orange Paint Job"
UL.DESCR = "Paint your tail and wings orange!"
UL.CATEGORY = 1
UL.COST = 100
UL.COL = Color(255,165,0,255)

function UL.FUNCTION(plane)
	plane.wing1:SetColor(255,165,0, 255)
	plane.wing2:SetColor(255,165,0, 255)
	plane.tail1:SetColor(255,165,0, 255)
end

Register("COL_ORNG", UL)

local UL = {}

UL.NAME = "Metallic Black Paint Job"
UL.DESCR = "Paint your tail and wings black!"
UL.CATEGORY = 1
UL.COST = 150
UL.COL = Color(0,0,0,255)

function UL.FUNCTION(plane)
	plane.wing1:SetColor(0,0,0,255)
	plane.wing2:SetColor(0,0,0,255)
	plane.tail1:SetColor(0,0,0,255)
	plane.wing1:SetMaterial( "models/shiny" )
	plane.wing2:SetMaterial( "models/shiny" )
	plane.tail1:SetMaterial( "models/shiny" )
end

Register("COL_BLAK", UL)

local UL = {}

UL.NAME = "Metallic Red Paint Job"
UL.DESCR = "RED MAKES IT GO FASTER"
UL.CATEGORY = 1
UL.COST = 150
UL.COL = Color(255,0,0,255)

function UL.FUNCTION(plane)
	plane.wing1:SetColor(255,0,0,255)
	plane.wing2:SetColor(255,0,0,255)
	plane.tail1:SetColor(255,0,0,255)
	plane.wing1:SetMaterial( "models/shiny" )
	plane.wing2:SetMaterial( "models/shiny" )
	plane.tail1:SetMaterial( "models/shiny" )
end

Register("COL_M_RED", UL)

local UL = {}

UL.NAME = "Metallic White Paint Job"
UL.DESCR = "Paint your tail and wings white!"
UL.CATEGORY = 1
UL.COST = 150
UL.COL = Color(255,255,255,255)

function UL.FUNCTION(plane)
	plane.wing1:SetMaterial( "models/shiny" )
	plane.wing2:SetMaterial( "models/shiny" )
	plane.tail1:SetMaterial( "models/shiny" )
end

Register("COL_WHIT", UL)

local UL = {}

UL.NAME = "Yellow Paint Job"
UL.DESCR = "Paint your tail and wings yellow!"
UL.CATEGORY = 1
UL.COST = 100
UL.COL = Color(255,255,51,255)

function UL.FUNCTION(plane)
	plane.wing1:SetColor(255,255,51,255)
	plane.wing2:SetColor(255,255,51,255)
	plane.tail1:SetColor(255,255,51,255)
end

Register("COL_YELO", UL)

local UL = {}

UL.NAME = "Dark Red Paint Job"
UL.DESCR = "Paint your tail and wings dark red!"
UL.CATEGORY = 1
UL.COST = 100
UL.COL = Color(100,0,0,255)

function UL.FUNCTION(plane)
	plane.wing1:SetColor(100,0,0,255)
	plane.wing2:SetColor(100,0,0,255)
	plane.tail1:SetColor(100,0,0,255)
end

Register("COL_D_RED", UL)

local UL = {}

UL.NAME = "Armour Level 1"
UL.DESCR = "Decrease damage taken by a little."
UL.CATEGORY = 4
UL.COST = 300
UL.OVERRIDES = {"ARMOUR_2", "ARMOUR_3"}

function UL.FUNCTION(plane)
	plane.ARMOUR = 1.3
	plane.DAMAGE_DIVIDE = 2.5
	local armour = ents.Create("df_prop_scale")
	armour:SetModel("models/props_junk/MetalBucket01a.mdl")
	armour:SetPos(plane:GetPos() + (plane:GetForward() * 33) + (plane:GetRight() * -17) + Vector(0,0,5))
	armour:SetAngles(plane:GetAngles() + Angle(90,0,0))
	armour:SetParent(plane)
	armour:Spawn()
	
	armour = ents.Create("df_prop_scale")
	armour:SetModel("models/props_junk/MetalBucket01a.mdl")
	armour:SetPos(plane:GetPos() + (plane:GetForward() * 33) + (plane:GetRight() * 17) + Vector(0,0,5))
	armour:SetAngles(plane:GetAngles() + Angle(90,0,0))
	armour:SetParent(plane)
	armour:Spawn()
	plane:AddSpeedDamping(0.05)
end

Register("ARMOUR_1", UL)

local UL = {}

UL.NAME = "Armour Level 2"
UL.DESCR = "Decrease damage taken by half."
UL.CATEGORY = 4
UL.COST = 500
UL.OVERRIDES = {"ARMOUR_1", "ARMOUR_3"}
UL.DISABLES = {"ARMOUR_1"}

function UL.FUNCTION(plane)
	plane.DAMAGE_DIVIDE = 3
	plane.ARMOUR = 1.5
	local armour = ents.Create("df_prop_scale")
	armour:SetModel("models/props_junk/MetalBucket01a.mdl")
	armour:SetPos(plane:GetPos() + (plane:GetForward() * 33) + (plane:GetRight() * -17) + Vector(0,0,5))
	armour:SetAngles(plane:GetAngles() + Angle(90,0,0))
	armour:SetParent(plane)
	armour:Spawn()
	
	armour = ents.Create("df_prop_scale")
	armour:SetModel("models/props_junk/MetalBucket01a.mdl")
	armour:SetPos(plane:GetPos() + (plane:GetForward() * 33) + (plane:GetRight() * 17) + Vector(0,0,5))
	armour:SetAngles(plane:GetAngles() + Angle(90,0,0))
	armour:SetParent(plane)
	armour:Spawn()
	
	armour = ents.Create("df_prop_scale")
	armour:SetModel("models/props_wasteland/prison_metalbed001a.mdl")
	armour:SetPos(plane:GetPos() + (plane:GetRight() * 20) + (plane:GetForward() * -2) + Vector(0,0,12))
	armour:SetAngles(plane:GetAngles() + Angle(270,90,0))
	armour:SetParent(plane)
	armour:Spawn()
	
	armour = ents.Create("df_prop_scale")
	armour:SetModel("models/props_wasteland/prison_metalbed001a.mdl")
	armour:SetPos(plane:GetPos() + (plane:GetRight() * -20) + (plane:GetForward() * -2) + Vector(0,0,12))
	armour:SetAngles(plane:GetAngles() + Angle(270,270,0))
	armour:SetParent(plane)
	armour:Spawn()
	plane:AddSpeedDamping(0.1)
end

Register("ARMOUR_2", UL)

local UL = {}

UL.NAME = "Armour Level 3"
UL.DESCR = "Decrease damage taken by bullets and collisions by 60%!"
UL.CATEGORY = 4
UL.COST = 1000
UL.OVERRIDES = {"ARMOUR_1", "AMOUR_2"}
UL.DISABLES = {"ARMOUR_1", "ARMOUR_2"}

function UL.FUNCTION(plane)
	plane.ARMOUR = 2
	plane.DAMAGE_DIVIDE = 3.5
	local armour = ents.Create("df_prop_scale")
	armour:SetModel("models/props_junk/MetalBucket01a.mdl")
	armour:SetPos(plane:GetPos() + (plane:GetForward() * 33) + (plane:GetRight() * -17) + Vector(0,0,5))
	armour:SetAngles(plane:GetAngles() + Angle(90,0,0))
	armour:SetParent(plane)
	armour:Spawn()
	
	armour = ents.Create("df_prop_scale")
	armour:SetModel("models/props_junk/MetalBucket01a.mdl")
	armour:SetPos(plane:GetPos() + (plane:GetForward() * 33) + (plane:GetRight() * 17) + Vector(0,0,5))
	armour:SetAngles(plane:GetAngles() + Angle(90,0,0))
	armour:SetParent(plane)
	armour:Spawn()
	
	armour = ents.Create("df_prop_scale")
	armour:SetModel("models/props_wasteland/prison_metalbed001a.mdl")
	armour:SetPos(plane:GetPos() + (plane:GetRight() * 20) + (plane:GetForward() * -2) + Vector(0,0,12))
	armour:SetAngles(plane:GetAngles() + Angle(270,90,0))
	armour:SetParent(plane)
	armour:Spawn()
	
	armour = ents.Create("df_prop_scale")
	armour:SetModel("models/props_wasteland/prison_metalbed001a.mdl")
	armour:SetPos(plane:GetPos() + (plane:GetRight() * -20) + (plane:GetForward() * -2) + Vector(0,0,12))
	armour:SetAngles(plane:GetAngles() + Angle(270,270,0))
	armour:SetParent(plane)
	armour:Spawn()
	
	armour = ents.Create("df_prop_scale")
	armour:SetModel("models/props_interiors/BathTub01a.mdl")
	armour:SetPos(plane:GetPos() + (plane:GetForward() * 12) + (plane:GetRight() * -5) + Vector(0,0,45))
	armour:SetAngles(plane:GetAngles() + Angle(0,0,180))
	armour:SetParent(plane.tail1)
	armour:SetMaterial( "models/shiny" )
	armour:SetColor(150,150,160,150)
	armour:Spawn()
	plane:AddSpeedDamping(0.15)
	plane:AddAngleDamping(0.05)
end

Register("ARMOUR_3", UL)

local UL = {}

UL.NAME = "Increase Ammo 1"
UL.DESCR = "Increase your max ammo to 750"
UL.CATEGORY = 2
UL.COST = 300
UL.OVERRIDES = {"AMMO_2"}

function UL.FUNCTION(plane)
	plane.MAX_AMMO = 750
	plane.gun.Ammo = 750
	umsg.Start("update_ammo", plane.ply)
	umsg.Long(750)
	umsg.End()
end

Register("AMMO_1", UL)

local UL = {}

UL.NAME = "Increase Ammo 2"
UL.DESCR = "Increase your max ammo to 1000"
UL.CATEGORY = 2
UL.COST = 750
UL.OVERRIDES = {"AMMO_1"}
UL.DISABLES = {"AMMO_1"}

function UL.FUNCTION(plane)
	plane.MAX_AMMO = 1000
	plane.gun.Ammo = 1000
	umsg.Start("update_ammo", plane.ply)
	umsg.Long(1000)
	umsg.End()
	local prop = ents.Create("prop_physics")
	prop:SetModel("models/Items/BoxSRounds.mdl")
	prop:SetPos(plane:GetPos() + plane:GetRight() * -13 + Vector(0,0,8) + plane:GetForward() * -15)
	prop:SetAngles(plane:GetAngles() + Angle(0,90,0))
	prop:SetParent(plane)
	prop:Spawn()
end

Register("AMMO_2", UL)

local UL = {}

UL.NAME = "Increase Ammo 3"
UL.DESCR = "Increase your max ammo to 2000"
UL.CATEGORY = 2
UL.COST = 1750

function UL.FUNCTION(plane)
	plane.MAX_AMMO = 2000
	plane.gun.Ammo = 2000
	umsg.Start("update_ammo", plane.ply)
	umsg.Long(2000)
	umsg.End()	
	local prop = ents.Create("prop_physics")
	prop:SetModel("models/Items/BoxSRounds.mdl")
	prop:SetPos(plane:GetPos() + plane:GetRight() * 13 + Vector(0,0,8) + plane:GetForward() * -15)
	prop:SetAngles(plane:GetAngles() + Angle(0,90,0))
	prop:SetParent(plane)
	prop:Spawn()
	local prop = ents.Create("prop_physics")
	prop:SetModel("models/Items/BoxSRounds.mdl")
	prop:SetPos(plane:GetPos() + plane:GetRight() * -13 + Vector(0,0,8) + plane:GetForward() * -15)
	prop:SetAngles(plane:GetAngles() + Angle(0,90,0))
	prop:SetParent(plane)
	prop:Spawn()
end

Register("AMMO_3", UL)


local UL = {}

UL.NAME = "Bombs 1"
UL.DESCR = "2 bombs to drop. Drop with right click. Reduces manouverability!"
UL.CATEGORY = 2
UL.COST = 2000
UL.OVERRIDES = {"BURN_1"}

function UL.FUNCTION(plane)
	plane.SECONDARY_WEAPON = "wep_bombs"
	plane:LoadGuns()
end

Register("BOMBS_1", UL)

local UL = {}

UL.NAME = "Wing Mounted Guns"
UL.DESCR = "2 Wing mounted guns"
UL.CATEGORY = 2
UL.COST = 1000

function UL.FUNCTION(plane)
	plane.PRIMARY_WEAPON = "plane_gun2"
	plane:LoadGuns()
end

Register("WING_G", UL)

/*
local UL = {}

UL.NAME = "AfterBurner"
UL.DESCR = "Get a boost of power with right click. Overrides bombs!"
UL.CATEGORY = 4
UL.COST = 1000
UL.OVERRIDES = {"BOMBS_1"}

function UL.FUNCTION(plane)
	local burn = ents.Create("plane_afterburn")
	burn.plane = plane
	burn:Spawn()
end

Register("BURN_1", UL)
*/

local UL = {}

UL.NAME = "Horn"
UL.DESCR = "Annoy people with this horn. Press JUMP to honk!"
UL.CATEGORY = 3
UL.COST = 100
function UL.FUNCTION(plane)
	plane.HORN = "df/horn.wav"
end

Register("HORN_1", UL)

local UL = {}

UL.NAME = "Faster Throttle"
UL.DESCR = "Increases throttle approach time by half."
UL.CATEGORY = 4
UL.COST = 300

function UL.FUNCTION(plane)
	plane.THROTTLE_SPEED = plane.THROTTLE_SPEED + 0.2
end

Register("THROTTLE_1", UL)

local UL = {}

UL.NAME = "TurboCharger"
UL.DESCR = "Increase your speed!"
UL.CATEGORY = 4
UL.COST = 600

function UL.FUNCTION(plane)
	plane:TakeSpeedDamping(0.06)
	--plane.Engine_Sound = CreateSound(plane, "vehicles/Airboat/fan_motor_fullthrottle_loop1.wav")
end

Register("TURBO_1", UL)

local UL = {}

UL.NAME = "Fighter Wings"
UL.DESCR = "A little speed boost. Lowers lift slightly."
UL.CATEGORY = 4
UL.COST = 300

function UL.FUNCTION(plane)
	plane.wing1:SetParent()
	plane.wing2:SetParent()
	plane.wing1:SetPos(plane:GetPos() + Vector(0,0,5) + (plane:GetRight() * -30))
	plane.wing1:SetAngles(plane:GetAngles() + Angle(0,120,0))
	plane.wing2:SetPos(plane:GetPos() + Vector(0,0,5) + (plane:GetRight() * 30))
	plane.wing2:SetAngles(plane:GetAngles() + Angle(0,-120,0))
	plane.wing1:SetParent(plane)
	plane.wing2:SetParent(plane)
	plane:TakeSpeedDamping(0.07)
	plane.LIFT_POWER = plane.LIFT_POWER - 1
end

Register("FI_WING", UL)



------DONATOR STUFF HERE---------------

local UL = {}

UL.NAME = "Dixie Horn"
UL.DESCR = "Annoy people with this hilarious novelty horn!"
UL.CATEGORY = 5
UL.COST = 0
function UL.FUNCTION(plane)
	plane.HORN = "df/dixie.mp3"
end

Register("HORN_2", UL)

local UL = {}

UL.NAME = "Blue Glass"
UL.DESCR = "Glass Wings and tail!"
UL.CATEGORY = 5
UL.COST = 0

function UL.FUNCTION(plane)
	plane.wing1:SetMaterial( "models/props_combine/stasisshield_sheet" )
	plane.wing2:SetMaterial( "models/props_combine/stasisshield_sheet" )
	plane.tail1:SetMaterial( "models/props_combine/stasisshield_sheet" )
end

Register("COL_GLASS", UL)

local UL = {}

UL.NAME = "Orange Tank Glass"
UL.DESCR = "Cool Wings and tail!"
UL.CATEGORY = 5
UL.COST = 0

function UL.FUNCTION(plane)
	plane.wing1:SetMaterial( "models/props_lab/Tank_Glass001" )
	plane.wing2:SetMaterial( "models/props_lab/Tank_Glass001" )
	plane.tail1:SetMaterial( "models/props_lab/Tank_Glass001" )
end

Register("COL_TANK", UL)

local UL = {}

UL.NAME = "Lightening Paint Job"
UL.DESCR = "ELECTRIFY YOUR PLANE!"
UL.CATEGORY = 5
UL.COST = 0

function UL.FUNCTION(plane)
	plane.wing1:SetMaterial("models/alyx/emptool_glow")
	plane.wing2:SetMaterial("models/alyx/emptool_glow")
	plane.tail1:SetMaterial("models/alyx/emptool_glow")
end

Register("COL_LIGHT", UL)

local UL = {}

UL.NAME = "Fire Paint Job"
UL.DESCR = "Burn up your ride!"
UL.CATEGORY = 5
UL.COST = 0

function UL.FUNCTION(plane)
	plane.wing1:SetMaterial("models/weapons/v_crossbow/rebar_glow")
	plane.wing2:SetMaterial("models/weapons/v_crossbow/rebar_glow")
	plane.tail1:SetMaterial("models/weapons/v_crossbow/rebar_glow")
end

Register("COL_FIRE", UL)

local UL = {}

UL.NAME = "Flesh Paint Job"
UL.DESCR = "MMM tastey!"
UL.CATEGORY = 5
UL.COST = 0

function UL.FUNCTION(plane)
	plane.wing1:SetMaterial("models/flesh")
	plane.wing2:SetMaterial("models/flesh")
	plane.tail1:SetMaterial("models/flesh")
end

Register("COL_FLSH", UL)

TOT_UNLOCK_COST = 0

for k,v in pairs(UNLOCKS) do
	TOT_UNLOCK_COST = TOT_UNLOCK_COST + v.COST
end

print("All unlocks loaded. The total unlock cost is "..TOT_UNLOCK_COST)


