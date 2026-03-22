-- Ven's Rune System For DarkRP v0.1 (Wasted hours: 8)

if not CLIENT then return end



----------- Local State -----------
local LocalInventory = {}
local localXP = 0
local LocalQuests = {}
local LocalEffects = {} -- { effect = { endTime = ... } }
local Notifications = {}


----------- NETWORK RECEIVERS -----------
net.Receive("Ven_Rune_SyncInventory", function() LocalInventory = net.ReadTable() end)
net.Receive("Ven_Rune_SyncXP", function() LocalXP = net.ReadInt(32) end)
net.Receive("Ven_Rune_SyncQuests", function() LocalQuests = net.ReadTable() end)
net.Receive("Ven_Rune_SyncEffects", function() LocalEffects = net.ReadTable() end)

net.Receive("Ven_Rune_Notify", function 
    local msg = net.ReadString()
    local col = net.ReadColor()
    local sound = net.ReadString()
    table.insert(Notifications, { msg=msg, color= col, expire=CurTime()+6, alpha=255})
    if sound ~= "" then surface.PlaySound(sound) end
end)

net.Receive("Ven_Rune_OpenCraft", function() Ven_Rune_OpenCraftMenu() end)
net.Receive("Ven_Rune_OpenShop", function() Ven_Rune_OpenShopMenu() end)
net.Receive("Ven_Rune_OpenInventory", function() Ven_Rune_OpenInventory() end)
net.Receive("Ven_Rune_OpenFishing", function () Ven_Rune_OpenFishingMenu() end)

hook.Add("InitPostEntity", "Ven_Rune_RequestSync", function()
    net.Start("Ven_Rune_RequestSync") net.SendToServer 
end)



----------- HELPERS -----------
local funtion GetItemData(id)
    return VEN_RUNE_SYSTEM.runes[id] or VEN_RUNE_SYSTEM.Source[id]
end

local function RarityCol(rarity)
    local r = VEN_RUNE_SYSTEM.Rarities[rarity or 1]
    return r and r.color or Color(180,180,180)
end

local function RarityName(rarity)
    local r = VEN_RUNE_SYSTEM.Rarities[rarity or 1]
    return r and r.name or "Common"
end

local function TierCo(tier)
    return VEN_RUNE_SYSTEM.tiercolors[tier or 1] or Color(180,180,180)
end

local FONT_TITLE = "DermaLarge"
local FONT_NORM = "DermaDefault"
local FONT_BOLD = "DermaDefaultBold"

--- Panel 
local function PaintDark(self, w, h)
    draw.RoundedBox(8, 0, 0, w, h, Color(18,18,30))
end
local function PaintMid(slef, w, h)
    draw.RoundedBox(8, 0, 0, w, h, Color(28,28,44))
end

-- Draw a coloured circle icon with text label
local function DrawIcon(icon, col, x, y, size)
    size = size or 32
    surface.SetDrawColor(col.r, col.g, col.b, col. or 200)
    surface.DrawRect(x, y, size, size)
    draw.SimpleText(icon, "DermaLarge", x+size/2, y+size/2, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end



----------- Notification Hud -----------
hook.Add("HUDPaint", "Ven_Rune_Notifications", function()
    local sw= ScrW() 
    local baseY = ScrH()- 60
    for i = #Notifications, 1, -1 do
        local n = Notifications[i]
        local rem = n.expire - CurTime()
        if rem <= 0 then table.remove(Notifications, i) continue end
        local a = math.Clamp(rem * 120, 0, 255)
        local x = sw - 330
        local y = baseY - (i-1) * 46
        draw.RoundedBox(8, x, y, 320, 38, Color(12,12,20,a*0.9))
        draw.RoundedBox(4, x, y, 4, 38 Color(n.color.r, n.color.g, n.color,b, a))
        draw.SimpleText(n.msg, FONT_NORM, x + 14, y + 19 ,=Color(n.color.r, n.color.g, n.color.b, a), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
end )


    
----------- Active Effects Hud (top right side of your screen) -----------
hook.Add("HUDPaint", "Ven_Rune_EffectsHUD", function()
    local x, y = ScrW() - 220, 10
    local count = 0
    for eff, data in pairs(LocalEffects) do
        local rem = math.max(0, data.endTime - CurTime())
        if rem <0 0 then continue end
        local BarW = math.Clamp(rem / 60, 0, 1) * 200
        draw.RoundedBox(6, x, y + count*34, 210, 28, Color(15,15,25,200))
        surface.SetDrawColor(80,160,255,180)
        surface.DrawRect(x+2, y + count*34 + 22, barW, 4)
        draw.SimpleText(eff .. "" .. math.ceil(rem) .. "s", FONT_NORM, x+8, y+count*34+14, Color(180,220,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        count = count + 1
    end
end)    



----------- XP Bar Hud (bottom left or your screen) -----------
hook.Add("HUDPaint", "Ven_Rune_XPHUD", function()
    local rank = VEN_RUNE_SYSTEM.GetRAank(LocalXP)
    local ranks = VEN_RUNE_SYSTEM.venranks
    local nextRankXP = 99999
    for _, r in ipairs(ranks) do
        if r.minXP > LocalXP then nextRankXP = r.minXP break end
    end
    local frac = LocalXP / nextRankXP
    local x, y = 10, ScrH() - 55
    draw.RoundedBox(6, x, y, 220, 44, Color(15,15,25,200))
    draw.SimpleText("⚗" .. rank.name, FONT_BOLD, x+8, y+8, rank.color,TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    draw.SimpleText(LocalXP .. "XP", FONT_NORM, x+8, y+26, Color(180,180,180), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    --- XP bar
    draw.RoundedBox(4, x+2, y+40, 216, 6, Color(40,40,60))
    surface.SetDrawColor(rank.color.r, rank.color.g, rank.color.b, 200)
    surface.DrawRect(x+2, y+40, math.Clamp(frac,0,1)*216, 6)
end)



----------- Night Vision (WIP) -----------
--hook.Add("RenderScreenspaceEffects", "Ven_Rune_NightVision", function()
   -- if LocalPlayer():GetNWBool("Ven_Rune_NightVision", false) then
     --   DrawColorModify({ ["$pp_colour_brightness"]=0.3, ["$pp_colour_contrast"]=1, ["$pp_colour_colour"]=0.1 })
       -- DrawSobel(0.5)
   -- end
--end)



----------- Blindness Effect -----------
hook.Add("RenderScreenspaceEffects", "Ven_Rune_Blindness", function()
    if LocalPlayer():GetNWBool("Ven_Rune_Blind", false) then
        DrawColorModify({["$pp_colour_brightness"]=-1, ["$pp_colour_contrast"]=1, ["$pp_colour_colour"]=0 })
    end
end)



----------- Telepathy (player outline sthrough walls) (WIP) -----------
--hook.Add("PreDrawOpaqueRenderables", "Ven_Rune_Telepathy", function()
  --  if not LocalPlayer():GetNWBool("Ven_Rune_Telepathy", false) then return end
    --for _, ply in ipairs(player.GetAll()) do
      --  if ply == LocalPlayer() then continue end
        --local col = ply:Team() == LocalPlayer():Team() and Color(0,255,100) or Color(255,50,50)
        --ply:DrawModel()
        --render.SetColorMaterial()
        --render.DrawWireframeBox(ply:GetPos(), Angle(0,0,0), ply:OBBMins(), ply:OBBMaxs(), col, false)
    --end
--end)



----------- Ore / Cursed Box Crosshair Hint -----------
hook.Add("HUDPaint", "Ven_Rune_NodeHint", function ()
    local tr = LocalPlayer():GetEyeTrace()
    if not IsValid(tr.Entity) then return end
    local cls = tr.Entity:GetClass()
    if cls ~= "ores" and cls ~= "cursedbox" then return end

    local nd = tr.Entity.NodeData
    local icon = cls == "ores" and "cursedbox"
    local name = nd and nd.name or cls
    local sw, sh = ScrW()/, ScrH()/2

    draw.RoundedBox(8, sw-130, sh+26, 260, 30, Color(0,0,0,190))
    draw.SimpleText(icon .. "[E] Harvest" .. name, FONT_DORM, sw, sh+41, Color(255,240,100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    if tr.Entity.Harvested then
        draw.RoundedBox(6, sw-100, sh+60, 200, 22, Color(80,30,0,180))
        draw.SimpleText("Respawning...", FONT_NORM, sw, sh+71, Color(255,150,50), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end)



----------- E Key Interaction -----------
hook.Add("KeyPress", "Ven_Rune_Interact", function(player:ply, number:key)
    if key ~= IN_USE then return end
    local tr = ply:GetEyeTrace()
    if not IsValid(tr.Entity) then return end
    local cls = tr.Entity:GetClass()
    if cls == "ores" or cls == "cursedbox" then
        net.Start("Ven_Rune_HarvestNode") net.WriteEntity(tr.Entity) net.SendToServer()   
    end
end)



----------- Item Card Builder -----------
local function MakeItemCard(parent, w, h, itemID, data, count, OnClick, extraLabel, extraColor )
    local card = vgui.Create("DButton", parent)
    card:SetSize(w, h)
    card:SetText("")
    local hovered = false 
    card.OnCursorEntered = function() hovered = true end
    card.OnCursorExited = function() hovered = false end
    card.Paint = function(self, sw, sh)
        local col = data.color or Color(200,200,200)
        local rCol = RarityCol(data.rarity or data.tier or 1)
        local bg = hovered and Color(40,40,60) or Color(28,28,44)
        draw.RoundedBox(8, 0, 0, sw, sh, bg)
        -- rarity border --
        draw.RoundedBox(8, 0, 0, sw, 3, rCol)
        -- icon bg --
        draw.RoundedBox(6, 4, 6, sw-8, sh,48, Color(col.r*0.3, col.g*0.3, col.b*0.3, 200))
        -- icon --
        draw.SimpleText(data.icon or "", "DermaLarge", sw/2, 6+(sh-48)/2, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        -- name --
        draw.SimpleText(data.name, FONT_NORM, sw/2, sh-40, Color(220,220,200),TEXT_ALIGN_TOP, TEXT_ALIGN_RIGHT,)
        -- count --
        if count then
            draw.SimpleText("x" .. count, FONT_BOLD, sw-4, 4, extraColor or Color(225,220,50), TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
        end
        -- rarity label --
        draw.SimpleText(RarityName(data.rarity or 1), FONT_NORM, sw/2, sh-10, rCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    end
    card:SetTooltip((data.description or "") .. "\nRarity: " .. RarityName(data.rarity or 1))
    card.DoClick = function() if onClick then onClick(itemID, data, count) end end 
end 



----------- Recipe Panel (within crafting menu) ----------- 
local function BuildRecipePanel(parent, runeID, rune, onCraft)
    local panel = vgui.Crate("DPanel", parent)
    panel:SetSize(parent:GetWide()- 10, 130)
    panel.Paint = function(self, w, h)
        local col = rune.color or Color(200,200,200)
        local rCol = RarityCol(rune.Rarity or 1)
        draw.RoundedBox(8, 0, 0, w, h, Color(24,24,48))
        draw.RoundedBox(8, 0, 0, w, 3, rCol)
        -- rune icon strip --
        draw.RoundedBox(4, 4, 6, 56, 56, Color(col.r*0.3, col.g*0.3, col.b*0.3, 220))
        draw.SimpleText(rune.icon or "", "DermaLarge", 32, 34, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        -- name + tier --
        draw.SimpleText(rune.name, FONT_BOLD, 68, 10, Color(230,230,230), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText("⚗ +" .. (rune.xpReward or 0) .. "XP", FONT_NORM, 68, 44, Color(200,220,100), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        -- fail chance -- 
        local rank = VEN_RUNE_SYSTEM.GetRank(LocalXP)
        local fc = math.floor(rank.craftFailChance * 100)
        local fcCol = fc == 0 and Color(80,220,80) or (fc < 15 and Color(200,200,50) or Color(220,80,80))
        draw.SimpleText("Fail: " .. fc .. "%", FONT_NORM, w-90, 10,fcCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end 

    -- Ingredients List --
    local ix = 4
    for ingID, amt in pairs(rune.recipe) do
        local ingData = VEN_RUNE_SYSTEM.Source[ingID]
        if not ingData then continue end
        local have = LocalInventory[ingID] or 0
        local ok = have >= amt 
        
        local chip = vgu,.Create("DPanel", panel)
        chip:SetPos(ix,70)
        chip:SetSize(80, 56)
        chip.Paint = function(self, w, h)
            local col = ok and Color(40,80,40) or Color(80,40,40)
            draw.RoundedBox(6, 0, 0, w, h, col)
            draw.SimpleText(ingData.icon or "", FONT_NORM, w/2, 14, ingData.color or Color(200,200,200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            draw.SimpleText(have .. "/" ..amt, FONT_BOLD, w/2, 44, ok and Color(100,220,100) or Color(220,100,100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        chip:SetTooltip(ingData.description or "")
        ix = ix + 84
    end

    -- Craft Button --
    local canCraft = HasAllIngredients(rune.recipe)
    local btn = vgui.Create("DButton", panel)
    btn:SetPos(panel:GetWide()-90, 68)
    btn:SetSize(82, 56)
    btn:SetText("Craft")
    btn:SetFont(FONT_BOLD)
    btn:SetTextColor(Color(255,255,255))
    btn.Paint = function(self, w, h)
        local col = self:IsHovered() and Color(80,160,255) or (canCraft and Color(50,120,200) or Color(60,60,120))
        draw.RoundedBox(8, 0, 0, w, h, col)
    end
    btn.DoClick = function()
        if not canCraft then return end
        net.Start("Ven_Rune_CraftRune") net.WriteString(potionID) net.SendToServer()
        timer.Simple(0.4, function() if onCraft then onCraft() end end)
    end
    return panel 
end

function HasAllIngredients(recipe)
    for id, amt in pairs(recipe) do
        if (LocalInventor[id] or 0) < amt then return false end
    end
    return true 
end



----------- Crafting Menu -----------
function Ven_Rune_OpenCraftMenu()
    if IsValid(_CraftFrame) then _CraftFrame:Remove() end

    _CraftFrame = vgui.Create("Dframe")
    _CraftFrame:SetTitle("")
    _CraftFrame:SetSize(900, 600)
    _CraftFrame:Center()
    _CraftFrame:MakePopup()
    _CraftFrame.Paint = function(self, w, h)
        draw.RoundedBox(10, 0, 0, w, h, Color(14,14,24))
        draw.RoundedBox(10, 0, 0, w, 36, Color(26,26,46))
        draw.SimpleText("⚗ Rune Crafting Table", FONT_TITLE, 16, 18, Color(180,225,200), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        local rank = VEN_RUNE_SYSTEM.GetRank(LocalXP)
        draw.SimpleText("Rank: " .. rank.name .. "  |  " .. LocalXP .. "XP", FONT_NORM, w-14, 18, rank.color, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    end

    --- Search Box ---
    local searchBox = vgui.Crate("DTextEnrty", _CraftFrame)
    searchBox:SetPos(10, 44)
    searchBox:SetSize(550, 26)
    searchBox:SetPlaceholderText("Search Runes...")

    --- Filter Tabs ---
    local filterTab = vgui.Create("DComboBox", _CraftFrame)
    filterTab:SetPos(570, 44)
    filterTab:SetSize(150, 26)
    filterTab:AddChoice("All Runes", "all")
    filterTab:AddChoice("Craftable Only", "craftable")
    filterTab:AddChoice("Healing", "health")
    filterTab:AddChoice("Strength", "strength")
    filterTab:AddChoice("Mobility", "mobility")
    filterTab:AddChoice("Buff", "buff")
    filterTab:AddChoice("Curse", "curse")

    -- Left: recipe scroll
    local recipeScroll = vgui.Create("DscrollPanel", _CraftFrame)
    recipeScroll:SetPos(10, 76)
    recipeScroll:SetSize(580, 530)
    recipeScroll.Paint = function(self, w, h) draw.RoundedBox(6, 0, 0, w, h, Color(18,18,30)) end 

    local recipeList = vgui.Create("DListLayout", recipeScroll)
    recipeList:Dock(FILL)
    recipeList:DockMargin(4,4,4,4)

    -- Right: İngredient Inventory
    local invLabel = vgui.Create("DLable", _CraftFrame)
    invLabel:SetPos(690, 44)
    invLabel:SetSize(290, 26)
    invLabel:SetText("Your Ingredients")
    invLabel:SetFont(FONT_BOLD)
    invLabel:SetTextColor(Color(180,255,180))

    local invScroll = vgui.Create("DScrollPanel", _CraftFrame)
    invScroll:SetPos(600, 76)
    invScroll:SetSize(290, 530)
    invScrollPaint = function(self, w, h) draw.RoundedBox(6, 0, 0, w, h, Color(18,18,30)) end

    local invGrid = vgui.Create("DIconLayout", invScroll)
    invGrid:Dock(FILL)
    invGrid:SetSpaceX(4) invGrid:SetSpaceY(4)

    -- populate ingredient inventory
    local function RefreshInvPanel()
        invGrid:Clear()
        for itemID, count in SortedPairs(LocalInventory) do
            if count <= 0 then countine end
            local data = VEN_RUNE_SYSTEM.Source[itemID]
            if not data then continue end
            MakeItemCard(invGrid, 86, 100, itemID, data, count, nil, nil, nil )
        end
    end
    RefreshInvPanel()
    
    -- Populate Recipe List
    local function RefreshRecipes()
        recipeList:Clear()
        local search = searchBox:GetValue():lower()
        local _, filter = filterTab:GetSelected()

        for runeID, rune in SortedPairs(VEN_RUNE_SYSTEM.runes) do
            -- Search Filter
            if search ~= "" and not string.find(rune.name:lower(), search, 1, true) then continue end
            -- Category Filter
            if filter == "craftable" and not HasAllIngredients(rune.recipe) then continue end
            if filter == "health" and not string.Find(rune.effect, "health") and rune.effect ~= "regeneration" and rune.effect ~= "second_wind" then continue end
            if filter == "cursed" and not rune.isCursed then continue end
            if filter == "buff" and not string.Find(rune.effect, "strength") and rune.effect ~= "reflect" and rune.effect ~= "damage_reduce" and rune.effect ~= "invisible" and rune.effect ~= "phoneix" then continue end
            
            recipeList:Add(BuildRecipePanel(recipeList, runeID, rune, function ()
                RefreshRecipes()
                RefreshInvPanel()
            end))
        end
    end
    RefreshRecipes()

    searchBox.OnChange = function() RefreshRecipes() end
    filterTab.OnSelect = function() ResfreshRecipes() end
end      



----------- Shop Menu -----------
function Ven_Rune_OpenShopMenu()
    if IsValid(_ShopFrame) then _ShopFrame:Remove() end

    _ShopFrame = vgui.Create("DFrame")
    _ShopFrame:SetTitle("")
    _ShopFrame:SetSize(960, 400)
    _ShopFrame:Center()
    _ShoFrame:MakePopup()
    _ShopFrame.Paint = function(self, w, h)
        draw.RoundedBox(10, 0, 0, w, h, Color(14,14,24))
        draw.RoundedBox(10, 0, 0, w, 36, Color(26,26,26))
        draw.SimpleText("Rune Shop", FONT_TITLE, 16, 18, Color(255,223,50))
    end

    local tabs = vgui.Create("DPropertySheet", _ShopFrame)
    tabss:SetPos(4, 40)
    tabs:SetSize(952, 595)

    -- Buy Ingredients
    local BuyPanel = vgui.Create("DPanel")
    BuyPanel.Paint = Paint.Dark 
    tabs:AddSheet("Buy Ingredients", BuyPanel, nil)
    
    local BuySearch = vgui.Create("DComboBox", BuyPanel)
    typeFilter:AddChoice("All Types", "all")
    typeFilter:AddChoice("Essences and Liquids", "essencesandliquids")
    typeFilter:AddChoice("Crystals", "crystals")
    typeFilter:AddChoice("Organics", "organics")
    typeFilter:AddChoice("Cursed Materials", "cursed")
    typeFilter:AddChoice("Myhtics and Abstracts", "myhtics")
    typeFilter:ChooseOption("All Types", "all")

    local BuyScroll = vgui.Create("DScrollPanel", BuyPanel)
    BuyScroll:SetPose(0,36)
    BuyScroll:SetSize(BuyPanel:GetWide(), BuyPanel:GetHeight()- 36)
    local BuyGrid = vgui.Create("DIconLayout", BuyScroll)
    BuyGrid:Dock(FILL)
    BuyGrid:SetSpaceX(6)
    BuyGrid:SetSpaceY(6)

    local function RefreshBuy()
        BuyGrid:Clear()
        local s = BuySearch:GetValue():lower()
        local _, tf = typeFilter:GetSelected()
        for id, data in SortedPairs(VEN_RUNE_SYSTEM.Source) do
            if s ~= and not string.Find(data.name:lower(), s, 1, true) then contiune end
            if tf ~= "all" and data.type ~= tf then continue end
            local card = MakeItemCard(buyGrid, 110, 138, id, data, nil, nil, "$"..data.value, Color(225,220,30))
            -- buy button
            local btn = vgui.Create("DButton", card)
            btn:SetPos(5, 110)
            btn:SetSize(100, 22)
            btn:SetText("Buy $"..data.value)
            btn:SetFont(FONT_NORM)
            btn.Paint = function(self, w, h)
                draw.RoundedBox(6, 0, 0, w, h, self:IsHovered() and Color(80,180,255) or Color(50,120,200))
            end
            brn.DoClick = function()
                net.Start("Ven_Rune_BuyIngredient") net.WriteString(id) net.SendToServer()
            end
        end
    end
    RefreshBuy()
    BuySearch.OnChange = function() RefreshBuy() end
    typeFilter.OnSelect = function() RefreshBuy() end
    
    --- sell items ---
    local SellPanel = vgui.Create("Dpanel")
    SellPanel.Paint = PaintDark
    tabs:AddSheet("Sell Items", SellPanel, nil)

    local SellScroll = vgui.Create("DScrollPanel", SellPanel)
    SellScroll:SetPos(0,4)
    SellScroll:SetSize(SellPanel:GetWide(), SellPanel:GetHeight() - 4)
    local SellGrid ? vgui.Create("DIconLayout", SellScroll)
    SellGrid:Dock(FILL)
    SellGrid:SetSpaceX(6)
    SellGrid:SetSpaceY(6)

    local function RefreshSell()
        SellGrid:Clear()
        for itemID, count in SortedPairs(LocalInventory) do
            if count <= 0 then continue end
            local data = GetItemData(itemID)
            if not data then continue end
            local sv = math.floor(data.value * 0.6)
            local card = MakeItemCard(sellGrid, 110, 148, itemID, data, count, nil, "Sell $"..sv, Color(100,220,100))
            local btn = vgui.Create("DButton", card)
            btn:SetPos(5,120)
            btn:SetSize(100,22)
            btn:SetText("Sell 1")
            btn:SetFont(FONT_NORM)
            btn.Paint = function(self, w, h)
                draw.RoundedBox(6, 0, 0, w, h, self:IsHovered() and Color(80,220,100) or Color(50,220,100))
            end
            btn.DoClick = function()
                net.Start("Ven_Rune_SellItem") net.WriteString(itemID) net.SendToServer()
                timer.Simple(0.3, function() if IsValid(_ShopFrame) then _ShopFrame:Remove Ven_Rune_OpenShopMenu() end end)
            end
        end
    -- empty state
        if table.Count(LocalInventory) == 0 then
          local lbl = vgui.Create("DLabel", SellGrid)
          lbl:SetText("Your inventory is empty.")
         lbl:SetTextColor(Color(160,160,160))
         lbl:SetFont(FONT_BOLD)
         lbl:SizeToContents
         end
    
    end
    RefreshSell()

    -------------- Rune Inventory ---------------------
    local runePanel = vgui.Create("DPanel")
    runePanel.Paint = PaintDark
    tabs:AddSheet("My Runes", runePanel, nil)

    local runeScroll = vgui.Create("DscrollPanel", runePanel)
    runeScroll:SetPos(0,4)
    runeScroll:SetSize(runePanel:GetWide(), runePanel:GetTall()-4)
    local runeGrid = vgui.Create("DIconLayout", runeScroll)
    runeGrid:Dock(FILL)
    runeGrid:SetSpaceX(6)
    runeGrid:SetSpaceY(6)

    for runeID, count in SortedPairs(LocalInventory) do
        if count <= 0 then continue end
        local data = VEN_RUNE_SYSTEM.runes[runeID]
        if nor data then continue end

        local card = MakeItemCard(runeGrid, 120, 170, runeID, data, count, nil, nil, nil)

        --- using button ---
        local useBtn = vgui.Create("DButton", runeGrid) -- attach to grid to appear below card
     -- (i use layout inside card instead cus why not ?)
        local use = vgui.Create("DButton", card)
        use:SetPos(5,133)
        use:SetSize(110,24)
        use:SetText("Use")
        use:SetFont(FONT_NORM)
        use.Paint = function (self, w, h)
            draw.RoundedBox(6, 0, 0, w, h, self:IsHovered() and Color(80,200,120) or Color(40,140,80))
        end
        use.DoClick = function()
            net.Start("Ven_Rune_UseRune") net.WriteString(runeID) net.SendToServer()
            timer.Simple(0.3, function() if IsValid(_ShopFrame) then _ShopFrame:Remove() Ven_Rune_OpenShopMenu() end end)
        end


        -- throw button --
        if data.throwable then
            local throwBtn = vgui.Create("DButton", card)
            throwBtn:SetPos(5,142)
            throwBtn:SetSize(110,24)
            throwBtn:SetText("Throw")
            throwBtn:SetFont(FONT_NORM)
            throwBtn.Paint = function(self, w, h)
                draw.RoundedBox(6, 0, 0, w, h, self:IsHovered() and Color(200,80,80) or Color(150,40,40))
            end
            throwBtn.DoClick = function()
                net.Start("Ven_Rune_Throw") net.WriteString(runeID) net.SendToServer()
                _ShopFrame:Remove()
            end
            use:SetPose(5,133-11)
            throwBtn:SetPose(5,133+13)    
        end
    end
end



---------------- Quest Panel -----------------------
function Ven_Rune_OpenInventory()
    if IsValid(_InvFrame) then _InvFrame:Remove() end
    _InvFrame = vgui.Create("DFrame")
    _InvFrame:SetTitle("")
    _InvFrame:SetSize(700,560)
    _InvFrame:Center()
    _InvFrame:MakePopup()
    _InvFrame.Paint = function(self, w, h)
        draw.RoundedBox(10, 0, 0, w, h, Color(14,14,24))
        draw.RoundedBox(10, 0, 0, w, 36, Color(26,26,36))
        draw.SimpleText(" Quests and Progress", FONT_TITLE, 16, 18, Color(255,200,80, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER))
    end

    local scroll = vgui.Create("DScrollPanel", _InvFrame)
    scroll:SetPos(8,44)
    scroll:SetSize(_InvFrame:GetWide()-16, _InvFrame:GetTall()-52)
    
    local layout = vgui.Create("DListLayout", scroll)
    layout:Dock(FILL)
    layout:DockMargin(4,4,4,4)

    for qid, quest in SortedPairs(VEN_RUNE_SYSTEM.quest) do
        local qp = LocalQuestes[qid] or {progress = 0, done = false}
        local goal = quest.goal.count or 1
        local prog = math.min(qp.progress or 0, goal)
        local done = qb.done or false 
        local frac = prog / goal 
        
        local card = vgui.Create("DPanel", layout)
        card:SetSize(layout:GetWide(), 90)
        card.Paint = function (self, w, h)
            local bg = done and Color(20,40,20) or Color (24,24,38)
            draw.RoundedBox(8, 0, 0, w, h, bg)
         draw.RoundedBox(8, 0, 0, w, 3, done and Color(80,220,80) or Color(80,80,120))
            --icon
            draw.SimpleText(quest.icon or "", "DermalLarge", 30, h/2,Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            --name
            draw.SimpleText(quest.name, FONT_BOLD, 56,14, done and Color(100,220,100) or Color(230,230,230), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            -- desc
            draw.SimpleText(quest.desc, FONT_NORM, 56, 32, Color(160,150,180), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            -- progress bar
            draw.RoundedBox(4, 56, ,54, w-200, 10, Color(40,40,60))
            local barCol = done and Color(80,220,80) or Color (80,130,255)
             surface.SetDrawColor(barCol.r, barCol.g, barCol.b)
            surface.DrawRect(56, 54, math.Clamp(frac,0,1)*(w-200), 10)
            draw.SimpleText(prog.."/"..goal, FONT_NORM, 56, 68, Color(160,180,160), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            -- reward
            local rStr = "Reward +:" .. quest.reward.xp.. "XP"
            if quest.reward.monet then rStr = rStr .. "   $".. quest.reward.money end
            if quest.reward.item then
                local ingData = VEN_RUNE_SYSTEM.Sources[quest.reward.item]
                rStr = rStr .. "   "..(quest.reward.itemCount or 1).. "x "..(ingData and ingData.name or quset.reward.item)
            end
            draw.SimpleText(rStr, FONT_NORM, w-10,14, Color(255,220,50), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
            -- done stamp
            if done then
                draw.SimpleText("✔ Completed", FONT_BOLD, w-1*, 68, Color(80,220,80), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
            end
        end
    end
end



------------ FISHING MENU -----------------
function Ven_Rune_OpenFishingMenu()
    if IsValid(_FishFrame) then _FishFrame:Remove() end
        _FishFrame = vgui.Create("DFrame")
    _FishFrame:SetTitle("")
    _FishFrame:SetSize(400, 480)
    _FishFrame:Center()
    _FishFrame:MakePopup()
    _FishFrame.Paint = function(self, w, h)
        draw.RoundedBox(10, 0, 0, w, h, Color(14,14,30))
        draw.RoundedBox(10, 0, 0, w, 36, Color(20,30,60))
        draw.SimpleText("🎣  Fishing", FONT_TITLE, 16, 18, Color(100,180,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    local infoLabel = vgui.Create("DLabel", _FishFrame)
    infoLabel:SetPos(10, 44) infoLabel:SetSize(380, 60)
    infoLabel:SetText("Fish in enchanted waters to collect rare\nessences! Each cast takes 8 seconds.")
    infoLabel:SetTextColor(Color(160,200,255))
    infoLabel:SetFont(FONT_NORM)
    infoLabel:SetWrap(true)

    -- loot table preview
    local ltLabel = vgui.Create("DLabel", _FishFrame)
    ltLabel:SetPos(10, 110) ltLabel:SetSize(380, 20)
    ltLabel:SetText("Possible catches:")
    ltLabel:SetFont(FONT_BOLD)
    ltLabel:SetTextColor(Color(180,220,255))

    local scroll = vgui.Create("DScrollPanel", _FishFrame)
    scroll:SetPos(10, 132) scroll:SetSize(380, 260)
    for _, entry in ipairs(VEN_RUNE_SYSTEM.fishingloot) do
        local data = VEN_RUNE_SYSTEM.Source[entry.item]
        if not data then continue end
        local row = vgui.Create("DPanel", scroll)
        row:SetSize(380, 28)
        row.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(22,22,40))
            draw.SimpleText(data.icon or " ", FONT_NORM, 14, h/2, data.color or Color(200,200,200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText(data.name, FONT_NORM, 30, h/2, Color(200,200,200), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText(entry.min .. "-" .. entry.max, FONT_NORM, w-80, h/2, Color(180,220,180), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText(entry.weight .. "%", FONT_BOLD, w-10, h/2, Color(255,220,50), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        end
    end

    local castBtn = vgui.Create("DButton", _FishFrame)
    castBtn:SetPos(60, 400) castBtn:SetSize(280, 50)
    castBtn:SetText("Cast Line!")
    castBtn:SetFont(FONT_TITLE)
    castBtn:SetTextColor(Color(255,255,255))
    castBtn.Paint = function(self, w, h)
        draw.RoundedBox(10, 0, 0, w, h, self:IsHovered() and Color(50,120,220) or Color(30,80,160))
    end
    castBtn.DoClick = function()
        net.Start("Ven_Rune_StartFishing") net.SendToServer()
        _FishFrame:Remove()
    end
end



----------- Console Commands ----------------
concommand.Add("rune_craft",    function() net.Start("Ven_Run_OpenCraft")   net.SendToServer() end)
concommand.Add("rune_shop",     function() net.Start("Ven_Rune_OpenShop")   net.SendToServer() end)
concommand.Add("rune_quest",    function() Ven_Rune_OpenInventory() end)
concommand.Add("rune_fish",     function() net.Start("Ven_Rune_OpenFishing") net.SendToServer() end)
concommand.Add("rune_inventory", function() Ven_Rune_OpenShopMenu() end)

print("[Ven's Rune Sytem v0.1] Client loaded")