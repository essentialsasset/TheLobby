AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

ENT.ActiveTime = 22

function ENT:PowerUpOn( ply )
	ply.Shaft = true
	ply:SetColor( Color(255, 0, 255, 255) )
	ply:SetWalkSpeed( 250 )
	ply:SetRunSpeed( 150 )
	PostEvent( ply, "pushaft_on" )

	local pimpHat = GTowerHats:GetHatByName( "hatpimphat" )
	if !pimpHat then return end
	local hatData = GTowerHats.Hats[pimpHat]
	if !hatData then return end

	ply:ReplaceHat( hatData.unique_Name, hatData.model, pimpHat, hatData.slot )
end

function ENT:PowerUpOff( ply )
	ply.Shaft = nil
	ply:SetColor( Color(255, 255, 255, 255) )
	ply:SetWalkSpeed( 450 )
	ply:SetRunSpeed( 450 )
	PostEvent( ply, "pushaft_off" )

	ply:ReturnHat()
end

/*function ShaftProtect( ply, inflictor, attacker, amount, dmginfo )
	if !ply.PowerUp then return end

	if ply:Health() > amount then
		amount = 0
		return true
	else
		return false
	end
end*/

hook.Add( "EntityTakeDamage", "ShaftProtect", function( ply, dmginfo )
	if ply:GetNet("PowerUp") == 0 then return end
	if !ply.Shaft then return end

	return true
end )
