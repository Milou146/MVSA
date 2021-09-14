AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.StartingIndex = 11
ENT.Slot11 = 1
ENT.Slot12 = 1
ENT.Slot13 = 1
ENT.Slot14 = 1
ENT.Slot15 = 1
ENT.Slot16 = 1
ENT.Slot17 = 1
ENT.Slot18 = 1
ENT.Slot19 = 1
ENT.Slot20 = 1

function ENT:Initialize()
    self:SetModel(self.Model)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:PhysWake()
end

function ENT:Use(activator, caller, useType, value)
    if activator:GetNWInt( "Rucksack" ) < 2 then
        activator:SetNWInt( "Rucksack", 8 )
        activator:SetBodygroup(self.BodyGroup[activator:GetNWString("Faction")][activator:GetNWInt("ModelIndex")][1], self.BodyGroup[activator:GetNWString("Faction")][activator:GetNWInt("ModelIndex")][2])
        sql.Query("UPDATE mvsa_characters SET Rucksack = 8 WHERE SteamID64 = " .. tostring(activator:SteamID64()) .. " AND RPName = " .. "'" .. activator.RPName .. "'")
        local BodyGroups = tostring(activator:GetBodygroup(0))
        for k = 1,activator:GetNumBodyGroups() - 1 do
            BodyGroups = BodyGroups .. "," .. tostring(activator:GetBodygroup(k))
        end
        sql.Query("UPDATE mvsa_characters SET BodyGroups = '" .. BodyGroups .. "' WHERE SteamID64 = " .. tostring(activator:SteamID64()) .. " AND RPName = " .. "'" .. activator.RPName .. "'")
        local Inventory = {}
        for k = 1,10 do
            Inventory[k] = activator:GetNWInt("Inventory" .. tostring(k))
        end
        for k = 11,20 do
            Inventory[k] = self["Slot" .. tostring(k)]
            activator:SetNWInt("Inventory" .. tostring(k), self["Slot" .. tostring(k)])
            if EntList[self["Slot" .. tostring(k)]].ammoName then
                activator:GiveAmmo( self["Slot" .. tostring(k) .. "AmmoCount"], EntList[self["Slot" .. tostring(k)]].ammoName )
                activator:SetNWInt("AmmoBox" .. tostring(k), self["Slot" .. tostring(k) .. "AmmoCount"])
            end
        end
        Inventory = table.concat(Inventory, ",")
        sql.Query("UPDATE mvsa_characters SET Inventory = '" .. Inventory .. "' WHERE SteamID64 = " .. tostring(activator:SteamID64()) .. " AND RPName = " .. "'" .. activator.RPName .. "'")
        self:Remove()
    end
end