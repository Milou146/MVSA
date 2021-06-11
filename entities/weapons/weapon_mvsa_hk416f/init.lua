AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include("shared.lua")

SWEP.Weight			= 5		-- Decides whether we should switch from/to this
SWEP.AutoSwitchTo	= false	-- Auto switch to if we pick it up
SWEP.AutoSwitchFrom	= false	-- Auto switch from if you pick up a better weapon