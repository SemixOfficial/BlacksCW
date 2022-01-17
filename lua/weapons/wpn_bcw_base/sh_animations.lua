-- From homonovus :>
function SWEP:SetWeaponSequence(sequence, playbackRate)
	if sequence == -1 then
		return false
	end

	self:SendViewModelMatchingSequence(sequence)

	local owner = self:GetOwner()
	if owner:IsValid() then
		local vm = owner:GetViewModel()
		if vm:IsValid() then
			vm:SendViewModelMatchingSequence(sequence)
			vm:SetPlaybackRate(playbackRate)
		end
	end

	local duration = self:SequenceDuration(sequence) / playbackRate
	self:SetNextIdleTime(CurTime() + duration)
	return true, duration
end

function SWEP:SetWeaponSequenceByName(sequenceName, playbackRate)
	local sequenceId = self:LookupSequence(sequenceName)
	return self:SetWeaponSequence(sequenceId, playbackRate)
end

function SWEP:SetWeaponAnim(act, playbackRate)
	local idealSequence = self:SelectWeightedSequence(act)
	if idealSequence == -1 then
		 return false
	end

	self:SendWeaponAnim(act)
	self:SendViewModelMatchingSequence(idealSequence)
	self:SetPlaybackRate(playbackRate)

	local duration = self:SequenceDuration(sequence) / playbackRate
	self:SetNextIdleTime(CurTime() + duration)
	return true, duration
end

function SWEP:PlayAnimation(animation, playbackRate)
	local animData = self.Animations[animation]

	if animData.PlaybackRate then
		playbackRate = animData.PlaybackRate
	end

	local owner = self:GetOwner()
	if IsValid(owner) and animData.Animation then
		owner:SetAnimation(animData.Animation)
	end

	if animData.Sequence then
		return self:SetWeaponSequenceByName(animData.Sequence, playbackRate)
	end

	if animData.Activity then
		self:SetPlaybackRate(playbackRate)
		self:SendWeaponAnim(animData.Activity)
		return true, self:SequenceDuration() * playbackRate
	end

	return false
end