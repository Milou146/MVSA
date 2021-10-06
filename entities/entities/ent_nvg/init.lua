AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    loot_spawn_system.LootCount = loot_spawn_system.LootCount + 1
    self:SetModel(self.Model)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
    self:PhysWake()
end

function ENT:Use(activator, caller, useType, value)
    if activator:GetNWInt( "NVG" ) < 2 and activator:GetNWInt("Helmet") > 1 then
        loot_spawn_system.LootCount = loot_spawn_system.LootCount - 1
        activator:SetNWInt( "NVG", 7 )
        activator:SetBodygroup(self.BodyGroup[activator:GetNWString("Faction")][activator:GetNWInt("ModelIndex")][1], self.BodyGroup[activator:GetNWString("Faction")][activator:GetNWInt("ModelIndex")][2])
        sql.Query("UPDATE mvsa_characters SET NVG = 7 WHERE SteamID64 = " .. tostring(activator:SteamID64()) .. " AND RPName = " .. "'" .. activator.RPName .. "'")
        local BodyGroups = tostring(activator:GetBodygroup(0))
        for k = 1,activator:GetNumBodyGroups() - 1 do
            BodyGroups = BodyGroups .. "," .. tostring(activator:GetBodygroup(k))
        end
        sql.Query("UPDATE mvsa_characters SET BodyGroups = '" .. BodyGroups .. "' WHERE SteamID64 = " .. tostring(activator:SteamID64()) .. " AND RPName = " .. "'" .. activator.RPName .. "'")
        self:Remove()
    else
        for k = 1,20 do
            if activator:GetNWInt("Inventory" .. tostring(k)) == 1 then
                activator:SetNWInt( "Inventory" .. tostring(k), 7 )
                self.Taken = true
                break
            end
        end
        if self.Taken then
            local Inventory = {}
            for k = 1,20 do
                Inventory[k] = activator:GetNWInt("Inventory" .. tostring(k))
            end
            Inventory = table.concat(Inventory, ",")
            sql.Query("UPDATE mvsa_characters SET Inventory = '" .. Inventory .. "' WHERE SteamID64 = " .. tostring(activator:SteamID64()) .. " AND RPName = " .. "'" .. activator.RPName .. "'")
            self:Remove()
        elseif CurTime() > self.Delay then
            self.Delay = CurTime() + 2
            activator:ChatPrint("You are full!")
        end
    end
end