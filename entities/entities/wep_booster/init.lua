include("shared.lua")

AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

AccessorFunc(ENT,"ePlane", "Plane")
AccessorFunc(ENT,"iNextFire", "NextFire", NUMBER)

function ENT:Initialize()
	self:SetOwner(self:GetPlane())
	self.Entity:SetModel("models/props_trainstation/trashcan_indoor001b.mdl")
	self:SetMaterial("models/props_canal/metalwall005b")
	self.Entity:SetMoveType(MOVETYPE_NONE)
	self.Entity:SetSolid(SOLID_NONE)
	self.a = 0
	self:SetColor(255,255,255,self.a)
	self:SetPos(self:GetPlane():GetPos() + (self:GetPlane():GetForward() * -25) + (self:GetPlane():GetUp() * 10))
	self:SetParent(self:GetPlane())
	self:SetNextFire(0);
	self:SetAmmo(self.DefaultAmmo)
	self.dt.Boosting = false
	self.charging = false
end

function ENT:ShouldUse(driver,plane)
	return true
end

function ENT:CanAttack()
	if self:GetPlane():GetHasFuelPod() then return false end
	if self:GetNextFire() > CurTime() then return false end
	if self:GetAmmo() <=  0 then return false end
	if self.dt.Boosting or self.charging then return false end
	return true
end

function ENT:ResetAmmo()
	self:SetAmmo(self:GetAmmo() + self.DefaultAmmo)
end

function ENT:FireGun()
	if !self:CanAttack() then return end
	self.charging = true
	self:EmitSound("weapons/strider_buster/Strider_Buster_stick1.wav", 100,100)
	self.fire_start = CurTime()
	self.old_plane_trick = self:GetPlane():GetTrick().CLASS
	self:GetPlane():SetTrick("none") //disable tricks for a bit
	self:GetPlane():SetRollCorrect(true)
end

function ENT:Think()
	if self:GetAmmo() <= 0 then self:Remove() end
	if self.charging then
		self.a = math.Approach(self.a, 255,1.5)
		self:SetColor(255,255,255,self.a)
		if self.a == 255 then
			self:EmitSound("weapons/strider_buster/Strider_Buster_detonate.wav", 100,70)
			self.charging = false
			self.dt.Boosting = true
			self.fire_start = CurTime()
		end
	end
	local pln_ang_o = self:GetPlane():GetAngles() //angles dont convert properly
	local pln_ang_c = self:GetPlane():GetAngles()
	pln_ang_c.r = pln_ang_o.p * -1
	pln_ang_c.p = pln_ang_o.r
	self:SetAngles(pln_ang_c + Angle(0,-90,90))
	if self.dt.Boosting then
		self:GetPlane():SetTrickRunning(false) // Trick breaks at high speeds
		if self:GetPlane():GetHasFuelPod() then self.fire_start = 0 end
		self:GetPlane():SetWingPower(0)
		self:GetPlane():SetTurnPower(3)
		self:GetPlane():GetPhysicsObject():SetVelocity((self:GetPlane():GetForward() * 1500) + (self:GetPlane():GetUp() * -50))
		if self.fire_start + self.Life < CurTime() then
			self:GetPlane():SetWingPower(1)
			self:GetPlane():SetTurnPower(1)
			self:SetAmmo(self:GetAmmo() - 1)
			self.dt.Boosting = false
			self.charging = false
			self:GetPlane():SetTrick(self.old_plane_trick)
		end
	end
	if !self.charging and !self.dt.Boosting then
		self.a = math.Approach(self.a, 0,5)
		self:SetColor(255,255,255,self.a)
	end
	self:NextThink(CurTime() + 0.01)
	return true
end

