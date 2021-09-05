AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    -- Sets what model to use
    self:SetModel("models/yukon/conscripts/hecu_jacket.mdl")
    -- Sets what color to use
    self:SetColor(Color(200, 255, 200))
    -- Physics stuff
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    -- Init physics only on server, so it doesn't mess up physgun beam
    self:PhysicsInit(SOLID_VPHYSICS)

    -- Make prop to fall on spawn
    self:PhysWake()
end

function ENT:Use(activator, caller, useType, value)
    if activator:GetNWInt( "Jacket" ) < 2 then
        activator:SetNWInt( "Jacket", 4 )
        activator:SetBodygroup(self.BodyGroup[activator:GetNWString("Faction")][activator:GetNWInt("ModelIndex")][1], self.BodyGroup[activator:GetNWString("Faction")][activator:GetNWInt("ModelIndex")][2])
        sql.Query("UPDATE mvsa_player_character SET Jacket = 4 WHERE SteamID64 = " .. tostring(activator:SteamID64()) .. " AND RPName = " .. "'" .. activator.RPName .. "'")
        local BodyGroups = tostring(activator:GetBodygroup(0))
        for k = 1,activator:GetNumBodyGroups() - 1 do
            BodyGroups = BodyGroups .. "," .. tostring(activator:GetBodygroup(k))
        end
        sql.Query("UPDATE mvsa_player_character SET BodyGroups = '" .. BodyGroups .. "' WHERE SteamID64 = " .. tostring(activator:SteamID64()) .. " AND RPName = " .. "'" .. activator.RPName .. "'")
        local Inventory = {
            [1] = activator:GetNWInt("Inventory1"),
            [2] = activator:GetNWInt("Inventory2"),
            [3] = 1,
            [4] = 1,
            [5] = 1
        }
        for k = 3,5 do
            activator:SetNWInt("Inventory" .. tostring(k), 1)
        end
        for k = 6,20 do
            Inventory[k] = activator:GetNWInt("Inventory" .. tostring(k))
        end
        Inventory = table.concat(Inventory, ",")
        sql.Query("UPDATE mvsa_player_character SET Inventory = '" .. Inventory .. "' WHERE SteamID64 = " .. tostring(activator:SteamID64()) .. " AND RPName = " .. "'" .. activator.RPName .. "'")
        self:Remove()
    end
end