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

SWEP.Debug = {}
SWEP.Debug.Sights = false
SWEP.Debug.Attachments = false
SWEP.Debug.Bones = false

SWEP.Inaccuracy				= {}
SWEP.Inaccuracy.Crouched	= 1.15	-- Base inaccuracy when crouching. (in minutes of arc)
SWEP.Inaccuracy.Standing	= 1.5	-- Base inaccuracy when stood still. (in minutes of arc)
SWEP.Inaccuracy.Walking		= 130	-- How much inaccuracy the gun gains per one m/s of velocity. (in minutes of arc)
SWEP.Inaccuracy.Firing		= 15	-- How much inaccuracy the gun gains everytime it's fired. (in minutes of arc)
SWEP.Inaccuracy.Decay		= 1.4	-- How long it takes for this weapon to recover from it's max inaccuracy. (in seconds)
SWEP.Inaccuracy.Max			= 16.5	-- Max possible inaccuracy from firing. (in minutes of arc)
SWEP.Inaccuracy.Gaussian	= 1		-- Controls the gaussian distribution of the bullet spread, 1 is full gaussian, 0 is flat, -1 is inverse gaussian.
SWEP.Inaccuracy.Bias		= 0		-- Controlls the spread distribution across pitch and yaw, 1 will make the spread fully horizontal, 0 is uniform, -1 will make it completely vertical.

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
	self.Projectile = table.Copy(BlacksCW.BaseProjectile)
	self.Projectile.Mass        = 125	-- Grains
	self.Projectile.Drag        = 0.1	-- No-Unit (multiplier)
	self.Projectile.Gravity     = 800	-- Inches per second
	self.Projectile.Velocity    = 400   -- Meters per second
	self.Projectile.Caliber     = 9.1	-- Milimeters

	self.Projectile.Initialize	= function(proj)
		-- Called when bullet is initialized.
		proj.TracerMaterial = Material("effects/spark")
		proj.HeadMaterial = Material("effects/yellowflare")
		proj.TracerLength = 128
		proj.TracerWidth = 16
	end
end


SWEP.AllowADS = false
SWEP.ADSTime = 1
SWEP.ADSPosition = Vector(0, 0, 0)
SWEP.ADSAngles = Angle(0, 0, 0)
SWEP.ADSMagnification = 1

SWEP.Primary.ClipSize		= 6 -- Rounds
SWEP.Primary.DefaultClip	= 24 -- Rounds
SWEP.Primary.Damage         = 72 -- HP
SWEP.Primary.HSMultiplier   = 2.5 -- No-Unit (multiplier)
SWEP.Primary.Automatic		= true -- Self-Explanatory
SWEP.Primary.Sound          = "Weapon_357.Single" -- Shoot sound
SWEP.Primary.Ammo			= "357" -- Ammo type