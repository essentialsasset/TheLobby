local meta = FindMetaTable( "Player" )
if !meta then
	Msg("ALERT! Could not hook Player Meta Table\n")
	return
end

function meta:PlaybackRateOV( rate )
	self:SetNWFloat( "PlaybackRate", math.Round( rate, 2 ) )
	self:SetNWBool( "PlaybackRateOver", true )
end

function meta:PlaybackReset()
	self:SetNWFloat( "PlaybackRate", 1 )
	self:SetNWBool( "PlaybackRateOver", false )
end

function GM:UpdateAnimation( ply, velocity, maxseqgroundspeed )
	
	local eye = ply:EyeAngles()
	
	local estyaw = math.Clamp( math.atan2( velocity.y, velocity.x ) * 180 / math.pi, -180, 180 )
	local myaw = math.NormalizeAngle( math.NormalizeAngle( eye.y ) - estyaw )
	
    // set the move_yaw ( because it's not an hl2mp model )
	ply:SetPoseParameter( "move_yaw", -myaw ) 
	
	local len2d = velocity:Length2D()
	local rate = 1.0
	
	if len2d > 0.5 then
		rate = (  len2d * 0.8  ) / maxseqgroundspeed
	end
	
	
	if !ply.Chimera then
	
		ply.SmoothBodyAngles = ply.SmoothBodyAngles || eye.y
		
		local pp = ply:GetPoseParameter( "head_yaw" )
	
		if ( pp > .9 || pp < .1 || len2d > 0 ) then
			
			ply.SmoothBodyAngles = math.ApproachAngle( ply.SmoothBodyAngles, eye.y, 5 )

			local y = ply.SmoothBodyAngles

			// correct player angles
			ply:SetLocalAngles(  Angle( 0, y, 0 )  )

			/*if CLIENT then

				local rang = ply:GetRenderAngles()

				//local diff = ( math.abs( eye.y ) - math.abs( rang.y))

				if len2d <= 0 then
					local num = 65
					
					if ply:GetNWBool( "IsGhost" ) then
						num = 25
					end
					
					if pp < .1 then
						rang.y = ( rang.y - num )
					else
						rang.y = ( rang.y + num )
					end
				end

				local diff = math.abs( math.AngleDifference( eye.y, rang.y ) )

				local num = diff * .12

				ply.SmoothBodyAnglesCL = ply.SmoothBodyAnglesCL || eye.y

				ply.SmoothBodyAnglesCL = math.ApproachAngle( ply.SmoothBodyAnglesCL, eye.y, num )

				//ply:SetRenderAngles( Angle( 0, ply.SmoothBodyAnglesCL, 0 ) )

			end*/
			
		end
		
		if CLIENT then
		
			if !ply:GetNWBool( "IsGhost" ) && !ply:GetNWBool( "IsChimera" ) then
			
				if ply.IsMicOpen then
					
					local num = math.sin( CurTime() * 32 ) * 5
					
					ply:SetPoseParameter( "snout", 5 + num )
					
				else

					if ply:GetPoseParameter( "snout" ) != 0 then
						ply:SetPoseParameter( "snout", 0 )
					end

				end

			end
			
		end
		
	else

		ply:SetLocalAngles( Angle( 0, eye.y, 0 ) )

		/*if CLIENT then
			ply:SetRenderAngles( Angle( 0, eye.y, 0 ) )
		end*/

	end
	
	rate = math.Clamp( rate, 0, 1 )
	
	if ply:GetNWBool( "PlaybackRateOver" ) then
		rate = ply:GetNWFloat( "PlaybackRate" )
	end

	ply:SetPlaybackRate( rate )
	
end

function GM:CalcMainActivity(  ply, velocity  )	

	ply.CalcIdeal = ACT_IDLE
	ply.CalcSeqOverride = "idle"

	if ply:GetNWBool( "IsChimera" ) then
		AnimateUC( ply, velocity )
		return ply.CalcIdeal, ply:LookupSequence( ply.CalcSeqOverride )
	end

	if ply:GetNWBool( "IsGhost" ) then
		AnimateGhost( ply, velocity )
		return ply.CalcIdeal, ply:LookupSequence( ply.CalcSeqOverride )
	end

	AnimatePig( ply, velocity )

	return ply.CalcIdeal, ply:LookupSequence( ply.CalcSeqOverride )

end

function GM:DoAnimationEvent(  ply, event, data  )

	if event == PLAYERANIMEVENT_ATTACK_PRIMARY then

		ply:AnimRestartGesture( GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_MELEE_ATTACK1, true )

		return ACT_VM_PRIMARYATTACK

	elseif event == PLAYERANIMEVENT_JUMP then

		ply:AnimRestartMainSequence()

		return ACT_INVALID

	end

	return nil

end