AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Delay = 0
ENT.ID = 13

function ENT:Initialize()
    self:SetModel(self.Model)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:PhysWake()
end

function ENT:Use(activator, caller, useType, value)
    AmmoBoxPickup(activator, self)
end