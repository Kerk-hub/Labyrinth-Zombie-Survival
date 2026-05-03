-- Shared mixin for building category weapons.
-- Grants nail/unnail functionality equivalent to the Carpenter's Hammer.
--
-- Usage in a single-file weapon (.lua):
--   At the top (shared):   BUILDING_WEAPON_MIXIN.ApplyShared(SWEP)
--   Inside INC_SERVER():   BUILDING_WEAPON_MIXIN.ApplyServer(SWEP)
--   Inside INC_CLIENT():   BUILDING_WEAPON_MIXIN.ApplyClient(SWEP)
--
-- Usage in a folder weapon:
--   shared.lua:   BUILDING_WEAPON_MIXIN.ApplyShared(SWEP)
--   init.lua:     BUILDING_WEAPON_MIXIN.ApplyServer(SWEP)
--   cl_init.lua:  BUILDING_WEAPON_MIXIN.ApplyClient(SWEP)

AddCSLuaFile()

BUILDING_WEAPON_MIXIN = BUILDING_WEAPON_MIXIN or {}

-- Sets ammo/stock fields required for nailing. Call in shared scope.
function BUILDING_WEAPON_MIXIN.ApplyShared(SWEP)
	SWEP.Primary.ClipSize    = 1
	SWEP.Primary.Automatic   = true
	SWEP.Primary.Ammo        = "GaussEnergy"
	SWEP.Primary.DefaultClip = 16

	SWEP.Secondary.ClipSize    = 1
	SWEP.Secondary.DefaultClip = 1
	SWEP.Secondary.Ammo        = "dummy"

	SWEP.MaxStock = 5

	SWEP.AutoBuyAmmoOnSecondary = true
	SWEP.NoPropThrowing         = true

	-- How long after nailing before the next action is allowed (default: 0.5)
	SWEP.NailDelay   = SWEP.NailDelay   or 0.5
	-- How long after unnailing before the next action is allowed (default: 0.5 with many nails, 1.0 with few)
	SWEP.UnnailDelay = SWEP.UnnailDelay or 1.0
end

-- Attaches Reload (unnail) and SecondaryAttack (nail) and OnMeleeHit guard. Call in server scope.
function BUILDING_WEAPON_MIXIN.ApplyServer(SWEP)

	-- UNNAIL — Reload key
	function SWEP:Reload()
		if CurTime() < self:GetNextPrimaryFire() then return end

		local owner = self:GetOwner()

		local tr    = owner:CompensatedMeleeTrace(self.MeleeRange, self.MeleeSize)
		local trent = tr.Entity
		if not trent:IsValid() or not trent:IsNailed() then return end

		local ent, dist
		for _, e in pairs(ents.FindByClass("prop_nail")) do
			if not e.m_PryingOut and e:GetParent() == trent then
				local edist = e:GetActualPos():DistToSqr(tr.HitPos)
				if not dist or edist < dist then
					ent  = e
					dist = edist
				end
			end
		end

		if not ent or not gamemode.Call("CanRemoveNail", owner, ent) then return end

		local nailowner = ent:GetOwner()
		if nailowner:IsValid() and nailowner:IsPlayer() and nailowner ~= owner
			and nailowner:Team() == TEAM_HUMAN
			and not gamemode.Call("CanRemoveOthersNail", owner, nailowner, ent) then
			return
		end

		self:SetNextPrimaryFire(CurTime() + (#trent.Nails > 2 and (self.UnnailDelay * 0.5) or self.UnnailDelay))

		ent.m_PryingOut = true

		self:SendWeaponAnim(self.Alternate and ACT_VM_HITCENTER or ACT_VM_MISSCENTER)
		self.Alternate = not self.Alternate

		owner:DoAnimationEvent(ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE)
		owner:EmitSound("weapons/melee/crowbar/crowbar_hit-" .. math.random(4) .. ".ogg")

		ent:GetParent():RemoveNail(ent, nil, owner)
		ent:GetParent():SetPhysicsAttacker(owner)

		if nailowner:IsValid() and nailowner:IsPlayer() and nailowner ~= owner and nailowner:Team() == TEAM_HUMAN then
			if gamemode.Call("PlayerShouldTakeNailRemovalPenalty", owner, ent, nailowner, trent) then
				owner:GivePenalty(30)
				owner:ReflectDamage(20)
			end

			if nailowner:NearestPoint(tr.HitPos):DistToSqr(tr.HitPos) <= 589824
				and (nailowner:HasWeapon("weapon_zs_hammer") or nailowner:HasWeapon("weapon_zs_electrohammer")) then
				nailowner:GiveAmmo(1, self.Primary.Ammo)
			else
				owner:GiveAmmo(1, self.Primary.Ammo)
			end
		else
			owner:GiveAmmo(1, self.Primary.Ammo)
		end
	end

	-- NAIL — Secondary Fire key
	function SWEP:SecondaryAttack()
		if self:GetPrimaryAmmoCount() <= 0 or CurTime() < self:GetNextPrimaryFire() then return end

		local owner = self:GetOwner()

		if GAMEMODE:IsClassicMode() then
			owner:PrintTranslatedMessage(HUD_PRINTCENTER, "cant_do_that_in_classic_mode")
			return
		end

		local tr    = owner:CompensatedMeleeTrace(64, self.MeleeSize, nil, nil, nil, true)
		local trent = tr.Entity

		if not trent:IsValid()
		or not util.IsValidPhysicsObject(trent, tr.PhysicsBone)
		or tr.Fraction == 0
		or (trent:GetMoveType() ~= MOVETYPE_VPHYSICS and not trent:GetNailFrozen())
		or trent.NoNails
		or trent:IsProjectile()
		or (trent:IsNailed() and (#trent.Nails >= GAMEMODE.MaxNails or trent:GetPropsInContraption() >= GAMEMODE.MaxPropsInBarricade))
		or (trent:GetMaxHealth() == 1 and trent:Health() == 0 and not trent.TotalHealth)
		or (trent.PreHoldCollisionGroup and (
			trent.PreHoldCollisionGroup == COLLISION_GROUP_DEBRIS or
			trent.PreHoldCollisionGroup == COLLISION_GROUP_DEBRIS_TRIGGER or
			trent.PreHoldCollisionGroup == COLLISION_GROUP_INTERACTIVE_DEBRIS))
		or (not trent:IsNailed() and not trent:GetPhysicsObject():IsMoveable()) then
			return
		end

		if not gamemode.Call("CanPlaceNail", owner, tr) then return end

		local count = 0
		for _, nail in pairs(trent:GetNails()) do
			if nail:GetDeployer() == owner then
				count = count + 1
				if count >= GAMEMODE.MaxNails then return end
			end
		end

		for _, nail in pairs(ents.FindByClass("prop_nail")) do
			if nail:GetParent() == trent and nail:GetActualPos():DistToSqr(tr.HitPos) <= 81 then
				owner:PrintTranslatedMessage(HUD_PRINTCENTER, "too_close_to_another_nail")
				return
			end
		end

		if trent:GetBarricadeHealth() <= 0 and trent:GetMaxBarricadeHealth() > 0 then
			owner:PrintTranslatedMessage(HUD_PRINTCENTER, "object_too_damaged_to_be_used")
			return
		end

		local ropeconstraint = constraint.FindConstraint(trent, "Rope")
		if ropeconstraint then
			if ropeconstraint.Ent1 and ropeconstraint.Ent1:IsValid() and ropeconstraint.Ent1:GetClass() == "prop_drone" then return end
			if ropeconstraint.Ent2 and ropeconstraint.Ent2:IsValid() and ropeconstraint.Ent2:GetClass() == "prop_drone" then return end
		end

		local aimvec = owner:GetAimVector()
		local trtwo  = util.TraceLine({
			start  = tr.HitPos,
			endpos = tr.HitPos + aimvec * 24,
			filter = table.Add({owner, trent}, GAMEMODE.CachedInvisibleEntities),
			mask   = MASK_SOLID,
		})

		if trtwo.HitSky then return end

		local ent          = trtwo.Entity
		local cannailtoent = ent:IsValid()
			and util.IsValidPhysicsObject(ent, trtwo.PhysicsBone)
			and (ent:GetMoveType() == MOVETYPE_VPHYSICS or ent:GetNailFrozen())
			and not ent.NoNails
			and not (not ent:IsNailed() and not ent:GetPhysicsObject():IsMoveable())
			and not (ent:GetMaxHealth() == 1 and ent:Health() == 0 and not ent.TotalHealth)

		if cannailtoent and not ent:IsNailed() then return end

		if trtwo.HitWorld or cannailtoent then
			if ent:IsValid()
				and (ent:IsProjectile() or ent.NoNails
					or (ent:IsNailed() and (#ent.Nails >= GAMEMODE.MaxNails or ent:GetPropsInContraption() >= GAMEMODE.MaxPropsInBarricade)))
			then return end

			if ent:GetBarricadeHealth() <= 0 and ent:GetMaxBarricadeHealth() > 0 then
				owner:PrintTranslatedMessage(HUD_PRINTCENTER, "object_too_damaged_to_be_used")
				return
			end

			if GAMEMODE:EntityWouldBlockSpawn(ent) then return end

			local cons = constraint.Weld(trent, ent, tr.PhysicsBone, trtwo.PhysicsBone, 0, true)
			if cons ~= nil then
				for _, oldcons in pairs(constraint.FindConstraints(trent, "Weld")) do
					if oldcons.Ent1 == ent or oldcons.Ent2 == ent then
						cons = oldcons.Constraint
						break
					end
				end
			end

			if not cons then return end

			self:SendWeaponAnim(self.Alternate and ACT_VM_HITCENTER or ACT_VM_MISSCENTER)
			self.Alternate = not self.Alternate

			owner:DoAnimationEvent(ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE)

			self:SetNextPrimaryFire(CurTime() + self.NailDelay)
			self:TakePrimaryAmmo(1)

			local nail = ents.Create("prop_nail")
			if nail:IsValid() then
				nail:SetActualOffset(tr.HitPos, trent)
				nail:SetPos(tr.HitPos - aimvec * 8)
				nail:SetAngles(aimvec:Angle())
				nail:AttachTo(trent, ent, tr.PhysicsBone, trtwo.PhysicsBone)
				nail:Spawn()
				nail:SetDeployer(owner)
				cons:DeleteOnRemove(nail)
				gamemode.Call("OnNailCreated", trent, ent, nail)
				nail:EmitSound(string.format("weapons/melee/crowbar/crowbar_hit-%d.ogg", math.random(4)))
			end
		end
	end

	-- Guard: skip melee damage on nailed props, same as the hammer
	local baseOnMeleeHit = SWEP.OnMeleeHit
	function SWEP:OnMeleeHit(hitent, hitflesh, tr)
		if not hitent:IsValid() then return end

		if hitent.HitByHammer and hitent:HitByHammer(self, self:GetOwner(), tr) then
			return
		end

		if hitent:IsNailed() then
			return true
		end

		if baseOnMeleeHit then
			return baseOnMeleeHit(self, hitent, hitflesh, tr)
		end
	end
end

-- Attaches the nail-count HUD element. Call in client scope.
function BUILDING_WEAPON_MIXIN.ApplyClient(SWEP)
	function SWEP:DrawHUD()
		if GetGlobalBool("classicmode") then return end

		local screenscale = BetterScreenScale()

		surface.SetFont("ZSHUDFont")
		local nails          = self:GetPrimaryAmmoCount()
		local text           = translate.Format("nails_x", nails)
		local nTEXW, nTEXH   = surface.GetTextSize(text)

		draw.SimpleTextBlurry(
			text, "ZSHUDFont",
			ScrW() - nTEXW * 0.75 - 32 * screenscale,
			ScrH() - nTEXH * 1.5,
			nails > 0 and COLOR_LIMEGREEN or COLOR_RED,
			TEXT_ALIGN_CENTER
		)

		if GetConVar("crosshair"):GetInt() ~= 1 then return end
		self:DrawCrosshairDot()
	end
end
