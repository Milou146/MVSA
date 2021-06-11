AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include("shared.lua")

SWEP.Weight			= 5		-- Decides whether we should switch from/to this
SWEP.AutoSwitchTo	= false	-- Auto switch to if we pick it up
SWEP.AutoSwitchFrom	= false	-- Auto switch from if you pick up a better weapon

sound.Add({
	name = 			"Weapon_AR15.Single",
	channel = 		CHAN_USER_BASE + 10,
	volume = 		1.0,
	sound = {"weapons/ar15/fire1.wav",
			"weapons/ar15/fire2.wav",
			"weapons/ar15/fire3.wav",
			"weapons/ar15/fire4.wav"}
})