---------------------------------
include('shared.lua')
include('cl_gui.lua')
include('cl_guiitem.lua')
include('cl_group.lua')

GTowerGroup.MainGui = nil
GTowerGroup.PlysGui = {}

GTowerGroup.AvatarSize = 40

GTowerGroup.LeaveBtn = nil


hook.Add("GtowerShowMenus", "ShowGroupShow", function()
	if not GTowerGroup:InGroup() then return end

	if not IsValid( GTowerGroup.LeaveBtn ) then
		GTowerGroup.LeaveBtn = vgui.Create("DButton")
	end

	GTowerGroup.LeaveBtn:SetText( T("Group_leave") )
	GTowerGroup.LeaveBtn:SetWide( 100 )

	GTowerGroup.LeaveBtn.DoClick = function()
		Derma_Query( T("Group_leavesure"), T("Group_leavesure"),
			T("yes"), function() RunConsoleCommand("gmt_leavegroup") surface.PlaySound("gmodtower/misc/leavegroup.wav") end,
			T("no"), nil
		)
	end

	GTowerGroup.LeaveBtn:SetVisible( true )

	GTowerGroup:RefreshGui()
end )

hook.Add("GtowerHideMenus", "ShowGroupLeave", function()
	if IsValid( GTowerGroup.LeaveBtn ) then
		GTowerGroup.LeaveBtn:Remove()
	end

	GTowerGroup.LeaveBtn = nil
	GTowerGroup:RefreshGui()
end )

hook.Add("PlayerActionBoxPanel","AddGroupItems", function( panel ) 

	local party = panel:CreateItem()
	party:SetMaterial( Scoreboard.PlayerList.MATERIALS.Group, 16, 16, 16, 16 )
	party:SetText( "Group" )
	party.OnMousePressed = function( self )
		GTowerGroup:RequestJoin( panel:GetPlayer() )
	end
	party.UpdateVisible = function( self, ply )
		return GTowerGroup.GroupOwner == nil or GTowerGroup.GroupOwner == LocalPlayer()
	end

	local owner = panel:CreateItem()
	owner:SetMaterial( Scoreboard.PlayerList.MATERIALS.MakeGroupOwner, 16, 16, 16, 16 )
	owner:SetText( T("Group_makeowner") )
	owner.OnMousePressed = function( self )
		local ply = panel:GetPlayer()
		Derma_Query( T("Group_newownermakesure", ply:GetName()), T("Group_newownermakesure", ply:GetName()), 
			T("yes"), function() RunConsoleCommand("gmt_groupmakeowner", ply:EntIndex() ) end,
			T("no"), nil
		)
	end
	owner.UpdateVisible = function( self, ply )
		return GTowerGroup.GroupOwner == LocalPlayer() and GTowerGroup:IsInGroup( ply )
	end

	local remove = panel:CreateItem()
	remove:SetMaterial( Scoreboard.PlayerList.MATERIALS.KickFromGroup, 16, 16, 16, 16 )
	remove:SetText( T("Group_removegroup") )
	remove.OnMousePressed = function( self )
		RunConsoleCommand("gmt_groupremove", panel:GetPlayer():EntIndex() )
	end
	remove.UpdateVisible = owner.UpdateVisible

end )

hook.Add("ExtraMenuPlayer", "GroupRequest", function(ply)

	//check if player is in group
	if GTowerGroup.GroupOwner == LocalPlayer() && GTowerGroup:IsInGroup( ply ) then
		return {
	        ["Name"] = T("Group_menu"),
	        ["order"] = 6,
	        ["icon"] = GTowerIcons:GetIcon( 'group' ),
			["sub"] = {
				[1] = {
	                    ["Name"] = T("Group_makeowner"),
	                    ["function"] = function()
							Derma_Query( T("Group_newownermakesure", ply:GetName()), T("Group_newownermakesure", ply:GetName()),
								T("yes"), function() RunConsoleCommand("gmt_groupmakeowner", ply:EntIndex() ) end,
								T("no"), nil
							)
						end
	            },
				[2] = {
	                    ["Name"] = T("Group_removegroup"),
	                    ["function"] = function() RunConsoleCommand("gmt_groupremove", ply:EntIndex() ) end
	            },
			}
		}

	elseif GTowerGroup.GroupOwner == nil || GTowerGroup.GroupOwner == LocalPlayer() then
		return {
            ["Name"] = T("Group_inviteroup"),
            ["order"] = 6,
            ["icon"] = GTowerIcons:GetIcon( 'group' ),
			["extra"] = ply,
			["function"] = function( ply ) GTowerGroup:RequestJoin( ply ) end,
        }
	end

	return nil

end )

--usermessage.Hook("GGroup", function(um)
net.Receive("GGroup",function()

	local MsgId = net.ReadInt(16)

	if MsgId == 0 then

		local NumMembers = net.ReadInt(16)
		GTowerGroup.GroupMembers = {}

		for i=1, NumMembers, 1 do

			local ply = ents.GetByIndex( net.ReadInt(16) )

			table.insert( GTowerGroup.GroupMembers, ply )

			if i == 1 then
				GTowerGroup.GroupOwner = ply
			end

		end

		GTowerGroup:RefreshGui()

	elseif MsgId == 1 then
		GTowerGroup:RecieveInvite( net.ReadInt(16), net.ReadInt(16) )

	elseif MsgId == 2 then


		GTowerMessages:AddNewItem( GetTranslation("Group_he_already_in_group", ply:GetName() ) )

	elseif MsgId == 3 then
		GTowerGroup:LeaveGroup()

	elseif MsgId == 4 then
		GTowerMessages:AddNewItem( GetTranslation("Group_already_in_group" ) )

	elseif MsgId == 5 then
		GTowerMessages:AddNewItem( "The group no longer exists." )

	elseif MsgId == 8 then
		local ply = ents.GetByIndex( net.ReadInt(16) )

		if not IsValid( ply ) or not ply:IsPlayer() then
			return
		end

		if ply == LocalPlayer() then
			GTowerMessages:AddNewItem( GetTranslation("Group_younewowner" ) )
		else
			GTowerMessages:AddNewItem( T("Group_himnewowner", ply:GetName() ) )
		end
	elseif MsgId == 9 then

		local ply = ents.GetByIndex( net.ReadInt(16) )

		if not IsValid( ply ) or not ply:IsPlayer() then
			return
		end

		GTowerMessages:AddNewItem( T("GroupDeny", ply:Name() ) )

	end

end )


function GTowerGroup:LeaveGroup( um )
	if IsValid( GTowerGroup.MainGui ) then
		GTowerGroup.MainGui:Remove()
		GTowerGroup.MainGui = nil
	end

	GTowerGroup.PlysGui = {}
	GTowerGroup.GroupOwner = nil
	GTowerGroup.GroupMembers = {}

	hook.Call("GTowerGroupChange", GAMEMODE )
end
