
local W = ScrW()
local H = ScrH()

local being_used_mat = Material("sprites/light_glow01.vtf")
being_used_mat:SetInt( "$spriterendermode", RENDERMODE_GLOW )

local PANEL = {}

PANEL.Size = H / 12

function PANEL:Init()
	self:SetPos(W - self.Size - 15, 100)
	self:SetSize(self.Size + 15,((self.Size + 5) * 9) + 15)
	self.last_cur_weapon = nil
	self.last_wep_change = CurTime()
end

function PANEL:Think()
end

function PANEL:Paint()
	local all_weps = LocalPlayer():GetAllWeapons()
	for k,v in pairs(all_weps) do
		if IsValid(v) then
			local y_pos = k * (self.Size + 5)
			if v == LocalPlayer():GetCurrentWeapon() then
				surface.SetMaterial(being_used_mat)
				for i=1,5 do
					surface.DrawTexturedRect(0,y_pos, self.Size + 30, self.Size + 30)
				end
			end
			surface.SetTexture(v:GetIconMaterial())
			surface.DrawTexturedRect( 15, y_pos + 15, self.Size, self.Size)
			surface.SetFont("rocket_nums")
			local w,h = surface.GetTextSize(v:GetAmmo())
			draw.SimpleTextOutlined(  v:GetAmmo(),  "rocket_nums",  self.Size - 6,  y_pos + self.Size - 6,  Color(10,10,10,255),  TEXT_ALIGN_CENTER,  TEXT_ALIGN_CENTER,  2,  Color(251,200,37,255) )
			
			//draw.SimpleTextOutlined(  k,  "rocket_nums",  7,  y_pos + self.Size * 0.75,  Color(251,200,37,255),  TEXT_ALIGN_CENTER,  TEXT_ALIGN_CENTER,  2,  Color(10,10,10,255) )
		end
	end
end

derma.DefineControl( "PowerupList", "", PANEL, "DPanel" )

local PANEL = {}

function PANEL:Init()
	self:SetPos(0,0)
	self:SetSize(W,H)
	self.list = vgui.Create("PowerupList",self)
	self.last_cur = nil
	self.last_change = 0
	
	self.x_off_anim = 0
end

function PANEL:Think()
	if !IsValid(LocalPlayer():GetPlane()) then self:Remove() end
	if IsValid(LocalPlayer():GetCurrentWeapon()) and self.last_cur != LocalPlayer():GetCurrentWeapon() then
		self:OnWeaponChange()
	end
end

function PANEL:OnWeaponChange()
	self.last_cur = LocalPlayer():GetCurrentWeapon()
	self.last_cur_time = CurTime()
	//GAMEMODE:CenterMessage(LocalPlayer():GetCurrentWeapon().PrintName, 0.6)
end

function PANEL:Paint()
	if self.last_cur and self.last_cur_time then
		for k,v in pairs(LocalPlayer():GetAllWeapons()) do
			if IsValid(v) then
				local y_pos = k * (self.list.Size + 5)
				local _,list_y = self.list:GetPos()
				if v == LocalPlayer():GetCurrentWeapon() and self.last_cur_time + 0.5 > CurTime() then
					draw.SimpleTextOutlined( LocalPlayer():GetCurrentWeapon().PrintName,  "rocket_nums", W - 75,  y_pos + list_y + (self.list.Size * 0.75),  Color(251,200,37,255),  TEXT_ALIGN_RIGHT,  TEXT_ALIGN_CENTER,  2,  Color(10,10,10,255) )
				else
					draw.SimpleTextOutlined(  k,  "rocket_nums",  W - 75,  y_pos + list_y + (self.list.Size * 0.75),  Color(251,200,37,255),  TEXT_ALIGN_CENTER,  TEXT_ALIGN_CENTER,  2,  Color(10,10,10,255) )
				end
			end
		end
	end
end

derma.DefineControl( "PowerupElement", "", PANEL, "DPanel" )

