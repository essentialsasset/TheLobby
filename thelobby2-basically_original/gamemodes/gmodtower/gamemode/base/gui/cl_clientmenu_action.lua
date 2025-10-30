module( "GTowerClick", package.seeall )

MaxDis = 2048

local function CanMouseEnt()
	return hook.Call("CanMousePress", GAMEMODE ) != false
end

hook.Add( "GUIMousePressed", "GTowerMousePressed", function( mc )

	if !CanMouseEnt() then return end

	GTowerMenu:CloseAll()

	local trace = LocalPlayer():GetEyeTrace()

	// More precise handling of mouse vector + third person support
	if IsLobby then

		local cursorvec = GetMouseVector()
		local origin = LocalPlayer().CameraPos
		trace = util.TraceLine( {
			start = origin, 
			endpos = origin + cursorvec * 9000,
			filter = { LocalPlayer() }
		} )

	end

	// World click pulls up menu
	if LocalPlayer():IsAdmin() && trace.HitWorld && mc != MOUSE_LEFT then
		GTowerClick:ClickOnPlayer( LocalPlayer(), mc )
		return
	end

	if !IsValid( trace.Entity ) then return end

	// Click on players
	if trace.Entity:IsPlayer() then
		GTowerClick:ClickOnPlayer( trace.Entity, mc )

	// Click on players in a ball
	elseif trace.Entity:GetClass() == "gmt_wearable_ballrace" then
		GTowerClick:ClickOnPlayer( trace.Entity:GetOwner(), mc )

	// Inventory items
	else
		hook.Call("GTowerMouseEnt", GAMEMODE, trace.Entity, mc )
	end

end )

hook.Add( "KeyPress", "GTowerMousePressedEmpty", function( ply, key )

	if !IsFirstTimePredicted() || key != IN_ATTACK || !CanMouseEnt() || IsValid(LocalPlayer():GetActiveWeapon()) then return end

	local trace = LocalPlayer():GetEyeTrace()

	if IsLobby then
		local cursorvec = GetMouseVector()
		local origin = LocalPlayer().CameraPos
		trace = util.TraceLine( { 
			start = origin, 
			endpos = origin + cursorvec * 9000,
			filter = { LocalPlayer() }
		} )
	end

	if !IsValid(trace.Entity) || trace.Entity:IsPlayer() then return end

	hook.Call("GTowerMouseEnt", GAMEMODE, trace.Entity, mc )

end )

function ClickOnPlayer( self, ply, mc )

	if !IsValid( ply ) then return end
	
	local tabl = {
		{
			["type"] = "text",
			["Name"] = ply:GetName(),
			["order"] = -10,
			["closebutton"] = true
		},
	}
	
	/*if CurTime() < ( ply.LastPlyClick or 0 ) then
		hook.Call("PlyDoubleClick", GAMEMODE, ply )
		return
	end
	ply.LastPlyClick = CurTime() + 0.4*/	
	
	if ply == LocalPlayer() then

		local AdminTable = GTowerAdmin:AddEnts()
		
		if AdminTable then
			for _, v in pairs( AdminTable ) do
				table.insert( tabl, v )
			end
		end
		
	else
	
		local HookTbl = hook.GetTable().ExtraMenuPlayer
		
		if HookTbl != nil then
		
			for _, v in pairs( HookTbl ) do
				local temp = v( ply )
				
				if temp != nil then
					table.insert( tabl, temp )
				end   
			end
		
		end
		
	end
	
	if #tabl == 1 then return end
	
	GTowerMenu:OpenMenu( tabl )

end