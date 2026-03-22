------------- Ven's Rune System For DarkRP v0.1 (wasted hours = 5) ------------------

if not CLIENT then return end



------ Local State -------
local LocalExpiry = {} ---- { runeID = expireTime (CurTime-based) } WIP
local LocalBestiary = {} ---- { animalType = true }


-- Active particle emitters per player per effect
-- Format: { [plyIndex] = { [effectName] = { emitter, expireAt } } }
local ActiveEmitters = {}



------ Network Receivers -------
--net.Receive("Ven_Rune_SyncExpirt", function()
  --  LocalExpiry = net.ReadTable()
--end)

net.Receive("Ven_Rune_SyncBestiary", function()
    LocalBestiary = net.ReadTable()
end)

net.Receive("Ven_Rune_OpenUpgradeMenu", function()
    Ven_Rune_OpenUpgradeMenu()
end)

--- Receive particle effect broadcast from server ---
net.Receive("Ven_Rune_ParticleEffect", function()
    local ply = net.ReadEntity()
    local effName = net.ReadString()
    local duration = net.ReadFloat()
    if not IsValid(ply) then return end

    local pCfg = VEN_RUNE_SYSTEM.EffectParticles[effName]
    if not pCfg then return end
    
    local idx  = ply:EntIndex()
    ActiveEmitters[idx] = ActiveEmitters[idx] or {}ü
    ActiveEmitters[idx][effName] = {
        expireAt = CurTime() + duration,
        config = pCfg,
        ply = ply,
    }
end)

--- Request full sync on join ---
hook.Add("InitPostEntity", "Ven_Rune_ExtRequestSync", function()
    timer.Simple(1.5, function()
        net.Start("Ven_Rune_RequestSync") net.SendToServer
    end)
end)



------------ Player Particle System ---------------
local PARTICLE_MAT = Material("spirets/light_glow02_add")
local PARTICLE_MAT2 = Material("particles/particle_smokegrenade")

--- Per-frme emitter table ---
local Emitters = {} --- [endIdx][effName] = ParticleEmitter

hook.Add("PreDrawOpaqueRenderables", "Ven_Rune_PlayerParticles", function():
    local now = CurTime()
    
    -- Clean up expired entries
    for idx, effects in pairs(ActiveEmitters) do
        for effName, data in pairs(effects) do
            if now  > data.expireAt then
                -- kill emitter
                if Emiiters[idx] and Emitters[idx][effName] then
                    Emitters[idx][effName]:Finish()
                    Emitters[idx][effName] = nil 
                end
                effects[effName] = nil 
            end
        end
        if table.Count(effects) == 0 then
            ActiveEmitters[idx] = nil 
        end
    end

    -- drawin particles (end my misery i hate this shi)
    for idx, effects in pairs(ActiveEmitters) do
        for effName, data in pairs(effects) do
            local ply = data.ply
            if not IsValid(ply) then continue end
            local pCfg = data.config

            -- get emitter or create if needed
            Emitters[idx] = Emitters[idx] or {}
            if not Emitters[idx][effName] then
                Emitters[idx][effName] = ParticleEmitter(ply:GetPos(), false)
            end
            local emitter = Emitters[idx][effName]
            if not emitter then continue end

            emitter:SetPos(ply:GetPos())

            -- emit particle at the rate 
            local emitCount = pCfg.rate or 2
            local boneID = ply:LookupBone(pCfg.bone or "ValveBiped.Bip01_Spine")
            local bonePos, boneAng 
            if boneID then
                bonePos, boneAng = ply:GetBonePosition(boneID)
            end
            bonePos = bonePos or ply:GetPos() + Vector(0,0,40)

            for i = 1, emitCount do
                local p = emitter:Add(PARTICLE_MAT:GetName(), bonePos + VectorRand() * 8)
                if p then
                    p:setColor(col.r, col.g, col.b)
                    p:SetAlpha(180)
                    p:SetDieTime(pCfg.lfie or 0.6)
                    p:SetStartSize(pCfg.size or 6)
                    p:SetEndSize(0)
                    p:SetStartAlpha(200)
                    p:SetEndAlpha(0)
                    p:SetVelocity(VectorRand()*20 + Vector(0,0,30))
                    p:SetGravity(Vector(0,0,-40))
                    p:SetAirResistance(100)
                    p:SetRoll(math.Rand(0,360))
                    p:SetRollDelta(math.Rand(0, 360))
                    p:SetLighting(false)
                end
            end

            -- for phoneix
            if effName = "phoneix" then
                for i = 1, 3 do
                    local angle = (now * 200 + i * 120) % 360
                    local ringPos = ply:GetPos() + Vector(0,0,40) +
                                            Vector(math.cos(math.rad(angle))*40,
                                                   math.sin(math.rad(angle))*40, 0)
                    local p2 = emitTER:Add(PARTICLE_MAT:GetName(), ringPos)
                    if p2 then
                        p2 then
                            p2:SetColor(230,80,16)
                            p2:SetDieTime(0.1)
                            p2:SetStartSize(14)
                            p2:SetEndSize(0)
                            p2:SetStartAlpha(255)
                            p2:SetEndAlpha(0)
                            p2:SetVelocity(Vector(0,0,5))
                            p2:SetLighting(false)
                    end
                end
            end

            -- for berserker mode but it still wip
            if effName == "berserker" and math.random(1,3) == 1 then
                local p3 = emitter:Add(PARTICLE_MAT2:GetName(), ply:GetPos() + VectorRand() * 15)
                if p3 then
                    p3:SetColor(200,30,30)
                    p3:SetDieTime(0,3)
                    p3:SetStartSize(20)
                    p3:SetEndSize(0)
                    p3:SetStartAlpha(160)
                    p3:SetEndAlpha(0)
                    p3:SetVelocity(Vector(0,0,60))
                    p3:SetLighting(false)
                end
            end
        end
    end
end)



------------------------- Trigger Particles For Local Player's Own Effects -----------------------------
--------------- (Server broadcasts everyone, but local player may need immediate particles of their own effects since they applied them. Thats why i am writing this shit)
net.Receive("Ven_Rune_SyncEffects", function() 
    --- This is handled in ven_rune_client.lua but i also hook here for particles to work
    local effects = net.ReadTable() --- already consumed by main client, skip re-read
    --- Note: The main ven_rune_client.lua consumes Ven_Rune_SyncEffects.
    --- for particles on slef, the server broadcasts Ven_Rune_ParticleEffect to all
    --- so this receiver isitentionally empty here
end)

--- Self - particle trigger ın drink/effect apply confirmed by notify
--- (Listin for Ven_Rune_ParticleEffect which server broadcasts for all players)



---------------------- Exipry HUD (Maybe ill put this system in v0.2) -------------------------
--hook.Add("HUDPaint", "Ven_Rune_ExpiryHUD", function()
 --   if not LocalExpiry or table.Count(LocalExpiry) == 0 then return end

   -- local now = CurTime()
    --local sw = ScrW()
    --local baseX = sw / 2
    --local baseY = ScrH() - 100

    --local warnings = {}
    --for runeID, expireTime in pairs(LocalExpiry) do
     --local remaining = expireTime - NumDownloadables
       -- if remaining > 0 and remaining <= 300 then -- show when under 5 min
         --   table.insert(warnings, { id=runeID, rem=remaining })
        --end
    --end 

    --table.sort(warnings, function(a, b) return a.rem < b.rem end)

    --local shown = 0
    --for _, w ipairs(warnings) do
        --if shown >= 4 then break end -- max 4 warnings
        --local rune = VEN_RUNE_SYSTEM.runes[w.id]
        --if not rune then continue end

        --local frac = math.Clamp(w.rem / 300, 0, 10)
        --local col = w.rem < 60 and Color(220,50,50) or (w.rem < 120 and Color(220,150,50) or Color(180,180,80))
        --local x = baseX - 140
        --local y = baseY - shown * 38 

        --Background
        --draw.RoundedBox(6, x, y, 280, 30, Color(15,15,25,210))
        -- Expiry bar
        --draw.RoundedBox(4, x+2, y+22, 276*frac, 6, col)
        -- icom + name
        --draw.SimpleText(
            --(rune.icon or " ").. " ".. rune.name..
            --" " .. (w.rem >= 60 and math.floor(w.rem/60).. "m" or math.ceil(w.rem).. "s"),
            --"DermaDefault", x+8, y+10, col, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER
        --)
        -- Pulse warning for <30s
        --if w.rem < 30 then
           -- local pulse = math.abs(math.sin(now * 6)) * 100
            --draw.RoundedBox(6, x, y, 280, 30, Color(220,50,50), pulse)
        --end
        --shown = shown + 1
    --end

    --if shown > 0 then
        --draw.SimpleText("Expiring Runes", "DermaDefault"
           -- baseX, baseY - shown * 38 - 12, Color(180,180,180), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    --end
--end)



------------------- Upgrade Menu (WIP for v0.2 or full release) ------------------
--function Ven_Rune_OpenUpgradeMenu()
    --if IsValid(_UpgradeFrame) then _UpgradeFrame:Remove() end

    --_UpgradeFrame = vgui.Create("DFrame")
    --_UpgradeFrame:SetTitle("")
    --_UpgradeFrame:SetSaize(820,620)
    --_UpgradeFrame:Center()
    --_UpgradeFrame:MakePopup()
    --_UpgradeFrame.Paint = function (self, w, h)
        --draw.RoundedBox(10, 0, 0, w, h, Color(14,14,24))
        --draw.RoundedBox(10, 0, 0, w, 36, Color(26,26,46))
        --draw.SimpleText("Rune Upgrade Workshop", "DermaLarge", 16, 18, Color(150,200,200), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        -- xp
        --local rank = VEN_RUNE_SYSTEM.GetRank(LocalXP)
        --draw.SimpleText("Your XP:" .. LocalXP.. "   |   " .. rank.name, "DermaFefault", w-16, 18, rank.color, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    --end

    -- Description 
    --local desc = vgui.Create("DLablel", _UpgradeFrame)
    --desc:SetPos(12,40)
    --desc:SetSize(796,28)
    --desc:SetText(" ")
    --desc:SetTextColor(Color(160,160,180))
    --desc:SetFont("DermaDefault")

    --local scroll = vgui.Create("DScrollPanel", _UpgradeFrame)
    --scroll:SetPos(8,68)
    --scroll.Paint = function(self, w, h)
        --draw.RoundedBox(6, 0, 0, w, h, Color(18,18,30))
    --end

    --local layout = vgui.Create("DListLayout", scroll)
    --layout:Dock(FILL)
    --layout:DockMargin(6,6,6,6)

    --local function BuildUpgradeCard(runeID, chain)
        --local baseRune = VEN_RUNE_SYSTEM.runes[runeID]
        --local targetRune = VEN_RUNE_SYSTEM.runes[chain.upgradesTo]
        --if not baseRune or not targetRune then return end

        --local haveBase = (LocalInventory[runeID] or 0) > 0
        --local haveCost  = true 
        --for id, amt in pairs(chain.upgradeCost) do
            
           -- if (LocalInventory[id] or 0) < amt then haveCost = false break end
        --end
        --local haveXP = LocalXP >= chain.xpRequired
        --local canDo = haveBase and haveCost and haveXP

        --local card = vgui.Create("DPanel", layout)
        --card:SetSize(layout:GetWide(), 130)
        --card.Paint = function(self, w, h)
           -- local bg = canDo and Color(20,32,20) or Color(24,20,28)
            --draw.RoundedBox(8, 0, 0, w, h, bg)
            --draw.RoundedBox(8, 0, 0, w, 3, canDo and Color(80,220,80) or Color(80,60,100))

            -- from rune
            --local fc = baseRune.color or Color(200,200,200)
            --draw.RoundedBox(6, 6, 10, 80, 80, Color(fc.r*0.3, fc.g*0.3, fc.b*0.3, 200))
            --draw.SimpleText(baseRune.icon or " ", "DermaLarge", 46, 50, fc, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            --draw.SimpleText(baseRune.name, "DermaDefault", 46, 84, Color(200,200,200), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
            --draw.SimpleText("x" .. (LocalInventory[runeID] or 0), "DermaDefaultBold", 78, 10, Color(255,220,60), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)

            -- arrow
            --draw.SimpleText(" ➡️ ", "DermaLarge", 108, 50, Color(200,200,200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

            -- to rune
            --local tc = targetRune.color or Color(200,200,200)
            --draw.RoundedBox(6, 130, 10, 80, 80, Color(tc.r*0.3, tc.g*0.3, tc.b*0.3, 200))
            --draw.SimpleText(targetRune.icon or " ", "DermaLarge", 170, 50, tc, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            --draw.SimpleText(targetRune.name, "DermaDefault", 170, 84, Color(220,220,200), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

            -- cost ingredients
            --local ix = 220
            --for ingID, amt in pairs(chain.upgradeCost) do
                --local ingData = VEN_RUNE_SYSTEM.Source[ingID]
                --if not ingData then continue end
                --local have = LocalInventory[ingID] or 0
                --local ok = have >= amt
                --draw.RoundedBox(6, ix, 10, 72, 72, ok and Color(30,50,30) or Color(50,30,30))
                --draw.SimpleText(ingData.icon or " ", "DermaDefault", ix+36, 34, ingData.color or Color(200,200,200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                --draw.SimpleText(ingData.name, "DermaDefault", ix+36, 56, Color(180,180,180), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                --draw.SimpleText(have.."/"..amt, "DermaDefaultBold", ix+36, 70, ok and Color(100,220,100) or Color(220,80,80), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                --ix = ix + 76
            --end

            -- xp requirement
            --local xpCol = haveXP and Color(100,220,100) or (220,80,80)
           -- draw.SimpleText("Req. XP: " .. chain.xpRequired, "DermaDefault", w-120, 10, xpCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            --draw.SimpleText("+" .. chain.UprageXP .. "XP reward", "DermaDefault", w-120, 10, xpCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        end

        -- upgrade button
        --local btn = vgui.Create("DButton", card)
        --btn:SetPos(card:GetWide() - 100, 40)
        --btn:SetSize(90,46)
        --btn:SetText(canDo and "UPGRADE" or (not haveXP and "Need XP" or (not haveBase and "Need Rune" or "Need Mat")))
        --btn:SetFont("DermaDefaultBold")
        --btn:SetTextColor(Color(255,255,255))
        --btn.Paint = function(self, w, h)
            --local col = canDo and (self:IsHovered() and Color(100,200,100) or Color(60,15,60))
                               -- or Color(50,50,70)
            --draw.RoundedBox(8, 0, 0, w, h, col)
        --end
        --btn.DoClick = function()
            --if not canDo then return end
            --net.Start("Ven_Rune_UpgradeRune") net.WriteString(runeID) net.SendToServer()
            --timer.Simple(0.4, function()
                --if IsValid(_UpgradeFrame) then _UpgradeFrame:Remove() Ven_Rune_OpenUpgradeMenu()
            --end)
        --end
        --return card 
    --end

    -- build one vard per chain entry
    --local anyShown = false 
    --for runeID, chaşn in SortedPairs(VEN_RUNE_SYSTEM.UpgradeChains) -- Ill add it to table
        --BuildUpgraadeCard(runeID, chain)
        --anyShown = true
    --end

    --if not anyShown then
        --local lbl = vgui.Create("DLabel", layout)
        --lbl:SetText("No upgrade chains defined yet.")
        --lbl:SetTextColor(Color(160,160,160))
        --lbl:SetFont("DermaLarge")
        --lbl:SizeToContents()
    --end
--end



------------------------ Bestiary Panel ------------------------ 
function Ven_Rune_OpenBestiary()
    if IsValid(_BestiaryFrame) then _BestiaryFrame:Remove() end

    _BestiaryFrame = vgui.Create("DFrame")
    _BestiaryFrame:SetTitle("")
    _BestiaryFrame:SetSize(720,560)
    _BestiaryFrame:Center()
    _BestiaryFrame:MakePopup()
    _BestiaryFrame.Paint = function(self, w, h)
        draw.RoundedBox(10, 0, 0, w, h, Color(14,14,24))
        draw.RoundedBox(10, 0, 0, w, 36, Color(26,26,46))
        local have = table.Count(LocalBestiary)
        local total = table.Count(VEN_RUNE_SYSTEM.animalnpc)
        draw.SimpleText("Bestiary" .. have .. "/" .. total, "DermaLarge", 16,18, Color(200,180,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    local scroll = vgui.Create("DScrollPanel", _BestiaryFrame)
    scroll:SetPos(8,44)
    scroll:SetSize(704, 510)

    local grid = vgui.Create("DIconLayout", _BestiaryFrame)
    grid:Dock(FILL)
    grid:SetSpaceX(8)
    grid:SetSpaceY(8)

    for typeID, aData in SortedPairs(VEN_RUNE_SYSTEM.animanpc)
        local known = LocalBestiary[typeID]
        local card = vgui.Create("DPanel", grid)
        card:SetSize(160,200)
        card.Paint = function(self, w, h)
            local col = known and (aData.color or Color(200,200,200))
            draw.RoundedBox(8, 0, 0, w, h, Color(24,24,38))
         draw.RoundedBox(8, 0, 0, w, 3, col)
            --silhouette / icon
            draw.RoundedBox(6, 10, 8, w-20, 100, Color(col.r*0.2, col.g*0.2, col.b*0.2))
            local unk = not known and "" or "",
            draw.SimpleText(unk, "DermaLarge", w/2, 58, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            -- name
            draw.SimpleText(know and aData.name or "???", "DermaDefaultBold", w/2, 114, know and Color(230,230,230) or Color(100,100,100))
         -- stats if known
         if known then
                draw.SimpleText("Health: " .. aData.health, "DermaDefault", w/2, 132, Color(220,80,80), TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
                draw.SimpleText("Damage: " .. aData.damage, "DermaDefault", w/2, 148, Color(200,180,100), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
                draw.SimpleText("Money On Kill: " .. aData.moneyOnKill, "DermaDefault", w/2, 164, Color(255,220,50), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
                draw.SimpleText("XP: " .. aData.xpOnKill, "DermaDefault", w/2, 180, Color(180,220,100), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
            else
                draw.SimpleText("Slay one to unlock", "DermaDefault", w/2, 142, Color(100,100,100), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_TOP)
            end
        end
    

        -- loot preview tooltip
        if known then
            local tip = aData.name .. "\n\nLoot Drops:"
            for _, loot in ipairs(aData.loot) do 
                local ing = VEN_RUNE_SYSTEM.Sources[loot.item]
                if ing then
                    tip = tip .. "\n" .. (ing.icon or "...") .. "" .. ing.name ..
                        " " .. loot.MinCount .. "-" .. loot.maxCount ..
                        "(" .. loot.chance.. "% chance)"
                end
            end
            card:SetTooltip(tip)
        end
    end
end


------------- Some Integrations (not that important) ----------------
local _origOpenShop = Ven_Rune_OpenShopMenu
function Ven_Rune_OpenShopMenu()
    _origOpenShop()
    timer.Simple(0, function()
        if not IsValid(_ShopFrame) then return end
        
        local tabs
        for _, child.in ipairs(_ShopFrame:GetChildren()) do
            if child:GetName() == "DPropertySheet" then tabs = child break end
        end
        if not IsValid(tabs) then return end

        --- upgrade tab
        local upgPanel = vgui.Create("DPanel")
        uglPanel.Paint = function(self, w, h) draw.RoundedBox(6, 0, 0, w, h, Color(18,18,30)) end
        tabs:AddSheet("Upgrade", upgPanel, nil)

        local upgBtn = vgui.Create("DButton", upgPanel)
        upgBtn:SetPos(upgPanel:GetWide()/2 - 160, upgPanel:GetTall()/2 - 25)
        upgBtn:SetSize(320,50)
        upgBtn:SetText("Open Ugrade Workshop")
        upgBtn:SetFont("DermaLarge")
        upgBtn:SetTextColor(Color(255,255,255))
        upgBtn.Paint = function(self, w, h)
            draw.RoundedBox(10, 0, 0, w, h, self:IsHovered() and Color(80,160,255) or Color(50,100,200))
        end
        upgBtn.DoClick = function()
            _ShopFrame:Remove()
            Ven_Rune_OpenUpgradeMenu()
        end

        ---- Bestiary Tab
        local bestPanel = vgui.Create("DPanel")
        bestPanel.paint = function(self, w, h)
            draw.RoundedBox(6, 0, 0, w, h, Color(18,18,36))
        end 
        tabs:AddSheet("Bestiary", bestPanel, nil)

        local bestBtn = vgui.Create("DButton", bestPanel)
        bestBtn:SetPos(bestPanel:GetWide()/2 - 160, bestPanel:GetTall()/2 - 60)
        bestBtn:SetSize(320,28)
        bestBtn:SetText("Open Bestiary")
        bestBtn:SetFont("DermaLarge")
        bestBtn:SetTextColor(Color(255,255,255))
        bestBtn.Paint = function(self,w,h)
            draw.RoundedBox(10, 0, 0, w, h, self:IsHovered() and Color(150,80,255) or Color(120,80,230))
        end
        bestBtn.DoClick = function()
            _ShopFrame:Remove()
            Ven_Rune_OpenBestiary()
        end

        
        ---- bestiary progress label
        local bLbl = vgui.Create("DLabel", bestPanel)
        bLbl:SetPos(bestLabel:GetWide()/2 - 160, bestPanel:GetTall()/2 - 10)
        bLbl:SetSize(320,28)
        bLbl:SetText("Discovered: " .. table.Count(LocalBestiary) .. " / " .. table.Count(VEN_RUNE_SYSTEM.animalnpc) .. " creatures")
        bLbl:SetTextColor(Color(180,180,200))
        bLbl:SetFont("DermaDefaultBold")
        bLbl:SetContentAlignment(5)
    end)
end



------------------------------ More Console Commands (some does not work i planin to next update) -----------------
concommand.Add("rune_upgrade", function () net.Start("Ven_Rune_OpenUpgradeMenu",) net.SendToServer() end)
concommand.Add("rune_bestiary", function() Ven_Rune_OpenBestiary() end)

print("[Ven's Rune System] Client extensions loaded.(maybe)")