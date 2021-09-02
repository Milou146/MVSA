
function CreateInventoryPanel()
    surface.CreateFont( "Font", { font = "Arial", extended = true, size = 20 } )
    local faded_black = Color( 0, 0, 0, 200 )		-- The color black but with 200 Alpha
    ply = LocalPlayer()
    -- Then font named "Font" compacted on one line.

    InventoryPanel = vgui.Create( "EditablePanel" )	-- The name DermaPanel to store the value DFrame.
    InventoryPanel:SetSize( ScrW() / 3, ScrH() ) 				-- Sets the size to 500x by 300y.
    InventoryPanel:SetPos( 0, 0 )						-- Centers the panel.
    InventoryPanel.Paint = function( self, w, h )	-- Paint function w, h = how wide and tall it is.
        -- Draws a rounded box with the color faded_black stored above.
        draw.RoundedBox( 2, 0, 0, w, h, faded_black )
    end
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

    local NVG = vgui.Create( "DImageButton", InventoryPanel )
    NVG:SetPos( NVGSlot:GetPos() )
    NVG:SetImage( MVSA.EntList[ply:GetNWInt("NVG")][2] )
    NVG:SetSize( ScrW() / 20, ScrW() / 20 )
    NVG.Ent = ents.CreateClientside( MVSA.EntList[ply:GetNWInt("NVG")][1] )
    NVG.DoRightClick = function()
        local ActionMenu = DermaMenu(false, InventoryPanel)
        ActionMenu:AddOption( "Drop", function()
            net.Start("DropRequest")
            net.WriteString( MVSA.EntList[ply:GetNWInt("NVG")][1] )
            net.WriteString( "NVG" )
            net.WriteBool(false) -- the specified entity is a weapon
            net.WriteBool(true) -- the specified entity is bodygrouped
            net.SendToServer()
            NVG:SetImage( "vgui/null.vmt" )
            PlayerModel.Entity:SetBodygroup(NVG.Ent.BodyGroup[ply:GetNWString("Faction")][ply:GetNWInt("ModelIndex")][3], NVG.Ent.BodyGroup[ply:GetNWString("Faction")][ply:GetNWInt("ModelIndex")][4])
            ActionMenu:Remove()
        end)
        ActionMenu:Open()
    end

    local HelmetSlot = vgui.Create( "DImage", InventoryPanel )
    HelmetSlot:CenterHorizontal(0.65)
    HelmetSlot:CenterVertical(0.025)
    HelmetSlot:SetImage( "icon64/inventory_slot.png")
    HelmetSlot:SetSize( ScrW() / 20, ScrW() / 20 )

    local Helmet = vgui.Create( "DImageButton", InventoryPanel )
    Helmet:SetPos( HelmetSlot:GetPos() )
    Helmet:SetImage( MVSA.EntList[ply:GetNWInt("Helmet")][2] )
    Helmet:SetSize( ScrW() / 20, ScrW() / 20 )
    Helmet.Ent = ents.CreateClientside( MVSA.EntList[ply:GetNWInt("Helmet")][1] )
    Helmet.DoRightClick = function()
        local ActionMenu = DermaMenu(false, InventoryPanel)
        ActionMenu:AddOption( "Drop", function()
            net.Start("DropRequest")
            net.WriteString( MVSA.EntList[ply:GetNWInt("Helmet")][1] )
            net.WriteString( "Helmet" )
            net.WriteBool(false) -- the specified entity is a weapon
            net.WriteBool(true) -- the specified entity is bodygrouped
            net.SendToServer()
            Helmet:SetImage( "vgui/null.vmt" )
            PlayerModel.Entity:SetBodygroup(Helmet.Ent.BodyGroup[ply:GetNWString("Faction")][ply:GetNWInt("ModelIndex")][3], Helmet.Ent.BodyGroup[ply:GetNWString("Faction")][ply:GetNWInt("ModelIndex")][4])
            ActionMenu:Remove()
        end)
        ActionMenu:Open()
    end

    local GasMaskSlot = vgui.Create( "DImage", InventoryPanel )
    GasMaskSlot:CenterHorizontal(0.85)
    GasMaskSlot:CenterVertical(0.125)
    GasMaskSlot:SetImage( "icon64/inventory_slot.png")
    GasMaskSlot:SetSize( ScrW() / 20, ScrW() / 20 )

    GasMask = vgui.Create( "DImage", InventoryPanel )
    GasMask:SetPos( GasMaskSlot:GetPos() )
    GasMask:SetImage( "icon64/gasmask.png" )
    GasMask:SetSize( ScrW() / 20, ScrW() / 20 )
    GasMask:SetVisible( ply:GetNWBool( "GasMaskSet" ) )

    local function ReloadSelectedContainer(StartingIndex)

        SelectedIcon = vgui.Create( "DImage", InventoryPanel )
        SelectedIcon:SetSize( ScrW() / 24, ScrW() / 24 )
        SelectedIcon:SetX(SelectedContainer:GetX() + SelectedContainer:GetWide() / 2 - SelectedIcon:GetWide() / 2 )
        SelectedIcon:SetY(SelectedContainer:GetY() + SelectedContainer:GetTall() / 2 - SelectedIcon:GetTall() / 2 )
        SelectedIcon:SetImage( "vgui/spawnmenu/hover.vmt" )

        InventorySlot = {}
        Inventory = {}
        if SelectedContainer.Ent.Capacity and SelectedContainer.Ent.Capacity > 0 then
            local i,j = 0,0
            for k = 0,SelectedContainer.Ent.Capacity - 1 do
                InventorySlot[k] = vgui.Create( "DImage", InventoryPanel )
                InventorySlot[k]:CenterHorizontal(0.09 + j * 0.2)
                InventorySlot[k]:CenterVertical(0.77 + i * 0.1)
                InventorySlot[k]:SetImage( "icon64/inventory_slot.png")
                InventorySlot[k]:SetSize( ScrW() / 20, ScrW() / 20 )
                Inventory[k] = vgui.Create( "DImage", InventoryPanel )
                Inventory[k]:SetPos(InventorySlot[k]:GetPos())
                Inventory[k]:SetImage(MVSA.EntList[ply:GetNWInt("Inventory" .. tostring(StartingIndex + k + 1))][2])
                Inventory[k]:SetSize( ScrW() / 20, ScrW() / 20 )
                j = j + 1
                if j == 5 then
                    i = i + 1
                    j = 0
                end
            end
        end
    end

    local RucksackSlot = vgui.Create( "DImage", InventoryPanel )
    RucksackSlot:CenterHorizontal(0.85)
    RucksackSlot:CenterVertical(0.225)
    RucksackSlot:SetImage( "icon64/inventory_slot.png")
    RucksackSlot:SetSize( ScrW() / 20, ScrW() / 20 )

    local Rucksack = vgui.Create( "DImageButton", InventoryPanel )
    Rucksack:SetPos(RucksackSlot:GetPos())
    Rucksack:SetImage( MVSA.EntList[ply:GetNWInt("Rucksack")][2] )
    Rucksack:SetSize( ScrW() / 20, ScrW() / 20 )
    Rucksack.Ent = ents.CreateClientside( MVSA.EntList[ply:GetNWInt("Rucksack")][1] )
    Rucksack.DoClick = function()
        if SelectedIcon then
            SelectedIcon:Remove()
            if SelectedContainer.Ent.Capacity and SelectedContainer.Ent.Capacity > 0 then
                for k = 0,SelectedContainer.Ent.Capacity - 1 do
                    InventorySlot[k]:Remove()
                    Inventory[k]:Remove()
                end
            end
        end
        SelectedContainer = Rucksack
        ReloadSelectedContainer(10)
    end
    Rucksack.DoRightClick = function()
        local ActionMenu = DermaMenu(false, InventoryPanel)
        ActionMenu:AddOption( "Drop", function()
            net.Start("DropRequest")
            net.WriteString( MVSA.EntList[ply:GetNWInt("Rucksack")][1] )
            net.WriteString( "Rucksack" )
            net.WriteBool(false) -- the specified entity is a weapon
            net.WriteBool(true) -- the specified entity is bodygrouped
            net.SendToServer()
            Rucksack:SetImage( "vgui/null.vmt" )
            PlayerModel.Entity:SetBodygroup(Rucksack.Ent.BodyGroup[ply:GetNWString("Faction")][ply:GetNWInt("ModelIndex")][3], Rucksack.Ent.BodyGroup[ply:GetNWString("Faction")][ply:GetNWInt("ModelIndex")][4])
            ActionMenu:Remove()
        end)
        ActionMenu:Open()
    end
    Rucksack:SetDrawOnTop(true)

    local VestSlot = vgui.Create( "DImage", InventoryPanel )
    VestSlot:CenterHorizontal(0.65)
    VestSlot:CenterVertical(0.225)
    VestSlot:SetImage( "icon64/inventory_slot.png")
    VestSlot:SetSize( ScrW() / 20, ScrW() / 20 )

    local Vest = vgui.Create( "DImageButton", InventoryPanel )
    Vest:SetPos(VestSlot:GetPos())
    Vest:SetImage( MVSA.EntList[ply:GetNWInt("Vest")][2] )
    Vest:SetSize( ScrW() / 20, ScrW() / 20 )
    Vest.Ent = ents.CreateClientside( MVSA.EntList[ply:GetNWInt("Vest")][1] )
    Vest.DoClick = function()
        if SelectedIcon then
            SelectedIcon:Remove()
            for k = 0,SelectedContainer.Ent.Capacity - 1 do
                InventorySlot[k]:Remove()
                Inventory[k]:Remove()
            end
        end
        SelectedContainer = Vest
        ReloadSelectedContainer(0)
    end
    Vest.DoRightClick = function()
        local ActionMenu = DermaMenu(false, InventoryPanel)
        ActionMenu:AddOption( "Drop", function()
            net.Start("DropRequest")
            net.WriteString( MVSA.EntList[ply:GetNWInt("Vest")][1] )
            net.WriteString( "Vest" )
            net.WriteBool(false) -- the specified entity is a weapon
            net.WriteBool(true) -- the specified entity is bodygrouped
            net.SendToServer()
            Vest:SetImage( "vgui/null.vmt" )
            PlayerModel.Entity:SetBodygroup(Vest.Ent.BodyGroup[ply:GetNWString("Faction")][ply:GetNWInt("ModelIndex")][3], Vest.Ent.BodyGroup[ply:GetNWString("Faction")][ply:GetNWInt("ModelIndex")][4])
            ActionMenu:Remove()
        end)
        ActionMenu:Open()
    end
    Vest:SetDrawOnTop(true)

    local JacketSlot = vgui.Create( "DImage", InventoryPanel )
    JacketSlot:CenterHorizontal(0.45)
    JacketSlot:CenterVertical(0.225)
    JacketSlot:SetImage( "icon64/inventory_slot.png")
    JacketSlot:SetSize( ScrW() / 20, ScrW() / 20 )

    local Jacket = vgui.Create( "DImageButton", InventoryPanel )
    Jacket:SetPos(JacketSlot:GetPos())
    Jacket:SetImage( MVSA.EntList[ply:GetNWInt("Jacket")][2] )
    Jacket:SetSize( ScrW() / 20, ScrW() / 20 )
    Jacket.Ent = ents.CreateClientside( MVSA.EntList[ply:GetNWInt("Jacket")][1] )
    Jacket.DoClick = function()
        if SelectedIcon then
            SelectedIcon:Remove()
            if SelectedContainer.Ent.Capacity and SelectedContainer.Ent.Capacity > 0 then
                for k = 0,SelectedContainer.Ent.Capacity - 1 do
                    InventorySlot[k]:Remove()
                    Inventory[k]:Remove()
                end
            end
        end
        SelectedContainer = Jacket
        ReloadSelectedContainer(2)
    end
    Jacket.DoRightClick = function()
        local ActionMenu = DermaMenu(false, InventoryPanel)
        ActionMenu:AddOption( "Drop", function()
            net.Start("DropRequest")
            net.WriteString( MVSA.EntList[ply:GetNWInt("Jacket")][1] )
            net.WriteString( "Jacket" )
            net.WriteBool(false) -- the specified entity is a weapon
            net.WriteBool(true) -- the specified entity is bodygrouped
            net.SendToServer()
            Jacket:SetImage( "vgui/null.vmt" )
            PlayerModel.Entity:SetBodygroup(Jacket.Ent.BodyGroup[ply:GetNWString("Faction")][ply:GetNWInt("ModelIndex")][3], Jacket.Ent.BodyGroup[ply:GetNWString("Faction")][ply:GetNWInt("ModelIndex")][4])
            ActionMenu:Remove()
        end)
        ActionMenu:Open()
    end
    Jacket:SetDrawOnTop(true)

    local PantSlot = vgui.Create( "DImage", InventoryPanel )
    PantSlot:CenterHorizontal(0.85)
    PantSlot:CenterVertical(0.325)
    PantSlot:SetImage( "icon64/inventory_slot.png")
    PantSlot:SetSize( ScrW() / 20, ScrW() / 20 )

    local Pant = vgui.Create( "DImageButton", InventoryPanel )
    Pant:SetPos(PantSlot:GetPos())
    Pant:SetImage( MVSA.EntList[ply:GetNWInt("Pant")][2] )
    Pant:SetSize( ScrW() / 20, ScrW() / 20 )
    Pant.Ent = ents.CreateClientside( MVSA.EntList[ply:GetNWInt("Pant")][1] )
    Pant.DoClick = function()
        if SelectedIcon then
            SelectedIcon:Remove()
            if SelectedContainer.Ent.Capacity and SelectedContainer.Ent.Capacity > 0 then
                for k = 0,SelectedContainer.Ent.Capacity - 1 do
                    InventorySlot[k]:Remove()
                    Inventory[k]:Remove()
                end
            end
        end
        SelectedContainer = Pant
        ReloadSelectedContainer(0)
    end
    Pant.DoRightClick = function()
        local ActionMenu = DermaMenu(false, InventoryPanel)
        ActionMenu:AddOption( "Drop", function()
            net.Start("DropRequest")
            net.WriteString( MVSA.EntList[ply:GetNWInt("Pant")][1] )
            net.WriteString( "Pant" )
            net.WriteBool(false) -- the specified entity is a weapon
            net.WriteBool(true) -- the specified entity is bodygrouped
            net.SendToServer()
            Pant:SetImage( "vgui/null.vmt" )
            PlayerModel.Entity:SetBodygroup(Pant.Ent.BodyGroup[ply:GetNWString("Faction")][ply:GetNWInt("ModelIndex")][3], Pant.Ent.BodyGroup[ply:GetNWString("Faction")][ply:GetNWInt("ModelIndex")][4])
            ActionMenu:Remove()
        end)
        ActionMenu:Open()
    end
    Pant:SetDrawOnTop(true)

    SelectedContainer = Pant
    ReloadSelectedContainer(0)

    local PrimaryWepSlot = vgui.Create( "DImage", InventoryPanel )
    PrimaryWepSlot:CenterHorizontal(0.09)
    PrimaryWepSlot:CenterVertical(0.53)
    PrimaryWepSlot:SetImage( "vgui/primary_wep_slot.png")
    PrimaryWepSlot:SetSize( ScrW() / 5, ScrW() / 15 )

    local PrimaryWep = vgui.Create( "DImageButton", InventoryPanel )
    PrimaryWep:SetImage( MVSA.EntList[ply:GetNWInt("PrimaryWep")][2] )
    PrimaryWep:SetSize( ScrW() / 7.5, ScrW() / 15 )
    PrimaryWep:SetX(PrimaryWepSlot:GetX() + PrimaryWepSlot:GetWide() / 2 - PrimaryWep:GetWide() / 2 )
    PrimaryWep:SetY(PrimaryWepSlot:GetY() + PrimaryWepSlot:GetTall() / 2 - PrimaryWep:GetTall() / 2 )
    PrimaryWep.DoRightClick = function()
        local ActionMenu = DermaMenu(false, InventoryPanel)
        ActionMenu:AddOption( "Drop", function()
            net.Start("DropRequest")
            net.WriteString( MVSA.EntList[ply:GetNWInt("PrimaryWep")][1] )
            net.WriteString( "PrimaryWep" )
            net.WriteBool(true) -- the specified entity is a weapon
            net.WriteString( MVSA.EntList[ply:GetNWInt("PrimaryWep")][3] )
            net.WriteBool(false) -- the specified entity is bodygrouped
            net.SendToServer()
            PrimaryWep:SetImage( "vgui/null.vmt" )
            ActionMenu:Remove()
        end)
        ActionMenu:AddOption( "Use", function()
            net.Start("UseRequest")
            net.WriteString(MVSA.EntList[ply:GetNWInt("PrimaryWep")][3])
            net.SendToServer()
        end)
        ActionMenu:Open()
    end

    local SecondaryWepSlot = vgui.Create( "DImage", InventoryPanel )
    SecondaryWepSlot:CenterHorizontal(0.72)
    SecondaryWepSlot:CenterVertical(0.53)
    SecondaryWepSlot:SetImage( "icon64/inventory_slot.png")
    SecondaryWepSlot:SetSize( ScrW() / 15, ScrW() / 15 )

    local SecondaryWep = vgui.Create( "DImageButton", InventoryPanel )
    SecondaryWep:SetImage( MVSA.EntList[ply:GetNWInt("SecondaryWep")][2] )
    SecondaryWep:SetSize( ScrW() / 15, ScrW() / 30 )
    SecondaryWep:SetX(SecondaryWepSlot:GetX() + SecondaryWepSlot:GetWide() / 2 - SecondaryWep:GetWide() / 2 )
    SecondaryWep:SetY(SecondaryWepSlot:GetY() + SecondaryWepSlot:GetTall() / 2 - SecondaryWep:GetTall() / 2 )
    SecondaryWep.DoRightClick = function()
        local ActionMenu = DermaMenu(false, InventoryPanel)
        ActionMenu:AddOption( "Drop", function()
            net.Start("DropRequest")
            net.WriteString( MVSA.EntList[ply:GetNWInt("SecondaryWep")][1] )
            net.WriteString( "SecondaryWep" )
            net.WriteBool(true) -- the specified entity is a weapon
            net.WriteString( MVSA.EntList[ply:GetNWInt("SecondaryWep")][3] )
            net.WriteBool(false) -- the specified entity is bodygrouped
            net.SendToServer()
            SecondaryWep:SetImage( "vgui/null.vmt" )
            ActionMenu:Remove()
        end)
        ActionMenu:AddOption( "Use", function()
            net.Start("UseRequest")
            net.WriteString(MVSA.EntList[ply:GetNWInt("SecondaryWep")][3])
            net.SendToServer()
        end)
        ActionMenu:Open()
    end

    local LauncherSlot = vgui.Create( "DImage", InventoryPanel )
    LauncherSlot:CenterHorizontal(0.09)
    LauncherSlot:CenterVertical(0.65)
    LauncherSlot:SetImage( "vgui/primary_wep_slot.png")
    LauncherSlot:SetSize( ScrW() / 3.61, ScrW() / 15 )

    local Launcher = vgui.Create( "DImageButton", InventoryPanel )
    Launcher:SetImage( MVSA.EntList[ply:GetNWInt("Launcher")][2] )
    Launcher:SetSize( ScrW() / 7.5, ScrW() / 15 )
    Launcher:SetX(LauncherSlot:GetX() + LauncherSlot:GetWide() / 2 - Launcher:GetWide() / 2 )
    Launcher:SetY(LauncherSlot:GetY() + LauncherSlot:GetTall() / 2 - Launcher:GetTall() / 2 )
    Launcher.DoRightClick = function()
        local ActionMenu = DermaMenu(false, InventoryPanel)
        ActionMenu:AddOption( "Drop", function()
            net.Start("DropRequest")
            net.WriteString( MVSA.EntList[ply:GetNWInt("Launcher")][1] )
            net.WriteString( "Launcher" )
            net.WriteBool(true) -- the specified entity is a weapon
            net.WriteString( MVSA.EntList[ply:GetNWInt("Launcher")][3] )
            net.WriteBool(false) -- the specified entity is bodygrouped
            net.SendToServer()
            Launcher:SetImage( "vgui/null.vmt" )
            ActionMenu:Remove()
        end)
        ActionMenu:AddOption( "Use", function()
            net.Start("UseRequest")
            net.WriteString(MVSA.EntList[ply:GetNWInt("Launcher")][3])
            net.SendToServer()
        end)
        ActionMenu:Open()
    end

    InventoryPanel.OnMousePressed = function()
        if ActionMenu and ActionMenu:IsValid() then
            ActionMenu:Remove()
        end
    end
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
            InventoryPanel:Remove()
            ply.InventoryOpen = false
        end
    end
end

function UpdateClientMask( bool )
    if InventoryPanel:IsValid() then
        GasMask:SetVisible( bool )
        for k = 0,#ply:GetBodyGroups() - 1 do
            PlayerModel.Entity:SetBodygroup(k, ply:GetBodygroup(k))
        end
    end
end