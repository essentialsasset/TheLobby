---------------------------------
GMode.Name = "Zombie Massacre"
GMode.Gamemode = "zombiemassacre"
GMode.ThemeColor = Color(111, 14, 8)

//Set true if players should be kicked if their "goserver" value on the database is not the same as the local server
GMode.Private = true

//Set true if this is only played by VIPs
GMode.VIP = false

//This is amount of time between the players being server to play
//And the players be able to join the game
GMode.WaitingTime = 20.0

//This setting is for large group join
//When you want all people to connect at once, the server must be empty to people be able to join.
//Set this to false if you want people to be able to go in and out of the server at any time.
//Set also the min amount of players to join the sevrer
GMode.OneTimeJoin = true
GMode.MinPlayers = 1
//Set this if only a group can join
GMode.GroupJoin = false

GMode.MaxPlayers = 6 //Leave nil if the maxplayers are suppost to be the server maxplayers
GMode.Gameplay = "3rd Person"

GMode.Maps = Maps.GetMapsInGamemode( GMode.Gamemode )
GMode.View = {
	pos = Vector( 1953, -4299, -822 ),
	ang = Angle( -9, 144, 0 )
}
function GMode:GetMapTexture( map )

	map = string.sub(map,0,#map-2)
	return "gmod_tower/maps/" .. map

end

GMode.Music = {
	"GModTower/zom/music/music_waiting1.mp3",
	"GModTower/zom/music/music_waiting2.mp3",
	"GModTower/zom/music/music_waiting3.mp3",
}

GMode.Tips = {
	"Stay away from Mutants at all costs.",
	"Press shift to use your special combo power.",
	"Get a combo of 5 zombie kills to activate your combo power",
	"Right click to use your equipment.",
	"Crimsons will light you on fire. Try not to get burned.",
	"Zombie dogs will mess you up.",
	"The film Ghostbusters was released in 1984.",
	"Stick together and fend off the zombies for more rewards.",
	"You can equip up to two weapons at one time.",
	"Use your backpack button and store your weapon of choice."
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

	if data == "#boss" then
		ent.TimeLeftMarkup = markup.Parse( "<font=MultiSubDeluxe><color=white>BOSS BATTLE</color><font>" )
		ent.TimeLeftMarkup.PosX = ent.TotalMinX + ent.TotalWidth * 0.5 - ent.TimeLeftMarkup:GetWidth() / 2
		ent.TimeLeftMarkup.PosY = ent.TotalMinY + ent.TopHeight * 0.75 - ent.TimeLeftMarkup:GetHeight() / 2
		return
	end

	if data == "#before" then
		ent.TimeLeftMarkup = markup.Parse( "<font=MultiSubDeluxe><color=white>Upgrading...</color><font>" )
		ent.TimeLeftMarkup.PosX = ent.TotalMinX + ent.TotalWidth * 0.5 - ent.TimeLeftMarkup:GetWidth() / 2
		ent.TimeLeftMarkup.PosY = ent.TotalMinY + ent.TopHeight * 0.75 - ent.TimeLeftMarkup:GetHeight() / 2
		return
	end

	ent.NoGameMarkup = nil
	ent.TimeLeftMarkup = nil

	local leftTitle = "TIME LEFT"
	local rightTitle = "DAY"

	// Game running, now parse
	local Exploded = string.Explode( "||||", data )

	// Time
	local Timeleft = tonumber( Exploded[1] )
	local leftString = string.NiceTimeShort( Timeleft, true )

	// Rounds
	local roundExploded = string.Explode( "/", Exploded[2] )
	local CurRound = roundExploded[1]
	local MaxRounds = roundExploded[2]

	local rightString = string.format( "%d <color=white>/</color> %d", CurRound, MaxRounds )

	// Parse and set position
	ent.LeftTitle = markup.Parse( "<font=MultiSubDeluxe><color=white>" .. leftTitle .. "</color></font>" )
	ent.LeftMarkup = markup.Parse( "<font=MultiSubDeluxe>" .. leftString .. "</font>" )

	ent.LeftTitle.PosX = ent.TotalMinX + ent.TotalWidth * 0.20 - ent.LeftTitle:GetWidth() / 2
	ent.LeftTitle.PosY = ent.TotalMinY + ent.TopHeight * 0.60 - ent.LeftTitle:GetHeight() / 2

	ent.LeftMarkup.PosX = ent.TotalMinX + ent.TotalWidth * 0.20 - ent.LeftMarkup:GetWidth() / 2
	ent.LeftMarkup.PosY = ent.TotalMinY + ent.TopHeight * 0.85 - ent.LeftMarkup:GetHeight() / 2

	ent.RightTitle = markup.Parse( "<font=MultiSubDeluxe><color=white>" .. rightTitle .. "</color></font>" )
	ent.RightMarkup = markup.Parse( "<font=MultiSubDeluxe>" .. rightString .. "</font>" )

	ent.RightTitle.PosX = ent.TotalMinX + ent.TotalWidth * 0.85 - ent.RightTitle:GetWidth() / 2
	ent.RightTitle.PosY = ent.TotalMinY + ent.TopHeight * 0.60 - ent.RightTitle:GetHeight() / 2

	ent.RightMarkup.PosX = ent.TotalMinX + ent.TotalWidth * 0.85 - ent.RightMarkup:GetWidth() / 2
	ent.RightMarkup.PosY = ent.TotalMinY + ent.TopHeight * 0.85 - ent.RightMarkup:GetHeight() / 2

end

GMode.DrawData = function( ent )

	if ent.NoData then return end

	if ent.NoGameMarkup then
		ent.NoGameMarkup:Draw( ent.NoGameMarkup.PosX, ent.NoGameMarkup.PosY )
		return
	end

	if ent.RightMarkup then
		ent.RightTitle:Draw( ent.RightTitle.PosX, ent.RightTitle.PosY )
		ent.RightMarkup:Draw( ent.RightMarkup.PosX, ent.RightMarkup.PosY )
	end

	if ent.TimeLeftMarkup then
		ent.TimeLeftMarkup:Draw( ent.TimeLeftMarkup.PosX, ent.TimeLeftMarkup.PosY )
		return
	end

	if ent.LeftMarkup then
		ent.LeftTitle:Draw( ent.LeftTitle.PosX, ent.LeftTitle.PosY )
		ent.LeftMarkup:Draw( ent.LeftMarkup.PosX, ent.LeftMarkup.PosY )
	end

end
