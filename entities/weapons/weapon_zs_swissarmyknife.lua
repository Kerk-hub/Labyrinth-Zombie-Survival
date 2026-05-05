AddCSLuaFile()
DEFINE_BASECLASS("weapon_zs_basemelee")

SWEP.PrintName = "Knife"
SWEP.Description = "A small bladed weapon that deals double damage to the back."

if CLIENT then
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 55
end

SWEP.Base = "weapon_zs_basemelee"

SWEP.HoldType = "knife"

SWEP.ViewModel = "models/weapons/cstrike/c_knife_t.mdl"
SWEP.WorldModel = "models/weapons/w_knife_t.mdl"
SWEP.UseHands = true

SWEP.MeleeDamage = 50
SWEP.MeleeRange = 52
SWEP.MeleeSize = 0.875

SWEP.WalkSpeed = SPEED_FASTEST

SWEP.Primary.Delay = 0.585
SWEP.Secondary.Automatic = false

SWEP.HitDecal = "Manhackcut"

SWEP.HitGesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_KNIFE
SWEP.MissGesture = SWEP.HitGesture

SWEP.HitAnim = ACT_VM_MISSCENTER
SWEP.MissAnim = ACT_VM_PRIMARYATTACK

SWEP.NoHitSoundFlesh = true

SWEP.AllowQualityWeapons = true
SWEP.Culinary = true

GAMEMODE:AddNewRemantleBranch(SWEP, 1, "'Spring' Knife", "Right click while airborne to double jump. Deals less damage.", function(wept)
	wept.SwissAltRightClick = true
	wept.MeleeDamage = wept.MeleeDamage * 0.8
	local cooldowns = {5, 4, 2}
	wept.SwissJumpCooldown = cooldowns[wept.QualityTier] or 5
end)

function SWEP:PlaySwingSound()
	self:EmitSound("weapons/knife/knife_slash"..math.random(2)..".wav")
end

function SWEP:PlayHitSound()
	self:EmitSound("weapons/knife/knife_hitwall1.wav")
end

function SWEP:PlayHitFleshSound()
	self:EmitSound("weapons/knife/knife_hit"..math.random(4)..".wav")
end

function SWEP:SecondaryAttack()
	if self.Branch ~= 1 then return end

	local owner = self:GetOwner()
	if not owner:IsValid() then return end
	if self:GetNextSecondaryFire() > CurTime() then return end

	if SERVER then
		owner:SetVelocity(Vector(0, 0, 280))
		self:EmitSound("Weapon_Flashbang.Bounce")
	end

	self:SetNextSecondaryFire(CurTime() + (self.SwissJumpCooldown or 5))
end

function SWEP:Think()
	if self.Branch == 1 then
		if CLIENT then
			local nxt = self:GetNextSecondaryFire()
			if nxt <= CurTime() then
				if self.m_LastNotifiedNxt ~= nxt then
					self.m_LastNotifiedNxt = nxt
					self:EmitSound("buttons/button1.wav", 75, 100)
					GAMEMODE:CenterNotify(COLOR_BLUE, "Double Jump Charged")
				end
			else
				self.m_LastNotifiedNxt = nil
			end
		end
	end

	BaseClass.Think(self)
end

function SWEP:OnMeleeHit(hitent, hitflesh, tr)
	if hitent:IsValid() and hitent:IsPlayer() and not self.m_BackStabbing and math.abs(hitent:GetForward():Angle().yaw - self:GetOwner():GetForward():Angle().yaw) <= 90 then
		local bsmul = 4 + (self.QualityTier or 0) * 2
		self.m_BackStabbing = true
		self.m_BackStabMul = bsmul
		self.MeleeDamage = self.MeleeDamage * bsmul
	end
end

function SWEP:PostOnMeleeHit(hitent, hitflesh, tr)
	if self.m_BackStabbing then
		self.m_BackStabbing = false
		self.MeleeDamage = self.MeleeDamage / self.m_BackStabMul
	end
end

if SERVER then
	function SWEP:InitializeHoldType()
		self.ActivityTranslate = {}
		self.ActivityTranslate[ACT_HL2MP_IDLE] = ACT_HL2MP_IDLE_KNIFE
		self.ActivityTranslate[ACT_HL2MP_WALK] = ACT_HL2MP_WALK_KNIFE
		self.ActivityTranslate[ACT_HL2MP_RUN] = ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslate[ACT_HL2MP_IDLE_CROUCH] = ACT_HL2MP_IDLE_CROUCH_PHYSGUN
		self.ActivityTranslate[ACT_HL2MP_WALK_CROUCH] = ACT_HL2MP_WALK_CROUCH_KNIFE
		self.ActivityTranslate[ACT_HL2MP_GESTURE_RANGE_ATTACK] = ACT_HL2MP_GESTURE_RANGE_ATTACK_KNIFE
		self.ActivityTranslate[ACT_HL2MP_GESTURE_RELOAD] = ACT_HL2MP_GESTURE_RELOAD_KNIFE
		self.ActivityTranslate[ACT_HL2MP_JUMP] = ACT_HL2MP_JUMP_KNIFE
		self.ActivityTranslate[ACT_RANGE_ATTACK1] = ACT_RANGE_ATTACK_KNIFE
	end
end
