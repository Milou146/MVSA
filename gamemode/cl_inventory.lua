function CreateInventoryPanel()
    ply = LocalPlayer()
    InventoryPanel = vgui.Create( "EditablePanel" )
    InventoryPanel:SetSize( ScrW() / 3, ScrH() )
    InventoryPanel.Paint = function( self, w, h )
        draw.RoundedBox( 2, 0, 0, w, h, Color( 0, 0, 0, 200 ) )
    end
    InventoryPanel:MakePopup( true )
    InventoryPanel:SetKeyboardInputEnabled( false )

    PlayerModel = vgui.Create( "DModelPanel", InventoryPanel )
    PlayerModel:SetModel(ply:GetModel())
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

    local NVGSlot = vgui.Create( "DImage", InventoryPanel )
    NVGSlot:CenterHorizontal(0.85)
    NVGSlot:CenterVertical(0.025)
    NVGSlot:SetImage( "icon64/inventory_slot.png")
    NVGSlot:SetSize( ScrH() / 12, ScrH() / 12 )

    local function DropNVG()
        net.Start("DropRequest")
        net.WriteString( "NVG" )
        net.WriteBool(false) -- the specified entity is a weapon
        net.WriteBool(true) -- the specified entity is bodygrouped
        net.SendToServer()
        NVG:Remove()
        if NV_Status then
            NV_Status = false
            net.Start("NVGPutOff")
            net.SendToServer()
            if InventoryPanel and InventoryPanel:IsValid() then
                PlayerModel.Entity:SetBodygroup(PlayerModels[ply:GetNWString("Faction")][ply:GetNWInt("ModelIndex")].nvg_bodygroup[1], PlayerModels[ply:GetNWString("Faction")][ply:GetNWInt("ModelIndex")].nvg_bodygroup[2])
            end

            surface.PlaySound( Sound( "items/nvg/off.wav" ) )
            hook.Remove("RenderScreenspaceEffects", "NV_FX")
            hook.Remove("PostDrawViewModel", "NV_PostDrawViewModel")
        end
        PlayerModel.Entity:SetBodygroup(NVG.Ent.BodyGroup[ply:GetNWString("Faction")][ply:GetNWInt("ModelIndex")][1], NVG.Ent.BodyGroup[ply:GetNWString("Faction")][ply:GetNWInt("ModelIndex")][3])
    end

    if ply:GetNWInt("NVG") > 1 then
        NVG = vgui.Create( "DImageButton", InventoryPanel )
        NVG:SetPos( NVGSlot:GetPos() )
        NVG:SetImage( EntList[ply:GetNWInt("NVG")].icon )
        NVG:SetSize( ScrH() / 12, ScrH() / 12 )
        if NV_Status then
            NVG:SetAlpha(255)
        else
            NVG:SetAlpha(100)
        end
        NVG.Ent = ents.CreateClientside( EntList[ply:GetNWInt("NVG")].className )
        NVG.DoRightClick = function()
            local ActionMenu = DermaMenu(false, InventoryPanel)
            ActionMenu:AddOption( "Drop", function()
                DropNVG()
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
        Helmet:SetImage( EntList[ply:GetNWInt("Helmet")].icon )
        Helmet:SetSize( ScrH() / 12, ScrH() / 12 )
        Helmet.Ent = ents.CreateClientside( EntList[ply:GetNWInt("Helmet")].className )
        Helmet.DoRightClick = function()
            local ActionMenu = DermaMenu(false, InventoryPanel)
            ActionMenu:AddOption( "Drop", function()
                net.Start("DropRequest")
                net.WriteString( "Helmet" )
                net.WriteBool(false) -- the specified entity is a weapon
                net.WriteBool(true) -- the specified entity is bodygrouped
                net.SendToServer()
                Helmet:Remove()
                PlayerModel.Entity:SetBodygroup(Helmet.Ent.BodyGroup[ply:GetNWString("Faction")][ply:GetNWInt("ModelIndex")][1], Helmet.Ent.BodyGroup[ply:GetNWString("Faction")][ply:GetNWInt("ModelIndex")][3])
                DropNVG()
            end)
            ActionMenu:Open()
        end
    end

    local GasMaskSlot = vgui.Create( "DImage", InventoryPanel )
    GasMaskSlot:SetX(NVGSlot:GetX())
    GasMaskSlot:SetY(NVGSlot:GetY() + NVGSlot:GetTall() + ScrH() / 50)
    GasMaskSlot:SetImage( "icon64/inventory_slot.png")
    GasMaskSlot:SetSize( ScrH() / 12, ScrH() / 12 )

    if ply:GetNWInt("GasMask") > 1 then
        GasMask = vgui.Create( "DImageButton", InventoryPanel )
        GasMask:SetPos( GasMaskSlot:GetPos() )
        GasMask:SetImage( "icon64/gasmask.png" )
        GasMask:SetSize( ScrH() / 12, ScrH() / 12 )
        if ply:GetNWInt("GasMaskSet") then
            GasMask:SetAlpha(255)
        else
            GasMask:SetAlpha(100)
        end
        GasMask.Ent = ents.CreateClientside( EntList[ply:GetNWInt("GasMask")].className )
        GasMask.DoRightClick = function()
            local ActionMenu = DermaMenu(false, InventoryPanel)
            ActionMenu:AddOption( "Drop", function()
                if not ply:GetNWInt("GASMASK_SpamDelay") or ply:GetNWInt("GASMASK_SpamDelay") < CurTime() then
                    net.Start("DropRequest")
                    net.WriteString( "GasMask" )
                    net.WriteBool(false) -- the specified entity is a weapon
                    net.WriteBool(true) -- the specified entity is bodygrouped
                    net.SendToServer()
                    if ply:GetNWBool("GasMaskSet") then
                        ply:ConCommand("gasmask_toggle")
                    end
                    timer.Simple(1, function()
                        PlayerModel.Entity:SetBodygroup(GasMask.Ent.BodyGroup[ply:GetNWString("Faction")][ply:GetNWInt("ModelIndex")][1], GasMask.Ent.BodyGroup[ply:GetNWString("Faction")][ply:GetNWInt("ModelIndex")][3])
                        GasMask:Remove()
                    end)
                end
            end)
            ActionMenu:Open()
        end
    end

    local function ReloadSelectedContainer(StartingIndex)

        SelectedIcon = vgui.Create( "DImage", InventoryPanel )
        SelectedIcon:SetSize( ScrW() / 24, ScrW() / 24 )
        SelectedIcon:SetX(SelectedContainer:GetX() + SelectedContainer:GetWide() / 2 - SelectedIcon:GetWide() / 2 )
        SelectedIcon:SetY(SelectedContainer:GetY() + SelectedContainer:GetTall() / 2 - SelectedIcon:GetTall() / 2 )
        SelectedIcon:SetImage( "vgui/spawnmenu/hover.vmt" )

        if SelectedContainer.Ent.Capacity then
            InventorySlotFrame = {}
            local InventorySlot = {}
            local InventoryFrame = {}
            local Inventory = {}
            local i,j = 0,0
            for k = 0,SelectedContainer.Ent.Capacity - 1 do
                InventorySlotFrame[k] = vgui.Create("EditablePanel", InventoryPanel)
                InventorySlotFrame[k]:SetSize( ScrH() / 12, ScrH() / 12 )
                InventorySlotFrame[k]:SetX(LauncherSlot:GetX() + j * (InventorySlotFrame[0]:GetWide() + ScrH() / 50))
                InventorySlotFrame[k]:SetY(LauncherSlot:GetY() + LauncherSlot:GetTall() + ScrH() / 50 + i * (InventorySlotFrame[0]:GetTall() + ScrH() / 50))
                InventorySlot[k] = vgui.Create( "DImage", InventorySlotFrame[k] )
                InventorySlot[k]:SetImage( "icon64/inventory_slot.png")
                InventorySlot[k]:SetSize( ScrH() / 12, ScrH() / 12 )
                if ply:GetNWInt("Inventory" .. tostring(StartingIndex + k + 1)) > 1 then
                    InventoryFrame[k] = vgui.Create( "EditablePanel", InventorySlotFrame[k] )
                    InventoryFrame[k]:SetSize( ScrH() / 12, ScrH() / 12 )
                    Inventory[k] = vgui.Create( "SpawnIcon", InventoryFrame[k] )
                    Inventory[k].Ent = ents.CreateClientside(EntList[ply:GetNWInt("Inventory" .. tostring(StartingIndex + k + 1))].className)
                    Inventory[k]:SetModel(Inventory[k].Ent.Model)
                    Inventory[k]:SetSize( ScrH() / 12, ScrH() / 12 )
                    if EntList[ply:GetNWInt("Inventory" .. tostring(StartingIndex + k + 1))].ammoName then
                        Inventory[k].ProgressBar = vgui.Create("DProgress", InventoryFrame[k])
                        Inventory[k].ProgressBar:SetSize(Inventory[k]:GetWide(), Inventory[k]:GetTall() / 5)
                        Inventory[k].ProgressBar:SetFraction( ply:GetNWInt("AmmoBox" .. tostring(StartingIndex + k + 1)) / EntList[ply:GetNWInt("Inventory" .. tostring(StartingIndex + k + 1))].capacity )
                    end
                    Inventory[k].DoRightClick = function()
                        local ActionMenu = DermaMenu(false, InventoryPanel)
                        ActionMenu:AddOption( "Drop", function()
                            net.Start("DropRequest")
                            net.WriteString( "Inventory" .. tostring(StartingIndex + k + 1) )
                            net.WriteBool(false) -- the specified entity is a weapon
                            net.WriteBool(false) -- the specified entity is bodygrouped
                            if Inventory[k].Ent.AmmoName ~= nil then
                                net.WriteUInt(ply:GetNWInt("AmmoBox" .. tostring(StartingIndex + k + 1)), 9)
                                net.WriteUInt(game.GetAmmoID(Inventory[k].Ent.AmmoName), 5)
                            end
                            net.SendToServer()
                            InventoryFrame[k]:Remove()
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
        Rucksack:SetImage( EntList[ply:GetNWInt("Rucksack")].icon )
        Rucksack:SetSize( ScrH() / 12, ScrH() / 12 )
        Rucksack.Ent = ents.CreateClientside( EntList[ply:GetNWInt("Rucksack")].className )
        Rucksack.DoClick = function()
            if SelectedIcon then
                SelectedIcon:Remove()
                if SelectedContainer and SelectedContainer.Ent.Capacity and SelectedContainer.Ent.Capacity > 0 then
                    for k = 0,SelectedContainer.Ent.Capacity - 1 do
                        InventorySlotFrame[k]:Remove()
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
                net.WriteString( "Rucksack" )
                net.WriteBool(false) -- the specified entity is a weapon
                net.WriteBool(true) -- the specified entity is bodygrouped
                net.SendToServer()
                Rucksack:Remove()
                PlayerModel.Entity:SetBodygroup(Rucksack.Ent.BodyGroup[ply:GetNWString("Faction")][ply:GetNWInt("ModelIndex")][1], Rucksack.Ent.BodyGroup[ply:GetNWString("Faction")][ply:GetNWInt("ModelIndex")][3])
                if SelectedContainer == Rucksack then
                    SelectedIcon:Remove()
                    for k = 0,SelectedContainer.Ent.Capacity - 1 do
                        InventorySlotFrame[k]:Remove()
                    end
                end
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
        Vest:SetImage( EntList[ply:GetNWInt("Vest")].icon )
        Vest:SetSize( ScrH() / 12, ScrH() / 12 )
        Vest.Ent = ents.CreateClientside( EntList[ply:GetNWInt("Vest")].className )
        Vest.DoClick = function()
            if SelectedIcon then
                SelectedIcon:Remove()
                if SelectedContainer and SelectedContainer.Ent.Capacity and SelectedContainer.Ent.Capacity > 0 then
                    for k = 0,SelectedContainer.Ent.Capacity - 1 do
                        InventorySlotFrame[k]:Remove()
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
                net.WriteString( "Vest" )
                net.WriteBool(false) -- the specified entity is a weapon
                net.WriteBool(true) -- the specified entity is bodygrouped
                net.SendToServer()
                Vest:Remove()
                PlayerModel.Entity:SetBodygroup(Vest.Ent.BodyGroup[ply:GetNWString("Faction")][ply:GetNWInt("ModelIndex")][1], Vest.Ent.BodyGroup[ply:GetNWString("Faction")][ply:GetNWInt("ModelIndex")][3])
                if SelectedContainer == Vest then
                    SelectedIcon:Remove()
                    if SelectedContainer.Ent.Capacity then
                        for k = 0,SelectedContainer.Ent.Capacity - 1 do
                            InventorySlotFrame[k]:Remove()
                        end
                    end
                end
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
        Jacket:SetImage( EntList[ply:GetNWInt("Jacket")].icon )
        Jacket:SetSize( ScrH() / 12, ScrH() / 12 )
        Jacket.Ent = ents.CreateClientside( EntList[ply:GetNWInt("Jacket")].className )
        Jacket.DoClick = function()
            if SelectedIcon then
                SelectedIcon:Remove()
                if SelectedContainer and SelectedContainer.Ent.Capacity and SelectedContainer.Ent.Capacity > 0 then
                    for k = 0,SelectedContainer.Ent.Capacity - 1 do
                        InventorySlotFrame[k]:Remove()
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
                net.WriteString( "Jacket" )
                net.WriteBool(false) -- the specified entity is a weapon
                net.WriteBool(true) -- the specified entity is bodygrouped
                net.SendToServer()
                Jacket:SetImage( "vgui/null.vmt" )
                PlayerModel.Entity:SetBodygroup(Jacket.Ent.BodyGroup[ply:GetNWString("Faction")][ply:GetNWInt("ModelIndex")][1], Jacket.Ent.BodyGroup[ply:GetNWString("Faction")][ply:GetNWInt("ModelIndex")][3])
                if SelectedContainer == Jacket then
                    SelectedIcon:Remove()
                    for k = 0,SelectedContainer.Ent.Capacity - 1 do
                        InventorySlotFrame[k]:Remove()
                    end
                end
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
        Pant:SetImage( EntList[ply:GetNWInt("Pant")].icon )
        Pant:SetSize( ScrH() / 12, ScrH() / 12 )
        Pant.Ent = ents.CreateClientside( EntList[ply:GetNWInt("Pant")].className )
        Pant.DoClick = function()
            if SelectedIcon then
                SelectedIcon:Remove()
                if SelectedContainer and SelectedContainer.Ent.Capacity and SelectedContainer.Ent.Capacity > 0 then
                    for k = 0,SelectedContainer.Ent.Capacity - 1 do
                        InventorySlotFrame[k]:Remove()
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
                net.WriteString( "Pant" )
                net.WriteBool(false) -- the specified entity is a weapon
                net.WriteBool(true) -- the specified entity is bodygrouped
                net.SendToServer()
                PlayerModel.Entity:SetBodygroup(Pant.Ent.BodyGroup[ply:GetNWString("Faction")][ply:GetNWInt("ModelIndex")][1], Pant.Ent.BodyGroup[ply:GetNWString("Faction")][ply:GetNWInt("ModelIndex")][3])
                if SelectedContainer == Pant then
                    SelectedIcon:Remove()
                    for k = 0,SelectedContainer.Ent.Capacity - 1 do
                        InventorySlotFrame[k]:Remove()
                    end
                end
                Pant:Remove()
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
        PrimaryWep:SetImage( EntList[ply:GetNWInt("PrimaryWep")].icon )
        PrimaryWep:SetSize( ScrH() / 4.5, ScrH() / 9 )
        PrimaryWep:SetX(PrimaryWepSlot:GetX() + PrimaryWepSlot:GetWide() / 2 - PrimaryWep:GetWide() / 2 )
        PrimaryWep:SetY(PrimaryWepSlot:GetY() + PrimaryWepSlot:GetTall() / 2 - PrimaryWep:GetTall() / 2 )
        PrimaryWep.DoRightClick = function()
            local ActionMenu = DermaMenu(false, InventoryPanel)
            ActionMenu:AddOption( "Drop", function()
                net.Start("DropRequest")
                net.WriteString( "PrimaryWep" )
                net.WriteBool(true) -- the specified entity is a weapon
                net.WriteBool(false) -- the specified entity is bodygrouped
                net.SendToServer()
                PrimaryWep:Remove()
            end)
            ActionMenu:AddOption( "Use", function()
                net.Start("UseRequest")
                net.WriteString(EntList[ply:GetNWInt("PrimaryWep")].wep)
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
        SecondaryWep:SetImage( EntList[ply:GetNWInt("SecondaryWep")].icon )
        SecondaryWep:SetSize( ScrH() / 9, ScrH() / 18 )
        SecondaryWep:SetX(SecondaryWepSlot:GetX() + SecondaryWepSlot:GetWide() / 2 - SecondaryWep:GetWide() / 2 )
        SecondaryWep:SetY(SecondaryWepSlot:GetY() + SecondaryWepSlot:GetTall() / 2 - SecondaryWep:GetTall() / 2 )
        SecondaryWep.DoRightClick = function()
            local ActionMenu = DermaMenu(false, InventoryPanel)
            ActionMenu:AddOption( "Drop", function()
                net.Start("DropRequest")
                net.WriteString( "SecondaryWep" )
                net.WriteBool(true) -- the specified entity is a weapon
                net.WriteBool(false) -- the specified entity is bodygrouped
                net.SendToServer()
                SecondaryWep:Remove()
                ActionMenu:Remove()
            end)
            ActionMenu:AddOption( "Use", function()
                net.Start("UseRequest")
                net.WriteString( EntList[ply:GetNWInt("SecondaryWep")].wep )
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
        Launcher:SetImage( EntList[ply:GetNWInt("Launcher")].icon )
        Launcher:SetSize( ScrW() / 7.5, ScrW() / 15 )
        Launcher:SetX(LauncherSlot:GetX() + LauncherSlot:GetWide() / 2 - Launcher:GetWide() / 2 )
        Launcher:SetY(LauncherSlot:GetY() + LauncherSlot:GetTall() / 2 - Launcher:GetTall() / 2 )
        Launcher.DoRightClick = function()
            local ActionMenu = DermaMenu(false, InventoryPanel)
            ActionMenu:AddOption( "Drop", function()
                net.Start("DropRequest")
                net.WriteString( "Launcher" )
                net.WriteBool(true) -- the specified entity is a weapon
                net.WriteBool(false) -- the specified entity is bodygrouped
                net.SendToServer()
                Launcher:SetImage( "vgui/null.vmt" )
                ActionMenu:Remove()
            end)
            ActionMenu:AddOption( "Use", function()
                net.Start("UseRequest")
                net.WriteString(EntList[ply:GetNWInt("Launcher")].wep)
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
    if RagdollPanel then
        RagdollPanel:Remove()
    end
    if player_manager.GetPlayerClass(LocalPlayer()) ~= "player_spectator" then
        if not InventoryPanel or not InventoryPanel:IsValid() then
            CreateInventoryPanel()
        else
            InventoryPanel:Remove()
        end
    end
end

net.Receive("RagdollLooting", function()
    if InventoryPanel then
        InventoryPanel:Remove()
    end
    if RagdollPanel then
        RagdollPanel:Remove()
    end
    CreateInventoryPanel()
    ragdollID = net.ReadUInt(32)
    CreateRagdollPanel(ents.GetByIndex(ragdollID))

end)

function CreateRagdollPanel(ragdoll)

    RagdollPanel = vgui.Create( "EditablePanel" )
    RagdollPanel:SetSize( ScrW() / 3, ScrH() )
    RagdollPanel.Paint = function( self, w, h )
        draw.RoundedBox( 2, 0, 0, w, h, Color( 0, 0, 0, 200 ) )
    end
    RagdollPanel:SetX(ScrW() - RagdollPanel:GetWide())
    RagdollPanel:MakePopup( true )
    RagdollPanel:SetKeyboardInputEnabled( false )

    local NVGSlot = vgui.Create( "DImage", RagdollPanel )
    NVGSlot:CenterHorizontal(0.85)
    NVGSlot:CenterVertical(0.025)
    NVGSlot:SetImage( "icon64/inventory_slot.png")
    NVGSlot:SetSize( ScrH() / 12, ScrH() / 12 )

    local function DropNVG()
        net.Start("RagdollDropRequest")
        net.WriteUInt(ragdollID, 32)
        net.WriteString( "NVG" )
        net.WriteBool(false) -- the specified entity is a weapon
        net.WriteBool(true) -- the specified entity is bodygrouped
        net.SendToServer()
        RagdollNVG:Remove()
    end

    if ragdoll:GetNWInt("NVG") > 1 then
        local RagdollNVG = vgui.Create( "DImageButton", RagdollPanel )
        RagdollNVG:SetPos( NVGSlot:GetPos() )
        RagdollNVG:SetImage( EntList[ragdoll:GetNWInt("NVG")].icon )
        RagdollNVG:SetSize( ScrH() / 12, ScrH() / 12 )
        RagdollNVG.Ent = ents.CreateClientside( EntList[ragdoll:GetNWInt("NVG")].className )
        RagdollNVG.DoRightClick = function()
            local ActionMenu = DermaMenu(false, RagdollPanel)
            ActionMenu:AddOption( "Drop", function()
                DropNVG()
            end)
            ActionMenu:Open()
        end
    end


    local HelmetSlot = vgui.Create( "DImage", RagdollPanel )
    HelmetSlot:SetX(NVGSlot:GetX() - NVGSlot:GetWide() - ScrH() / 50)
    HelmetSlot:SetY(NVGSlot:GetY())
    HelmetSlot:SetImage( "icon64/inventory_slot.png")
    HelmetSlot:SetSize( ScrH() / 12, ScrH() / 12 )

    if ragdoll:GetNWInt("Helmet") > 1 then
        local Helmet = vgui.Create( "DImageButton", RagdollPanel )
        Helmet:SetPos( HelmetSlot:GetPos() )
        Helmet:SetImage( EntList[ragdoll:GetNWInt("Helmet")].icon )
        Helmet:SetSize( ScrH() / 12, ScrH() / 12 )
        Helmet.Ent = ents.CreateClientside( EntList[ragdoll:GetNWInt("Helmet")].className )
        Helmet.DoRightClick = function()
            local ActionMenu = DermaMenu(false, RagdollPanel)
            ActionMenu:AddOption( "Drop", function()
                net.Start("RagdollDropRequest")
                net.WriteUInt(ragdollID, 32)
                net.WriteString( "Helmet" )
                net.WriteBool(false) -- the specified entity is a weapon
                net.WriteBool(true) -- the specified entity is bodygrouped
                net.SendToServer()
                Helmet:Remove()
            end)
            ActionMenu:Open()
        end
    end

    local GasMaskSlot = vgui.Create( "DImage", RagdollPanel )
    GasMaskSlot:SetX(NVGSlot:GetX())
    GasMaskSlot:SetY(NVGSlot:GetY() + NVGSlot:GetTall() + ScrH() / 50)
    GasMaskSlot:SetImage( "icon64/inventory_slot.png")
    GasMaskSlot:SetSize( ScrH() / 12, ScrH() / 12 )

    if ragdoll:GetNWInt("GasMask") > 1 then
        RagdollGasMask = vgui.Create( "DImageButton", RagdollPanel )
        RagdollGasMask:SetPos( GasMaskSlot:GetPos() )
        RagdollGasMask:SetImage( "icon64/gasmask.png" )
        RagdollGasMask:SetSize( ScrH() / 12, ScrH() / 12 )
        if ragdoll:GetNWInt("GasMaskSet") then
            RagdollGasMask:SetAlpha(255)
        else
            RagdollGasMask:SetAlpha(100)
        end
        RagdollGasMask.Ent = ents.CreateClientside( EntList[ragdoll:GetNWInt("GasMask")].className )
        RagdollGasMask.DoRightClick = function()
            local ActionMenu = DermaMenu(false, RagdollPanel)
            ActionMenu:AddOption( "Drop", function()
                net.Start("RagdollDropRequest")
                net.WriteUInt(ragdollID, 32)
                net.WriteString( "GasMask" )
                net.WriteBool(false) -- the specified entity is a weapon
                net.WriteBool(true) -- the specified entity is bodygrouped
                net.SendToServer()
                RagdollGasMask:Remove()
            end)
            ActionMenu:Open()
        end
    end

    local function ReloadSelectedContainer(StartingIndex)

        RagdollSelectedIcon = vgui.Create( "DImage", RagdollPanel )
        RagdollSelectedIcon:SetSize( ScrW() / 24, ScrW() / 24 )
        RagdollSelectedIcon:SetX(SelectedContainer:GetX() + SelectedContainer:GetWide() / 2 - RagdollSelectedIcon:GetWide() / 2 )
        RagdollSelectedIcon:SetY(SelectedContainer:GetY() + SelectedContainer:GetTall() / 2 - RagdollSelectedIcon:GetTall() / 2 )
        RagdollSelectedIcon:SetImage( "vgui/spawnmenu/hover.vmt" )

        RagdollInventorySlotFrame = {}
        local InventorySlot = {}
        local InventoryFrame = {}
        local Inventory = {}
        local i,j = 0,0
        if SelectedContainer.Ent.Capacity and SelectedContainer.Ent.Capacity > 0 then
            for k = 0,SelectedContainer.Ent.Capacity - 1 do
                RagdollInventorySlotFrame[k] = vgui.Create("EditablePanel", RagdollPanel)
                RagdollInventorySlotFrame[k]:SetSize( ScrH() / 12, ScrH() / 12 )
                RagdollInventorySlotFrame[k]:SetX(LauncherSlot:GetX() + j * (RagdollInventorySlotFrame[0]:GetWide() + ScrH() / 50))
                RagdollInventorySlotFrame[k]:SetY(LauncherSlot:GetY() + LauncherSlot:GetTall() + ScrH() / 50 + i * (RagdollInventorySlotFrame[0]:GetTall() + ScrH() / 50))
                InventorySlot[k] = vgui.Create( "DImage", RagdollInventorySlotFrame[k] )
                InventorySlot[k]:SetImage( "icon64/inventory_slot.png")
                InventorySlot[k]:SetSize( ScrH() / 12, ScrH() / 12 )
                if ragdoll:GetNWInt("Inventory" .. tostring(StartingIndex + k + 1)) > 1 then
                    InventoryFrame[k] = vgui.Create( "EditablePanel", RagdollInventorySlotFrame[k] )
                    InventoryFrame[k]:SetSize( ScrH() / 12, ScrH() / 12 )
                    Inventory[k] = vgui.Create( "SpawnIcon", InventoryFrame[k] )
                    Inventory[k].Ent = ents.CreateClientside(EntList[ragdoll:GetNWInt("Inventory" .. tostring(StartingIndex + k + 1))].className)
                    Inventory[k]:SetModel(Inventory[k].Ent.Model)
                    Inventory[k]:SetSize( ScrH() / 12, ScrH() / 12 )
                    if EntList[ragdoll:GetNWInt("Inventory" .. tostring(StartingIndex + k + 1))].ammoName then
                        Inventory[k].ProgressBar = vgui.Create("DProgress", InventoryFrame[k])
                        Inventory[k].ProgressBar:SetSize(Inventory[k]:GetWide(), Inventory[k]:GetTall() / 5)
                        Inventory[k].ProgressBar:SetFraction( ragdoll:GetNWInt("AmmoBox" .. tostring(StartingIndex + k + 1)) / EntList[ragdoll:GetNWInt("Inventory" .. tostring(StartingIndex + k + 1))].capacity )
                    end
                    Inventory[k].DoRightClick = function()
                        local ActionMenu = DermaMenu(false, RagdollPanel)
                        ActionMenu:AddOption( "Drop", function()
                            net.Start("RagdollDropRequest")
                            net.WriteUInt(ragdollID, 32)
                            net.WriteString( "Inventory" .. tostring(StartingIndex + k + 1) )
                            net.WriteBool(false) -- the specified entity is a weapon
                            net.WriteBool(false) -- the specified entity is bodygrouped
                            if Inventory[k].Ent.AmmoName ~= nil then
                                net.WriteUInt(ragdoll:GetNWInt("AmmoBox" .. tostring(StartingIndex + k + 1)), 9)
                            end
                            net.SendToServer()
                            InventoryFrame[k]:Remove()
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
    local RucksackSlot = vgui.Create( "DImage", RagdollPanel )
    RucksackSlot:SetX(GasMaskSlot:GetX())
    RucksackSlot:SetY(GasMaskSlot:GetY() + GasMaskSlot:GetTall() + ScrH() / 50)
    RucksackSlot:SetImage( "icon64/inventory_slot.png")
    RucksackSlot:SetSize( ScrH() / 12, ScrH() / 12 )

    if ragdoll:GetNWInt("Rucksack") > 1 then
        RagdollRucksack = vgui.Create( "DImageButton", RagdollPanel )
        RagdollRucksack:SetPos(RucksackSlot:GetPos())
        RagdollRucksack:SetImage( EntList[ragdoll:GetNWInt("Rucksack")].icon )
        RagdollRucksack:SetSize( ScrH() / 12, ScrH() / 12 )
        RagdollRucksack.Ent = ents.CreateClientside( EntList[ragdoll:GetNWInt("Rucksack")].className )
        RagdollRucksack.DoClick = function()
            if RagdollSelectedIcon then
                RagdollSelectedIcon:Remove()
                if SelectedContainer and SelectedContainer.Ent.Capacity and SelectedContainer.Ent.Capacity > 0 then
                    for k = 0,SelectedContainer.Ent.Capacity - 1 do
                        RagdollInventorySlotFrame[k]:Remove()
                    end
                end
            end
            SelectedContainer = RagdollRucksack
            ReloadSelectedContainer(10)
        end
        RagdollRucksack.DoRightClick = function()
            local ActionMenu = DermaMenu(false, RagdollPanel)
            ActionMenu:AddOption( "Drop", function()
                net.Start("RagdollDropRequest")
                net.WriteUInt(ragdollID, 32)
                net.WriteString( "Rucksack" )
                net.WriteBool(false) -- the specified entity is a weapon
                net.WriteBool(true) -- the specified entity is bodygrouped
                net.SendToServer()
                RagdollRucksack:Remove()
                if SelectedContainer == RagdollRucksack then
                    RagdollSelectedIcon:Remove()
                    for k = 0,SelectedContainer.Ent.Capacity - 1 do
                        RagdollInventorySlotFrame[k]:Remove()
                    end
                end
            end)
            ActionMenu:Open()
        end
    end

    local VestSlot = vgui.Create( "DImage", RagdollPanel )
    VestSlot:SetX(RucksackSlot:GetX() - RucksackSlot:GetWide() - ScrH() / 50)
    VestSlot:SetY(RucksackSlot:GetY())
    VestSlot:SetImage( "icon64/inventory_slot.png")
    VestSlot:SetSize( ScrH() / 12, ScrH() / 12 )

    if ragdoll:GetNWInt("Vest") > 1 then
        RagdollVest = vgui.Create( "DImageButton", RagdollPanel )
        RagdollVest:SetPos(VestSlot:GetPos())
        RagdollVest:SetImage( EntList[ragdoll:GetNWInt("Vest")].icon )
        RagdollVest:SetSize( ScrH() / 12, ScrH() / 12 )
        RagdollVest.Ent = ents.CreateClientside( EntList[ragdoll:GetNWInt("Vest")].className )
        RagdollVest.DoClick = function()
            if RagdollSelectedIcon then
                RagdollSelectedIcon:Remove()
                if SelectedContainer and SelectedContainer.Ent.Capacity and SelectedContainer.Ent.Capacity > 0 then
                    for k = 0,SelectedContainer.Ent.Capacity - 1 do
                        RagdollInventorySlotFrame[k]:Remove()
                    end
                end
            end
            SelectedContainer = RagdollVest
            ReloadSelectedContainer(0)
        end
        RagdollVest.DoRightClick = function()
            local ActionMenu = DermaMenu(false, RagdollPanel)
            ActionMenu:AddOption( "Drop", function()
                net.Start("RagdollDropRequest")
                net.WriteUInt(ragdollID, 32)
                net.WriteString( "Vest" )
                net.WriteBool(false) -- the specified entity is a weapon
                net.WriteBool(true) -- the specified entity is bodygrouped
                net.SendToServer()
                RagdollVest:Remove()
                if SelectedContainer == RagdollVest then
                    RagdollSelectedIcon:Remove()
                    for k = 0,SelectedContainer.Ent.Capacity or 1 - 1 do
                        RagdollInventorySlotFrame[k]:Remove()
                    end
                end
            end)
            ActionMenu:Open()
        end
        RagdollVest:SetDrawOnTop(true)
    end

    local JacketSlot = vgui.Create( "DImage", RagdollPanel )
    JacketSlot:SetX(VestSlot:GetX() - VestSlot:GetWide() - ScrH() / 50)
    JacketSlot:SetY(VestSlot:GetY())
    JacketSlot:SetImage( "icon64/inventory_slot.png")
    JacketSlot:SetSize( ScrH() / 12, ScrH() / 12 )

    if ragdoll:GetNWInt("Jacket") > 1 then
        RagdollJacket = vgui.Create( "DImageButton", RagdollPanel )
        RagdollJacket:SetPos(JacketSlot:GetPos())
        RagdollJacket:SetImage( EntList[ragdoll:GetNWInt("Jacket")].icon )
        RagdollJacket:SetSize( ScrH() / 12, ScrH() / 12 )
        RagdollJacket.Ent = ents.CreateClientside( EntList[ragdoll:GetNWInt("Jacket")].className )
        RagdollJacket.DoClick = function()
            if RagdollSelectedIcon then
                RagdollSelectedIcon:Remove()
                if SelectedContainer and SelectedContainer.Ent.Capacity and SelectedContainer.Ent.Capacity > 0 then
                    for k = 0,SelectedContainer.Ent.Capacity - 1 do
                        RagdollInventorySlotFrame[k]:Remove()
                    end
                end
            end
            SelectedContainer = RagdollJacket
            ReloadSelectedContainer(2)
        end
        RagdollJacket.DoRightClick = function()
            local ActionMenu = DermaMenu(false, RagdollPanel)
            ActionMenu:AddOption( "Drop", function()
                net.Start("RagdollDropRequest")
                net.WriteUInt(ragdollID, 32)
                net.WriteString( "Jacket" )
                net.WriteBool(false) -- the specified entity is a weapon
                net.WriteBool(true) -- the specified entity is bodygrouped
                net.SendToServer()
                RagdollJacket:SetImage( "vgui/null.vmt" )
                if SelectedContainer == RagdollJacket then
                    RagdollSelectedIcon:Remove()
                    for k = 0,SelectedContainer.Ent.Capacity or 1 - 1 do
                        RagdollInventorySlotFrame[k]:Remove()
                    end
                end
            end)
            ActionMenu:Open()
        end
        RagdollJacket:SetDrawOnTop(true)
    end

    local PantSlot = vgui.Create( "DImage", RagdollPanel )
    PantSlot:SetX(RucksackSlot:GetX())
    PantSlot:SetY(RucksackSlot:GetY() + RucksackSlot:GetTall() + ScrH() / 50)
    PantSlot:SetImage( "icon64/inventory_slot.png")
    PantSlot:SetSize( ScrH() / 12, ScrH() / 12 )

    if ragdoll:GetNWInt("Pant") > 1 then
        RagdollPant = vgui.Create( "DImageButton", RagdollPanel )
        RagdollPant:SetPos(PantSlot:GetPos())
        RagdollPant:SetImage( EntList[ragdoll:GetNWInt("Pant")].icon )
        RagdollPant:SetSize( ScrH() / 12, ScrH() / 12 )
        RagdollPant.Ent = ents.CreateClientside( EntList[ragdoll:GetNWInt("Pant")].className )
        RagdollPant.DoClick = function()
            if RagdollSelectedIcon then
                RagdollSelectedIcon:Remove()
                if SelectedContainer and SelectedContainer.Ent.Capacity and SelectedContainer.Ent.Capacity > 0 then
                    for k = 0,SelectedContainer.Ent.Capacity - 1 do
                        RagdollInventorySlotFrame[k]:Remove()
                    end
                end
            end
            SelectedContainer = RagdollPant
            ReloadSelectedContainer(0)
        end
        RagdollPant.DoRightClick = function()
            local ActionMenu = DermaMenu(false, RagdollPanel)
            ActionMenu:AddOption( "Drop", function()
                net.Start("RagdollDropRequest")
                net.WriteUInt(ragdollID, 32)
                net.WriteString( "Pant" )
                net.WriteBool(false) -- the specified entity is a weapon
                net.WriteBool(true) -- the specified entity is bodygrouped
                net.SendToServer()
                RagdollPant:SetImage( "vgui/null.vmt" )
                if SelectedContainer == RagdollPant then
                    RagdollSelectedIcon:Remove()
                    for k = 0,SelectedContainer.Ent.Capacity or 1 - 1 do
                        RagdollInventorySlotFrame[k]:Remove()
                    end
                end
            end)
            ActionMenu:Open()
        end
        RagdollPant:SetDrawOnTop(true)
    end

    local PrimaryWepSlot = vgui.Create( "DImage", RagdollPanel )
    PrimaryWepSlot:CenterHorizontal(0.09)
    PrimaryWepSlot:CenterVertical(0.53)
    PrimaryWepSlot:SetImage( "vgui/primary_wep_slot.png")
    PrimaryWepSlot:SetSize( ScrH() / 3, ScrH() / 9 )

    if ragdoll:GetNWInt("PrimaryWep") > 1 then
        local PrimaryWep = vgui.Create( "DImageButton", RagdollPanel )
        PrimaryWep:SetImage( EntList[ragdoll:GetNWInt("PrimaryWep")].icon )
        PrimaryWep:SetSize( ScrH() / 4.5, ScrH() / 9 )
        PrimaryWep:SetX(PrimaryWepSlot:GetX() + PrimaryWepSlot:GetWide() / 2 - PrimaryWep:GetWide() / 2 )
        PrimaryWep:SetY(PrimaryWepSlot:GetY() + PrimaryWepSlot:GetTall() / 2 - PrimaryWep:GetTall() / 2 )
        PrimaryWep.DoRightClick = function()
            local ActionMenu = DermaMenu(false, RagdollPanel)
            ActionMenu:AddOption( "Drop", function()
                net.Start("RagdollDropRequest")
                net.WriteUInt(ragdollID, 32)
                net.WriteString( "PrimaryWep" )
                net.WriteBool(true) -- the specified entity is a weapon
                net.WriteBool(false) -- the specified entity is bodygrouped
                net.SendToServer()
                PrimaryWep:Remove()
            end)
            ActionMenu:Open()
        end
    end

    local SecondaryWepSlot = vgui.Create( "DImage", RagdollPanel )
    SecondaryWepSlot:SetX(PrimaryWepSlot:GetX() + PrimaryWepSlot:GetWide() + ScrH() / 50)
    SecondaryWepSlot:SetY(PrimaryWepSlot:GetY())
    SecondaryWepSlot:SetImage( "icon64/inventory_slot.png")
    SecondaryWepSlot:SetSize( ScrH() / 7, ScrH() / 9 )

    if ragdoll:GetNWInt("SecondaryWep") > 1 then
        local SecondaryWep = vgui.Create( "DImageButton", RagdollPanel )
        SecondaryWep:SetImage( EntList[ragdoll:GetNWInt("SecondaryWep")].icon )
        SecondaryWep:SetSize( ScrH() / 9, ScrH() / 18 )
        SecondaryWep:SetX(SecondaryWepSlot:GetX() + SecondaryWepSlot:GetWide() / 2 - SecondaryWep:GetWide() / 2 )
        SecondaryWep:SetY(SecondaryWepSlot:GetY() + SecondaryWepSlot:GetTall() / 2 - SecondaryWep:GetTall() / 2 )
        SecondaryWep.DoRightClick = function()
            local ActionMenu = DermaMenu(false, RagdollPanel)
            ActionMenu:AddOption( "Drop", function()
                net.Start("RagdollDropRequest")
                net.WriteUInt(ragdollID, 32)
                net.WriteString( "SecondaryWep" )
                net.WriteBool(true) -- the specified entity is a weapon
                net.WriteBool(false) -- the specified entity is bodygrouped
                net.SendToServer()
                SecondaryWep:Remove()
            end)
            ActionMenu:Open()
        end
    end

    LauncherSlot = vgui.Create( "DImage", RagdollPanel )
    LauncherSlot:SetX(PrimaryWepSlot:GetX())
    LauncherSlot:SetY(PrimaryWepSlot:GetY() + PrimaryWepSlot:GetTall() + ScrH() / 50)
    LauncherSlot:SetImage( "vgui/primary_wep_slot.png")
    LauncherSlot:SetSize( ScrW() / 3.61, ScrW() / 15 )

    if ragdoll:GetNWInt("Launcher") > 1 then
        local Launcher = vgui.Create( "DImageButton", RagdollPanel )
        Launcher:SetImage( EntList[ragdoll:GetNWInt("Launcher")].icon )
        Launcher:SetSize( ScrW() / 7.5, ScrW() / 15 )
        Launcher:SetX(LauncherSlot:GetX() + LauncherSlot:GetWide() / 2 - Launcher:GetWide() / 2 )
        Launcher:SetY(LauncherSlot:GetY() + LauncherSlot:GetTall() / 2 - Launcher:GetTall() / 2 )
        Launcher.DoRightClick = function()
            local ActionMenu = DermaMenu(false, RagdollPanel)
            ActionMenu:AddOption( "Drop", function()
                net.Start("RagdollDropRequest")
                net.WriteUInt(ragdollID, 32)
                net.WriteString( "Launcher" )
                net.WriteBool(true) -- the specified entity is a weapon
                net.WriteBool(false) -- the specified entity is bodygrouped
                net.SendToServer()
                Launcher:Remove()
            end)
            ActionMenu:Open()
        end
    end
    if RagdollRucksack and RagdollRucksack:IsValid() then
        SelectedContainer = RagdollRucksack
        ReloadSelectedContainer(10)
    elseif RagdollVest and RagdollVest:IsValid() then
        SelectedContainer = RagdollVest
        ReloadSelectedContainer(5)
    elseif RagdollJacket and RagdollJacket:IsValid() then
        SelectedContainer = RagdollJacket
        ReloadSelectedContainer(2)
    elseif RagdollPant and RagdollPant:IsValid() then
        SelectedContainer = RagdollPant
        ReloadSelectedContainer(0)
    else
        SelectedContainer = nil
    end
end