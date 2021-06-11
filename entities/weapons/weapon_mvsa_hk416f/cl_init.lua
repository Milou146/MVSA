include('shared.lua')

SWEP.Category			= 'MVSA'
SWEP.Slot				= 1						-- Slot in the weapon selection menu
SWEP.SlotPos			= 1						-- Position in the slot
SWEP.DrawAmmo			= true					-- Should draw the default HL2 ammo counter
SWEP.DrawCrosshair		= true					-- Should draw the default crosshair
SWEP.DrawWeaponInfoBox	= true					-- Should draw the weapon info box
SWEP.BounceWeaponIcon	= true					-- Should the weapon icon bounce?
SWEP.SwayScale			= 1.0					-- The scale of the viewmodel sway
SWEP.BobScale			= 1.0					-- The scale of the viewmodel bob

sound.Add({
	name = 			'Weapon_AR15.Single',
	channel = 		CHAN_USER_BASE + 10,
	volume = 		1.0,
	sound = {'weapons/ar15/fire1.wav',
			'weapons/ar15/fire2.wav',
			'weapons/ar15/fire3.wav',
			'weapons/ar15/fire4.wav'}
})

sound.Add({
	name = 			'Weapon_AR15.magout',
	channel = 		CHAN_USER_BASE + 10,
	volume = 		1.0,
	sound = 			'weapons/ar15/magout.wav'
})
sound.Add({
	name = 			'Weapon_AR15.magin',
	channel = 		CHAN_USER_BASE + 10,
	volume = 		1.0,
	sound = 			'weapons/ar15/magin.wav'
})
sound.Add({
	name = 			'Weapon_AR15.boltrelease',
	channel = 		CHAN_USER_BASE + 10,
	volume = 		1.0,
	sound = 			'weapons/ar15/boltrelease.wav'
})