INC_SERVER()

function SWEP:ShootBullets(damage, numshots, cone)
	local owner = self:GetOwner()
	self:SendWeaponAnimation()
	owner:DoAttackEvent()

	local shootpos = owner:GetShootPos()
	local endpos = shootpos + owner:GetAimVector() * 2048
	local filter = {owner}

	for i = 1, player.GetCount() do
		local tr = util.TraceLine({
			start = shootpos,
			endpos = endpos,
			filter = filter,
			mask = MASK_SHOT
		})

		local hitent = tr.Entity
		if not hitent:IsValid() then break end
		if not hitent:IsPlayer() then break end
		if hitent:Team() == TEAM_UNDEAD then break end

		local ehithp, ehitmaxhp = hitent:Health(), hitent:GetMaxHealth()

		if ehithp >= ehitmaxhp then
			table.insert(filter, hitent)
		end

		if hitent:IsSkillActive(SKILL_D_FRAIL) and ehithp >= ehitmaxhp * 0.25 then
			owner:CenterNotify(COLOR_RED, translate.Format("frail_healdart_warning", hitent:GetName()))
			hitent:EmitSound("buttons/button8.wav", 70, math.random(115, 128))
			if not self.Refunded and owner:IsSkillActive(SKILL_RECLAIMSOL) then
				self.Refunded = true
				owner:GiveAmmo(3, "Battery")
			end
		elseif not (owner:IsSkillActive(SKILL_RECLAIMSOL) and ehithp >= ehitmaxhp) then
			hitent:GiveStatus("healdartboost", self.BuffDuration or 10)
			local distmul = 1 - (tr.Fraction * 0.75) -- at max range heals 25% of base
			owner:HealPlayer(hitent, self.Heal * (owner.MedDartEffMul or 1) * distmul)
		end

		local effectdata = EffectData()
			effectdata:SetOrigin(tr.HitPos)
			effectdata:SetNormal(tr.HitNormal)
			effectdata:SetEntity(hitent)
		util.Effect("hit_healdart", effectdata)

		break
	end
end