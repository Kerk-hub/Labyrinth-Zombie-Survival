CLASS.Name = "Bloated Zombie"
CLASS.TranslationName = "class_bloated_zombie"
CLASS.Description = "description_bloated_zombie"
CLASS.Help = "controls_bloated_zombie"

CLASS.BaseHealth = 300
CLASS.HealthPerTier = 150
CLASS.BaseSpeed = 140 -- 20% slower than 175
CLASS.Speed = CLASS.BaseSpeed
CLASS.Revives = true
CLASS.Unlocked = true
CLASS.Order = 1

CLASS.SWEP = "weapon_zs_bloatedzombie"
CLASS.Model = Model("models/player/zombie_classic_hbfix.mdl")


CLASS.GetMaxZombieHealth = function(self)
    return self:GetScaledHealth()
end
-- Health property for spawn logic: set to base value, will be overwritten at runtime if needed
CLASS.Health = CLASS.BaseHealth

-- At registration, update Health to current scaled value for compatibility
if GAMEMODE and GAMEMODE.GetWave then
    CLASS.Health = CLASS.BaseHealth + (math.Clamp(GAMEMODE:GetWave(), 1, 5) - 1) * CLASS.HealthPerTier
end
CLASS.Points = (CLASS.BaseHealth or 300)/GM.HumanoidZombiePointRatio

function CLASS:GetTier()
    local wave = GAMEMODE and GAMEMODE.GetWave and GAMEMODE:GetWave() or 1
    return math.Clamp(wave, 1, 5)
end

function CLASS:GetScaledHealth()
    return self.BaseHealth + (self:GetTier() - 1) * self.HealthPerTier
end

function CLASS:GetTierColor()
    local tier = self:GetTier()
    local baseColor = Color(120, 80, 40) -- brownish base
    local redScale = 1 + 0.2 * (tier - 1)
    return Color(math.Clamp(baseColor.r * redScale, 0, 255), baseColor.g, baseColor.b)
end

if SERVER then
    function CLASS:OnKilled(pl, attacker, inflictor, suicide, headshot, dmginfo)
        -- Spew 5 puke projectiles in facing direction
        local ang = pl:EyeAngles()
        local pos = pl:GetShootPos()
        for i = 1, 5 do
            local ent = ents.Create("projectile_puke")
            if ent:IsValid() then
                ent:SetPos(pos)
                local spread = Angle(0, (i-3)*8, 0)
                ent:SetAngles(ang + spread)
                ent:SetOwner(pl)
                ent:Spawn()
                local phys = ent:GetPhysicsObject()
                if phys:IsValid() then
                    phys:SetVelocity((ang:Forward() + VectorRand() * 0.1):GetNormalized() * 400)
                end
            end
        end
    end
end

if CLIENT then
    CLASS.Icon = "zombiesurvival/killicons/zombie"
end
