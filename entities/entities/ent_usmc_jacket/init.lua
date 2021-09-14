AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.StartingIndex = 3
ENT.Slot3 = 1
ENT.Slot4 = 1
ENT.Slot5 = 1

function ENT:Initialize()
    self:SetModel(self.Model)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:PhysWake()
end

function ENT:Use(activator, caller, useType, value)
    if activator:GetNWInt( "Jacket" ) < 2 then
        activator:SetNWInt( "Jacket", 4 )
        activator:SetBodygroup(self.BodyGroup[activator:GetNWString("Faction")][activator:GetNWInt("ModelIndex")][1], self.BodyGroup[activator:GetNWString("Faction")][activator:GetNWInt("ModelIndex")][2])
        sql.Query("UPDATE mvsa_characters SET Jacket = 4 WHERE SteamID64 = " .. tostring(activator:SteamID64()) .. " AND RPName = " .. "'" .. activator.RPName .. "'")
        local BodyGroups = tostring(activator:GetBodygroup(0))
        for k = 1,activator:GetNumBodyGroups() - 1 do
            BodyGroups = BodyGroups .. "," .. tostring(activator:GetBodygroup(k))
        end
        sql.Query("UPDATE mvsa_characters SET BodyGroups = '" .. BodyGroups .. "' WHERE SteamID64 = " .. tostring(activator:SteamID64()) .. " AND RPName = " .. "'" .. activator.RPName .. "'")
        local Inventory = {
            [1] = activator:GetNWInt("Inventory1"),
            [2] = activator:GetNWInt("Inventory2")
        }
        for k = 3,5 do
            Inventory[k] = self["Slot" .. tostring(k)]
            activator:SetNWInt("Inventory" .. tostring(k), self["Slot" .. tostring(k)])
            if EntList[self["Slot" .. tostring(k)]].ammoName then
                activator:GiveAmmo( self["Slot" .. tostring(k) .. "AmmoCount"], EntList[self["Slot" .. tostring(k)]].ammoName )
                activator:SetNWint("AmmoBox" .. tostring(k), self["Slot" .. tostring(k) .. "AmmoCount"])
            end
        end
        for k = 6,20 do
            Inventory[k] = activator:GetNWInt("Inventory" .. tostring(k))
        end
        Inventory = table.concat(Inventory, ",")
        sql.Query("UPDATE mvsa_characters SET Inventory = '" .. Inventory .. "' WHERE SteamID64 = " .. tostring(activator:SteamID64()) .. " AND RPName = " .. "'" .. activator.RPName .. "'")
        self:Remove()
    end
end