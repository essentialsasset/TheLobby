AddCSLuaFile "shared.lua"

local BaseClass = baseclass.Get( "mp_entity" )

include "shared.lua"

function MEDIAPLAYER:Init()
	BaseClass.Init( self )

    self._TransmitState = TRANSMIT_LOCATION

    self._Voteskips = {}
    self._VoteManager = MediaPlayer.VoteManager:New( self )
    self._VoteskipManager = MediaPlayer.VoteskipManager:New( self )
	
	self._IsRoom = false -- Help me
	
    self:on( "mediaChanged", function( media )
        self._VoteskipManager:Clear()

        if ( IsValid( media ) ) then
            self._VoteManager:ClearVotesForMedia( media )
        end

        MediaPlayer.UpdateMediaVote( self )
    end )
end

function MEDIAPLAYER:NetWriteUpdate( ply )
    BaseClass.NetWriteUpdate( self )

    // _hasVoteskipped
    net.WriteBool( self._VoteskipManager:HasVoted( ply ) or false )
end

function MEDIAPLAYER:OnNetWriteMedia( media, ply )
    // votecount
	self.net.WriteVote( media:GetMetadataValue( "votes" ) or 0 )

    // ply vote
	self.net.WriteVote( self._VoteManager:HasVoted( media, ply ) && 1 or -1 )
end

local function queueVoteSort( a, b )
	local avote = a:GetMetadataValue( "votes" ) or 0
	local bvote = b:GetMetadataValue( "votes" ) or 0

    if ( avote == bvote ) then
        local atime = a:GetMetadataValue( "queueTime" )
	    local btime = b:GetMetadataValue( "queueTime" )

	    return atime < btime
    end

    return avote > bvote
end

function MEDIAPLAYER:SortQueue()
	table.sort( self._Queue, queueVoteSort )
end

MEDIAPLAYER._MaxDuration = 15*60 // 15 minutes

function MEDIAPLAYER:ShouldQueueMedia( media )
    local owner = media:Owner() or NULL
    if ( owner.IsStaff and owner:IsStaff() ) then return true end

    if ( not media:IsTimed() ) then return false, "Livestreams cannot be queued." end

    local duration = media:Duration() or nil
    if ( not duration ) then return false, T( "Theater_RequestFailed" ) end

	local MaxDuration = self._MaxDuration * ( owner:IsVIP() and 2 or 1 )
	
    // check duration
    if ( duration > MaxDuration ) && self._IsRoom == false then return false, T( "TheaterTooLong" ) end  // Temp, we should make a proper player for all of this

    for _, v in ipairs( self._Queue ) do
        if ( v.IsOwner && v:IsOwner( owner ) ) then
            return false, "You already have a song in the queue."
        end
    end

    return true
end