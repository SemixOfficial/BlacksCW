-- AddCSLuaFile()
-- DEFINE_BASECLASS("weapon_base")

-- SWEP.PrintName		= "Scripted Weapon"
-- SWEP.Author			= "BlacK"
-- SWEP.IsBCWWeapon	= true

-- SWEP.HoldType		= "ar2"
-- SWEP.UseHands		= true
-- SWEP.BobScale		= 1
-- SWEP.SwayScale		= 1
-- SWEP.ViewModelFOV	= 62
-- SWEP.ViewModelFlip	= false
-- SWEP.ViewModel		= "models/weapons/v_pistol.mdl"
-- SWEP.WorldModel		= "models/weapons/w_357.mdl"

-- SWEP.Spawnable		= false
-- SWEP.AdminOnly		= false

-- SWEP.Debug = {}
-- SWEP.Debug.Sights = false
-- SWEP.Debug.Attachments = false
-- SWEP.Debug.Bones = false

-- SWEP.Inaccuracy				= {}
-- SWEP.Inaccuracy.Crouched	= 0.5	-- Base inaccuracy when crouching. (in minutes of arc)
-- SWEP.Inaccuracy.Standing	= 1		-- Base inaccuracy when stood still. (in minutes of arc)
-- SWEP.Inaccuracy.Walking		= 1		-- How much inaccuracy the gun gains per one m/s of velocity. (in minutes of arc)
-- SWEP.Inaccuracy.Firing		= 0.5	-- How much inaccuracy the gun gains everytime it's fired. (in minutes of arc)
-- SWEP.Inaccuracy.Decay		= 1		-- How long it takes for this weapon to recover from it's max inaccuracy. (in seconds)
-- SWEP.Inaccuracy.Max			= 3		-- Max possible inaccuracy from firing. (in minutes of arc)
-- SWEP.Inaccuracy.Gaussian	= 1		-- Controls the gaussian distribution of the bullet spread, 1 is full gaussian, 0 is flat, -1 is inverse gaussian.
-- SWEP.Inaccuracy.Bias		= 0		-- Controlls the spread distribution across pitch and yaw, 1 will make the spread fully horizontal, 0 is uniform, -1 will make it completely vertical.

-- SWEP.Primary.ClipSize		= 30
-- SWEP.Primary.DefaultClip	= 90
-- SWEP.Primary.Automatic		= true
-- SWEP.Primary.Ammo			= "Pistol"

-- SWEP.Secondary.ClipSize		= -1
-- SWEP.Secondary.DefaultClip	= 0
-- SWEP.Secondary.Automatic	= false
-- SWEP.Secondary.Ammo			= "none"

-- SWEP.Projectile = {}
-- SWEP.Projectile.Mass        = 1	-- Grains
-- SWEP.Projectile.Drag        = 0.3	-- No-Unit (multiplier)
-- SWEP.Projectile.Gravity     = 800	-- Inches per second
-- SWEP.Projectile.Velocity    = 400   -- Meters per second
-- SWEP.Projectile.Caliber     = 9	-- Milimeters

-- SWEP.Projectile.Initialize	= function(self)
-- 	-- Called when bullet is initialized.
-- 	self.TracerMaterial = Material("effects/spark")
-- 	self.HeadMaterial = Material("effects/yellowflare")
-- 	self.TracerLength = 128
-- 	self.TracerWidth = 8
-- end

-- SWEP.Projectile.Draw		= function(self)
-- 	-- do not render for the first 10ms, to prevent bullets in ur eyeballs!
-- 	if (self.Attacker == LocalPlayer() and not self.Attacker:ShouldDrawLocalPlayer()) and self.CreationTime + 0.010 > BlacksCW.CurrentTime then
-- 		return
-- 	end

-- 	local heading = self.Velocity:GetNormalized()

-- 	-- Called every frame when bullet is about to be drawn.
-- 	render.SetMaterial(self.TracerMaterial)
-- 	render.DrawBeam(self.Position, self.Position - heading * 128, self.TracerWidth, 1, 0, color_white)

-- 	local bulletDir = self.Position - (self.Position - heading * 128)

-- 	local degAway = 90 - math.abs(math.deg(math.asin(bulletDir:Dot(EyeAngles():Forward()) / bulletDir:Length())))

-- 	local w = (self.TracerWidth * 2) * (math.max(15 - degAway, 0) / 15)
-- 	local h = (self.TracerWidth * 2) * (math.max(15 - degAway, 0) / 15)

-- 	render.SetMaterial(self.HeadMaterial)
-- 	render.DrawSprite(self.Position, w, h, color_white)
-- end
-- SWEP.Projectile.OnImpact	= function(self)
-- 	-- Called when bullet hits a solid object.
-- 	util.BulletImpactW(self.TraceResult, self.Attacker)
-- end

-- function SWEP:Initialize()
-- 	self:SetSpreadRandomSeed(0)
-- 	self:SetHoldType(self.HoldType)
-- 	self:GenerateRecoilTable()

-- 	self:ProjectileInit()
-- end

-- function SWEP:ProjectileInit()
-- end

-- function SWEP:SetupDataTables()
-- 	self:NetworkVar("Float", 0, "NextIdleTime")
-- 	self:NetworkVar("Float", 1, "ReloadFinishTime")
-- 	self:NetworkVar("Float", 2, "RecoilIndex")
-- 	self:NetworkVar("Float", 3, "ADSDelta")
-- 	self:NetworkVar("Float", 4, "AccuracyPenalty")

-- 	self:NetworkVar("Bool", 0, "IsReloading")

-- 	self:NetworkVar("Int", 0, "SpreadRandomSeed")

-- 	self:SetRecoilIndex(1)
-- end

-- function SWEP:Holster()
-- 	self:SetIsReloading(false)
-- 	self:SetReloadFinishTime(0)

-- 	return true
-- end

-- function SWEP:IdleThink()
-- 	if self:GetNextIdleTime() == 0 or CurTime() <= self:GetNextIdleTime() then
-- 		return
-- 	end

-- 	self:SendWeaponAnim(ACT_VM_IDLE)
-- 	self:SetNextIdleTime(0)
-- end

-- function SWEP:ADSThink()
-- 	local owner = self:GetOwner()
-- 	local currentDelta = self:GetADSDelta()
-- 	local deltaChange = (1 / self.ADSTime) * FrameTime()
-- 	local flip = Either(owner:KeyDown(IN_ATTACK2), 1, -1)

-- 	currentDelta = math.Clamp(currentDelta + (deltaChange * flip), 0, 1)

-- 	self:SetADSDelta(currentDelta)
-- end

-- function SWEP:UpdateAccuracyPenalty()
-- 	local penalty = self:GetAccuracyPenalty()
-- 	local decreaseAmount = (self.Inaccuracy.Max / self.Inaccuracy.Decay) * FrameTime()

-- 	self:SetAccuracyPenalty(math.max(penalty - decreaseAmount, 1))
-- end

-- function SWEP:RecoilThink()
-- 	if self:GetNextPrimaryFire() > CurTime() - (self.CycleTime * self.Recoil.Decay_Treshold) then
-- 		return
-- 	end

-- 	local recoilIndex = self:GetRecoilIndex()
-- 	local decreaseMagnitude = self.Recoil.Decay -- + (recoilIndex / #self.Recoil.Table) ^ self.Recoil.Decay_Exponent
-- 	local decreaseAmount = (decreaseMagnitude / self.CycleTime) * FrameTime()

-- 	self:SetRecoilIndex(math.max(recoilIndex - decreaseAmount, 1))
-- end

-- function SWEP:Think()
-- 	local owner = self:GetOwner()

-- 	if self:GetIsReloading() then
-- 		if CurTime() > self:GetReloadFinishTime() then

-- 			local clip = self:Clip1()
-- 			local maxclip = self:GetMaxClip1()
-- 			local dif = self:GetMaxClip1() - self:Clip1()
-- 			local amt = math.min(self:Clip1() + owner:GetAmmoCount(self.Primary.Ammo), self:GetMaxClip1())
-- 			if self.CanChamberRound ~= false and dif ~= self:GetMaxClip1() then
-- 				dif = 1
-- 				amt = amt + 1
-- 			end

-- 			self:SetClip1(amt)
-- 			owner:RemoveAmmo(dif, self.Primary.Ammo)
-- 			self:SetIsReloading(false)
-- 			self:SetRecoilIndex(1)
-- 		end
-- 	end

-- 	self:UpdateAccuracyPenalty()
-- 	self:RecoilThink()
-- 	self:ADSThink()
-- end

-- function SWEP:Reload()
-- 	local owner = self:GetOwner()
-- 	local viewmodel = owner:GetViewModel()

-- 	if owner:GetAmmoCount(self.Primary.Ammo) == 0 then
-- 		return
-- 	end

-- 	local extra = 1
-- 	if self.CanChamberRound == false then
-- 		extra = 0
-- 	end

-- 	if self:GetIsReloading() or self:Clip1() >= (self:GetMaxClip1() + extra) then
-- 		return
-- 	end

-- 	local sequence = "Reload"
-- 	if self.Animations.Reload_Empty and self:Clip1() == 0 then
-- 		sequence = "Reload_Empty"
-- 	elseif self.Animations.Reload_Start then
-- 		sequence = "Reload_Start"
-- 	end

-- 	self:SetIsReloading(true)
-- 	self:PlayAnimation(sequence, 1)
-- 	owner:SetAnimation(PLAYER_RELOAD)

-- 	local sequenceDuration = viewmodel:SequenceDuration()
-- 	self:SetReloadFinishTime(CurTime() + sequenceDuration)
-- 	self:CalculateNextAttackTime(sequenceDuration)
-- end

-- -- function SWEP:GenerateRecoilTable()
-- -- 	local recoilIncrease = Angle(25, 1.5, 0)
-- -- 	local recoilVelocity = Angle(0, 0, 0)
-- -- 	local recoilVariance = 0.5
-- -- 	local recoilDeviation = 15
-- -- 	local recoilExponent = 0.5

-- -- 	local recoilSeed = self.Recoil.RandomSeed
-- -- 	local magazineCapacity = self:GetMaxClip1()
-- -- 	local recoilAngle = Angle(0, 0, 0)

-- -- 	local recoilTableSize = self:GetMaxClip1() + 1

-- -- 	math.randomseed(recoilSeed)
-- -- 	while #self.Recoil.Table < recoilTableSize do

-- -- 		local herkz = #self.Recoil.Table / recoilTableSize

-- -- 		recoilAngle = recoilAngle + (recoilVelocity / magazineCapacity)
-- -- 		recoilAngle:Normalize()

-- -- 		recoilVelocity = recoilVelocity - (recoilIncrease / magazineCapacity)
-- -- 		recoilVelocity:Normalize()

-- -- 		recoilIncrease.y = recoilIncrease.y + recoilDeviation
-- -- 		recoilIncrease:Normalize()

-- -- 		if math.Rand(0, 1) < recoilVariance then
-- -- 			recoilDeviation = recoilDeviation * -math.Rand(1, 2)
-- -- 		end

-- -- 		table.insert(self.Recoil.Table, recoilAngle)
-- -- 	end
-- -- end

-- local WPN_RECOIL_VARIANCE = 0.55
-- local WPN_RECOIL_SUPPRESSION_SHOTS = 4
-- local WPN_RECOIL_SUPPRESSION_FACTOR = 0.75
-- function SWEP:GenerateRecoilTable()
-- 	math.randomseed(self.Recoil.RandomSeed)
-- 	local mode = self.Primary.Automatic
-- 	local recoilAngle = self.Recoil.Angle
-- 	local recoilAngleVariance = self.Recoil.AngleVariance
-- 	local recoilMagnitude = self.Recoil.Magnitude
-- 	local recoilMagnitudeVariance = self.Recoil.MagnitudeVariance
-- 	local recoilMagnitudeIncrease = self.Recoil.MagnitudeIncrease

-- 	for j = 1, self:GetMaxClip1() + 1 do
-- 		local newAngle = recoilAngle + math.Rand(-recoilAngleVariance, recoilAngleVariance)
-- 		local newMagnitude = recoilMagnitude + recoilMagnitudeIncrease + math.Rand(-recoilMagnitudeVariance, recoilMagnitudeVariance)

-- 		if (mode and (j > 1)) then
-- 			recoilAngle = Lerp(WPN_RECOIL_VARIANCE, recoilAngle, newAngle)
-- 			recoilMagnitude = Lerp(WPN_RECOIL_VARIANCE, recoilMagnitude, newMagnitude)
-- 		else
-- 			recoilAngle = newAngle
-- 			recoilMagnitude = newMagnitude
-- 		end

-- 		if (mode and (j < WPN_RECOIL_SUPPRESSION_SHOTS)) then
-- 			local suppressionFactor = Lerp(j / WPN_RECOIL_SUPPRESSION_SHOTS, WPN_RECOIL_SUPPRESSION_FACTOR, 1.0)
-- 			recoilMagnitude = recoilMagnitude * suppressionFactor
-- 		end

-- 		table.insert(self.Recoil.Table, Angle(
-- 			-math.sin(math.rad(recoilAngle)) * recoilMagnitude,
-- 			-math.cos(math.rad(recoilAngle)) * recoilMagnitude, 0))
-- 	end
-- end

-- function SWEP:GetCone()
-- 	local owner = self:GetOwner()
-- 	local inaccuracy = self.Inaccuracy.Standing

-- 	-- TODO: lerp between standing accuracy and crouched accuracy based on CBasePlayer->m_flDuckAmount?
-- 	if owner:Crouching() then
-- 		inaccuracy = self.Inaccuracy.Crouched
-- 	end

-- 	local velocity = owner:GetAbsVelocity():Length()
-- 	-- Add movement inaccuracy
-- 	inaccuracy = inaccuracy + self.Inaccuracy.Walking * UTIL_UnitsToMeters(velocity) * FrameTime()
-- 	-- Add firing inaccuracy
-- 	inaccuracy = inaccuracy + self:GetAccuracyPenalty()
-- 	-- Convert inaccuracy from minutes of arc to Source engine's tangent accuracy shit number thing (idfk)
-- 	inaccuracy = math.tan(math.deg(inaccuracy / 180 / 60))

-- 	local bias = self.Inaccuracy.Bias
-- 	local x = inaccuracy * math.Remap(bias, -1, 1, 0, 1)
-- 	local y = inaccuracy * math.Remap(bias, 1, -1, 0, 1)

-- 	return Vector(x, y, 0)
-- end

-- local AI_SHOT_BIAS_MIN = -1
-- local AI_SHOT_BIAS_MAX = 1
-- function SWEP:GetSpreadVector(direction, spread)
-- 	local x, y, z = 0, 0, 0
-- 	local angles = direction:Angle()
-- 	local bias = math.Remap(self.Inaccuracy.Gaussian, -1, 1, 0, 1)
-- 	local shotBias = ((AI_SHOT_BIAS_MAX - AI_SHOT_BIAS_MIN) * bias) + AI_SHOT_BIAS_MIN;
-- 	local flatness = math.abs(shotBias) * 0.5

-- 	repeat
-- 			x = math.Rand(-1,1) * flatness + math.Rand(-1,1) * (1 - flatness);
-- 			y = math.Rand(-1,1) * flatness + math.Rand(-1,1) * (1 - flatness);

-- 			if shotBias < 0 then
-- 				x = Either(x >= 0, 1.0 - x, -1.0 - x)
-- 				y = Either(y >= 0, 1.0 - y, -1.0 - y)
-- 			end

-- 			z = x * x + y * y;
-- 	until (z <= 1);

-- 	return angles:Forward() + (angles:Right() * x * spread.x) + (angles:Up() * y * spread.y)
-- end

-- function SWEP:DoDrawCrosshair(x, y)
-- 	local owner = LocalPlayer()
-- 	if not (IsValid(owner) and owner:Alive()) then
-- 		return
-- 	end

-- 	if self.Debug.Sights then
-- 		surface.SetDrawColor(color_white)
-- 		local w, h = ScrW(), ScrH()
-- 		local x, y = w * 0.5, h * 0.5
-- 		surface.DrawLine(x, 0, x, h)
-- 		surface.DrawLine(0, y, w, y)
-- 	end

-- 	local cone = self:GetCone()
-- 	local spreadFov = math.deg(math.atan((cone.x + cone.y) * 0.5))
-- 	local screenFov = 0.5 * math.deg(2 * math.atan((ScrW() / ScrH()) * (3 / 4) * math.tan(0.5 * math.rad(owner:GetFOV())))) --To calculate your actual fov based on your aspect ratio
-- 	local srAngle = 180 - (90 + screenFov)
-- 	local scrSide = ((0.5 * ScrW()) * math.sin(math.rad(srAngle))) / math.sin(math.rad(screenFov))
-- 	local arAngle = 180 - (90 + spreadFov)
-- 	local fixedFov = (scrSide * math.sin(math.rad(spreadFov))) / math.sin(math.rad(arAngle))
-- 	local maxFov = math.sqrt(((0.5 * ScrW()) ^ 2) + ((0.5 * ScrH()) ^ 2))

-- 	if (spreadFov > 0 and fixedFov <= maxFov and spreadFov <= owner:GetFOV()) then
-- 		local gap = math.ceil(fixedFov)

-- 		surface.SetDrawColor(Color(0, 0, 0, 205))
-- 		surface.DrawRect(x - 1, y - 1, 3, 3)
-- 		surface.DrawRect((x - 1) + gap, y - 1, 8, 3)
-- 		surface.DrawRect((x - 1) - (5 + gap), y - 1, 8, 3)
-- 		surface.DrawRect(x - 1, (y - 1) + gap, 3, 8)
-- 		surface.DrawRect(x - 1, (y - 1) - (5 + gap), 3, 8)

-- 		surface.SetDrawColor(Color(137, 255, 34, 255))
-- 		surface.DrawRect(x, y, 1, 1)
-- 		surface.DrawRect(x + gap, y, 6, 1)
-- 		surface.DrawRect(x - (5 + gap), y, 6, 1)
-- 		surface.DrawRect(x, y + gap, 1, 6)
-- 		surface.DrawRect(x, y - (5 + gap), 1, 6)

-- 	end

-- 	return true
-- end

-- function SWEP:IsAbleToUseRTPIPScope()
-- 	-- FIXME: "Render-Target Picture in Picture scope" is such a fucking long phrase, can we just call it R-T PiP scopes... or dynamic scopes? OR JNUS SOMETHING ELSE?!!!
-- 	-- CURIOSITY: ^ Who came up with this name? ^
-- 	-- Only draw Render Target Picture in Picture scopes if we have a DirectX 7 capable card (lower versions are not supported :C).
-- 	return render.GetDXLevel() >= 70 -- TODO: check if the user wants to use render target picture in picture scopes in the first place.
-- end
