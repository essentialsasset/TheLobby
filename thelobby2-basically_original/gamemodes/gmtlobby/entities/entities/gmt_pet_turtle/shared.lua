
-----------------------------------------------------
ENT.Type 			= "anim"

ENT.Base 			= "base_anim"

ENT.PrintName		= "Pet Flying Turtle"



ENT.Spawnable		= false

ENT.AdminSpawnable	= false



ENT.AutomaticFrameAdvance = true

ENT.Model			= "models/props/de_tides/vending_turtle.mdl"

function ENT:SetupDataTables()

	self:NetworkVar( "String", 0, "PetName" )

end
