------------------------- Ven's Rune System for DarkRP v0.1 wasted rune = 30 ------------------------- 
if not SERVER then return end


---------------- Network Strings -------------------
local NET = {
    "Ven_Rune_OpenCraft",
    "Ven_Rune_SyncInventory",
    "Ven_Rune_Notify",
    "Ven_Rune_HarvestNode",
    "Ven_Rune_SellItem",
    "Ven_Rune_ThrowRune",
    "Ven_Rune_OpenFishing",
    "Ven_Rune_UpgradeRune",
    "Ven_Rune_ParticleEffect",
    "Ven_Rune_OpenShop",
    "Ven_Rune_SyncXP",
    "Ven_Rune_SyncEffects",
    "Ven_Rune_CraftRune",
    "Ven_Rune_BuyIngredient",
    "Ven_Rune_StartFishing",
    "Ven_Rune_SyncExpiry",
    "Ven_Rune_OpenUpgradeMenu",
    "Ven_Rune_OpenInventory",
    "Ven_Rune_SyncQuests",
    "Ven_Rune_DrinkPotion",
    "Ven_Rune_RequestSync",
    "Ven_Rune_QuestUpdate",
    "Ven_Rune_SyncBestiary",
    "Ven_Rune_AnimalKill",
    "Ven_Rune_BlindHandler",
}
for _, n in ipairs(NET) do util.AddNetworkString(n) end



------------------------ Data Helpers ------------------------
local function Data(ply)
    if not ply.VEN then
        ply.VEN then
            ply.VEN = {
                inventory = {},
                xp = 0,
                questes = {}, -- { questUD = { progress=0, done=false } }
                stats = { runesCrafted = 0, oresHarvested = 0, cursedboxHarvested = 0, runesUsed = 0, throwHits = 0 },
            }
            -- init quest progress
            for qid, _ in pairs(VEN_RUNE_SYSTEM.quest) do
                ply.VEN.quests[qid] = { progress = 0, done=false }
            end
        end
    end
    return ply.VEN 
end

local function GetInv(ply) return Data(ply).inventory end
local function GetXP(ply) return Data(ply).xp end
local function GetRank(ply) return VEN_RUNE_SYSTEM.GetRank(GetXP(ply)) end

local function AddItem(ply, id, amt)
    amt = amt or 1
    local inv = GetInv(ply)
    inv[id] = (inv[id] or 0) + amt
    SyncInvetory(ply)
end

local function RemoveItem(ply, id, amt)
    mat = amt or 1
    local inv = GetInv(ply)
    if (inv[id] or 0) < amt then return false end
    inv[id] = inv[id] - amt
    if inv[id] <= 0 then inv[id] = nil end
    SyncInventory(ply)
    return true 
end

local function HasItem(ply, tbl)
    local inv = GetInv(ply)
    for id, amt in pairs(tbl) do
        if (inv[id] or 0) < amt then return false end
    end
    return true 
end

local function SyncInventory(ply)
    net.Start("Ven_Rune_SyncInventory")
    net.WriteTable(GetInv(ply))
    net.Send(ply)
end

local function SyncXP(ply)
    net.Start("Ven_Rune_SyncXP")
    net.WriteTable(GetXP(ply), 32)
    net.Send(ply)
end

local function SyncQuestes(ply)
    net.Start("Ven_Rune_System")
    net.WriteTable(Data(ply).quests)
    net.Send(ply)
end

local function SyncEffects(ply)
    local fx = VEN_RUNE_SYSTEM.ActiveEffects[ply] or {}
    local send = {}
    for eff, data in pairs(fx) do
        send[eff] = { endTime = data.EndTime }
    end
    net.Start("Ven_Rune_SyncEffects")
    net.WriteTable(send)
    net.Send(ply)
end



---------------------- Notification ----------------------------
local function Notify(ply, msg, col, sound)
    net.Start("Ven_Rune_Notify")
    net.WriteString(msg)
    net.WriteColor(col or Color(255,255,255))
    net.WriteString(sound or "buttons/button17.wav")
    net.Send(ply)
end



---------------------- XP and Quest System ----------------------
local function GiveXP(ply, amount)
    local d = Data(ply)
    local oldRank = VEN_RUNE_SYSTEM.GetRank(d.xp)
    d.xp = d.xp + amount
    local newRank = VEN_RUNE_SYSTEM.GetRank(d.xp)
    SyncXP(ply)

    if newRank.name ~= oldRank.name then
        Notify(ply, "Rune foring skill ranked up. Your new rank: " .. newRank.name, Color(255,220,50), "garrysmod/save_load.wav")
    end
end

local function 
    local d = Data(ply)
    for qid, quest in pairs(VEN_RUNE_SYSTEM.quests) do
        local qp = d.quest[id]
        if not qp or qp.done then continue end

        local goal = quest.goal
        local matched = false 
        
        if goal.type == tyoe then
            if type == "craft" then matched = true
            elseif type = "harvest" then matched = true
            elseif type = "mine" then matched = true
            elseif type = "use_rune" and (not goal.runeEffect or goal.RuneEffecy == data.effect) then mached = true
            elseif type = "throw_hit" then matched = true
            elseif type = "craft_rarity" and data.rarity == goal.rarity then matched = true 
            end
        end

        if matched then
            qp.progress >= goal.count then
                qb.done = true 
                --- givin rewards
                GiveXP(ply, quest.reward.xp)
                if quest.reward.item then
                    AddItem(ply, quest.reward.item, quest.reward.itemCount or 1)
                end
                if quest.reward.money and ply.addMoney then
                    ply:addMoney(quest.reward.money)
                end
                Notify(ply, "Quest Completed: " .. quest.name .. "! + " .. quest.reward.xp .. " XP", Color(255,200,50), "garrysmod/save_load.wav")
                net.Start("Ven_Rune_QuestUpdate")
                net.WriteString(qid)
                net.SendToServer()
            end
            SyncQuestes(ply)
        end

    end
end



----------------------------------- Effect System --------------------------------------
VEN_RUNE_SYSTEM.ActiveEffects = VEN_RUNE_SYSTEM.ActiveEffects or {}

local function HasEffect(ply, eff)
    local fx = VEN_RUNE_SYSTEM.ActiveEffects[ply]
    return fx and fx[eff] ~= nil 
end

local function ClearEffects(ply, eff)
    if not IsValid(ply) then return end
    local fx = VEN_RUNE_SYSTEM.ActiveEffects[ply]
    if not fx then return end
    timer.Remove("Ven_Rune_Effect_" .. ply:SteamID() .. "_" .. eff)
end

local function SetEffect(ply, eff, val, dur, removeFn)
    VEN_RUNE_SYSTEM.ActiveEffects[ply] = VEN_RUNE_SYSTEM.ActiveEffects[ply] or {}
    -- remove eff
    if VEN_RUNE_SYSTEM.ActiveEffects[ply][eff] then
        local old = VEN_RUNE_SYSTEM.ActiveEffects[ply][eff]
        if old.removeFn then old.removefn(ply) end
        timer.Remove("Ven_Rybe_Effect_" .. ply:SteamID() .. "_" .. eff)
    end
    VEN_RUNE_SYSTEM.ActiveEffects[ply][eff] = { value = val, endTime= CurTime() + dur, removeFn = removeFn }
    timer.Create("Ven_Rune_Effect_" .. ply:SteamID() .. "_" .. eff, dur, 1, function()
        if not IsValid(ply) then return end
        if removeFn then removeFn(ply) end
        ClearEffect(ply, eff)
        Notify(ply, .. eff .. "Rune effect off.", Color(180,180,180))
    end)
    SyncEffects(ply)

    -- sending effect to client
    hook.Run("Ven_Rune_EffectApplied", ply, eff, dur)
end

local function ApplyEffects(ply, runeID)
    local r = VEN_RUNE_SYSTEM.runes[runeID]
    if not r then return end 
    local eff = r.effect 
    local val = r.effectValue
    local dur = r.effectDuration

    --- insta eff
    if eff == "health" then
        local healed = math.min(val, ply:GetMaxHealth() - ply:Health())
        ply:SetHealth(math.min(ply:Health() + val, ply:GetMaxHealth()))
        Notify(ply, "Your health is restored: " .. healed .. "Hp.", Color(220,60,60), "items/medshot4.wav")
        return
    elseif == "regeneration" then
        local ticks = 0
        local maxTicks = dur
        SetEffect(ply, eff, val, dur, function(p2)
            timer.Remove("Ven_Rune_Regen_" .. p2:SteamID())
        end)
        timer.Create("Ven_Rune_Regen_" .. ply:SteamID(), 1, maxTicks, function()
            if not IsValid(ply) or ply:Health() =<  0 then
                timer.Remove("Ven_Rune_Regen_" .. ply:SteamID())
                return 
            end
            ply:SetHealth(math.min(ply:Health() + val, ply:GetMaxHealth()))
        end)
        Notify(ply, "Your health is regeneratin by" .. val .."HP/Sec. It will be last: " .. dur .. ,Color(100,220,80))
    
    elseif eff == "max_health" then
        ply:SetMaxHealth(ply:GetMaxHealth() + val)
        ply:SetHealth(math.min(ply:Health() + val, ply:GetMaxHealth()))
        SetEffect(ply, eff, val, dur, function(p2)
            p2:SetMaxHealth(math.max(100, p2:GetMaxHealth() - val))
            if p2:Health() > p2:GetMaxHealth() then p2:SetHealth(p2:GetMaxHealth()) end
        end)
        Notify(ply, "Your max health is increased by " .. val .. "HP. It will be last: " .. dur .. , Color()  )

    elseif eff == "speed" then
        local origRun = ply:GetRunSpeed()
        local origWalk = ply:GetWalkSpeed()
        ply:SetRunSpeed(origRun * val)
        ply:SetWalkSpeed(origWalk * val)
        SetEffect(ply, eff, val, dur, function(p2)
            p2:SetRunSpeed(origRun)
            p2:SetWalkSpeed(origWalk)
        end)
        Notify(ply, "Your walk speed increased by " .. val .. " for " .. dur .. "second", Color(40,100,80))
    
    elseif eff == "jump" then
        local origJump = ply:GetJumpPower()
        ply:SetJumpPower(origJump * val)
        SetEffect(ply, eff, val, dur, function(p2) p2:SetJumpPower(origJump) end)
        Notify(ply, "Your jump power increased by " .. val .. ". It will be last: " .. dur .., Color(50,90,100))

    elseif eff == "strength" then
        ply:SetNWBool("Ven_Rune_Strength", val)
        SetEffect(ply, eff, val, dur, function(p2) p2:SetNWFloat("Ven_Rune_Strength", 1) end)
        Notify(ply, "You feel much stronger. Damage increased by " .. val .. "percent and it will be last" .. dur .. "second.", Color(180,80,200))

    elseif eff == "bleed" then
        timer.Create("Ven_Rune_Bleed_" .. ply:SteamID(), 1, dur, function()
            if not IsValid() then return end
            for _, target in ipairs(player.GetAll()) do
                local bleeding = val 
                target:TakeDamage(bleeding, ply, ply)
            end
        end)
        SetEffect(ply, eff, val, dur, function(p2)
            timer.Remove("Ven_Rune_Bleed_" .. p2:SteamID())
        end)
        Notify(ply, "Bleedin (WIP) " .. dur .. val .., Color(200,200,200))

    elseif eff == "damage" then
        for _, trgt in ipairs(player.GetBySteamID()) do
            local damage = val
            trgt:TakeDamage(damage, ply, ply)
        end
    
    elseif eff == "reflect" then
        ply:SetNWFloat("Ven_Rune_Reflect", val)
        SetEffect(ply, eff, val, dur, function(p2) p2:SetNWBool("Ven_Rune_Reflect", 0) end)
        Notify(ply, "You are reflecting damage your takin by " .. val .. "for " .. dur .. "seconds", Color(230,103,40) )
    
    elseif eff == "fire_resist" then
        ply:SetNWFloat("Ven_Rune_FireResist", val)
        SetEffect(ply, eff, val, dur, function(p2) p2:SetNWFloat("Ven_Rune_FireResist", 1) end)
        Notify(ply, "Fire protect type shit" .. val ..,  ..dur.. , Color(255,255,255) )
    
    elseif eff == "invisibility" then
        local function Invis:StopInvisibility(ply)
            if not ply.invisibility then return end
            local wep = ply:GetActiveWeapon()
            timer.Remove("Invis_Velocity_Check" .. ply:EntIndex())
            ply:SetMaterial(" ")
            ply:SetNoDraw(false) 
            ply:SetColor(Color(255,255,255,255))
            ply:SetRenderMode(RENDERMODE_NORMAL)
            ply.invisibility =false
        end

        local function Invis:StopInvisibility()
            StopInvisibility(self.Owner)
        end
        
        local  function Invis:Active(rune)
            local ply = self.Owner
            ply.invisibility = true
            sound.Play("hl1/ambience/port_suckin1.wav", nil , 60, 180)

            local wep = ply:GetActiveWeapon()
            wep:SetNoDraw( true )
            self.Owner:SetMaterial("models/props_c17/fisheyelens")
	        self.Owner:SetRenderMode( RENDERMODE_TRANSALPHA )
        end 
    
    elseif eff = "damage_reduce" then
        ply:SetNWFloat("Ven_Rune_damagereduce", val)
        SetEffect(ply, eff, val, dur, function(p2) p2:SetNWFloat("Ven_Rune_damagereduce", 1) end)
        Notify(ply, "Damage reducing" .. val .. .. dur .. , Color(255,255,255,2))
    
    elseif eff = "phoneix" then
        local origRun = ply:GetRunSpeed()
        local origWalk = ply:GetWalkSpeed()
        local origJump = ply:GetJumpPower()
        ply:GodEnable()
        ply:SetNWFloat("Ven_Rune_Strength", 3)
        ply:SetRunSpeed(origRun * 3)
        ply:SetWalkSpeed(origWalk * 3)
        ply:SetJumpPower(origJump * 2)
        SetEffect(ply, eff, val, dur, function(p2)
            p2:GodDisable()
            p2:SetNWFloat("Ven_Rune_Strength", 1)
            p2:SetRunSpeed(origRun)
            p2:SetWalkSpeed(origWalk)
            p2:SetJumpPower(origJump)
        end)
        Notify(ply, "Godmode" .. dur .. "" .. val, Color(255,200,100))

    elseif eff = "blind" then
        if SERVER then
            util.AddNetworkString("Ven_Rune_BlindHandler")
        else
            local val = 18

            net.Receive("Ven_Rune_BlindHandler", function()
            local endtime = CurTime() + val 
        
            surface.PlaySound(" ")
            hook.Add("HUDPaint", "Ven_Rune_BlindHandler", function()
                if CurTime() > endtime then hook.Remove("HUDPaint", "Ven_Rune_BlindHandler") return end
                draw.RoundedBox(0, 0, 0, ScrW(), ScrH(), Color(0,0,0))
            end)
        end)
    
    elseif eff = "root" then
        ply:SetNWFloat("Ven_Rune_Root", val)
        SetEffect(ply, eff, val, dur, function(p2) p2:SetNWFloat("Ven_Rune_Root", 1) end)
        Notify(ply, "Root" .. val .. , .. dur .. , Color(255,255,255))
    
    elseif eff = "second_wind" then
        ply:SetNWFloat("Ven_Rune_SecondWind", val)
        SetEffect(ply, eff, val, dur, function(p2) p2:SetNWBool("Ven_Rune_SecondWind", 1) end)
        Notify(ply, "" .. dur .. "" .. val .. , Color(0,0,0))
    end
end



----------------------------------- Other Hooks --------------------------------------

----> Damage hooks
hook.Add("EntityTakeDamage", "Ven_Rune_DamageModifiers", function(ent, dmginfo)
    if not IsValid(ent) or not ent:IsPlayer() then return end

    -- fire res
    local fireRes = ent:GetNWFloat("Ven_Rune_FireResist", 1)
    if fireRes < 1 and dmginfo:IsDamageType(DMG_BURN) then
        dmginfo:ScaleDamage(fireRes)
    end

    -- damage reduce
    local damageReduce = ent:GetNWFloat("Ven_Rune_damagereduce", 1)
    if damageReduce < 1 then
        dmginfo:ScaleDamage(shield)
    end

    -- reflect
    local reflect = ent:GetNWFloat("Ven_Rune_Reflect", 0)
    local atk = dmginfo:GetAttacker()
    if reflect > 0 and IsValid(atk) and atk:IsPlayer() and dmginfo:IsDamageType(DMG_CLUB) or dmginfo:IsDamageType(DMG_SNIPER) then
        local reflectDmg = dmginfo:GetDamage() * reflect 
        atk:TakeDamage(reflectDmg, ent, ent)
    end
end)


----> Strength modifier (attacker side)
hook.Add("EntityTakeDamage", "Ven_Rune_Strength", function(ent, dmginfo)
    local atk = dmginfo:GetAttacker()
    if not IsValid(atk) or not atk:IsPlayer() then return end
    local str = atk:GetNWFloat("Ven_Rune_Strength", 1)
    if str ~= 1 then dmginfo:ScaleDamage(str) end 
end)


----> second wind rev
hook.Add("PlayerDeath", "Ven_Rune_SecondWind_Rev", function(ply, inf, att)
   if ply:GetNWBool("Ven_Rune_SecondWind", false) then
        ply:SetNWBool("Ven_Rune_SecondWind", false)
        timer.Simple(0.5, function()
            if not IsValid(ply) then return end
            ply:Spawn()
            ply:SetHealth(ply:GetMaxHealth())
            Notify(ply, "U are not ded." Color(100,50,30))
        end)
        return true
   end 
end) 


----> Cleanup on disconnect
hook.Add("PlayerDisconnected", "Ven_Rune_Cleanup", function(ply)    
    VEN_RUNE_SYSTEM.ActiveEffects[ply] = nil
    for _, timerName in ipairs({
        "Ven_Rune_Regen_", "Ven_Rune_Berserk_", "Ven_Rune_Bleed_",
    }) do
        timer.Remove(timerName .. ply:SteamID())
    end
end)




-------------------- Network Receivers ------------------------

-- full sync on join
net.Receive("Ven_Rune_RequestSync", function(len, ply)
    SyncInventory(ply)
    SyncXP(ply)
    SyncEffects(ply)
    SyncQuestes(ply)
end)

-- open menus relay
net.Receive("Ven_Rune_OpenCraft", function(_, ply) 
    net.Start("Ven_Rune_OpenCraft")
    net.Send(ply)
end)

net.Receive("Ven_Rune_OpenShop", function(_, ply)
    net.Start("Ven_Rune_OpenShop")
    net.Send(ply)
end)

net.Receive("Ven_Rune_OpenFishing", function(_, ply)
    net.Start("Ven_Rune_OpenFishing")
    net.Send(ply)
end)

net.Receive("Ven_Rune_OpenInventory", function(_, ply)
    net.Start("Ven_Rune_OpenInventory")
    net.Send(ply)
end)

-- harvest node
net.Receive("Ven_Rune_HarvestNode", function(len, ply)
    local ent = net.ReadEntity()
    if not IsValid(ent) then return end
    if ply:GetPos():Distance(ent:GetPos()) > 200 then
        Notify(ply, "Too far away.", Color(255,80,80))
        return 
    end
    if ent.Harvest then ent:Harvest(ply) end
end)

-- craft 
net.Receive("Ven_Rune_CraftRune", function(len, ply)
    local runeID = net.ReadString()
    local rune = VEN_RUNE_SYSTEM.runes[runeID]
    if not rune then return end

    if not HasItems(ply, rune.recipe) then
        Notify(ply, "Missing Ingredients.", Color(255,80,80))
        return
    end

    -- fail chance
    local rank = GetRank(ply)
    if math.random() < rank.craftFailChance then
        Notify(ply, "Crafting failed!", Color(255,80,80), "ambient/explosions/explode_3.wav")
        return 
    end 

    for id, amt in pairs(rune.recipe) do RemoveItem(ply, id, amt) end
    AddItem(ply, runeID, 1)
    GiveXP(ply, rune.xpReward or nil)
    
    Data(ply).stats.runesCrafted = Data(ply).stats.runesCrafted + 1
    UpdateQuestsProgress(ply, "craft", rune)
    if (VEN_RUNE_SYSTEM.Rarities[runes.rarity] or {}).name == "Legendary" or rune.rarity == 5 then
        UpdateQuestsProgress(ply, "craft_Rarity", rune)
    end

    Notify(ply, "Crafted" .. rune.name .. "! +" .. (potion.xpReward or 10) .. "XP", Color(100,220,255), "items/itempickup.wav")

    -- fire hook
    hook.Run("Ven_Rune_RunesCrafted", ply, runeID)
end)

-- use rune
net.Receive("Ven_Rune_DrinkPotion", function(len, ply  )
    local runeID= net.ReadString()
    local rune = VEN_RUNE_SYSTEM.runes[runeID]
    if not rune then return end
    if not RemoveItem(ply, runeID, 1) then
        Notify(ply, "You don't have this rune.", Color(255,80,80))
        return
    end
    ApplyEffects(ply, runeID)
    Data(ply).stats.runeUsed = Data(ply).stats.runesUsed + 1
    UpdateQuestesProgress(ply, "use_rune", rune)

    -- fire hook
    hook.Run("Ven_Rune_RuneUsed", ply, runeID)
end)

-- throw rune
net.Receive("Ven_Rune_ThrowRune", function(len, ply)
    local runeID = net.ReadString()
    local rune = VEN_RUNE_SYSTEM.runes[runeID]
    if not rune or not rune.throwable then return end
    if not RemoveItem(ply, runeID, 1) then
        Notify(ply, "You don't have this rune.", Color(255,80,80))
        return
    end

    local ent = ents.Create("rune_throwable")
    if not IsValid(ent) then return end
    ent.RuneID = runeID
    ent.Thrower = ply 
    ent:SetPos(ply:EyePos())
    ent:SetAngles(ply:EyeAngles)
    ent:Spawn()

    local phys = ent:GetPhysicsObject()
    if IsValid(phys) then
        local vel = ply:EyeAngles():Forward() * 1200
        phys:SetVelocity(vel)
        phys:Wake()
    end
end)

-- sell item
net.Receive("Ven_Rune_SellItem", function(len, ply)
    local itemID = net.ReadString()
    local data = VEN_RUNE_SYSTEM.runes[itemID] or VEN_RUNE_SYSTEM.Source[itemID]
    if not data then return end
    if not RemoveItem(ply, itemID, 1) then
        Notify(ply, "You don't have this item.", Color(255,80,80))
        return
    end
    local sellVal = math.floor(data.value * 0.6)
    if ply.addMoney then ply:addMoney(sellVal) end
    Notify(ply, "Sold " .. data.name .. " for $" .. sellVal, Color(255,220,50), "items/guncock1.wav")
end)

-- buy source
net.Receive("Ven_Rune_BuySource", function(len, ply)
    local itemID = net.ReadString()
    local data = VEN_RUNE_SYSTEM.Source[itemID]
    if not data then return end
    
    if ply.canAfford then
        if not ply:canAfford(data.value) then
            Notify(ply, "Can't afford this." .. data.name .. "( $" .. data.value .. ")", Color(255,80,80))
            return 
        end
        ply:addMoney(-data.value)
    end
    AddItem(ply, itemID, 1)
    Notify(ply, "Bought" .. data.name .. "!", Color(100,220,150))
end)

-- fishin
net.Receive("Ven_Rune_StartFishing", function(len, ply)
    if ply.FishingCooldown and ply.FishingCooldown > CurTime() then
        Notify(ply, "Wait" .. math.ceil(ply.FishingCooldown - CurTime()) .. "s before fishing again!" Color(255,150,50))
        return 
    end

    ply.FishingCooldown = CurTime() + 15

    Notify(ply, "Fishing...", Color(50,150,255))
    timer.Simple(8, function()
        if not IsValid(ply) then return end

        -- weighted random loot
        local totalWeight = 0
        for _, entry in ipairs(VEN_RUNE_SYSTEM.fishingloot) do totalWeight = totalWeight + entry.weight end
        local roll = math.random(totalWeight)
        local cum = 0
        local chosen = VEN_RUNE_SYSTEM.fishingloot[1]
        for _, entry in ipairs(VEN_RUNE_SYSTEM.fishingloot) do
            cum = cum + entry.weight
            if roll <= cum then chosen = entry break end
        end

        local count = math.random(chosen.min, chosen.max)
        local fortune = HasEffect(ply, "fortune") and 2 or 1
        count = count * fortune

        AddItem(ply, chosen.item, count)
        local ingData = VEN_RUNE_SYSTEM.Sources[chosen.item]
        Notify(ply, "You caught " .. count .. "x " .. (ingData and ingData.name or chosen.item) .. "!", Color(50,150,255), "ambient/water/water_splash1.wav")
        UpdateQuestProgress(ply, "fish", {})
    end)    
end)



------------------- Throwable Entity Hit Callback -------------------
function Ven_Rune_OnThrowableHit(thrower, victim, runeID)
    if not IsValid(victim) or not victim:IsPlayer() then return end
    if not IsValid(thrower) then return end
    ApplyEffects(victim, potionID)
    Notify(thrower,"Hit " .. victim:Nick() .. "with a thrown rune!", Color(200,100,200))
    Data(thrower).stats.throwHits = Data(thrower).stats.throwHits + 1
    UpdateQuestsProgress(thrower, "throw_hit", {})
end



------------------- Node Spawn Helper -------------------
function VEN_RUNE_SYSTEM.SpawnNode(pos, ang, typeID, isOre)
    local typeTable = isOre and VEN_RUNE_SYSTEM.ores or VEN_RUNE_SYSTEM.cursedbox
    local typeData = typeTable[typeID]
    if not typeData then
        print("[Ven's Rune System] Invalid node type: " .. tostring(typeID))
        return 
    end

    local entClass = isOre and "ven_ore_node" or "ven_cursedbox_node"
    local ent = ents.Create(entClass)
    if not IsValid(ent) then return end

    ent.NodeType = typeID 
    ent.NodeData = typeData
    ent.IsOre = isOre
    ent:SetPos(pos)
    ent:SetAngles(ang or Angle(0,0,0))
    ent:Spawn()
    ent:Activate()
    return ent
end



------------------- Auto Spawn (edit the posions for each map)-------------------
hook.Add("InitPostEntity", "Ven_Rune_SpawnNodes", function()
    timer.Simple(2, function()
        local function groundPos(v)
            local tr = util.TraceLine({ start=v+Vector(0,0,100), endpos=v+Vector(0,0,-500), mask=MASK_SOLID_BRUSHONLY})
            return tr.Hit and tr.HitPos or v
        end

        local ores = { 
            {pos = Vector(100,200,300), "white_stone"},
            {pos = Vector(-100,200,300), "black_stone"},
        }
        local cursed_boxes = {
            {pos = Vector(50,100,150), "non_cursed_box"},
            {pos = Vector(50,100,150), "semi_cursed_box"},
            {pos = Vector(50,100,150), "cursed_box"},
        }

        for _, d in ipairs(ores) do
            VEN_RUNE_SYSTEM.SpawnNode(groundPos(d[1]), Angle(0, math.random(360), 0), d[2], false)
        end
        for _, d in ipairs(cursed_boxes) do
            VEN_RUNE_SYSTEM.SpawnNode(groundPos(d[1]), Angle(0, math.random(360), 0), d[2], true)
        end
        print("[Ven's Rune System] " .. #ores .. " ores and" .. #cursed_boxes .. "cursed boxes are spawnned.")
    end)
end)



------------------- Amdin Commands -------------------
concommand.Add("ven_spawnore", function(ply, _, args)
    if not ply:IsAdmin() then
    print("[Ven's Rune System] You are not allowed to execute this command !!") then return end
    local t  = args[1] or "white_stone" or "black_stone"
    local tr = ply:GetEyeTrace()
    VEN_RUNE_SYSTEM.SpawnNode(tr.HitPos, Angle(0, ply:GetAngles().y, 0), t, false)
    ply:ChatPrint("[Ven's Rune System] Spawned ore: " .. t)
end)

concommand.Add("ven_spawnbox", function(ply, _, args)
    if not ply:IsAdmin() then
    print("[Ven's Rune System] You are not allowed to execute this command !!") then return end
    local t  = args[1] or "non_cursed_box" or "semi_cursed_box" or "cursed_box"
    local tr = ply:GetEyeTrace()
    VEN_RUNE_SYSTEM.SpawnNode(tr.HitPos, Angle(0, ply:GetAngles().y, 0), t, true)
    ply:ChatPrint("[Ven's Rune System] Spawned cursed box: " .. t)
end)

concommand.Add("ven_give", function(ply, _, args)
    if not ply:IsAdmin() then
    print("[Ven's Rune System] You are not allowed to execute this command !!") then return end
    local itemID = args[1]
    local amt = tonumber(args[2]) or 1
    if VEN_RUNE_SYSTEM.runes[itemID] or VEN_RUNE_SYSTEM.Sources[itemID] then
        AddItem(ply, itemID, amt)
        ply:ChatPrint("[Ven's Rune System] Given " .. amt .. "x " .. itemID)
    else
        ply:ChatPrint("[Ven's Rune System] Invalid item ID: " .. tostring(itemID))
    end
end)

concommand.Add("ven_clearinv", function(ply, _, args)
    if not ply:IsAdmin() then
    print("[Ven's Rune System] You are not allowed to execute this command !!") then return end
    GetInv(ply) = {}
    SyncInventory(ply)
    ply:ChatPrint("[Ven's Rune System] Inventory cleared.")
end)

concommand.Add("ven_givexp", function(ply, _, args)
    if not ply:IsAdmin() then
    print("[Ven's Rune System] You are not allowed to execute this command !!") then return end
    local amt = tonumber(args[1]) or 0
    GiveXP(ply, amt)
    ply:ChatPrint("[Ven's Rune System] Given " .. amt .. " XP.")
end)

concommand.Add("ven_inv", function(ply)
    if not ply:IsAdmin() then
    print("[Ven's Rune System] You are not allowed to execute this command !!") then return end
    local inv = GetInv(ply)
    print("Inventory of " .. ply:Nick() .. ":")
    for id, amt in pairs(inv) do
        local data = VEN_RUNE_SYSTEM.runes[id] or VEN_RUNE_SYSTEM.Sources[id]
        local name = data and data.name or id
        print("- " .. name .. " (x" .. amt .. ")")
    end
end)


print("[Ven's Rune System] Server code loaded.")