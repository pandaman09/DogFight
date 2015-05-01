MsgN("Shared init")
/*
	shared.lua - Shared Component
	-----------------------------------------------------
	This is the shared component of your gamemode, a lot of the game variables
	can be changed from here.
*/

DeriveGamemode( "fretta" )
IncludePlayerClasses()	

include( "player_extension.lua" )
include( "aerobatics.lua" )
include( "powerup.lua")

DF_BOT_NAMES = {}
DF_BOT_NAMES[1] = "Whisky Delta"
DF_BOT_NAMES[2] = "Stay Frosty"
DF_BOT_NAMES[3] = "Oscar Mike"
DF_BOT_NAMES[4] = "Lt. Butterscotch"
DF_BOT_NAMES[5] = "Not A Bot"
DF_BOT_NAMES[6] = "Red Baron"
DF_BOT_NAMES[7] = "Aces High"
DF_BOT_NAMES[8] = "Daimao\'s Evil Twin"
DF_BOT_NAMES[9] = "Hawkeyes"
DF_BOT_NAMES[10] = "Pvt. Billiam Bottomsworth"
DF_BOT_NAMES[11] = "Cpt. Obvious"
DF_BOT_NAMES[12] = "Narry Gewman"
DF_BOT_NAMES[13] = "Dr. Freeman"
DF_BOT_NAMES[14] = "Stanford Spitfire"
DF_BOT_NAMES[15] = "Mach 1"
DF_BOT_NAMES[16] = "Alfred Irmiles"
DF_BOT_NAMES[17] = "U.A.V"
DF_BOT_NAMES[18] = "Down With Humans!"
DF_BOT_NAMES[19] = "Leeroy Jenkins"
DF_BOT_NAMES[20] = "humans:Kill()"
DF_BOT_NAMES[21] = "... .-- --- .-. -.. ...- .- -."

function GM:SetRocket(Team,ent) SetGlobalEntity("df_rocket"..Team, ent) end
function GM:GetRocket(Team) return GetGlobalEntity("df_rocket"..Team) end //inlines

function GM:SetFuelPod(Team,ent) SetGlobalEntity("df_fuelpod"..Team, ent) end
function GM:GetFuelPod(Team) return GetGlobalEntity("df_fuelpod"..Team) end

GM.Name 	= "Dogfight: Arcade Assault"
GM.Author 	= "Conman420"
GM.Email 	= ""
GM.Website 	= "Thread"
GM.Help		= "Aerial warfare in the traditional airboat plane! Capture the enemies fuel tank to fuel your rocket and win the game!"

GM.TeamBased = true					// Team based game or a Free For All game?
GM.AllowAutoTeam = true			// Allow auto-assign?
GM.AllowSpectating = true			// Allow people to spectate during the game?
GM.SecondsBetweenTeamSwitches = 5	// The minimum time between each team change?
GM.GameLength = 60					// The overall length of the game
GM.RoundLimit = 2				// Maximum amount of rounds to be played in round based games
GM.VotingDelay = 5					// Delay between end of game, and vote. if you want to display any extra screens before the vote pops up

GM.KillsForRank = 5 //How many kills until you are allowed on the leaderboard

GM.NoPlayerSuicide = false			// Set to true if players should not be allowed to commit suicide.
GM.NoPlayerDamage = false			// Set to true if players should not be able to damage each other.
GM.NoPlayerSelfDamage = false		// Allow players to hurt themselves?
GM.NoPlayerTeamDamage = true		// Allow team-members to hurt each other?
GM.NoPlayerPlayerDamage = true  	// Allow players to hurt each other?
GM.NoNonPlayerPlayerDamage = true 	// Allow damage from non players (physics, fire etc)
GM.NoPlayerFootsteps = false		// When true, all players have silent footsteps
GM.PlayerCanNoClip = false			// When true, players can use noclip without sv_cheats
GM.TakeFragOnSuicide = false			// -1 frag on suicide

GM.RespawnWaveTime = 5
GM.MaximumDeathLength = GM.RespawnWaveTime * 2  // Player will repspawn if death length > this (can be 0 to disable)
GM.MinimumDeathLength = GM.RespawnWaveTime 		// Player has to be dead for at least this long
GM.FuelSpawnDelay = 60 							//Let people battle it out first
GM.FuelReturnTime = 20
GM.MaxFuel = 3									//How much fuel is needed to win

GM.AutomaticTeamBalance = true    	// Teams will be periodically balanced 
GM.ForceJoinBalancedTeams = true	// Players won't be allowed to join a team if it has more players than another team
GM.RealisticFallDamage = false		// Set to true if you want realistic fall damage instead of the fix 10 damage.
GM.AddFragsToTeamScore = false		// Adds player's individual kills to team score (must be team based)

GM.ScoreEvents = {}
GM.ScoreEvents["kill"] = {Score = 25, Text = "Killed %s !"}
GM.ScoreEvents["friendlykill"] = {Score = -10, Text = "Killed wingman!"}
GM.ScoreEvents["capture"] = {Score = 100, Text = "Captured Fuel!"}
GM.ScoreEvents["fuelrescue"] = {Score = 25, Text = "Kill Fuel Carrier!"}
GM.ScoreEvents["firstblood"] = {Score = 25, Text = "First Blood!"}
GM.ScoreEvents["pickup"] = {Score = 20, Text = "Stole Fuel!"}
GM.ScoreEvents["missiledodge"] = {Score = 5, Text = "Evaded Missile!"}

GM.NoAutomaticSpawning = false		// Players don't spawn automatically when they die, some other system spawns them
GM.RoundBased = true				// Round based, like CS
GM.RoundLength = 900				// Round length, in seconds
GM.RoundPreStartTime = 3			// Preperation time before a round starts
GM.RoundPostLength = 20				// Seconds to show the 'x team won!' screen at the end of a round
GM.DefaultRoundPostLength = GM.RoundPostLength	// Cos I chage it sometimes
GM.RoundEndsWhenOneTeamAlive = false// CS Style rules

GM.EnableFreezeCam = false			// TF2 Style Freezecam
GM.DeathLingerTime = 1				// The time between you dying and it going into spectator mode, 0 disables

GM.SelectModel = false              // Can players use the playermodel picker in the F1 menu?
GM.SelectColor = false				// Can players modify the colour of their name? (ie.. no teams)

GM.PlayerRingSize = 48              // How big are the colored rings under the player's feet (if they are enabled) ?
GM.HudSkin = "SimpleSkin"			// The Derma skin to use for the HUD components
GM.SuicideString = " is a Kamikaze!"// The string to append to the player's name when they commit suicide.
GM.DeathNoticeDefaultColor = Color( 255, 128, 0 ); // Default colour for entity kills
GM.DeathNoticeTextColor = color_white; // colour for text ie. "died", "killed"

GM.ValidSpectatorModes = { OBS_MODE_CHASE, OBS_MODE_ROAMING } // The spectator modes that are allowed
GM.ValidSpectatorEntities = { "df_plane", "df_map_center" }	// Entities we can spectate, players being the obvious default choice.
GM.CanOnlySpectateOwnTeam = false; // you can only spectate players on your own team

TEAM_PILOTS = 1
TEAM_RED = 1
TEAM_BLUE = 2

if GM.TeamBased then
	team.SetUp( TEAM_RED, "Red", Color( 255, 50, 50 ), true)
	team.SetUp( TEAM_BLUE, "Blue", Color( 50, 50, 255 ), true)
	TEAM_BLUE_WAVE = 0
	TEAM_RED_WAVE = 0
else
	team.SetUp( TEAM_PILTOS, "Pilots", Color(70,255,70), false)
end

/*---------------------------------------------------------
   Name: gamemode:PlayerNoClip( player, bool )
   Desc: Player pressed the noclip key, return true if
		  the player is allowed to noclip, false to block
---------------------------------------------------------*/
function GM:PlayerNoClip( pl, on )
	return false
end
