PlayerModels = {}
PlayerModels.USMC = {
    [1] = {
        model = "models/yukon/conscripts/conscript_a_w_pm_v2.mdl",
        skins = {0,1,2,3,4,5,6,7,8,9,10,11,12,13}, -- authorized skins
        bodygroups = {0,3,0,1,{0,2},0,0,1,1,2,{17},0,{0,1,2},0,0,0,0,0,1}, -- authorized bodygroups
        gasmask_bodygroup = {17,2,1}, -- gasmak bodygroup ID, bodygroup value when gasmask set, bodygroup value when gasmask unset
        nvg_bodygroup = {16,9,10} -- same for the NVG
    },
    [2] = {
        model = "models/yukon/conscripts/conscript_a_b_pm_v2.mdl",
        skins = {0,1,2,3,4,5},
        bodygroups = {0,3,0,1,{0,2},0,0,1,1,2,{17},0,{0,1,2},0,0,0,0,0,1},
        gasmask_bodygroup = {17,2,1},
        nvg_bodygroup = {16,9,10}
    },
}
PlayerModels.Survivor = {
    [1] = {
        model = "models/survivors/group02/male_01.mdl",
        skins = 0,
        bodygroups = {0,0,0,0,0,0,0,0},
        gasmask_bodygroup = {7,2,1},
        nvg_bodygroup = {6,9,10}
    },
    [2] = {
        model = "models/survivors/group02/male_03.mdl",
        skins = 0,
        bodygroups = {0,0,0,0,0,0,0,0},
        gasmask_bodygroup = {7,2,1},
        nvg_bodygroup = {6,9,10}
    },
    [3] = {
        model = "models/survivors/group02/male_04.mdl",
        skins = 0,
        bodygroups = {0,0,0,0,0,0,0,0},
        gasmask_bodygroup = {7,2,1},
        nvg_bodygroup = {6,9,10}
    },
    [4] = {
        model = "models/survivors/group02/male_05.mdl",
        skins = 0,
        bodygroups = {0,0,0,0,0,0,0,0},
        gasmask_bodygroup = {7,2,1},
        nvg_bodygroup = {6,9,10}
    },
    [5] = {
        model = "models/survivors/group02/male_06.mdl",
        skins = 0,
        bodygroups = {0,0,0,0,0,0,0,0},
        gasmask_bodygroup = {7,2,1},
        nvg_bodygroup = {6,9,10}
    },
    [6] = {
        model = "models/survivors/group02/male_07.mdl",
        skins = 0,
        bodygroups = {0,0,0,0,0,0,0,0},
        gasmask_bodygroup = {7,2,1},
        nvg_bodygroup = {6,9,10}
    },
    [7] = {
        model = "models/survivors/group02/male_08.mdl",
        skins = 0,
        bodygroups = {0,0,0,0,0,0,0,0},
        gasmask_bodygroup = {7,2,1},
        nvg_bodygroup = {6,9,10}
    },
    [8] = {
        model = "models/survivors/group02/male_09.mdl",
        skins = 0,
        bodygroups = {0,0,0,0,0,0,0,0},
        gasmask_bodygroup = {7,2,1},
        nvg_bodygroup = {6,9,10}
    },
    [9] = {
        model = "models/survivors/group02/female_01.mdl",
        skins = 0,
        bodygroups = {0,0,0,0,0,0,0,0},
        gasmask_bodygroup = {7,2,1},
        nvg_bodygroup = {6,9,10}
    },
    [10] = {
        model = "models/survivors/group02/female_02.mdl",
        skins = 0,
        bodygroups = {0,0,0,0,0,0,0,0},
        gasmask_bodygroup = {7,2,1},
        nvg_bodygroup = {6,9,10}
    },
    [11] = {
        model = "models/survivors/group02/female_07.mdl",
        skins = 0,
        bodygroups = {0,0,0,0,0,0,0,0},
        gasmask_bodygroup = {7,2,1},
        nvg_bodygroup = {6,9,10}
    }
}

EntList = {
    [0] = {
        className = nil,
        icon = "vgui/null.vmt",
    }, -- no item slot
    [1] = {
        className = nil,
        icon = "vgui/null.vmt"
    }, -- empty item slot
    [2] = {
        className = "ent_gasmask",
        icon = "icon64/gasmask.png"
    },
    [3] = {
        className = "ent_usmc_pant",
        icon = "icon64/usmc_pant.png"
    },
    [4] = {
        className = "ent_usmc_jacket",
        icon = "icon64/usmc_jacket.png"
    },
    [5] = {
        className = "ent_usmc_vest1",
        icon = "icon64/usmc_vest1.png",
        armor = 100
    },
    [6] = {
        className = "ent_usmc_helmet",
        icon = "icon64/usmc_helmet.png",
        armor = 100
    },
    [7] = {
        className = "ent_nvg",
        icon = "icon64/nvg.png"
    },
    [8] = {
        className = "ent_usmc_rucksack",
        icon = "icon64/usmc_rucksack.png"
    },
    [9] = {
        className = "ent_m4a1",
        icon = "vgui/hud/m9k_m4a1.vmt",
        wep = "m9k_m4a1",
        ammo = "5.56x45mm NATO"
    },
    [10] = {
        className = "ent_m92beretta",
        icon = "vgui/hud/m9k_m92beretta.vmt",
        wep = "m9k_m92beretta",
        ammo = "9x19mm Parabellum"
    },
    [11] = {
        className = "ent_matador",
        icon = "vgui/hud/m9k_matador.vmt",
        wep = "m9k_matador",
        ammo = "90mm HESH"
    },
    [12] = {
        className = "ent_ammobox_556mm",
        ammoName = "5.56x45mm NATO",
        capacity = 30
    },
    [13] = {
        className = "ent_ammobox_9mm",
        ammoName = "9x19mm Parabellum",
        capacity = 60
    },
    [14] = {
        className = "ent_remington870",
        icon = "vgui/hud/m9k_remington870.vmt",
        wep = "m9k_remington870",
        ammo = "12 Gauge"
    },
    [15] = {
        className = "ent_ak47",
        icon = "vgui/hud/m9k_ak47.vmt",
        wep = "m9k_ak47",
        ammo = "7.62x39mm M43"
    },
    [16] = {
        className = "ent_ak74",
        icon = "vgui/hud/m9k_ak74.vmt",
        wep = "m9k_ak74",
        ammo = "5.45x39mm M74"
    },
    [17] = {
        className = "ent_amd65",
        icon = "vgui/hud/m9k_amd65.vmt",
        wep = "m9k_amd65",
        ammo = "7.62x39mm M43"
    },
    [18] = {
        className = "ent_spas12",
        icon = "vgui/hud/m9k_spas12.vmt",
        wep = "m9k_spas12",
        ammo = "12 Gauge"
    },
    [19] = {
        className = "ent_colt1911",
        icon = "vgui/hud/m9k_colt1911.vmt",
        wep = "m9k_colt1911",
        ammo = ".45 ACP"
    },
    [20] = {
        className = "ent_coltpython",
        icon = "vgui/hud/m9k_coltpython.vmt",
        wep = "m9k_coltpython",
        ammo = ".357 Magnum"
    },
    [21] = {
        className = "ent_fal",
        icon = "vgui/hud/m9k_fal.vmt",
        wep = "m9k_fal",
        ammo = "7.62x51mm NATO"
    },
    [22] = {
        className = "ent_famas",
        icon = "vgui/hud/m9k_famas.vmt",
        wep = "m9k_famas",
        ammo = "5.56x45mm NATO"
    },
    [23] = {
        className = "ent_g3a3",
        icon = "vgui/hud/m9k_g3a3.vmt",
        wep = "m9k_g3a3",
        ammo = "7.62x51mm NATO"
    },
    [24] = {
        className = "ent_g36",
        icon = "vgui/hud/m9k_g36.vmt",
        wep = "m9k_g36",
        ammo = "5.56x45mm NATO"
    },
    [25] = {
        className = "ent_m14sp",
        icon = "vgui/hud/m9k_m14sp.vmt",
        wep = "m9k_m14sp",
        ammo = "7.62x51mm NATO"
    },
    [26] = {
        className = "ent_m16a4_acog",
        icon = "vgui/hud/m9k_m16a4_acog.vmt",
        wep = "m9k_m16a4_acog",
        ammo = "5.56x45mm NATO"
    },
    [27] = {
        className = "ent_m416",
        icon = "vgui/hud/m9k_m416.vmt",
        wep = "m9k_m416",
        ammo = "5.56x45mm NATO"
    },
    [28] = {
        className = "ent_scar",
        icon = "vgui/hud/m9k_scar.vmt",
        wep = "m9k_scar",
        ammo = "7.62x51mm NATO"
    },
    [29] = {
        className = "ent_deagle",
        icon = "vgui/hud/m9k_deagle.vmt",
        wep = "m9k_deagle",
        ammo = ".357 Magnum"
    },
    [30] = {
        className = "ent_glock",
        icon = "vgui/hud/m9k_glock.vmt",
        wep = "m9k_glock",
        ammo = "9x19mm Parabellum"
    },
    [31] = {
        className = "ent_barret_m82",
        icon = "vgui/hud/m9k_barret_m82.vmt",
        wep = "m9k_barret_m82",
        ammo = ".50 BMG"
    },
    [32] = {
        className = "ent_dbarrel",
        icon = "vgui/hud/m9k_dbarrel.vmt",
        wep = "m9k_dbarrel",
        ammo = "12 Gauge"
    },
    [33] = {
        className = "ent_1887winchester",
        icon = "vgui/hud/m9k_1887winchester.vmt",
        wep = "m9k_1887winchester",
        ammo = "12 Gauge"
    },
    [34] = {
        className = "ent_1897winchester",
        icon = "vgui/hud/m9k_1897winchester.vmt",
        wep = "m9k_1897winchester",
        ammo = "12 Gauge"
    },
    [35] = {
        className = "ent_browningauto5",
        icon = "vgui/hud/m9k_browningauto5.vmt",
        wep = "m9k_browningauto5",
        ammo = "12 Gauge"
    },
    [36] = {
        className = "ent_dragunov",
        icon = "vgui/hud/m9k_dragunov.vmt",
        wep = "m9k_dragunov",
        ammo = "7.62x54mm R"
    },
    [37] = {
        className = "ent_ithacam37",
        icon = "vgui/hud/m9k_ithacam37.vmt",
        wep = "m9k_ithacam37",
        ammo = "12 Gauge"
    },
    [38] = {
        className = "ent_m3",
        icon = "vgui/hud/m9k_m3.vmt",
        wep = "m9k_m3",
        ammo = "12 Gauge"
    },
    [39] = {
        className = "ent_m24",
        icon = "vgui/hud/m9k_m24.vmt",
        wep = "m9k_m24",
        ammo = "7.62x51mm NATO"
    },
    [40] = {
        className = "ent_m60",
        icon = "vgui/hud/m9k_m60.vmt",
        wep = "m9k_m60",
        ammo = "7.62x51mm NATO"
    },
    [41] = {
        className = "ent_m249lmg",
        icon = "vgui/hud/m9k_m249lmg.vmt",
        wep = "m9k_m249lmg",
        ammo = "5.56x45mm NATO"
    },
    [42] = {
        className = "ent_mossberg590",
        icon = "vgui/hud/m9k_mossberg590.vmt",
        wep = "m9k_mossberg590",
        ammo = "12 Gauge"
    },
    [43] = {
        className = "ent_pkm",
        icon = "vgui/hud/m9k_pkm.vmt",
        wep = "m9k_pkm",
        ammo = "7.62x54mm R"
    },
    [44] = {
        className = "ent_hk45",
        icon = "vgui/hud/m9k_hk45.vmt",
        wep = "m9k_hk45",
        ammo = ".45 ACP"
    },
    [45] = {
        className = "ent_ammobox_545mm",
        ammoName = "5.45x39mm M74",
        capacity = 30
    },
    [46] = {
        className = "ent_ammobox_762_m43",
        ammoName = "7.62x39mm M43",
        capacity = 20
    },
    [47] = {
        className = "ent_ammobox_762_nato",
        ammoName = "7.62x51mm NATO",
        capacity = 20
    },
    [48] = {
        className = "ent_ammobox_50bmg",
        ammoName = ".50 BMG",
        capacity = 15
    },
    [49] = {
        className = "ent_ammobox_762_r",
        ammoName = "7.62x54mm R",
        capacity = 20
    },
    [50] = {
        className = "ent_ammobox_12gauge",
        ammoName = "12 Gauge",
        capacity = 20
    },
    [51] = {
        className = "ent_ammobox_357magnum",
        ammoName = ".357 Magnum",
        capacity = 30
    },
    [52] = {
        className = "ent_ammobox_45acp",
        ammoName = ".45 ACP",
        capacity = 40
    },
    [53] = {
        className = "ent_ifak",
        wep = "weapon_ifak"
    },
    [54] = {
        className = "ent_model627",
        icon = "vgui/hud/m9k_model627.vmt",
        wep = "m9k_model627",
        ammo = ".357 Magnum"
    },
    [54] = {
        className = "ent_model627",
        icon = "vgui/hud/m9k_model627.vmt",
        wep = "m9k_model627",
        ammo = ".357 Magnum"
    },
    [55] = {
        className = "ent_mp5",
        icon = "vgui/hud/m9k_mp5.vmt",
        wep = "m9k_mp5",
        ammo = "9x19mm Parabellum"
    },
    [56] = {
        className = "ent_sig_p229r",
        icon = "vgui/hud/m9k_sig_p229r.vmt",
        wep = "m9k_sig_p229r",
        ammo = "9x19mm Parabellum"
    },
    [57] = {
        className = "ent_tec9",
        icon = "vgui/hud/m9k_tec9.vmt",
        wep = "m9k_tec9",
        ammo = "9x19mm Parabellum"
    },
    [58] = {
        className = "ent_ump45",
        icon = "vgui/hud/m9k_ump45.vmt",
        wep = "m9k_ump45",
        ammo = ".45 ACP"
    },
    [59] = {
        className = "ent_uzi",
        icon = "vgui/hud/m9k_uzi.vmt",
        wep = "m9k_uzi",
        ammo = "9x19mm Parabellum"
    },
    [60] = {
        className = "ent_thompson",
        icon = "vgui/hud/m9k_thompson.vmt",
        wep = "m9k_thompson",
        ammo = ".45 ACP"
    }
}

AmmoList = {
    [1] = {
        ammoName = "5.56x45mm NATO",
        entID = 12-- not the ammoID, the entity in this example is ent_ammobox_556mm
    },
    [2] = {
        ammoName = "9x19mm Parabellum",
        entID = 13
    },
    [3] = {
        ammoName = "7.62x39mm M43",
        entID = 46
    },
    [4] = {
        ammoName = "5.45x39mm M74",
        entID = 45
    },
    [5] = {
        ammoName = "7.62x51mm NATO",
        entID = 47
    },
    [6] = {
        ammoName = ".50 BMG",
        entID = 48
    },
    [7] = {
        ammoName = "7.62x54mm R",
        entID = 49
    },
    [8] = {
        ammoName = "12 Gauge",
        entID = 50
    },
    [9] = {
        ammoName = ".357 Magnum",
        entID = 51
    },
    [10] = {
        ammoName = ".45 ACP",
        entID = 52
    }
}

NPCList = {
    "npc_vj_zss_zombie1",
    "npc_vj_zss_zombie2",
    "npc_vj_zss_zombie3",
    "npc_vj_zss_zombie4",
    "npc_vj_zss_zombie5",
    "npc_vj_zss_zombie6",
    "npc_vj_zss_zombie7",
    "npc_vj_zss_zombie8",
    "npc_vj_zss_zombie9",
    "npc_vj_zss_zombie10",
    "npc_vj_zss_zombie11",
    "npc_vj_zss_zombie12",
    "npc_vj_zss_zombfast1",
    "npc_vj_zss_zombfast2",
    "npc_vj_zss_zombfast3",
    "npc_vj_zss_zombfast4",
    "npc_vj_zss_zombfast5",
    "npc_vj_zss_zombfast6",
    "npc_vj_zss_cfastzombie",
    "npc_vj_zss_burnzie",
    "npc_vj_zss_cpzombie",
    "npc_vj_zss_czombie",
    "npc_vj_zss_czombietors",
    "npc_vj_zss_draggy",
    "npc_vj_zss_zhulk",
    "npc_vj_zss_zombguard",
    "npc_vj_zss_undeadstalker",
    "npc_vj_zss_zp1",
    "npc_vj_zss_zp2",
    "npc_vj_zss_zp3",
    "npc_vj_zss_zp4"
}

LootList = {
    "ent_ammobox_556mm",
    "ent_ammobox_556mm",
    "ent_ammobox_556mm",
    "ent_ammobox_9mm",
    "ent_ammobox_9mm",
    "ent_ammobox_9mm",
    "ent_ammobox_9mm",
    "ent_ammobox_9mm",
    "ent_ammobox_9mm",
    "ent_ammobox_9mm",
    "ent_ammobox_45acp",
    "ent_ammobox_45acp",
    "ent_ammobox_45acp",
    "ent_ammobox_357magnum",
    "ent_ammobox_357magnum",
    "ent_ammobox_357magnum",
    "ent_ammobox_762_nato",
    "ent_ammobox_762_nato",
    "ent_ammobox_762_nato",
    "ent_ammobox_762_nato",
    "ent_ammobox_762_nato",
    "ent_ammobox_762_r",
    "ent_ammobox_762_r",
    "ent_ammobox_762_m43",
    "ent_ammobox_762_m43",
    "ent_ammobox_12gauge",
    "ent_ammobox_12gauge",
    "ent_ammobox_12gauge",
    "ent_ammobox_12gauge",
    "ent_ammobox_12gauge",
    "ent_ammobox_12gauge",
    "ent_ammobox_12gauge",
    "ent_usmc_rucksack",
    "ent_usmc_helmet",
    "ent_m92beretta",
    "ent_uzi",
    "ent_glock",
    "ent_hk45",
    "ent_mp5",
    "ent_sig_p229r",
    "ent_tec9",
    "ent_browningauto5",
    "ent_dbarrel",
    "ent_ithacam37",
    "ent_mossberg590",
    "ent_remington870",
    "ent_spas12",
    "ent_m3",
    "ent_dragunov",
    "ent_pkm",
    "ent_ak47",
    "ent_amd65",
    "ent_fal",
    "ent_g3a3",
    "ent_m14sp",
    "ent_m60",
    "ent_m24",
    "ent_m4a1",
    "ent_m249lmg",
    "ent_m16a4_acog",
    "ent_colt1911",
    "ent_ump45",
    "ent_thompson",
    "ent_coltpython",
    "ent_deagle",
    "ent_model627",
    "ent_nvg",
    "ent_gasmask",
    "ent_gasmask",
    "ent_gasmask",
    "ent_gasmask",
}
-- character size
minSize = 165
maxSize = 190

FirstName = {
    [1] = "Noah",
    [2] = "Liam",
    [3] = "Jacob",
    [4] = "William",
    [5] = "Mason",
    [6] = "Ethan",
    [7] = "Michael",
    [8] = "Alexander",
    [9] = "James",
    [10] = "Elijah",
    [11] = "Benjamin",
    [12] = "Daniel",
    [13] = "Aiden",
    [14] = "Logan",
    [15] = "Jayden",
    [16] = "Matthew",
    [17] = "Lucas",
    [18] = "David",
    [19] = "Jackson",
    [20] = "Joseph",
    [21] = "Anthony",
    [22] = "Samuel",
    [23] = "Joshua",
    [24] = "Gabriel",
    [25] = "Andrew",
    [26] = "John",
    [27] = "Christopher",
    [28] = "Oliver",
    [29] = "Dylan",
    [30] = "Carter",
    [31] = "Isaac",
    [32] = "Luke",
    [33] = "Henry",
    [34] = "Owen",
    [35] = "Ryan",
    [36] = "Nathan",
    [37] = "Wyatt",
    [38] = "Caleb",
    [39] = "Sebastian",
    [40] = "Jack"
}

LastName = {
    [1] = "Smith",
    [2] = "Johnson",
    [3] = "Williams",
    [4] = "Brown",
    [5] = "Jones",
    [6] = "Garcia",
    [7] = "Miller",
    [8] = "Davis",
    [9] = "Rodriguez",
    [10] = "Martinez",
    [11] = "Hernandez",
    [12] = "Lopez",
    [13] = "Gonzalez",
    [14] = "Wilson",
    [15] = "Anderson",
    [16] = "Thomas",
    [17] = "Taylor",
    [18] = "Moore",
    [19] = "Jackson",
    [20] = "Martin",
    [21] = "Lee",
    [22] = "Perez",
    [23] = "Thompson",
    [24] = "White",
    [25] = "Harris",
    [26] = "Sanchez",
    [27] = "Clark",
    [28] = "Ramirez",
    [29] = "Lewis",
    [30] = "Robinson",
    [31] = "Walker",
    [32] = "Young",
    [33] = "Allen",
    [34] = "King",
    [35] = "Wright",
    [36] = "Scott",
    [37] = "Torres",
    [38] = "Nguyen",
    [39] = "Hill",
    [40] = "Flores"
}