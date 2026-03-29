ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Rune Merchant"
ENT.Author = "Ven"
ENT.Category = "Ven's Rune System"
ENT.Spawnable = true 

function ENT:Initialize()
    self:SetModel("models/humans/group03/male_07.mdl")
    self:SetHullType(HULL_HUMAN)
    self:SetHullSizeNormal()
    self:SetSolid(SOLID_BBOX)
    self:SetMoveType(MOVETYPE_STEP)
    if SERVER then
        self:SetMaxHealth(99999)
        self:SetHealth(99999)
        self:SetNWString("Ven_Rune_MerchantType", "shop")
    end
end

if SERVER then
    function ENT:Use(activator, caller)
        if not activator:IsPlayer() then return end
        net.Start("Ven_Rune_OpenShop")
        met.Send(activator)
    end
end