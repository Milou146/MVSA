GM.Name = "MilitaryRP"
GM.Author = "N/A"
GM.Email = "N/A"
GM.Website = "N/A"
DeriveGamemode( "sandbox" )

include( "player_class/player_usmc.lua" )
include( "player_class/player_survivor.lua" )
include( "player_class/player_spectator.lua" )
include( "sh_config.lua" )

function GM:Initialize()
	game.AddAmmoType( {
		name = "5.56×45mm NATO",
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE_AND_WHIZ,
		force = 2000,
		minsplash = 5,
		maxsplash = 15
	} )
	game.AddAmmoType( {
		name = "5.45x39mm M74",
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE_AND_WHIZ,
		force = 2000,
		minsplash = 5,
		maxsplash = 15
	} )
	game.AddAmmoType( {
		name = "9×19mm Parabellum",
		dmgtype = DMG_BULLET,
		tracer = TRACER_NONE,
		force = 1000,
		minsplash = 5,
		maxsplash = 10
	} )
	game.AddAmmoType( {
		name = ".45 ACP",
		dmgtype = DMG_BULLET,
		tracer = TRACER_NONE,
		force = 1500,
		minsplash = 5,
		maxsplash = 10
	} )
	game.AddAmmoType( {
		name = "12 Gauge",
		dmgtype = DMG_BULLET,
		tracer = TRACER_NONE,
		force = 1500,
		minsplash = 2,
		maxsplash = 7
	} )
	game.AddAmmoType( {
		name = "7.62×51mm NATO",
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE_AND_WHIZ,
		force = 3000,
		minsplash = 5,
		maxsplash = 15
	} )
	game.AddAmmoType( {
		name = "7.62×39mm M43",
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE_AND_WHIZ,
		force = 3000,
		minsplash = 5,
		maxsplash = 15
	} )
	game.AddAmmoType( {
		name = "7.62×54mm R",
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE_AND_WHIZ,
		force = 3000,
		minsplash = 5,
		maxsplash = 15
	} )
	game.AddAmmoType( {
		name = ".50 BMG",
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE_AND_WHIZ,
		force = 4000,
		minsplash = 5,
		maxsplash = 20
	} )
	game.AddAmmoType( {
		name = ".357 Magnum",
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE_AND_WHIZ,
		force = 4000,
		minsplash = 5,
		maxsplash = 20
	} )
	game.AddAmmoType( {
		name = "90mm HESH",
		dmgtype = DMG_BLAST,
		tracer = TRACER_NONE,
		force = 10000,
		minsplash = 20,
		maxsplash = 50
	} )
end