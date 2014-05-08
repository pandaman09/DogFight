--[[
	Check if it's a team based game.
]]

if( GM.TEAM_BASED ) then
	HELP_TEXT = "This is team deathmatch! Help your team!"
	
	--needs to be changed to a global shared so it can be changed if nessecary
	T_IDC = 1 
	T_GBU = 2
	team.SetUp( T_IDC, "International Destruction Corp", Color( 90, 60, 60, 255 ) )
	team.SetUp( T_GBU, "Global Builders Union", Color( 60, 90, 60, 255 ) )
else
	HELP_TEXT = "This is deathmatch kill all your opponents!"
	team.SetUp( 1, "Free For All", Color(255,255,255,255))
end