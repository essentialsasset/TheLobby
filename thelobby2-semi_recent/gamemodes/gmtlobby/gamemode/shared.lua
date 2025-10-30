GM.Name 	= "GMod Tower: Deluxe"
GM.Author	= "Deluxe Team & PixelTail Games"
GM.Website	= "http://www.gmtdelxue.org/"
GM.AllowSpecialModels = true
GM.AllowEquippables = true

GM.UsesHands = true
IsLobby = true

DeriveGamemode( "gmodtower" )

if SERVER then
	game.ConsoleCommand("hostname [The Lobby: Deluxe] Lobby\n")
end

include("player_class/player_lobby.lua")

//=====================================================
game.AddParticles( "particles/lobby_2.pcf" )

local ParticleSystems = { "condo_fireplace", "condo_fireplace_embers", "condo_fireplace_burner",
"ocean_splash", "condo_fireplace_flames_2", "condo_fireplace_flames_3" }
						  
for _, part in pairs( ParticleSystems ) do
	PrecacheParticleSystem( part )
end
//=====================================================

function IsHalloweenMap()
	return string.EndsWith(game.GetMap(), "h")
end

function IsChristmasMap()
	return string.EndsWith(game.GetMap(), "c")
end

function IsHolidayMap()
	return ( IsHalloweenMap() || IsChristmasMap() )
end

if IsHalloweenMap() then
	if SERVER then AddCSLuaFile("sh_halloween.lua") end
	include("sh_halloween.lua")
end

Loadables.Load( {

	-- Old/Lobby 1
	--------------------------------------------------------
	--"theater",			-- Theater (Lobby 1)
	--"soundbrowser",		-- Sound browser (Lobby 1)
	--"bassemitstream",		-- Emit stream (radios)
	"ragdollcontroller",	-- Player ragdolling (Lobby 1)
	--"icon",				-- Scoreboard icons, no longer used
	--"npc_chat",			-- Chatting NPCs (suite and PVP Battle)
	"animation",			-- Force animation system
	--"ambiance",			-- Ambient music (Lobby 1)
	"enchant",				-- Player enchantments
	"trivia",				-- Trivia board
	--"funmeter",			-- Fun Meter (experimental minigame)
	--"spawner",			-- Special spawner (presents and candy)
	--"fakeself" 			-- Creates a fake third person model for WHEN GARRY BREAKS IT!

	-- WIP/Unfinished
	---------------------------------------------------------
	--"advertisement",		-- Advertisement system (WIP)
	--"lscontrol",			-- for live.gmtower.org
	--"autorestart" 		-- Manages restarting the server every so often (WIP)
	--"websocket",			-- WebSocket connection for cross-server/web chat
	--"racing",				-- Silly little minigame (WIP)
	--"boss",				-- Boss battle (WIP)

	-- Base Modules
	---------------------------------------------------------
	"inventory",			-- Inventory and items
	"clientsettings",		-- Client systems (GMC networking, etc.)
	"clsound",				-- Clientside emitsound sent by serverside actions
	"group",				-- Group
	"achievement",			-- Achievements
	"hacker",				-- Hacker logging
	"npc",					-- Store NPCs
	"room",					-- Suite/condo system
	"scoreboard3",			-- Scoreboard
	"store",				-- Stores
	"multiserver",			-- Multiserver
	"location",				-- Location system
	"seats",				-- Seat manager
	--"gibsystem",			-- Gibs
	"thirdperson",			-- Thirdperson
	"commands",				-- Chat commands (required for emotes)
	"afk",					-- AFK kicker
	"drunk", 				-- Drunk system
	--"events",				-- Random events (sales, minigames)
	"emote",				-- Player emote system (ie. /dance)
	"duel",					-- Player dueling
	"legs",					-- First person legs
	--"arcade",				-- Arcade API
	"contentmanager",		-- Alerts players when they're missing a required game or addon
	"fakeclientmodel",		-- Less-specific version of fakeself for drastic clientmodel modifications
	"ping",					-- Pings the clients to detect for server crashes
	"soundscape",			-- Soundscape system (Lobby 2)
	"theater2", 			-- Theater built with the media player (Lobby 2)
	"elevator",				-- Elevator system for suites (Lobby 2)
	"condopanel",			-- Condo OS
	"mapdata",				-- Map specific fixes and additions

	-- Items Depend On These
	---------------------------------------------------------
	"mediaplayer",			-- Media player
	"jetpack",				-- Jetpacks
	"bonemod",				-- Bone modifications
	"pet",					-- Pets
	"cards",				-- Poker module
	"minecraftskins",		-- Minecraft Steve model skins
	"auction",				-- Auction tables

	-- Debugging/Tools
	---------------------------------------------------------
	"weaponfix",			-- Fixes weapon viewmodels
	"errortrace",			-- Error debugging tracing

	-- UI/Misc
	---------------------------------------------------------
	"question",				-- Global voting
	--"radialmenu",			-- Zak's radial menu system
	--"kickstarter",		-- Kickstarter feed
	"multicore",			-- Possible Performance Booster

	-- Weapons
	---------------------------------------------------------
	--"weaponmanager",		-- Manages minigame weapons and such
	"pvp",					-- PVP weapons
	"virus",				-- Virus weapons

} )

function CanPlayerUse( arg1, arg2 )

	local ply, ent
	if CLIENT and !IsValid( arg2 ) then

		-- one argument can only be done clientside
		ply = LocalPlayer()
		ent = arg1

	else

		-- two args: ply and ent
		ply = arg1
		ent = arg2

	end
	if !IsValid( ply ) or !IsValid( ent ) then return nil end

	if ply:InVehicle() then return nil end
	if ent.HideTooltip then return nil end

	local class = ent:GetClass()

	-- Seats
	if seats.ChairOffsets[ ent:GetModel() ] then return "SIT" end

	-- Support custom prop sounds
	if class == "prop_physics_multiplayer" and ( (ply._NextUse or 0) < CurTime() ) then
		local Item = GTowerItems:GetTableByEntity( ent )
		if Item and Item.UseSound then
			return "TOUCH"
		end
	end

	// multiserver leave/join/offline
	if class == "gmt_multiserver" then
		if ent.ServerName && ent.ServerName == "Loading..." then
			return "GAMEMODE UNAVAILABLE, CHECK BACK LATER", true
		end

		if ent.ServerGamemode && LocalPlayer():GetNWString("QueuedGamemode") == ent.ServerGamemode then
			return "LEAVE"
		end

		return "JOIN"
	end

	-- Support custom entities
	if ent.CanUse then
		local enter, message = ent:CanUse( ply )
		return message, not enter
	end

	-- Doors
	if string.match(class, "func_door*") then return "OPEN/CLOSE" end

	-- Any props should be ignored
	if class == "prop_physics" or class == "prop_dynamic" or class == "prop_dynamic_override" then
		return nil
	end

	-- Just in case
	if ent.OnUse then
		return "USE"
	end

	return nil

end

function GM:PlayerUseTrace( ply, filter )

	if !filter then
		filter = ply
	end

	local pos = ply:EyePos()
	local trace = util.TraceLine({
		["start"] = pos,
		["endpos"] = pos + ( ply:GetAimVector() * 96 ),
		["filter"] = filter
	})

	return trace.Entity

end

function GM:FindUseEntity( ply, ent )

	local usable = self:PlayerUseTrace( ply, player.GetAll() ) -- getting players in location doesn't work with bots
	if IsValid( usable ) and CanPlayerUse( ply, usable ) then

		return usable

	end

	return ent

end

function GM:OnPlayerHitGround() return true end -- Disable fall damage sound

hook.Add("GTowerPhysgunPickup", "NoFuncForFun", function( ply, ent )
	local phys = ent:GetPhysicsObject()
	if IsValid( phys ) then
		phys:EnableMotion( true )
		phys:Wake()
	end

	local Class = ent:GetClass()
	if string.sub( Class, 1, 5 ) == "func_" or string.sub( Class, 1, 10 ) == "prop_door_" then
		return false
	end

	if ent:GetModel() == "models/gmod_tower/suite_bath.mdl" then
		return false
	end

	// No picking up of chairs
	if ent:GetClass() == "prop_vehicle_prisoner_pod" then
		return false
	end

	// Forbid anyone to pickup the live camera.
	if ent:IsPlayer() && ent:IsLiveStream() then
		return false
	end
end )

function GM:ShouldCollide( ent1, ent2 )
	if IsValid( ent1:GetNWEntity("DuelOpponent") ) && IsValid( ent2:GetNWEntity("DuelOpponent") ) then return true end
	return !(ent1:IsPlayer() and ent2:IsPlayer())
end