function SWEP:GetMaxAmmo()
	local maxAmmoCount = self:GetMaxClip1()

	if self:GetIsPrimed() then
		return maxAmmoCount + self.Primary.ChamberSize
	end

	return maxAmmoCount
end

function SWEP:UsesSequentialReloads()
	local animData = self.Animations
	return animData["Reload Start"] and animData["Reload Loop"] and animData["Reload End"]
end

function SWEP:StartReload()
	local owner = self:GetOwner()
	local reserveAmmoType = self:GetPrimaryAmmoType()
	local reserveAmmoCount = owner:GetAmmoCount(reserveAmmoType)
	if reserveAmmoCount <= 0 then
		return false
	end

	local ammoCount = self:Clip1()
	local maxAmmoCount = self:GetMaxAmmo()
	if ammoCount >= maxAmmoCount then
		return false
	end

	local j = math.min(1, reserveAmmoCount)
	if j <= 0 then
		return false
	end

	local _, anim_duration = self:PlayAnimation("Reload Start", 1)
	self:CalculateNextAttackTime(anim_duration)
	self:SetReloadFinishTime(self:GetNextPrimaryFire())
	self:SetIsReloading(true)
	return true
end

function SWEP:ContinueReload()
	local owner = self:GetOwner()
	local reserveAmmoType = self:GetPrimaryAmmoType()
	local reserveAmmoCount = owner:GetAmmoCount(reserveAmmoType)
	if reserveAmmoCount <= 0 then
		return false
	end

	local ammoCount = self:Clip1()
	local maxAmmoCount = self:GetMaxAmmo()
	if ammoCount >= maxAmmoCount then
		return false
	end

	local _, anim_duration = self:PlayAnimation("Reload Loop", 1)
	self:CalculateNextAttackTime(anim_duration)
	self:SetReloadFinishTime(self:GetNextPrimaryFire())
	self:SetClip1(self:Clip1() + 1)
	owner:RemoveAmmo(1, reserveAmmoType)

	return true
end

function SWEP:FinishReload()
	local _, anim_duration = self:PlayAnimation("Reload End", 1)
	self:CalculateNextAttackTime(anim_duration)
	self:SetReloadFinishTime(self:GetNextPrimaryFire())
	self:SetIsReloading(false)
end

function SWEP:ReloadThink()
	local owner = self:GetOwner()
	if not IsValid(owner) then
		return
	end

	local ammoCount = self:Clip1()
	local maxAmmoCount = self:GetMaxAmmo()
	local reserveAmmoType = self:GetPrimaryAmmoType()
	local reserveAmmoCount = owner:GetAmmoCount(reserveAmmoType)

	if self:GetIsReloading() then
		if math.max(self:GetNextPrimaryFire(), self:GetReloadFinishTime()) <= CurTime() then
			if self:UsesSequentialReloads() then
				if ammoCount >= maxAmmoCount or reserveAmmoCount <= 0 then
					self:FinishReload()
					return
				end

				self:ContinueReload()
			else
				local dif = maxAmmoCount - ammoCount
				local amt = math.min(ammoCount + reserveAmmoCount, maxAmmoCount)

				self:SetClip1(amt)
				owner:RemoveAmmo(dif, reserveAmmoType)
				self:SetRecoilIndex(1)
				self:SetIsReloading(false)

				if not self.Animations["Prime"] then
					-- HACK: We did not actually prime the weapon, but since we don't have either empty reload animation or prime animation we are just gonna make the weapon magicaly prime itself.
					self:SetIsPrimed(true)
				end
			end
		end
	else
		if self.Animations["Prime"] and self:GetNextPrimaryFire() <= CurTime() and ammoCount > 0 and not self:GetIsPrimed() then
			local _, anim_duration = self:PlayAnimation("Prime", 1)
			self:CalculateNextAttackTime(anim_duration)
			self:SetReloadFinishTime(self:GetNextPrimaryFire())
			self:SetIsPrimed(true)
		end
	end
end

function SWEP:Reload()
	local owner = self:GetOwner()
	if not IsValid(owner) then
		return
	end

	if self:GetIsReloading() then
		return
	end

	local animData = self.Animations
	if animData["Reload Start"] and animData["Reload Loop"] and animData["Reload End"] then
		self:StartReload()
		return
	end

	local sequence = "Reload"
	if not self:GetIsPrimed() and animData["Reload Empty"] then
		sequence = "Reload Empty"
	end

	local _, anim_duration = self:PlayAnimation(sequence, 1)
	self:CalculateNextAttackTime(anim_duration)
	self:SetReloadFinishTime(self:GetNextPrimaryFire())
	self:SetIsReloading(true)
end