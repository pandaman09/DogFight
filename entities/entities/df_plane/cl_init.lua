include('shared.lua')

AccessorFunc(ENT,"iAmmo", "Ammo",NUMBER) // NOT NETWORKED handled with usermessages.
AccessorFunc(ENT,"iSecondAmmo", "SecondaryAmmo",NUMBER)

function ENT:Initialize()
	local ed = EffectData()
	ed:SetEntity(self)
	util.Effect("plane_effects", ed)
	self.Wind_Sound = CreateSound(self,"vehicles/fast_windloop1.wav")
end

function ENT:Draw()
	self:DrawModel()
end

function OnSpawnMenuClose( )
	RunConsoleCommand("-roll_l")
end

hook.Add("OnSpawnMenuClose","OnSpawnMenuclose",OnSpawnMenuClose)

function OnSpawnMenuOpen( )
	if IsValid(LocalPlayer():GetNWEntity("PLANE")) then
		RunConsoleCommand("+roll_l")
		return false
	end
end

hook.Add("OnSpawnMenuOpen", "OnSpawnMenuopen", OnSpawnMenuOpen)

function ENT:OnRemove()
	self.Wind_Sound:Stop()
end

