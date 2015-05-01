
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

AccessorFunc(ENT,"ePlane", "Plane")
AccessorFunc(ENT,"iNextFire", "NextFire", NUMBER)
AccessorFunc(ENT,"bDummy", "Dummy", BOOL)

Sound( "NPC_FloorTurret.Shoot" )

function ENT:Initialize()
	self.Entity:SetModel("models/weapons/w_smg1.mdl")
	self.Entity:SetMoveType( MOVETYPE_NONE)
	self.Entity:SetSolid( SOLID_NONE )
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	
	if !self:GetDummy() then
		self.gun2 = ents.Create("wep_default")
		self.gun2:SetModel("models/weapons/w_smg1.mdl")
		self.gun2:SetDummy(true)
		self.gun2:SetPlane(self:GetPlane())
		self.gun2:Spawn()
		
		self:SetPos(self:GetPlane():GetPos() + (self:GetPlane():GetForward() * 15) + (self:GetPlane():GetRight() * 10))
		self.gun2:SetPos(self:GetPlane():GetPos() + (self:GetPlane():GetForward() * 15) + (self:GetPlane():GetRight() * -10))
		self:SetAngles(self:GetPlane():GetAngles())
		self.gun2:SetAngles(self:GetPlane():GetAngles())
		self.gun2:SetParent(self:GetPlane())
		self:SetParent(self:GetPlane())
	end
	self:SetNextFire(0);
end

function OnPlaneBulletHit(atk, trc, dmg)
	if !IsValid(atk:GetPlane()) then return end
	atk:GetPlane():GetDriver().LastBulletHit = atk:GetPlane():GetDriver().LastBulletHit or 0
	if atk:GetPlane():GetDriver().LastBulletHit + 0.5 < CurTime() then
		if IsValid(trc.Entity) and trc.Entity:GetClass() == "df_plane" then
			umsg.Start("df_bullet_hit", atk:GetPlane():GetDriver())
			umsg.End()
		end
	end
	local ret = {}
	ret.damage = true
	ret.effects = true
	return ret
end

function ENT:FireGun()
	if self:GetPlane():GetAmmo() > 1 && self:GetNextFire() < CurTime() then
		local bot = self:GetPlane():GetDriver():IsBot()
		local bullet = {}
		bullet.Num = 1
		bullet.Src = self:GetPos() + (self:GetForward() * 5)
		bullet.Dir = self:GetAngles():Forward()
		bullet.Tracer = 3
		if bot then
			bullet.Spread = Vector(0.1,0.1,0.1)
		else
			bullet.Spread = Vector(0.05,0.05,0.05)
		end
		bullet.Force = 2
		bullet.Damage = 7
		bullet.Callback = OnPlaneBulletHit;
		self:FireBullets(bullet)
		bullet = {}
		bullet.Num = 1
		bullet.Src = self.gun2:GetPos() + (self.gun2:GetForward() * 5)
		bullet.Dir = self.gun2:GetAngles():Forward()
		bullet.Tracer = 3
		bullet.Spread = Vector(0.03,0.03,0.03)
		bullet.Force = 2
		bullet.Damage = 6
		self.gun2:FireBullets(bullet)
		self:EmitSound("npc/turret_floor/shoot"..math.random(1,3)..".wav", 70,100)
		self:SetNextFire(CurTime() + 0.05)
	end
end

function ENT:Think()
	self:NextThink(CurTime() + 0.1)
	return true
end

function ENT:OnRemove()
end






