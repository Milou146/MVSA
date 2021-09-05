AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    -- Sets what model to use
    self:SetModel("models/weapons/w_m4a1_iron.mdl")
    -- Sets what color to use
    self:SetColor(Color(200, 255, 200))
    -- Physics stuff
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    -- Init physics only on server, so it doesn't mess up physgun beam
    if (SERVER) then
        self:PhysicsInit(SOLID_VPHYSICS)
    end

    -- Make prop to fall on spawn
    self:PhysWake()
end

function ENT:Use(activator, caller, useType, value)
    if activator:GetNWInt( "PrimaryWep" ) < 2 then
        local ent = ents.Create( "m9k_m4a1" )
        ent.Primary.DefaultClip = ent.Primary.ClipSize
        activator:PickupWeapon(ent)
        ent:SetClip1( self.PreviousMag or ent.Primary.ClipSize )
        activator:SetNWInt( "PrimaryWep", 9 )
        sql.Query("UPDATE mvsa_player_character SET PrimaryWep = 9 WHERE SteamID64 = " .. tostring(activator:SteamID64()) .. " AND RPName = " .. "'" .. activator.RPName .. "'")
        self:Remove()
    end
end