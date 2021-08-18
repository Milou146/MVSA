
function CreateInventoryPanel()
    surface.CreateFont( "Font", { font = "Arial", extended = true, size = 20 } )
    local faded_black = Color( 0, 0, 0, 200 )		-- The color black but with 200 Alpha
    ply = LocalPlayer()
    -- Then font named "Font" compacted on one line.

    InventoryPanel = vgui.Create( "DFrame" )	-- The name DermaPanel to store the value DFrame.
    InventoryPanel:SetSize( ScrW() / 3, ScrH() ) 				-- Sets the size to 500x by 300y.
    InventoryPanel:SetPos( 0, 0 )						-- Centers the panel.
    InventoryPanel:SetTitle( "" )					-- Set the title to nothing.
    InventoryPanel:SetDraggable( false )			-- Makes it so you can't drag it.
    InventoryPanel.Paint = function( self, w, h )	-- Paint function w, h = how wide and tall it is.
        -- Draws a rounded box with the color faded_black stored above.
        draw.RoundedBox( 2, 0, 0, w, h, faded_black )
    end
    InventoryPanel:ShowCloseButton(false)
    InventoryPanel:MakePopup( true )
    InventoryPanel:SetKeyboardInputEnabled( false )

    PlayerModel = vgui.Create( "DModelPanel", InventoryPanel )
    PlayerModel:SetModel(ply:GetModel())
    PlayerModel:CenterHorizontal(0.15)
    PlayerModel:CenterVertical(0.05)
    PlayerModel:SetSize( InventoryPanel:GetWide() * 2 / 3, ScrH() / 2 )

    local headpos = PlayerModel.Entity:GetBonePosition(PlayerModel.Entity:LookupBone("ValveBiped.Bip01_Head1"))
    PlayerModel.Entity:SetEyeTarget(headpos-Vector(-15, 0, 0))
    for k = 0,#ply:GetBodyGroups() - 1 do
        PlayerModel.Entity:SetBodygroup(k, ply:GetBodygroup(k))
    end
    PlayerModel:SetCamPos(PlayerModel:GetCamPos() + Vector(-40, 0, 0))
    ply.InventoryOpen = true

    local CaskSlot = vgui.Create( "DImage", InventoryPanel )
    CaskSlot:CenterHorizontal(0.8)
    CaskSlot:CenterVertical(0.05)
    CaskSlot:SetImage( "icon64/mvsa_inventory_slot.png")
    CaskSlot:SetSize( ScrW() / 20, ScrW() / 20 )

    local Cask = vgui.Create( "DImage", CaskSlot )
    Cask:CenterHorizontal(0.5)
    Cask:CenterVertical(0.15)
    Cask:SetImage( "icon64/mvsa_gasmask.png")
    Cask:SetSize( ScrW() / 20, ScrW() / 20 )
    Cask:SetVisible( false )

    local GasMaskSlot = vgui.Create( "DImage", InventoryPanel )
    GasMaskSlot:CenterHorizontal(0.8)
    GasMaskSlot:CenterVertical(0.15)
    GasMaskSlot:SetImage( "icon64/mvsa_inventory_slot.png")
    GasMaskSlot:SetSize( ScrW() / 20, ScrW() / 20 )

    GasMask = vgui.Create( "DImage", GasMaskSlot )
    GasMask:CenterHorizontal(0.5)
    GasMask:CenterVertical(0.15)
    GasMask:SetImage( "icon64/mvsa_gasmask.png")
    GasMask:SetSize( ScrW() / 20, ScrW() / 20 )
    GasMask:SetVisible( ply:GetNWBool( "GasMaskSet" ) )
end
function GM:ScoreboardShow()
    ply = LocalPlayer()
    if player_manager.GetPlayerClass(ply) ~= "player_spectator" then
        if InventoryPanel == nil then
            CreateInventoryPanel()
        elseif not ply.InventoryOpen or ply.InventoryOpen == nil then
            InventoryPanel:SetVisible(true)
            ply.InventoryOpen = true
        elseif ply.InventoryOpen then
            InventoryPanel:SetVisible(false)
            ply.InventoryOpen = false
        end
    end
end

function UpdateClientMask( bool )
    GasMask:SetVisible( bool )
    for k = 0,#ply:GetBodyGroups() - 1 do
        PlayerModel.Entity:SetBodygroup(k, ply:GetBodygroup(k))
    end
end