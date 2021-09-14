AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel(self.Model)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:PhysWake()
end

function ENT:Use(activator, caller, useType, value)
    if activator:GetNWInt( "PrimaryWep" ) < 2 then
        local ent = ents.Create( "m9k_m4a1" )
        ent.Primary.DefaultClip = ent.Primary.ClipSize
        ent.Primary.Ammo = "5.56×45mm NATO"
        activator:PickupWeapon(ent)
        ent:SetClip1( self.PreviousMag or ent.Primary.ClipSize )
        activator:SetNWInt( "PrimaryWep", 9 )
        sql.Query("UPDATE mvsa_characters SET PrimaryWep = 9 WHERE SteamID64 = " .. tostring(activator:SteamID64()) .. " AND RPName = " .. "'" .. activator.RPName .. "'")
        self:Remove()
    end
end