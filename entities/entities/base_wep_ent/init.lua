AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.WepName = "m9k_m4a1"
ENT.Ammo = "5.56x45mm NATO"
ENT.ID = 9

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
    if CurTime() > activator:GetNWInt("PickupDelay") then
        activator:SetNWInt("PickupDelay", CurTime() + 1)
        if activator:GetNWInt( self.Category ) < 2 then
            loot_spawn_system.LootCount = loot_spawn_system.LootCount - 1
            PickupWep(activator, self)
        else
            local oldEnt = ents.Create(EntList[activator:GetNWInt( self.Category )].className)
            local wep_class = EntList[activator:GetNWInt( self.Category )].wep
            local wep = activator:GetWeapon(wep_class)
            oldEnt.PreviousMag = wep:Clip1()
            activator:StripWeapon(wep_class)
            oldEnt:Spawn()
            oldEnt:SetPos( activator:GetEyeTraceNoCursor()["HitPos"] )
            PickupWep(activator, self)
        end
    end
end