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
    for k = 0,ply:GetNumBodyGroups() - 1 do
        PlayerModel.Entity:SetBodygroup(k, ply:GetBodygroup(k))
    end
    PlayerModel.Entity:SetSkin(ply:GetNWInt("Skin"))
    PlayerModel:SetCamPos(Vector(40, 0, 45))
    PlayerModel:SetLookAt(headpos + Vector(-90,20,-40))
    ply.InventoryOpen = true

    local NVGSlot = vgui.Create( "DImage", InventoryPanel )
    NVGSlot:CenterHorizontal(0.85)
    NVGSlot:CenterVertical(0.025)
    NVGSlot:SetImage( "icon64/inventory_slot.png")
    NVGSlot:SetSize( ScrH() / 12, ScrH() / 12 )

    if ply:GetNWInt("NVG") > 1 then
        local NVG = vgui.Create( "DImageButton", InventoryPanel )
        NVG:SetPos( NVGSlot:GetPos() )
        NVG:SetImage( MVSA.EntList[ply:GetNWInt("NVG")][2] )
        NVG:SetSize( ScrH() / 12, ScrH() / 12 )
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
                PlayerModel.Entity:SetBodygroup(NVG.Ent.BodyGroup[ply:GetNWString("Faction")][ply:GetNWInt("ModelIndex")][1], NVG.Ent.BodyGroup[ply:GetNWString("Faction")][ply:GetNWInt("ModelIndex")][3])
                ActionMenu:Remove()
            end)
            ActionMenu:Open()
        end
    end


    local HelmetSlot = vgui.Create( "DImage", InventoryPanel )
    HelmetSlot:SetX(NVGSlot:GetX() - NVGSlot:GetWide() - ScrH() / 50)
    HelmetSlot:SetY(NVGSlot:GetY())
    HelmetSlot:SetImage( "icon64/inventory_slot.png")
    HelmetSlot:SetSize( ScrH() / 12, ScrH() / 12 )

    if ply:GetNWInt("Helmet") > 1 then
        local Helmet = vgui.Create( "DImageButton", InventoryPanel )
        Helmet:SetPos( HelmetSlot:GetPos() )
        Helmet:SetImage( MVSA.EntList[ply:GetNWInt("Helmet")][2] )
        Helmet:SetSize( ScrH() / 12, ScrH() / 12 )
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
                PlayerModel.Entity:SetBodygroup(Helmet.Ent.BodyGroup[ply:GetNWString("Faction")][ply:GetNWInt("ModelIndex")][1], Helmet.Ent.BodyGroup[ply:GetNWString("Faction")][ply:GetNWInt("ModelIndex")][3])
                ActionMenu:Remove()
            end)
            ActionMenu:Open()
        end
    end

    local GasMaskSlot = vgui.Create( "DImage", InventoryPanel )
    GasMaskSlot:SetX(NVGSlot:GetX())
    GasMaskSlot:SetY(NVGSlot:GetY() + NVGSlot:GetTall() + ScrH() / 50)
    GasMaskSlot:SetImage( "icon64/inventory_slot.png")
    GasMaskSlot:SetSize( ScrH() / 12, ScrH() / 12 )

    GasMask = vgui.Create( "DImage", InventoryPanel )
    GasMask:SetPos( GasMaskSlot:GetPos() )
    GasMask:SetImage( "icon64/gasmask.png" )
    GasMask:SetSize( ScrH() / 12, ScrH() / 12 )
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
            local i,j = 0,1
            InventorySlot[0] = vgui.Create( "DImage", InventoryPanel )
            InventorySlot[0]:SetX(LauncherSlot:GetX())
            InventorySlot[0]:SetY(LauncherSlot:GetY() + LauncherSlot:GetTall() + ScrH() / 50)
            InventorySlot[0]:SetImage( "icon64/inventory_slot.png")
            InventorySlot[0]:SetSize( ScrH() / 12, ScrH() / 12 )
            if ply:GetNWInt("Inventory" .. tostring(1 + StartingIndex)) > 1 then
                Inventory[0] = vgui.Create( "SpawnIcon", InventoryPanel )
                Inventory[0].Ent = ents.CreateClientside(MVSA.EntList[ply:GetNWInt("Inventory" .. tostring(1 + StartingIndex))][1])
                Inventory[0]:SetPos(InventorySlot[0]:GetPos())
                Inventory[0]:SetModel(Inventory[0].Ent.Model)
                Inventory[0]:SetSize( ScrH() / 12, ScrH() / 12 )
                Inventory[0].DoRightClick = function()
                    local ActionMenu = DermaMenu(false, InventoryPanel)
                    ActionMenu:AddOption( "Drop", function()
                        net.Start("DropRequest")
                        net.WriteString( MVSA.EntList[ply:GetNWInt("Inventory" .. tostring(StartingIndex + 1))][1] )
                        net.WriteString( "Inventory" .. tostring(StartingIndex + 1) )
                        net.WriteBool(false) -- the specified entity is a weapon
                        net.WriteBool(false) -- the specified entity is bodygrouped
                        net.WriteBool(Inventory[0].Ent.AmmoID ~= nil) -- the specified entity is ammo
                        if Inventory[0].Ent.AmmoID ~= nil then
                            net.WriteInt(Inventory[0].Ent.AmmoCount, 9)
                            net.WriteInt(Inventory[0].Ent.AmmoID, 5)
                        end
                        net.SendToServer()
                        Inventory[0]:Remove()
                    end)
                    ActionMenu:Open()
                end
            end
            for k = 1,SelectedContainer.Ent.Capacity - 1 do
                InventorySlot[k] = vgui.Create( "DImage", InventoryPanel )
                InventorySlot[k]:SetX(InventorySlot[0]:GetX() + j * (InventorySlot[0]:GetWide() + ScrH() / 50))
                InventorySlot[k]:SetY(InventorySlot[0]:GetY() + i * (InventorySlot[0]:GetTall() + ScrH() / 50))
                InventorySlot[k]:SetImage( "icon64/inventory_slot.png")
                InventorySlot[k]:SetSize( ScrH() / 12, ScrH() / 12 )
                if ply:GetNWInt("Inventory" .. tostring(StartingIndex + k + 1)) > 1 then
                    Inventory[k] = vgui.Create( "SpawnIcon", InventoryPanel )
                    Inventory[k].Ent = ents.CreateClientside(MVSA.EntList[ply:GetNWInt("Inventory" .. tostring(StartingIndex + k + 1))][1])
                    Inventory[k]:SetPos(InventorySlot[k]:GetPos())
                    Inventory[k]:SetModel(Inventory[k].Ent.Model)
                    Inventory[k]:SetSize( ScrH() / 12, ScrH() / 12 )
                    Inventory[k].DoRightClick = function()
                        local ActionMenu = DermaMenu(false, InventoryPanel)
                        ActionMenu:AddOption( "Drop", function()
                            net.Start("DropRequest")
                            net.WriteString( MVSA.EntList[ply:GetNWInt("Inventory" .. tostring(StartingIndex + k + 1))][1] )
                            net.WriteString( "Inventory" .. tostring(StartingIndex + k + 1) )
                            net.WriteBool(false) -- the specified entity is a weapon
                            net.WriteBool(false) -- the specified entity is bodygrouped
                            net.WriteBool(Inventory[k].Ent.AmmoID ~= nil) -- the specified entity is ammo
                            if Inventory[k].Ent.AmmoID ~= nil then
                                net.WriteUInt(Inventory[k].Ent.AmmoCount, 9)
                                net.WriteUInt(Inventory[k].Ent.AmmoID, 5)
                            end
                            net.SendToServer()
                            Inventory[k]:Remove()
                        end)
                        ActionMenu:Open()
                    end
                end
                j = j + 1
                if j == 5 then
                    i = i + 1
                    j = 0
                end
            end
        end
    end

    local RucksackSlot = vgui.Create( "DImage", InventoryPanel )
    RucksackSlot:SetX(GasMaskSlot:GetX())
    RucksackSlot:SetY(GasMaskSlot:GetY() + GasMaskSlot:GetTall() + ScrH() / 50)
    RucksackSlot:SetImage( "icon64/inventory_slot.png")
    RucksackSlot:SetSize( ScrH() / 12, ScrH() / 12 )

    if ply:GetNWInt("Rucksack") > 1 then
        Rucksack = vgui.Create( "DImageButton", InventoryPanel )
        Rucksack:SetPos(RucksackSlot:GetPos())
        Rucksack:SetImage( MVSA.EntList[ply:GetNWInt("Rucksack")][2] )
        Rucksack:SetSize( ScrH() / 12, ScrH() / 12 )
        Rucksack.Ent = ents.CreateClientside( MVSA.EntList[ply:GetNWInt("Rucksack")][1] )
        Rucksack.DoClick = function()
            if SelectedIcon then
                SelectedIcon:Remove()
                if SelectedContainer and SelectedContainer.Ent.Capacity and SelectedContainer.Ent.Capacity > 0 then
                    for k = 0,SelectedContainer.Ent.Capacity - 1 do
                        InventorySlot[k]:Remove()
                        if Inventory[k] and Inventory[k]:IsValid() then
                            Inventory[k]:Remove()
                        end
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
                net.WriteBool(false) -- the specified entity is ammo
                net.SendToServer()
                Rucksack:Remove()
                PlayerModel.Entity:SetBodygroup(Rucksack.Ent.BodyGroup[ply:GetNWString("Faction")][ply:GetNWInt("ModelIndex")][1], Rucksack.Ent.BodyGroup[ply:GetNWString("Faction")][ply:GetNWInt("ModelIndex")][3])
            end)
            ActionMenu:Open()
        end
    end

    local VestSlot = vgui.Create( "DImage", InventoryPanel )
    VestSlot:SetX(RucksackSlot:GetX() - RucksackSlot:GetWide() - ScrH() / 50)
    VestSlot:SetY(RucksackSlot:GetY())
    VestSlot:SetImage( "icon64/inventory_slot.png")
    VestSlot:SetSize( ScrH() / 12, ScrH() / 12 )

    if ply:GetNWInt("Vest") > 1 then
        Vest = vgui.Create( "DImageButton", InventoryPanel )
        Vest:SetPos(VestSlot:GetPos())
        Vest:SetImage( MVSA.EntList[ply:GetNWInt("Vest")][2] )
        Vest:SetSize( ScrH() / 12, ScrH() / 12 )
        Vest.Ent = ents.CreateClientside( MVSA.EntList[ply:GetNWInt("Vest")][1] )
        Vest.DoClick = function()
            if SelectedIcon then
                SelectedIcon:Remove()
                if SelectedContainer and SelectedContainer.Ent.Capacity and SelectedContainer.Ent.Capacity > 0 then
                    for k = 0,SelectedContainer.Ent.Capacity - 1 do
                        InventorySlot[k]:Remove()
                        if Inventory[k] and Inventory[k]:IsValid() then
                            Inventory[k]:Remove()
                        end
                    end
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
                net.WriteBool(false) -- the specified entity is ammo
                net.SendToServer()
                Vest:Remove()
                PlayerModel.Entity:SetBodygroup(Vest.Ent.BodyGroup[ply:GetNWString("Faction")][ply:GetNWInt("ModelIndex")][1], Vest.Ent.BodyGroup[ply:GetNWString("Faction")][ply:GetNWInt("ModelIndex")][3])
            end)
            ActionMenu:Open()
        end
        Vest:SetDrawOnTop(true)
    end

    local JacketSlot = vgui.Create( "DImage", InventoryPanel )
    JacketSlot:SetX(VestSlot:GetX() - VestSlot:GetWide() - ScrH() / 50)
    JacketSlot:SetY(VestSlot:GetY())
    JacketSlot:SetImage( "icon64/inventory_slot.png")
    JacketSlot:SetSize( ScrH() / 12, ScrH() / 12 )

    if ply:GetNWInt("Jacket") > 1 then
        Jacket = vgui.Create( "DImageButton", InventoryPanel )
        Jacket:SetPos(JacketSlot:GetPos())
        Jacket:SetImage( MVSA.EntList[ply:GetNWInt("Jacket")][2] )
        Jacket:SetSize( ScrH() / 12, ScrH() / 12 )
        Jacket.Ent = ents.CreateClientside( MVSA.EntList[ply:GetNWInt("Jacket")][1] )
        Jacket.DoClick = function()
            if SelectedIcon then
                SelectedIcon:Remove()
                if SelectedContainer and SelectedContainer.Ent.Capacity and SelectedContainer.Ent.Capacity > 0 then
                    for k = 0,SelectedContainer.Ent.Capacity - 1 do
                        InventorySlot[k]:Remove()
                        if Inventory[k] and Inventory[k]:IsValid() then
                            Inventory[k]:Remove()
                        end
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
                net.WriteBool(false) -- the specified entity is ammo
                net.SendToServer()
                Jacket:SetImage( "vgui/null.vmt" )
                PlayerModel.Entity:SetBodygroup(Jacket.Ent.BodyGroup[ply:GetNWString("Faction")][ply:GetNWInt("ModelIndex")][1], Jacket.Ent.BodyGroup[ply:GetNWString("Faction")][ply:GetNWInt("ModelIndex")][3])
                ActionMenu:Remove()
            end)
            ActionMenu:Open()
        end
        Jacket:SetDrawOnTop(true)
    end

    local PantSlot = vgui.Create( "DImage", InventoryPanel )
    PantSlot:SetX(RucksackSlot:GetX())
    PantSlot:SetY(RucksackSlot:GetY() + RucksackSlot:GetTall() + ScrH() / 50)
    PantSlot:SetImage( "icon64/inventory_slot.png")
    PantSlot:SetSize( ScrH() / 12, ScrH() / 12 )

    if ply:GetNWInt("Pant") > 1 then
        Pant = vgui.Create( "DImageButton", InventoryPanel )
        Pant:SetPos(PantSlot:GetPos())
        Pant:SetImage( MVSA.EntList[ply:GetNWInt("Pant")][2] )
        Pant:SetSize( ScrH() / 12, ScrH() / 12 )
        Pant.Ent = ents.CreateClientside( MVSA.EntList[ply:GetNWInt("Pant")][1] )
        Pant.DoClick = function()
            if SelectedIcon then
                SelectedIcon:Remove()
                if SelectedContainer and SelectedContainer.Ent.Capacity and SelectedContainer.Ent.Capacity > 0 then
                    for k = 0,SelectedContainer.Ent.Capacity - 1 do
                        InventorySlot[k]:Remove()
                        if Inventory[k] and Inventory[k]:IsValid() then
                            Inventory[k]:Remove()
                        end
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
                net.WriteBool(false) -- the specified entity is ammo
                net.SendToServer()
                Pant:SetImage( "vgui/null.vmt" )
                PlayerModel.Entity:SetBodygroup(Pant.Ent.BodyGroup[ply:GetNWString("Faction")][ply:GetNWInt("ModelIndex")][1], Pant.Ent.BodyGroup[ply:GetNWString("Faction")][ply:GetNWInt("ModelIndex")][3])
                ActionMenu:Remove()
            end)
            ActionMenu:Open()
        end
        Pant:SetDrawOnTop(true)
    end

    local PrimaryWepSlot = vgui.Create( "DImage", InventoryPanel )
    PrimaryWepSlot:CenterHorizontal(0.09)
    PrimaryWepSlot:CenterVertical(0.53)
    PrimaryWepSlot:SetImage( "vgui/primary_wep_slot.png")
    PrimaryWepSlot:SetSize( ScrH() / 3, ScrH() / 9 )

    if ply:GetNWInt("PrimaryWep") > 1 then
        local PrimaryWep = vgui.Create( "DImageButton", InventoryPanel )
        PrimaryWep:SetImage( MVSA.EntList[ply:GetNWInt("PrimaryWep")][2] )
        PrimaryWep:SetSize( ScrH() / 4.5, ScrH() / 9 )
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
                net.WriteBool(false) -- the specified entity is ammo
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
    end

    local SecondaryWepSlot = vgui.Create( "DImage", InventoryPanel )
    SecondaryWepSlot:SetX(PrimaryWepSlot:GetX() + PrimaryWepSlot:GetWide() + ScrH() / 50)
    SecondaryWepSlot:SetY(PrimaryWepSlot:GetY())
    SecondaryWepSlot:SetImage( "icon64/inventory_slot.png")
    SecondaryWepSlot:SetSize( ScrH() / 7, ScrH() / 9 )

    if ply:GetNWInt("SecondaryWep") > 1 then
        local SecondaryWep = vgui.Create( "DImageButton", InventoryPanel )
        SecondaryWep:SetImage( MVSA.EntList[ply:GetNWInt("SecondaryWep")][2] )
        SecondaryWep:SetSize( ScrH() / 9, ScrH() / 18 )
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
                net.WriteBool(false) -- the specified entity is ammo
                net.SendToServer()
                SecondaryWep:SetImage( "vgui/null.vmt" )
                ActionMenu:Remove()
            end)
            ActionMenu:AddOption( "Use", function()
                net.Start("UseRequest")
                net.WriteString( MVSA.EntList[ply:GetNWInt("SecondaryWep")][3] )
                net.SendToServer()
            end)
            ActionMenu:Open()
        end
    end

    LauncherSlot = vgui.Create( "DImage", InventoryPanel )
    LauncherSlot:SetX(PrimaryWepSlot:GetX())
    LauncherSlot:SetY(PrimaryWepSlot:GetY() + PrimaryWepSlot:GetTall() + ScrH() / 50)
    LauncherSlot:SetImage( "vgui/primary_wep_slot.png")
    LauncherSlot:SetSize( ScrW() / 3.61, ScrW() / 15 )

    if ply:GetNWInt("Launcher") > 1 then
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
                net.WriteBool(false) -- the specified entity is ammo
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
    end
    if Rucksack and Rucksack:IsValid() then
        SelectedContainer = Rucksack
        ReloadSelectedContainer(10)
    elseif Vest and Vest:IsValid() then
        SelectedContainer = Vest
        ReloadSelectedContainer(5)
    elseif Jacket and Jacket:IsValid() then
        SelectedContainer = Jacket
        ReloadSelectedContainer(2)
    elseif Pant and Pant:IsValid() then
        SelectedContainer = Pant
        ReloadSelectedContainer(0)
    else
        SelectedContainer = nil
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