AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Delay = 0

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
    if activator:GetNWInt("GasMask") < 2 then
        LootCount = LootCount - 1
        activator:SetNWInt("GasMask", 2)
        sql.Query("UPDATE mvsa_characters SET GasMask = 2 WHERE SteamID64 = " .. tostring(activator:SteamID64()) .. " AND RPName = " .. "'" .. activator.RPName .. "'")
        if self.BodyGroup[activator:GetNWString("Faction")] then -- the playermodel might not have this specific bodygroup
            activator:SetBodygroup(self.BodyGroup[activator:GetNWString("Faction")][activator:GetNWInt("ModelIndex")][1], self.BodyGroup[activator:GetNWString("Faction")][activator:GetNWInt("ModelIndex")][2])
            local BodyGroups = tostring(activator:GetBodygroup(0))
            for k = 1,activator:GetNumBodyGroups() - 1 do
                BodyGroups = BodyGroups .. "," .. tostring(activator:GetBodygroup(k))
            end
            sql.Query("UPDATE mvsa_characters SET BodyGroups = '" .. BodyGroups .. "' WHERE SteamID64 = " .. tostring(activator:SteamID64()) .. " AND RPName = " .. "'" .. activator.RPName .. "'")
        end
        self:Remove()
    else
        for k = 1,20 do
            if activator:GetNWInt("Inventory" .. tostring(k)) == 1 then
                activator:SetNWInt( "Inventory" .. tostring(k), 2 )
                self.Taken = true
                break
            end
        end
        if self.Taken then -- the gas mask is taken
            SaveInventoryData(activator)
            self:Remove()
        elseif CurTime() > self.Delay then
            self.Delay = CurTime() + 2
            activator:ChatPrint("You are full!")
        end
    end
end