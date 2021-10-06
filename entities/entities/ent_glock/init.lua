AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.ID = 30
ENT.WepName = EntList[ENT.ID].wep
ENT.Ammo = EntList[ENT.ID].ammo