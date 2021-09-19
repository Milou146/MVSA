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
    if activator:GetNWInt( "SecondaryWep" ) < 2 then
        LootCount = LootCount - 1
        local ent = ents.Create( "m9k_m92beretta" )
        ent.Primary.DefaultClip = ent.Primary.ClipSize
        ent.Primary.Ammo = "9×19mm Parabellum"
        activator:PickupWeapon(ent)
        ent:SetClip1( self.PreviousMag or ent.Primary.ClipSize )
        activator:SetNWInt( "SecondaryWep", 10 )
        sql.Query("UPDATE mvsa_characters SET SecondaryWep = 10 WHERE SteamID64 = " .. tostring(activator:SteamID64()) .. " AND RPName = " .. "'" .. activator.RPName .. "'")
        self:Remove()
    end
end