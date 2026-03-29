include("shared.lua")

function ENT:Draw()
    self:DrawModel()
    -- trial
    local rid = self:GetNWString("Ven_Rune_RuneID", "")
    local rune = VEN_RUNE_SYSTEM.runes[rid]
    if rune then 
        local col = rune.color or Color(200,100,255)
        render.SetMaterial(Material("sprites/light_glow02_add"))
        render.DrawSprite(self:GetPos(), 20, 20, Color(col.r, col.g, col.b, 200))
    end
end

function ENT:Think()
    -- particle trail
    if math.random(1, 2) == 1 then
        local rid = self:GetNWString("Ven_Rune_RuneID", "")
        local rune = VEN_RUNE_SYSTEM.runes[rid]
        if rune then
            local e = EffectData()
            e:SetOrigin(self:GetPos())
            e:SetScale(0.1)
            util.Effect("bloodimpact", e)
        end
    end
end