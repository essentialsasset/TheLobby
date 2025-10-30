
-----------------------------------------------------
module( "FloatingChat", package.seeall )





local DrawChat = CreateClientConVar( "gmt_drawfloatingchat", 1, true )



Text = {}



surface.CreateFont( "FloatChat", { font = "Arial", size = 20, weight = 600 } )



TextColor		= Color( 250, 250, 250, 255 )

BGColor 		= Color( 20, 20, 20, 128 )

Font			= "FloatChat"





local function IsLookingTowards( ply, vect )



	local dot = ply:GetAimVector():DotProduct( ( vect - ply:GetPos() ):GetNormal() )

	return dot < 1



end



function Draw( id, chat )



	local ply = chat.Player



	if ply == LocalPlayer() && !LocalPlayer().ThirdPerson then return end



	chat.Alpha = math.Approach( chat.Alpha, chat.CurAlpha, FrameTime() * 800 )

	BGColor.a = ( chat.Alpha / 1.1 ) / id

	TextColor.a = chat.Alpha / id



	if chat.DieTime < CurTime() then



		chat.CurAlpha = 0



		if chat.Alpha == 0 then

			table.remove( ply._FloatingText, id )

			return

		end



	end



	if !IsValid( ply ) || !ply:Alive() then return end



	if IsLookingTowards( LocalPlayer(), ply:GetPos() ) || LocalPlayer() == ply then



		local pos = ply:GetShootPos()



		// Try to get head bone

		local head = ply:LookupBone( "ValveBiped.Bip01_Head1" )

		if head then

			local bonepos, boneang = ply:GetBonePosition( head )



			if bonepos then

				pos = bonepos

			end

		end



		// Override for Ball Race Orb

		--[[if IsValid( ply:GetBallRaceBall() ) then

			pos = ply:GetBallRaceBall():GetPos()

		end]]



		local pos = ( pos + Vector( 0, 0, 30 ) ):ToScreen()

		local text = chat.Text



		// Get size

		surface.SetFont( Font )

		local w,h = surface.GetTextSize( text )



		// Draw it

		if LocalPlayer():GetPos():WithinDistance( ply:GetPos(), 1000 ) then



			chat.ApproachY = math.Approach( chat.ApproachY, ( id * 28 ), FrameTime() * 80 )



			pos.y = pos.y + chat.ApproachY

			pos.x = pos.x - w / 2 - 5



			draw.WordBox( 4, pos.x, pos.y, text, Font, BGColor, TextColor )



		end



	end



end



hook.Add( "HUDPaint", "FloatingPaint", function()



	if DrawChat:GetBool() == false then return end



	local players = Location.GetPlayersInLocation( LocalPlayer():Location() )

	for _, ply in pairs( players ) do



		if !ply._FloatingText then ply._FloatingText = {} end

		if #ply._FloatingText == 0 then return end



		for id, chat in pairs( ply._FloatingText ) do

			FloatingChat.Draw( id, chat )

		end



	end



end )



function AddChat( ply, text )



	local chat = {}

	chat.Text = text

	chat.DieTime = CurTime() + 5

	chat.Player = ply

	chat.Alpha = 0

	chat.CurAlpha = 255

	chat.ApproachY = 0



	if !ply._FloatingText then ply._FloatingText = {} end

	table.insert( ply._FloatingText, 1, chat )



	if #ply._FloatingText > 3 then

		table.remove( ply._FloatingText, #ply._FloatingText )

	end



end



hook.Add( "OnPlayerChat", "FloatingChat", function( ply, text, teamtext, alive )



	if IsValid( ply ) && text != "" and not teamtext then

		AddChat( ply, text )

	end



end )
