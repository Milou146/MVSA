AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.StartingIndex = 3
ENT.Slot3 = 1
ENT.Slot4 = 1
ENT.Slot5 = 1
ENT.Category = "Jacket"
ENT.ID = 4

function ENT:Initialize()
    LootCount = LootCount + 1
    self:SetModel(self.Model)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:PhysWake()
end

function ENT:Use(activator, caller, useType, value)
    if activator:GetNWInt( self.Category ) < 2 then
        LootCount = LootCount - 1
        PickupContainer( activator, self )
    end
end