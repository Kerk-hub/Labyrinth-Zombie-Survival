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

	-- Hitscan check
	local shootpos = owner:GetShootPos()

	local tr = util.TraceLine({
		start = shootpos,
		endpos = shootpos + owner:GetAimVector() * 2048,
		filter = owner,
		mask = MASK_SHOT
	})

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

	-- Fire the actual dart for visuals
	-- This keeps the original ZS projectile look
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