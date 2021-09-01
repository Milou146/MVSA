
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
    PlayerModel:SetX(0)
    PlayerModel:CenterVertical(0.05)
    PlayerModel:SetSize( InventoryPanel:GetWide() * 0.5, ScrH() / 2 )
    PlayerModel:SetMouseInputEnabled( false )

    local headpos = PlayerModel.Entity:GetBonePosition(PlayerModel.Entity:LookupBone("ValveBiped.Bip01_Head1"))
    PlayerModel.Entity:SetEyeTarget(headpos-Vector(-15, 0, 0))
    for k = 0,#ply:GetBodyGroups() - 1 do
        PlayerModel.Entity:SetBodygroup(k, ply:GetBodygroup(k))
    end
    PlayerModel:SetCamPos(Vector(40, 0, 45))
    PlayerModel:SetLookAt(headpos + Vector(-90,20,-40))
    ply.InventoryOpen = true

    local NVGSlot = vgui.Create( "DImage", InventoryPanel )
    NVGSlot:CenterHorizontal(0.85)
    NVGSlot:CenterVertical(0.025)
    NVGSlot:SetImage( "icon64/inventory_slot.png")
    NVGSlot:SetSize( ScrW() / 20, ScrW() / 20 )

    local NVG = vgui.Create( "DImage", NVGSlot )
    NVG:CenterHorizontal(0.5)
    NVG:CenterVertical(0.15)
    NVG:SetImage( MVSA.EntList[ply:GetNWInt("NVG")][2] )
    NVG:SetSize( ScrW() / 20, ScrW() / 20 )

    local HelmetSlot = vgui.Create( "DImage", InventoryPanel )
    HelmetSlot:CenterHorizontal(0.65)
    HelmetSlot:CenterVertical(0.025)
    HelmetSlot:SetImage( "icon64/inventory_slot.png")
    HelmetSlot:SetSize( ScrW() / 20, ScrW() / 20 )

    local Helmet = vgui.Create( "DImage", HelmetSlot )
    Helmet:CenterHorizontal(0.5)
    Helmet:CenterVertical(0.15)
    Helmet:SetImage( MVSA.EntList[ply:GetNWInt("Helmet")][2] )
    Helmet:SetSize( ScrW() / 20, ScrW() / 20 )

    local GasMaskSlot = vgui.Create( "DImage", InventoryPanel )
    GasMaskSlot:CenterHorizontal(0.85)
    GasMaskSlot:CenterVertical(0.125)
    GasMaskSlot:SetImage( "icon64/inventory_slot.png")
    GasMaskSlot:SetSize( ScrW() / 20, ScrW() / 20 )

    GasMask = vgui.Create( "DImage", GasMaskSlot )
    GasMask:CenterHorizontal(0.5)
    GasMask:CenterVertical(0.15)
    GasMask:SetImage( "icon64/gasmask.png" )
    GasMask:SetSize( ScrW() / 20, ScrW() / 20 )
    GasMask:SetVisible( ply:GetNWBool( "GasMaskSet" ) )

    local BagSlot = vgui.Create( "DImage", InventoryPanel )
    BagSlot:CenterHorizontal(0.85)
    BagSlot:CenterVertical(0.225)
    BagSlot:SetImage( "icon64/inventory_slot.png")
    BagSlot:SetSize( ScrW() / 20, ScrW() / 20 )

    local Bag = vgui.Create( "DImage", BagSlot )
    Bag:CenterHorizontal(0.5)
    Bag:CenterVertical(0.15)
    Bag:SetImage( MVSA.EntList[ply:GetNWInt("RuckSack")][2] )
    Bag:SetSize( ScrW() / 20, ScrW() / 20 )

    local VestSlot = vgui.Create( "DImage", InventoryPanel )
    VestSlot:CenterHorizontal(0.65)
    VestSlot:CenterVertical(0.225)
    VestSlot:SetImage( "icon64/inventory_slot.png")
    VestSlot:SetSize( ScrW() / 20, ScrW() / 20 )

    local Vest = vgui.Create( "DImage", VestSlot )
    Vest:CenterHorizontal(0.5)
    Vest:CenterVertical(0.15)
    Vest:SetImage( MVSA.EntList[ply:GetNWInt("Vest")][2] )
    Vest:SetSize( ScrW() / 20, ScrW() / 20 )

    local JacketSlot = vgui.Create( "DImage", InventoryPanel )
    JacketSlot:CenterHorizontal(0.45)
    JacketSlot:CenterVertical(0.225)
    JacketSlot:SetImage( "icon64/inventory_slot.png")
    JacketSlot:SetSize( ScrW() / 20, ScrW() / 20 )

    local Jacket = vgui.Create( "DImage", JacketSlot )
    Jacket:CenterHorizontal(0.5)
    Jacket:CenterVertical(0.15)
    Jacket:SetImage( MVSA.EntList[ply:GetNWInt("Jacket")][2] )
    Jacket:SetSize( ScrW() / 20, ScrW() / 20 )

    local PantSlot = vgui.Create( "DImage", InventoryPanel )
    PantSlot:CenterHorizontal(0.85)
    PantSlot:CenterVertical(0.325)
    PantSlot:SetImage( "icon64/inventory_slot.png")
    PantSlot:SetSize( ScrW() / 20, ScrW() / 20 )

    local Pant = vgui.Create( "DImage", PantSlot )
    Pant:CenterHorizontal(0.5)
    Pant:CenterVertical(0.15)
    Pant:SetImage( MVSA.EntList[ply:GetNWInt("Pant")][2] )
    Pant:SetSize( ScrW() / 20, ScrW() / 20 )
end

function GM:ScoreboardShow()
    ply = LocalPlayer()
    if player_manager.GetPlayerClass(ply) ~= "player_spectator" then
        if InventoryPanel == nil then
            CreateInventoryPanel()
        elseif not ply.InventoryOpen or ply.InventoryOpen == nil then
            CreateInventoryPanel()
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