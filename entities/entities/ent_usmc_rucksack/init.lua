AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    -- Sets what model to use
    self:SetModel("models/yukon/conscripts/rucksack.mdl")
    -- Sets what color to use
    self:SetColor(Color(200, 255, 200))
    -- Physics stuff
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    -- Init physics only on server, so it doesn't mess up physgun beam
    if (SERVER) then
        self:PhysicsInit(SOLID_VPHYSICS)
    end

    -- Make prop to fall on spawn
    self:PhysWake()
end

function ENT:Use(activator, caller, useType, value)
    if activator:GetNWInt( "Rucksack" ) < 2 then
        activator:SetNWInt( "Rucksack", 8 )
        activator:SetBodygroup(self.BodyGroup[activator:GetNWString("Faction")][activator:GetNWInt("ModelIndex")][1], self.BodyGroup[activator:GetNWString("Faction")][activator:GetNWInt("ModelIndex")][2])
        sql.Query("UPDATE mvsa_player_character SET Rucksack = 8 WHERE SteamID64 = " .. tostring(activator:SteamID64()) .. " AND RPName = " .. "'" .. activator.RPName .. "'")
        local BodyGroups = tostring(activator:GetBodygroup(0))
        for k = 1,activator:GetNumBodyGroups() - 1 do
            BodyGroups = BodyGroups .. "," .. tostring(activator:GetBodygroup(k))
        end
        sql.Query("UPDATE mvsa_player_character SET BodyGroups = '" .. BodyGroups .. "' WHERE SteamID64 = " .. tostring(activator:SteamID64()) .. " AND RPName = " .. "'" .. activator.RPName .. "'")
        local Inventory = {}
        for k = 1,10 do
            Inventory[k] = activator:GetNWInt("Inventory" .. tostring(k))
        end
        for k = 11,20 do
            Inventory[k] = 1
            activator:SetNWInt("Inventory" .. tostring(k), 1)
        end
        Inventory = table.concat(Inventory, ",")
        sql.Query("UPDATE mvsa_player_character SET Inventory = '" .. Inventory .. "' WHERE SteamID64 = " .. tostring(activator:SteamID64()) .. " AND RPName = " .. "'" .. activator.RPName .. "'")
        self:Remove()
    end
end