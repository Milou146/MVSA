PlayerModels = {}
PlayerModels.USMC = {
    [1] = {
        model = "models/yukon/conscripts/conscript_a_w_pm_v2.mdl",
        skins = {0,1,2,3,4,5,6,7,8,9,10,11,12,13}, -- authorized skins
        bodygroups = {{0},{3},{0},{1},{0,2},{0},{0},{1},{1},{2},{17},{0},{0,1,2},{0},{0},{0},{0},{0},{1}}, -- authorized bodygroups
        gasmask_bodygroup = {17,2,1}, -- gasmak bodygroup ID, bodygroup value when gasmask set, bodygroup value when gasmask unset
        nvg_bodygroup = {16,9,10} -- same for the NVG
    },
    [2] = {
        model = "models/yukon/conscripts/conscript_a_b_pm_v2.mdl",
        skins = {0,1,2,3,4,5},
        bodygroups = {{0},{3},{0},{1},{0,2},{0},{0},{1},{1},{2},{17},{0},{0,1,2},{0},{0},{0},{0},{0},{1}},
        gasmask_bodygroup = {17,2,1},
        nvg_bodygroup = {16,9,10}
    },
}
PlayerModels.Survivor = {
    [1] = {
        model = "models/survivors/group02/male_01.mdl",
        skins = {0},
        bodygroups = {{0},{0},{0},{0},{0},{0},{0},{0}},
        gasmask_bodygroup = {7,2,1},
        nvg_bodygroup = {6,9,10}
    },
    [2] = {
        model = "models/survivors/group02/male_03.mdl",
        skins = {0},
        bodygroups = {{0},{0},{0},{0},{0},{0},{0},{0}},
        gasmask_bodygroup = {7,2,1},
        nvg_bodygroup = {6,9,10}
    },
    [3] = {
        model = "models/survivors/group02/male_04.mdl",
        skins = {0},
        bodygroups = {{0},{0},{0},{0},{0},{0},{0},{0}},
        gasmask_bodygroup = {7,2,1},
        nvg_bodygroup = {6,9,10}
    },
    [4] = {
        model = "models/survivors/group02/male_05.mdl",
        skins = {0},
        bodygroups = {{0},{0},{0},{0},{0},{0},{0},{0}},
        gasmask_bodygroup = {7,2,1},
        nvg_bodygroup = {6,9,10}
    },
    [5] = {
        model = "models/survivors/group02/male_06.mdl",
        skins = {0},
        bodygroups = {{0},{0},{0},{0},{0},{0},{0},{0}},
        gasmask_bodygroup = {7,2,1},
        nvg_bodygroup = {6,9,10}
    },
    [6] = {
        model = "models/survivors/group02/male_07.mdl",
        skins = {0},
        bodygroups = {{0},{0},{0},{0},{0},{0},{0},{0}},
        gasmask_bodygroup = {7,2,1},
        nvg_bodygroup = {6,9,10}
    },
    [7] = {
        model = "models/survivors/group02/male_08.mdl",
        skins = {0},
        bodygroups = {{0},{0},{0},{0},{0},{0},{0},{0}},
        gasmask_bodygroup = {7,2,1},
        nvg_bodygroup = {6,9,10}
    },
    [8] = {
        model = "models/survivors/group02/male_09.mdl",
        skins = {0},
        bodygroups = {{0},{0},{0},{0},{0},{0},{0},{0}},
        gasmask_bodygroup = {7,2,1},
        nvg_bodygroup = {6,9,10}
    },
    [9] = {
        model = "models/survivors/group02/female_01.mdl",
        skins = {0},
        bodygroups = {{0},{0},{0},{0},{0},{0},{0},{0}},
        gasmask_bodygroup = {7,2,1},
        nvg_bodygroup = {6,9,10}
    },
    [10] = {
        model = "models/survivors/group02/female_02.mdl",
        skins = {0},
        bodygroups = {{0},{0},{0},{0},{0},{0},{0},{0}},
        gasmask_bodygroup = {7,2,1},
        nvg_bodygroup = {6,9,10}
    },
    [11] = {
        model = "models/survivors/group02/female_07.mdl",
        skins = {0},
        bodygroups = {{0},{0},{0},{0},{0},{0},{0},{0}},
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
        icon = "icon64/usmc_vest1.png"
    },
    [6] = {
        className = "ent_usmc_helmet",
        icon = "icon64/usmc_helmet.png"
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
        ammo = "5.56×45mm NATO"
    },
    [10] = {
        className = "ent_m92beretta",
        icon = "vgui/hud/m9k_m92beretta.vmt",
        wep = "m9k_m92beretta",
        ammo = "9×19mm Parabellum"
    },
    [11] = {
        className = "ent_matador",
        icon = "vgui/hud/m9k_matador.vmt",
        wep = "m9k_matador",
        ammo = "90mm HESH"
    },
    [12] = {
        className = "ent_ammobox_556mm",
        ammoName = "5.56×45mm NATO",
        capacity = 30
    },
    [13] = {
        className = "ent_ammobox_9mm",
        ammoName = "9×19mm Parabellum",
        capacity = 60
    },
    [14] = {
        className = "ent_acr",
        icon = "vgui/hud/m9k_acr.vmt",
        wep = "m9k_acr",
        ammo = "5.56×45mm NATO"
    },
    [15] = {
        className = "ent_ak47",
        icon = "vgui/hud/m9k_ak47.vmt",
        wep = "m9k_ak47",
        ammo = "7.62×39mm M43"
    },
    [16] = {
        className = "ent_ak74",
        icon = "vgui/hud/m9k_ak74.vmt",
        wep = "m9k_ak74",
        ammo = "5.45x39mm M74"
    }
}

AmmoList = {
    [1] = {
        ammoName = "5.56×45mm NATO",
        entID = 12-- not the ammoID, the entity in this example is ent_556_ammobox
    },
    [2] = {
        ammoName = "9×19mm Parabellum",
        entID = 13
    },
    [3] = {
        ammoName = "7.62×39mm M43",
        entID = 12
    },
    [4] = {
        ammoName = "5.45x39mm M74",
        entID = 12
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
    "npc_vj_zss_zboss",
    "npc_vj_zss_zminiboss",
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
    "ent_ammobox_556mm",
    "ent_ammobox_556mm",
    "ent_ammobox_556mm",
    "ent_ammobox_9mm",
    "ent_ammobox_9mm",
    "ent_ammobox_9mm",
    "ent_ammobox_9mm",
    "ent_ak47",
    "ent_m92beretta",
    "ent_usmc_rucksack",
    "ent_usmc_helmet",
}
-- character size
minSize = 165
maxSize = 210

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