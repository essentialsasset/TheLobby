local Player = FindMetaTable("Player")

function Player:StartChatBubble()
	if IsValid(self.ChatBubble) then return end

	self.ChatBubble = ClientsideModel(GTowerChat.Bubble, RENDERGROUP_OPAQUE)
	self.ChatBubble:SetNoDraw(true)

	self.ChatBubble:ResetSequenceInfo()
	self.ChatBubble:ResetSequence(0)
end

function Player:EndChatBubble()
	if !IsValid(self.ChatBubble) then return end

	self.ChatBubble:Remove()
	self.ChatBubble = nil
end

local eye_offset = Vector(0,0,24)

function Player:ManualBubbleDraw()
	if !IsValid(self.ChatBubble) then return end

	local pos
	local override = hook.Call( "ChatBubbleOverride", GAMEMODE, self )
	if override then
		pos = override
		if !pos then return end
	else
		pos = self:EyePos() + eye_offset
	end

	if IsValid( self.ChatBubble ) then
		self.ChatBubble:SetRenderOrigin(pos + Vector(0, 0, math.sin(CurTime())) )
		self.ChatBubble:SetPlaybackRate(0.1)

		self.ChatBubble:FrameAdvance(FrameTime())
		self.ChatBubble:DrawModel()
	end

end

hook.Add( "PostPlayerDraw", "PositionBubble", Player.ManualBubbleDraw )

hook.Add( "EntityRemoved", "PlyGone", function( ply )
	if IsValid( ply ) && ply:IsPlayer() && IsValid(ply.ChatBubble) then
		ply:EndChatBubble()
	end
end)