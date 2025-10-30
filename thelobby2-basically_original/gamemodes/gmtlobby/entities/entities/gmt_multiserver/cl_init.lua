---------------------------------
include("shared.lua")
include("cl_network.lua")
include("cl_playerlist.lua")
include("cl_map.lua")
include("cl_list.lua")
include("cl_mainobj.lua")

surface.CreateFont( "MultiTitleDeluxe", {
	font = "Open Sans",
	extended = false,
	size = 180,
	weight = 800,
	antialias = true,
} )

surface.CreateFont( "MultiSubDeluxe", {
	font = "Open Sans",
	extended = false,
	size = 72,
	weight = 800,
	antialias = true,
} )

surface.CreateFont( "MultiMapDeluxe", {
	font = "Open Sans",
	extended = false,
	size = 120,
	weight = 800,
	antialias = true,
	shadow = true
} )

surface.CreateFont( "MultiQueueTitleDeluxe", {
	font = "Open Sans",
	extended = false,
	size = 64,
	weight = 800,
	antialias = true,
} )

surface.CreateFont( "MultiQueuePlayerDeluxe", {
	font = "Open Sans",
	extended = false,
	size = 52,
	weight = 600,
	antialias = true,
} )

surface.CreateFont( "MultiQueuePlayerBDeluxe", {
	font = "Open Sans",
	extended = false,
	size = 52,
	weight = 800,
	antialias = true,
} )

ENT.RenderGroup = RENDERGROUP_BOTH

ENT.ThemeColor = Color(150, 150, 150)
ENT.OfflineColor = Color(33, 33, 33)

ENT.BackgroundURL = "https://i.imgur.com/vhEnT1G.png"
ENT.MapGradientURL = "https://i.imgur.com/IYnb9xO.png"

function ENT:Initialize()

	self.ImageZoom = 0.0825
	self:ReloadOBBBounds()

	self.Entities = {}
	self.PlayerData = {}
	//self.ServerId = 0

	self.ServerPlayers = {}
	self.ServerMaxPlayers = 0
	self.ServerMap = "Loading..."
	self.ServerName = "Loading..."
	self.ServerGamemode = ""
	self.ServerStatus = ""

	self.WaitingList = {}
	self.TotalMaxPlayers = 1

	local min, max = self:GetRenderBounds()
	self:SetRenderBounds( min * 1.0, max * 1.0 )


	//self:SharedInit()
	self.NextUpdate = 1.0
	self:DrawShadow( false )

	self.DefaultTextHeight = draw.GetFontHeight("Default")
	self:ReloadPositions()
end

function ENT:Id()
	return tonumber( self:GetSkin() )
end

function ENT:GetServer()
	local Id = self:Id()

	if GTowerServers.Servers[ Id ] then
		return GTowerServers:Get( Id )
	end
end

function ENT:UpdateBoundries()
	self.TotalMinX   = -self.NegativeX   / self.ImageZoom
	self.TotalMinY   = -self.NegativeY   / self.ImageZoom
	self.TotalWidth  =  self.TableWidth  / self.ImageZoom
	self.TotalHeight =  self.TableHeight / self.ImageZoom

	//The size of the player board width
	self.PlayerWidth = self.TotalWidth * 0.5

	//Top height of the main object
	self.TopHeight = self.TotalHeight * 0.3

	//Start Y Posistion for the player boards
	self.PlayerStartY = self.TotalMinY + self.TopHeight + 20
end

function ENT:ReloadPositions()
	self:UpdateBoundries()
	self:ProcessMain()
	self:ProcessMapPos()
	self:UpdatePlayerList()
end

function ENT:Draw()
	return
end

function ENT:DrawTranslucent()

	if CurTime() > self.NextUpdate then
		self:UpdateData()
	end

	local EntPos = self:GetPos()
	local Eye = self:EyeAngles()

	local ang = self:GetAngles()
	ang:RotateAroundAxis(ang:Up(), 90)
	ang:RotateAroundAxis(ang:Forward(), 90)

	local pos = EntPos + Eye:Up() * self.UpPos + Eye:Forward() * self.FowardsPos + Eye:Right()

	cam.Start3D2D( pos, ang, self.ImageZoom )

		surface.SetDrawColor(255,255,255,255)

		CasinoKit.getRemoteMaterial(self.BackgroundURL, function(mat)
			self.BackgroundMat = mat
		end, true)

		if self.BackgroundMat then
			surface.SetMaterial(self.BackgroundMat)
			surface.SetDrawColor(self.ThemeColor)

			surface.DrawTexturedRect(
				self.TotalMinX,
				self.TotalMinY - 256,
				2048,
				2048
			)
		end


		if self.ServerOnline then
			self:DrawPlayers()
			self:DrawMap()
		else
			self.ThemeColor = self.OfflineColor
		end

		self:DrawMain()

	cam.End3D2D()

end

function ENT:DrawMainGuiOffline()
	surface.SetTextColor( 255, 50, 50, 255 )
	surface.SetFont("MultiTitleDeluxe")

	local w,h = surface.GetTextSize( "Gamemode Offline" )

	surface.SetTextPos(
		self.TotalMinX + self.TotalWidth / 2 - w / 2,
		self.TotalMinY + self.TotalHeight * 0.15 - h / 2
	)

	surface.DrawText( "Gamemode Offline" )
end

ENT.DrawMainGui = ENT.DrawMainGuiOffline
