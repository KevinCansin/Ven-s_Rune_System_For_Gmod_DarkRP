-- Ven's Rune System For DarkRP v0.1 (Wasted Hours = 7 on this file)
VEN_RUNE_SYSTEM = VEN_RUNE_SYSTEM or {}
VEN_RUNE_SYSTEM.version = "0.1"


-------------- Rarity -----------------------
VEN_RUNE_SYSTEM.Rarities= {
    [1] = {name = "UnCommon", color = Color(180, 180, 180), glowColor = Color(180, 180,180),},
    [2] = {name = "Common", color = Color(80,130,255), glowColor = Color(80,130,255)},
    [3] = {name = "Rare", color = Color(255,165,0)}, glowColor = Color(255,165,0),
    [4] = {name = "Epic", color = Color(160,25,227), glowColor = Color(160,25,227)},
    [5] = {name = "Legendary", color = Color(255,230,10), glowColor = Color(255,230,10)},
}



-------------- Sources For Forgin Rune ---------------
VEN_RUNE_SYSTEM.Source= {
    --Essences and Liquids--
    ancient_ink = {name = "Ancient Ink", icon = SetIcon("materials/essences/ancient_ink.png"), color = Color(34,33,33) , rarity = 1, value = 10, description = "Ancient Ink" },
    moonlight_essences = {name = "Moonlight Essences", icon = SetIcon("materials/essences/moonlight_essences.png"), color = Color(61,61,61), rarity = 2, value = 20, description = "Moonlight Essences" },
    liquid_mana = {name = "Liquid Mana", icon = SetIcon("materials/essences/liquid_mana"), color = Color(5,29,243), rarity = 3, value = 30, description = "Liquid Mana"},
    shadow_residue = {name = "Shadow Residue", icon = SetIcon("materials/essences/shadow_residue.png"), color = Color(0,0,0), rarity = 4, value = 40,  description = "Shadow Residue"},
    stardust = {name = "Stardust", icon = SetIcon("materials/essences/stardust.png"), color = Color(32,203,212), rarity = 5, value = 50, description = "Stardust"},
    --Crystal--
    quartz = {name = "Quartz", icon = SetIcon("materials/crystals/quartz.png"), color = Color(255,255,255), rarity = 1, value = 10, description = "Quartz"},
    obsidian_shard = {name = "Obsidian Shard", icon = SetIcon("materials/crystals/obsidian_shard.png"), color = Color(0,0,0), rarity = 2, value = 20, description = "Obsidian Shard"},
    runed_marble = {name = "Runed Marble", icon = SetIcon("materials/crystals/runed_marble.png"), color = Color(92,90,88), rarity = 3, value = 30, description = "Runed Marble"},
    soulstone = {name = "Soulstone", icon = SetIcon("materials/crystals/soulstone.png"), color = Color(182,51,103,175), rarity = 4, value = 40, description = "Soulstone"},
    meteorite_core = {name = "Meteorite Core", icon = SetIcon("materials/crystals/meteroite_core.png"), color = Color(236,25,25), rarity = 5, value = 50, description = "Meteroite Core"},
    --Organics--
    animal_heart = {name = "Animal Heart", icon = SetIcon("materials/organics/animal_heart.png"), color = Color(199, 58, 22), rarity = 1, value = 10, description = "Animal Heart"},
    silver_thron = {name ="Silver Thorn", icon = SetIcon("materials/organics/silver_thron.png"), color = Color(124,123,123), rarity = 2, value = 20, description ="Silver Thron"},
    owl_feather = {name = "Owl Feather", icon = SetIcon("materials/organics/owl_feather.png"), color = Color(94,59,33), rarity = 3, value = 30, description = "Owl Feather"},
    black_snake_venom = {name ="Black Snake Venom", icon = SetIcon("materials/organcis/black_snake_venom.png"), color = Color(191,230,38), rarity = 4, value = 40, description = "Black Snake Venom"},
    --Cursed Materials--
    cursed_bronze = {name = "Cursed Bronze", icon = SetIcon("materials/cursed/cursed_bronze.png"), color = Color(225,109,32), rarity = 1, value = 10, description = "Cursed Bronze"},
    nightmare_stone = {name = "Nightmare Stone", icon = SetIcon("materials/cursed/nightmare_stone.png"),color = Color(0,0,0) , rarity = 2, value = 20, description = "Nightmare Stone"},
    midnight_oil = {name = "Midnight Oil", icon = SetIcon("materials/cursed/midnight_oil.png"),color = Color(168,210,113), rarity = 3, value = 30, description = "Midnight Oil"},
    void_blood = {name = "Void Blood", icon = SetIcon("materials/cursed/void_blood.png"), color = Color(96,11,11),  rarity = 4, value = 40, description = "Void Blood"},
    werewolf_claw = {name = "Werewolf Claw", icon = SetIcon("materials/cursed/werewolf_claw.png"), color = Color(54,54,60) ,rarity = 5, value = 50, description = "Werewolf Claw"},
    -- Myhtics and Abstract --
    last_breath =  {name = "Traitor's Last Breath", icon = SetIcon("materials/myhtics/last_breath.png"), color = Color(43,53,48), rarity = 5, value = 50, description = "Last Breath"},
    soul_fragment = {name = "Soul Fragment", icon = SetIcon("materials/myhtics/soul_fragment.png"), color = Color(255,255,255), rarity = 5, value = 50, description ="Soul Fragment"},
}   



-------------- Rune Tiers --------------
-- Tier 1 = Weak, Tier 2 = Normal, Tier 3 = Strong, Tier 4 = Elite, Tier 5 = Supreme
VEN_RUNE_SYSTEM.tiernames  = {"Weak", "Normal", "Strong", "Elite", "Supreme"}
VEN_RUNE_SYSTEM.tiercolors = { Color(160,160,160), Color(80,200,80), Color(80,130,255), Color(255,165,0), Color(220,27,27) }



-------------- Runes --------------
VEN_RUNE_SYSTEM.runes = {

    --- HEALING RUNES ---
    aqua_vitalty = {
        name = "Aqua Vitalty",
        icon = SetIcon("materials/runes/healing_runes/aqua_vitalty.png"),
        tier = 1
        rarity = 1,
        color = Color(67,47,243)
        description = "Restores 25 health. Basic healing rune.",
        effect = "health",
        effectValue = 25, 
        effectDuration = 0,
        throwable = true,
        canCurse = false,
        recipe = { quartz = 1, ancient_ink = 1 },
        xpReward = 10,
    },
    essence_of_life = {
        name = "Essence Of Life",
        icon = SetIcon("materials/runes/healing_runes/essence_of_life.png"),
        tier = 2,
        rarity = 2,
        color = Color(191,27,21),
        description = "Restores 50 health. Normal healing rune."
        effect = "health",
        effectValue = 50,
        effectDuration = 0,
        throwable = true,
        canCurse = false,
        recipe =  { moonlight_essence = 1, silver_thron = 1, quartz = 1 },
        xpReward = 20,
    },
    regen_trace = {
        name = "Regen Trace",
        icon = SetIcon("materials/runes/healing_runes/regen_trace.png"),
        tier = 3,
        rarity = 3,
        color = Color(35,234,29),
        description = "Restores 20 health per second. It has 5 second duration.",
        effect = "regeneration",
        effectValue = 20,
        effectDuration = 5,
        throwable = false,
        canCurse = false,
        recipe = { owl_feather = 1, liquid_mana = 1, runed_marble = 1 },
        xpReward = 30,
    },
    holly_well = {
        name = "Holly Well",
        icon = SetIcon("materials/runes/healing/runes/healing_runes/holly_well.png"),
        tier = 4,
        rarity = 4,
        color = Color(207,233,93),
        description = "It boosted your max health by 100 for 60 seconds.",
        effect = "max_health",
        effectValue = 100,
        effectDuration = 60,
        throwable = false,
        canCurse = false,
        recipe = { liquid_mana = 2, obsidian_shard = 2, quartz = 2 },
        xpRward = 40,
    },
    second_wind = {
        name = "Second Wind",
        icon = SetIcon("materials/runes/healing_runes/second_wind.png"),
        tier = 5,
        rarity = 5,
        color = Color(28,56,241),
        description = "Revives you once from death with full HP within 30 seconds.",
        effect = "second_wind",
        effectValue = 100,
        effectDuration = 30,
        throwable = false,
        canCurse = false,
        recipe = { soul_fragment = 1, last_breath = 1, quartz = 2, liquid_mana = 2 },
        xpReward = 50,
    },
    
    --- Move Speed and Jump Height Runes ---
    swift_foot = {
        name = "Swift Foot",
        icon = SetIcon("materials/runes/speed_jump_runes/swift_foot.png"),
        tier = 1,
        rarity = 1,
        color = Color(230,18,188),
        description = "2.5x movement speed for 45 seconds.",
        effect = "speed",
        effectValue = 2.5,
        effectDuration = 45,
        throwable = true,
        canCurse = false,
        recipe = { quartz = 1, ancient_ink = 1 },
        xpReward = 10,
    },
    leap_rune = {
        name = "Leap Rune",
        icon = SetIcon("materials/runes/speed_jump_runes/leap_rune.png"),
        tier = 1,
        rarity = 1,
        color = Color(115,203,42),
        description = "Triple jump power for 25 seconds."
        effect = "jump",
        effectValue = 3,
        effectDuration = 25,
        throwable = true,
        canCurse = false,
        recipe = { quartz = 1, obsidian_shard = 1},
        xpReward = 10,
    },

    ---Strength Runes ---
    power_surge = {
        name = "Power Surge",
        icon = SetIcon("materials/runes/strength_runes/power_surge.png"),
        tier = 2,
        rarity = 2,
        color = Color(154,35,35),
        description = "2x melee damage for 30 seconds.",
        effect = "strength",
        effectValue = 2,
        effectDuration = 30,
        throwable = false,
        canCurse = false,
        recipe = { obsidian_shard = 1, quartz = 1, liquid_mana = 1},
        xpReward =  20,
    },
    bloodscourge = {
        name = "Bloodscourge",
        icon = SetIcon("materials/runes/strength_runes/bloodscourge.png"),
        rarity = 3,
        tier = 3,
        color = Color(231,63,16),
        description = "Bleeds 10 hp per seconds enemy or yourself. (Bleed time = 5 sec)",
        effect = "bleed",
        effectValue = 10,
        effectDuration = 5,
        throwable = true,
        canCurse = false,
        recipe = { midnight_oil = 1, void_blood = 2 },
        xpReward = 30,
    },
    soulstone = {
        name = "Soul Stone",
        icon = SetIcon("materials/runes/strength_runes/soulstone.png"),
        rarity = 5,
        tier = 5,
        color = Color(5,5,5),
        description = "Takes yours enemy soul and executes it.",
        effect = "damage",
        effectValue = 99999,
        effectDuration = 0,
        throwable = true,
        canCurse = true,
        recipe = { last_breath = 1, soul_fragment = 1, liquid_mana = 2, void_blood = 2 },
        xpReward = 100,
    },
    --- Buff Runes ---
    stone_guard = {
        name = "Stone Guard",
        icon = SetIcon("materials/runes/buff_runes/stone_guard.png"),
        rarity = 3,
        tier = 3,
        color = Color(22,195,51),
        description = "Reflects %20 of the damage taken. 15 seconds duration time.",
        effect = "reflect",
        effectValue = 20,
        effectDuration = 15,
        throwable = false,
        canCurse = false,
        recipe = { liquid_mana = 1, runed_marble = 1, quartz = 1 },
        xpReward = 30,
    },
    iron_skin = {
        name = "Iron Skin",
        icon = SetIcon("materials/runes/buff_runes/iron_skin.png"),
        rarity = 3,
        tier = 3,
        color = Color(85,80,84),
        description = "It reduces takne damage by %20 for 30 seconds.",
        effect = "damage_reduce",
        effectValue = 20,
        effectDuration = 30,
        throwable = false,
        canCurse = false,
        recipe = { cursed_bronze = 1, liquid_mana = 1, quartz = 1},
        xpReward = 30,
    },
    shadow_veil = {
        name = "Shadow Veil",
        icon = SetIcon("materials/runes/buff_runes/shadow_veil.png"),
        rarity = 4,
        tier = 4,
        color = Color(41,39,39,159),
        description = "It make you invisible. If you take damage effect will be gone",
        effect = "invisible"
        effectValue = 0,
        effectDuration = 9999,
        throwable = true,
        canCurse = false,
        recipe = { owl_feather = 1, soulstone = 1, shadow_residue = 1},
        xpReward = 40,    
    },
    phoneix = {
        name = "Phoneix",
        icon = SetIcon("materials/runes/buff_runes/phoneix.png"),
        rarity = 5,
        tier = 5,
        color = Color(230,80,16),
        description = "Gives you 100 max HP and doubles your melee damage for 120 seconds."
        effect = "phoneix",
        effectValue = 100
        effectDuration = 120,
        throwable = false,
        canCurse = false,
        recipe =  { stardust = 1, owl_feather = 1, meteorite_core = 1},
        xpReward = 50,

    },
    --- Curse Runes ---
    blind_terror = {
        name = "Blind Terror",
        icon = SetIcon("materials/runes/curse_runes/blind_terror.png"),
        rarity = 4,
        tier = 4,
        color = Color(5,4,4),
        description = "Makes your enemy blind for 120 second",
        effect = "blind",
        effectValue = 99,
        effectDuration = 120,
        thorwable = true,
        canCurse = true,
        recipe = { nightmare_stone = 2, cursed_bronze = 3, animal_hearth = 1, ancient_ink = 1 },
        xpReward = 40,
    },
    doom = {
        name = "Doom",
        icon = SetIcon("materials/runes/curse_runes/doom.png"),
        rarity = 5,
        tier = 5,
        color = Color(179,25,19),
        description = "It kills",
        effect = "damage",
        effectValue = 9999999,
        effectDuration = 0,
        throwable = true,
        canCurse = true,
        recipe = { werewolf_claw = 1, void_blood = 2, black_snake_venom = 1, liquid_mana = 2 },
        xpReward = 50,
    },
    abyss_chain = {
        name = "Abyss Chain",
        icon = SetIcon("materials/runes/curse_runes/abyss_chain.png"),
        rarity = 5,
        tier = 5,
        color = Color(10,241,233),
        description = "Roots your enemy for 60 second",
        effect = "root",
        effectValue = 1,
        effectDuration = 60,
        throwable = true,
        canCurse = true,
        recipe = { nightmare_stone = 2, animal_heart = 2, soulstone = 2, void_blood = 2 },
        xpReward = 50,
    }

}


-------------- ORE TYPES --------------

VEN_RUNE_SYSTEM.ores = {
    white_stone = {
        name = "White Stone",
        color = Color(240,236,236),
        respawnTime =  70,
        harvestXP = 3,
        loot = { quartz = 70, obsidian_shard = 20, runed_marble = 7, soul_stone = 3 },
    },
    black_stone = {
        name = "Black Stone",
        color = Color(21,19,19),
        respawnTime = 100,
        harvestXP = 6,
        loot = { obsidian_shard = 50, runed_marble = 25, soul_stone = 20, meteorire_core = 5 },
    },
}


-------------- Cursed Boxs -------------- 
VEN_RUNE_SYSTEM.cursedbox = {
    non_curse_box = {
        name = "Non Cursed Box",
        color = Color(238,177,34),
        respawnTime = 120,
        harvestXP = 10,
        loot = {cursed_bronze = 80, nightmare_stone = 15, midnight_oil = 5 },
    },
    semi_cursed_box = {
        name = "Semi Cursed Box",
        color = Color(164,172,15),
        respawnTine = 240,
        harvestXP = 20,
        loot = { nightmare_stone = 70, midnight_oil = 19, void_blood = 10, werewolf_claw = 1 },
    },
    cursed_box = {
        name ="Cursed Box",
        color = Color(26,30,1),
        respawnTime = 360,
        harvestXP = 30,
        loot = { midnight_oil = 70, void_blood = 20, werewolf_claw = 10 },
    },
}



-------------- Fishing Loot (Essences) --------------
VEN_RUNE_SYSTEM.fishingloot = {
    -- Each entry: weight, itemID, minCount, maxCount
    { weight = 40, item ="ancient_ink",   min = 1, max = 3 },
    { weight = 25, item ="moonlight_essences",   min = 1, max = 3 },
    { weight = 15, item ="liquid_mana",   min = 1, max = 3 },
    { weight = 10, item ="shadow_residue",   min = 1, max = 3 },
    { weight = 5, item = "stardust",   min = 1, max = 3 },
}



-------------- Rank System --------------
VEN_RUNE_SYSTEM.venranks = {
    {name = "Tier 1", minXP = 0, color = Color(180,180,180), craftFailChance = 0.50 },
    {name = "Tier 2", minXP = 50, color = Color(180,180,180), craftFailChance = 0.25 },
    {name = "Tier 3", minXP = 125, color = Color(180,180,180), craftFailChance = 0.5 },
    {name = "Tier 4", minXP = 200, color = Color(180,180,180), craftFailChance = 0.3 },
    {name = "Tier 5", minXP = 400, color = Color(180,180,180), craftFailChance = 0.1 },
}


function VEN_RUNE_SYSTEM.GetRank(xp)
    local rank = RUNE_SYSTEM.venranks[1]
    for _, r in ipairs(RUNE_SYSTEM.venranks) do
        if xp >= r.minXP then rank = r end
    end
    return rank 
end 



-------------- Quest System --------------
VEN_RUNE_SYSTEM.quest = {
    first_rune = {
        name = "Forging First Rune",
        icon = SetIcon("materials/quests/quest1.png"),
        desc = "Forge your first rune.",
        goal = { type = "forge", count = 1},
        reward = { xp = 10, money = 10 }
    },
    rock_breaker = {
        name = "Mine 5 stones",
        icon = SetIcon("materials/quests/quest2.png"),
        desc = "Mine 5 stones",
        goal = { type = "mine", count = 5 },
        reward = { xp = 10, money = 10 },
    },
}



-------------- Animal NPC Typess --------------
VEN_RUNE_SYSTEM.animalnpc = {
    wolf = {
        name = "Wolf",
        model = "",
        health = 100,
        speed = 150,
        damage = 10,
        color = Color(52,49,49),
        loot = {
            { item="animal_heart",    minCount = 1, maxCount = 2, chance= 80 },
            { item="silver_thorn",    minCount = 1, maxCount = 2, chance= 20 },
        }
        xpOnKill = 10,
        moneyOnKill = 10,
        spawnWeight = 30,
    },
    white_wolf = {
        name = "White Wolf",
        model = "",
        health = 150,
        speed = 120,
        damage = 20,
        color = Color(77,72,72),
        loot = {
            { item = "silver_thorn", minCount = 1, maxCount = 3, chance = 70 },
            { item = "liquid_mana", minCount = 1, maxCount = 2, chance = 30 },
        }
        xpOnKill = 20,
        moneyOnKill = 20,
        spawnWeight = 20,
    },
    owl = {
        name = "Owl",
        model = "",
        health = 50,
        speed = 200,
        damage = 10,
        color = Color(229,146,37),
        loot = {
            { item = "owl_feather" , minCount = 1, maxCount = 1, chance = 100 },
        }
        xpOnKill = 10,
        moneyOnKill = 10,
        spawnWeight = 10,
    },
    black_snake = {
        name = "Black Snake",
        model = "",
        health = 200,
        speed = 100,
        damage = 40, 
        color = Color(0,0,0),
        loot = {
            { item = "black_snake_venom", minCount = 1, maxCount = 1, chance = 100 },
        }
        xpOnKill = 50,
        moneyOnKill = 50,
        spawnWeight = 4,
    }
}



-------------- Particle Effect Map --------------
VEN_RUNE_SYSTEM.EffectParticles = {
     -- [effectName] = { emitter color, sprite, rate, size, lifetime, emitFromBone }
    health  = { color = Color(255,80,80),   sprite = "sprites/light_glow02_add", rate = 4,  size = 8,  life = 0.5,  bone = "ValveBiped.Bip01_Spine2" },
    regeneration = { color = Color(21,226,28), spirte = "sprites/light/glow02_add", rate = 3, size = 5, life = 1, bone = "ValveBiped.Bip01_Spine2" },
    max_health = { color = Color(158,37,37), spirte = "sprites/lights/glow02_add", rate = 2, size = 7, life = 0.3, bone = "ValveBiped.Bip01_Spine2" },
    second_wind = { color = Color(28,56,241), spirte = "sprites/lights/glow02_add", rate = 1, size = 3, life = 1, bone = "ValveBiped.Bip01_Spine2" },
    speed = { color = Color(15,231,152), spirte = "sprites/light/glow2_add", rate = 1, size = 1, life = 0.3, bone = "ValveBiped.Bip01_L_Calf", "ValveBiped.Bip01_R_Calf" },
    jump = { color = Color(8,110,13), spirte = "sprites/light/glow2_add", rate = 1, size = 1, life = 0.3, bone = "ValveBiped.Bip01_L_Calf", "ValveBiped.Bip01_R_Calf" },
    strength = { color = Color(154,35,35), spirte = "sprites/light/glow2_add", rate = 1, size = 3, life = 0.7, bone = "ValveBiped.Bip01_R_Hand", "ValveBiped.Bip01_L_Hand", "ValveBiped.Bip01_L_Finger0", "ValveBiped.Bip01_L_Finger1", "ValveBiped.Bip01_L_Finger2", "ValveBiped.Bip01_L_Finger3", "ValveBiped.Bip01_L_Finger4", "ValveBiped.Bip01_R_Finger0", "ValveBiped.Bip01_R_Finger1", "ValveBiped.Bip01_R_Finger2", "ValveBiped.Bip01_R_Finger3", "ValveBiped.Bip01_R_Finger4" },
    bleed = { color = Color(231,63,16), spirte = "sprites/light/glow2_add", rate = 3, size = 2, life = 1, bone = "ValveBiped.Bip01_Spine2" },
    damage = { color = Color(5,5,5), spirte = "spirtes/light/glow2_add", rate = 1, size = 3, life = 0.3, bone = "ValveBiped.Bip01_Spine2" },
    reflect = { color = Color(22,195,51), spirte = "spirtes/light/glow2_add", rate = 3, size = 5, life = 1, bone = "ValveBiped.Bip01_Spine2" },
    damage_reduce = { color = Color(85,80,84), spirte = "spirtes/light/glow2_add", rate = 3, size = 5, life = 1, bone = "ValveBiped.Bip01_Spine2" },
    invisible = { color = Color(41,39,39,159), spirte = "spirtes/light/glow2_add", rate = 3, size = 5, life = 1, bone = "ValveBiped.Bip01_Spine2" },
    phoneix = { color = Color(230,80,16), spirte = "spirtes/light/glow2_add", rate = 5, size = 5, life = 3, bone = "ValveBiped.Bip01_Spine2" },
    blind = { color = Color(5,4,4), spirte = "spirtes/light/glow2_add", rate = 3, size = 2, life = 1, bone = "ValveBiped.Bip01_Spine" },
    root = { color = Color(10,241,233), spirte = "spirtes/light/glow2_add", rate = 3, size = 2, life = 1, bone = "ValveBiped.Bip01_Spine2" },
    
}


-------------- Active Effect Storage (server side thing, so dont touch it) --------------
VEN_RUNE_SYSTEM.ActiveEffects = VEN_RUNE_SYSTEM.ActiveEffects or {}

print("[Ven's Rune System v0.1] Shared data loaded -" ..
    table.Count(VEN_RUNE_SYSTEM.Rarities) .. "rarities," ..
    table.Count(VEN_RUNE_SYSTEM.Sources) .. "sources," ..
    table.Count(VEN_RUNE_SYSTEM.runes) .. "runes," ..
    table.Count(VEN_RUNE_SYSTEM.ores) .. "ores," ..
    table.Count(VEN_RUNE_SYSTEM.cursedbox) .. "cursed box," ..
    table.Count(VEN_RUNE_SYSTEM.fishingloot) .. "fishing loot," ..
    table.Count(VEN_RUNE_SYSTEM.venranks) .. "ranks," .. 
    table.Count(VEN_RUNE_SYSTEM.quest) .. "quest," .. 
    table.Count(VEN_RUNE_SYSTEM.animalnpc) .. "animal npcs," .. 
    table.Count(VEN_RUNE_SYSTEM.EffectParticles) .. "particles.")