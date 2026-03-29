include("shared.lua")

function ENT:Draw()
    self:DrawModel()

    -- glow eff when harvestable
    if not self:GetNWBool("Ven_Rune_Harvested", false) then
        local nd = self.NodeData or {}
        local col = nd.color or Color(80,160,60)
        local t = CurTime()
        local pulse = math.abs(math.sin(t * 2)) * 0.5 + 0.5

        -- sprite glow
        render.SetMaterial(Material("sprites/light_glow002_add"))
        render.DrawSprite(self:GetPos() + Vector(0,0,20), 50 * pulse, 50 * pulse, Color(col.r, col.g, col.b, 180 * pulse))

        if math.random(1, 8) == 1 then
            local particle = EffectData()
            particle:SetOrigin(self:GetPos() + Vector(math.random(-20,20), math.random(-20,20), math.random(5,40)))
            particle:SetScale(0.1)
            particle:SetColor(Vector(col.r/255, col.g/255, col.b/255))
            util.Effect("bloodimpact", particle)
        end
    end
end

function ENT:Think()
    -- Animate slightly swaying
    local t = CurTime()
    local base = self:GetNWString("Ven_Rune_BaseAng") or "0 0 0"
    -- Subtle bob
end