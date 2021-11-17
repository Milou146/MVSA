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

gasTriggerDelay = 0

loot_spawn_system = {}
loot_spawn_system.SpawnDelay = 0
loot_spawn_system.MinSpawnDistance = 3000
loot_spawn_system.MaxSpawnDistance = 20000
loot_spawn_system.LootCount = 0
loot_spawn_system.LootLimit = 30

local npc_spawn_system = {}
npc_spawn_system.SpawnDelay = 0
npc_spawn_system.MinSpawnDistance = 3000
npc_spawn_system.MaxSpawnDistance = 20000
npc_spawn_system.NPCCount = 0
npc_spawn_system.NPCLimit = 20

gas_zones = {
    ["rp_cscdesert_v2-1"] = {
        [1] = {x1 = -12595,x2 = 12595,y1 = -14360,y2 = 14360,z1 = 60,z2 = 3125}
    }
}
loot = {
    ["rp_cscdesert_v2-1"] = {
        [1] = { pos = Vector(-1187.29,6872.5,25) },
        [2] = { pos = Vector(-1216,6836,73.1166) },
        [3] = { pos = Vector(-1232,6880,76) },
        [4] = { pos = Vector(-978.503,7296.3,65) },
        [5] = { pos = Vector(-1004.87,7363.91,25) },
        [6] = { pos = Vector(3925.28,4357.26,17) },
        [7] = { pos = Vector(2626.99,-8585.93,57) },
        [8] = { pos = Vector(2591.81,-8675.71,17) },
        [9] = { pos = Vector(2100.1,-7881.49,17) },
        [10] = { pos = Vector(2066,-7956,59) },
        [11] = { pos = Vector(2729.94,-7884.01,53.028) },
        [12] = { pos = Vector(2477.3,-7993.21,60.134) },
        [13] = { pos = Vector(2519.9,-8124.84,38.948) },
        [14] = { pos = Vector(2828.14,-8168.94,52.876) },
        [15] = { pos = Vector(2705.39,-7887.14,53.028) },
        [16] = { pos = Vector(4186.49,-9617.55,52.876) },
        [17] = { pos = Vector(4223.65,-9574.92,58.7535) },
        [18] = { pos = Vector(4461.09,-9510.63,53.028) },
        [19] = { pos = Vector(4431.85,-9555.43,36.2458) },
        [20] = { pos = Vector(4478.45,-9299.73,38.948) },
        [21] = { pos = Vector(4229.83,-9303.72,38.948) },
        [22] = { pos = Vector(3436.87,-9656.13,8) },
        [23] = { pos = Vector(3252.15,-9675.31,8) },
        [24] = { pos = Vector(3335.33,-9608.73,46.9262) },
        [25] = { pos = Vector(1652.32,-9420.02,53.028) },
        [26] = { pos = Vector(1604.2,-9280.2,53.028) },
        [27] = { pos = Vector(1973.84,-9495.26,54.9262) },
        [28] = { pos = Vector(1963.81,-9522.33,54.9262) },
        [29] = { pos = Vector(1937.05,-9517.97,16) },
        [30] = { pos = Vector(1776.19,-9456.13,56) },
        [31] = { pos = Vector(1621.21,-9407.96,-91.008) },
        [32] = { pos = Vector(1638,-9311.36,-136) },
        [33] = { pos = Vector(1665.52,-9162.54,-136) },
        [34] = { pos = Vector(1832.58,-9305.59,-136) },
        [35] = { pos = Vector(1787.48,-9291.78,-136) },
        [36] = { pos = Vector(1854.72,-9371.3,-136) },
        [37] = { pos = Vector(1801.94,-9504.73,-136) },
        [38] = { pos = Vector(1967.68,-9266.76,-232.493) },
        [39] = { pos = Vector(2017.19,-9264.25,-232.493) },
        [40] = { pos = Vector(2577.21,-9624.14,58.7535) },
        [41] = { pos = Vector(2515.29,-9680.84,52.876) },
        [42] = { pos = Vector(2803.19,-9573.49,53.028) },
        [43] = { pos = Vector(2786.75,-9529.46,16) },
        [44] = { pos = Vector(2816.44,-9362.02,38.948) },
        [45] = { pos = Vector(2555.27,-9353.56,38.948) },
        [46] = { pos = Vector(4673.48,-9081.65,8) },
        [47] = { pos = Vector(2785.34,-8120.95,56.064) },
        [48] = { pos = Vector(2513.53,-7869.12,38.948) },
        [49] = { pos = Vector(2488.94,-8121.24,38.948) },
        [50] = { pos = Vector(2322.84,2965.81,-344) },
        [51] = { pos = Vector(2133.37,2162.23,-349.046) },
        [52] = { pos = Vector(1965.96,2146.66,-349.835) },
        [53] = { pos = Vector(2051.85,2141.58,-376) },
        [54] = { pos = Vector(2218.78,2124.54,-376) },
        [55] = { pos = Vector(1717.52,2602.28,-331.879) },
        [56] = { pos = Vector(2194.77,2680.91,-328.719) },
        [57] = { pos = Vector(1922.41,2699.93,-328.719) },
        [58] = { pos = Vector(2380.01,2447.77,-331.504) },
        [59] = { pos = Vector(2949.77,2530.7,-376) },
        [60] = { pos = Vector(2961.51,2588.08,-376) },
        [61] = { pos = Vector(2913.45,2556.79,-376) },
        [62] = { pos = Vector(2513.59,2957.11,-670.579) },
        [63] = { pos = Vector(2244.63,3010.93,-696) },
        [64] = { pos = Vector(3018.96,2789.48,-648.719) },
        [65] = { pos = Vector(3024.8,2744.22,-648.719) },
        [66] = { pos = Vector(2951.11,2966.55,-668.788) },
        [67] = { pos = Vector(3242.83,2690.86,-652.215) },
        [68] = { pos = Vector(3148.41,2684.88,-696) },
        [69] = { pos = Vector(3144.23,2734.85,-696) },
        [70] = { pos = Vector(3605.56,2803.04,-696) },
        [71] = { pos = Vector(3670.66,2320.18,-696) },
        [72] = { pos = Vector(2432.09,2438.47,-984.433) },
        [73] = { pos = Vector(2391.24,2433.12,-984.433) },
        [74] = { pos = Vector(2469.53,2442.08,-984.433) },
        [75] = { pos = Vector(2474.66,2302.83,-984.433) },
        [76] = { pos = Vector(2420.74,2292.68,-984.433) },
        [77] = { pos = Vector(2119.02,2288.76,-984.433) },
        [78] = { pos = Vector(2195.59,2292.55,-984.433) },
        [79] = { pos = Vector(2131.18,2435.32,-984.433) },
        [80] = { pos = Vector(2191.95,2427.99,-984.433) },
        [81] = { pos = Vector(2479.31,3016.22,-1014) },
        [82] = { pos = Vector(3296.6,2918.96,-970.35) },
        [83] = { pos = Vector(3419.38,2658.46,-970.654) },
        [84] = { pos = Vector(2069.04,2828.54,-1014) },
        [85] = { pos = Vector(1926.94,2827.37,-1014) },
        [86] = { pos = Vector(1922.91,3546.28,-971.228) },
        [87] = { pos = Vector(1609.21,3476.94,-1016) },
        [88] = { pos = Vector(1354.29,3200.76,-1016) },
        [89] = { pos = Vector(1357.09,3425.01,-1016) },
        [90] = { pos = Vector(3165.92,2653.03,-1016) },
        [91] = { pos = Vector(3418.05,2753,-1016) },
        [92] = { pos = Vector(3407.29,2589.29,-1016) },
        [93] = { pos = Vector(3245.51,2622.08,-1016) }
    }
}

spawns = {
    ["rp_cscdesert_v2-1"] = {
        spectators = {
            [1] = { pos = Vector(-117.146927,-14558.839844,64.031250) },
            [2] = { pos = Vector(129.822708,-14545.011719,64.031250) }
        },
        survivors = {
            [1] = { pos = Vector(7991.36,4065.73,-895) },
            [2] = { pos = Vector(7965.24,3896.58,-895) },
            [3] = { pos = Vector(7999.54,3704.67,-895) },
            [4] = { pos = Vector(7279.78,3800.35,-575) },
            [5] = { pos = Vector(7277.46,3603.09,-575) },
            [6] = { pos = Vector(7565.54,3547.52,-575) },
            [7] = { pos = Vector(7351.19,3526.92,-575) },
            [8] = { pos = Vector(7519.77,3378.24,-575) },
            [9] = { pos = Vector(7478.33,3676.06,-575) }
        },
        usmc = {
            [1] = { pos = Vector(-2712,5931,-383) },
            [2] = { pos = Vector(-2712,5871,-383) },
            [3] = { pos = Vector(-2712,5811,-383) },
            [4] = { pos = Vector(-2712,5751,-383) },
            [5] = { pos = Vector(-2792,5751,-383) },
            [6] = { pos = Vector(-2792,5931,-383) },
            [7] = { pos = Vector(-2792,5871,-383) },
            [8] = { pos = Vector(-2792,5811,-383) }
        },
        zombies = {
            [1] = { pos = Vector(2537.28,-9564.46,17) },
            [2] = { pos = Vector(2702.14,-9622.52,17) },
            [3] = { pos = Vector(2764.91,-9361.93,17) },
            [4] = { pos = Vector(2746.19,-9487.16,17) },
            [5] = { pos = Vector(2436.46,-9654.15,17) },
            [6] = { pos = Vector(1864.59,-9472.89,17) },
            [7] = { pos = Vector(1658.81,-9366.7,17) },
            [8] = { pos = Vector(1751.43,-9263.23,17) },
            [9] = { pos = Vector(1758.09,-8145.32,17) },
            [10] = { pos = Vector(1592.51,-7959.19,17) },
            [11] = { pos = Vector(1552.25,-8141.02,25) },
            [12] = { pos = Vector(1759.07,-8029.78,17) },
            [13] = { pos = Vector(2007.56,-7957.61,17) },
            [14] = { pos = Vector(2620.35,-9360.51,17) },
            [15] = { pos = Vector(4181.64,-9500.42,17) },
            [16] = { pos = Vector(4384.14,-9544.87,17) },
            [17] = { pos = Vector(4421.62,-9302.01,17) },
            [18] = { pos = Vector(4341.98,-9324.47,17) },
            [19] = { pos = Vector(2760.41,-8186.87,17) },
            [20] = { pos = Vector(2719.09,-8125.51,17) },
            [21] = { pos = Vector(2734.08,-7989.25,17) },
            [22] = { pos = Vector(2350.86,2482.99,-695) },
            [23] = { pos = Vector(3913.65,2498.28,-695) },
            [24] = { pos = Vector(3732.66,2490.5,-695) },
            [25] = { pos = Vector(3545.36,2484.08,-695) },
            [26] = { pos = Vector(3365.32,2882.91,-695) },
            [27] = { pos = Vector(2832.55,2755.91,-695) },
            [28] = { pos = Vector(2930.71,2730.06,-695) },
            [29] = { pos = Vector(2908.09,2857.46,-695) },
            [30] = { pos = Vector(1917.82,-9215.47,-264) },
            [31] = { pos = Vector(1986.22,-9191.36,-264) },
            [32] = { pos = Vector(2640.35,-7951.96,16) },
            [33] = { pos = Vector(3786.5,4360.95,16) },
            [34] = { pos = Vector(3896.53,4363.47,16) },
            [35] = { pos = Vector(3795.32,4392.09,-397.28) },
            [36] = { pos = Vector(3682.61,4300.96,-389.811) },
            [37] = { pos = Vector(3427.23,4433.58,-401.92) },
            [38] = { pos = Vector(3229.05,4591.59,-400.2) },
            [39] = { pos = Vector(2941.68,4582.43,-399.412) },
            [40] = { pos = Vector(2598.52,4733.37,-378.607) },
            [41] = { pos = Vector(2383.64,4609.72,-382.009) },
            [42] = { pos = Vector(2463.52,4372.71,-404.403) },
            [43] = { pos = Vector(2427.34,4170.22,-377.865) },
            [44] = { pos = Vector(2475.49,3999.66,-398.918) },
            [45] = { pos = Vector(2423.32,3678.75,-376) },
            [46] = { pos = Vector(2539.98,3698.08,-376) },
            [47] = { pos = Vector(2506.28,3149.86,-376) },
            [48] = { pos = Vector(2395.35,3108.67,-376) },
            [49] = { pos = Vector(2465.37,2999.53,-376) },
            [50] = { pos = Vector(2477.53,2610.35,-376) },
            [51] = { pos = Vector(2683.9,2627.63,-376) },
            [52] = { pos = Vector(2687.09,2498.29,-376) },
            [53] = { pos = Vector(2152.11,2483.98,-376) },
            [54] = { pos = Vector(2018.34,2572.62,-376) },
            [55] = { pos = Vector(1876.49,2483.08,-376) },
            [56] = { pos = Vector(2119.2,2609.2,-376) },
            [57] = { pos = Vector(2067.3,2504.76,-376) },
            [58] = { pos = Vector(1964.16,2278.21,-376) },
            [59] = { pos = Vector(2052.66,2242.83,-376) },
            [60] = { pos = Vector(2206.71,2243.25,-376) },
            [61] = { pos = Vector(2918.75,2647.19,-376) },
            [62] = { pos = Vector(2706.68,2288.54,-376) },
            [63] = { pos = Vector(2603.17,2491.91,-696) },
            [64] = { pos = Vector(3179.19,2482.39,-696) },
            [65] = { pos = Vector(2391.2,2777.52,-696) },
            [66] = { pos = Vector(2485.66,2860.74,-696) },
            [67] = { pos = Vector(2578.25,2855.58,-696) },
            [68] = { pos = Vector(2394.01,2984,-696) },
            [69] = { pos = Vector(3444.78,2794.39,-696) },
            [70] = { pos = Vector(2688.7,2451.33,-1016) },
            [71] = { pos = Vector(2799.63,2547.09,-1016) },
            [72] = { pos = Vector(2691.13,2686.81,-1016) },
            [73] = { pos = Vector(2422.34,2684.2,-1016) },
            [74] = { pos = Vector(2412.78,2519.7,-1016) },
            [75] = { pos = Vector(2201.69,2507.62,-1016) },
            [76] = { pos = Vector(2270.93,2360.08,-1016) },
            [77] = { pos = Vector(2052.33,2157.9,-1016) },
            [78] = { pos = Vector(2464.53,2218.64,-1016) },
            [79] = { pos = Vector(2294.1,2903.75,-1016) },
            [80] = { pos = Vector(3221.99,3216.93,-1016) },
            [81] = { pos = Vector(3031.28,3178.64,-1016) },
            [82] = { pos = Vector(2891.94,3219.95,-1016) },
            [83] = { pos = Vector(3217.66,2917.84,-1016) },
            [84] = { pos = Vector(3038.13,2933.37,-1016) },
            [85] = { pos = Vector(3016.08,2702.89,-1016) },
            [86] = { pos = Vector(1992.89,3219.44,-1016) },
            [87] = { pos = Vector(2015.5,3341.14,-1016) },
            [88] = { pos = Vector(2083.27,3294.73,-1016) },
            [89] = { pos = Vector(2130.5,2938.69,-1016) },
            [90] = { pos = Vector(1966.36,2923.96,-1016) },
            [91] = { pos = Vector(1903,2996.41,-1016) },
            [92] = { pos = Vector(1678.7,3427.51,-1016) },
            [93] = { pos = Vector(1422.84,3376.02,-1016) },
            [94] = { pos = Vector(1674.52,3628.7,-1016) },
            [95] = { pos = Vector(1848.64,3632.29,-1016) },
            [96] = { pos = Vector(2041.47,3544.8,-1016) },
            [97] = { pos = Vector(2520.17,3226.51,-1016) },
            [98] = { pos = Vector(3827.72,2246.71,-696) },
            [99] = { pos = Vector(3609.77,2899.74,-696) },
            [100] = { pos = Vector(3162.8,2906.43,-696) }
        }
    }
}

function GM:InitPostEntity()
    for k = 1,#spawns[game.GetMap()].spectators do
        spawn = ents.Create("info_player_spectator")
        spawn:Spawn()
        spawn:SetPos(spawns[game.GetMap()].spectators[k].pos)
    end
    for k = 1,#spawns[game.GetMap()].survivors do
        spawn = ents.Create("info_player_survivor")
        spawn:Spawn()
        spawn:SetPos(spawns[game.GetMap()].survivors[k].pos)
    end
    for k = 1,#spawns[game.GetMap()].usmc do
        spawn = ents.Create("info_player_usmc")
        spawn:Spawn()
        spawn:SetPos(spawns[game.GetMap()].usmc[k].pos)
    end
end

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
        loot_spawn_system.LootCount = loot_spawn_system.LootCount - 1
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

local function RunEquipment(ply)
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
        local usmc_spawns = ents.FindByClass("info_player_usmc")
        local random_entry = math.random(#usmc_spawns)

        return usmc_spawns[random_entry]
    elseif ply:GetNWString("Faction") == "Survivor" then
        local survivor_spawns = ents.FindByClass("info_player_survivor")
        local random_entry = math.random(#survivor_spawns)

        return survivor_spawns[random_entry]
    elseif player_manager.GetPlayerClass(ply) == "player_spectator" then
        local spectator_spawns = ents.FindByClass("info_player_spectator")
        local random_entry = math.random(#spectator_spawns)

        return spectator_spawns[random_entry]
    end
end

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

local function RemoveAmmoFromBoxes(index, AmmoCountToRemove, key, ply)
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
    if player_manager.GetPlayerClass(ply) ~= "player_spectator" then
        sql.Query("DELETE FROM mvsa_characters WHERE SteamID64 = " .. tostring(ply:SteamID64()) .. " AND RPName = " .. "'" .. ply.RPName .. "'")
        player_manager.SetPlayerClass(ply, "player_spectator")
    end
end

local CleanupDelay = 0
local StartingIndex = 0

local function AutoCleanup()
    if CurTime() > CleanupDelay then
        CleanupDelay = CurTime() + 500
        local TempTable = ents.GetAll()
        if StartingIndex == 0 then
            StartingIndex = #TempTable
        end
        for k = StartingIndex, #TempTable do
            TempTable[k]:RemoveAllDecals()
            if TempTable[k]:IsRagdoll() then
                TempTable[k]:Remove()
            end
        end
    end
end

local function NPCSpawnSystem()
    if npc_spawn_system.SpawnDelay < CurTime() then
        npc_spawn_system.SpawnDelay = CurTime() + 20
        for k, v in pairs( player.GetAll() ) do
            local PlayerPos = v:GetPos()
            for i, platform in pairs( spawns[game.GetMap()].zombies ) do
                if not platform.npc or not platform.npc:IsValid() then
                    local distance = PlayerPos:Distance( platform.pos )
                    if distance > npc_spawn_system.MinSpawnDistance and distance < npc_spawn_system.MaxSpawnDistance and npc_spawn_system.NPCCount < npc_spawn_system.NPCLimit then
                        platform.npc = ents.Create( table.Random(NPCList))
                        platform.npc:SetPos(platform.pos)
                        platform.npc:Spawn()
                        npc_spawn_system.NPCCount = npc_spawn_system.NPCCount + 1
                    end
                end
            end
        end
    end
end

local function LootSpawnSystem()
    if loot_spawn_system.SpawnDelay < CurTime() and loot_spawn_system.LootCount < loot_spawn_system.LootLimit then
        loot_spawn_system.SpawnDelay = CurTime() + 20
        for k, v in pairs( player.GetAll() ) do
            local PlayerPos = v:GetPos()
            for i, platform in pairs( loot[game.GetMap()] ) do
                if not platform.ent or not platform.ent:IsValid() then
                    local distance = PlayerPos:Distance( platform.pos )
                    if distance > loot_spawn_system.MinSpawnDistance and distance < loot_spawn_system.MaxSpawnDistance then
                        platform.ent = ents.Create( table.Random(LootList) )
                        platform.ent:SetPos(platform.pos)
                        platform.ent:Spawn()
                    end
                end
            end
        end
    end
end

local function Gas(ply)
    if CurTime() > gasTriggerDelay then
        gasTriggerDelay = CurTime() + 2
        plyPos = ply:GetPos()
        map = game.GetMap()
        for k = 1,#gas_zones[map] do
            if plyPos.x > gas_zones[map][k].x1 and plyPos.x < gas_zones[map][k].x2 and plyPos.y > gas_zones[map][k].y1 and plyPos.y < gas_zones[map][k].y2 and plyPos.z > gas_zones[map][k].z1 and plyPos.z < gas_zones[map][k].z2 then
                ply:TakeDamageInfo( GasDamage )
            end
        end
    end
end

function GM:PlayerPostThink( ply )
    Gas(ply)
end

function GM:Think()
    AutoCleanup()
    NPCSpawnSystem()
    LootSpawnSystem()
end

function GM:OnNPCKilled( npc, attacker, inflictor )
    npc_spawn_system.NPCCount = npc_spawn_system.NPCCount - 1
end

function GM:PostCleanupMap()
    npc_spawn_system.NPCCount = 0
    loot_spawn_system.LootCount = 0
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