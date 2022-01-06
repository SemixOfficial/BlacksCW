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
	self.Projectile = table.Copy(BaseClass.Projectile)
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


SWEP.Primary.ClipSize		= 30 -- Rounds
SWEP.Primary.DefaultClip	= 90 -- Rounds
SWEP.Primary.Damage         = 33 -- HP
SWEP.Primary.HSMultiplier   = 1.5 -- No-Unit (multiplier)
SWEP.Primary.Automatic		= true -- Self-Explanatory
SWEP.Primary.Sound          = "Weapon_AR2.Single" -- Shoot sound
SWEP.Primary.Ammo			= "AR2" -- Ammo type