
local W = ScrW()
local H = ScrH()

local mat_fill = Material("DFHUD/rocket_fill")
local mat_out = Material("DFHUD/rocket_outline")

local border_size = 20
local border_size_x = 45

local PANEL = {}

PANEL.Size = 150

function PANEL:SetTeam(it)
	self.iTeam = it
	if it == TEAM_RED then
		self:SetPos(-border_size_x,-border_size)
	else
		self:SetPos(W - self.Size + border_size_x, -border_size)
	end
end

function PANEL:GetTeam()
	return self.iTeam
end

function PANEL:Init()
	self.last_fuel = nil
	self.rocket_fill_poly = {{},{},{},{}}
	self:UpdatePoly(0)
	self:SetSize(self.Size,self.Size)
	mat_out:SetVector("$color", Vector(0,0,0))
end

function PANEL:Think()
	local rock = GAMEMODE:GetRocket(self:GetTeam())
	if IsValid(rock) and rock.dt then
		if rock.dt.Fuel != self.last_fuel then
			self:UpdatePoly(rock.dt.Fuel)
			self.last_fuel = rock.dt.Fuel
		end
	end
end

function PANEL:UpdatePoly(fuel)
	local fill_frac = 1 - (fuel / GAMEMODE.MaxFuel)
	local y = Lerp(fill_frac, border_size, self.Size - border_size)
	self.rocket_fill_poly[1]["x"] = 0 //Top left
	self.rocket_fill_poly[1]["y"] = y
	self.rocket_fill_poly[1]["u"] = 0
	self.rocket_fill_poly[1]["v"] = y / self.Size

	self.rocket_fill_poly[2]["x"] = self.Size //Top right 
	self.rocket_fill_poly[2]["y"] = y
	self.rocket_fill_poly[2]["u"] = 1
	self.rocket_fill_poly[2]["v"] = y / self.Size

	self.rocket_fill_poly[3]["x"] = self.Size //bottom right
	self.rocket_fill_poly[3]["y"] = self.Size
	self.rocket_fill_poly[3]["u"] = 1
	self.rocket_fill_poly[3]["v"] = 1

	self.rocket_fill_poly[4]["x"] = 0 //Bottom left
	self.rocket_fill_poly[4]["y"] = self.Size
	self.rocket_fill_poly[4]["u"] = 0
	self.rocket_fill_poly[4]["v"] = 1
end

function PANEL:Paint()
	if self:GetTeam() == TEAM_RED then
		local col = team.GetColor(TEAM_RED)
		//mat_out:SetMaterialVector("$color", Vector(col.r/255,col.g/255,col.b/255))
		mat_fill:SetVector("$color", Vector(col.r/255,col.g/255,col.b/255))
	else
		local col = team.GetColor(TEAM_BLUE)
		//mat_out:SetMaterialVector("$color", Vector(col.r/255,col.g/255,col.b/255))
		mat_fill:SetVector("$color", Vector(col.r/255,col.g/255,col.b/255))
	end
	local rock = GAMEMODE:GetRocket(self:GetTeam())
	if IsValid(rock) and rock.dt then
		local iFuel = rock.dt.Fuel or 0
		surface.SetDrawColor(255,255,255,255)
		surface.SetMaterial(mat_fill)
		surface.DrawPoly(self.rocket_fill_poly)
		surface.SetMaterial(mat_out)
		surface.DrawTexturedRect( 0, 0, self.Size, self.Size)
		surface.SetFont("rocket_nums")
		local w,h = surface.GetTextSize(iFuel)
		surface.SetTextColor(255,255,255,255)
		local p = self.Size * 0.5
		surface.SetTextPos(p + 2 - w * 0.5, p - h * 0.5)
		surface.DrawText(iFuel)
	end
end

derma.DefineControl( "RocketIcon", "", PANEL, "DPanel" )

