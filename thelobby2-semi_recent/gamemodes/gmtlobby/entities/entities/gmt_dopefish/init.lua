
include("shared.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

util.AddNetworkString("fishTalk")

function ENT:Initialize()
    self:SetModel(self.Model)
    self:SetSolid(SOLID_BBOX)
    self:SetUseType(SIMPLE_USE)
end

function ENT:Think()
   self:NextThink(CurTime())
end

function ENT:Use(ply)
  if CurTime() < (ply.NextFishTime or 0) then return end
  ply.NextFishTime = (CurTime() + 15)

  local hasAchi = ply:Achived( ACHIEVEMENTS.DOPEFISH )

  ply:Lock()

  timer.Simple(10,function()
    ply:UnLock()
  end)

  net.Start( "fishTalk" )
    net.WriteBool( hasAchi )
  net.Send( ply )

  if !hasAchi then
    timer.Simple(7.5, function()
      if IsValid( ply ) then
        ply:AddAchievement( ACHIEVEMENTS.DOPEFISH, 1 )
      end
    end)
  end
end
