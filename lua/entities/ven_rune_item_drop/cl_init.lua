include("shared.lua")

local MAT_GLOW = Material("sprites/light_glow02_add")

surface.CreateFont("Ven_Rune_DropTag", { font = "Arial", size = 14, weight = 700 })

function ENT:Draw()
    -- spin the drop
    local ang = Angle(0, (CurTime() * 120) % 360, 0)
    local pos = self:GetPos() + Vector(0, 0, math.sin(CurTime() * 3) * 4 + 8)

    local itemID = self:GetNWString("Ven_Rune_DropItem", "ancient_ink")
    local count = self:GetNWInt("Ven_Rune_DropCount", 1)
    local ingData = VEN_RUNE_SYSTEM.Source[itemID]
    local col = ingData and ingData.color or Color(200,200,200)
    local icon = ingData and ingData.icon or ""
    local name = ingData and ingData.name or itemID

    -- draw spinning model 
    render.SetColorMaterial()
    self:SetAngles(Angle(0, (CurTime() * 120) % 360, 0))
    self:DrawModel()

    -- glow sprite 
    render.SetMaterial(MAT_GLOW)
    render.DrawSprite(pos, 28, 28, Color(col.r, col.g, col.b, 180))

    -- floatin label
    local labPos = pos + Vector(0, 0, 16)
    local labAng = (LocalPlayer():GetPos() - labPos):Angle()
    labAng:RotateAroundAxis(labAng:Forward(), 90)
    labAng:RotateAroundAxis(labAng:Right(), 90)

    cam.Start3D2D(labPos, labAng, 0.07)
        draw.RoundedBox(6, -90, -14, 180, 28, Color(0,0,0,170))
        draw.SimpleText(icon .. " " .. name .. " x" .. count, "Ven_Rune_DropTag", 0, 0, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    cam.End3D2D()
end