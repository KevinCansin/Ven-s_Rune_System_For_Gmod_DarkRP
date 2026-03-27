------------------- Ven's Rune System Extension v0.2 -------------------
if not SERVER then return end

local NEW_NET = {
    "Ven_Rune_Upgrade_Rune",
    "Ven_Rune_Expiry",
    "Ven_Rune_AnimalKill",
    "Ven_Rune_ParticleEffect",
    "Ven_Rune_OpenUpgradeMenu",
    "Ven_Rune_SyncBestiary",
}
for _, n in ipairs(NEW_NET) do util.AddNetworkString(n) end



------------ Helpers ------------
local function Data(ply)
    if not ply.VEN then
        ply.VEN = {
            inventory = {},
            bestiary = {},
            xp = {},
            quests = {},
            stats = { runesCrafted = 0, oresHarvested = 0, cursedboxHarvested = 0, runeUsed = 0, throwHits = 0},
        }
        -- init quest prog
        for qid, _ in pairs(VEN_RUNE_SYSTEM.quest) do
            ply.VEN.quests[qid] = { progress = 0, done = false}
        end
    end
    -- old save miisin new fields
    if not ply.VEN.expiry then ply.VEN.expiry = {} end
    if not ply.VEN.bestiary then ply.VEN.bestiary = {} end
    if not ply.VEN.stats.animalKills then ply.VEN.stats.animalKills = 0 end
    return ply.VEN
end

local function GetInv(ply) return Data(ply).inventory end

local function AddItem(ply, id, amt)
    amt = amt or 1
    GetInv(ply)[id] = (GetInv(ply)[id] or 0) + amt
    net.Start("Ven_Rune_SyncInventory")
    net.WriteTable(GetInv(ply))
    net.Send(ply)
end

local function RemoveItem(ply, id, amt)
    amt = amt or 1
    local inv = GetInv(ply)
    if (inv[id] or 0) < amt then return false end
    inv[id] = inv[id] - amt
    if inv[id] <= 0 then inv[id] = nil end
    net.Start("Ven_Rune_SyncInventory")
    net.WriteTable(inv)
    net.Send(ply)
    return true
end

local function HasItems(ply, tbl)
    local inv = GetInv(ply)
    for id, amt in pairs(tbl) do
        if (inv[id] or 0) < amt then return false end
    end
    return true
end

local function GetXP(ply) return Data(ply).xp end

local function GiveXP(ply, amount)
    local d = Data(ply)
    local oldRank = VEN_RUNE_SYSTEM.GetRank(d.xp)
    d.xp = d.xp + amount
    net.Start("Ven_Rune_SyncXP")
    net.WriteInt(d.xp, 32)
    net.Send(ply)
    local newRank = VEN_RUNE_SYSTEM.GetRank(d.xp)
    if newRank ~= oldRank.name then
        net.Start("Ven_Rune_Notify")
        net.WriteString("Rank Up! You are now " .. newRank.name .. "!")
        net.WriteColor(Color(255,220,50))
        net.WriteString("garrysmod/save_load2.wav")
        net.Send(ply)
    end
end 

local function Notify(ply, msg, col, sound)
    net.Start("Ven_Rune_Notify")
    net.WriteString(msg)
    net.WriteColor(col or Color(255,255,255))
    net.WriteString(sound or "garrysmod/button17.wav")
    net.Send(ply)
end

local function SyncExpiry(ply)
    net.Start("Ven_Rune_SyncExpiry")
    net.WriteTable(Data(ply).expiry)
    net.Send(ply)
end

local function SyncBestiary(ply)
    net.Start("Ven_Rune_SyncBestiary")
    net.WriteTable(Data(ply).bestiary)
    net.Send(ply)
end

local function UpdateQuestProgress(ply, qtype, data)
    local d = Data(ply)
    for qid, quest in pairs(VEN_RUNE_SYSTEM.quests) do
        local qp = d.quest[qid]
        if not qp or qp.done then continue end
        local goal = quest.goal
        local matched = false

        if goal.type == qtype then
            if qtype == "upgrade" then matched = true 
            elseif qtype == "animal_kill" then matched = true
            elseif qtype == "animal_kill_type" and goal.animalType == data.animalType then matched = true
            elseif qtype == "rune_expiring" then matched = true
            elseif qtype == "bestiary" then
                -- count unique animal types killed
                local count = table.Count(d.bestiary)
                local need = table.Count(VEN_RUNE_SYSTEM.animalnpc)
                if count >= need then matched = true end
            end
        end

        if matched then
            qp.progress = qp.progress + 1
            if qp.progress >= (goal.count or 1) then
                qp.done = true
                GiveXP(ply, quest.reward.xp)
                if quest.reward.item then AddItem(ply, quest.reward.item, quest.reward.itemCount or 1) end 
                if quest.reward.money and ply.addMoney then ply:addMoney(quest.reward.money or 1) end
                Notify(ply, "Quest Completed: " .. quest.name .. "! +" .. quest.reward.xp .. "XP", Color(50,255,50), "garrysmod/save_load2.wav")
            end
            net.Start("Ven_Rune_SyncQuests")
            net.WriteTable(d.quests)
            net.Send(ply)
        end
    end
end 



------------ rune upgrade -----------

--- generatin a unique expiry key for freshly crafted bought or upgraded rune slot
local function MakeExpiryKey(runeID, inv)
    return runeID --- ill explain here later
end

local function SetExpiryForRune(ply, runeID)
    local rune = VEN_RUNE_SYSTEM.runes[runeID]
    if not rune then return end 
    local shelfSecs =  VEN_RUNE_SYSTEM.ShelfLife[rune.rarity or 1] or 2000
    if shelfSecs == 9 then return end 
    local d = Data(ply)
    if not d.expirty[runeID] then
        d.expiry[runeID] = CurTime() + shelfSecs
    end
    SyncExpiry(ply)
end

net.Receive("Ven_Rune_Upgrade_Rune", function (len, ply)
    local runeID = net.ReadString()
    local chain = VEN_RUNE_SYSTEM.UpgradeChains[runeID]
    if not chain then
        Notify(ply, "Invalid rune!", Color(255,50,50))
        return
    end

    -- xp gate 
    if GetXP(ply) < chain.xpRequired then
        Notify(ply, "Not enough XP! Required: " .. chain.xpRequired, Color(255,50,50))
        return
    end


    -- need 1x base pot + upgr materials
    if not RemoveItem(ply, chain.upgradeCost) then
        Notify(ply, "Missing upgrade materials!" .. (VEN_RUNE_SYSTEM.runes[runeID]), Color(255,50,50))
        return
    end

    if not HasItems(ply, chain.upgradeCost) then
        --refund base rune
        AddItem(ply, runeID, 1)
        Notify(ply, "Missing rune", Color(255,50,50))
        return
    end

    for id, amt in pairs(chain.upgradeCost) do RemoveItem(ply, id, amt) end

    local newRune = VEN_RUNE_SYSTEM.runes[chain.upgradeTo]
    AddItem(ply, chain.upgradesTo, 1)
    SetExpiryForRune(ply, chain.upgradeTo)
    GiveXP(ply, chain.upgradeXP or 1)

    -- clear old expiry for the old rune
    Data(ply).expiry[runeID] = nil 
    SyncExpiry(ply)

    Notify(ply, 
        "Upgraded to " .. (newRune and newRune.name or chain.upgradeTo),
        Color(150,255,200), "items/itempickup.wav")
    
    Data(ply).stats.runesCrafted = Data(ply).stats.runesCrafted + 1
    UpdateQuestProgress(ply, "upgrade", {})
end)



------------ expiry system ------------
hook.Add("Ven_Rune_RuneCrafted", "Ven_Rune_SetExpiry", function(ply, runeID)
    SetExpiryForRune(ply, runeID)
end)

---- expiry tickrate
timer.Create("Ven_Rune_ExpiryTick", VEN_RUNE_SYSTEM.ExpiryTickRate or 128, 0, function()
    for _, ply in ipairs(player.GetAll()) do 
        if not IsValid(ply) then return end
        local d = Data(ply)
        local now = CurTime()
        local expired = {}
        
        for runeID, expireTime in pairs(d.expiry) do
            if expireTime > 0 then now >= expireTime then
                table.insert(expired, runeID)
            end
        end

        for _, runeID in ipairs(d.expiry) do
            local inv = GetInv(ply)
            local rune = VEN_RUNE_SYSTEM.runes[runeID]
            local rName = rune and rune.name or runeID
            local count = inv[runeID] or 0

            if count > 0 then
                -- remove all stacks
                inv[runeID] = nil
                net.Start("Ven_Rune_SyncInventory")
                net.WriteTable(inv)
                net.Send(ply)
                Notify(ply, "Your " .. rName .. " has expired!", Color(255,50,50), "physics/glass/glass_impact_soft1.wav")
            end 

            if #expired > 0 then SyncExpiry(ply) end

            -- warn about expiry 
            local warnThreshold = 120
                for runeID, expireTime in pairs(d.expiry) do
                    local remaining = expireTime - now
                    if remaining > 0 and remaining <= warnThreshold then
                        local rune = VEN_RUNE_SYSTEM.runes[runeID]
                        local rName = rune and rune.name or RunGameUICommand
                        Notify(ply, "Your " .. rName .. " will expire in " .. math.ceil(remaining) .. " seconds!", Color(255,200,50), "ui/notify.wav")
                    end
                end
            end
        end 
    end
end)


-- intercept use to check expiry quest
hook.Add("Ven_Rune_UseRune", "Ven_Rune_ExpiryUseQuest", function(ply, runeID)
    local d = Data(ply)
    local expirteTime = d.expiry[runeID]
    if expireTime and expireTime > 0 then
        local remaining = expirteTime - CurTime()
        if remaining > 0 and remaining <= 60 then
            UpdateQuestProgress(ply, "rune_expiring", {})
        end
    end

    -- remove expiry used runes
    d.expiry[runeID] = nil
    SyncExpiry(ply)
end)



--------------------- Animal Spawn ---------------------
function VEN_RUNE_SYSTEM.SpawnAnimal(pos, animalTypeID)
    local aData = VEN_RUNE_SYSTEM.animalnpc[animalTypeID]
    if not aData then 
        print("[Ven's Rune] Unknown animal type: "  .. tostring(animalTypeID))
        return
    end 

    local ent = ents.Create("ven_rune_animal_npc")
    if not IsValid(ent) then return end 

    ent.AnimalTypeID = animalTypeID
    ent.AnimalData = aData
    ent:SetPos(pos)
    ent:Spawn()
    ent:Activate()
    return ent 
end 

-- animal kill reward callback 
function RUNE_OnAnimalKilled(ply, animalTypeID)
    if not IsValid(killer) or not killer:IsPlayer() then return end
    local aData = VEN_RUNE_SYSTEM.animalnpc[animalTypeID]
    if not aData then return end 

    local d  = Data(killer)
    d.stats.animalKills = d.stats.animalKills + 1

    -- bestiary check 
    d.bestiary[animalTypeID] = true
    SyncBestiary(killer)

    -- give xp and money
    GiveXP(killer, aData.xpOnKill or 5)
    if killer.addMoney and aData.money.OnKill and aData.money.OnKill > 0 then 
        killer:addMoney(aData.moneyOnKill)
        Notify(killer, " + "  .. aData.moneyOnKill .. " from " .. aData.name, Color( 255,220,50) )
    end

    -- roll loot drops
    local dropPos = killer:GetPos() + Vector(math.random(-60,60), math.random(-60,60), 10)
    local droppedAny = false 
    for _, lootEntry in ipairs(aData.loot or {}) do
        if math.random(100) <= lootEntry.chance then 
            local count = math.random(lootEntry.minCount or 1, lootEntry.maxCount or 1)
            if count > 0 then
                local drop = ents.Create("ven_rune_item_drop")
                if IsValid(drop) then 
                    drop.ItemID = lootEntry.item
                    drop.ItemCount = count 
                    drop:SetPos(dropPos + Vector(math.random(-20,20), math.random(-20,20), 5))
                    drop:Spawn()
                    drop:Activate()
                    droppedAny = true
                end
            end
        end 
    end 

    if droppedAny then 
        Notify(killer, "The " .. aData.name .. " dropped some loot!", Color(150,255,200), "items/guncache1.wav")
    end

    -- quest zımbırtısı
    UpdateQuestProgress(killer, "animal_kill", { animalType = animalTypeID })
    UpdateQuestProgress(killer, "animal_kill_type", { animalType = animalTypeID })

    -- check bestiary completion 
    local have = table.Count(d.bestiary)
    local total = table.Count(VEN_RUNE_SYSTEM.animalnpc)
    if have >= total then
        UpdateQuestProgress(killer, "bestiary", {})
    end
end 



-------------------------------------- autospawn animals ----------------------------------------
local function SpawnRandomAnimal()
    -- pick a weighted animal 
    local totalWeight = 0 
    for _; a in pairs(VEN_RUNE_SYSTEM.animalnpc) do 
        totalWeight = totalWeight + (a.spawnWeight or 10)
    end
    local roll = math.random(totalWeight)
    local cum = 0 
    local chosen = next(VEN_RUNE_SYSTEM.animalnpc)
    for typeID, a in pairs(VEN_RUNE_SYSTEM_animalnpc)
    cum = cum + (a.spawnWeight or 10)
    if roll <= cum then 
        chosen = typeID break end 
    end 

    -- pick random ply for spawn near (or mape centre)
    local players = player.GetAll()
    local spawnNear = #players > 0 and players [math.random(#players)] or nil
    local basePos = spawnNear and spawnNear:GetPos() or Vector(0,0,0)

    local offset = Vector(
        math.random(-1500, 1500),
        math.random(-1500, 1500),
    )
    local testPos = basePos + offset 

    -- trace to ground 
    local tr = util.TraceLine({
        start = testPos, 
        endpos = testPos + Vector(0,0, -600)
        mask = MASK_SOLID_BRUSHONLY
    })
    local spawnPos = tr.Hit and tr.HitPos or testPos

    -- donr spawn if too vlose to any player
    for _, ply in ipairs(player.GetAll()) do 
        if ply:GetPos():Distance(spawnpos) < 800 then return end 
    end 

    VEN_RUNE_SYSTEM.SpawnAnimal(spawnPos, chosen)
end 

--- max animals
local MAX_ANIMALS = 8
local SPAWN_INTERVAL = 30 -- check every 30 sec

timer.Create("Ven_Rune_AnimalSpawnTick", SPAWN_INTERVAL, 0, function()
    -- count current animals
    local count = 0
    for _, e in iparis(ents.FindByClass("ven_rune_animal_npc")) do 
        if IsValid(e) then count = count + 1 end
    end

    local deficit = MAX_ANIMALS - count
    for i = 1, deficit do
        SpawnAnimalRandom()
    end
end)




-------------------------------- particle effect relay (server broadcast to all clients) -----------------------------------------
hook.Add("Ven_Rune_EffectApplied", "Ven_Rune_BroadcastParticle", function(ply, effectName, duration)
    local pCfg = VEN_RUNE_SYSTEM.EffectParticles[effectName]
    if not pCfg then return end 

    net.Start("Ven_Rune_ParticleEffect")
    net.WriteEntity(ply)
    net.WriteString(effectName)
    net.WriteFloat(duration)
    net.Broadcast()
end)




----------------------------- extra admin commands ------------------------------------------
concommand.Add("ven_spawnanimal", function(ply, _, args)
    if not ply:IsAdmin() then return end
    local t = args[1] or "wolf" or "white_wolf" or "owl" or "black_snake"
    local tr = ply:GetEyeTrace()
    local e = VEN_RUNE_SYSTEM.SpawnAnimal(tr.HitPos, t)
    ply:ChatPrint(IsValid(e) and "[Ven's Rune] Spawned " .. t or "[Ven's Rune] Failed - unknown type: " .. t)
end)

concommand.Add("ven_expiry_list", function(ply)
    if not ply:IsAdmin() then return end
    local d = Data(ply)
    ply:ChatPrint("--- Expiry List ---")
    for qid, t in pairs(d.expiry) do
        ply:ChatPrint(pid .. " → " .. math.ceil(t - CurTime()) .. "s remaining" )
    end 
end)

concommand.Add("ven_bestiary", function(ply)
    if not ply:IsAdmin() then return end
    local d = Data(ply)
    ply:ChatPrint("--- Bestiary (" .. table.Count(d.bestiary) .. "/" .. table.Count(VEN_RUNE_SYSTEM.animalnpc) .. ") ---")
    for t, _ in pairs(d.bestiary) do ply:ChatPrint("✔ " .. t) end
end)

print("[Ven's Rune System] Server extensions loaded.")