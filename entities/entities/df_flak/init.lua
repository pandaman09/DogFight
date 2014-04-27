
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local current_map_is_cvn78_b2 = (game.GetMap() == "df_cvn78_b2")

-- NOTES: Add ENT.IsADamnPlane = true to the init.lua of your plane SENT and test for that instead of GetClass,
--        it's faster.

-- NOTES: Change TakeDamage method of your plane SENT to TakeDFDamage, otherwise it'll be overriding a metamethod
--        which provides different functionality then that you give.

local FiringDelay = 1.2

--ENT.team      = "idc" -- They should set it manually in all cases, else, it is an error.
ENT.health      = GM.FLAK_MAX_HEALTH -- set in settings.lua

ENT.search_delay = 1
ENT.skill        = 2
ENT.range        = 4096

--ENT.ClusterGUID = -1 -- Why bother?

ENT.FIRE_DELAY  = 0.6 -- Configuration data goes at the top, gods.... 
ENT.closest     = nil

local BarrelAttachmentID = nil -- Shared among all flak guns, and it's a local, so it's faster to access then a table member

function ENT:Initialize()
	self.Entity:SetModel("models/bennyg/cannons/flak.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_NONE)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	
	local phys = self.Entity:GetPhysicsObject()
	
	if phys:IsValid() then
		phys:Wake()
	end    
	
	self:SetSequence(self:LookupSequence("aim"))
	
	if not GM.TEAM_BASED then -- set in settings.lua
		--self:Remove()
	end
	
	if not BarrelAttachmentID then
		BarrelAttachmentID = self:LookupAttachment("barrel_r")
	end
	
	self.LastFiring = 0
end

function ENT:KeyValue(k,v)
	if k == "team" then
		self.team = (string.lower(v) == "gbu") and T_GBU or T_IDC
	elseif k == "range" then
		self.range = tonumber(v)
	elseif k == "skill" then
		self.skill = tonumber(v)
	elseif k == "cluster" then
		self.ClusterGUID = self.ClusterGUID or v
		
		return self:SetName(self.ClusterGUID or v)
	elseif current_map_is_cvn78_b2 then
		local pos = self:GetPos()
		
		local idc = ((pos.x <  10400) and (pos.x > 9700) and
		             (pos.y <  6200)  and (pos.y > 5900) and
		             (pos.z < -400))
		
		if idc then -- It's actually cluster_idc_4!
			self.ClusterGUID = "cluster_idc_4"
			
			return self:SetName("cluster_idc_4")
		end
	end
end

function ENT:FireGun(targetpos, targetvel)
	local flak_pos = targetpos + (VectorRand() * ((targetvel / self.skill * .25) + math.Rand(0, 2048)))
	
	local fx = EffectData()
	fx:SetOrigin(flak_pos)
	util.Effect("flak_smoke", fx, true, true) -- flak_smoke
	
	for k,v in pairs(ents.FindInSphere(flak_pos, 80)) do
		if v.IsADamnPlane then
			local damage = math.random(35, 50)
			
			v:Shake(15, damage)
			
			v:SetKiller(self, 1)
			v:TakeDamage(damage, self)
			
			v.killers.FLAK = (v.killers.FLAK or 0) + damage
		end
	end
	
	return self:EmitSound("weapons/underwater_explode3.wav", 400, 100)
end

function ENT:Think()
	FlacClacStuff(self)
end

function FlacClacStuff(self)
	local CTime = CurTime()
	
	local selfpos = self:GetPos()
	
	local targ    = self.Target
	local valid   = IsValid(targ) and ((targ.Damage or 0) < 100)
	local targpos = valid and targ:GetPos() or nil
	
	if valid and (targpos:Distance(selfpos) < self.range) then
		local direction = (targpos - selfpos):Angle()
		
		self:SetPoseParameter("aim_yaw",         direction.yaw)
		self:SetPoseParameter("aim_pitch", 360 - direction.pitch)
		
		if CTime > self.LastFiring then
			self:FireGun(targpos, targ:GetVelocity():Length())
			
			self.LastFiring = CTime + FiringDelay
		end
	else
		targ = nil
		
		for k,v in pairs(ents.FindInSphere(selfpos, self.range)) do -- Let Source do some PVS filtering & crap, it's faster for it then you
			if v and v.IsADamnPlane and v:IsValid() then
				local dist = v:GetPos():Distance(self:GetPos())
				
				if (dist < self.range) and (v.ply:Team() ~= self.team) then
					targ = v
					Msg(self, " targ is now ", v, "\n")
				end
			end
		end
		
		self.Target = targ
	end
	
	return self:NextThink(CTime + (targ and .5 or 1))
end

function ENT:Team()
	return self.team
end

function ENT:OnRemove() -- ?
end
