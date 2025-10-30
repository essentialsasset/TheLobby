GTowerModerators = {
	"STEAM_0:1:109275666",	-- Lego
	"STEAM_0:1:90972003",	-- Dragon4k
}

hook.Add("PlayerInitialSpawn", "GTowerCheckMod", function(ply)

	if table.HasValue( GTowerModerators, ply:SteamID() )then
        ply:SetUserGroup( "moderator" )
    end

end )