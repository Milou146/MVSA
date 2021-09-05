AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Delay = 0

function ENT:Initialize()
    -- Sets what model to use
    self:SetModel(self.Model)
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
    for k = 1,20 do
        if activator:GetNWInt("Inventory" .. tostring(k)) == 1 then
            activator.GasMaskEquiped = true
            activator:SetNWInt( "Inventory" .. tostring(k), 2 )
            self.Taken = true
            break
        end
    end
    if self.Taken then -- the gas mask is taken
        local Inventory = {}
        for k = 1,20 do
            Inventory[k] = activator:GetNWInt("Inventory" .. tostring(k))
        end
        Inventory = table.concat(Inventory, ",")
        sql.Query("UPDATE mvsa_player_character SET Inventory = '" .. Inventory .. "' WHERE SteamID64 = " .. tostring(activator:SteamID64()) .. " AND RPName = " .. "'" .. activator.RPName .. "'")
        self:Remove()
    elseif CurTime() > self.Delay then
        self.Delay = CurTime() + 2
        activator:ChatPrint("You are full!")
    end
end