AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.ID = 6
ENT.Armor = EntList[ENT.ID].armor

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
    if activator:GetNWInt( "Helmet" ) < 2 then
        loot_spawn_system.LootCount = loot_spawn_system.LootCount - 1
        activator:SetNWInt("HelmetArmor", self.Armor)
        activator:SetNWInt( "Helmet", 6 )
        activator:SetBodygroup(self.BodyGroup[activator:GetNWString("Faction")][activator:GetNWInt("ModelIndex")][1], self.BodyGroup[activator:GetNWString("Faction")][activator:GetNWInt("ModelIndex")][2])
        sql.Query("UPDATE mvsa_characters SET Helmet = 6 WHERE SteamID64 = " .. tostring(activator:SteamID64()) .. " AND RPName = " .. "'" .. activator.RPName .. "'")
        local BodyGroups = tostring(activator:GetBodygroup(0))
        for k = 1,activator:GetNumBodyGroups() - 1 do
            BodyGroups = BodyGroups .. "," .. tostring(activator:GetBodygroup(k))
        end
        sql.Query("UPDATE mvsa_characters SET BodyGroups = '" .. BodyGroups .. "' WHERE SteamID64 = " .. tostring(activator:SteamID64()) .. " AND RPName = " .. "'" .. activator.RPName .. "'")
        self:Remove()
    end
end