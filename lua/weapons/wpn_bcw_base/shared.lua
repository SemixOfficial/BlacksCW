AddCSLuaFile()
DEFINE_BASECLASS("weapon_base")

if SERVER then
	AddCSLuaFile("sh_debug.lua")
	AddCSLuaFile("sh_firing.lua")
	AddCSLuaFile("sh_viewmodel.lua")
	AddCSLuaFile("sh_animations.lua")
	AddCSLuaFile("sh_reloads.lua")
end

include("sh_debug.lua")
include("sh_firing.lua")
include("sh_viewmodel.lua")
include("sh_animations.lua")
include("sh_reloads.lua")

SWEP.PrintName		= "Scripted Weapon"
SWEP.Author			= "BlacK"
SWEP.IsBCWWeapon	= true

SWEP.HoldType		= "ar2"
SWEP.UseHands		= true
SWEP.BobScale		= 1
SWEP.SwayScale		= 1
SWEP.ViewModelFOV	= 62
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/weapons/v_pistol.mdl"
SWEP.WorldModel		= "models/weapons/w_357.mdl"

SWEP.Spawnable		= false
SWEP.AdminOnly		= false

SWEP.Debug = {}
SWEP.Debug.Sights = false
SWEP.Debug.Attachments = false
SWEP.Debug.Bones = false

SWEP.Inaccuracy				= {}
SWEP.Inaccuracy.Crouched	= 0.5	-- Base inaccuracy when crouching. (in minutes of arc)
SWEP.Inaccuracy.Standing	= 1		-- Base inaccuracy when stood still. (in minutes of arc)
SWEP.Inaccuracy.Walking		= 1		-- How much inaccuracy the gun gains per one m/s of velocity. (in minutes of arc)
SWEP.Inaccuracy.Firing		= 0.5	-- How much inaccuracy the gun gains everytime it's fired. (in minutes of arc)
SWEP.Inaccuracy.Decay		= 1		-- How long it takes for this weapon to recover from it's max inaccuracy. (in seconds)
SWEP.Inaccuracy.Scoped		= 1		-- Inaccuracy multiplier for when aiming down the sights.
SWEP.Inaccuracy.Max			= 3		-- Max possible inaccuracy from firing. (in minutes of arc)
SWEP.Inaccuracy.Gaussian	= 1		-- Controls the gaussian distribution of the bullet spread, 1 is full gaussian, 0 is flat, -1 is inverse gaussian.
SWEP.Inaccuracy.Bias		= 0		-- Controlls the spread distribution across pitch and yaw, 1 will make the spread fully horizontal, 0 is uniform, -1 will make it completely vertical.

SWEP.Primary.ClipSize		= 30
SWEP.Primary.DefaultClip	= 90
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "Pistol"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= 0
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.Projectile = table.Copy(BlacksCW.BaseProjectile)

function SWEP:Initialize()
	self:SetSpreadRandomSeed(0)
	self:SetIsPrimed(true)
	self:SetHoldType(self.HoldType)
	self:GenerateRecoilTable()
	self:ProjectileInit()
end

-- CURIOSITY: Why does this exist here like this?
function SWEP:ProjectileInit()
end

function SWEP:SetupDataTables()
	self:NetworkVar("Float", 0, "NextIdleTime")
	self:NetworkVar("Float", 1, "ReloadFinishTime")
	self:NetworkVar("Float", 2, "RecoilIndex")
	self:NetworkVar("Float", 3, "ADSDelta")
	self:NetworkVar("Float", 4, "AccuracyPenalty")

	self:NetworkVar("Bool", 0, "IsReloading")
	self:NetworkVar("Bool", 1, "IsPrimed")
	self:NetworkVar("Bool", 2, "FireAfterReloadEnds")

	self:NetworkVar("Int", 0, "SpreadRandomSeed")

	self:SetRecoilIndex(1)
end

function SWEP:Holster()
	self:SetIsReloading(false)
	self:SetReloadFinishTime(0)

	return true
end

function SWEP:IdleThink()
	if self:GetNextIdleTime() == 0 or CurTime() <= self:GetNextIdleTime() then
		return
	end

	self:SendWeaponAnim(ACT_VM_IDLE)
	self:SetNextIdleTime(0)
end

function SWEP:ADSThink()
	local owner = self:GetOwner()
	local currentDelta = self:GetADSDelta()
	local deltaChange = (1 / self.ADSTime) * FrameTime()
	local flip = Either(owner:KeyDown(IN_ATTACK2), 1, -1)

	currentDelta = math.Clamp(currentDelta + (deltaChange * flip), 0, 1)

	self:SetADSDelta(currentDelta)
end

function SWEP:TranslateFOV(fov)
	return Lerp(self:GetADSDelta(), fov, fov / self.ADSMagnification)
end

function SWEP:AdjustMouseSensitivity()
	local owner = self:GetOwner()
	local fov_desired = GetConVar("fov_desired")
	local fov = owner:GetFOV()

	return fov / fov_desired:GetFloat()
end

function SWEP:UpdateAccuracyPenalty()
	local penalty = self:GetAccuracyPenalty()
	local decreaseAmount = (self.Inaccuracy.Max / self.Inaccuracy.Decay) * FrameTime()

	self:SetAccuracyPenalty(math.max(penalty - decreaseAmount, 1))
end

function SWEP:RecoilThink()
	if self:GetNextPrimaryFire() > CurTime() - (self.CycleTime * self.Recoil.Decay_Treshold) then
		return
	end

	local recoilIndex = self:GetRecoilIndex()
	local decreaseMagnitude = self.Recoil.Decay -- + (recoilIndex / #self.Recoil.Table) ^ self.Recoil.Decay_Exponent
	local decreaseAmount = (decreaseMagnitude / self.CycleTime) * FrameTime()

	self:SetRecoilIndex(math.max(recoilIndex - decreaseAmount, 1))
end

function SWEP:Think()
	local owner = self:GetOwner()

	-- if self:GetIsReloading() and CurTime() >= self:GetReloadFinishTime() then
	-- 	local clip = self:Clip1()
	-- 	local maxclip = self:GetMaxClip1()
	-- 	local dif = maxclip - clip
	-- 	local amt = math.min(clip + owner:GetAmmoCount(self.Primary.Ammo), maxclip)
	-- 	if self.CanChamberRound ~= false and dif ~= maxclip then
	-- 		dif = 1
	-- 		amt = amt + 1
	-- 	end

	-- 	self:SetClip1(amt)
	-- 	owner:RemoveAmmo(dif, self.Primary.Ammo)
	-- 	self:SetIsReloading(false)
	-- 	self:SetRecoilIndex(1)
	-- end

	self:UpdateAccuracyPenalty()
	self:RecoilThink()
	self:ReloadThink()
	self:ADSThink()
end

function SWEP:DoDrawCrosshair(x, y)
	local owner = LocalPlayer()
	if not (IsValid(owner) and owner:Alive()) then
		return
	end

	if self.Debug.Sights then
		surface.SetDrawColor(color_white)
		local w, h = ScrW(), ScrH()
		surface.DrawLine(w * 0.5, 0, w * 0.5, h)
		surface.DrawLine(0, h * 0.5, w, h * 0.5)
	end

	local cone = self:GetCone()
	local spreadFov = math.deg(math.atan((cone.x + cone.y) * 0.5))
	local screenFov = 0.5 * math.deg(2 * math.atan((ScrW() / ScrH()) * (3 / 4) * math.tan(0.5 * math.rad(owner:GetFOV())))) --To calculate your actual fov based on your aspect ratio
	local srAngle = 180 - (90 + screenFov)
	local scrSide = ((0.5 * ScrW()) * math.sin(math.rad(srAngle))) / math.sin(math.rad(screenFov))
	local arAngle = 180 - (90 + spreadFov)
	local fixedFov = (scrSide * math.sin(math.rad(spreadFov))) / math.sin(math.rad(arAngle))
	local maxFov = math.sqrt(((0.5 * ScrW()) ^ 2) + ((0.5 * ScrH()) ^ 2))

	if (spreadFov > 0 and fixedFov <= maxFov and spreadFov <= owner:GetFOV()) then
		local gap = math.ceil(fixedFov)

		surface.SetDrawColor(Color(0, 0, 0, 205))
		surface.DrawRect(x - 1, y - 1, 3, 3)
		surface.DrawRect((x - 1) + gap, y - 1, 8, 3)
		surface.DrawRect((x - 1) - (5 + gap), y - 1, 8, 3)
		surface.DrawRect(x - 1, (y - 1) + gap, 3, 8)
		surface.DrawRect(x - 1, (y - 1) - (5 + gap), 3, 8)

		surface.SetDrawColor(Color(137, 255, 34, 255))
		surface.DrawRect(x, y, 1, 1)
		surface.DrawRect(x + gap, y, 6, 1)
		surface.DrawRect(x - (5 + gap), y, 6, 1)
		surface.DrawRect(x, y + gap, 1, 6)
		surface.DrawRect(x, y - (5 + gap), 1, 6)

	end

	return true
end

function SWEP:IsAbleToUseRTPIPScope()
	-- FIXME: "Render-Target Picture in Picture scope" is such a fucking long phrase, can we just call it R-T PiP scopes... or dynamic scopes? OR JNUS SOMETHING ELSE?!!!
	-- CURIOSITY: ^ Who came up with this name? ^
	-- Only draw Render Target Picture in Picture scopes if we have a DirectX 7 capable card (lower versions are not supported :C).
	return render.GetDXLevel() >= 70 -- TODO: check if the user wants to use render target picture in picture scopes in the first place.
end