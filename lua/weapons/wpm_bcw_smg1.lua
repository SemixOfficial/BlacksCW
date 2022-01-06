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
	self.Projectile = table.Copy(BaseClass.Projectile)
	self.Projectile.Mass        = 42	-- Grains
	self.Projectile.Drag        = 0.1	-- No-Unit (multiplier)
	self.Projectile.Gravity     = 800	-- Inches per second
	self.Projectile.Velocity    = 600   -- Meters per second
	self.Projectile.Caliber     = 4.6	-- Milimeters
end

SWEP.Primary.ClipSize		= 40 -- Rounds
SWEP.Primary.DefaultClip	= 160 -- Rounds
SWEP.Primary.Damage         = 18 -- HP
SWEP.Primary.HSMultiplier   = 1.5 -- No-Unit (multiplier)
SWEP.Primary.Automatic		= true -- Self-Explanatory
SWEP.Primary.Sound          = "Weapon_SMG1.Single" -- Shoot sound
SWEP.Primary.Ammo			= "AR2" -- Ammo type