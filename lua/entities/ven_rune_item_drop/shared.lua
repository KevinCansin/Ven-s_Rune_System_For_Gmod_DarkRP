ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.PrintName = "Item Drop"
ENT.Author = "Ven"
ENT.Category = "Ven's Rune System"
ENT.Spawnable = false

function ENT:Initialize()
    self:SetModel("models/props_junk/garbage_bag001a.mdl")
    self:SetModelScale(0.25)
    self:PhysicsInit(SOLID_BBOX)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_BBOX)
    self:SetTrigger(true)

    local ingData = VEN_RUNE_SYSTEM.Source[self.ItemID or "ancient_ink"]
    if ingData then
        self:SetColor(ingData.color or Color(200,200,200))
    end

    if SERVER then
        self:SetNWString("Ven_Rune_DropItem", self.ItemID or "ancient_ink")
        self:SetNWInt("Ven_Rune_DropCount", self.ItemCount or 1)
        self:SetNWFloat("Ven_Rune_DropBorn", CurTime())
        -- auto despawn after 3 min
        timer.Simple(180, function()
            if IsValid(self) then self:Remove() end
        end)
    end
end

if SERVER then
    -- touch pickup
    function ENT:StartTouch(ent)
        if not IsValid(ent) or not ent:IsPlayer() then return end
        if self.Collected then return end 
        self.Collected = true

        local itemID = self.ItemID or "ancient_ink"
        local count = self.ItemCount or 1
        local ingData = VEN_RUNE_SYSTEM.Source[itemID]
        local name = ingData and ingData.name or itemID

        -- give item to ply
        local inv = ent.VEN and ent.VEN.inventory
        if inv then
            inv[itemID] = (inv[itemID] or 0) + count
            net.Start("Ven_Rune_SyncInventory")
            net.WriteTable(inv)
            net.Send(ent)
        end

        net.Start("Ven_Rune_Notify")
        net.WriteString("Picked up " .. count .. "x " .. name .. "!")
        net.WriteColor(ingData and ingData.color or Color(200,200,200))
        net.WriteString("items/itempickup.wav")
        net.Send(ent)

        self:Remove()
    end
end