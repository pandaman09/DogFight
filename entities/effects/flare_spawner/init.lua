
local explode_glow = Material( "sprites/light_glow02" )
explode_glow:SetInt( "$spriterendermode", RENDERMODE_GLOW )

local explode_snd = Sound( "weapons/mortar/mortar_fire1.wav" )

local flare_count = 5

function EFFECT:Init( data )
	self.plane = data:GetEntity()
	self.flares = 0
	self.last_emit = 0
 end

 
function EFFECT:Think()
	if self.flares > flare_count then return false end
	if self.last_emit + 0.2 < CurTime() then
		self:EmitSound(explode_snd)
		local ED = EffectData()
		ED:SetEntity(self.plane)
		util.Effect("flare_ent", ED)
		self.flares = self.flares + 1
		self.last_emit = CurTime()
	end
	return true
end
 
function EFFECT:Render()
end
