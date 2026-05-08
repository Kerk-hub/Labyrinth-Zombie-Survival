AddCSLuaFile()

SWEP.PrintName = "'Zombie Drill' Desert Eagle"
SWEP.Description = "High-powered rounds penetrate through targets. Each surface or target penetrated before hitting increases damage by 30%."
SWEP.Slot = 1
SWEP.SlotPos = 0

if CLIENT then
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 55

	SWEP.HUD3DBone = "v_weapon.Deagle_Slide"
	SWEP.HUD3DPos = Vector(-1, 0, 1)
	SWEP.HUD3DAng = Angle(0, 0, 0)
	SWEP.HUD3DScale = 0.015

	SWEP.IronSightsPos = Vector(-6.35, 5, 1.7)
end

SWEP.Base = "weapon_zs_base"

SWEP.HoldType = "revolver"

SWEP.ViewModel = "models/weapons/cstrike/c_pist_deagle.mdl"
SWEP.WorldModel = "models/weapons/w_pist_deagle.mdl"
SWEP.UseHands = true

SWEP.Primary.Sound = Sound("Weapon_Deagle.Single")
SWEP.Primary.Damage = 32
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.32
SWEP.Primary.KnockbackScale = 2

SWEP.Primary.ClipSize = 7
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "pistol"
GAMEMODE:SetupDefaultClip(SWEP.Primary)

SWEP.ConeMax = 2.5
SWEP.ConeMin = 1

SWEP.Pierces = 2

GAMEMODE:SetPrimaryWeaponModifier(SWEP, WEAPON_MODIFIER_BULLET_PIERCES, 1)

SWEP.QualityDescs = {
	"Penetrates 2 targets; +30% damage per penetration",
	"Penetrates 3 targets; +30% damage per penetration",
	"Penetrates 4 targets; +30% damage per penetration"
}

SWEP.FireAnimSpeed = 1.3

function SWEP:ShootBullets(dmg, numbul, cone)
	local owner = self:GetOwner()
	self:SendWeaponAnimation()
	owner:DoAttackEvent()

	local dir = owner:GetAimVector()
	local dirang = dir:Angle()
	local start = owner:GetShootPos()

	dirang:RotateAroundAxis(dirang:Forward(), util.SharedRandom("bulletrotate1", 0, 360))
	dirang:RotateAroundAxis(dirang:Up(), util.SharedRandom("bulletangle1", -cone, cone))
	dir = dirang:Forward()
	local endpoint = start + dir * 2048

	owner:LagCompensation(true)
	-- Visual tracer only, no damage; damage is applied manually below
	owner:FireBulletsLua(start, dir, 0, numbul, 0, nil, nil, self.TracerName, nil, nil, nil, 2048, nil, self)

	if SERVER then
		local maxPierces = self.Pierces or 2
		local traceStart = start
		local hitEnts = {[owner] = true}
		local penetrations = 0

		for _ = 1, maxPierces do
			local tr = util.TraceLine({
				start = traceStart,
				endpos = endpoint,
				mask = MASK_SHOT,
				filter = function(e) return not hitEnts[e] end
			})

			if not tr.Hit then break end

			local ent = tr.Entity
			if IsValid(ent) and ent:IsValidLivingZombie() then
				local hitDmg = dmg * (1 + penetrations * 0.3)
				owner:FireBulletsLua(tr.HitPos, dir, 0, numbul, hitDmg, nil, self.Primary.KnockbackScale, "", self.BulletCallback, nil, nil, nil, nil, self)
				hitEnts[ent] = true
			end

			penetrations = penetrations + 1
			traceStart = tr.HitPos + dir * 4
		end
	end

	owner:LagCompensation(false)
end
