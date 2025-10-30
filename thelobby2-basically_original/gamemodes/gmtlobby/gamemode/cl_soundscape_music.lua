local function isEmpty(str)
	return str == nil or str == ""
end

local lastRand 
local curRand 
local function uniqueRandom(min, max )

	-- Prevent infinite loop
	if min == max then return min end

	-- Repeat until we have a new unique number 
	repeat
		curRand = math.random(min, max)
	until (curRand ~= lastRand )

	return curRand 
end

local Enabled = CreateClientConVar("gmt_bgmusic_enable", "1", true, false )
local Volume = CreateClientConVar("gmt_bgmusic_volume", "50", true, false )

-- Hook into when these babies change
cvars.AddChangeCallback(Enabled:GetName(), function(name, old, new )
	if not tobool(new) then
		soundscape.StopChannel("music", 0.5, true)
	else /*if not soundscape.IsPlaying("music_global_ambient") then
		soundscape.Play("music_global_ambient", "music", true)*/

		local scape = soundscape.GetMusicSoundscape( LocalPlayer():Location() ) or "music_global_ambient"
		soundscape.Play( scape, "music", true )
	end
end )

cvars.AddChangeCallback(Volume:GetName(), function(name, old, new )
	soundscape.SetVolume("music", math.Clamp(tonumber(new), 0, 100) / 100)
end )

-- Set initial volume
soundscape.SetVolume("music", math.Clamp(Volume:GetInt(), 0, 100) / 100)

-- Some locations call for certain behavior of soundscapes, more than just groups
-- This function is fine-tuned for background music, not just generic soundscapes
-- To define a custom musicscape, name it exactly as you would a normal soundscape, prefixed with "music_"
-- For example, a custom musicscape for the "lobby" location would be named "music_lobby"
soundscape = soundscape or {}
function soundscape.GetMusicSoundscape(loc)
	local location = Location.Get(loc)
	if not location then return end

	-- First, see if there's a soundscape defined for the current specific location
	local scape = soundscape.IsDefined("music_" .. location.Name) and "music_" .. location.Name or nil 
	scape = scape and string.lower(scape) or nil 

	-- if it's registered, return
	if not isEmpty(scape) then return scape end

	-- Move on to any overrides before we get to a 'group' soundscape
	-- Play a super quiet soundscape when they're in the movie theater itself
	if location.Group == "theater" and location.Name ~= "theatermain" then
		return "music_theater_inside"
	end

	-- When in the stores, stop playing the plaza soundscape
	if location.Group == "stores" and location.Name ~= "stores" then
		return "music_stores_inside"
	end

	-- Fix for the condos
	if location.CondoID then
		return "music_condo"
	end

	-- Just use default methods to find the soundscape
 	scape = Location.GetGroup(loc)

	-- Return what we've got
	return (scape and soundscape.IsDefined("music_" .. scape) ) and string.lower("music_" .. scape) or nil
end

-- Very similar to the one in cl_soundscape.lua
-- However, this one changes PASSIVELY, so that it's only changed when it's set to change
-- This keeps the music going even in new locations, whereas the other does not
hook.Add("Location", "MusicscapeChangeLocation", function(ply, loc)
	if not Enabled:GetBool() then return end

	-- Retrieve the two locations
	local newGroup = string.lower(Location.GetGroup(loc))

	-- Get the soundscape matching this location
	local sndscape = soundscape.GetMusicSoundscape(loc)

	-- if there's no soundscapes for this location stop the presses
	if isEmpty(sndscape) or not soundscape.IsDefined(sndscape) then
		 -- Only stop the soundscape if they're in no man's land
		if loc == 0 or Location.Get(loc) == nil then
			soundscape.StopChannel("music")

		-- Just play an ambient music track if there's no music override here
		elseif not soundscape.IsPlaying("music_global_ambient") then
			soundscape.StopChannel("music")
			soundscape.Play("music_global_ambient", "music", true)
		end
		return
	end

	-- If there is an actual defined soundscape for this location, use that
	if not soundscape.IsPlaying(sndscape) then
		soundscape.StopChannel("music")
		soundscape.Play(sndscape, "music")
	end
end )


--------------------------------------
--      SOUNDSCAPE DEFINITIONS      --
-- TODO: Better place to put these? --
--------------------------------------

//local LobbyMusicName = "GModTower/soundscapes/music/lobby"
//local LobbyMusicCount = 10 -- Define the number of music files for ambient lobby jams

local LobbyMusicName = "GModTower/soundscapes/music/deluxe_plaza"
local LobbyMusicCount = 13 -- Define the number of music files for ambient lobby jams

if IsHalloweenMap() then
	LobbyMusicName = "GModTower/soundscapes/music/halloween/deluxe_plaza"
	LobbyMusicCount = 3
end

if IsChristmasMap() then
	LobbyMusicName = "GModTower/soundscapes/music/christmas/deluxe_plaza"
	LobbyMusicCount = 4
end

local LobbySongs = {}
for n=1, LobbyMusicCount do 
	table.insert(LobbySongs, {LobbyMusicName .. n .. ".mp3", 10} )
end
soundscape.Register("music_global_ambient", 
{
	-- Tell the soundscape system that when this is usually removed and faded out, keep it alive
	idle = true, 

	-- Select a random song to play every once in a while
	{
	type = "playlist",
		time = {60 * 0.5, 60 * 5}, -- Play the next song 0.5 to 5 minutes after the song ends

		-- Override the sound selector function with our own
		sounds = LobbySongs,
	},
})

local GameMusicName = "GModTower/soundscapes/music/deluxe_games"
local GameMusicCount = 2
local GameSongs = {}
for n=1, GameMusicCount do
	table.insert(GameSongs, {GameMusicName .. n .. ".mp3", 10} )
end

soundscape.Register("music_games",
{
	-- Tell the soundscape system that when this is usually removed and faded out, keep it alive
	idle = true,

	-- Select a random song to play every once in a while
	{
	type = "playlist",
		time = {60 * 0.5, 60 * 5}, -- Play the next song 0.5 to 5 minutes after the song ends

		-- Override the sound selector function with our own
		sounds = GameSongs,
	},
})

-- Dynamically create the soundscapes based on gamemode names
for _, v in pairs(Location.Locations) do
	local gmode = GTowerServers:GetGamemode( v.Name )
	if not gmode then continue end 

	-- Format the songs so they're in { song, length } format 
	local formattedSongs = {}
	for __, song in pairs(gmode.Music) do
		table.insert(formattedSongs, {song, 10})
	end

	-- Create the rule to insert into the soundscape system
	//print("Registering soundscape", v.Name)
	soundscape.Register("music_" .. v.Name, 
	{ 
		dsp = 0,

		{
		type = "playrandom_bass",
			volume = 0.70,
			sounds = formattedSongs,
		},
	})
end

local TowerLobby = Sound("GModTower/soundscapes/music/towermainlobby1.mp3")
if IsHalloweenMap() then TowerLobby = Sound("gmodtower/soundscapes/music/halloween/condo_lobby.mp3") end

soundscape.Register("music_lobby", 
{
	{
	type = "playlooping",
		-- Limit the volume
		volume = 0.25,

		-- Start this sound's position syncronized with servertime
		--sync = true,

		-- All sounds are in a table format of {soundpath, soundlength}
		sound = {TowerLobby, 234},
	},
})

soundscape.Register("music_store",
{
	{
		type = "playlooping",
		-- Limit the volume
		volume = .7,

		-- All sounds are in a table format of {soundpath, soundlength}
		sound = {Sound("gmodtower/music/store_deluxe.mp3"), 67},
	},
})

soundscape.Register("music_store_merchant",
{
	{
		type = "playlooping",

		-- Limit the volume
		volume = .7,

		-- All sounds are in a table format of {soundpath, soundlength}
		sound = {Sound("gmt_minigolf_desert/desert_radio.wav"), (120+51)},
	},

})

/*if !IsHolidayMap() then
	soundscape.Register("music_cplaza",
	{
		{
			type = "playlooping",
			-- Limit the volume
			volume = 0.25,

			-- All sounds are in a table format of {soundpath, soundlength}
			sound = {Sound("gmodtower/soundscapes/music/deluxe_centralplaza.mp3"), 4},
		},
	})
end*/

-- Mute BG music in elevator
soundscape.Register("music_elevator", {})

-- Mute any music in the theater
soundscape.Register("music_theater_inside", {} )

-- Mute any music in the condo
soundscape.Register("music_condo", {})

-- Mute any music in the nightclub
soundscape.Register("music_nightclub", {})

-- Mute any music in the duels lobby
soundscape.Register("music_duels", {})

-- Mute any music in the duels arena
soundscape.Register("music_duelarena", {})

-- Mute any music in the transit station
soundscape.Register("music_transit", {})

-- Mute BG music in arcade
soundscape.Register("music_arcade", {})

-- Mute any music in the button room
soundscape.Register("music_button", {})

-- Mute any music in the hallway and dev hq
soundscape.Register("music_secret", {})

-- Mute any music in the hallway entrance
soundscape.Register("music_secret_entrance", {})