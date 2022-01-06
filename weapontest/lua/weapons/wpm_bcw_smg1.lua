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
SWEP.Recoil.Angle = 60
SWEP.Recoil.AngleVariance = 30
SWEP.Recoil.Magnitude = 10
SWEP.Recoil.MagnitudeVariance = 0
SWEP.Recoil.MagnitudeIncrease = 1
SWEP.Recoil.Decay = 1
SWEP.Recoil.Decay_Treshold = 1
SWEP.Recoil.Decay_Exponent = 1
SWEP.Recoil.Table = {}

SWEP.Projectile = {}
SWEP.Projectile.Mass        = 42	-- Grains
SWEP.Projectile.Drag        = 0.1	-- No-Unit (multiplier)
SWEP.Projectile.Gravity     = 800	-- Inches per second
SWEP.Projectile.Velocity    = 600   -- Meters per second
SWEP.Projectile.Caliber     = 4.6	-- Milimeters

SWEP.Projectile.Initialize	= function(self)
	-- Called when bullet is initialized.
	self.TracerMaterial = Material("effects/spark")
end

SWEP.Projectile.Draw		= function(self)
	-- Called every frame when bullet is about to be drawn.
	render.SetMaterial(self.TracerMaterial)
	render.DrawBeam(self.Position, self.Position - self.Velocity:GetNormalized() * 128, 8, 1, 0, color_white)
end
SWEP.Projectile.OnImpact	= function(self)
	-- Called when bullet hits a solid object.
	util.BulletImpactW(self.TraceResult, self.Attacker)
end

SWEP.Primary.ClipSize		= 40 -- Rounds
SWEP.Primary.DefaultClip	= 160 -- Rounds
SWEP.Primary.Damage         = 18 -- HP
SWEP.Primary.HSMultiplier   = 1.5 -- No-Unit (multiplier)
SWEP.Primary.Automatic		= true -- Self-Explanatory
SWEP.Primary.Sound          = "Weapon_SMG1.Single" -- Shoot sound
SWEP.Primary.Ammo			= "AR2" -- Ammo type