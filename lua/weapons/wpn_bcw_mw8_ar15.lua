DEFINE_BASECLASS("wpn_bcw_base")

SWEP.Base           = "wpn_bcw_base"
SWEP.PrintName		= "XRK M4"
SWEP.Author			= "BlacK"

SWEP.HoldType		= "ar2"
SWEP.UseHands		= true
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
	Reload_Empty = "reload_2"
}

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

SWEP.Projectile.Mass        = 42	-- Grains
SWEP.Projectile.Drag        = 0.1	-- No-Unit (multiplier)
SWEP.Projectile.Gravity     = 800	-- Inches per second
SWEP.Projectile.Velocity    = 600   -- Meters per second
SWEP.Projectile.Caliber     = 4.6	-- Milimeters

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