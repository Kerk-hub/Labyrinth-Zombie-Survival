AddCSLuaFile()

SWEP.Base = "weapon_zs_baseshotgun"

SWEP.PrintName = "'Sweeper' Shotgun"
SWEP.Description = "A hard-hitting pump shotgun. Each pellet ignites zombies for 3s. Deals bonus damage to burning targets."
SWEP.Slot = 1

if CLIENT then
	SWEP.ViewModelFlip = false

	SWEP.HUD3DBone = "v_weapon.M3_PARENT"
	SWEP.HUD3DPos = Vector(-1, -4, -3)
	SWEP.HUD3DAng = Angle(0, 0, 0)
	SWEP.HUD3DScale = 0.015
end

SWEP.Base = "weapon_zs_baseshotgun"

SWEP.HoldType = "shotgun"

SWEP.ViewModel = "models/weapons/cstrike/c_shot_m3super90.mdl"
SWEP.WorldModel = "models/weapons/w_shot_m3super90.mdl"
SWEP.UseHands = true

SWEP.ReloadDelay = 0.45

SWEP.Primary.Sound = Sound("Weapon_M3.Single")
SWEP.Primary.Damage = 9
SWEP.Primary.NumShots = 8
SWEP.Primary.Delay = 0.87

SWEP.Primary.ClipSize = 6
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "buckshot"
GAMEMODE:SetupDefaultClip(SWEP.Primary)

SWEP.ConeMax = 4
SWEP.ConeMin = 4

SWEP.FireAnimSpeed = 1.2
SWEP.WalkSpeed = SPEED_SLOWER

SWEP.BurnBonus = 0.1 -- 10% per tier

SWEP.BurnDuration = 3

SWEP.QualityDescs = {
    "+10% damage to burning targets",
    "+20% damage to burning targets",
    "+30% damage to burning targets"
}

function SWEP.BulletCallback(attacker, tr, dmginfo)
    if SERVER then
        local ent = tr.Entity
        if ent:IsValidLivingZombie() then
            local wep = attacker:GetActiveWeapon()
            local tier = (IsValid(wep) and wep.QualityTier or 0)
            local burnBonus = 1 + (tier + 1) * (wep.BurnBonus or 0.1)
            local duration = (IsValid(wep) and wep.BurnDuration or 3)
            ent:Ignite(duration)
            for _, fire in pairs(ents.FindByClass("entityflame")) do
                if fire:IsValid() and fire:GetParent() == ent then
                    fire:SetOwner(attacker)
                    fire:SetPhysicsAttacker(attacker)
                    fire.AttackerForward = attacker
                end
            end
            if ent:IsOnFire() then
                dmginfo:SetDamage(dmginfo:GetDamage() * burnBonus)
            end
        end
    end
end
