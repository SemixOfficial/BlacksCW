DEFINE_BASECLASS("wpn_bcw_base")

SWEP.Base           = "wpn_bcw_base"
SWEP.PrintName		= "HL2 Shotgun"
SWEP.Author			= "BlacK"

SWEP.HoldType		= "shotgun"
SWEP.UseHands		= true
SWEP.BobScale		= 1
SWEP.SwayScale		= 2
SWEP.ViewModelFOV	= 62
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/weapons/c_shotgun.mdl"
SWEP.WorldModel		= "models/weapons/w_shotgun.mdl"

SWEP.Spawnable		= true
SWEP.AdminOnly		= false

SWEP.CycleTime = 60 / 600 -- RPM

SWEP.Animations = {
	["Fire"] = {
		Sequence = "fire01",
		Animation = PLAYER_ATTACK1,
		Activity = ACT_VM_PRIMARYATTACK,
		PlaybackRate = 2
	},
	["Prime"] = {
		Sequence = "pump",
		Animation = PLAYER_RELOAD,
		Activity = ACT_INVALID,
		PlaybackRate = 1.25
	},
	["Reload Start"] = {
		Sequence = "reload1",
		Animation = PLAYER_RELOAD,
		Activity = ACT_VM_RELOAD,
		PlaybackRate = 1
	},
	["Reload Loop"] = {
		Sequence = "reload2",
		Animation = PLAYER_RELOAD,
		Activity = ACT_VM_RELOAD,
		PlaybackRate = 1
	},
	["Reload End"] = {
		Sequence = "reload3",
		Animation = PLAYER_RELOAD,
		Activity = ACT_VM_RELOAD,
		PlaybackRate = 1
	}
}

SWEP.Debug = {}
SWEP.Debug.Sights = false
SWEP.Debug.Attachments = false
SWEP.Debug.Bones = false

SWEP.Inaccuracy				= {}
SWEP.Inaccuracy.Crouched	= 10	-- Base inaccuracy when crouching. (in minutes of arc)
SWEP.Inaccuracy.Standing	= 12	-- Base inaccuracy when stood still. (in minutes of arc)
SWEP.Inaccuracy.Walking		= 30	-- How much inaccuracy the gun gains per one m/s of velocity. (in minutes of arc)
SWEP.Inaccuracy.Firing		= 20.5	-- How much inaccuracy the gun gains everytime it's fired. (in minutes of arc)
SWEP.Inaccuracy.Decay		= 0.5	-- How long it takes for this weapon to recover from it's max inaccuracy. (in seconds)
SWEP.Inaccuracy.Scoped		= 0.33	-- Inaccuracy multiplier for when aiming down the sights.
SWEP.Inaccuracy.Max			= 8.5	-- Max possible inaccuracy from firing. (in minutes of arc)
SWEP.Inaccuracy.Gaussian	= 1		-- Controls the gaussian distribution of the bullet spread, 1 is full gaussian, 0 is flat, -1 is inverse gaussian.
SWEP.Inaccuracy.Bias		= 0		-- Controlls the spread distribution across pitch and yaw, 1 will make the spread fully horizontal, 0 is uniform, -1 will make it completely vertical.

SWEP.Recoil = {}
SWEP.Recoil.RandomSeed = 738
SWEP.Recoil.Scale = 1
SWEP.Recoil.Angle = 85
SWEP.Recoil.AngleVariance = -30
SWEP.Recoil.Magnitude = 40
SWEP.Recoil.MagnitudeVariance = 5
SWEP.Recoil.MagnitudeIncrease = 3.5
SWEP.Recoil.Decay = 0.9
SWEP.Recoil.Decay_Treshold = 1.1
SWEP.Recoil.Decay_Exponent = 1
SWEP.Recoil.Table = {}

function SWEP:ProjectileInit()
	self.Projectile = table.Copy(BlacksCW.BaseProjectile)
	self.Projectile.Mass        = 53.8	-- Grains
	self.Projectile.Drag        = 0.2	-- No-Unit (multiplier)
	self.Projectile.Gravity     = 800	-- Inches per second
	self.Projectile.Velocity    = 365.7	-- Meters per second
	self.Projectile.Caliber     = 2.6	-- Milimeters
	self.Projectile.Count		= 9		-- Amount of projectiles lol
end

SWEP.AllowADS = false
SWEP.ADSTime = 1
SWEP.ADSPosition = Vector(0, 0, 0)
SWEP.ADSAngles = Angle(0, 0, 0)
SWEP.ADSMagnification = 1

SWEP.Primary.ClipSize		= 8		-- Rounds
SWEP.Primary.DefaultClip	= 32	-- Rounds
SWEP.Primary.Damage         = 8		-- HP
SWEP.Primary.HSMultiplier   = 1.5	-- No-Unit
SWEP.Primary.Automatic		= false	-- Self-Explanatory
SWEP.Primary.ManualAction	= true	-- Do we need to prime this gun after every shot?
SWEP.Primary.ChamberSize	= 0
SWEP.Primary.Sound          = "Weapon_Shotgun.Single" -- Shoot sound
SWEP.Primary.Ammo			= "Buckshot" -- Ammo type