function SWEP:CalculateNextAttackTime(cycletime)
	local lastShotTime = self:GetNextPrimaryFire()
	local currentTime = CurTime()
	local deltaTime = currentTime - lastShotTime

	if deltaTime < 0 or deltaTime > FrameTime() then
		lastShotTime = currentTime
	end

	self:SetNextPrimaryFire(lastShotTime + cycletime)
	return lastShotTime + cycletime
end

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then
		return
	end

	local owner = self:GetOwner()
	local seed = self:GetSpreadRandomSeed()
	local recoilIndex = self:GetRecoilIndex()
	local sequence = "Fire"
	if self.Animations.DryFire and self:Clip1() == 1 then
		sequence = "DryFire"
	end

	self:PlayAnimation(sequence, 1)
	self:SetNextIdleTime(CurTime() + owner:GetViewModel():SequenceDuration())
	owner:SetAnimation(PLAYER_ATTACK1)
	owner:MuzzleFlash()

	local shootAngle = owner:GetAimVector():Angle()
	shootAngle = shootAngle + owner:GetViewPunchAngles()
	shootAngle:Normalize()

	local recoilVelocity = owner:GetViewPunchVelocity()
	recoilVelocity = recoilVelocity + self.Recoil.Table[math.floor(recoilIndex)] * self.Recoil.Scale
	recoilVelocity:Normalize()
	owner:SetViewPunchVelocity(recoilVelocity)

	math.randomseed(owner:GetCurrentCommand():CommandNumber()) -- self:GetSpreadRandomSeed()
	local cone = self:GetCone()

	local bullet = {}
	bullet.Src = owner:GetShootPos()
	bullet.Dir = self:GetSpreadVector(shootAngle:Forward(), cone)
	bullet.Damage = 24
	bullet.Force = 1
	bullet.Tracer = 2
	bullet.Spread = Vector(0, 0, 0)

	-- owner:FireBullets(bullet)

	local bulletInfo = {}
	local projectileInfo = self.Projectile

	bulletInfo.Attacker			= owner
	bulletInfo.Inflictor		= self
	bulletInfo.Position			= owner:GetShootPos()
	bulletInfo.Velocity			= self:GetSpreadVector(shootAngle:Forward(), cone) * UTIL_MetersToUnits(projectileInfo.Velocity)
	bulletInfo.Mass				= projectileInfo.Mass / 15432.3584 -- Christ fucking kill me  [One kilogram has 15,432.3584 grains]
	bulletInfo.Diameter			= projectileInfo.Caliber / 25.4 -- One inch has 25.4 milimeters.
	bulletInfo.Gravity			= projectileInfo.Gravity
	bulletInfo.DragCoefficient	= projectileInfo.Drag
	bulletInfo.Initialize		= projectileInfo.Initialize
	bulletInfo.Draw				= projectileInfo.Draw
	bulletInfo.OnImpact			= projectileInfo.OnImpact

	-- server always IsFirstTimePredicted()
	if SERVER then
		net.Start("BlacksCW_NetworkBullets", true)
		net.WriteEntity(bulletInfo.Attacker)
		net.WriteEntity(bulletInfo.Inflictor)
		net.WriteVector(bulletInfo.Position)
		net.WriteVector(bulletInfo.Velocity:GetNormalized() * BLACKCW_DIRECTION_SCALEUP)
		net.WriteFloat(bulletInfo.Velocity:Length())
		net.SendOmit(bulletInfo.Attacker)
	elseif CLIENT and IsFirstTimePredicted() then
		BlacksCW.FireBullets(bulletInfo)

		-- debugoverlay.Cone(bulletInfo.Attacker, bulletInfo.Position, shootAngle:Forward(), 56756, cone, 5, Color(255, 230, 34, 255))
	end

	self:EmitSound(self.Primary.Sound)
	self:TakePrimaryAmmo(1)
	self:CalculateNextAttackTime(self.CycleTime)
	self:SetSpreadRandomSeed(math.fmod(seed + 1, 0x7FFFFFFF))
	self:SetAccuracyPenalty(math.min(self:GetAccuracyPenalty() + self.Inaccuracy.Firing, self.Inaccuracy.Max))
	self:SetRecoilIndex(math.min(recoilIndex + 1, #self.Recoil.Table))
end

function SWEP:CanSecondaryAttack()
	return false -- big gamer
end

function SWEP:SecondaryAttack()

end