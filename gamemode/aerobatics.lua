
DF_AEROBATICS = {} // Table containing all the different aerobatics you can have

function RegisterTrick(tab)
	DF_AEROBATICS[tab.CLASS] = tab;
end

local TRICK = {}

TRICK.NAME = ""
TRICK.CLASS = "none"

function TRICK.INIT(ply)
end

function TRICK.END(ply)
end

function TRICK.EFUNCPRESS(ply)
end

function TRICK.EFUNCRELEASE(ply)
end

function TRICK.QFUNCPRESS(ply)
end

function TRICK.QFUNCRELEASE(ply)
end

function TRICK.SIM(plane)
end

RegisterTrick(TRICK)

local TRICK = {}

TRICK.NAME = "Barrel Roll"
TRICK.CLASS = "barrel_roll"

function TRICK.INIT(ply)
	ply:GetPlane().brolling = 0;
end

function TRICK.END(ply)
	local plane = ply:GetPlane()
	plane:SetTrickRunning(false)
	plane.brolling = 0
	plane:SetRollCorrect(true)
	plane.NextTrick = CurTime() + 1.5 //When the trick will be reenabled.
	ply:StopTip("BarrelRoll")
end

TRICK.ROLL_QUICKT = 0.6
TRICK.ROLL_SLOWT = 2

function TRICK.EFUNCPRESS(ply)		
	local plane = ply:GetPlane()
	plane:SetTrickRunning(true)
	if !IsValid(plane) || math.abs(plane.brolling) == 1 then return end
	plane.brolling = 1
	plane:SetRollCorrect(false)
	plane.Trick_Start = CurTime()
end

function TRICK.EFUNCRELEASE(ply)
end

function TRICK.QFUNCPRESS(ply)
	local plane = ply:GetPlane()
	plane:SetTrickRunning(true)
	if !IsValid(plane) || math.abs(plane.brolling) == 1 then return end
	plane.brolling = -1
	plane:SetRollCorrect(false)
	plane.Trick_Start = CurTime()
end

function TRICK.QFUNCRELEASE(ply)
end

function TRICK.SIM(plane)
	if plane.Trick_Start + 0.5 < CurTime() then
		if plane.brolling < 0 then
			if plane:GetAngles().r < 25 and plane:GetAngles().r > 15 then
				plane:GetDriver():Boost()
				plane:SetThrottle(plane.MAX_SPEED * 1.5)
				TRICK.END(plane:GetDriver())
			end
		elseif plane.brolling > 0 then
			if plane:GetAngles().r > -25 and plane:GetAngles().r < -15 then
				plane:GetDriver():Boost()
				plane:SetThrottle(plane.MAX_SPEED * 1.5)
				TRICK.END(plane:GetDriver())
			end
		end
	end
	if plane:GetAngles().p > 85 || plane:GetAngles().p < -80  then TRICK.END(plane:GetDriver()) end
	//local roll_speed = math.Clamp(plane.brolling * plane:GetVelocity():Length(),-355,355)
	local roll_speed = plane.brolling * plane:GetVelocity():Length()
	plane:GetPhysicsObject():AddAngleVelocity(Vector(roll_speed,0,0))
end

RegisterTrick(TRICK)

local TRICK = {}

TRICK.NAME = "Loop the loop"
TRICK.CLASS = "loop"

function TRICK.INIT(ply)
	ply:GetPlane().brolling = 0;
end

function TRICK.END(ply)
	local plane = ply:GetPlane()
	plane:SetTrickRunning(false)
	plane.brolling = 0
	plane:SetRollCorrect(true)
	plane:SetTrick("barrel_roll")
	plane.NextTrick = CurTime() + 1.5 //When the trick will be reenabled.
	plane.loop_start = nil
	ply:SetAngles(plane:GetAngles())
end

function TRICK.EFUNCPRESS(ply)		

end

function TRICK.EFUNCRELEASE(ply)
end

function TRICK.QFUNCPRESS(ply)
end

function TRICK.QFUNCRELEASE(ply)
end

function TRICK.SIM(plane)
	plane:SetRollCorrect(false)
	plane.loop_start = plane.loop_start or CurTime()
	if CurTime() - plane.loop_start < 4 then
		plane.p_diff = -40
		plane.y_diff = 0
	elseif plane:GetAngles().p < 60 then
		TRICK.END(plane:GetDriver())
	end
end

RegisterTrick(TRICK)
