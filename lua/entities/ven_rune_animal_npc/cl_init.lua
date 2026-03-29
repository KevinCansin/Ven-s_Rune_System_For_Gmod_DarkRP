include("shared.lua")

local MAT_GLOW = Material("sprites/light_glow02_add")

surface.CreateFont("Ven_Rune_AnimalTag", { font = "Arial", size = 16, weight = 700 })

function ENT:Draw()
    self:DrawModel()

    local aType = self:GetNWString("Ven_Rune_AnimalType", "wolf")
    local aName = self:GetNWString("Ven_Rune_AnimalName", "Animal")
    local aData = VEN_RUNE_SYSTEM.animalnpc[aType] or {}
    local hp = self:GetNWFloat("Ven_Rune_AnimalHP", 80)
    local maxHP = self:GetNWFloat("Ven_Rune_AnimalMaxHP", 80)
    local col = aData.color or Color(200,200,200)

    --- floatin name and hp bar
    local pos = self:GetPos() + self:GetUp() * 75
    local ang = (LocalPlayer():GetPos() - pos):Angle()
    ang:RotateAroundAxis(ang:Forward(), 90)
    ang:RotateAroundAxis(ang:Right(), 90)

    local frac = math.Clamp(hp / math.max(maxHP, 1), 0, 1)

    cam.Start3D2D(pos, ang, 0.1)
        -- background
        draw.RoundedBox(6, -130, -28, 260, 52, Color(0,0,0,180))
        -- name
        draw.SimpleText(aName, "Ven_Rune_AnimalTag", 0, -18, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        -- HP var background
        draw.RoundedBox(4, -120, 4, 240, 14, Color(40,20,20,220))
        -- HP bar fill
        local barCol = frac > 0.5 and Color(60,200,60) or (frac > 0.25 and Color(220,180,30) or Color(220,40,40))
        draw.RoundedBox(4, -120, 4, 240 * frac, 14, barCol)
        -- HP text
        draw.SimpleText(math.ceil(hp) .. "/" .. math.ceil(maxHP), "DermaDefault", 0, 11, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    cam.End3D2D()

    -- glow 
    render.SetMaterial(MAT_GLOW)
    render.DrawSprite(
        self:GetPos() + Vector(0,0,30),
        30, 30,
        Color(col.r, col.g, col.b, 80 + math.sin(CurTime() * 3) * 40)
    )
end