if SERVER then
	AddCSLuaFile "shared.lua"
	AddCSLuaFile "cl_init.lua"

	--resource.AddFile "materials/theater/STATIC.vmt"
end
include "shared.lua"

ENT.UseDelay = 0.5 -- seconds

ENT.IdleScreenTitle = "Daniel Tower Present: Magine TV & Vanilla Thorsten: Raus aus dem Sender-Dschungel"
ENT.IdleScreenDuration = (2*60) + 06
ENT.IdleScreenURL = "https://www.youtube.com/watch?v=jk4-d2tBqpc"

hook.Add("Location", "TurnOffTV", function( ply, loc )
	for k,v in pairs(ents.FindByClass('mediaplayer_*')) do
		local mp = v:GetMediaPlayer()

		if not mp then
			ErrorNoHalt("MediaPlayer test entity doesn't have player installed\n")
			debug.Trace()
			return
		end

		if mp:HasListener(ply) then
			mp:RemoveListener(ply)
		end
	end
	
	for k,v in pairs(ents.FindByClass('gmt_room_tv')) do
		local mp = v:GetMediaPlayer()

		if not mp then
			ErrorNoHalt("MediaPlayer test entity doesn't have player installed\n")
			debug.Trace()
			return
		end

		if mp:HasListener(ply) then
			mp:RemoveListener(ply)
		end
	end
	
	for k,v in pairs(ents.FindByClass('gmt_jukebox')) do
		local mp = v:GetMediaPlayer()

		if not mp then
			ErrorNoHalt("MediaPlayer test entity doesn't have player installed\n")
			debug.Trace()
			return
		end

		if loc == Location.Find(v:GetPos()) then
			if !mp:HasListener(ply) then
				mp:AddListener(ply)
			end
		else
			if mp:HasListener(ply) then
				mp:RemoveListener(ply)
			end
		end

	end
	
	for k,v in pairs(ents.FindByClass('gmt_condoplayer')) do
		local mp = v:GetMediaPlayer()

		if not mp then
			ErrorNoHalt("MediaPlayer test entity doesn't have player installed\n")
			debug.Trace()
			return
		end

		if loc == Location.Find(v:GetPos()) then
			if !mp:HasListener(ply) then
				mp:AddListener(ply)
			end
		else
			if mp:HasListener(ply) then
				mp:RemoveListener(ply)
			end
		end

	end
	
	for k,v in pairs(ents.FindByClass('gmt_club_dj')) do
		local mp = v:GetMediaPlayer()

		if not mp then
			ErrorNoHalt("MediaPlayer test entity doesn't have player installed\n")
			debug.Trace()
			return
		end

		if loc == Location.Find(v:GetPos()) then
			if !mp:HasListener(ply) then
				mp:AddListener(ply)
			end
		else
			if mp:HasListener(ply) && loc != 26 then
				mp:RemoveListener(ply)
			end
		end

	end

	for k,v in pairs(ents.FindByClass('gmt_theater_screen')) do
		local mp = v:GetMediaPlayer()

		if not mp then
			ErrorNoHalt("MediaPlayer test entity doesn't have player installed\n")
			debug.Trace()
			return
		end
		
		if !v:GetNoDraw() then
			v:SetNoDraw( true )
		end

		if loc == Location.Find(v:GetPos()) then
			if !mp:HasListener(ply) then
				mp:AddListener(ply)
			end
		else
			if mp:HasListener(ply) then
				mp:RemoveListener(ply)
			end
		end

	end

	for k,v in pairs(ents.FindByClass('gmt_radio')) do
		local mp = v:GetMediaPlayer()

		if not mp then
			ErrorNoHalt("MediaPlayer test entity doesn't have player installed\n")
			debug.Trace()
			return
		end

		if mp:HasListener(ply) then
			mp:RemoveListener(ply)
		end
	end
end)

function ENT:Use(ply)
	if not IsValid(ply) then return end

	-- Delay request
	if ply.NextUse and ply.NextUse > CurTime() then
		return
	end

	local mp = self:GetMediaPlayer()

	if not mp then
		ErrorNoHalt("MediaPlayer test entity doesn't have player installed\n")
		debug.Trace()
		return
	end

	if mp:HasListener(ply) then
		mp:RemoveListener(ply)
	else
		mp:AddListener(ply)
	end

	ply.NextUse = CurTime() + self.UseDelay
end

function ENT:UpdateTransmitState()
	return TRANSMIT_PVS
end

function ENT:OnEntityCopyTableFinish( data )
	local mp = self:GetMediaPlayer()
	data.MediaPlayerSnapshot = mp:GetSnapshot()
	data._mp = nil
end

function ENT:PostEntityPaste( ply, ent, createdEnts )
	local snapshot = self.MediaPlayerSnapshot
	if not snapshot then return end

	local mp = self:GetMediaPlayer()
	self:SetMediaPlayerID( mp:GetId() )

	mp:RestoreSnapshot( snapshot )

	self.MediaPlayerSnapshot = nil
end

function ENT:KeyValue( key, value )
	if key == "model" then
		self.Model = value
	end
end

local function CreateMedia( title, duration, url, ownerName, ownerSteamID, startTime )
	local media = MediaPlayer.GetMediaForUrl( url )

	media._metadata = {
		title = title,
		duration = duration
	}

	media._OwnerName = ownerName
	media._OwnerSteamID = ownerSteamID
	media:StartTime( startTime or RealTime() )

	return media
end

function ENT:StartIdleScreen(mp)
	mp:AddMedia( CreateMedia(
		self.IdleScreenTitle,
		self.IdleScreenDuration,
		self.IdleScreenURL,
		"",
		""
	) )
end

function ENT:Think()
	if self:GetClass() == "gmt_theater_screen" then
		local mp = self:GetMediaPlayer()
		if !mp:IsPlaying() then
			self:StartIdleScreen(mp)
		else
			if #mp._Queue > 0 then
				if ( mp:GetMedia():Title() == self.IdleScreenTitle && mp:GetMedia():OwnerName() == "" && mp:GetMedia():OwnerSteamID() == "" ) then
					mp:OnMediaFinished()
				end
			end
		end
	end
end
