ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Crafting Table"
ENT.Author = "Ven"
ENT.Category = "Ven's Rune System"
ENT.Spawnable = true

function ENT:Initialize()
    self:SetModel("models/props_c17/FurniturTable001a.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    if SERVER then
        local phys = self:GetPhysicsObject()
        if IsValid(phys) then phys:Wake() end
    end
end

if SERVER then 
    function ENT:Use(activator, caller)
        if not activator:IsPlayer() then return end 
        net.Start("Ven_Rune_OpenCraft")
        net.Send(activator)
    end
end
