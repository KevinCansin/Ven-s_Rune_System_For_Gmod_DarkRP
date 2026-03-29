include("shared.lua")

function ENT:Draw()
    self:DrawModel()
    local pos = self:GetPos() + self:GetUp() * 55
    local ang = (LocalPlayer():GetPos() - pos):Angle()
    ang:RotateAroundAxis(ang:Forward(), 90)
    ang:RotateAroundAxis(ang:Right(), 90)
    cam.Start3D2D(pos, ang, 0.09)
        draw.RoundedBox(8, -220, -22, 440, 44, Color(0,0,0,190))
        draw.SimpleText("Crafting Table  [E]", "DermaLarge", 0, 0, Color(180,255,200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    cam.End3D2D()
    -- Green glow
    render.SetMaterial(Material("sprites/light_glow02_add"))
    render.DrawSprite(self:GetPos()+Vector(0,0,60), 35, 35, Color(80,255,150, 120+math.sin(CurTime()*3)*40))
end
