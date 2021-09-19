AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.StartingIndex = 1 -- where the inventory index of the player start
ENT.Slot1 = 1
ENT.Slot2 = 1
ENT.Category = "Pant"
ENT.ID = 3

function ENT:Initialize()
    LootCount = LootCount + 1
    self:SetModel(self.Model)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
    self:PhysWake()
end

function ENT:Use(activator, caller, useType, value)
    if activator:GetNWInt( self.Category ) < 2 and player_manager.GetPlayerClass(activator) == "player_usmc" then
        LootCount = LootCount - 1
        PickupContainer( activator, self )
    elseif player_manager.GetPlayerClass(activator) ~= "player_usmc" then
        activator:ChatPrint("You can't take it")
    end
end