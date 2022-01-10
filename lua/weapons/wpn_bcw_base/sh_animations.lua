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

	self:SetNextIdleTime(CurTime() + (self:SequenceDuration(sequence) * playbackRate))
	return true
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

	-- Set the next time the weapon will idle
	self:SetNextIdleTime(CurTime() + (self:SequenceDuration() * playbackRate))
	return true
end

function SWEP:PlayAnimation(animation, playbackRate)
	local animData = self.Animations[animation]

	if istable(animData) then
		self:SetWeaponSequenceByName(table.Random(animData), playbackRate)
	elseif isstring(animData) then
		self:SetWeaponSequenceByName(animData, playbackRate)
	end
end