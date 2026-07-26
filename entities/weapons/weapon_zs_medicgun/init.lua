INC_SERVER()

SWEP.Primary.Projectile = "projectile_healdart"
SWEP.Primary.ProjVelocity = 2000

function SWEP:EntModify(ent)
	-- Keep normal medic dart behavior
end

function SWEP:ShootBullets(damage, numshots, cone)
	local owner = self:GetOwner()

	self:SendWeaponAnimation()
	owner:DoAttackEvent()

	local shootpos = owner:GetShootPos()
	local endpos = shootpos + owner:GetAimVector() * 2048

	local filter = {owner}
	local tr

	while true do
		tr = util.TraceLine({
			start = shootpos,
			endpos = endpos,
			filter = filter,
			mask = MASK_SHOT
		})

		local ent = tr.Entity

		if not IsValid(ent) then
			break
		end

		if ent:IsPlayer() and ent:Team() ~= TEAM_UNDEAD then
			local hp = ent:Health()
			local maxhp = ent:GetMaxHealth()

			-- low hp ppl get za heal
			if ent:IsSkillActive(SKILL_D_FRAIL) then
				break
			end

			-- ppl w/max hp get no heal
			if hp >= maxhp then
				table.insert(filter, ent)
			else
				break
			end
		else
			break
		end
	end

	local hitent = tr.Entity

	if IsValid(hitent) and hitent:IsPlayer() and hitent:Team() ~= TEAM_UNDEAD then
		local ehithp = hitent:Health()
		local ehitmaxhp = hitent:GetMaxHealth()

		if hitent:IsSkillActive(SKILL_D_FRAIL) and ehithp >= ehitmaxhp * 0.25 then
			owner:CenterNotify(COLOR_RED, translate.Format("frail_healdart_warning", hitent:GetName()))
			hitent:EmitSound("buttons/button8.wav", 70, math.random(115, 128))

			if not self.Refunded and owner:IsSkillActive(SKILL_RECLAIMSOL) then
				self.Refunded = true
				owner:GiveAmmo(3, "Battery")
			end
		elseif not (owner:IsSkillActive(SKILL_RECLAIMSOL) and ehithp >= ehitmaxhp) then
			hitent:GiveStatus("healdartboost", self.BuffDuration or 10)

			local distmul = 1 - (tr.Fraction * 0.75)
			owner:HealPlayer(
				hitent,
				self.Heal * (owner.MedDartEffMul or 1) * distmul
			)
		end

		local effectdata = EffectData()
		effectdata:SetOrigin(tr.HitPos)
		effectdata:SetNormal(tr.HitNormal)
		effectdata:SetEntity(hitent)
		util.Effect("hit_healdart", effectdata)
	end

	for i = 1, numshots do
		local ent = ents.Create(self.Primary.Projectile)

		if IsValid(ent) then
			ent:SetPos(shootpos)
			ent:SetAngles(owner:EyeAngles())
			ent:SetOwner(owner)

			ent.ProjDamage = 0
			ent.ProjSource = self
			ent.ShotMarker = i
			ent.Team = owner:Team()

			self:EntModify(ent)
			ent:Spawn()

			local phys = ent:GetPhysicsObject()

			if IsValid(phys) then
				phys:Wake()

				local angle = owner:GetAimVector():Angle()
				phys:SetVelocityInstantaneous(
					angle:Forward() * self.Primary.ProjVelocity
				)

				self:PhysModify(phys)
			end
		end
	end
end
