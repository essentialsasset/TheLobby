---------------------------------
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

function ENT:Initialize()

	if !self.Owner then return end

	local owner = self.Owner

	self:SetModel("models/player/items/all_class/hwn_pet_ghost.mdl")
	self:SetMoveType(MOVETYPE_NONE)

	self:SetAngles(self:GetAngles() + Angle(90,0,0))
	self:DrawShadow(false)


	if IsValid( owner ) then
		local BoneIndx = owner:LookupBone("ValveBiped.Bip01_Head1")
		local BonePos, BoneAng = owner:GetBonePosition( BoneIndx )
		local pos = BonePos + Vector(0,0,-10)
		local ang = owner:GetAngles()
		self:SetPos(pos + owner:GetRight() * 35 + owner:GetForward() * 10 )
		self:SetAngles(Angle(180,ang.y - 90,ang.r))
	end

end
