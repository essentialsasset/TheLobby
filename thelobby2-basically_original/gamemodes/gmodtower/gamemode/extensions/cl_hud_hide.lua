
GtowerHudToHide = { "CHUDQuickInfo", "CHudSuitPower", "CHudZoom", "CHudChat" }

if IsLobby then
	table.insert( GtowerHudToHide, "CHudCrosshair" )
end

//Somewhy when I hook two things to HUDShouldDraw, only 1 get's called
//Making this global D:

function GM:HUDShouldDraw( Name )
	return !table.HasValue( GtowerHudToHide, Name )
end

function GM:HUDDrawPickupHistory()
	return false
end