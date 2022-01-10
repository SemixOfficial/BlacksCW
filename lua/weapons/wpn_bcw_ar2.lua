DEFINE_BASECLASS("wpn_bcw_base")

SWEP.Base           = "wpn_bcw_base"
SWEP.PrintName		= "HL2 PULSE-RIFLE"
SWEP.Author			= "BlacK"

SWEP.HoldType		= "smg"
SWEP.UseHands		= true
SWEP.ViewModelFOV	= 62
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/weapons/c_irifle.mdl"
SWEP.WorldModel		= "models/weapons/w_irifle.mdl"

SWEP.Spawnable		= true
SWEP.AdminOnly		= false

SWEP.CanChamberRound = false
SWEP.CycleTime = 60 / 600 -- RPM

SWEP.Animations = {
	Fire = "ir_fire",
	Reload = "ir_reload",
}

SWEP.Debug = {}
SWEP.Debug.Sights = false
SWEP.Debug.Attachments = false
SWEP.Debug.Bones = false

SWEP.Inaccuracy				= {}
SWEP.Inaccuracy.Crouched	= 1.35	-- Base inaccuracy when crouching. (in minutes of arc)
SWEP.Inaccuracy.Standing	= 2		-- Base inaccuracy when stood still. (in minutes of arc)
SWEP.Inaccuracy.Walking		= 120	-- How much inaccuracy the gun gains per one m/s of velocity. (in minutes of arc)
SWEP.Inaccuracy.Firing		= 1.75	-- How much inaccuracy the gun gains everytime it's fired. (in minutes of arc)
SWEP.Inaccuracy.Decay		= 0.5	-- How long it takes for this weapon to recover from it's max inaccuracy. (in seconds)
SWEP.Inaccuracy.Max			= 7.25	-- Max possible inaccuracy from firing. (in minutes of arc)
SWEP.Inaccuracy.Gaussian	= 1		-- Controls the gaussian distribution of the bullet spread, 1 is full gaussian, 0 is flat, -1 is inverse gaussian.
SWEP.Inaccuracy.Bias		= 0		-- Controlls the spread distribution across pitch and yaw, 1 will make the spread fully horizontal, 0 is uniform, -1 will make it completely vertical.

SWEP.Recoil = {}
SWEP.Recoil.RandomSeed			= 117
SWEP.Recoil.Scale				= 0.65
SWEP.Recoil.Angle				= 90
SWEP.Recoil.AngleVariance		= 20
SWEP.Recoil.Magnitude			= 20
SWEP.Recoil.MagnitudeVariance	= 0
SWEP.Recoil.MagnitudeIncrease	= 2
SWEP.Recoil.Decay				= 1
SWEP.Recoil.Decay_Treshold		= 1
SWEP.Recoil.Decay_Exponent		= 1 -- Unused (deprecated)
SWEP.Recoil.Table				= {}

function SWEP:ProjectileInit()
	self.Projectile = table.Copy(BlacksCW.BaseProjectile)
	self.Projectile.Mass        = 10    -- Grains
	self.Projectile.Drag        = 0     -- No-Unit (multiplier)
	self.Projectile.Gravity     = 0     -- Inches per second
	self.Projectile.Velocity    = 450   -- Meters per second
	self.Projectile.Caliber     = 8		-- Milimeters

	self.Projectile.Initialize	= function(proj)
		-- Called when bullet is initialized.

		proj.HeadMaterial = Material("effects/combinemuzzle1")
		proj.TracerMaterial = Material("effects/gunshiptracer")
		proj.TracerLength = 128
		proj.TracerWidth = 8
	end
	self.Projectile.OnImpact	= function(proj)
		-- Called when bullet hits a solid object.
		local effect = EffectData()
		effect:SetOrigin(proj.TraceResult.HitPos + proj.TraceResult.HitNormal)
		effect:SetNormal(proj.TraceResult.HitNormal)
		util.Effect("AR2Impact", effect)

		util.BulletImpactW(proj.TraceResult, proj.Inflictor)
	end
end

SWEP.AllowADS = true
SWEP.ADSTime = 0.15
SWEP.ADSPosition = Vector(-7.79, -8, 2.25)
SWEP.ADSAngles = Angle(0, 0, 0)
SWEP.ADSMagnification = 1

SWEP.Primary.ClipSize		= 30 -- Rounds
SWEP.Primary.DefaultClip	= 90 -- Rounds
SWEP.Primary.Damage         = 33 -- HP
SWEP.Primary.HSMultiplier   = 1.5 -- No-Unit (multiplier)
SWEP.Primary.Automatic		= true -- Self-Explanatory
SWEP.Primary.Sound          = "Weapon_AR2.Single" -- Shoot sound
SWEP.Primary.Ammo			= "AR2" -- Ammo type