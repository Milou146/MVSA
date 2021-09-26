AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.WepName = "m9k_g3a3"
ENT.Ammo = "7.62x51mm NATO"
ENT.ID = 23

function ENT:Initialize()
    LootCount = LootCount + 1
    self:SetModel(self.Model)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
    self:PhysWake()
end

local delay = 0

function ENT:Use(activator, caller, useType, value)
    if CurTime() > delay then
        delay = CurTime() + 5
        if activator:GetNWInt( self.Category ) < 2 then
            LootCount = LootCount - 1
            PickupWep(activator, self)
        else
            local ent = ents.Create(EntList[activator:GetNWInt( self.Category )].className)
            local wep_class = EntList[activator:GetNWInt( self.Category )].wep
            local wep = activator:GetWeapon(wep_class)
            ent.PreviousMag = wep:Clip1()
            activator:StripWeapon(wep_class)
            ent:Spawn()
            ent:SetPos( activator:GetEyeTraceNoCursor()["HitPos"] )
            PickupWep(activator, self)
        end
    end
end