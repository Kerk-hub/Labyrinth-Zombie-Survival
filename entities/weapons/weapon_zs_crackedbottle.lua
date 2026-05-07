AddCSLuaFile()
DEFINE_BASECLASS("weapon_zs_basemelee")

SWEP.PrintName = "Cracked Bottle"
SWEP.Description = "A cracked bottle with jagged edges that slash through zombie flesh. Right click to extra jump (cooldown reduced per tier)."

if CLIENT then
	SWEP.ViewModelFOV = 55
	SWEP.VElements = {
		["base"] = { type = "Model", model = "models/props_junk/glassbottle01a_chunk01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3.635, 1.557, -4.676), angle = Angle(180, -111.04, 155.455), size = Vector(1.144, 1.144, 1.144), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
	SWEP.WElements = {
		["base"] = { type = "Model", model = "models/props_junk/glassbottle01a_chunk01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(5.714, 2.596, -2.597), angle = Angle(38.57, -68.961, 22.208), size = Vector(1.274, 1.274, 1.274), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
end

SWEP.Base = "weapon_zs_basemelee"

SWEP.HoldType = "knife"

SWEP.DamageType = DMG_SLASH

SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/weapons/cstrike/c_knife_t.mdl"
SWEP.WorldModel = "models/props_junk/glassbottle01a_chunk01a.mdl"
SWEP.ShowViewModel = false
SWEP.ShowWorldModel = false
SWEP.UseHands = true

SWEP.AutoSwitchFrom	= true

SWEP.MeleeDamage = 60
SWEP.MeleeRange = 45
SWEP.MeleeSize = 0.875

SWEP.WalkSpeed = SPEED_FASTEST

SWEP.Primary.Delay = 0.8

SWEP.HitDecal = "Manhackcut"

SWEP.HitGesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_KNIFE
SWEP.MissGesture = SWEP.HitGesture

SWEP.HitAnim = ACT_VM_MISSCENTER
SWEP.MissAnim = ACT_VM_PRIMARYATTACK

SWEP.NoHitSoundFlesh = true

SWEP.NoGlassWeapons = true

SWEP.AllowQualityWeapons = true
SWEP.QualityDescs = {
	"-0.08s swing delay. Extra jump cooldown reduced to 5s.",
	"-0.16s swing delay. Extra jump cooldown reduced to 4s.",
	"-0.24s swing delay. Extra jump cooldown reduced to 3s.",
}

GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_FIRE_DELAY, -0.08)

local JUMP_COOLDOWN = {7, 5, 4, 3}

function SWEP:PlaySwingSound()
	self:EmitSound("weapons/knife/knife_slash"..math.random(2)..".wav")
end

function SWEP:PlayHitSound()
	self:EmitSound("physics/glass/glass_bottle_break2.wav")
end

function SWEP:PlayHitFleshSound()
	self:EmitSound("physics/glass/glass_bottle_break2.wav")
end

function SWEP:SecondaryAttack()
	local owner = self:GetOwner()
	if not owner:IsValid() then return end
	if self:GetNextSecondaryFire() > CurTime() then return end

	if SERVER then
		owner:SetVelocity(Vector(0, 0, 280))
		self:EmitSound("Weapon_Flashbang.Bounce")
	end

	local cooldown = JUMP_COOLDOWN[(self.QualityTier or 0) + 1]
	self:SetNextSecondaryFire(CurTime() + cooldown)
end

function SWEP:Think()
	if CLIENT then
		local nxt = self:GetNextSecondaryFire()
		if nxt <= CurTime() then
			if self.m_LastNotifiedNxt ~= nxt then
				self.m_LastNotifiedNxt = nxt
				self:EmitSound("buttons/button1.wav", 75, 100)
				GAMEMODE:CenterNotify(COLOR_GREEN, "Extra Jump Charged")
			end
		else
			self.m_LastNotifiedNxt = nil
		end
	end
	BaseClass.Think(self)
end
