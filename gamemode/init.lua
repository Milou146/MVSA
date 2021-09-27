AddCSLuaFile("cl_init.lua")
AddCSLuaFile("cl_inventory.lua")
AddCSLuaFile("cl_gasmask.lua")
AddCSLuaFile("cl_hud.lua")
AddCSLuaFile("cl_nvg.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("sh_config.lua")
AddCSLuaFile("sh_gasmask.lua")
AddCSLuaFile("panel/mvsa_panel.lua")

include("sv_commands.lua")
include("sv_gasmask.lua")
include("sv_npc_spawn_system.lua")
include("sv_loot_system.lua")
include("sv_autocleanup.lua")
include("shared.lua")

util.AddNetworkString("CharacterCreation")
util.AddNetworkString("DeleteCharacter")
util.AddNetworkString("CharacterSelection")
util.AddNetworkString("CharacterSelected")
util.AddNetworkString("CharacterInformation")
util.AddNetworkString("DropRequest")
util.AddNetworkString("RagdollDropRequest")
util.AddNetworkString("UseRequest")
util.AddNetworkString("NVGPutOn")
util.AddNetworkString("NVGPutOff")
util.AddNetworkString("RagdollLooting")

sql.Query("CREATE TABLE IF NOT EXISTS mvsa_characters( SteamID64 BIGINT NOT NULL, Faction BOOL, RPName VARCHAR(45), ModelIndex TINYINT, Size SMALLINT NOT NULL, Skin TINYINT, BodyGroups VARCHAR(60), PrimaryWep TINYINT, PrimaryWepAmmo TINYINT, SecondaryWep TINYINT, SecondaryWepAmmo TINYINT, Launcher TINYINT, LauncherAmmo TINYINT, Pant TINYINT, Jacket TINYINT, Vest TINYINT, VestArmor TINYINT, Rucksack TINYINT, GasMask TINYINT, Helmet TINYINT, HelmetArmor TINYINT, NVG TINYINT, Inventory VARCHAR(60), AmmoBoxes VARCHAR(120) )")

host_timescale = game.GetTimeScale()

function SaveInventoryData(ply)
    local Inventory = {}
    for k = 1,20 do
        Inventory[k] = ply:GetNWInt("Inventory" .. tostring(k))
    end
    Inventory = table.concat(Inventory, ",")
    sql.Query("UPDATE mvsa_characters SET Inventory = '" .. Inventory .. "' WHERE SteamID64 = " .. tostring(ply:SteamID64()) .. " AND RPName = " .. "'" .. ply.RPName .. "'")
end

function SaveBodyGroupsData(ply)
    local BodyGroups = tostring(ply:GetBodygroup(0))
    for k = 1,ply:GetNumBodyGroups() - 1 do
        BodyGroups = BodyGroups .. "," .. tostring(ply:GetBodygroup(k))
    end
    sql.Query("UPDATE mvsa_characters SET BodyGroups = '" .. BodyGroups .. "' WHERE SteamID64 = " .. tostring(ply:SteamID64()) .. " AND RPName = " .. "'" .. ply.RPName .. "'")
end

function PickupAmmoBox(ply, ent)
    local taken = false
    for k = 1,20 do
        if ply:GetNWInt("Inventory" .. tostring(k)) == ent.ID and ply:GetNWInt("AmmoBox" .. tostring(k)) < EntList[ent.ID].capacity and ent.AmmoCount > 0 then
            local temp = EntList[ent.ID].capacity - ply:GetNWInt("AmmoBox" .. tostring(k))
            ply:SetNWInt("AmmoBox" .. tostring(k), ply:GetNWInt("AmmoBox" .. tostring(k)) + ent.AmmoCount)
            if ply:GetNWInt("AmmoBox" .. tostring(k)) > EntList[ent.ID].capacity then
                ply:GiveAmmo( temp, ent.AmmoName )
                ent.AmmoCount = ply:GetNWInt("AmmoBox" .. tostring(k)) - EntList[ent.ID].capacity
                ply:SetNWInt("AmmoBox" .. tostring(k), EntList[ent.ID].capacity)
            else
                ply:GiveAmmo( ent.AmmoCount, ent.AmmoName )
            end
        end
        if ply:GetNWInt("Inventory" .. tostring(k)) == 1 and ent.AmmoCount > 0 then
            ply:GiveAmmo( ent.AmmoCount, ent.AmmoName )
            ply:SetNWInt( "Inventory" .. tostring(k), ent.ID )
            ply:SetNWInt( "AmmoBox" .. tostring(k), ent.AmmoCount )
            taken = true
            break
        end
    end
    if taken then
        SaveInventoryData(ply)
        ent:Remove()
        LootCount = LootCount - 1
    elseif CurTime() > ent.Delay then
        ent.Delay = CurTime() + 2
        ply:ChatPrint("You are full!")
    end
end

function PickupContainer( ply, ent )
    ply:SetNWInt( ent.Category, ent.ID )
    sql.Query("UPDATE mvsa_characters SET " .. ent.Category .. " = " .. tostring(ent.ID) .. " WHERE SteamID64 = " .. tostring(ply:SteamID64()) .. " AND RPName = " .. "'" .. ply.RPName .. "'")
    ply:SetBodygroup(ent.BodyGroup[ply:GetNWString("Faction")][ply:GetNWInt("ModelIndex")][1], ent.BodyGroup[ply:GetNWString("Faction")][ply:GetNWInt("ModelIndex")][2])
    SaveBodyGroupsData(ply)
    local Inventory = {}
    for k = 1,20 do
        Inventory[k] = ply:GetNWInt("Inventory" .. tostring(k))
    end
    for k = ent.StartingIndex ,ent.StartingIndex + ent.Capacity - 1 do
        Inventory[k] = ent["Slot" .. tostring(k)]
        ply:SetNWInt("Inventory" .. tostring(k), ent["Slot" .. tostring(k)])
        if EntList[ent["Slot" .. tostring(k)]].ammoName then
            ply:GiveAmmo( ent["Slot" .. tostring(k) .. "AmmoCount"], EntList[ent["Slot" .. tostring(k)]].ammoName )
            ply:SetNWInt("AmmoBox" .. tostring(k), ent["Slot" .. tostring(k) .. "AmmoCount"])
        end
    end
    Inventory = table.concat(Inventory, ",")
    sql.Query("UPDATE mvsa_characters SET Inventory = '" .. Inventory .. "' WHERE SteamID64 = " .. tostring(ply:SteamID64()) .. " AND RPName = " .. "'" .. ply.RPName .. "'")
    ent:Remove()
end

function PickupWep(ply, ent)
    local wep = ents.Create( ent.WepName )
    wep.Primary.DefaultClip = wep.Primary.ClipSize
    wep.Primary.Ammo = ent.Ammo
    ply:PickupWeapon(wep)
    wep:SetClip1( ent.PreviousMag or wep.Primary.ClipSize )
    ply:SetNWInt( ent.Category, ent.ID )
    sql.Query("UPDATE mvsa_characters SET " .. ent.Category .. " = " .. tostring(ent.ID) .. " WHERE SteamID64 = " .. tostring(ply:SteamID64()) .. " AND RPName = " .. "'" .. ply.RPName .. "'")
    ent:Remove()
end

local function CheckData(ply)
    local data = sql.Query(" SELECT * FROM mvsa_characters WHERE SteamID64 = " .. tostring(ply:SteamID64()))

    if not data then
        net.Start("CharacterCreation")
        net.Send(ply)
    else
        net.Start("CharacterSelection")
        net.WriteUInt(#data, 5)

        for k, v in pairs(data) do
            net.WriteUInt(tonumber(v["Faction"]), 1)
            net.WriteString(v["RPName"])
            net.WriteUInt(tonumber(v["ModelIndex"]), 5)
            net.WriteUInt(tonumber(v["Size"]), 8)
            net.WriteUInt(tonumber(v["Skin"]), 5)
            net.WriteString(v["BodyGroups"])
        end

        net.Send(ply)
    end
end

function RunEquipment(ply)

    if ply:GetNWInt("PrimaryWep") > 1 then
        local ent = ents.Create(EntList[ply:GetNWInt("PrimaryWep")].wep)
        ent.Primary.DefaultClip = 0
        ent.Primary.Ammo = EntList[ply:GetNWInt("PrimaryWep")].ammo
        ply:PickupWeapon(ent)
        ent:SetClip1( ply.PrimaryWepAmmo )
    end
    if ply:GetNWInt("SecondaryWep") > 1 then
        local ent = ents.Create(EntList[ply:GetNWInt("SecondaryWep")].wep)
        ent.Primary.DefaultClip = 0
        ent.Primary.Ammo = EntList[ply:GetNWInt("SecondaryWep")].ammo
        ply:PickupWeapon(ent)
        ent:SetClip1( ply.SecondaryWepAmmo )
    end
    if ply:GetNWInt("Launcher") > 1 then
        local ent = ents.Create(EntList[ply:GetNWInt("Launcher")].wep)
        ent.Primary.DefaultClip = 0
        ent.Primary.Ammo = EntList[ply:GetNWInt("Launcher")].ammo
        ply:PickupWeapon(ent)
        ent:SetClip1( ply.LauncherAmmo )
    end
    for k = 1, 20 do
        if EntList[ply:GetNWInt("Inventory" .. tostring(k))].ammoName then
            ply:GiveAmmo(ply:GetNWInt("AmmoBox" .. tostring(k)), EntList[ply:GetNWInt("Inventory" .. tostring(k))].ammoName, true)
        elseif EntList[ply:GetNWInt("Inventory" .. tostring(k))].wep then
            ply:Give(EntList[ply:GetNWInt("Inventory" .. tostring(k))].wep)
        end
    end
end

function GM:PlayerInitialSpawn(ply, transition)
    player_manager.SetPlayerClass(ply, "player_spectator")
    ply:AllowFlashlight(true)
end

function GM:PlayerSpawn(ply, transition)
    ply:SetShouldServerRagdoll( true )
    if player_manager.GetPlayerClass(ply) == "player_spectator" then
        local view_ent = ents.FindByName("spectator_view")[1]
        ply:SetViewEntity(view_ent)
        CheckData(ply)
    else
        ply:SetViewEntity(ply)
        ply:SetModel(PlayerModels[ply:GetNWString("Faction")][ply:GetNWInt("ModelIndex")].model)
        ply:SetModelScale(ply:GetNWInt("Size") / 180, 0)
        ply:SetSkin(ply:GetNWInt("Skin"))

        for k, v in pairs(ply.BodyGroups) do
            ply:SetBodygroup(k - 1, v)
        end

        ply:SetupHands() -- Create the hands and call GM:PlayerSetHandsModel
        player_manager.RunClass( ply, "Loadout" )
    end
end

net.Receive("CharacterInformation", function(len, ply)
    ply.Faction = net.ReadBit()
    ply.RPName = net.ReadString()
    ply:SetNWInt( "ModelIndex", net.ReadUInt(5) )
    ply:SetNWInt( "Size", net.ReadUInt(8))
    ply:SetNWInt( "Skin", net.ReadUInt(5))
    ply:SetNWInt("GasMask", 1)
    ply.BodyGroups = net.ReadString()
    ply:SetNWBool( "GasMaskSet", false )
    ply:SetNWInt( "PrimaryWep", 1 )
    ply:SetNWInt( "SecondaryWep", 1 )
    ply:SetNWInt( "Launcher", 1 )
    ply:SetNWInt( "Pant", 1 )
    ply:SetNWInt( "Jacket", 1 )
    ply:SetNWInt( "Vest", 1 )
    ply:SetNWInt( "VestArmor", 0 )
    ply:SetNWInt( "Rucksack", 1 )
    ply:SetNWInt( "GasMask", 1 )
    ply:SetNWInt( "Helmet", 1 )
    ply:SetNWInt( "HelmetArmor", 0 )
    ply:SetNWInt( "NVG", 1 )

    for k = 1,20 do
        ply:SetNWInt( "Inventory" .. tostring(k), 0 )
        ply:SetNWInt( "AmmoBox" .. tostring(k), 0 )
    end

    sql.Query("INSERT INTO mvsa_characters VALUES( " .. ply:SteamID64() .. ", " .. tostring(ply.Faction) .. ", " .. SQLStr(ply.RPName) .. ", " .. tostring(ply:GetNWInt("ModelIndex")) .. ", " .. tostring(ply:GetNWInt("Size")) .. ", " .. tostring(ply:GetNWInt("Skin")) .. ", '" .. ply.BodyGroups .. "', 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, '0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0', '0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0')")
    ply.BodyGroups = string.Split(ply.BodyGroups, ",")

    if ply.Faction == 1 then
        ply:SetNWString("Faction", "Survivor")
    else
        ply:SetNWString("Faction", "USMC")
    end
    player_manager.SetPlayerClass(ply, "player_" .. string.lower(ply:GetNWString("Faction")))
    ply:Spawn()

    RunEquipment(ply)
end)

net.Receive("DeleteCharacter", function(len, ply)
    local rpname = net.ReadString()
    sql.Query("DELETE FROM mvsa_characters WHERE SteamID64 = " .. tostring(ply:SteamID64()) .. " AND RPName = " .. "'" .. rpname .. "'")
end)

net.Receive("CharacterSelected", function(len, ply)
    ply.RPName = net.ReadString()
    local Character = sql.QueryRow("SELECT * FROM mvsa_characters WHERE SteamID64 = " .. tostring(ply:SteamID64()) .. " AND RPName = " .. "'" .. ply.RPName .. "'")

    if Character.Faction == "1" then
        Character.Faction = "Survivor"
    else
        Character.Faction = "USMC"
    end

    ply:SetNWString("Faction", Character.Faction)
    ply:SetNWInt("ModelIndex", tonumber(Character.ModelIndex))
    ply:SetNWInt("Size", tonumber(Character.Size))
    ply:SetNWInt("Skin", tonumber(Character.Skin))
    ply.Size = tonumber(Character.Size)
    ply.Skin = tonumber(Character.Skin)
    ply.BodyGroups = string.Split(Character.BodyGroups, ",")
    ply:SetNWBool( "GasMaskSet", false )
    ply:SetNWInt( "PrimaryWep", tonumber(Character.PrimaryWep) )
    ply.PrimaryWepAmmo = tonumber(Character.PrimaryWepAmmo)
    ply:SetNWInt( "SecondaryWep", tonumber(Character.SecondaryWep) )
    ply.SecondaryWepAmmo = tonumber(Character.SecondaryWepAmmo)
    ply:SetNWInt( "Launcher", tonumber(Character.Launcher) )
    ply.LauncherAmmo = tonumber(Character.LauncherAmmo)
    ply:SetNWInt( "Pant", tonumber(Character.Pant) )
    ply:SetNWInt( "Jacket", tonumber(Character.Jacket) )
    ply:SetNWInt( "Vest", tonumber(Character.Vest) )
    ply:SetNWInt( "VestArmor", tonumber(Character.VestArmor) )
    ply:SetNWInt( "Rucksack", tonumber(Character.Rucksack) )
    ply:SetNWInt( "GasMask", tonumber(Character.GasMask) )
    if ply:GetNWInt("GasMask") > 1 then
        ply.BodyGroups[PlayerModels[ply:GetNWString("Faction")][ply:GetNWInt("ModelIndex")].gasmask_bodygroup[1] + 1] = PlayerModels[ply:GetNWString("Faction")][ply:GetNWInt("ModelIndex")].gasmask_bodygroup[3] -- this is meant to remove the gasmask bodygroup at spawn if the player was wearing a gasmask the last time he disconnected
    end
    ply:SetNWInt( "Helmet", tonumber(Character.Helmet) )
    ply:SetNWInt( "HelmetArmor", tonumber(Character.HelmetArmor) )
    ply:SetNWInt( "NVG", tonumber(Character.NVG) )
    if ply:GetNWInt("NVG") > 1 then
        ply.BodyGroups[PlayerModels[ply:GetNWString("Faction")][ply:GetNWInt("ModelIndex")].nvg_bodygroup[1]] = PlayerModels[ply:GetNWString("Faction")][ply:GetNWInt("ModelIndex")].nvg_bodygroup[2]
    end

    Character.Inventory = string.Split(Character.Inventory, ",")
    Character.AmmoBoxes = string.Split(Character.AmmoBoxes, ",")
    for k = 1,20 do
        ply:SetNWInt( "Inventory" .. tostring(k), tonumber(Character.Inventory[k]) )
        ply:SetNWInt( "AmmoBox" .. tostring(k), tonumber(Character.AmmoBoxes[k]) )
    end
    player_manager.SetPlayerClass(ply, "player_" .. string.lower(ply:GetNWString("Faction")))
    ply:Spawn()

    RunEquipment(ply)
end)

function GM:PlayerSelectSpawn(ply, transition)
    if ply:GetNWString("Faction") == "USMC" then
        local spawns = ents.FindByClass("info_player_usmc")
        local random_entry = math.random(#spawns)

        return spawns[random_entry]
    elseif ply:GetNWString("Faction") == "Survivor" then
        local spawns = ents.FindByClass("info_player_survivor")
        local random_entry = math.random(#spawns)

        return spawns[random_entry]
    end
end

hook.Add("GasMaskNeeded", "TestTeleportHook", function()
    if player_manager.GetPlayerClass(ACTIVATOR) ~= "player_spectator" then
        local d = DamageInfo()
        d:SetDamage( 1 )
        d:SetAttacker( ACTIVATOR )
        d:SetDamageType( DMG_NERVEGAS )

        ACTIVATOR:TakeDamageInfo( d )
    end
end)

net.Receive("DropRequest", function(len, ply)
    local category = net.ReadString()
    local ent = ents.Create(EntList[ply:GetNWInt(category)].className)
    if ent.Capacity then
        for k = ent.StartingIndex,ent.StartingIndex + ent.Capacity - 1 do
            ent["Slot" .. tostring(k)] = ply:GetNWInt("Inventory" .. tostring(k))
            if EntList[ply:GetNWInt("Inventory" .. tostring(k))].ammoName then
                ent["Slot" .. tostring(k) .. "AmmoCount"] = ply:GetNWInt("AmmoBox" .. tostring(k))
            end
            ply:SetNWInt("Inventory" .. tostring(k), 1)
        end
        for k = ent.StartingIndex,ent.StartingIndex + ent.Capacity - 1 do -- Since the "RemoveAmmo" function call the "PlayerAmmoChanged" function which change the "AmmoBox" networked value we have to do a boucle again ...
            if EntList[ply:GetNWInt("Inventory" .. tostring(k))].ammoName then
                ply:RemoveAmmo( ply:GetNWInt("AmmoBox" .. tostring(k)), EntList[ply:GetNWInt("Inventory" .. tostring(k))].ammoName )
            end
        end
    end
    sql.Query("UPDATE mvsa_characters SET " .. category .. " = 1 WHERE SteamID64 = " .. tostring(ply:SteamID64()) .. " AND RPName = " .. "'" .. ply.RPName .. "'")
    if EntList[ply:GetNWInt(category)].wep then
        local wep = ply:GetWeapon(EntList[ply:GetNWInt(category)].wep)
        ent.PreviousMag = wep:Clip1()
        ply:StripWeapon(EntList[ply:GetNWInt(category)].wep)
    end
    if ent.BodyGroup then
        ply:SetBodygroup(ent.BodyGroup[ply:GetNWString("Faction")][ply:GetNWInt("ModelIndex")][1], ent.BodyGroup[ply:GetNWString("Faction")][ply:GetNWInt("ModelIndex")][3])
        SaveBodyGroupsData(ply)
    end
    if ent.AmmoCount then
        ent.AmmoCount = net.ReadUInt(9)
        ply:RemoveAmmo( ent.AmmoCount, net.ReadUInt(5) )
    end
    if ent.Armor then
        ent.Armor = ply:GetNWInt(category .. "Armor")
    end
    ent:Spawn()
    ent:SetPos( ply:EyePos() - Vector(0,0,10) )
    ply:SetNWInt(category, 1)
end)

net.Receive("RagdollDropRequest", function(len, ply)
    local ragdoll = ents.GetByIndex(net.ReadUInt(32))
    local category = net.ReadString()
    local ent = ents.Create(EntList[ragdoll:GetNWInt(category)].className)
    if ent.Capacity then
        for k = ent.StartingIndex,ent.StartingIndex + ent.Capacity - 1 do
            ent["Slot" .. tostring(k)] = ragdoll:GetNWInt("Inventory" .. tostring(k))
            if EntList[ragdoll:GetNWInt("Inventory" .. tostring(k))].ammoName then
                ent["Slot" .. tostring(k) .. "AmmoCount"] = ragdoll:GetNWInt("AmmoBox" .. tostring(k))
            end
            ragdoll:SetNWInt("Inventory" .. tostring(k), 1)
        end
        for k = ent.StartingIndex,ent.StartingIndex + ent.Capacity - 1 do -- Since the "RemoveAmmo" function call the "PlayerAmmoChanged" function which change the "AmmoBox" networked value we have to do a boucle again ...
            if EntList[ragdoll:GetNWInt("Inventory" .. tostring(k))].ammoName then
                ragdoll:RemoveAmmo( ragdoll:GetNWInt("AmmoBox" .. tostring(k)), EntList[ragdoll:GetNWInt("Inventory" .. tostring(k))].ammoName )
            end
        end
    end
    if EntList[ragdoll:GetNWInt(category)].wep then
        ent.PreviousMag = ragdoll:GetNWInt(category .. "Ammo")
    end
    if ent.BodyGroup then
        ragdoll:SetBodygroup(ent.BodyGroup[ragdoll:GetNWString("Faction")][ragdoll:GetNWInt("ModelIndex")][1], ent.BodyGroup[ragdoll:GetNWString("Faction")][ragdoll:GetNWInt("ModelIndex")][3])
    end
    if ent.AmmoCount then
        ent.AmmoCount = net.ReadUInt(9)
    end
    if ent.Armor then
        ent.Armor = ragdoll:GetNWInt(category .. "Armor")
    end
    ent:Spawn()
    ent:SetPos( ragdoll:GetPos() + Vector(0,0,10) )
    ragdoll:SetNWInt(category, 1)
end)

net.Receive("UseRequest", function(len, ply)
    ply:SelectWeapon( net.ReadString() )
end)

function GM:PlayerDisconnected(ply)
    if player_manager.GetPlayerClass(ply) == "player_usmc" or "player_survivor" then
        if ply:GetNWInt("PrimaryWep") > 1 then
            sql.Query("UPDATE mvsa_characters SET PrimaryWepAmmo = " .. tostring(ply:GetWeapon(EntList[ply:GetNWInt("PrimaryWep")].wep):Clip1()) .. " WHERE SteamID64 = " .. tostring(ply:SteamID64()) .. " AND RPName = " .. "'" .. ply.RPName .. "'")
        end
        if ply:GetNWInt("SecondaryWep") > 1 then
            sql.Query("UPDATE mvsa_characters SET SecondaryWepAmmo = " .. tostring(ply:GetWeapon(EntList[ply:GetNWInt("SecondaryWep")].wep):Clip1()) .. " WHERE SteamID64 = " .. tostring(ply:SteamID64()) .. " AND RPName = " .. "'" .. ply.RPName .. "'")
        end
        if ply:GetNWInt("Launcher") > 1 then
            sql.Query("UPDATE mvsa_characters SET LauncherAmmo = " .. tostring(ply:GetWeapon(EntList[ply:GetNWInt("Launcher")].wep):Clip1()) .. " WHERE SteamID64 = " .. tostring(ply:SteamID64()) .. " AND RPName = " .. "'" .. ply.RPName .. "'")
        end
        local AmmoBoxes = tostring(ply:GetNWInt("AmmoBox1"))
        for k = 2,20 do
            AmmoBoxes = AmmoBoxes .. "," .. tostring(ply:GetNWInt("AmmoBox" .. tostring(k)))
        end
        sql.Query("UPDATE mvsa_characters SET AmmoBoxes = '" .. AmmoBoxes .. "' WHERE SteamID64 = " .. tostring(ply:SteamID64()) .. " AND RPName = " .. "'" .. ply.RPName .. "'")
    end
end

function RemoveAmmoFromBoxes(index, AmmoCountToRemove, key, ply)
    for k = index,20 do
        if ply:GetNWInt("Inventory" .. tostring(21 - k)) == AmmoList[key].entID then
            ply:SetNWInt("AmmoBox" .. tostring(21 - k), ply:GetNWInt("AmmoBox" .. tostring(21 - k)) - AmmoCountToRemove)
            if ply:GetNWInt( "AmmoBox" .. tostring(21 - k)) <= 0 then
                ply:SetNWInt("Inventory" .. tostring(21 - k), 1)
                RemoveAmmoFromBoxes(k, - ply:GetNWInt("AmmoBox" .. tostring(21 - k)), key, ply)
            end
            break
        end
    end
end

function GM:PlayerAmmoChanged( ply, ammoID, oldCount, newCount )
    local AmmoName = game.GetAmmoName(ammoID)
    if newCount < oldCount then
        local key = 1
        for k = 1,#AmmoList do
            if table.KeyFromValue(AmmoList[k], AmmoName) ~= nil then
                key = k
            end
        end
        local AmmoCountToRemove = oldCount - newCount
        local startingIndex = 1
        RemoveAmmoFromBoxes(startingIndex, AmmoCountToRemove, key, ply)
        local Inventory = {}
        for k = 1,20 do
            Inventory[k] = ply:GetNWInt("Inventory" .. tostring(k))
        end
        Inventory = table.concat(Inventory, ",")
        sql.Query("UPDATE mvsa_characters SET Inventory = '" .. Inventory .. "' WHERE SteamID64 = " .. tostring(ply:SteamID64()) .. " AND RPName = " .. "'" .. ply.RPName .. "'")
    end
end

function GM:PlayerNoClip( ply, desiredState )
    if ply:IsAdmin() then
        return true
    else
        return false
    end
end

function GM:PlayerDeath( ply, inflictor, attacker )
    sql.Query("DELETE FROM mvsa_characters WHERE SteamID64 = " .. tostring(ply:SteamID64()) .. " AND RPName = " .. "'" .. ply.RPName .. "'")
    player_manager.SetPlayerClass(ply, "player_spectator")
end

function GM:Think()
    AutoCleanup()
    NPCSpawnSystem()
    LootSpawnSystem()
end

function GM:OnNPCKilled( npc, attacker, inflictor )
    NPCCount = NPCCount - 1
end

function GM:PostCleanupMap()
    NPCCount = 0
    LootCount = 0
end

function GM:CreateEntityRagdoll( owner, ragdoll )
    for k = 1,20 do
        ragdoll:SetNWInt("Inventory" .. tostring(k), owner:GetNWInt("Inventory" .. tostring(k)))
        ragdoll:SetNWInt("AmmoBox" .. tostring(k), owner:GetNWInt("AmmoBox" .. tostring(k)))
    end
    ragdoll:SetNWInt("Helmet", owner:GetNWInt("Helmet"))
    ragdoll:SetNWInt("HelmetArmor", owner:GetNWInt("HelmetArmor"))
    ragdoll:SetNWInt("NVG", owner:GetNWInt("NVG"))
    ragdoll:SetNWInt("GasMask", owner:GetNWInt("GasMask"))
    ragdoll:SetNWInt("Rucksack", owner:GetNWInt("Rucksack"))
    ragdoll:SetNWInt("Vest", owner:GetNWInt("Vest"))
    ragdoll:SetNWInt("VestArmor", owner:GetNWInt("VestArmor"))
    ragdoll:SetNWInt("Jacket", owner:GetNWInt("Jacket"))
    ragdoll:SetNWInt("Pant", owner:GetNWInt("Pant"))
    ragdoll:SetNWInt("PrimaryWep", owner:GetNWInt("PrimaryWep"))
    ragdoll:SetNWInt("SecondaryWep", owner:GetNWInt("SecondaryWep"))
    ragdoll:SetNWInt("Launcher", owner:GetNWInt("Launcher"))
    ragdoll:SetNWInt("Faction", owner:GetNWInt("Faction"))
    ragdoll:SetNWInt("ModelIndex", owner:GetNWInt("ModelIndex"))
    ragdoll:SetNWInt("GasMaskSet", owner:GetNWInt("GasMaskSet"))
    if owner:GetNWInt("PrimaryWep") > 1 then
        ragdoll:SetNWInt("PrimaryWepAmmo", owner:GetWeapon(EntList[owner:GetNWInt("PrimaryWep")].wep):Clip1())
    end
    if owner:GetNWInt("SecondaryWep") > 1 then
        ragdoll:SetNWInt("SecondaryWepAmmo", owner:GetWeapon(EntList[owner:GetNWInt("SecondaryWep")].wep):Clip1())
    end
    if owner:GetNWInt("Launcher") > 1 then
        ragdoll:SetNWInt("LauncherAmmo", owner:GetWeapon(EntList[owner:GetNWInt("Launcher")].wep):Clip1())
    end
end

function GM:PlayerUse( ply, ent )
    if ent:IsRagdoll() and ent:GetOwner():IsPlayer() then
        net.Start("RagdollLooting")
        net.WriteUInt(ent:EntIndex(), 32)
        net.Send(ply)
    end
end

net.Receive("NVGPutOn", function(len, ply)
    ply:SetBodygroup(PlayerModels[ply:GetNWString("Faction")][ply:GetNWInt("ModelIndex")].nvg_bodygroup[1], PlayerModels[ply:GetNWString("Faction")][ply:GetNWInt("ModelIndex")].nvg_bodygroup[3])
end)
net.Receive("NVGPutOff", function(len, ply)
    ply:SetBodygroup(PlayerModels[ply:GetNWString("Faction")][ply:GetNWInt("ModelIndex")].nvg_bodygroup[1], PlayerModels[ply:GetNWString("Faction")][ply:GetNWInt("ModelIndex")].nvg_bodygroup[2])
end)

function GM:ScalePlayerDamage( ply, hitgroup, dmginfo )
    if hitgroup == HITGROUP_HEAD and ply:GetNWInt("Helmet") > 1 then
        ply:SetNWInt("HelmetArmor", math.Clamp(math.floor(ply:GetNWInt("HelmetArmor") - dmginfo:GetDamage()), 0, EntList[ply:GetNWInt("Helmet")].armor))
        dmginfo:SetDamage( dmginfo:GetDamage() * (1 - ply:GetNWInt("HelmetArmor") / EntList[ply:GetNWInt("Helmet")].armor))
    elseif hitgroup == HITGROUP_CHEST and ply:GetNWInt("Vest") > 1 then
        ply:SetNWInt("VestArmor", math.Clamp(math.floor(ply:GetNWInt("VestArmor") - dmginfo:GetDamage()), 0, EntList[ply:GetNWInt("Vest")].armor))
        dmginfo:SetDamage( dmginfo:GetDamage() * (1 - ply:GetNWInt("VestArmor") / EntList[ply:GetNWInt("Vest")].armor))
    end
end