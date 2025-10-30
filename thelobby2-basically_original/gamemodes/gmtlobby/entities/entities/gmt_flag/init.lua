AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel(self.Model)
    self:SetSolid(SOLID_VPHYSICS)

    self:DrawShadow(false)

    local e = ents.Create("prop_dynamic")
    e:SetPos(self:GetPos())
    e:SetAngles(self:GetAngles())
    e:SetModel(self.Model)
    e:Spawn()
    e:ResetSequence("idle")

    if IsHalloweenMap() then
      e:SetMaterial( "models/map_detail/flagsidedeluxe_h", true )
    end

    self:Remove()

end
