include('shared.lua')

function ENT:Initialize()
	self.DieTime = CurTime() + self.LifeTime
	local ED = EffectData()
	ED:SetEntity(self)
	ED:SetScale(self.LifeTime)
	util.Effect("missile_trail", ED)
end

function ENT:Draw()
	self.Entity:DrawModel()
end


