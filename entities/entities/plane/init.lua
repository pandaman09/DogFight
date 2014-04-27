
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

ENT.IsADamnPlane = true
ENT.MAX_DAMAGE = 100
ENT.MAX_SPEED = 50
ENT.MAX_AMMO = 500
ENT.MAX_AMMO2 = 2
ENT.EXPLODE_DAMAGE = 200
ENT.THROTTLE_SPEED = 0.2
ENT.SPEED_MOD = 5.6

ENT.S_DAMP_RUNWAY = 0.8
ENT.S_DAMP = 0.6
ENT.A_DAMP = 2.5
ENT.A_DAMP_TURN = 0.75
ENT.PRIMARY_WEAPON = "plane_gun"
ENT.SECONDARY_WEAPON = nil

ENT.ply = nil
ENT.speed = 0
ENT.Damage = 0
ENT.LastTwitch = CurTime()
ENT.Wingless = false
ENT.LastPos = CurTime()
ENT.killers = {}
ENT.killer = nil
ENT.nkc = CurTime()
ENT.LIFT_POWER = 9
ENT.DAMAGE_DIVIDE = 2

ENT.WING_HEALTH = 150
ENT.TAIL_HEALTH = 150
ENT.ARMOUR = 1
ENT.S_MOD = 1

function ENT:AddSpeedDamping(amount)
	self.S_DAMP_RUNWAY = self.S_DAMP_RUNWAY + (amount / 2)
	self.S_DAMP = self.S_DAMP + amount
	self.LIFT_POWER = self.LIFT_POWER + (amount * 5)
end

function ENT:AddAngleDamping(amount)
	self.A_DAMP = self.A_DAMP + (amount / 2)
	self.A_DAMP_TURN = self.A_DAMP + amount 
end

function ENT:TakeSpeedDamping(amount)
	self.S_DAMP_RUNWAY = self.S_DAMP_RUNWAY - (amount / 2)
	self.S_DAMP = self.S_DAMP - amount
	self.LIFT_POWER = self.LIFT_POWER - (amount * 2.5)
	if self.LIFT_POWER < 8 then self.LIFT_POWER = 8 end
end

function ENT:TakeAngleDamping(amount)
	self.A_DAMP = self.A_DAMP - (amount / 2)
	self.A_DAMP_TURN = self.A_DAMP - amount 
end

function ENT:Initialize()
	self.Entity:SetModel("models/Bennyg/plane/re_airboat2.mdl")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	self.Entity:StartMotionController()
	
	self.wing1 = ents.Create("prop_physics")
	self.wing1:SetPos(self:GetPos() + Vector(0,0,10) + (self:GetRight() * -35))
	self.wing1:SetAngles(self:GetAngles() + Angle(0,0,10))
	self.wing1:SetModel("models/Bennyg/plane/re_airboat_pallet2.mdl")
	--self.wing1:SetParent(self.Entity)
	self.wing1:SetColor(255,255,255,255)
	self.wing1.plane = self
	self.wing1:Spawn()
	
	self.wing2 = ents.Create("prop_physics")
	self.wing2:SetPos(self:GetPos() + Vector(0,0,10) + (self:GetRight() * 35))
	self.wing2:SetAngles(self:GetAngles() + Angle(0,0,-10))
	self.wing2:SetModel("models/Bennyg/plane/re_airboat_pallet2.mdl")
	self.wing2:SetColor(255,255,255,255)
	--self.wing2:SetParent(self.Entity)
	self.wing2.plane = self
	self.wing2:Spawn()
	
	self.tail1 = ents.Create("prop_physics")
	self.tail1:SetModel("models/Bennyg/plane/re_airboat_tail2.mdl")
	self.tail1:SetPos(self:GetPos() + (self:GetForward() * -55) + Vector(0,0,35))
	self.tail1:SetAngles(self:GetAngles() + Angle(0,180,0))
	self.tail1:SetParent(self)
	--self.tail1.plane = self
	--self.tail1:Spawn()
	
	--self.tail1:GetPhysicsObject():EnableGravity(false) -- all thsi crap is to keep the damn thing balanced
	--self.tail1:GetPhysicsObject():EnableDrag(false) -- all thsi crap is to keep the damn thing balanced
	
	self.wing1:GetPhysicsObject():SetMass(7)
	self.wing2:GetPhysicsObject():SetMass(7)
	--self.tail1:GetPhysicsObject():SetMass(7)
	self.wing1:SetHealth(self.WING_HEALTH)
	self.wing2:SetHealth(self.WING_HEALTH)
	--self.tail1:SetHealth(self.TAIL_HEALTH)

	--self.tail1:GetPhysicsObject():OutputDebugInfo()
	
	self.wing1_weld = constraint.Weld( self, self.wing1, 0, 0, 0, true ) 
	self.wing2_weld = constraint.Weld( self, self.wing2, 0, 0, 0, true ) 
									-- ent1  ent2 bone1 bone2 forcelimit nocolide_until_break
	--self.tail1_weld = constraint.Weld( self, self.tail1, 0, 0, 0, true ) 
	
	self.Engine_Sound = CreateSound(self, "vehicles/Airboat/fan_blade_fullthrottle_loop1.wav")
	
	--self:SetFriction(200)
	
	self.scrape = CreateSound(self,"physics/metal/metal_box_scrape_rough_loop1.wav")
	self:GetPhysicsObject():SetMass(500)
	self:GetPhysicsObject():SetMaterial("slipperymetal")
	self.killers = {}
	self.killer = nil
	self.nkc = CurTime()
	self.OnRunway = true
end

function ENT:AddPilot(ent)
	if !ent:IsPlayer() && !IsValid(self.player) then return end
	ent:SetColor(255,255,255,0)
	self.ply = ent
	self.ply:StripWeapons()
	self:SetNWEntity("ply", self.ply)
	self:GetPhysicsObject():Wake()
	self.Entity:StartMotionController()
	self.start = CurTime()
	self.Engine_Sound:PlayEx( 1.5, 50 )
	self.ply:CrosshairDisable(true)
	self.ply:SetCollisionGroup(COLLISION_GROUP_WORLD)
	self.ply:Spectate(OBS_MODE_CHASE)
	self.ply:SpectateEntity(self)
	--[[
	self.ply_model = ents.Create("prop_ragdoll")
	self.ply_model:SetModel(self.ply:GetModel())
	self.ply_model:SetPos(self:GetPos())
	self.ply_model:SetAngles(self:GetAngles())
	self.ply_model:Spawn()
	self.ply_model:SetParent(self)
	self.ply_model:ResetSequence(self.ply_model:LookupSequence( "drive_airboat") )
	]]-- perhaps another day
	self:LoadGuns()
	local unlock_val = 1
	if ent.UNLOCKS && ent.UNLOCKS != {} then
		for k,v in pairs(ent.UNLOCKS) do
			local UL_ID = v.ID
			local UL_ENABLE = v.EN
			if UNLOCKS[UL_ID] && v.EN == 1 then
				UNLOCKS[UL_ID].FUNCTION(self)
				unlock_val = unlock_val + UNLOCKS[UL_ID].COST
			elseif !UNLOCKS[UL_ID] then
				table.remove(ent.UNLOCKS, k)
				print("Removing Invalid Unlock: "..UL_ID)
			end
		end
		--ply:ChatPrint("Your skill level is "..ply.skill)
	end
	ent.skill = (unlock_val + ent:GetNWInt("money",0)) / (TOT_UNLOCK_COST / 6)
	ent.skill = math.Clamp(ent.skill * ent:CalcKD(), 0.2, 5)
end

function ENT:LoadGuns()
	if IsValid(self.gun) then
		self.gun:Remove()
	end
	if IsValid(self.gun2) then
		self.gun2:Remove()
	end
	self.gun = ents.Create(self.PRIMARY_WEAPON)
	self.gun.plane = self
	self.gun:Spawn()
	if self.SECONDARY_WEAPON then
		self.gun2 = ents.Create(self.SECONDARY_WEAPON)
		self.gun2.plane = self
		self.gun2:Spawn()
	end
end

function ENT:DamageModel()
	local p = self:GetPhysicsObject()
	self:SetNWInt("dmg", self.Damage)
	if self:WaterLevel() > 0.3 then
		self.Damage = 200
	end
	if !self.OnRunway && self:GetVelocity():Length() >= 200 then
		local trc = {}
		trc.start = self:GetPos()
		trc.endpos = self:GetPos() + self:GetUp() * -5
		trc.filter = self
		local tr = util.TraceLine(trc)
		if tr.HitWorld then
			self.Damage = self.Damage + 1
			util.ScreenShake( self:GetPos(), 50, 1, 1, 20 )
			self.scrape:Play()
		else
			self.scrape:Stop()
		end
	end
	if self.Damage >= 15 && !self.Smoking then
		self.Smoking = true
		local ED = EffectData()
		ED:SetEntity(self)
		util.Effect("plane_smoke", ED)
		self.ply:SendMessage("Your engine is smoking.")
	elseif self.Damage < 15 then
		self.Smoking = false
	end
	if self.Damage >= 60 && self.LastTwitch + math.Rand(1,4) <= CurTime() then
		self:DoDamageTwitch()
	end
	if self.Wingless then
		self.Damage = self.Damage + 0.1
	end
	if self.Damage >= 100 then
		if math.random(1,2) == 1 then
			if IsValid(self.wing1_weld) && IsValid(self.wing2_weld) then
				self.wing1_weld:Remove()
				self:EmitSound("physics/metal/metal_sheet_impact_bullet2.wav", 100,100)
				self.ply:SendMessage("Your wing has fallen off!")
				if IsValid(self.killer) then
					self.ply:StartCrashCam(self.killer)
				end
			end
		elseif IsValid(self.wing2_weld) && IsValid(self.wing1_weld) then
			self.wing2_weld:Remove()
			self:EmitSound("physics/metal/metal_sheet_impact_bullet2.wav", 100,100)
			self.ply:SendMessage("Your wing has fallen off!")
			if IsValid(self.killer) then
				self.ply:StartCrashCam(self.killer)
			end
		end
	end
	if !IsValid(self.wing1) || !IsValid(self.wing1_weld) then
		p:ApplyForceOffset(self:GetUp() * -150, self:GetPos() + (self:GetRight() * -250))
		p:ApplyForceCenter(Vector(0,0,-10000))
		self.Wingless = true
		self.Engine_Sound:ChangePitch(math.Clamp(math.random(-50,20) + self.speed * 3, 50,1000),1)
		self.Engine_Sound:ChangeVolume(math.Clamp(self.speed * 3, 100,400),1)
	elseif !IsValid(self.wing2) || !IsValid(self.wing2_weld) then
		p:ApplyForceOffset(self:GetUp() * -150, self:GetPos() + (self:GetRight() * 250))
		p:ApplyForceCenter(Vector(0,0,-10000))
		self.Wingless = true
		self.Engine_Sound:ChangePitch(math.Clamp(math.random(-50,20) + self.speed * 3, 50,1000),1)
		self.Engine_Sound:ChangeVolume(math.Clamp(self.speed * 3, 100,400),1)
	end
	if self.Damage >= self.EXPLODE_DAMAGE && !self.Exploding then
		self:Explode()
	end
end

ENT.shcnt = 0

function ENT:Shake(dur, amp, cont)
	if !IsValid(self) then return end
	if self.OnRunway then return end
	if !dur then dur = 10 end
	if !cont then
		self.shcnt = 0
	else
		if self.shcnt >= dur then return end
	end
	self.shcnt = self.shcnt + 1
	local p = self:GetPhysicsObject()
	local force = (self:GetRight() * math.random(-5,5)) + (self:GetUp() * math.random(-1,2))
	p:ApplyForceCenter(force * p:GetMass() * amp)
	timer.Simple(math.Rand(0.01,0.05), self.Shake, self,dur,amp, true)
end

function ENT:SendValues()
	net.Start("up")
		net.WriteInt(self.speed, 16)
		net.WriteInt(self.gun.Ammo, 16)
	net.Send(self.ply)
end

ENT.pitch = 0
ENT.lasthorn = 0
ENT.LAST_THINK = 0

function ENT:Think()
	if !IsValid(self.ply) || !self.ply:Alive() then self:Remove() end
	if self.LastPos + 10 <= CurTime() then
		self.ply:SetPos(self:GetPos())
		self.LastPos = CurTime()
	end
	if self.OnRunway && self:GetVelocity():Length() <= 200 then
		self.Damage = 0
		self.gun:Regen()
		if IsValid(self.gun2) then
			self.gun2:Regen()
		end
	else
		if self.ply:KeyDown(IN_ATTACK) then
			self.gun:FireGun()
			self:SendValues()
		end
		if self.ply:KeyDown(IN_ATTACK2) && IsValid(self.gun2) then
			self.gun2:FireGun()
			self:SendValues()
		end
	end
	if self.ply:KeyDown(IN_SPEED) then
		self.speed = math.Approach(self.speed, self.MAX_SPEED, self.THROTTLE_SPEED)
		self.ply.learnt = true
		self:SendValues()
	elseif self.ply:KeyDown(IN_DUCK) then
		self.speed = math.Approach(self.speed, -10, self.THROTTLE_SPEED)
		self:SendValues()
	end
	if self.HORN && self.ply:KeyDown(IN_JUMP) && self.lasthorn + 4 <= CurTime() then
		self:EmitSound(self.HORN, 500,100)
		self.lasthorn = CurTime()
	end
	if self.LAST_THINK + 0.05 <= CurTime() then
		self:DamageModel() -- check damage etc
		if self.Damage < 100 then
			local vel = self.Entity:WorldToLocal(self.Entity:GetVelocity()+self.Entity:GetPos()) -- thanks wiremod
			self.Engine_Sound:ChangePitch(math.Clamp(math.random(0,self.Damage / 5) + (self.speed * 2) + (vel.x / 500)^3,20,2000),1)
		end
		if self.nkc <=CurTime() && !self.Wingless then
			self.killer = nil
		end
		self.LAST_THINK = CurTime()
	end
	self:NextThink(CurTime() + 0.01)
	return true
end

function ENT:SetKiller(ent, tme)
	self.killer = ent
	self.nkc = CurTime() + tme
end

function ENT:DoDamageTwitch()
	self.LastTwitch = CurTime()
	if self.OnRunway then return end
	local p = self:GetPhysicsObject()
	local force = (self:GetRight() * math.random(-4,4) + (self:GetForward() * math.random(-1,1)))
	p:ApplyForceCenter(force * p:GetMass() * 40)
	self:EmitSound("physics/metal/metal_barrel_impact_hard3.wav", 60, math.random(180,255))
end

function ENT:PhysicsSimulate( phys, deltatime )
	if !IsValid(self.ply) then return end
	--so shit works
	--self.ply.UPKEY = IN_BACK
	--self.ply.DOWNKEY = IN_FORWARD

	local p = self:GetPhysicsObject()
	local ply = self.ply
	local speed = self.speed / self.SPEED_MOD
	local off = self:GetPos() + (self:GetForward() * 25)
	local vel = self.Entity:WorldToLocal(self.Entity:GetVelocity()+self.Entity:GetPos()) -- thanks wiremod
	local MAX_LIFT = 4470
	if self.OnRunway then
		MAX_LIFT = 4350
	end
	local lift = math.Clamp((vel.x * self.LIFT_POWER - self.Damage), 0, MAX_LIFT)
	local p_ctrl_pow = math.Clamp(vel.x / 700 * 0.2, 0.1,0.3)
	local y_ctrl_pow = math.Clamp(vel.x / 500 * 0.1, 0.05,0.2)
	if self.OnRunway then
		y_ctrl_pow = 0.15
	end
	if self.Wingless then
		lift = 0
	end
	if ply:KeyDown(self.ply.UPKEY) then
		if self.pitch < p_ctrl_pow / 2 then self.pitch = p_ctrl_pow / 2 end
		self.pitch = math.Approach(self.pitch,p_ctrl_pow * 1.5, 0.01)
	elseif ply:KeyDown(self.ply.DOWNKEY) then
		if self.pitch > -p_ctrl_pow / 2 then self.pitch = -p_ctrl_pow / 2 end
		self.pitch = math.Approach(self.pitch,-p_ctrl_pow, 0.01)
	else
		self.pitch = 0
	end
	if self.Damage > 100 then
		p:ApplyForceCenter((self:GetForward() * speed ) * p:GetMass())
	else
		p:ApplyForceCenter((self:GetForward() * speed ) * p:GetMass())
		p:ApplyForceCenter(self:GetUp() * lift)
	end
	local side_drift = vel.y * 10
	p:ApplyForceCenter(self:GetRight() * side_drift)
	if ply:KeyDown(IN_MOVELEFT) then
		p:ApplyForceOffset((self:GetRight() * -y_ctrl_pow) * p:GetMass(), off + Vector(0,0,25))
		p:ApplyForceCenter(Vector(0,0,1) * p:GetMass())
	elseif ply:KeyDown(IN_MOVERIGHT) then
		p:ApplyForceOffset((self:GetRight() * y_ctrl_pow) * p:GetMass(), off + Vector(0,0,25))
		p:ApplyForceCenter(Vector(0,0,1) * p:GetMass())
	end
	if vel.x > 500 then
		self.S_MOD = math.Approach(self.S_MOD,math.Clamp(2 - (vel.x / 900 * 1), 0.7, 1.2), 0.01)
	else
		self.S_MOD = 1.2
	end
	if !ply:KeyDown(IN_MOVELEFT) && !ply:KeyDown(IN_MOVERIGHT) && !ply:KeyDown(ply.UPKEY) && !ply:KeyDown(ply.DOWNKEY) then
		if self.OnRunway then
			self:GetPhysicsObject():SetDamping( self.S_DAMP_RUNWAY, self.A_DAMP )
		else
			self:GetPhysicsObject():SetDamping( self.S_DAMP * self.S_MOD, self.A_DAMP )
		end
	else
		if self.OnRunway then
			self:GetPhysicsObject():SetDamping( self.S_DAMP_RUNWAY, self.A_DAMP_TURN )
		else
			self:GetPhysicsObject():SetDamping( self.S_DAMP * self.S_MOD, self.A_DAMP_TURN )
		end
	end
	if self.pitch != 0 then
		p:ApplyForceOffset((self:GetUp() * self.pitch) * p:GetMass(), off)
	end
	local cor = (vel.x / 1000) * 0.07
	p:ApplyForceOffset((self:GetUp() * cor) * p:GetMass(), off)
	if self.Damage <= 90 then
		if ply.ROLL_ON then
			if ply.Q then
				p:ApplyForceOffset(self:GetRight() * -20, self:GetPos() + (self:GetUp() * 100))
				p:ApplyForceOffset(self:GetRight() * 20, self:GetPos() + (self:GetUp() * -100))
			elseif ply:KeyDown(IN_USE) then
				p:ApplyForceOffset(self:GetRight() * 20, self:GetPos() + (self:GetUp() * 100))
				p:ApplyForceOffset(self:GetRight() * -20, self:GetPos() + (self:GetUp() * -100))
			else
				local ang = self:GetAngles()
				p:ApplyForceOffset((self:GetRight() * ang.r) * 0.5, self:GetPos() + (self:GetUp() * 5))
			end
		else
			local ang = self:GetAngles()
			p:ApplyForceOffset((self:GetRight() * ang.r) * 2.5, self:GetPos() + (self:GetUp() * 5))
		end
	end
end

function Q_DOWN(ply)
	ply.Q = true
end

concommand.Add("+roll_l", Q_DOWN)

function Q_UP(ply)
	ply.Q = false
end

concommand.Add("-roll_l", Q_UP)

function ENT:PhysicsCollide( data, physobj )
	local plane = nil
	if IsValid(data.Entity) then
		if data.Entity:GetClass() == "plane" then
			plane = data.Entity
		end
		if IsValid(data.Entity.plane) then
			plane = data.Entity.plane
		end
		if plane then
			local trc = {}
			trc.start = plane:GetPos()
			trc.endpos = plane:GetPos() + plane:GetForward() * 100
			trc.filter = {plane, plane.ply}
			local tr = util.TraceLine(trc)
			if IsValid(tr.Entity) then
				if tr.Entity == self then
					local trc = {}
					trc.start = self:GetPos()
					trc.endpos = self:GetPos() + self:GetForward() * 100
					trc.filter = {self, self.ply}
					local tr = util.TraceLine(trc)
					if IsValid(tr.Entity) then
						if tr.Entity == plane then
							self.Damage = self.Damage + data.Speed 
							self:EmitSound("physics/metal/metal_sheet_impact_hard2.wav")
							return
						else
							self.Damage = self.Damage + (data.Speed / 100)
							return
						end
					end
				end
			end
		end
	end
	if math.NormalizeAngle(math.floor(self:GetAngles().r)) > 100 || math.NormalizeAngle(math.floor(self:GetAngles().r)) < -100 then
		self:Explode()
	end
	if data.Speed >= 150 && !self.OnRunway then
		self.Damage = self.Damage + (data.Speed / 7) / self.ARMOUR
		self:EmitSound("physics/metal/metal_sheet_impact_hard2.wav")
	elseif data.Speed >= 150 && self.OnRunway then
		self.Damage = self.Damage + (data.Speed / 12) / self.ARMOUR
	end
	if data.Speed >=300 && self.OnRunway then
		self.Damage = self.Damage + (data.Speed / 10)
		self:EmitSound("physics/metal/metal_sheet_impact_hard2.wav")
	end
	if data.Speed >= 10 && self.Wingless then
		self:Explode()
	end
end

function ENT:Touch(ent)
end

function ENT:OnTakeDamage(dmg)
	if self.OnRunway && self:GetVelocity():Length() <= 300 then
		return false
	end
	local inf = dmg:GetInflictor()
	if inf:GetClass() == "df_flak" then
		self.Damage = self.Damage + dmg:GetDamage()
	elseif inf:GetClass() == "wep_bombs" then
		self.Damage = self.Damage + dmg:GetDamage()
		inf = inf.plane.ply
	elseif inf:GetClass() == "plane_gun" || inf:GetClass() == "plane_gun2" then
		if inf == self.gun then return end
		if GAMEMODE.TEAM_BASED then
			local ply = inf.plane.ply
			if ply:Team() == self.ply:Team() then
				ply:SendMessage("Stop shooting teammates!")
				return
			end
		end
		inf = inf.plane.ply
	end
	local damg = dmg:GetDamage() / self.DAMAGE_DIVIDE
	damg = GAMEMODE:ScalePlaneDamage(self, damg)
	self.Damage = self.Damage + damg
	if !self.Wingless && inf:GetClass() == "player" && inf != self.ply && inf:Team() != self.ply:Team() then
		local idx = inf:UniqueID( )
		if self.killers[idx] then
			self.killers[idx] = self.killers[idx] + damg
		else
			self.killers[idx] = damg
		end
		self:SetKiller(inf, 1)
	end
end

function ENT:Explode()
	local ED = EffectData()
	ED:SetOrigin(self:GetPos())
	util.Effect( "plane_explode",ED)
	util.BlastDamage( self.gun, self.gun, self:GetPos(), 550, 30 )
	for k,v in pairs(ents.FindInSphere(self:GetPos(), 350)) do
		if v:GetClass() == "plane" then
			v:Shake(5, 60)
		end
	end
	self:Remove()
end

function ENT:OnRemove()
	self.Engine_Sound:Stop()
	self.scrape:Stop()
	if IsValid(self.wing1) then
		self.wing1:Remove()
	end
	if IsValid(self.wing2) then
		self.wing2:Remove()
	end
	if IsValid(self.tail1) then
		self.tail1:Remove()
	end
	if IsValid(self.ply) && self.ply:Alive() then
		self.ply:Kill()
	end
end





