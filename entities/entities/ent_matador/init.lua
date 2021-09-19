AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

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
    if activator:GetNWInt( "Launcher" ) < 2 then
        LootCount = LootCount - 1
        local ent = ents.Create( "m9k_matador" )
        ent.Primary.DefaultClip = ent.Primary.ClipSize
        activator:PickupWeapon(ent)
        ent:SetClip1( self.PreviousMag or ent.Primary.ClipSize )
        activator:SetNWInt( "Launcher", 11 )
        sql.Query("UPDATE mvsa_characters SET Launcher = 11 WHERE SteamID64 = " .. tostring(activator:SteamID64()) .. " AND RPName = " .. "'" .. activator.RPName .. "'")
        self:Remove()
    end
end