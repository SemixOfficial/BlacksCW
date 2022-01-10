function SWEP:GetViewModelPosition(eyePos, eyeAngles)
	local mult = self:GetADSDelta()
	local offset = self.ADSPosition

	if self.ADSAngles then
		eyeAngles:RotateAroundAxis(eyeAngles:Right(), self.ADSAngles.x * mult)
		eyeAngles:RotateAroundAxis(eyeAngles:Up(), self.ADSAngles.y * mult)
		eyeAngles:RotateAroundAxis(eyeAngles:Forward(), self.ADSAngles.z * mult)
	end

	local right 	= eyeAngles:Right()
	local up 		= eyeAngles:Up()
	local forward 	= eyeAngles:Forward()

	eyePos = eyePos + offset.x * right * mult
	eyePos = eyePos + offset.y * forward * mult
	eyePos = eyePos + offset.z * up * mult

	return eyePos, EyeAng
end

function SWEP:PreDrawViewModel(viewmodel, weapon, ply)
	if self.Debug.Attachments or self.Debug.Bones then
		render.SetBlend(0.1)
		self.RestoreBlending = true
	end

end

function SWEP:ViewModelDrawn(viewmodel)
	if self.Debug.Attachments then
		self:DrawAttachmentDebug(viewmodel)
	end

	if self.Debug.Bones then
		self:DrawBoneDebug(viewmodel)
	end

	if self.RestoreBlending then
		render.SetBlend(1)
		self.RestoreBlending = nil
	end

end