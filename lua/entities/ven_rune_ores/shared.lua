ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.PrintName = "Ore"
ENT.Author = "Ven"
ENT.Category = "Ven's Rune System"
ENT.Spawnable = false 

function ENT:Initialize()
    self:SetModel("models/props_c17/concrete_barrier001a.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_VPHYSICS)
    local nd = self.NodeData or {}
    self:SetColor(nd.color or Color(80,160,60))
    self.Harvested = false
    if SERVER then
        self:SetNWBool("PS_Harvested", false)
        self:SetNWString("PS_NodeName", nd.name or "Bush")
    end
end

if SERVER then
    local function WeightedRoll(loot)
        local total = 0
        for _, w in pairs(loot) do total = total + w end
        local roll = math.random(total)
        local cum  = 0
        for item, w in pairs(loot) do
            cum = cum + w
            if roll <= cum then return item end
        end
        return next(loot)
    end

    function ENT:Harvest(ply)
        if self.Harvested then
            return
        end

        local nd = self.NodeData or { loot={quartz = 100}, respawnTime = 180, harvestXP =5}
        local itemID = WeightedRoll(nd.loot)
        local base = math.random(1, 3)
        
        -- tell server to give item (called by server allready why i am suppose to write that shit. if i am not writing this line it will be go boom)
        AddItem(ply, itemID, count)

        local ingData = VEN_RUNE_SYSTEM.Source[itemID]
        local name = ingData and ingData.name or itemID
        Notify(ply, "Mined " .. count .. "x " .. name .. "!", Color(80,200,80), "items/itempickup.wav")


        -- track stats
        Data(ply).stats.nodesHarvested = Data(ply).stats.nodesHarvested + 1
        UpdateQuestProgress(ply, mine, {})
        GiveXP(ply, nd.harvestXP or 5)

        self.MineCount = (self.MineCount or 0) + 1
        if self.MineCount >= 3 then
            self.Harvested = true
            self:SetNWBool("Ven_Rune_Harvested", true)
            self:SetColor(Color(80,70,80))
            self.MineCount = 0

            timer.Simple(nd.respawnTime or 180, function()
                if IsValid(self) then
                    self.Harvested = false
                    self:SetNWBool("Ven_Rune_Harvested", false)
                    self:SetColor(nd.color or Color(180,220,255))
                end
            end)
        else 
            --visual damage
            local remaining = 3 - self.MineCount 
            Notify(ply, .. remaining .. " more strikes to deplete this vein.", Color(180,200,220))
        end
    end

    function ENT:Use(activator, caller)
        if activator:IsPlayer() then
            if self.Harvested then
                Notify(activator, "This vein is depleted. Come back later!", Color(255,220,100))
                return
            end
            self:Harvest(activator)
        end
    end
end 