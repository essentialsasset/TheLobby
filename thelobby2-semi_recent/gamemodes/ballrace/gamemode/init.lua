AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_choose.lua")
AddCSLuaFile("cl_message.lua")
AddCSLuaFile("sh_mapnames.lua")

include("shared.lua")
include("round.lua")
include("player.lua")
include("sql.lua")

ActiveTeleport = nil
NextMap = nil
LateSpawn = nil

afks = {}

CreateConVar("gmt_srvid", 4 )

function GM:Initialize()

	self:SetState( STATE_NOPLAY )

	GAMEMODE.LateSpawn = nil
	GAMEMODE.RoundNum = 0
	GAMEMODE.PreviousState = self:GetState()

end

hook.Add( "GTAfk", "BRAFK", function( afk, ply )

	afks[ply] = afk

end )

hook.Add( "PlayerDisconnected", "NoPlayerCheck", function(ply)
	
	if ply:IsBot() then return end

	timer.Simple( 5, function()
		if player.GetCount() == 0 then GAMEMODE:EndServer() return end
	end )

end )

function GM:Think()

	local ThatTime = true

	for k,v in pairs(player.GetAll()) do
		if v:Team() == TEAM_PLAYERS and !v.AFK then
			ThatTime = false
		end
	end

	if !ThatTime then return end

	for ply,afk in pairs(afks) do
		if afk then
			if ply:Team() == TEAM_DEAD then continue end

			ply:SetTeam(TEAM_DEAD)
			GAMEMODE:UpdateSpecs(ply, true)
			GAMEMODE:LostPlayer(ply)
		end
	end

end

function NumPlayers(team)

	local count = 0

	for k,v in ipairs(player.GetAll()) do
		if v:Team() == team then
			count = count + 1
		end
	end

	return count

end

local function PlayerSetup( ply )

	ply:SetModel(default_pm)

end

concommand.Add("gmt_requestballupdate",function(ply)

	net.Start( 'GtBall' )
		net.WriteInt( 0, 2 )
		net.WriteBool(GTowerStore:GetPlyLevel(ply,"BallRacerCube") == 1)
		net.WriteBool(GTowerStore:GetPlyLevel(ply,"BallRacerIcosahedron") == 1)
		net.WriteBool(GTowerStore:GetPlyLevel(ply,"BallRacerCatBall") == 1)
		net.WriteBool(GTowerStore:GetPlyLevel(ply,"BallRacerBomb") == 1)
		net.WriteBool(GTowerStore:GetPlyLevel(ply,"BallRacerGeo") == 1)
		net.WriteBool(GTowerStore:GetPlyLevel(ply,"BallRacerSoccerBall") == 1)
		net.WriteBool(GTowerStore:GetPlyLevel(ply,"BallRacerSpikedd") == 1)
	net.Send( ply )

end)

local function GamemodeNotFull()
	return true // ballrace will always have afk enabled, even if not full
end

hook.Add( "PlayerInitialSpawn", "PlayerSetup", PlayerSetup )

hook.Add( "PlayerSpawn", "whee", function( ply )

	ply:SetNoDraw(true)
	hook.Call( "PlayerSetModel", GAMEMODE, ply )

end )

hook.Add( "AFKNotFull", "GamemodeNotFull", GamemodeNotFull )

// no anti-tranquility on gamemodes
hook.Add( "AntiTranqEnable", "GamemodeAntiTranq", function() return false end )

function GM:PlayerDeath( victim, inflictor, attacker )

	if ( self:GetState() != STATE_PLAYINGBONUS && self:GetState() != STATE_INTERMISSION ) then
		victim:SetNWBool( "Died", true )
		victim:SetNWBool( "Popped", true )
	end

end

timer.Create( "AchiBallerRoll", 60.0, 0, function()

	for _, v in pairs( player.GetAll() ) do
		if v:AchievementLoaded() then
			v:AddAchievement( ACHIEVEMENTS.BRBALLERROLL, 1 )
		end
	end

end )

util.AddNetworkString( "roundmessage" )
util.AddNetworkString( "BGM" )
util.AddNetworkString( "br_electrify" )
util.AddNetworkString( "pick_ball" )
util.AddNetworkString( "GtBall" )
