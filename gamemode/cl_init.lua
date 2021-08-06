include( "shared.lua" )
include( "panel/mvsa_panel.lua" )
include( "config.lua" )

local function character_creation( ply )
    ply = ply or LocalPlayer()
    CharacPanel = vgui.Create("MVSAPanel")

    local CharacCreationLabel = vgui.Create( "DLabel", CharacPanel )
    CharacCreationLabel:SetFont( "DermaLarge" )
    CharacCreationLabel:SetText( "Character creation" )
    CharacCreationLabel:SizeToContents()
    CharacCreationLabel:CenterHorizontal( 0.5 )
    CharacCreationLabel:CenterVertical( 0.05 )

    local ChooseFactionLabel = vgui.Create( "DLabel", CharacPanel )
    ChooseFactionLabel:SetFont( "DermaLarge" )
    ChooseFactionLabel:SetText( "Choose your faction" )
    ChooseFactionLabel:SizeToContents()
    ChooseFactionLabel:SetPos( ScrW() / 2 - ChooseFactionLabel:GetWide() / 2, 200 )

    local CloseLabel = vgui.Create( "DLabel", CharacPanel )
    CloseLabel:SetFont( "DermaLarge" )
    CloseLabel:SetText( "CLOSE" )
    CloseLabel:SizeToContents()
    CloseLabel:Dock(BOTTOM)
    CloseLabel:SetMouseInputEnabled( true )
    function CloseLabel:DoClick()
        CharacPanel:SetVisible( false )
    end

    local USMCButton = vgui.Create( "DImageButton", CharacPanel )
    USMCButton:SetImage( "gui/faction/usmc.png" )
    USMCButton:SizeToContents()
    USMCButton:SetPos( ScrW() / 2 - USMCButton:GetWide() - 100, ScrH() / 2 - 150 )

    local SurvivorButton = vgui.Create( "DImageButton", CharacPanel )
    SurvivorButton:SetImage( "gui/faction/survivor.png" )
    SurvivorButton:SizeToContents()
    SurvivorButton:SetPos( ScrW() / 2 + 100, ScrH() / 2 - 150 )

    local function DrawCharacPerso()

        RPName = MVSA.FirstName[math.random(#MVSA.FirstName)] .. " " .. MVSA.LastName[math.random(#MVSA.LastName)]
        Size = math.random(MVSA.minSize, MVSA.maxSize)

        local RPNameEntry = vgui.Create("DTextEntry", CharacPanel)
        RPNameEntry:SetSize( 200, 35 )
        RPNameEntry:SetPlaceholderText( RPName )
        RPNameEntry:SetPos(ScrW() / 2 - 100, ScrH() / 10 + 20)
        RPNameEntry.OnLoseFocus = function( self )
            RPName = self:GetValue()
        end

        local GenerateButton = vgui.Create( "DButton", CharacPanel )
        GenerateButton:SetText( "Generate" )
        GenerateButton:SetSize( 100, 30)
        GenerateButton:SetPos( ScrW() / 2 - 100 + RPNameEntry:GetWide() + 20, ScrH() / 10 + 20 )
        GenerateButton.DoClick = function()
            RPName = MVSA.FirstName[math.random(#MVSA.FirstName)] .. " " .. MVSA.LastName[math.random(#MVSA.LastName)]
            RPNameEntry:SetPlaceholderText( RPName )
        end

        local Model = vgui.Create( "DModelPanel" , CharacPanel )
        Model:SetSize(ScrW() * 0.5, ScrH() * 0.8)
        Model:SetPos( 0.1 * ScrW(), 1.6 * ScrH() / 10 )
        ModelIndex = math.random( #MVSA[Faction] )
        Model:SetModel( MVSA[Faction][ModelIndex][1] )
        Model.Entity:SetModelScale(Size / 180)

        function Model:LayoutEntity( Entity ) return end	-- Disable cam rotation

        local headpos = Model.Entity:GetBonePosition(Model.Entity:LookupBone("ValveBiped.Bip01_Head1"))
        Model.Entity:SetEyeTarget(headpos-Vector(-15, 0, 0))

        SpecPanel = vgui.Create( "EditablePanel", CharacPanel )
        SpecPanel:SetPos( ScrW() / 2, 4 * ScrH() / 10 )
        SpecPanel:SetSize( ScrW() / 3, Model:GetTall() )

        local function LoadBodygroup()
            SizeSlider = vgui.Create( "DNumSlider", ScrollPanel )
            SizeSlider:Dock( TOP )				-- Set the position
            SizeSlider:DockMargin(0, 0, 0, 0)
            SizeSlider:SetSize( 300, 30 )			-- Set the size
            SizeSlider:SetText( "Size(cm)" )	-- Set the text above the slider
            SizeSlider:SetMin( MVSA.minSize )				 	-- Set the minimum number you can slide to
            SizeSlider:SetMax( MVSA.maxSize )
            SizeSlider:SetDecimals( 0 )				-- Decimal places - zero for whole number
            SizeSlider:SetValue(math.random(MVSA.minSize, MVSA.maxSize))
            Size = SizeSlider:GetValue()
            Model.Entity:SetModelScale(Size / 180)
            SizeSlider.OnValueChanged = function( self )
                -- Called when the slider value changes
                Size = math.Round(self:GetValue(), 0)
                Model.Entity:SetModelScale(Size / 180)
            end
            local skinCount = #MVSA[Faction][ModelIndex][2]
            SkinSlider = vgui.Create( "DNumSlider", ScrollPanel )
            SkinSlider:Dock( TOP )				-- Set the position
            SkinSlider:DockMargin(0, 0, 0, 0)
            SkinSlider:SetSize( 300, 30 )			-- Set the size
            SkinSlider:SetText( "Skin" )	-- Set the text above the slider
            SkinSlider:SetMin( 1 )				 	-- Set the minimum number you can slide to
            SkinSlider:SetMax(skinCount)
            SkinSlider:SetDecimals( 0 )				-- Decimal places - zero for whole number
            SkinSlider:SetValue(math.random(1, skinCount))
            Skin = MVSA[Faction][ModelIndex][2][SkinSlider:GetValue()]
            Model.Entity:SetSkin(Skin)
            SkinSlider.OnValueChanged = function( self )
                -- Called when the slider value changes
                local val = math.Round(self:GetValue(), 0)
                Skin = MVSA[Faction][ModelIndex][2][val]
                Model.Entity:SetSkin(Skin)
            end

            for i = 1, Model.Entity:GetNumBodyGroups() do
                if istable(MVSA[Faction][ModelIndex][3][i]) then
                    local lentgh = #MVSA[Faction][ModelIndex][3][i]
                    BodygroupSlider = vgui.Create( "DNumSlider", ScrollPanel )
                    BodygroupSlider:Dock( TOP )				-- Set the position
                    BodygroupSlider:DockMargin(0, 0, 0, 0)
                    BodygroupSlider:SetSize( 300, 30 )			-- Set the size
                    BodygroupSlider:SetText( Model.Entity:GetBodygroupName(i - 1) )	-- Set the text above the slider
                    BodygroupSlider:SetMin( 1 )				 	-- Set the minimum number you can slide to
                    BodygroupSlider:SetMax(lentgh)
                    BodygroupSlider:SetDecimals( 0 )				-- Decimal places - zero for whole number
                    BodygroupSlider:SetValue(math.random(1, lentgh))
                    Model.Entity:SetBodygroup(i - 1, MVSA[Faction][ModelIndex][3][i][BodygroupSlider:GetValue()])
                    BodygroupSlider.OnValueChanged = function( self )
                        -- Called when the slider value changes
                        local val = math.Round(self:GetValue(), 0)
                        Model.Entity:SetBodygroup(i - 1, MVSA[Faction][ModelIndex][3][i][val])
                    end
                else
                    Model.Entity:SetBodygroup(i - 1, MVSA[Faction][ModelIndex][3][i])
                end
            end

        end

        local modelCount = #MVSA[Faction]
        ModelSlider = vgui.Create( "DNumSlider", SpecPanel )
        ModelSlider:Dock( TOP )
        ModelSlider:DockMargin(0, 0, 0, 0)
        ModelSlider:SetSize( 300, 30 )
        ModelSlider:SetText( "Model" )
        ModelSlider:SetMin( 1 )
        ModelSlider:SetMax( modelCount )
        ModelSlider:SetDecimals( 0 )
        ModelSlider:SetValue(ModelIndex)
        Model.Entity:SetModelScale(Size / 180)

        local function LoadModel()
            if ScrollPanel != nil then ScrollPanel:Remove() end

            ScrollPanel = vgui.Create( "DScrollPanel", SpecPanel )
            ScrollPanel:Dock(TOP)
            ScrollPanel:SetSize( Model:GetWide(), Model:GetTall() - 30 )

            Model:SetModel( MVSA[Faction][ModelIndex][1] )
            Model.Entity:SetModelScale(Size / 180)
            Model.Entity:SetEyeTarget(headpos-Vector(-15, 0, 0))

            LoadBodygroup()
        end
        LoadModel()

        ModelSlider.OnValueChanged = function( self )
            local val = math.Round(self:GetValue(), 0)
            if val - ModelIndex != 0 then
                ModelIndex = val
                LoadModel()
            end
        end

        local DoneButton = vgui.Create( "DButton", CharacPanel )
        DoneButton:SetText( "Done" )
        DoneButton:SetSize( 100, 30)
        DoneButton:SetPos( ScrW() / 2 - 50, 9 * ScrH() / 10 )
        DoneButton.DoClick = function()
            net.Start( "mvsa_character_information" )
            net.WriteBit( Faction == "Survivor" )
            net.WriteString( RPName )
            net.WriteUInt( ModelIndex, 5 )
            net.WriteUInt( Size, 8 )
            net.WriteUInt( Skin, 5 )
            local BodyGroups = tostring(Model.Entity:GetBodygroup(0))
            for i = 1, Model.Entity:GetNumBodyGroups() - 1 do
                BodyGroups = BodyGroups .. "," .. tostring(Model.Entity:GetBodygroup(i))
            end
            net.WriteString(BodyGroups)
            net.SendToServer()

            CharacPanel:Remove()
        end
    end

    USMCButton.DoClick = function()
        Faction = "USMC"
        ChooseFactionLabel:Remove()
        USMCButton:Remove()
        SurvivorButton:Remove()
        DrawCharacPerso()
    end

    SurvivorButton.DoClick = function()
        Faction = "Survivor"
        ChooseFactionLabel:Remove()
        USMCButton:Remove()
        SurvivorButton:Remove()
        DrawCharacPerso()
    end
end

net.Receive( "mvsa_character_creation", function()
    character_creation()
end)

net.Receive( "mvsa_character_selection", function( len, ply )
    local SelectionPanel = vgui.Create( "MVSAPanel" )

    local SelectionPanelLabel = vgui.Create( "DLabel", SelectionPanel )
    SelectionPanelLabel:SetFont( "DermaLarge" )
    SelectionPanelLabel:SetText( "Character selection" )
    SelectionPanelLabel:SizeToContents()
    SelectionPanelLabel:CenterHorizontal( 0.5 )
    SelectionPanelLabel:CenterVertical( 0.05 )

    local CloseLabel = vgui.Create( "DLabel", SelectionPanel )
    CloseLabel:SetFont( "DermaLarge" )
    CloseLabel:SetText( "CLOSE" )
    CloseLabel:SizeToContents()
    CloseLabel:Dock(BOTTOM)
    CloseLabel:SetMouseInputEnabled( true )
    function CloseLabel:DoClick()
        SelectionPanel:SetVisible( false )
    end

    local Character = {}
    local namesCount = net.ReadUInt( 5 )
    for i = 1, namesCount do
        Character[i] = {}
        Character[i]["Faction"] = net.ReadString()
        if Character[i]["Faction"] == "1" then
            Character[i]["Faction"] = "Survivor"
        else
            Character[i]["Faction"] = "USMC"
        end
        Character[i]["RPName"] = net.ReadString()
        Character[i]["ModelIndex"] = tonumber(net.ReadString())
        Character[i]["Size"] = net.ReadString()
        Character[i]["Skin"] = tonumber(net.ReadString())
        Character[i]["BodyGroups"] = net.ReadString()
        Character[i]["BodyGroups"] = string.Split(Character[i]["BodyGroups"], ",")
    end

    local index = 1
    local rpname = vgui.Create("DLabel", SelectionPanel)
    rpname:SetText( Character[index]["RPName"] )
    rpname:SetFont("Trebuchet24")
    rpname:SizeToContents()
    rpname:SetPos( ScrW() / 2 - rpname:GetWide() / 2, ScrH() / 10 + 50 )

    local AdjustableModelPanel = vgui.Create( "DModelPanel", SelectionPanel )
    AdjustableModelPanel:SetSize( ScrW() / 2, 0.8 * ScrH() )
    AdjustableModelPanel:SetPos( ScrW() / 2 - AdjustableModelPanel:GetWide() / 2, ScrH() / 10 + 100 )
    local function LoadCharacter()
        rpname:SetText( Character[index]["RPName"] )
        rpname:SetFont("Trebuchet24")
        rpname:SizeToContents()
        rpname:SetPos( ScrW() / 2 - rpname:GetWide() / 2, ScrH() / 10 + 50 )
        AdjustableModelPanel:SetModel( MVSA[Character[index]["Faction"]][Character[index]["ModelIndex"]][1] )
        for k,v in pairs(Character[index]["BodyGroups"]) do
            AdjustableModelPanel.Entity:SetBodygroup( k - 1, v )
        end
        AdjustableModelPanel.Entity:SetModelScale(tonumber(Character[index]["Size"]) / 180)
        AdjustableModelPanel.Entity:SetSkin( Character[index]["Skin"] )
    end
    LoadCharacter()

    local SelectButton = vgui.Create( "DLabel", SelectionPanel )
    SelectButton:SetFont( "DermaLarge" )
    SelectButton:SetText( "SELECT" )
    SelectButton:SizeToContents()
    SelectButton:Dock(LEFT)
    SelectButton:DockMargin( 200, ScrH() - ScrH() / 10, 0, 0)
    SelectButton:SetMouseInputEnabled( true )
    function SelectButton:DoClick()
        net.Start("mvsa_character_selected")
        net.WriteString(Character[index]["RPName"])
        net.SendToServer()
        SelectionPanel:Remove()
    end

    local DeleteButton = vgui.Create( "DLabel", SelectionPanel )
    DeleteButton:SetFont( "DermaLarge" )
    DeleteButton:SetText( "DELETE" )
    DeleteButton:SizeToContents()
    DeleteButton:Dock(RIGHT)
    DeleteButton:DockMargin( 0, ScrH() - ScrH() / 10, 100, 0)
    DeleteButton:SetMouseInputEnabled( true )
    function DeleteButton:DoClick()
        local ConfirmationPanel = vgui.Create("DFrame", SelectionPanel)
        ConfirmationPanel:Center()
        ConfirmationPanel:SetTitle("Warning")
        ConfirmationPanel:SetSize( 400, 200 )

        local ConfirmationLabel = vgui.Create("DLabel", ConfirmationPanel)
        ConfirmationLabel:SetText( "Your character will be removed permanently \n Are you sure?" )
        ConfirmationLabel:SizeToContents()
        ConfirmationLabel:Center()

        local YesButton = vgui.Create( "DButton", ConfirmationPanel )
        YesButton:SetText("Yes")
        YesButton:SetSize(60,30)
        YesButton:SetPos(375 - 60,150)
        YesButton.DoClick = function()
            net.Start("mvsa_character_deletion")
            net.WriteString(Character[index]["RPName"])
            net.SendToServer()
            table.remove(Character, index)
            namesCount = namesCount - 1
            index = index - 1
            rpname:SetText( Character[index]["RPName"] )
            rpname:SetFont("Trebuchet24")
            rpname:SizeToContents()
            rpname:SetPos( ScrW() / 2 - rpname:GetWide() / 2, ScrH() / 10 + 50 )
            ConfirmationPanel:Remove()
        end

        local NoButton = vgui.Create( "DButton", ConfirmationPanel )
        NoButton:SetText("No")
        NoButton:SetSize(60,30)
        NoButton:SetPos(25,150)
        NoButton.DoClick = function()
            ConfirmationPanel:Remove()
        end
    end

    local SeparationLabel = vgui.Create( "DLabel", SelectionPanel )
    SeparationLabel:SetFont( "DermaLarge" )
    SeparationLabel:SetText( " | " )
    SeparationLabel:SizeToContents()
    SeparationLabel:Dock(RIGHT)
    SeparationLabel:DockMargin( 0, ScrH() - ScrH() / 10, 0, 0)

    local NewButton = vgui.Create( "DLabel", SelectionPanel )
    NewButton:SetFont( "DermaLarge" )
    NewButton:SetText( "NEW" )
    NewButton:SizeToContents()
    NewButton:Dock(RIGHT)
    NewButton:DockMargin( 0, ScrH() - ScrH() / 10, 0, 0)
    NewButton:SetMouseInputEnabled( true )
    function NewButton:DoClick()
        SelectionPanel:Remove()
        character_creation( ply )
    end

    if namesCount > 1 then
        local LeftArrow = vgui.Create( "DImageButton", SelectionPanel )
        LeftArrow:SetSize( 16, 32)
        LeftArrow:SetImage( "icon32/mvsa_arrow_left.png" )
        LeftArrow:SetPos( AdjustableModelPanel:GetX() - 16, AdjustableModelPanel:GetY() + AdjustableModelPanel:GetTall() / 2 )
        LeftArrow.DoClick = function()
            if index > 1 then
                index = index - 1
                LoadCharacter()
            else
                index = namesCount
                LoadCharacter()
            end
        end

        local RightArrow = vgui.Create( "DImageButton", SelectionPanel )
        RightArrow:SetSize( 16, 32)
        RightArrow:SetImage( "icon32/mvsa_arrow_right.png" )
        RightArrow:SetPos( AdjustableModelPanel:GetX() + AdjustableModelPanel:GetWide(), AdjustableModelPanel:GetY() + AdjustableModelPanel:GetTall() / 2 )
        RightArrow.DoClick = function()
            if index < namesCount then
                index = index + 1
                LoadCharacter()
            else
                index = 1
                LoadCharacter()
            end
        end
    end
end)

function GM:PostDrawViewModel(vm, ply, weapon)
    if weapon.UseHands or not weapon:IsScripted() then
        local hands = LocalPlayer():GetHands()

        if IsValid(hands) then
            hands:DrawModel()
        end
    end
end