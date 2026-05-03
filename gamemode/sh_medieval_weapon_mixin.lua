-- Shared mixin for medieval category weapons.
-- Grants cleave: each swing hits all zombies in the arc via penetrating trace.
-- Damage scales down per additional target (0.5x minimum).
--
-- Usage (single-file weapon):
--   At the end of the file: MEDIEVAL_WEAPON_MIXIN.Apply(SWEP)
--
-- Usage (folder weapon with special secondary):
--   Add GetTracesNumPlayers, GetDamage, MeleeSwing, and MeleeHitEntity
--   directly to shared.lua, adapting MeleeSwing as needed.

AddCSLuaFile()

MEDIEVAL_WEAPON_MIXIN = MEDIEVAL_WEAPON_MIXIN or {}

function MEDIEVAL_WEAPON_MIXIN.Apply(SWEP)
	SWEP.GetTracesNumPlayers = function(self, traces)
		local numplayers = 0
		for _, trace in pairs(traces) do
			local ent = trace.Entity
			if ent and ent:IsValidPlayer() then
				numplayers = numplayers + 1
			end
		end
		return numplayers
	end

	SWEP.GetDamage = function(self, numplayers, basedamage)
		basedamage = basedamage or self.MeleeDamage
		if numplayers then
			return basedamage * math.Clamp(1.25 - numplayers * 0.25, 0.5, 1)
		end
		return basedamage
	end

	SWEP.MeleeSwing = function(self)
		local owner = self:GetOwner()

		owner:DoAttackEvent()
		self:SendWeaponAnim(self.MissAnim)
		self.IdleAnimation = CurTime() + self:SequenceDuration()

		local hit = false
		local tr = owner:CompensatedPenetratingMeleeTrace(self.MeleeRange * (owner.MeleeRangeMul or 1), self.MeleeSize)
		local damage = self:GetDamage(self:GetTracesNumPlayers(tr))
		local ent

		local damagemultiplier = owner:Team() == TEAM_HUMAN and owner.MeleeDamageMultiplier or 1
		if owner:IsSkillActive(SKILL_LASTSTAND) then
			if owner:Health() <= owner:GetMaxHealth() * 0.25 then
				damagemultiplier = damagemultiplier * 2
			else
				damagemultiplier = damagemultiplier * 0.85
			end
		end

		for _, trace in ipairs(tr) do
			if not trace.Hit then continue end

			ent = trace.Entity
			hit = true

			local hitflesh = trace.MatType == MAT_FLESH or trace.MatType == MAT_BLOODYFLESH or trace.MatType == MAT_ANTLION or trace.MatType == MAT_ALIENFLESH

			if hitflesh then
				util.Decal(self.BloodDecal, trace.HitPos + trace.HitNormal, trace.HitPos - trace.HitNormal)
				if SERVER then
					self:ServerHitFleshEffects(ent, trace, damagemultiplier)
				end
			end

			if ent and ent:IsValid() then
				if SERVER then
					self:ServerMeleeHitEntity(trace, ent, damagemultiplier)
				end
				self:MeleeHitEntity(trace, ent, damagemultiplier, damage)
				if SERVER then
					self:ServerMeleePostHitEntity(trace, ent, damagemultiplier)
				end
				if owner.GlassWeaponShouldBreak then break end
			end
		end

		if hit then
			self:PlayHitSound()
		else
			self:PlaySwingSound()
			if owner.MeleePowerAttackMul and owner.MeleePowerAttackMul > 1 then
				self:SetPowerCombo(0)
			end
		end
	end

	SWEP.MeleeHitEntity = function(self, tr, hitent, damagemultiplier, damage)
		if not IsFirstTimePredicted() then return end

		local owner = self:GetOwner()

		if SERVER and hitent:IsPlayer() and owner:IsSkillActive(SKILL_GLASSWEAPONS) then
			damagemultiplier = damagemultiplier * 3.5
			owner.GlassWeaponShouldBreak = not owner.GlassWeaponShouldBreak
		end

		damage = damage * damagemultiplier

		local dmginfo = DamageInfo()
		dmginfo:SetDamagePosition(tr.HitPos)
		dmginfo:SetAttacker(owner)
		dmginfo:SetInflictor(self)
		dmginfo:SetDamageType(self.DamageType)
		dmginfo:SetDamage(damage)
		dmginfo:SetDamageForce(math.min(self.MeleeDamage, 50) * 50 * owner:GetAimVector())

		local vel
		if hitent:IsPlayer() then
			if owner.MeleePowerAttackMul and owner.MeleePowerAttackMul > 1 then
				self:SetPowerCombo(self:GetPowerCombo() + 1)
				damage = damage + damage * (owner.MeleePowerAttackMul - 1) * (self:GetPowerCombo() / 4)
				dmginfo:SetDamage(damage)
				if self:GetPowerCombo() >= 4 then
					self:SetPowerCombo(0)
					if SERVER then
						local pitch = math.Clamp(math.random(90, 110) + 15 * (1 - damage / 45), 50, 200)
						owner:EmitSound("npc/strider/strider_skewer1.wav", 75, pitch)
					end
				end
			end

			hitent:MeleeViewPunch(damage)
			if hitent:IsHeadcrab() then
				damage = damage * 2
				dmginfo:SetDamage(damage)
			end

			if SERVER then
				hitent:SetLastHitGroup(tr.HitGroup)
				if tr.HitGroup == HITGROUP_HEAD then
					hitent:SetWasHitInHead()
				end
				if hitent:WouldDieFrom(damage, tr.HitPos) then
					dmginfo:SetDamageForce(math.min(self.MeleeDamage, 50) * 400 * owner:GetAimVector())
				end
			end

			vel = hitent:GetVelocity()
		else
			if owner.MeleePowerAttackMul and owner.MeleePowerAttackMul > 1 then
				self:SetPowerCombo(0)
			end
		end

		if self.PointsMultiplier then
			POINTSMULTIPLIER = self.PointsMultiplier
		end
		hitent:DispatchTraceAttack(dmginfo, tr, owner:GetAimVector())
		if self.PointsMultiplier then
			POINTSMULTIPLIER = nil
		end

		if vel then
			hitent:SetLocalVelocity(vel)
		end

		if hitent:IsPlayer() then
			local knockback = self.MeleeKnockBack * (owner.MeleeKnockbackMultiplier or 1)
			if knockback > 0 then
				hitent:ThrowFromPositionSetZ(tr.StartPos, knockback, nil, true)
			end
			if owner.MeleeLegDamageAdd and owner.MeleeLegDamageAdd > 0 then
				hitent:AddLegDamage(owner.MeleeLegDamageAdd)
			end
		end

		local effectdata = EffectData()
		effectdata:SetOrigin(tr.HitPos)
		effectdata:SetStart(tr.StartPos)
		effectdata:SetNormal(tr.HitNormal)
		util.Effect("RagdollImpact", effectdata)
		if not tr.HitSky then
			effectdata:SetSurfaceProp(tr.SurfaceProps)
			effectdata:SetDamageType(self.DamageType)
			effectdata:SetHitBox(tr.HitBox)
			effectdata:SetEntity(hitent)
			util.Effect("Impact", effectdata)
		end
	end
end
