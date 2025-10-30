module( "Scoreboard.Customization", package.seeall )

MatDirectory = "gmod_tower/scoreboard/"
EnableMouse = true
ShowBackgrounds = true

// COLORS
ColorFont = color_white
ColorFontShadow = Color( 6, 76, 127, 255 )

ColorNormal = Color( 55, 55, 111, 255 )
ColorBright = Color( 125, 125, 175, 255 )
ColorDark = Color( 25, 25, 61, 255 )

ColorBackground = colorutil.Brighten( ColorNormal, 0.75 )

ColorTabActive = colorutil.Brighten( ColorDark, .75, 200 )
ColorTabDivider = ColorBright
ColorTabInnerActive = ColorTabActive
ColorTabHighlight = colorutil.Brighten( ColorBright, 3 )

ColorAwardsDescription = Color( 162, 203, 233, 255 )
ColorAwardsBarAchieved = Color( 125, 125, 175, 150 )
ColorAwardsBarNotAchieved = Color( 55, 55, 111, 255 )
ColorAwardsAchievedIcon = Color( 225, 225, 225, 150 )

// HEADER
HeaderTitle = "GMT: The Lobby"
HeaderTitleFont = "SCTitle"
HeaderTitleColor = color_white
HeaderTitleLeft = 188
HeaderWidth = 256
HeaderHeight = 64
HeaderMatHeader = Scoreboard.GenTexture( "ScoreboardLogo", "main_header_deluxe" )
HeaderMatFiller = Scoreboard.GenTexture( "ScoreboardFiller", "main_filler_deluxe" )
HeaderMatRightBorder = Scoreboard.GenTexture( "ScoreboardRightBorder", "main_rightborder_deluxe" )


// COLLAPSABLES
CollapsablesFont = "GTowerHUDMain"


// PLAYER

PlayersSort = function( a, b )
	return string.lower( a:Name() ) < string.lower( b:Name() )
end

// Subtitle (under name)
PlayerSubtitleText = function( ply )
	return ""
end

// Subtitle right (under name)
PlayerSubtitleRightText = function( ply )
	if !ply:GetNWBool("FullyConnected") then
		return "LOADING"
	end
	return ""
end

// Background
PlayerBackgroundMaterial = function( ply )

	return nil

end

// Notification (above avatar)
PlayerNotificationIcon = function( ply )

	return nil

end
PlayerNotificationIconSize = 24

// Jazz the player avatar? (for winner only)
PlayerAvatarJazz = function( ply )

	return false

end

// Info Value
PlayerInfoValueVisible = function( ply )
	return false --LocalPlayer() == ply
end

PlayerInfoValueIcon = MatDirectory .. "icon_money.png"
PlayerInfoValueGet = function( ply )
	return nil --string.FormatNumber( Money() or 0 )
end

// Action Box
PlayerActionBoxEnabled = true
PlayerActionBoxAlwaysShow = false


// FONTS
surface.CreateFont( "SCTitle", { font = "TodaySHOP-BoldItalic", size = 42, weight = 400 } )
surface.CreateFont( "SCTNavigation", { font = "Oswald", size = 24, weight = 400 } )

surface.CreateFont( "SCPlyName", { font = "Oswald", size = 32, weight = 400 } )
surface.CreateFont( "SCPlyGroupName", { font = "Oswald", size = 20, weight = 400 } )
surface.CreateFont( "SCPlyGroupLocName", { font = "Oswald", size = 16, weight = 400 } )
surface.CreateFont( "SCPlyLoc", { font = "Tahoma", size = 16, weight = 400 } )
surface.CreateFont( "SCPlyValue", { font = "Tahoma", size = 16, weight = 400 } )
surface.CreateFont( "SCPlyLabel", { font = "Tahoma", size = 14, weight = 300 } )

surface.CreateFont( "SCPlyScoreTitle", { font = "Oswald", size = 16, weight = 00 } )
surface.CreateFont( "SCPlyScore", { font = "Oswald", size = 34, weight = 400 } )

surface.CreateFont( "SCMapName", { font = "TodaySHOP-Bold", size = 24, weight = 500 } )

surface.CreateFont( "SCAwardCategory", { font = "Oswald", size = 18, weight = 400 } )
surface.CreateFont( "SCAwardTitle", { font = "Oswald", size = 26, weight = 400 } )
surface.CreateFont( "SCAwardDescription", { font = "Arial", size = 14, weight = 400 } )
surface.CreateFont( "SCAwardProgress", { font = "Akfar", size = 12, weight = 400 } )
surface.CreateFont( "SCAwardGMC", { font = "Oswald", size = 16, weight = 400 } )
surface.CreateFont( "SCAwardGMCSmall", { font = "Oswald", size = 12, weight = 400 } )

surface.CreateFont( "SCPayoutTitle", { font = "Oswald", size = 26, weight = 400 } )
surface.CreateFont( "SCPayoutDescription", { font = "Arial", size = 14, weight = 400 } )
surface.CreateFont( "SCPayoutGMC", { font = "Oswald", size = 18, weight = 400 } )
surface.CreateFont( "SCPayoutGMCSmall", { font = "Oswald", size = 14, weight = 400 } )

/*surface.CreateFont( "SCAwardDescription", { font = "Oswald Light", size = 28, weight = 400 } )
surface.CreateFont( "SCAwardProgress", { font = "Oswald Light", size = 24, weight = 400 } )*/