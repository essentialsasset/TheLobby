---------------------------------
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

ENT.Duration = 1.2

ENT.RocketMultiplier = .07

ENT.Spins = false
ENT.SpinMultiplier = 10

ENT.ThinkEffect = nil
ENT.EndEffect = "firework_wine"

ENT.Shockwave = false

ENT.SoundLiftOff = Sound("GModTower/lobby/firework/firework_launch.wav")
ENT.SoundExplosion = Sound("GModTower/lobby/firework/firework_explode.wav")