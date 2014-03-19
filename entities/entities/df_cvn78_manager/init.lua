AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local VecZero = Vector(0, 0, 0)
-- No need for this now...
--[[
local BulletTable = {Num		= 1,
					 Src		= VecZero, -- Override
					 Dir		= VecZero, -- Override
					 Spread		= VecZero,
					 Tracer		= 0,
					 TracerName	= "",
					 Force		= 250,
					 Damage		= 99999,}
					 --Attacker	= ents.GetByID(0)}
--]]
function ENT:Initialize()
	g_CVN78Manager = self
	
	self:SetColor(0, 0, 0, 0)
	self.LAST_WIND_DIR = 0
	self.WIND_DIR = Vector(0,1,0)
	return self:Event()
end

function ENT:UpdateTransmitStatez()
	return TRANSMIT_ALWAYS --?
end

function ENT:KeyValue(k, v)
	if k == "top" then
		SetGlobalInt("df_cvn78_manager_top",     tonumber(v))
	elseif k == "bottom" then
		SetGlobalInt("df_cvn78_manager_bottom",  tonumber(v))
	elseif k == "left" then
		SetGlobalInt("df_cvn78_manager_left",    tonumber(v))
	elseif k == "right" then
		SetGlobalInt("df_cvn78_manager_right",   tonumber(v))
	elseif k == "forward" then
		SetGlobalInt("df_cvn78_manager_forward", tonumber(v))
	elseif k == "back" then
		SetGlobalInt("df_cvn78_manager_back",    tonumber(v))
	-- SKYBOX STUFF NOW
	elseif k == "top_skybox" then
		SetGlobalInt("df_cvn78_manager_top_skybox",     tonumber(v))
	elseif k == "bottom_skybox" then
		SetGlobalInt("df_cvn78_manager_bottom_skybox",  tonumber(v))
	elseif k == "left_skybox" then
		SetGlobalInt("df_cvn78_manager_left_skybox",    tonumber(v))
	elseif k == "right_skybox" then
		SetGlobalInt("df_cvn78_manager_right_skybox",   tonumber(v))
	elseif k == "forward_skybox" then
		SetGlobalInt("df_cvn78_manager_forward_skybox", tonumber(v))
	elseif k == "back_skybox" then
		SetGlobalInt("df_cvn78_manager_back_skybox",    tonumber(v))
	end
end

function ENT:Event()
	--if not (self and self.IsValid and self:IsValid()) then return end
	
	--if math.random(1, 5) <= 3 then -- Gust
	--	self:Gust(math.random(0, 2) == 0)
	--else
	--	self:AttemptPlaneStrike() -- Fry the bastard!
	--end
	
	--return timer.Simple(math.Rand(.5, 3), self.Event, self)
end

function ENT:Gust(large_gust)
	local vec = self.WIND_DIR
	if self.LAST_WIND_DIR + 30 <= CurTime() then
		self.WIND_DIR = Vector(math.Rand(-2,2), math.Rand(-2,2), 0)
		self.LAST_WIND_DIR = CurTime()
	end
	if large_gust then
		if math.random(0, 1) == 1 then -- Huge gust!
			umsg.Start("df_cvn78_manager_gust")
				umsg.Char(3)
			umsg.End()
			
			--return self:PushPlanes(vec, 2, CurTime() + 15)
		end
		
		umsg.Start("df_cvn78_manager_gust")
			umsg.Char(2)
		umsg.End()
		
		--return self:PushPlanes(vec, 1, CurTime() + 6)
	end

end

function ENT:PushPlanes(dir, scale, starttime)
	--loclaahhcajkdslads(self, dir, scale, starttime)
end

function loclaahhcajkdslads(self, dir, scale, starttime)
	if not (self and self.IsValid and self:IsValid()) then return end
	
	local offset  = 1  * scale
	local basevec = dir * scale
	
	for k, v in pairs(ents.FindByClass("plane")) do
		if not v:GetNWBool("CVN78Indoors", false) then
			local phys = v:GetPhysicsObject()
			
			if phys and phys:IsValid() then
				phys:ApplyForceCenter((dir + (VectorRand() * offset)) * phys:GetMass() * 25)
			end
		end
	end
	
	if CurTime() < starttime then
		return timer.Simple(.25, self.PushPlanes, self, dir, scale, starttime)
	end
end

local TraceData = {mask = MASK_NPCWORLDSTATIC}

function ENT:AttemptPlaneStrike()
	local CTime = CurTime()
	
	for k, v in pairs(ents.FindByClass("plane")) do
		if not v:GetNWBool("CVN78Indoors", true) then
			if ((v.CVN78_LastThunderHit or 0) < CTime) and (math.random(1, 5) == 1) then
				v.CVN78_LastThunderHit = CTime + math.random(10, 15)
				
				local dir  = Vector(math.Rand(-.4, .4), math.Rand(-.25, .25), 1)
				local vpos = v:GetPos()
				
				TraceData.start  = vpos
				TraceData.endpos = vpos + (dir * 99999)
				TraceData.filter = v
				
				local tr = util.TraceLine(TraceData)
				
				if tr.HitSky or (not tr.HitNonWorld) then
					umsg.Start("df_cvn78_manager_thunder")
						umsg.Vector(vpos)
						umsg.Vector(tr.HitPos)
					umsg.End()
					return
				end
			end
		end
	end
end
