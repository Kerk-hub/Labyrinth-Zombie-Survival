-- Shared mixin for survival category weapons.
-- Grants an extra jump on right click with a 7-second cooldown.
--
-- Usage (single-file weapon):
--   At the end of the file: SURVIVAL_WEAPON_MIXIN.Apply(SWEP)
--
-- The jump cooldown is tracked via self.m_SurvivalNextJump so that weapons
-- whose base class resets SetNextSecondaryFire (e.g. weapon_zs_fists) do not
-- accidentally bypass the cooldown.

AddCSLuaFile()

SURVIVAL_WEAPON_MIXIN = SURVIVAL_WEAPON_MIXIN or {}

local JUMP_COOLDOWN = 7
local JUMP_VELOCITY = 280

function SURVIVAL_WEAPON_MIXIN.Apply(SWEP)
	local prevThink = rawget(SWEP, "Think")

	-- SecondaryAttack: extra jump with independent 7-second cooldown.
	SWEP.SecondaryAttack = function(self)
		local owner = self:GetOwner()
		if not owner:IsValid() then return end
		if self:GetNextSecondaryFire() > CurTime() then return end
		if (self.m_SurvivalNextJump or 0) > CurTime() then return end

		if SERVER then
			owner:SetVelocity(Vector(0, 0, JUMP_VELOCITY))
			self:EmitSound("Weapon_Flashbang.Bounce")
		end

		self.m_SurvivalNextJump = CurTime() + JUMP_COOLDOWN
		self:SetNextSecondaryFire(CurTime() + 0.5)
	end

	-- Think: client-side notification when jump is recharged.
	SWEP.Think = function(self)
		if CLIENT then
			local isCharged = (self.m_SurvivalNextJump or 0) <= CurTime()
			if isCharged and not self.m_JumpChargeNotified then
				self.m_JumpChargeNotified = true
				self:EmitSound("buttons/button1.wav", 75, 100)
				GAMEMODE:CenterNotify(COLOR_GREEN, "Extra Jump Charged")
			elseif not isCharged then
				self.m_JumpChargeNotified = false
			end
		end

		if prevThink then
			prevThink(self)
		else
			self.BaseClass.Think(self)
		end
	end
end
