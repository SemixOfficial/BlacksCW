DEFINE_BASECLASS("wpn_bcw_base")

SWEP.Base           = "wpn_bcw_base"
SWEP.PrintName		= "XRK M4"
SWEP.Author			= "BlacK"

SWEP.HoldType		= "ar2"
SWEP.UseHands		= true
SWEP.BobScale		= 1
SWEP.SwayScale		= 2
SWEP.ViewModelFOV	= 62
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/weapons/v_rif_mw8_peacemaker.mdl"
SWEP.WorldModel		= "models/weapons/w_rif_mw8_peacemaker.mdl"

SWEP.Spawnable		= true
SWEP.AdminOnly		= false

SWEP.CycleTime = 60 / 857 -- RPM

SWEP.Animations = {
	Fire = "fire",
	Reload = "reload_1",
	Reload_Empty = "reload_2",
}
SWEP.UsesProceduralSprintAnimation = false

SWEP.Debug = {}
SWEP.Debug.Sights = false
SWEP.Debug.Attachments = false
SWEP.Debug.Bones = false

SWEP.Inaccuracy				= {}
SWEP.Inaccuracy.Crouched	= 2.45	-- Base inaccuracy when crouching. (in minutes of arc)
SWEP.Inaccuracy.Standing	= 3		-- Base inaccuracy when stood still. (in minutes of arc)
SWEP.Inaccuracy.Walking		= 75	-- How much inaccuracy the gun gains per one m/s of velocity. (in minutes of arc)
SWEP.Inaccuracy.Firing		= 1.5	-- How much inaccuracy the gun gains everytime it's fired. (in minutes of arc)
SWEP.Inaccuracy.Decay		= 0.5	-- How long it takes for this weapon to recover from it's max inaccuracy. (in seconds)
SWEP.Inaccuracy.Max			= 8.5	-- Max possible inaccuracy from firing. (in minutes of arc)
SWEP.Inaccuracy.Gaussian	= 1		-- Controls the gaussian distribution of the bullet spread, 1 is full gaussian, 0 is flat, -1 is inverse gaussian.
SWEP.Inaccuracy.Bias		= 0		-- Controlls the spread distribution across pitch and yaw, 1 will make the spread fully horizontal, 0 is uniform, -1 will make it completely vertical.

SWEP.Recoil = {}
SWEP.Recoil.RandomSeed = 225
SWEP.Recoil.Scale = 0.75
SWEP.Recoil.Angle = 100
SWEP.Recoil.AngleVariance = -10
SWEP.Recoil.Magnitude = 10
SWEP.Recoil.MagnitudeVariance = 0.1
SWEP.Recoil.MagnitudeIncrease = 2.5
SWEP.Recoil.Decay = 1
SWEP.Recoil.Decay_Treshold = 1.1
SWEP.Recoil.Decay_Exponent = 1
SWEP.Recoil.Table = {}

function SWEP:ProjectileInit()
	self.Projectile = table.Copy(BlacksCW.BaseProjectile)
	self.Projectile.Mass        = 42	-- Grains
	self.Projectile.Drag        = 0.1	-- No-Unit (multiplier)
	self.Projectile.Gravity     = 800	-- Inches per second
	self.Projectile.Velocity    = 600   -- Meters per second
	self.Projectile.Caliber     = 4.6	-- Milimeters
end

SWEP.AllowADS = true
SWEP.ADSTime = 0.15
SWEP.ADSPosition = Vector(-7.79, -8, 2.25)
SWEP.ADSAngles = Angle(0, 0, 0)
SWEP.ADSMagnification = 1.5

SWEP.Primary.ClipSize		= 30 -- Rounds
SWEP.Primary.DefaultClip	= 90 -- Rounds
SWEP.Primary.Damage         = 24 -- HP
SWEP.Primary.Caliber        = 5.56 -- Milimeters
SWEP.Primary.MuzzleVelocity = 715 -- Meters per second
SWEP.Primary.ProjectileMass = 62 -- Grains
SWEP.Primary.HSMultiplier   = 2.25 -- No-Unit
SWEP.Primary.Automatic		= true -- Self-Explanatory
SWEP.Primary.Sound          = "Mike4.Single" -- Shoot sound
SWEP.Primary.Ammo			= "AR2" -- Ammo type

sound.Add({
	name = "Mike4.Single",
	channel = CHAN_WEAPON,
	volume = 1.0,
	pitch = 100,
	sound = ")weapons/iw8/mike4/fire.wav"
})

sound.Add({
	name = "Mike4.Deploy",
	channel = CHAN_ITEM,
	volume = 1.0,
	pitch = 100,
	sound = "weapons/iw8/mike4/deploy.wav"
})

sound.Add({
	name = "Mike4.SlideBack",
	channel = CHAN_ITEM,
	volume = 1.0,
	pitch = 100,
	sound = "weapons/iw8/mike4/slideback.wav"
})

sound.Add({
	name = "Mike4.SlideForward",
	channel = CHAN_ITEM,
	volume = 1.0,
	pitch = 100,
	sound = "weapons/iw8/mike4/slideforward.wav"
})

sound.Add({
	name = "Mike4.Lift",
	channel = CHAN_ITEM,
	volume = 1.0,
	pitch = 100,
	sound = "weapons/iw8/mike4/wpfoly_mike4_reload_lift_v2.wav"
})

sound.Add({
	name = "Mike4.Magout_Empty",
	channel = CHAN_ITEM,
	volume = 1.0,
	pitch = 100,
	sound = "weapons/iw8/mike4/wpfoly_mike4_reload_empty_magout_v2.wav"
})

sound.Add({
	name = "Mike4.Magin_Empty",
	channel = CHAN_ITEM,
	volume = 1.0,
	pitch = 100,
	sound = "weapons/iw8/mike4/wpfoly_mike4_reload_empty_magin_v2_02.wav"
})

sound.Add({
	name = "Mike4.Chamber",
	channel = CHAN_ITEM,
	volume = 1.0,
	pitch = 100,
	sound = "weapons/iw8/mike4/wpfoly_mike4_reload_empty_chamber_v2.wav"
})

sound.Add({
	name = "Mike4.ReloadEnd_Empty",
	channel = CHAN_ITEM,
	volume = 1.0,
	pitch = 100,
	sound = "weapons/iw8/mike4/wpfoly_mike4_reload_empty_end_v2.wav"
})

sound.Add({
	name = "Mike4.Magin",
	channel = CHAN_ITEM,
	volume = 1.0,
	pitch = 100,
	sound = "weapons/iw8/mike4/wpfoly_mike4_reload_magin_v2_01.wav"
})

sound.Add({
	name = "Mike4.Magout",
	channel = CHAN_ITEM,
	volume = 1.0,
	pitch = 100,
	sound = "weapons/iw8/mike4/wpfoly_mike4_reload_magout_v2.wav"
})

sound.Add({
	name = "Mike4.ReloadEnd",
	channel = CHAN_ITEM,
	volume = 1.0,
	pitch = 100,
	sound = "weapons/iw8/mike4/wpfoly_mike4_reload_end_v2.wav"
})

-- "reload1"
-- {
-- 	"channel"		"CHAN_ITEM"
-- 	"volume"		"1.0"
-- 	"CompatibilityAttenuation"	"1.0"
-- 	"pitch"		"PITCH_NORM"

-- 	"wave"			"weapons\iw8\mike4\reload1.wav"

-- }

-- "reload2"
-- {
-- 	"channel"		"CHAN_ITEM"
-- 	"volume"		"1.0"
-- 	"CompatibilityAttenuation"	"1.0"
-- 	"pitch"		"PITCH_NORM"

-- 	"wave"			"weapons\iw8\mike4\reload2.wav"

-- }

-- "reload3"
-- {
-- 	"channel"		"CHAN_ITEM"
-- 	"volume"		"1.0"
-- 	"CompatibilityAttenuation"	"1.0"
-- 	"pitch"		"PITCH_NORM"

-- 	"wave"			"weapons\iw8\mike4\reload3.wav"

-- }