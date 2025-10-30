---------------------------------
GMode.Name = "Monotone"
GMode.Gamemode = "monotone"
//Set true if players should be kicked if their "goserver" value on the database is not the same as the local server
GMode.Private = true
//Set true if this is only played by VIPs
GMode.VIP = false
//This is amount of time between the players being server to play
//And the players be able to join the game
GMode.WaitingTime = 15.0
//This setting is for large group join
//When you want all people to connect at once, the server must be empty to people be able to join.
//Set this to false if you want people to be able to go in and out of the server at any time.
//Set also the min amount of players to join the sevrer
GMode.OneTimeJoin = true
GMode.MinPlayers = 2

//Set this if only a group can join
GMode.GroupJoin = false
GMode.MaxPlayers = 8 //Leave nil if the maxplayers are suppost to be the server maxplayers
GMode.Gameplay = ""
GMode.Maps = {"gmt_mono_main"}
GMode.MapsNames = {
	["gmt_mono_main"] = "Monotone",
}
GMode.View = {
	pos = Vector( 11398, 9227, 6711 ),
	ang = Angle( -8, 20, 0 )
}
function GMode:GetMapTexture( map )

	if map == "gmt_mono_main" then
		map = map
	else
		map = string.sub(map,0,#map-2)
	end

	return "gmod_tower/maps/" .. map

end

GMode.Tips = {
	"Try not to waste your ink, running out could cause you to lose!",
	"Keep an eye out on the radar, it shows where the artifacts are!",
}
GMode.Music = {
	"gmodtower/mono/round/round1.mp3",
	"gmodtower/mono/round/round2.mp3",
	"gmodtower/mono/round/round3.mp3",
	"gmodtower/mono/waiting/waiting.mp3",
}
function GMode:ProcessData( ent, data )
	ent.NoData = ( #data == 0 )
	if ent.NoData then return end
	ent.NoData = false
	if data == "#nogame" then
		ent.NoGameMarkup = markup.Parse( T( "GamemodePanelNoGame" ) )
		ent.NoGameMarkup.PosX = ent.TotalMinX + ent.TotalWidth * 0.5 - ent.NoGameMarkup:GetWidth() / 2
		ent.NoGameMarkup.PosY = ent.TotalMinY + ent.TopHeight * 0.75 - ent.NoGameMarkup:GetHeight() / 2
		return
	end
	ent.NoGameMarkup = nil
	/*local Explode = string.Explode( "||||", data )
	local RoundStatus = string.Explode("/", Explode[1] )
	local cur, max = tonumber(RoundStatus[1]), tonumber(RoundStatus[2])
	//ent.InBonusRound = (cur < 0)
	if !cur then cur = 0 end
	if !max then max = 18 end
	local frac = (math.abs(cur) / max)
	ent.ProgressX = ent.TotalMinX + ent.TotalWidth * 0.05
	ent.ProgressY = ent.TotalMinY + ent.TopHeight * 0.65
	local tr = (ent.TotalMinX + ent.TotalWidth * 0.8)
	local tw = (tr - ent.ProgressX)
	ent.ProgressWidth = tw * frac
	ent.CompleteWidth = tw
	ent.ProgressHeight = 30
	local text = "<font=GTowerGMTitle><color=ltgrey>Hole:</color> " .. string.format("%d / %d", math.abs(cur), max) .. "</font>"
	ent.ProgressText = markup.Parse(text)
	ent.ParTitle = markup.Parse( "<font=GTowerGMTitle><color=grey>PAR</color></font>" )
	ent.ParMarkup = markup.Parse( "<font=GTowerHUDMainLarge>" .. tonumber(Explode[2]) .. "</font>" )
	PositionCenter( ent, ent.ParTitle, 0.9, 0.60 )
	PositionCenter( ent, ent.ParMarkup, 0.9, 0.85 )
	ent.ProgressText.PosX = ent.ProgressX + ( tw / 2 ) - ( ent.ProgressText:GetWidth() / 2 )
	ent.ProgressText.PosY = ent.ProgressY + ( ent.ProgressHeight / 2 ) - ( ent.ProgressText:GetHeight() / 2 )*/

	/*surface.SetFont("GTowerbig")
	local w, h = surface.GetTextSize(bonustext)
	ent.BonusX = ent.TotalMinX + ent.TotalWidth * 0.75 - (w/2)
	ent.BonusY = ent.TotalMinY + ent.TopHeight * 0.78 - (h/2)*/
end
local color_red = Color(200, 0, 0, 100)
local color_black = Color(0, 0, 0, 150)
GMode.DrawData = function( ent )
	if ent.NoData then return end
	if ent.NoGameMarkup then
		ent.NoGameMarkup:Draw( ent.NoGameMarkup.PosX, ent.NoGameMarkup.PosY )
		return
	end
	surface.SetDrawColor(color_red)
	surface.DrawRect(ent.ProgressX, ent.ProgressY, ent.ProgressWidth, ent.ProgressHeight)
	surface.SetDrawColor(color_black)
	surface.DrawOutlinedRect(ent.ProgressX, ent.ProgressY, ent.CompleteWidth, ent.ProgressHeight)
	if ent.ProgressText then
		ent.ProgressText:Draw( ent.ProgressText.PosX, ent.ProgressText.PosY )
	end
	if ent.ParMarkup then
		ent.ParTitle:Draw( ent.ParTitle.PosX, ent.ParTitle.PosY )
		ent.ParMarkup:Draw( ent.ParMarkup.PosX, ent.ParMarkup.PosY )
	end
	/*if ent.InBonusRound then
		surface.SetTextColor(color_redbonus)
		surface.SetTextPos(ent.BonusX, ent.BonusY)
		surface.SetFont("GTowerbig")
		surface.DrawText(bonustext)
	end*/
end
