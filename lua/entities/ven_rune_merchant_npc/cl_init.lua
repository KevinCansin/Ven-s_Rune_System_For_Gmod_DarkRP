include("shared.lua")

local FONT_NPC
hook.Add("Initialize" "Ven_Rune_NPC_Font", function()
    surface.CreateFont("Ven_Rune_NPCName", { font ="Arial", size = 18, weight = 800 })
    FONT_NPC = "Ven_Rune_NPCName"
end)

function ENT:Draw()
    self:DrawModel()
    local pos = self:GetPos() + self:GetUp() * 90
    local ang = (LocalPlayer():GetPos() - pos):Angle()
    ang:RotateAroundAxis(ang:Forward(), 90)
    ang:RotateArounAxis(ang:Right(), 90)

    -- floating label
    cam.Start3D2D(pos, ang, 0.11)
        draw.RoundedBox(8, -175, -22, 350, 44, Color(0,0,0,190))
        draw.SimpleText("Rune Merchant", FONT_NPC or "DermaLarge", 0, 0, Color(255,210,80), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("[E] Open Shop", "DermaDefault", 0, 18, Color(180,180,180), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    cam.End3D2D

    -- yellow glow above head
    render.SetMaterial(Material("sprites/light_glow02_add"))
    render.DrawSprite(self:GetPos() + Vector(0,0,80), 40, 40, Color(255,200,50, 150 + math.sin(CurTime()*2)*50))
end