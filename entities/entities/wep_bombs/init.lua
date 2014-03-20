
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

ENT.plane = nil
ENT.primed = nil
ENT.ID = nil

function ENT:Initialize()
	if !self.ID then
		self:SetPos(self.plane:GetPos())
		self:SetNoDraw(true)
		self.Entity:SetMoveType( MOVETYPE_NONE )
		self.Entity:SetSolid( SOLID_NONE )
		self.bomb1 = ents.Create("wep_bombs")
		self.bomb1.plane = self.plane
		self.bomb1.ID = 1
		self.bomb1.ctrl = self
		self.bomb1:Spawn()
		self.bomb2 = ents.Create("wep_bombs")
		self.bomb2.plane = self.plane
		self.bomb2.ID = 2
		self.bomb2.ctrl = self
		self.bomb2:Spawn()
		print("taking speed init")
		self.plane:AddSpeedDamping(0.25)
	else
		self.Entity:SetModel("models/props_debris/concrete_cynderblock001.mdl")
		self.Entity:PhysicsInit( SOLID_VPHYSICS )
		self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
		self.Entity:SetSolid( SOLID_VPHYSICS )
	end
	if !self.plane then self:Remove() end
	if self.ID == 1 then
		self:SetPos(self.plane:GetPos() + (self.plane:GetRight() * 30) + Vector(0,0,5))
	else
		self:SetPos(self.plane:GetPos() + (self.plane:GetRight() * -30) + Vector(0,0,5))
	end
	self:SetAngles(self.plane:GetAngles() + Angle(0,0,90))
	self:SetParent(self.plane)
end

function ENT:FireGun()
	if !self.plane.OnRunway then
		if !self.primed then
			if !self.ID then
				self.plane.ply:ConCommand("say BOMBS AWAY!")
			end
			self:Drop()
			self.bomb1:Drop()
			self.bomb2:Drop()
		end
	end
end

function ENT:Regen()
	if self.dropped then
		self.bomb1 = ents.Create("wep_bombs")
		self.bomb1.plane = self.plane
		self.bomb1.ID = 1
		self.bomb1.ctrl = self
		self.bomb1:Spawn()
		self.bomb2 = ents.Create("wep_bombs")
		self.bomb2.plane = self.plane
		self.bomb2.ID = 2
		self.bomb2.ctrl = self
		self.bomb2:Spawn()
		self.plane:AddSpeedDamping(0.25)
		self.plane.ply:SendMessage("Bombs re-armed!")
		self.dropped = false
		self.primed = nil
	end
end

ENT.PRIMEDELAY = 0.1

function ENT:PhysicsCollide(data)
	if self.ID then
		local ent = data.HitEntity
		if !self.primed then return end
		if self.primed + self.PRIMEDELAY <= CurTime() then
			if !IsValid(self.plane.ply) then self:Remove() return end
			if ent:GetClass() == "plane" then
				ent:SetKiller(self.plane.ply, 1)
			end
			local ED = EffectData()
			ED:SetOrigin(self:GetPos())
			util.Effect( "df_bombs",ED)
			for k,v in pairs(ents.FindInSphere(self:GetPos(), 350)) do
				if v:GetClass() == "plane" then
					if !TEAM_BASED || (v.ply:Team() != self.plane.ply:Team()) || (v.ply == self.plane.ply) then
						if v.Damage < 100 then
							v:Shake(15, 50)
							local dam = math.Clamp(1050 - v:GetPos():Distance(self:GetPos()),20,1050)
							v:TakeDamage(dam, self.plane.ply, self)
						end
					end
				elseif v:GetClass() == "df_target" then
					local dam = 4050 - v:GetPos():Distance(self:GetPos())
					v:TakeDamage(dam, self.plane.ply, self)
				end
			end
			self:Remove()
		end
	end
end

function ENT:Drop()
	self.primed = CurTime()
	if !self.ID then
		self.plane:TakeSpeedDamping(0.25)
		self.dropped = true
	else
		self:SetParent()
		if self.ID == 1 then
			self:SetPos(self.plane:GetPos() + (self.plane:GetRight() * 30) + self.plane:GetUp() * -15)
		end
		if self.ID == 2 then
			self:SetPos(self.plane:GetPos() + (self.plane:GetRight() * -30) + self.plane:GetUp() * -15)
		end
		local phys= self.Entity:GetPhysicsObject()
		if (phys:IsValid()) then
			phys:Wake()
			phys:SetVelocity(self.plane:GetVelocity())
		end
	end
end

function ENT:OnRemove()
	if !self.ID then
		self.plane:TakeSpeedDamping(0.25)
	end
	if IsValid(self.bomb1) then
		self.bomb1:Remove()
	end
	if IsValid(self.bomb2) then
		self.bomb2:Remove()
	end
end






