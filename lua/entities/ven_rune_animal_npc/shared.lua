--- ven_rune_animal_npc shared ---

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Ven's Animal Npc"
ENT.Author = "Ven"
ENT.Spawnable = false
ENT.Category = "Ven's Rune System"

function ENT:Initialize()
    local aData = self.AnimalData or {}

    self:SetModel(aData.model or "")
    self:SetHullType(HULL_HUMAN)  
    self:SetHullSizeNormal()
    self:SetSolid(SOLID_BBOX)
    self:SetMoveType(MOVETYPE_STEP)
    self:SetMaxHealth(aData.health or 80)
    self:SetHealth(aData.health or 80)
    self:Color(aData.color or Color(200,200,200))

    if SERVER then
        self:SetNWString("Ven_Rune_AnimalType", self.AnimalTypeID or "wolf")
        self:SetNWString("Ven_Rune_AnimalName", aData.name or "Animal")
        self:SetNWFloat("Ven_Rune_AnimalMaxHP", aData.health or 80)
        self:SetNWFloat("Ven_Rune_AnimalHP", aData.health or 80)

        self.MoveSpeed = aData.speed or 180
        self.Damage = aData.damage or 10
        self.Target = nil
        self.AttackCooldown = 0 
        self.WanderAngle = Angle(0, math.random(360), 0)
        self.WanderTimer = CurTime() + math.random(3, 8)
    end
end 

if SERVER then
    function ENT:OnTakeDamage(dmginfo)
        local newHP = self:Health() - dmginfo:GetDamage()
        self:SetHealth(newHP)
        self:SetNWFloat("Ven_Rune_AnimalHP", math.max(0, newHP))

        -- bleed particle
        local eff = EffectData()
        eff:SetOrigin(self:GetPos())
        eff:SetNormal(Vector(0,0,1))
        util.Effect("BloodImpact", eff)

        -- remember attacker as target
        local atk = dmginfo:GetAttacker()
        if IsValid(atk) and atk:IsPlayer() then
            self.Target = atk
        end 

        if newHP <= 0 then 
            self:Die(dmginfo:GetAttacker())
        end
    end

    function ENT:Die(killer)
        if self.Dead then return end
        self.Dead = true

        -- fire the kill reward
        Ven_Rune_OnAnimalKilled(killer, self.AnimalTypeID or "wolf")

        -- death eff
        local eff = EffectData()
        eff:SetOrigin(self:GetPos())
        eff:SetScale(2)
        util.Effect("Explosion", eff)

        timer.Simple(0.1, function()
        if IsValid(self) then self:Remove() end
        end)
    end

    function ENT:Think()
        if self.Dead then return end

        local now = CurTime()

        -- ── Target acquisition ──────────────────────────────────
        if not IsValid(self.Target) or not self.Target:IsAlive() then
            self.Target = nil
            -- Find nearest player within 800 units
            local nearestDist = 800
            for _, ply in ipairs(player.GetAll()) do
                if not ply:IsAlive() then continue end
                local dist = self:GetPos():Distance(ply:GetPos())
                if dist < nearestDist then
                    nearestDist = dist
                    self.Target = ply
                end
            end
        end

        -- ── Chase / Wander ───────────────────────────────────────
        if IsValid(self.Target) then
            local toTarget = (self.Target:GetPos() - self:GetPos())
            local dist     = toTarget:Length()
            local dir      = toTarget:GetNormalized()

            self:SetAngles(dir:Angle())

            if dist > 80 then
                -- Move toward target
                local vel = dir * self.MoveSpeed
                self:SetVelocity(vel)
                self:SetSequence(self:LookupSequence("walk_all") ~= -1 and "walk_all" or "walk")
            else
                -- In melee range — attack
                self:SetVelocity(Vector(0,0,0))
                self:SetSequence(self:LookupSequence("attack1") ~= -1 and "attack1" or "idle")

                if now > self.AttackCooldown then
                    self.AttackCooldown = now + 1.5
                    local dmginfo = DamageInfo()
                    dmginfo:SetDamage(self.Damage)
                    dmginfo:SetAttacker(self)
                    dmginfo:SetInflictor(self)
                    dmginfo:SetDamageType(DMG_CLUB)
                    self.Target:TakeDamageInfo(dmginfo)
                end
            end

        else
            -- Idle wander
            if now > self.WanderTimer then
                self.WanderAngle  = Angle(0, math.random(360), 0)
                self.WanderTimer  = now + math.random(3, 10)
            end
            local wanderDir = self.WanderAngle:Forward()
            self:SetAngles(self.WanderAngle)
            self:SetVelocity(wanderDir * (self.MoveSpeed * 0.4))
            self:SetSequence(self:LookupSequence("walk_all") ~= -1 and "walk_all" or "idle")
        end

        -- Gravity
        local vel = self:GetVelocity()
        if not self:IsOnGround() then
            self:SetVelocity(vel + Vector(0, 0, -18))
        end

        self:NextThink(now + 0.05)
        return true
    end

    function ENT:Use(activator, caller)
        -- hitting with e does nothin
    end
end