--[[
	Resource Table
]]
local ResourceLocations = {
	"materials/modulus/particles/",
	"materials/DFHUD/crosshair.vtf",
	"materials/bennyg/cannon_1/",
	"materials/models/airboat/",
	"models/Bennyg/Cannons/",
	"materials/bennyg/radar/",
	"models/Bennyg/Radar/",
	"models/Bennyg/plane/",
	"sound/df/"
}

--[[
	Desc: Load all the needed resources using ResourceLocations
]]
for key, dir in pairs( ResourceLocations ) do
	local files, dirs = file.Find( dir .. "*", "GAME" )
	if( not files ) then continue end
	for _, fileName in pairs( files ) do
		resource.AddFile(dir .. fileName)
		if( UL_DEBUG ) then
			Msg( "[DF] Adding resource: " .. dir .. fileName .. "\n" )
		end
	end
end
