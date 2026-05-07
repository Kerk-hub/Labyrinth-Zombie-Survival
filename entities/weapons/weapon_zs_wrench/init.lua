INC_SERVER()

local function RefreshOwnedTurretScanSpeed(owner, mul)
	for _, ent in pairs(ents.FindByClass("prop_gunturret*")) do
		if ent:IsValid() and ent:GetObjectOwner() == owner then
			ent:SetScanSpeed(mul * (owner.TurretScanSpeedMul_Base or 1))
		end
	end
end

function SWEP:Deploy()
	local owner = self:GetOwner()
	if owner:IsValid() then
		owner.m_WrenchActive = true
		local mul = 1 + (self.QualityTier or 0) * 0.30
		owner.TurretScanSpeedMul = mul
		RefreshOwnedTurretScanSpeed(owner, mul)
	end
	return self.BaseClass.Deploy(self)
end

function SWEP:Holster(wep)
	local owner = self:GetOwner()
	if owner:IsValid() then
		owner.m_WrenchActive = nil
		owner.TurretScanSpeedMul = nil
		RefreshOwnedTurretScanSpeed(owner, 1)
	end
	return self.BaseClass.Holster(self, wep)
end

function SWEP:PlayRepairSound(hitent)
	hitent:EmitSound("npc/dog/dog_servo"..math.random(7, 8)..".wav", 70, math.random(100, 105))
end

function SWEP:OnMeleeHit(hitent, hitflesh, tr)
	if CLIENT or not hitent:IsValid() then return end

	local owner = self:GetOwner()

	if hitent.HitByWrench and hitent:HitByWrench(self, owner, tr) then
		return
	end

	if hitent.GetObjectHealth then
		local oldhealth = hitent:GetObjectHealth()
		if oldhealth <= 0 or oldhealth >= hitent:GetMaxObjectHealth() or hitent.m_LastDamaged and CurTime() < hitent.m_LastDamaged + 4 then return end

		local healstrength = self.HealStrength * (owner.RepairRateMul or 1) * (hitent.WrenchRepairMultiplier or 1)

		hitent:SetObjectHealth(math.min(hitent:GetMaxObjectHealth(), hitent:GetObjectHealth() + healstrength))
		local healed = hitent:GetObjectHealth() - oldhealth
		self:PlayRepairSound(hitent)
		gamemode.Call("PlayerRepairedObject", owner, hitent, healed / 2, self)

		local effectdata = EffectData()
			effectdata:SetOrigin(tr.HitPos)
			effectdata:SetNormal(tr.HitNormal)
			effectdata:SetMagnitude(1)
		util.Effect("nailrepaired", effectdata, true, true)

		return true
	end
end
