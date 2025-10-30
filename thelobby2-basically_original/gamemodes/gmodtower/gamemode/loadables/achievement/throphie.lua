
hook.Add("Achievement", "GiveThrophie", function( ply, id )

	local Achievement = GTowerAchievements:Get( id )
	
	if Achievement.GiveItem then
	
		local ItemId = GTowerItems:FindByFile( Achievement.GiveItem )
		
		if ply:HasItemById( ItemId ) then 
			return
		end
		
		if !ItemId then
			Error("Could not give ".. Achievement.Name .. " thophy " .. tostring(Achievement.GiveItem) )
		end
	
		local Item = GTowerItems:CreateById( ItemId, ply ) 
		local Slot = GTowerItems:NewItemSlot( ply, "-2" ) //In the bank!
		
		if !Item then
			ply:Msg2( T("AchievementsTrophyFailed"), "trophy" )
		return end

		ply:Msg2( T("AchievementsTrophyGot", Item.Name), "trophy" )

		if Achievement.NotGiveSlot != true then
			//You are getting a raise! A free slot!
			ply:SetMaxBank( ply:BankLimit() + 1 )
		end
		
		Slot:FindUnusedSlot( Item, true )
		
		if !Slot:IsValid() then
			return
		end
		
		Slot:Set( Item )	
		Slot:ItemChanged()
	
	end

end )

concommand.Add("gmt_resettrophies", function( ply, cmd, args )
	
	if !GtowerRooms then
		//The item could be in the suite :/
		return
	end
	
	if ply._TrophiesReset && ply._TrophiesReset > CurTime() then
		return
	end
	
	ply._TrophiesReset = CurTime() + 1.0
	
	local TrophiesGiven = 0
	
	for k, Achievement in pairs( GTowerAchievements.Achievements ) do
		
		if ply:Achived( k ) && Achievement.GiveItem then
			
			local ItemId = GTowerItems:FindByFile( Achievement.GiveItem )
			
			if !ply:HasItemById( ItemId ) then 
				
				local Item = GTowerItems:CreateById( ItemId , ply ) 
				local Slot = GTowerItems:NewItemSlot( ply, "-2" ) //In the bank!
				
				if Item then
				
					Slot:FindUnusedSlot( Item, true )
					
					if Slot:IsValid() then
						Slot:Set( Item )	
						Slot:ItemChanged()
						TrophiesGiven = TrophiesGiven + 1
					end
					
				end
				
			end
			
		end
		
	end

	if TrophiesGiven > 0 then
		
		umsg.Start("GTAchRest", ply )
			umsg.Char( TrophiesGiven )
		umsg.End()
		
	end

end )