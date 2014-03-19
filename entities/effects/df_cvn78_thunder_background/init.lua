
local function Snd(filename, duration)
	local path = "df/cvn78/" .. filename .. ".mp3"

	Sound(path)

	return {path, duration}
end

local z_min_main = 15294
local z_max_main = 15295

local y_min_main = -15225
local y_max_main =  15295

local x_min_main = -15295
local x_max_main =  15225

local z_min_skybox = -2541
local z_max_skybox = -2540

local y_min_skybox = -2096
local y_max_skybox =  2096

local x_min_skybox = -2096
local x_max_skybox =  2096

-- These last four are procedurally filled in
local y_skybox_offset_min
local y_skybox_offset_max

local x_skybox_offset_min
local x_skybox_offset_max

local got_local_values = false

local TraceData = {mask = MASK_SOLID || MASK_WATER}

function EFFECT:Init(data)
	g_CVN78ThunderManager = self
	--ErrorNoHalt("INI!\n")
	self.LastEvent = 0

	local ply = LocalPlayer()

	self:SetPos(ply:GetPos())
	self:SetParent(ply)

	return self:Event()
end

function EFFECT:Event()
	if not (self and self.IsValid and self:IsValid()) then return end

	if not got_local_values then
		if not string.find(string.gsub(ents.GetByIndex(0):GetModel(), "(%w*/)", ""), "df_cvn78") then -- Only for my map, don't want to have to recompile either
			local bottom = GetGlobalInt("df_cvn78_manager_bottom", -1)

			if bottom == -1 then return timer.Simple(1, self.Event, self) end -- Probably need a better way of doing this but wtf, it works for now.
																			  -- This system wasn't meant to be fully reusable in other maps anyways,
																			  -- I've just hacked it in as a favour.

			z_min_main = bottom
			z_max_main = GetGlobalInt("df_cvn78_manager_top",      15295)

			y_min_main = GetGlobalInt("df_cvn78_manager_left",    -15225)
			y_max_main = GetGlobalInt("df_cvn78_manager_right",    15225)

			x_min_main = GetGlobalInt("df_cvn78_manager_back",    -15295)
			x_max_main = GetGlobalInt("df_cvn78_manager_forward",  15225)

			z_min_skybox = GetGlobalInt("df_cvn78_manager_bottom_skybox",  -2541)
			z_max_skybox = GetGlobalInt("df_cvn78_manager_top_skybox",     -2540)

			y_min_skybox = GetGlobalInt("df_cvn78_manager_left_skybox",    -2096)
			y_max_skybox = GetGlobalInt("df_cvn78_manager_right_skybox",    2096)

			x_min_skybox = GetGlobalInt("df_cvn78_manager_forward_skybox", -2096)
			x_max_skybox = GetGlobalInt("df_cvn78_manager_back_skybox",     2096)
		end

		local y = ((y_max_main - y_min_main) / 16) * .25
		local x = ((x_max_main - x_min_main) / 16) * .25
		--Msg((x_max_main - x_min_main) / 16, "\n")
		--Msg((y_max_main - y_min_main) / 16, "\n")
		--Msg("----\n")

		y_skybox_offset_min = y_min_skybox + y
		y_skybox_offset_max = y_max_skybox - y

		x_skybox_offset_min = x_min_skybox + x
		x_skybox_offset_max = x_max_skybox - x
		--Msg(x_min_skybox, " : ", x_skybox_offset_min, "\n")
		--Msg(y_min_skybox, " : ", y_skybox_offset_min, "\n")
		got_local_values = true
	end

	local skybox = math.random(1, 7) <= 4

	if skybox then
		--local x = (math.random(0, 1) == 1) and math.Rand(x_min_skybox, x_skybox_offset_min) or math.Rand(x_skybox_offset_max, x_max_skybox)
		--local y = (math.random(0, 1) == 1) and math.Rand(y_min_skybox, y_skybox_offset_min) or math.Rand(y_skybox_offset_max, y_max_skybox)
		local x = math.Rand(x_min_skybox, x_max_skybox)
		local y = math.Rand(y_min_skybox, y_max_skybox)
		--ErrorNoHalt("X: ", x, "\n")
		--ErrorNoHalt("Y: ", y, "\n")
		TraceData.start = Vector(x, y, math.random(z_min_skybox, z_max_skybox))
	else
		TraceData.start = Vector(math.random(x_min_main, x_max_main), math.random(y_min_main, y_max_main), math.random(z_min_main, z_max_main))
	end

	TraceData.endpos = TraceData.start + (Vector(math.Rand(-.15, .15), math.Rand(-.15, .15), -1) * 99999)

	local tr = util.TraceLine(TraceData)

	if not tr.HitSky then
		local fx = EffectData()
		fx:SetOrigin(tr.StartPos)
		fx:SetStart(tr.HitPos)
		fx:SetMagnitude(true)
		fx:SetScale(skybox and 2 or 1)

		util.Effect("df_cvn78_thunder", fx, true, true)
	end

	return timer.Simple(math.Rand(1, 3), self.Event, self)
end

function EFFECT:Think()
	return (g_CVN78ThunderManager == self)
end

function EFFECT:Render()
end
