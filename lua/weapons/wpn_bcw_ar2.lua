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


SWEP.CycleTime = 60 / 600 -- RPM

SWEP.Animations = {
	Fire = "ir_fire",
	Reload = "ir_reload",
}

SWEP.Recoil = {}
SWEP.Recoil.RandomSeed			= 117
SWEP.Recoil.Scale				= 0.65
SWEP.Recoil.Angle				= 60
SWEP.Recoil.AngleVariance		= 10
SWEP.Recoil.Magnitude			= 10
SWEP.Recoil.MagnitudeVariance	= 0
SWEP.Recoil.MagnitudeIncrease	= 2
SWEP.Recoil.Decay				= 1
SWEP.Recoil.Decay_Treshold		= 1
SWEP.Recoil.Decay_Exponent		= 1 -- Unused (deprecated)
SWEP.Recoil.Table				= {}

SWEP.Projectile.Mass        = 10    -- Grains
SWEP.Projectile.Drag        = 0     -- No-Unit (multiplier)
SWEP.Projectile.Gravity     = 0     -- Inches per second
SWEP.Projectile.Velocity    = 450   -- Meters per second
SWEP.Projectile.Caliber     = 8		-- Milimeters

SWEP.Projectile.Initialize	= function(self)
	-- Called when bullet is initialized.

	self.HeadMaterial = Material("effects/combinemuzzle1")
	self.TracerMaterial = Material("effects/gunshiptracer")
	self.TracerLength = 128
	self.TracerWidth = 8
end

SWEP.Projectile.OnImpact	= function(self)
	-- Called when bullet hits a solid object.
	local effect = EffectData()
	effect:SetOrigin(self.TraceResult.HitPos + self.TraceResult.HitNormal)
	effect:SetNormal(self.TraceResult.HitNormal)
	util.Effect("AR2Impact", effect)

	util.BulletImpactW(self.TraceResult, self.Inflictor)
end

SWEP.Primary.ClipSize		= 30 -- Rounds
SWEP.Primary.DefaultClip	= 90 -- Rounds
SWEP.Primary.Damage         = 33 -- HP
SWEP.Primary.HSMultiplier   = 1.5 -- No-Unit (multiplier)
SWEP.Primary.Automatic		= true -- Self-Explanatory
SWEP.Primary.Sound          = "Weapon_AR2.Single" -- Shoot sound
SWEP.Primary.Ammo			= "AR2" -- Ammo type