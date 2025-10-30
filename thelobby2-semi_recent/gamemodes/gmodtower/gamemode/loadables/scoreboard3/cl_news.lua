---------------------------------

-----------------------------------------------------
module( "Scoreboard.News", package.seeall )



// TAB



hook.Add( "ScoreBoardItems", "NewsTab", function()

	return vgui.Create( "NewsTab" )

end )



TAB = {}

TAB.Order = 5

TAB.HideForGamemode = true



function TAB:GetText()

	return "NEWS"

end



function TAB:CreateBody()

	return vgui.Create( "ScoreboardNews", self )

end



vgui.Register( "NewsTab", TAB, "ScoreboardTab" )



// NEWS





NEWS = {}



function NEWS:Init()



	self.Tabs = {}

	self.ActiveTab = nil



	local website = "http://gmtthelobby.com/"



	self:AddURLTab( 1, "Latest News", website .. "?p=home" )

	--self:AddURLTab( 2, "Changelog", website .. "?p=changelog" )

	self:AddURLTab( 2, "Stats", website .. "?p=stats" )

	self:AddURLTab( 3, "GMT Staff", website .. "?p=staff" )
	
	self:AddURLTab( 4, "Downloads", website .. "?p=downloads" )



	if #self.Tabs > 0 then

		self:SetActiveTab( self.Tabs[1] )

	end



end





function NEWS:AddURLTab( id, name, url )



	local tab = vgui.Create( "ScoreboardTabInner", self )

	local html = vgui.Create( "HTML", tab )

	html:SetPos( 4, 25 )

	html:SetSize( self:GetWide(), ScrH() * 0.5 )



	tab.URL = url



	tab:SetBody( html )

	tab:SetText( name )

	tab:SetOrder( id )



	self:AddTab( tab )



end



function NEWS:AddTab( tab )



	table.insert( self.Tabs, tab )

	tab:SetParent( self )



end



function NEWS:SetActiveTab( tab )



	if IsValid( self.ActiveTab ) then



		self.ActiveTab:SetActive( false )

		local oldBody = self.ActiveTab:GetBody()



		oldBody:SetParent( nil )

		oldBody:SetVisible( false )



	end



	local newBody = tab:GetBody()



	self.ActiveTab = tab

	self.ActiveTab:SetActive( true )

	self.ActiveTab:GetBody():OpenURL( tab.URL )



	newBody:SetParent( self )

	newBody:SetVisible( true )



	self:SetTall( 24 + ( ScrH() * 0.5 ) - 4 )

	//self:Center()



	self:InvalidateLayout()



end



function NEWS:PerformLayout()



	local position = 0



	// Sort their order

	table.sort( self.Tabs, function( a, b )

		if a.Order == b.Order then

			return a:GetText() > b:GetText()

		end



		return a.Order < b.Order

	end )



	// Set their positions and size

	for _, tab in pairs( self.Tabs ) do

		tab:SetTall( 24 )

		tab:InvalidateLayout( true )



		tab:SetPos( position, 0 )



		position = position + tab:GetWide()

	end



	// Layout active tab

	if IsValid( self.ActiveTab ) then

		local body = self.ActiveTab:GetBody()

		body:InvalidateLayout( true )

		body:SetPos( 0, 26 )

		body:SetWide( self:GetWide() - 4 )

		//body:CenterHorizontal()

	end



end



function NEWS:Paint( w, h )



	surface.SetDrawColor( Scoreboard.Customization.ColorDark )

	surface.DrawRect( 0, 0, self:GetWide(), 24 )



end



function NEWS:Think()



end



vgui.Register( "ScoreboardNews", NEWS )
