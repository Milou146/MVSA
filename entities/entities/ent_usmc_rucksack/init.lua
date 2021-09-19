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
ENT.Category = "Rucksack"
ENT.ID = 8

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
    if activator:GetNWInt( self.Category ) < 2 then
        LootCount = LootCount - 1
        PickupContainer( activator, self )
    end
end