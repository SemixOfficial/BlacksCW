AddCSLuaFile()
DEFINE_BASECLASS("weapon_base")

SWEP.PrintName		= "Scripted Weapon"
SWEP.Author			= "BlacK"
SWEP.IsBCWWeapon	= true

SWEP.HoldType		= "ar2"
SWEP.UseHands		= true
SWEP.ViewModelFOV	= 62
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/weapons/v_pistol.mdl"
SWEP.WorldModel		= "models/weapons/w_357.mdl"

SWEP.Spawnable		= false
SWEP.AdminOnly		= false

SWEP.Primary.ClipSize		= 30
SWEP.Primary.DefaultClip	= 90
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "Pistol"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= 0
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.Projectile = {}
SWEP.Projectile.Mass        = 1	-- Grains
SWEP.Projectile.Drag        = 0.3	-- No-Unit (multiplier)
SWEP.Projectile.Gravity     = 800	-- Inches per second
SWEP.Projectile.Velocity    = 400   -- Meters per second
SWEP.Projectile.Caliber     = 9	-- Milimeters

SWEP.Projectile.Initialize	= function(self)
	-- Called when bullet is initialized.
	self.TracerMaterial = Material("effects/spark")
	self.HeadMaterial = Material("effects/yellowflare")
	self.TracerLength = 128
	self.TracerWidth = 8
end

SWEP.Projectile.Draw		= function(self)
	-- Called every frame when bullet is about to be drawn.
	render.SetMaterial(self.TracerMaterial)
	render.DrawBeam(self.Position, self.Position - self.Velocity:GetNormalized() * 128, self.TracerWidth, 1, 0, color_white)

	local bulletDir = self.Position - (self.Position - self.Velocity:GetNormalized() * 128)

	local degAway = 90 - math.abs(math.deg(math.asin(bulletDir:Dot(EyeAngles():Forward()) / bulletDir:Length())))

	local w = (self.TracerWidth * 2) * (math.max(15 - degAway, 0) / 15)
	local h = (self.TracerWidth * 2) * (math.max(15 - degAway, 0) / 15)

	render.SetMaterial(self.HeadMaterial)
	render.DrawSprite(self.Position, w, h, color_white)
end
SWEP.Projectile.OnImpact	= function(self)
	-- Called when bullet hits a solid object.
	util.BulletImpactW(self.TraceResult, self.Attacker)
end

function SWEP:Initialize()
	self:SetSpreadRandomSeed(0)
	self:SetHoldType(self.HoldType)
	self:GenerateRecoilTable()
end

function SWEP:SetupDataTables()
	self:NetworkVar("Float", 0, "NextIdleTime")
	self:NetworkVar("Float", 1, "ReloadFinishTime")
	self:NetworkVar("Float", 2, "RecoilIndex")

	self:NetworkVar("Bool", 0, "IsReloading")

	self:NetworkVar("Int", 0, "SpreadRandomSeed")

	self:SetRecoilIndex(1)
end

function SWEP:Holster()
	self:SetIsReloading(false)
	self:SetReloadFinishTime(0)

	return true
end

function SWEP:IdleThink()
	if self:GetNextIdleTime() == 0 or CurTime() <= self:GetNextIdleTime() then
		return
	end

	self:SendWeaponAnim(ACT_VM_IDLE)
	self:SetNextIdleTime(0)
end

function SWEP:RecoilThink()
	if self:GetNextPrimaryFire() > CurTime() - (self.CycleTime * self.Recoil.Decay_Treshold) then
		return
	end

	local recoilIndex = self:GetRecoilIndex()
	local decreaseMagnitude = self.Recoil.Decay -- + (recoilIndex / #self.Recoil.Table) ^ self.Recoil.Decay_Exponent
	local decreaseAmount = (decreaseMagnitude / self.CycleTime) * FrameTime()

	self:SetRecoilIndex(math.max(recoilIndex - decreaseAmount, 1))
end

function SWEP:Think()
	local owner = self:GetOwner()

	if self:GetIsReloading() then
		if CurTime() > self:GetReloadFinishTime() then

			local clip = self:Clip1()
			local maxclip = self:GetMaxClip1()
			local dif = self:GetMaxClip1() - self:Clip1()
			local amt = math.min(self:Clip1() + owner:GetAmmoCount(self.Primary.Ammo), self:GetMaxClip1())
			if self.CanChamberRound ~= false and dif ~= self:GetMaxClip1() then
				dif = 1
				amt = amt + 1
			end

			self:SetClip1(amt)
			owner:RemoveAmmo(dif, self.Primary.Ammo)
			self:SetIsReloading(false)
			self:SetRecoilIndex(1)
		end
	end

	self:RecoilThink()
end

-- From homonovus :>
function SWEP:SetWeaponSequence(sequence, playbackRate)
	if sequence == -1 then
		return false
	end

	self:SendViewModelMatchingSequence(sequence)

	local owner = self:GetOwner()
	if owner:IsValid() then
		local vm = owner:GetViewModel()
		if vm:IsValid() then
			vm:SendViewModelMatchingSequence(sequence)
			vm:SetPlaybackRate(playbackRate)
		end
	end

	self:SetNextIdleTime(CurTime() + (self:SequenceDuration(sequence) * playbackRate))
	return true
end

function SWEP:SetWeaponSequenceByName(sequenceName, playbackRate)
	local sequenceId = self:LookupSequence(sequenceName)
	return self:SetWeaponSequence(sequenceId, playbackRate)
end

function SWEP:SetWeaponAnim(act, playbackRate)
	local idealSequence = self:SelectWeightedSequence(act)
	if idealSequence == -1 then
		 return false
	end

	self:SendWeaponAnim(act)
	self:SendViewModelMatchingSequence(idealSequence)
	self:SetPlaybackRate(playbackRate)

	-- Set the next time the weapon will idle
	self:SetNextIdleTime(CurTime() + (self:SequenceDuration() * playbackRate))
	return true
end

function SWEP:PlayAnimation(animation, playbackRate)
	local animData = self.Animations[animation]

	if istable(animData) then
		self:SetWeaponSequenceByName(table.Random(animData), playbackRate)
	elseif isstring(animData) then
		self:SetWeaponSequenceByName(animData, playbackRate)
	end
end

function SWEP:Reload()
	local owner = self:GetOwner()
	local viewmodel = owner:GetViewModel()

	if owner:GetAmmoCount(self.Primary.Ammo) == 0 then
		return
	end

	local extra = 1
	if self.CanChamberRound == false then
		extra = 0
	end

	if self:GetIsReloading() or self:Clip1() >= (self:GetMaxClip1() + extra) then
		return
	end

	local sequence = "Reload"
	if self.Animations.Reload_Empty and self:Clip1() == 0 then
		sequence = "Reload_Empty"
	elseif self.Animations.Reload_Start then
		sequence = "Reload_Start"
	end

	self:SetIsReloading(true)
	self:PlayAnimation(sequence, 1)
	owner:SetAnimation(PLAYER_RELOAD)

	local sequenceDuration = viewmodel:SequenceDuration()
	self:SetReloadFinishTime(CurTime() + sequenceDuration)
	self:CalculateNextAttackTime(sequenceDuration)
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

-- function SWEP:GenerateRecoilTable()
-- 	local recoilIncrease = Angle(25, 1.5, 0)
-- 	local recoilVelocity = Angle(0, 0, 0)
-- 	local recoilVariance = 0.5
-- 	local recoilDeviation = 15
-- 	local recoilExponent = 0.5

-- 	local recoilSeed = self.Recoil.RandomSeed
-- 	local magazineCapacity = self:GetMaxClip1()
-- 	local recoilAngle = Angle(0, 0, 0)

-- 	local recoilTableSize = self:GetMaxClip1() + 1

-- 	math.randomseed(recoilSeed)
-- 	while #self.Recoil.Table < recoilTableSize do

-- 		local herkz = #self.Recoil.Table / recoilTableSize

-- 		recoilAngle = recoilAngle + (recoilVelocity / magazineCapacity)
-- 		recoilAngle:Normalize()

-- 		recoilVelocity = recoilVelocity - (recoilIncrease / magazineCapacity)
-- 		recoilVelocity:Normalize()

-- 		recoilIncrease.y = recoilIncrease.y + recoilDeviation
-- 		recoilIncrease:Normalize()

-- 		if math.Rand(0, 1) < recoilVariance then
-- 			recoilDeviation = recoilDeviation * -math.Rand(1, 2)
-- 		end

-- 		table.insert(self.Recoil.Table, recoilAngle)
-- 	end
-- end

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

	local bullet = {}
	bullet.Src = owner:GetShootPos()
	bullet.Dir = shootAngle:Forward()
	bullet.Damage = 24
	bullet.Force = 1
	bullet.Tracer = 2
	bullet.Spread = Vector(0.01, 0.01, 0)
	bullet.Callback = function(attacker, trace, dmgInfo)
		if IsValid(trace.Entity) and trace.Entity:GetClass() == "npc_helicopter" then
			dmgInfo:SetDamageType(DMG_AIRBOAT)
			dmgInfo:ScaleDamage(0.1)
		end
	end

	--owner:FireBullets(bullet)

	local bulletInfo = {}
	local projectileInfo = self.Projectile

	bulletInfo.Attacker			= owner
	bulletInfo.Inflictor		= self
	bulletInfo.Position			= owner:GetShootPos()
	bulletInfo.Velocity			= shootAngle:Forward() * UTIL_MetersToUnits(projectileInfo.Velocity)
	bulletInfo.Mass				= projectileInfo.Mass / 15432.3584 -- Christ fucking kill me  [One kilogram has 15,432.3584 grains]
	bulletInfo.Diameter			= projectileInfo.Caliber / 25.4 -- One inch has 25.4 milimeters.
	bulletInfo.Gravity			= projectileInfo.Gravity
	bulletInfo.DragCoefficient	= projectileInfo.Drag
	bulletInfo.Initialize		= projectileInfo.Initialize
	bulletInfo.Draw				= projectileInfo.Draw
	bulletInfo.OnImpact			= projectileInfo.OnImpact

	if CLIENT and IsFirstTimePredicted() then
		BlacksCW.FireBullets(bulletInfo)
	elseif SERVER then
		net.Start("BlacksCW_NetworkBullets", true)
		net.WriteEntity(bulletInfo.Attacker)
		net.WriteEntity(bulletInfo.Inflictor)
		net.WriteVector(bulletInfo.Position)
		net.WriteNormal(bulletInfo.Velocity:GetNormalized())
		net.WriteFloat(bulletInfo.Velocity:Length())
		net.SendOmit(bulletInfo.Attacker)
	end

	self:EmitSound(self.Primary.Sound)
	self:TakePrimaryAmmo(1)
	self:CalculateNextAttackTime(self.CycleTime)
	self:SetSpreadRandomSeed(math.fmod(seed + 1, 0x7FFFFFFF))

	self:SetRecoilIndex(recoilIndex + 1)
end

function SWEP:CanSecondaryAttack()
	return false -- big gamer
end

function SWEP:SecondaryAttack()

end

function SWEP:DoDrawCrosshair(x, y)
	local owner = LocalPlayer()
	if not (IsValid(owner) and owner:Alive()) then
		return
	end

	local spreadFov = math.deg(0.01)
	local screenFov = 0.5 * math.deg(2 * math.atan((ScrW() / ScrH()) * (3 / 4) * math.tan(0.5 * math.rad(owner:GetFOV())))) --To calculate your actual fov based on your aspect ratio
	local srAngle = 180 - (90 + screenFov)
	local scrSide = ((0.5 * ScrW()) * math.sin(math.rad(srAngle))) / math.sin(math.rad(screenFov))
	local arAngle = 180 - (90 + spreadFov)
	local fixedFov = (scrSide * math.sin(math.rad(spreadFov))) / math.sin(math.rad(arAngle))
	local maxFov = math.sqrt(((0.5 * ScrW()) ^ 2) + ((0.5 * ScrH()) ^ 2))

	if (spreadFov > 0 and fixedFov <= maxFov and spreadFov <= owner:GetFOV()) then
		local eyeTrace = owner:GetEyeTrace()
		local gap = math.ceil(fixedFov)
		local color = Color(0, 255, 0, 255)
		local hitEntity = eyeTrace.Entity
		if (IsValid(hitEntity) and (hitEntity:IsPlayer() or hitEntity:IsNPC() or hitEntity:IsNextBot())) then
			color = Color(255, 0, 0)
		end

		surface.SetDrawColor(Color(0, 0, 0, 205))
		surface.DrawRect(x - 1, y - 1, 3, 3)
		surface.DrawRect((x - 1) + gap, y - 1, 8, 3)
		surface.DrawRect((x - 1) - (5 + gap), y - 1, 8, 3)
		surface.DrawRect(x - 1, (y - 1) + gap, 3, 8)
		surface.DrawRect(x - 1, (y - 1) - (5 + gap), 3, 8)

		surface.SetDrawColor(color)
		surface.DrawRect(x, y, 1, 1)
		surface.DrawRect(x + gap, y, 6, 1)
		surface.DrawRect(x - (5 + gap), y, 6, 1)
		surface.DrawRect(x, y + gap, 1, 6)
		surface.DrawRect(x, y - (5 + gap), 1, 6)
	end

	return true
end