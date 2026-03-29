ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.PrintName = "Throw Potion"
ENT.Author = "Ven"
ENT.Category = "Ven's Rune System"
ENT.Spawnable = false 

function ENT:Initialize()
    self:SetModel("models/props_junk_garbage_bag001a.mdl")
    self:SetModelScale(0.3)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)

    local rune = VEN_RUNE_SYSTEM.runes[self.RuneID or ""]
    if rune then
        self:SetColor(rune.color or Color(200,100,255))
    end

    if SERVER then
        self:SetNWString("Ven_Rune_RuneID", self.RuneID or "")
        -- autoremove after 15 sec if doesnt hit
        timer.Simple(15, function()
            if IsValid(self) then self:Remove() end
        end)
    end
end

if SERVER then 
    function ENT:PhysicsCollide(data, phys)
        local hitEnt = data.HitEntity

        -- splash eff
        local eff = EffectData()
        eff:SetOrigin(data.HitPos)
        eff:SetNormal(data.HitNormal)
        eff:SetScale(2)
        util.Effect("WaterSplash", eff)

        -- aoe
        local hitPlayers = {}
        for _, ply in ipairs(player.GetAll()) do 
            if ply ~= self.Thrower and ply:GetPos():Distance(data.HitPos) < 80 then
                table.insert(hitPlayers, ply)
            end
        end

        if #hitPlayers > 0 then
            for _, victim in ipairs(hitPlayers) do
                Ven_Rune_OnThrowableHit(self.Thrower, victim, self.RuneID)
            end
        elseif IsValid(hitEnt) and hitEnt:IsPlayer() and hitEnt ~= self.Thrower then
            Ven_Rune_OnTHrowableHit(self.Thrower, hitEnt, self.RuneID)
        end

        self:Remove()
    end

    function ENT:Think()
        --
    end
end