AddCSLuaFile()
DEFINE_BASECLASS("weapon_zs_basemelee")

SWEP.PrintName = "Push Broom"
SWEP.Description = "A long-reach broom that sends zombies flying. If a knocked-back zombie collides with an entity before landing, they take the hit damage again."

if CLIENT then
	SWEP.ViewModelFOV = 70

	SWEP.ShowViewModel = false
	SWEP.ShowWorldModel = false

	SWEP.VElements = {
		["base"] = { type = "Model", model = "models/props_c17/pushbroom.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(5, 0.5, 8), angle = Angle(-65, -90, 90), size = Vector(0.75, 0.75, 0.75), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
	SWEP.WElements = {
		["base"] = { type = "Model", model = "models/props_c17/pushbroom.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3, 1, 5), angle = Angle(247, 90, 283), size = Vector(0.75, 0.75, 0.75), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
end

SWEP.Base = "weapon_zs_basemelee"

SWEP.HoldType = "melee2"

SWEP.DamageType = DMG_CLUB

SWEP.ViewModel = "models/weapons/c_crowbar.mdl"
SWEP.WorldModel = "models/props_c17/pushbroom.mdl"
SWEP.UseHands = true

SWEP.MeleeDamage = 94
SWEP.MeleeRange = 80
SWEP.MeleeSize = 1.7
SWEP.MeleeKnockBack = 300

SWEP.Primary.Delay = 1.05

SWEP.Tier = 2

SWEP.WalkSpeed = SPEED_FAST

SWEP.SwingRotation = Angle(0, -90, -60)
SWEP.SwingOffset = Vector(0, 30, -40)
SWEP.SwingTime = 0.6
SWEP.SwingHoldType = "melee"

SWEP.AllowQualityWeapons = true
SWEP.DismantleDiv = 2
SWEP.QualityDescs = {
	"Knockback increased to 400. Collision bounce damage applies.",
	"Knockback increased to 500. Collision bounce damage applies.",
	"Knockback increased to 700. Collision bounce damage applies.",
}

local KNOCKBACK = {300, 400, 500, 700}

function SWEP:Initialize()
	BaseClass.Initialize(self)
	self.MeleeKnockBack = KNOCKBACK[(self.QualityTier or 0) + 1]
end

BUILDING_WEAPON_MIXIN.ApplyShared(SWEP)

GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_FIRE_DELAY, -0.08, 1)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MELEE_RANGE, 3, 1)

function SWEP:PlaySwingSound()
	self:EmitSound("weapons/iceaxe/iceaxe_swing1.wav", 80, math.Rand(60, 65))
end

function SWEP:PlayHitSound()
	self:EmitSound("physics/wood/wood_plank_impact_hard"..math.random(4)..".wav", 75, math.random(75, 80))
end

function SWEP:PlayHitFleshSound()
	self:EmitSound("physics/wood/wood_plank_impact_hard"..math.random(4)..".wav", 75, math.random(75, 80))
end

function SWEP:PostOnMeleeHit(hitent, hitflesh, tr)
	if not SERVER then return end
	if not hitflesh then return end
	if not hitent:IsValid() or not hitent:IsPlayer() or not hitent:IsValidLivingZombie() then return end
	local owner = self:GetOwner()
	if not owner:IsValid() then return end

	local vel = hitent:GetVelocity()
	hitent.m_BroomBounce = {
		owner     = owner,
		weapon    = self,
		damage    = (self.MeleeDamage * 0.5),
		expiry    = CurTime() + 2,
		prevhspeed = Vector(vel.x, vel.y, 0):Length(),
	}
end

if SERVER then
	hook.Add("Think", "PushBroomBounceCheck", function()
		for _, ply in ipairs(player.GetAll()) do
			if not ply:IsValidLivingZombie() then
				ply.m_BroomBounce = nil
				continue
			end
			local bounce = ply.m_BroomBounce
			if not bounce then continue end

			if CurTime() > bounce.expiry then
				ply.m_BroomBounce = nil
				continue
			end

			local vel = ply:GetVelocity()
			local hspeed = Vector(vel.x, vel.y, 0):Length()
			local prev   = bounce.prevhspeed

			-- Detect sudden horizontal stop (wall/entity collision, not normal floor landing)
			if prev > 120 and hspeed < prev * 0.35 then
				local owner = bounce.owner
				local wep   = bounce.weapon
				if owner:IsValid() and wep:IsValid() and gamemode.Call("PlayerShouldTakeDamage", ply, owner) then
					ply:TakeSpecialDamage(bounce.damage, DMG_CLUB, owner, wep, ply:GetPos())
				end
				ply.m_BroomBounce = nil
			else
				bounce.prevhspeed = hspeed
			end
		end
	end)

	BUILDING_WEAPON_MIXIN.ApplyServer(SWEP)
end

if CLIENT then
	BUILDING_WEAPON_MIXIN.ApplyClient(SWEP)
end
