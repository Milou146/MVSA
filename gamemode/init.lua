AddCSLuaFile("cl_init.lua")
AddCSLuaFile("cl_inventory.lua")
AddCSLuaFile("cl_commands.lua")
AddCSLuaFile("cl_gasmask.lua")
AddCSLuaFile("cl_hud.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("sh_config.lua")
AddCSLuaFile("sh_gasmask.lua")
AddCSLuaFile("panel/mvsa_panel.lua")

include("sv_commands.lua")
include("sv_gasmask.lua")
include("shared.lua")

util.AddNetworkString("mvsa_character_creation")
util.AddNetworkString("mvsa_character_deletion")
util.AddNetworkString("mvsa_character_selection")
util.AddNetworkString("mvsa_character_selected")
util.AddNetworkString("mvsa_character_information")
util.AddNetworkString("DropRequest")
util.AddNetworkString("UseRequest")

sql.Query("CREATE TABLE IF NOT EXISTS mvsa_player_character( SteamID64 BIGINT NOT NULL, Faction BOOL, RPName VARCHAR(45), ModelIndex TINYINT, Size SMALLINT NOT NULL, Skin TINYINT, BodyGroups VARCHAR(60), PrimaryWep TINYINT, PrimaryWepAmmo TINYINT, SecondaryWep TINYINT, SecondaryWepAmmo TINYINT, Launcher TINYINT, LauncherAmmo TINYINT, Pant TINYINT, Jacket TINYINT, Vest TINYINT, Rucksack TINYINT, Helmet TINYINT, NVG TINYINT, Inventory VARCHAR(60) )")

local function CheckData(ply)
    local data = sql.Query(" SELECT * FROM mvsa_player_character WHERE SteamID64 = " .. tostring(ply:SteamID64()))

    if not data then
        net.Start("mvsa_character_creation")
        net.Send(ply)
    else
        net.Start("mvsa_character_selection")
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

function RunClass(ply)
    player_manager.SetPlayerClass(ply, "player_" .. string.lower(ply:GetNWString("Faction")))
    ply:Spawn()
    if ply:GetNWInt("PrimaryWep") > 1 then
        local ent = ents.Create(MVSA.EntList[ply:GetNWInt("PrimaryWep")][3])
        ent.Primary.DefaultClip = 0
        ply:PickupWeapon(ent)
        ent:SetClip1( ply.PrimaryWepAmmo )
    end
    if ply:GetNWInt("SecondaryWep") > 1 then
        local ent = ents.Create(MVSA.EntList[ply:GetNWInt("SecondaryWep")][3])
        ent.Primary.DefaultClip = 0
        ply:PickupWeapon(ent)
        ent:SetClip1( ply.SecondaryWepAmmo )
    end
    if ply:GetNWInt("Launcher") > 1 then
        local ent = ents.Create(MVSA.EntList[ply:GetNWInt("Launcher")][3])
        ent.Primary.DefaultClip = 0
        ply:PickupWeapon(ent)
        ent:SetClip1( ply.LauncherAmmo )
    end
end

function GM:PlayerInitialSpawn(ply, transition)
    player_manager.SetPlayerClass(ply, "player_spectator")
    CheckData(ply)
    ply:AllowFlashlight(true)
end

function GM:PlayerSpawn(ply, transition)
    if player_manager.GetPlayerClass(ply) == "player_spectator" then
        local view_ent = ents.FindByName("spectator_view")[1]
        ply:SetViewEntity(view_ent)
    else
        ply:SetViewEntity(ply)
        ply:SetModel(MVSA[ply:GetNWString("Faction")][ply:GetNWInt("ModelIndex")][1])
        ply:SetModelScale(ply:GetNWInt("Size") / 180, 0)
        ply:SetSkin(ply:GetNWInt("Skin"))

        for k, v in pairs(ply.BodyGroups) do
            ply:SetBodygroup(k - 1, v)
        end

        ply:SetupHands() -- Create the hands and call GM:PlayerSetHandsModel
    end
end

net.Receive("mvsa_character_information", function(len, ply)
    ply.Faction = net.ReadBit()
    ply.RPName = net.ReadString()
    ply:SetNWInt( "ModelIndex", net.ReadUInt(5) )
    ply:SetNWInt( "Size", net.ReadUInt(8))
    ply:SetNWInt( "Skin", net.ReadUInt(5))
    ply.BodyGroups = net.ReadString()
    ply:SetNWBool( "GasMaskSet", false )
    ply:SetNWInt( "PrimaryWep", 0 )
    ply:SetNWInt( "SecondaryWep", 0 )
    ply:SetNWInt( "Launcher", 0 )
    ply:SetNWInt( "Pant", 3 )
    ply:SetNWInt( "Jacket", 0 )
    ply:SetNWInt( "Vest", 0 )
    ply:SetNWInt( "Rucksack", 0 )
    ply:SetNWInt( "Helmet", 0 )
    ply:SetNWInt( "NVG", 0 )

    ply:SetNWInt( "Inventory1", 1)
    ply:SetNWInt( "Inventory2", 1)
    for k = 3,20 do
        ply:SetNWInt( "Inventory" .. tostring(k), 0 )
    end

    sql.Query("INSERT INTO mvsa_player_character VALUES( " .. ply:SteamID64() .. ", " .. tostring(ply.Faction) .. ", " .. SQLStr(ply.RPName) .. ", " .. tostring(ply:GetNWInt("ModelIndex")) .. ", " .. tostring(ply:GetNWInt("Size")) .. ", " .. tostring(ply:GetNWInt("Skin")) .. ", '" .. ply.BodyGroups .. "', 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, '1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0')")
    ply.BodyGroups = string.Split(ply.BodyGroups, ",")

    if ply.Faction == 1 then
        ply:SetNWString("Faction", "Survivor")
    else
        ply:SetNWString("Faction", "USMC")
    end

    RunClass(ply)
end)

net.Receive("mvsa_character_deletion", function(len, ply)
    local rpname = net.ReadString()
    sql.Query("DELETE FROM mvsa_player_character WHERE SteamID64 = " .. tostring(ply:SteamID64()) .. " AND RPName = " .. "'" .. rpname .. "'")
end)

net.Receive("mvsa_character_selected", function(len, ply)
    ply.RPName = net.ReadString()
    local Character = sql.QueryRow("SELECT * FROM mvsa_player_character WHERE SteamID64 = " .. tostring(ply:SteamID64()) .. " AND RPName = " .. "'" .. ply.RPName .. "'")

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
    ply.BodyGroups[MVSA[ply:GetNWString("Faction")][ply:GetNWInt("ModelIndex")][4][1]] = MVSA[ply:GetNWString("Faction")][ply:GetNWInt("ModelIndex")][4][3] -- this is meant to remove the gasmask bodygroup at spawn if the player was wearing a gasmask the last time he disconnected
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
    ply:SetNWInt( "Rucksack", tonumber(Character.Rucksack) )
    ply:SetNWInt( "Helmet", tonumber(Character.Helmet) )
    ply:SetNWInt( "NVG", tonumber(Character.NVG) )

    Character.Inventory = string.Split(Character.Inventory, ",")
    for k = 1,20 do
        ply:SetNWInt( "Inventory" .. tostring(k), tonumber(Character.Inventory[k]) )
    end

    for k = 1,20 do
        if ply:GetNWInt("Inventory" .. tostring(k)) == 2 then
            ply.GasMaskEquiped = true
            break
        end
    end

    RunClass(ply)
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
    local ent = ents.Create(net.ReadString())
    local category = net.ReadString()
    ply:SetNWInt(category, 1)
    sql.Query("UPDATE mvsa_player_character SET " .. category .. " = 0 WHERE SteamID64 = " .. tostring(ply:SteamID64()) .. " AND RPName = " .. "'" .. ply.RPName .. "'")
    if net.ReadBool() then
        local wep_class = net.ReadString()
        local wep = ply:GetWeapon(wep_class)
        ent.PreviousMag = wep:Clip1()
        ply:StripWeapon(wep_class)
    end
    if net.ReadBool() then
        ply:SetBodygroup(ent.BodyGroup[ply:GetNWString("Faction")][ply:GetNWInt("ModelIndex")][1], ent.BodyGroup[ply:GetNWString("Faction")][ply:GetNWInt("ModelIndex")][3])
        local BodyGroups = tostring(ply:GetBodygroup(0))
        for k = 1,ply:GetNumBodyGroups() - 1 do
            BodyGroups = BodyGroups .. "," .. tostring(ply:GetBodygroup(k))
        end
        sql.Query("UPDATE mvsa_player_character SET BodyGroups = '" .. BodyGroups .. "' WHERE SteamID64 = " .. tostring(ply:SteamID64()) .. " AND RPName = " .. "'" .. ply.RPName .. "'")
    end
    if net.ReadBool() then
        ply:RemoveAmmo( net.ReadUInt(9), net.ReadUInt(5) )
    end
    ent:Spawn()
    ent:SetPos( ply:EyePos() - Vector(0,0,10) )
end)

net.Receive("UseRequest", function(len, ply)
    ply:SelectWeapon( net.ReadString() )
end)

function GM:PlayerDisconnected(ply)
    if player_manager.GetPlayerClass(ply) == "player_usmc" or "player_survivor" then
        if ply:GetNWInt("PrimaryWep") > 1 then
            sql.Query("UPDATE mvsa_player_character SET PrimaryWepAmmo = " .. tostring(ply:GetWeapon(MVSA.EntList[ply:GetNWInt("PrimaryWep")][3]):Clip1()) .. " WHERE SteamID64 = " .. tostring(ply:SteamID64()) .. " AND RPName = " .. "'" .. ply.RPName .. "'")
        end
        if ply:GetNWInt("SecondaryWep") > 1 then
            sql.Query("UPDATE mvsa_player_character SET SecondaryWepAmmo = " .. tostring(ply:GetWeapon(MVSA.EntList[ply:GetNWInt("SecondaryWep")][3]):Clip1()) .. " WHERE SteamID64 = " .. tostring(ply:SteamID64()) .. " AND RPName = " .. "'" .. ply.RPName .. "'")
        end
        if ply:GetNWInt("Launcher") > 1 then
            sql.Query("UPDATE mvsa_player_character SET LauncherAmmo = " .. tostring(ply:GetWeapon(MVSA.EntList[ply:GetNWInt("Launcher")][3]):Clip1()) .. " WHERE SteamID64 = " .. tostring(ply:SteamID64()) .. " AND RPName = " .. "'" .. ply.RPName .. "'")
        end
    end
end

function GM:PlayerAmmoChanged( ply, ammoID, oldCount, newCount )
    ply["Ammo" .. tostring(ammoID) .. "StartedCount"] = ply["Ammo" .. tostring(ammoID) .. "StartedCount"] or 0
    if newCount < oldCount then
        local AmmoCountToRemove = oldCount - newCount + ply["Ammo" .. tostring(ammoID) .. "StartedCount"] or 0
        if AmmoCountToRemove > MVSA.AmmoList[ammoID][2] then
            ply["Ammo" .. tostring(ammoID) .. "StartedCount"] = AmmoCountToRemove - MVSA.AmmoList[ammoID][2]
            for k = 1,20 do
                if ply:GetNWInt("Inventory" .. tostring(k)) == MVSA.AmmoList[ammoID][1] then
                    ply:SetNWInt("Inventory" .. tostring(k), 1)
                    break
                end
            end
            local Inventory = {}
            for k = 1,20 do
                Inventory[k] = ply:GetNWInt("Inventory" .. tostring(k))
            end
            Inventory = table.concat(Inventory, ",")
            sql.Query("UPDATE mvsa_player_character SET Inventory = '" .. Inventory .. "' WHERE SteamID64 = " .. tostring(ply:SteamID64()) .. " AND RPName = " .. "'" .. ply.RPName .. "'")
        elseif AmmoCountToRemove == MVSA.AmmoList[ammoID][2] then
            ply["Ammo" .. tostring(ammoID) .. "StartedCount"] = 0
            for k = 1,20 do
                if ply:GetNWInt("Inventory" .. tostring(k)) == MVSA.AmmoList[ammoID][1] then
                    ply:SetNWInt("Inventory" .. tostring(k), 1)
                    break
                end
            end
            local Inventory = {}
            for k = 1,20 do
                Inventory[k] = ply:GetNWInt("Inventory" .. tostring(k))
            end
            Inventory = table.concat(Inventory, ",")
            sql.Query("UPDATE mvsa_player_character SET Inventory = '" .. Inventory .. "' WHERE SteamID64 = " .. tostring(ply:SteamID64()) .. " AND RPName = " .. "'" .. ply.RPName .. "'")
        elseif AmmoCountToRemove < MVSA.AmmoList[ammoID][2] then
            ply["Ammo" .. tostring(ammoID) .. "StartedCount"] = AmmoCountToRemove
        end
    end
end