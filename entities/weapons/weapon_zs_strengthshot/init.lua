INC_SERVER()

DEFINE_BASECLASS("weapon_zs_baseproj")

SWEP.Primary.Projectile = "projectile_strengthdart"
SWEP.Primary.ProjVelocity = 2000

function SWEP:EntModify(ent)
	ent:SetSeeked(self:GetSeekedPlayer() or nil)
	ent.BuffDuration = self.BuffDuration
end

function SWEP:ShootBullets(damage, numshots, cone)
	local owner = self:GetOwner()

	local tr = util.TraceLine({
		start = owner:GetShootPos(),
		endpos = owner:GetShootPos() + owner:GetAimVector() * 2048,
		filter = owner,
		mask = MASK_SHOT
	})

	local hitent = tr.Entity

	if IsValid(hitent) and hitent:IsPlayer() and hitent:Team() ~= TEAM_UNDEAD then
		local strstatus = hitent:GiveStatus("strengthdartboost", self.BuffDuration or 10)
		strstatus.Applier = owner

		local txt = "Strength Shot Gun"

		net.Start("zs_buffby")
			net.WriteEntity(owner)
			net.WriteString(txt)
		net.Send(hitent)

		net.Start("zs_buffwith")
			net.WriteEntity(hitent)
			net.WriteString(txt)
		net.Send(owner)

		hitent:GiveStatus("healdartboost", (self.BuffDuration or 10) / 2)
	end

	-- keep the normal flying dart
	BaseClass.ShootBullets(self, damage, numshots, cone)
end