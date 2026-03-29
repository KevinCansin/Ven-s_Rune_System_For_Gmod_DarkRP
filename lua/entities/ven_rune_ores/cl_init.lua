include("shared.lua")

function ENT:Draw()
    self:DrawModel()

    if not self:GetNWBool("Ven_Rune_Harvested", false) then
        local nd = self.NodeData or {}
        local col = nd.color or Color(100,100,100)
        local t = CurTime()
        local pulse = math.abs(math.sin(t * 2)) * 0.5 + 0.5

        -- sprite glow
        render.SetMaterial(Material("sprites/light_glow02_add"))
        render.DrawSprite(self:GetPos() + Vector(0,0,20), 50 * pulse, Color(col.r, col.g, col.b, 180 * pulse))


        -- sparkle particles
        if math.random(1, 8) == 1 then
            local particle = EffectData()
            particle:SetOrigin(self:GetPos() + Vector(math.random(-20, 20), math.random(-20, 20), math.random(5, 40)))
            particle:SetScale(0.1)
            particle:SetColor(Vector(col.r/255, col.g/255, col.b/255))
            util.Effect("sparks", particle)
        end
    end 
end 

function ENT:Think()
    -- animate slightly swaying
    local t = CurTime
    local base = self:GetNWString("Ven_Rune_BaseAng") or "0 0 0"
end