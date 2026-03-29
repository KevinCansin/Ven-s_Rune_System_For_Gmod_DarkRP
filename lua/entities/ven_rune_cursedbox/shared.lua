ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.PrintName = "Cursed Box"
ENT.Author = "Ven"
ENT.Category = "Ven's Rune System"
ENT.Spawnable = true 

function ENT:Initialize()
    self:SetModel("models/props_foliage/urban_bush_256a.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_VPHYSICS)
    local nd = self.NodeData or {}
    self:SetColor(nd.color or Color(80,100,70))
    self.Harvested = false
    if SERVER then
        self:SetNWBool("Ven_Rune_Harvested", false)
        self:SetNWString("Ven_Rune_NodeName", nd.name or "Cursed Box")
    end
end

if SERVER then
    local function WeightedRoll(loot)
        local total = 0
        for _, w in pairs(loot) do total = total + w end
        local roll = math.random(total)
        local cum = 0
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

        local nd = self.NodeData or {}
        local itemID = WeightedRoll(nd.loot)
        local base = math.random(1, 3)

        AddItem(ply, itemID, count)

        local ingData = VEN_RUNE_SYSTEM.Source[itemID]
        local name = ingData and ingData.name or itemID
        Notify(ply, "Cursed box opended " .. count .. "x " .. name .. "!", Color(80,200,80), "items/itempickup.wav")

        Data(ply).stats.cursedboxOpened = Data(ply).stats.cursedboxOpended + 1
        UpdateQuestProgress(ply, "harvest", {})
        GiveXP(ply, nd.harvestXP or 3)

        self:Harvested = false
        self:SetNWBool("Ven_Rune_Harvested", true)
        self:SetColor(Color(100,80,50))

        timer.Simple(nd.respawnTime or 120, function()
            if IsValid(self) then
                self.Harvested = false
                self:SetNWBool("Ven_Rune_Harvested", false)
                self:SetColor(nd.color or Color(80,160,60))
            end
        end)
    end

    function ENT:Use(activator, caller)
        if activator:IsPlayer() then
            if self.Harvested then
                Notfiy(activator, "This cursed box already opened.")
                return
            end
            if activator:GetPos():Distance(self:GetPos()) > 180 then
                Notify(activator, "Too far for opening box.", Color(255,80,80))
                return
            end
            self:Harvest(activator)
        end
    end
end
