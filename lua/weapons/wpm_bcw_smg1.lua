DEFINE_BASECLASS("wpn_bcw_base")

SWEP.Base           = "wpn_bcw_base"
SWEP.PrintName		= "HL2 SMG"
SWEP.Author			= "BlacK"

SWEP.HoldType		= "smg"
SWEP.UseHands		= true
SWEP.ViewModelFOV	= 62
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/weapons/c_smg1.mdl"
SWEP.WorldModel		= "models/weapons/w_smg1.mdl"

SWEP.Spawnable		= true
SWEP.AdminOnly		= false

SWEP.CycleTime = 60 / 950 -- RPM

SWEP.Animations = {
	Fire = "fire01",
	DryFire = "fire04",
	Reload = "reload",
}

SWEP.Debug = {}
SWEP.Debug.Sights = false
SWEP.Debug.Attachments = false
SWEP.Debug.Bones = false

SWEP.Inaccuracy				= {}
SWEP.Inaccuracy.Crouched	= 5.5	-- Base inaccuracy when crouching. (in minutes of arc)
SWEP.Inaccuracy.Standing	= 6		-- Base inaccuracy when stood still. (in minutes of arc)
SWEP.Inaccuracy.Walking		= 100	-- How much inaccuracy the gun gains per one m/s of velocity. (in minutes of arc)
SWEP.Inaccuracy.Firing		= 0.5	-- How much inaccuracy the gun gains everytime it's fired. (in minutes of arc)
SWEP.Inaccuracy.Decay		= 2.6	-- How long it takes for this weapon to recover from it's max inaccuracy. (in seconds)
SWEP.Inaccuracy.Max			= 8.5	-- Max possible inaccuracy from firing. (in minutes of arc)
SWEP.Inaccuracy.Gaussian	= 1		-- Controls the gaussian distribution of the bullet spread, 1 is full gaussian, 0 is flat, -1 is inverse gaussian.
SWEP.Inaccuracy.Bias		= 0		-- Controlls the spread distribution across pitch and yaw, 1 will make the spread fully horizontal, 0 is uniform, -1 will make it completely vertical.

SWEP.Recoil = {}
SWEP.Recoil.RandomSeed = 90
SWEP.Recoil.Scale = 0.75
SWEP.Recoil.Angle = 90
SWEP.Recoil.AngleVariance = 30
SWEP.Recoil.Magnitude = 10
SWEP.Recoil.MagnitudeVariance = 0
SWEP.Recoil.MagnitudeIncrease = 1
SWEP.Recoil.Decay = 1
SWEP.Recoil.Decay_Treshold = 1
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
SWEP.ADSPosition = Vector(-6.415, -8, 1.03)
SWEP.ADSAngles = Angle(0, 0, 0)
SWEP.ADSMagnification = 1.5

SWEP.Primary.ClipSize		= 40 -- Rounds
SWEP.Primary.DefaultClip	= 160 -- Rounds
SWEP.Primary.Damage         = 18 -- HP
SWEP.Primary.HSMultiplier   = 1.5 -- No-Unit (multiplier)
SWEP.Primary.Automatic		= true -- Self-Explanatory
SWEP.Primary.Sound          = "Weapon_SMG1.Single" -- Shoot sound
SWEP.Primary.Ammo			= "AR2" -- Ammo type