AddCSLuaFile()

SWEP.PrintName = "'Hunter' Rifle"
SWEP.Description = "Single-shot bolt-action rifle. Overkill damage is released as an explosion on kill."
SWEP.Slot = 1
SWEP.SlotPos = 0

if CLIENT then
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 60

	SWEP.HUD3DBone = "v_weapon.awm_parent"
	SWEP.HUD3DPos = Vector(-1.25, -3.5, -16)
	SWEP.HUD3DAng = Angle(0, 0, 0)
	SWEP.HUD3DScale = 0.02
end

sound.Add(
{
	name = "Weapon_Hunter.Single",
	channel = CHAN_WEAPON,
	volume = 1.0,
	soundlevel = 100,
	pitchstart = 134,
	pitchend = 10,
	sound = "weapons/awp/awp1.wav"
})

SWEP.Base = "weapon_zs_base"

SWEP.HoldType = "ar2"

SWEP.ViewModel = "models/weapons/cstrike/c_snip_awp.mdl"
SWEP.WorldModel = "models/weapons/w_snip_awp.mdl"
SWEP.UseHands = true

SWEP.ReloadSound = Sound("Weapon_AWP.ClipOut")
SWEP.Primary.Sound = Sound("Weapon_Hunter.Single")
SWEP.Primary.Damage = 100
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 1.3
SWEP.ReloadDelay = SWEP.Primary.Delay

SWEP.Primary.ClipSize = 1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "357"
SWEP.Primary.DefaultClip = 15

SWEP.Primary.Gesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_CROSSBOW
SWEP.ReloadGesture = ACT_HL2MP_GESTURE_RELOAD_SHOTGUN

SWEP.ConeMax = 6
SWEP.ConeMin = 0

SWEP.HeadshotMulti = 3

SWEP.IronSightsPos = Vector(5.015, -8, 2.52)
SWEP.IronSightsAng = Vector(0, 0, 0)

SWEP.WalkSpeed = SPEED_SLOWER


SWEP.TracerName = "AR2Tracer"


-- Overkill explosion scales with remantle tier (base ability)
SWEP.Description = "Single-shot bolt-action rifle. Overkill damage is released as an explosion on kill. Each remantle tier increases explosion radius (+32 units) and overkill damage (+25%)."

SWEP.QualityDescs = {
	"Explosion radius 104; overkill damage multiplier 1.25",
	"Explosion radius 136; overkill damage multiplier 1.5",
	"Explosion radius 168; overkill damage multiplier 1.75"
}

function SWEP:GetExplosionStats()
    local base_radius = 72
    local base_mult = 1
    local tier = 0
    if self.GetWeaponRemantleTier then
        tier = self:GetWeaponRemantleTier()
    end
    local radius = base_radius + 32 * tier
    local mult = base_mult + 0.25 * tier
    return radius, mult
end


function SWEP:OnZombieKilled(zombie, total, dmginfo)
	local killer = self:GetOwner()
	local minushp = -zombie:Health()
	if killer:IsValid() and minushp > 10 then
		local pos = zombie:GetPos()
		local radius, mult = 72, 1
		if self.GetExplosionStats then
			radius, mult = self:GetExplosionStats()
		elseif self.ExplosionRadius or self.ExplosionOverkillMult then
			radius = self.ExplosionRadius or 72
			mult = self.ExplosionOverkillMult or 1
		end
		timer.Simple(0.15, function()
			util.BlastDamagePlayer(killer:GetActiveWeapon(), killer, pos, radius, minushp * mult, DMG_ALWAYSGIB, 0.94)
		end)
		local effectdata = EffectData()
			effectdata:SetOrigin(pos)
		util.Effect("Explosion", effectdata, true, true)
	end
end

function SWEP:IsScoped()
	return self:GetIronsights() and self.fIronTime and self.fIronTime + 0.25 <= CurTime()
end

function SWEP:SendWeaponAnimation()
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)

	local owner = self:GetOwner()
	local vm = owner:GetViewModel()
	local speed = self.ReloadSpeed * self:GetReloadSpeedMultiplier()

	if vm:IsValid() then
		vm:SetPlaybackRate(0.7 * speed)
	end

	self:SetReloadFinish(CurTime() + 1.3 / speed)
end

function SWEP:MockReload()
	local speed = self.ReloadSpeed * self:GetReloadSpeedMultiplier()
	self:SetReloadFinish(CurTime() + 1.3 / speed)
end

function SWEP:Reload()
	local owner = self:GetOwner()
	if owner:IsHolding() then return end

	if self:GetIronsights() then
		self:SetIronsights(false)
	end

	if self:CanReload() then
		self:MockReload()
	end
end

function SWEP:Deploy()
	self.BaseClass.Deploy(self)

	if self:Clip1() <= 0 then
		self:MockReload()
	end

	return true
end

function SWEP:Think()
	self.BaseClass.Think(self)

	if self:Clip1() <= 0 and self:GetPrimaryAmmoCount() <= 0 then
		self:MockReload()
	end
end

function SWEP.BulletCallback(attacker, tr, dmginfo)
	local effectdata = EffectData()
		effectdata:SetOrigin(tr.HitPos)
		effectdata:SetNormal(tr.HitNormal)
	util.Effect("hit_hunter", effectdata)
end

if CLIENT then
	SWEP.IronsightsMultiplier = 0.25

	function SWEP:GetViewModelPosition(pos, ang)
		if GAMEMODE.DisableScopes then return end

		if self:IsScoped() then
			return pos + ang:Up() * 256, ang
		end

		return self.BaseClass.GetViewModelPosition(self, pos, ang)
	end

	function SWEP:DrawHUDBackground()
		if GAMEMODE.DisableScopes then return end

		if self:IsScoped() then
			self:DrawRegularScope()
		end
	end
end
