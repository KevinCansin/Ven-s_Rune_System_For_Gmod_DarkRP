# Manual For Ven's Rune System For Gmod DarkRP

## Features Of Addon


### World Gathering
Sources = Ores, Cursed Boxes and Fishing

How To Harvest =
    For Ores and Cursed Boxes   ----> Walk up to node and pres **E**
    For Fishing                 ----> Fish menu and cast

What you get from them = 
    Ores =  Quartz, Obsidian Shard, Runed Marble, Soul Stone
    Cursed Boxes = Cursed Bronze, Nightmare Stone, Midnight Oil
    Fishing = Ancient Ink, Moonlight Esssences, Liquid Mana, Shadow Residue, Stardust



### Sources For Runes and Rarities of Sources
- **UnCommon**: Ancient Ink, Quartz, Animal Heart, Cursed Bronze
- **Common**:  Moonkight Essences, Obsidian Shard, Silver Thron, Nightmare Stone
- **Rare**: Liquid Mana, Runed Marble, Owl Feather, Midnight Oil
- **Epic**: Shadow Residue, Soul Stone, Black Snake Venom, Void Blood
- **Legendary**: Stardust, Meteorite Core, Werewolf Claw, Last Breath, Soul Fragment



### 17 Rune, 4 Tiers and 5 Rarities

### Healin Runes
- *Aqua Vitalty* = Instant restores 25 HP
- *Essence Of Life* = Instant restores 50 HP
- *Regen Trace*  = Restores 20 HP per second. It have 5 sec duration
- *Holly Well* = Boosts your HP by 100 for 60 sec
- *Second Wind* = Revives you from death with full HP

### Movement Runes
- *Swift Foot* = 2.5x movement speed for 45 sec
- *Leap Rune* = Triple jump power for 24 sec

### Strength Runes
- *Power Surge* = 2x melee damage for 30 sec
- *Bloodscourge* = Bleeds 10 hp per seconds enemy or yourself. (Bleed time = 5 sec)
- *Soul Stone = Takes yours enemy soul and executes it

### Buff Runes
- *Stone Guard* = Reflects %20 of the damage taken. 15 seconds duration time
- *Iron Skin* = It reduces takne damage by %20 for 30 seconds
- *Shadow Veil* = It make you invisible. If you take damage effect will be gone
- *Phoneix* = Gives you 100 max HP and doubles your melee damage for 120 seconds

### Curse Runes
- *Blind Terror* = Makes your enemy blind for 120 second
- *Doom* = It kills
- *Abyss Chain* = Roots your enemy for 60 second



### Ranks and XP
- *Tier 1* = 0 XP required and CraftFail Chance is %50
- *Tier 2* = 50 XP required and CraftFail Chance is %25
- *Tier 3* = 125 XP required and CraftFail Chance is %5
- *Tier 4* = 200 XP required and CraftFail Chance is %3
- *Tier 5* = 400 XP required and CraftFail Chance is %1



## Console Commands
- **ven_rune_craft** = Opens craft menu
- **ven_rune_shop** = Opens shop menu
- **ven_rune_quest** = Opens quest menu
- **ven_rune_fish** = Opens fishing menu
- **ven_rune_inventory** = Opens inventory menu
- **ven_rune_upgrade** = Opens upgrade menu
- **ven_rune_bestiary** = Opens bestiary menu



## Admin Commands
- **ven_spawnore** = Spawns ore at looking direction
- **ven_spawnbox** = Spawns cursed box on looking direction
- **ven_give** = Gives item to yourself or targeted player
- **ven_clearinv** = Clear inventory to yourself or targeted player
- **ven_givexp** = Gives XP to yourself or targeted player
- **ven_inv** = Shows inventory of targeted player
- **ven_spawnanimal** = Spawns animal on looking direction
- **ven_expiry_list** = Lists of expirying runes
- **ven_bestiary** = Shows bestiary of yourself or targeted player






### Adding New Content to Addon

### New Source for Rune
In `ven_rune_init.lua`, add to `VEN_RUNE_SYSTEM.Source`:
```lua
new_source = {
    name = "New Source", Icon = "", color = Color(255,255,255),
    rarity = 1-5, value= 45, description = "New Source", type = ""
},
```

### Adding New Rune
In `ven_rune_init.lua`, add to `VEN_RUNE_SYSTEM.runes`:
``` lua
new_rune = {
    name="New Rune",
    icon = "",
    tier= 1-5,
    rarity= 1-5,
    description = "",
    effect = "new_effect",
    effectValue = 1,
    effectDuration = 10, -- secs
    throwable = false,
    canCurse = false, 
    recipe = { new_source = 3 },
    xpReward = 20,
},
```

Then add the effect in `ven_rune_server.lua` inside `ApplyEffect()`:
``` lua
elseif eff == "new_effect" then
    --- custon effect goes here
    SetEffect(ply, eff, val, dur, nil)
    Notify(ply, "New Effect Active!", Color(255,230,50))
```


### Adding New Ore
In `ven_rune_init.lua`, add to `VEN_RUNE_SYSTEM.ores`:
``` lua
new_ore = {
    name = "New Ore",
    color = Color(10,10,10),
    respawnTime = 1-9999,
    harvestXP = 1-999,
    loot = {new_source = 1},
},
```


### New Quest
In `ven_rune_init.lua`, add to `VEN_RUNE_SYSTEM.quest`:
``` lua 
new_quest = {
    name = "New Quest",
    icon = SetIcon("")
    desc = "New Quest"
    goal = { type = "forge", count = 1},
    reward = { xp = 10, money = 10 }
},
```


### DarkRP
The system auto-detects DarkRP's `addMoney` / `canAfford`. No configuration needed.  
Without DarkRP, buying/selling still works visually — plug in your own economy by editing `Ven_Rune_BuyIngredient` and `Ven_Rune_SellItem` net receivers.