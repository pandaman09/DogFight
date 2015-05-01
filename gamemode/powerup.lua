
DF_POWERUPS = {}
DF_POWERUPS_WEIGHT_TOTAL = 0

function RegisterPowerup(tab, class)
	//print("REGISTERING",class)
	table.insert(DF_POWERUPS, {["TABLE"]=tab,["CLASS"]=class})
end

function CalculateWeights()
	for k,v in pairs(DF_POWERUPS) do
		v.TABLE.MinSelect = DF_POWERUPS_WEIGHT_TOTAL
		DF_POWERUPS_WEIGHT_TOTAL = DF_POWERUPS_WEIGHT_TOTAL + v.TABLE.PowerupWeight
		v.TABLE.MaxSelect = DF_POWERUPS_WEIGHT_TOTAL
	end
	for k,v in pairs(DF_POWERUPS) do
		local frc = (v.TABLE.MaxSelect - v.TABLE.MinSelect) / DF_POWERUPS_WEIGHT_TOTAL
		//print("CHANCE FOR", v.CLASS, math.floor(frc * 100).."%")
	end
end

hook.Add("Initialize", "Powerupinit", CalculateWeights)

//returns the table of a random powerup
function GetRandomPowerup()
	local target = math.random(1,DF_POWERUPS_WEIGHT_TOTAL)
	for _,pwp in pairs(DF_POWERUPS) do
		if pwp.TABLE.MinSelect < target and pwp.TABLE.MaxSelect >= target then
			return pwp
		end
	end
end
