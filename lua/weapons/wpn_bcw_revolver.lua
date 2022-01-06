DEFINE_BASECLASS("wpn_bcw_base")

SWEP.Base           = "wpn_bcw_base"
SWEP.PrintName		= "HL2 Revolver"
SWEP.Author			= "BlacK"

SWEP.HoldType		= "revolver"
SWEP.UseHands		= true
SWEP.ViewModelFOV	= 62
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/weapons/c_357.mdl"
SWEP.WorldModel		= "models/weapons/w_357.mdl"

SWEP.Spawnable		= true
SWEP.AdminOnly		= false


SWEP.CanChamberRound = false
SWEP.CycleTime = 60 / 80 -- RPM

SWEP.Animations = {
	Fire = "fire",
	Reload = "reload",
}

SWEP.Recoil = {}
SWEP.Recoil.RandomSeed = 357
SWEP.Recoil.Scale = 1
SWEP.Recoil.Angle = 90
SWEP.Recoil.AngleVariance = 65
SWEP.Recoil.Magnitude = 100
SWEP.Recoil.MagnitudeVariance = 0
SWEP.Recoil.MagnitudeIncrease = 1
SWEP.Recoil.Decay = 1
SWEP.Recoil.Decay_Treshold = 1.25
SWEP.Recoil.Decay_Exponent = 1
SWEP.Recoil.Table = {}

function SWEP:ProjectileInit()
	self.Projectile = table.Copy(BaseClass.Projectile)
	self.Projectile.Mass        = 125	-- Grains
	self.Projectile.Drag        = 0.1	-- No-Unit (multiplier)
	self.Projectile.Gravity     = 800	-- Inches per second
	self.Projectile.Velocity    = 440   -- Meters per second
	self.Projectile.Caliber     = 9.1	-- Milimeters

	self.Projectile.Initialize	= function(proj)
		-- Called when bullet is initialized.
		proj.TracerMaterial = Material("effects/spark")
		proj.HeadMaterial = Material("effects/yellowflare")
		proj.TracerLength = 128
		proj.TracerWidth = 16
	end
end

SWEP.Primary.ClipSize		= 6 -- Rounds
SWEP.Primary.DefaultClip	= 24 -- Rounds
SWEP.Primary.Damage         = 72 -- HP
SWEP.Primary.HSMultiplier   = 2.5 -- No-Unit (multiplier)
SWEP.Primary.Automatic		= true -- Self-Explanatory
SWEP.Primary.Sound          = "Weapon_357.Single" -- Shoot sound
SWEP.Primary.Ammo			= "357" -- Ammo type