hook.Add("ClientExtraModels", "InventoryCheck", function( func, clickfunc, category )

	local function TestForItem( ItemObj )
		if ItemObj.Item && ItemObj.Item:IsValid() && ItemObj.Item.ModelItem == true then			
			func( ItemObj.Item.ModelName .. "-" .. ItemObj.Item.ModelSkinId, ItemObj.Item.Model, ItemObj.Item.ModelSkinId, clickfunc, category, 0, 0, ItemObj.Item.Description, ItemObj.Item.Name )
			//func( ItemObj.Item.ModelName .. "-" .. ItemObj.Item.ModelSkinId, ItemObj.Item.Model, ItemObj.Item.ModelSkinId )
		end
	end
	
	for _, tbl in pairs( GTowerItems.ClientItems ) do
		
		for _, v in pairs( tbl ) do
			TestForItem( v )
		end
		
	end
	
end )

hook.Add("InventoryChanged", "RecreatePlayerList", function( ItemObj )

	if ItemObj.Item && ItemObj.Item.ModelItem == true then

		if GtowerScoreBoard && IsValid( GtowerScoreBoard.SettingPanel ) then
			GtowerScoreBoard.SettingPanel:GenerateModelSelection()
		end

	end

end )