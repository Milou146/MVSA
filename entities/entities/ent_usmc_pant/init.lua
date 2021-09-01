AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    -- Sets what model to use
    self:SetModel("models/half-dead/metroll/p_mask_1.mdl")
    self:SetName("USMC Pant")
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
    if activator.GasMaskEquiped then
        activator:ChatPrint("Gas mask already equipped!")
    else
        for k, v in pairs(activator.Inventory) do
            if v == '0' then
                activator.Inventory[k] = "1"
                activator.GasMaskEquiped = true
                sql.Query("UPDATE mvsa_player_character SET Inventory" .. k .. " = 1 WHERE SteamID64 = " .. tostring(activator:SteamID64()) .. " AND RPName = " .. "'" .. activator.RPName .. "'")
                break
            end
        end
        activator:Give("weapon_gasmask")
        activator.GasMaskEquiped = true
        activator:ChatPrint("Gas mask equipped!")
        self:Remove()
    end
end