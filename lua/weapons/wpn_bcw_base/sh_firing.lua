local WPN_RECOIL_VARIANCE = 0.55
local WPN_RECOIL_SUPPRESSION_SHOTS = 4
local WPN_RECOIL_SUPPRESSION_FACTOR = 0.75
function SWEP:GenerateRecoilTable()
	math.randomseed(self.Recoil.RandomSeed)
	local mode = self.Primary.Automatic
	local recoilAngle = self.Recoil.Angle
	local recoilAngleVariance = self.Recoil.AngleVariance
	local recoilMagnitude = self.Recoil.Magnitude
	local recoilMagnitudeVariance = self.Recoil.MagnitudeVariance
	local recoilMagnitudeIncrease = self.Recoil.MagnitudeIncrease

	for j = 1, self:GetMaxClip1() + 1 do
		local newAngle = recoilAngle + math.Rand(-recoilAngleVariance, recoilAngleVariance)
		local newMagnitude = recoilMagnitude + recoilMagnitudeIncrease + math.Rand(-recoilMagnitudeVariance, recoilMagnitudeVariance)

		if (mode and (j > 1)) then
			recoilAngle = Lerp(WPN_RECOIL_VARIANCE, recoilAngle, newAngle)
			recoilMagnitude = Lerp(WPN_RECOIL_VARIANCE, recoilMagnitude, newMagnitude)
		else
			recoilAngle = newAngle
			recoilMagnitude = newMagnitude
		end

		if (mode and (j < WPN_RECOIL_SUPPRESSION_SHOTS)) then
			local suppressionFactor = Lerp(j / WPN_RECOIL_SUPPRESSION_SHOTS, WPN_RECOIL_SUPPRESSION_FACTOR, 1.0)
			recoilMagnitude = recoilMagnitude * suppressionFactor
		end

		table.insert(self.Recoil.Table, Angle(
			-math.sin(math.rad(recoilAngle)) * recoilMagnitude,
			-math.cos(math.rad(recoilAngle)) * recoilMagnitude, 0))
	end
end

function SWEP:GetCone()
	local owner = self:GetOwner()
	local inaccuracy = self.Inaccuracy.Standing

	-- TODO: lerp between standing accuracy and crouched accuracy based on CBasePlayer->m_flDuckAmount?
	if owner:Crouching() then
		inaccuracy = self.Inaccuracy.Crouched
	end

	local velocity = owner:GetVelocity():Length()
	-- Add movement inaccuracy
	inaccuracy = inaccuracy + math.floor(self.Inaccuracy.Walking * UTIL_UnitsToMeters(velocity)) * FrameTime()
	-- Add firing inaccuracy
	inaccuracy = inaccuracy + self:GetAccuracyPenalty()
	-- Aaaa
	inaccuracy = Lerp(self:GetADSDelta(), inaccuracy, inaccuracy * self.Inaccuracy.Scoped)
	-- Convert inaccuracy from minutes of arc to Source engine's tangent accuracy shit number thing (idfk)
	inaccuracy = math.tan(math.deg(inaccuracy / 180 / 60))

	local bias = self.Inaccuracy.Bias
	local x = inaccuracy * math.Remap(bias, -1, 1, 0, 1)
	local y = inaccuracy * math.Remap(bias, 1, -1, 0, 1)

	return Vector(x, y, 0)
end

local AI_SHOT_BIAS_MIN = -1
local AI_SHOT_BIAS_MAX = 1
function SWEP:GetSpreadVector(direction, spread)
	local x, y, z = 0, 0, 0
	local angles = direction:Angle()
	local bias = math.Remap(self.Inaccuracy.Gaussian, -1, 1, 0, 1)
	local shotBias = ((AI_SHOT_BIAS_MAX - AI_SHOT_BIAS_MIN) * bias) + AI_SHOT_BIAS_MIN;
	local flatness = math.abs(shotBias) * 0.5

	repeat
			x = math.Rand(-1,1) * flatness + math.Rand(-1,1) * (1 - flatness);
			y = math.Rand(-1,1) * flatness + math.Rand(-1,1) * (1 - flatness);

			if shotBias < 0 then
				x = Either(x >= 0, 1.0 - x, -1.0 - x)
				y = Either(y >= 0, 1.0 - y, -1.0 - y)
			end

			z = x * x + y * y;
	until (z <= 1);

	return angles:Forward() + (angles:Right() * x * spread.x) + (angles:Up() * y * spread.y)
end

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
	if not self:CanPrimaryAttack() or (self.Primary.ManualAction and not self:GetIsPrimed()) then
		return
	end

	local owner = self:GetOwner()
	if not IsValid(owner) then
		return
	end

	local sequence = "Fire"
	if self.Animations["Dry Fire"] and self:Clip1() == 1 then
		sequence = "Dry Fire"
	end

	local _, __ = self:PlayAnimation(sequence, 1)
	owner:MuzzleFlash()

	local shootAngle = owner:GetAimVector():Angle()
	shootAngle = shootAngle + owner:GetViewPunchAngles()
	shootAngle:Normalize()

	local recoilIndex = self:GetRecoilIndex()
	local recoilVelocity = owner:GetViewPunchVelocity()
	recoilVelocity = recoilVelocity + self.Recoil.Table[math.floor(recoilIndex)] * self.Recoil.Scale
	recoilVelocity:Normalize()
	owner:SetViewPunchVelocity(recoilVelocity)

	local seed = self:GetSpreadRandomSeed()
	local cone = self:GetCone()

	math.randomseed(owner:GetCurrentCommand():CommandNumber()) -- self:GetSpreadRandomSeed()

	local bulletInfo = {}
	local projectileInfo = self.Projectile

	bulletInfo.Attacker			= owner
	bulletInfo.Inflictor		= self
	bulletInfo.Position			= owner:GetShootPos()
	bulletInfo.Mass				= projectileInfo.Mass / 15432.3584 -- Christ fucking kill me  [One kilogram has 15,432.3584 grains]
	bulletInfo.Diameter			= projectileInfo.Caliber / 25.4 -- One inch has 25.4 milimeters.
	bulletInfo.Gravity			= projectileInfo.Gravity
	bulletInfo.DragCoefficient	= projectileInfo.Drag
	bulletInfo.Initialize		= projectileInfo.Initialize
	bulletInfo.Draw				= projectileInfo.Draw
	bulletInfo.OnImpact			= projectileInfo.OnImpact

	for i = 1, self.Projectile.Count do
		-- CURIOSITY: Perhaps we should be incrementing randomseed here?
		bulletInfo.Velocity			= self:GetSpreadVector(shootAngle:Forward(), cone) * UTIL_MetersToUnits(projectileInfo.Velocity)

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
	end

	self:TakePrimaryAmmo(1)
	self:EmitSound(self.Primary.Sound)
	self:CalculateNextAttackTime(self.CycleTime)
	self:SetSpreadRandomSeed(math.fmod(seed + 1, 0x7FFFFFFF))
	self:SetAccuracyPenalty(math.min(self:GetAccuracyPenalty() + self.Inaccuracy.Firing, self.Inaccuracy.Max))
	self:SetRecoilIndex(math.min(recoilIndex + 1, #self.Recoil.Table))

	local ammoCount = self:Clip1()
	if ammoCount <= 0 or self.Primary.ManualAction then
		self:SetIsPrimed(false)
	end
end

function SWEP:CanSecondaryAttack()
	return false -- big gamer
end

function SWEP:SecondaryAttack()

end