
include('shared.lua')

module("GTowerModels", package.seeall)

ConVar = CreateClientConVar( "gmt_playermodel", "barney", true, true )

cvars.AddChangeCallback( "gmt_playermodel", function()
	LocalPlayer():ConCommand( "gmt_updateplayermodel" )
end, "GMTPlayermodelUpdate" )

function Get( ply )
	return ply._PlyModelSize
end

hook.Add("PlayerSpawn","GTowerChangePlyScale", function( ply )
	ChangeHull( ply )
end )

hook.Add("OnEntityCreated", "Test", function( spawned )
	
	if IsValid( spawned ) then
		local class = spawned:GetClass()
		
		if class == "class C_HL2MPRagdoll" then			
			for _, ply in pairs( player.GetAll() ) do
				local ent = ply:GetRagdollEntity()
		
				if IsValid( ent ) then
					ent:SetSkin( ply:GetSkin() )
				end
			end
		end
	end
	
end )

/*
usermessage.Hook("PlySize", function( um )

	local id = um:ReadBool()
	
	if id == true then
		local count = um:ReadChar()
		
		for i=1, count do 
			local PlyIndex = um:ReadChar()
			local ply = Entity( PlyIndex )
			local size = um:ReadFloat()
			
			if DEBUG then Msg("GTowerModels - Recieving " .. tostring(ply) .. " to " .. size .. "\n") end
			
			ply._ForcePlayerSize = size
			ChangeHull( ply )	
		end	
	
	else
		local PlyIndex = um:ReadChar()
		local ply = Entity(PlyIndex)
		
		ply._ForcePlayerSize = nil
		ChangeHull( ply )
	end

end ) 

hook.Add("AllowModel", "DisableAdminModels", function( ply, model )
	if AdminModels[model] && !ply:IsAdmin() then
		return false
	end
end ) 
*/

function AskTempOverrideSize( ply )
	Derma_StringRequest( "Temporary override - until death", 
		"Set the player size for: " .. ply:Name() .. " (0-"..MaxScale..")", 
		"", 
		function( out ) GTowerAdmin:PlayerCommand( "plytsize", ply, out ) end,
		nil,
		"Set", 
		"Cancel" 
	)
end

function AskPerNamentSize( ply )
	Derma_StringRequest( "PerNament player size", 
		"Set the player size for: " .. ply:Name() .. " (0-"..MaxScale..")", 
		"", 
		function( out ) GTowerAdmin:PlayerCommand( "plysize", ply, out ) end,
		nil,
		"Set", 
		"Cancel" 
	)
end

function RemoveSize( ply )
	GTowerAdmin:PlayerCommand( "remsize", ply, 1 )
end

local function AdminSetPlayerSize( ply )
	return {
		["Name"] = "Player size",
		["sub"] = {
			{
				["Name"] = "Temp. override",
				["function"] = function() AskTempOverrideSize( ply ) end	 
			},
			{
				["Name"] = "Change size",
				["function"] = function() AskPerNamentSize( ply ) end	 
			},
			{
				["Name"] = "Remove",
				["function"] = function() RemoveSize( ply ) end	 
			},
		}
	}
end

hook.Add("GTowerAdminPly", "ChangePlayersize", AdminSetPlayerSize )
hook.Add("GTowerAdminMenus", "ChangePlayersize", AdminSetPlayerSize )


cvars.AddChangeCallback("cl_playercolor", function(convar_name, value_old, value_new)
    RunConsoleCommand("gmt_updateplayercolor")
end)