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


-- Poison projectile logic adapted from Pukepuss
local function CreateFlesh(pl, damage, damagepos, damagedir)
    damage = math.min(damage, 300)
    pl:EmitSound(string.format("physics/body/body_medium_break%d.wav", math.random(2, 4)), 74, 125 - damage * 0.50)
    if SERVER then
        damagepos = pl:LocalToWorld(damagepos)
        for i=1, math.max(1, math.floor(damage / 12)) do
            local ent = ents.Create("projectile_puke")
            if ent:IsValid() then
                local heading = (damagedir + VectorRand() * 0.3):GetNormalized()
                ent:SetPos(damagepos + heading)
                ent:SetOwner(pl)
                ent:Spawn()
                local phys = ent:GetPhysicsObject()
                if phys:IsValid() then
                    phys:Wake()
                    phys:SetVelocityInstantaneous(math.min(325, 100 + damage ^ math.Rand(1.15, 1.25)) * heading)
                end
            end
        end
    end
end

function CLASS:ProcessDamage(pl, dmginfo)
    local attacker, damage = dmginfo:GetAttacker(), dmginfo:GetDamage()
    if attacker ~= pl and damage >= 5 and damage < pl:Health() and CurTime() >= (pl.m_NextPukeEmit or 0) then
        pl.m_NextPukeEmit = CurTime() + 0.3
        local pos = pl:WorldToLocal(dmginfo:GetDamagePosition())
        local norm = dmginfo:GetDamageForce():GetNormalized() * -1
        timer.Simple(0, function()
            if pl:IsValid() then
                CreateFlesh(pl, damage, pos, norm)
            end
        end)
    end
end

if SERVER then
    function CLASS:OnKilled(pl, attacker, inflictor, suicide, headshot, dmginfo, assister)
        local pos = pl:WorldToLocal(dmginfo:GetDamagePosition())
        local norm = dmginfo:GetDamageForce():GetNormalized() * -1
        timer.Simple(0, function()
            if pl:IsValid() then
                CreateFlesh(pl, 300, pos, norm)
            end
        end)
    end
end

if CLIENT then
    CLASS.Icon = "zombiesurvival/killicons/zombie"
end
