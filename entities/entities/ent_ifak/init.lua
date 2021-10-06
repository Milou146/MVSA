AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Delay = 0

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
        for k = 1,20 do
            if activator:GetNWInt("Inventory" .. tostring(k)) == 1 then
                activator:SetNWInt( "Inventory" .. tostring(k), 53 )
                self.Taken = true
                loot_spawn_system.LootCount = loot_spawn_system.LootCount - 1
                break
            end
        end
        if self.Taken then
            SaveInventoryData(activator)
            activator:Give("weapon_ifak")
            self:Remove()
        elseif CurTime() > self.Delay then
            self.Delay = CurTime() + 2
            activator:ChatPrint("You are full!")
        end
end