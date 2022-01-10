function SWEP:DrawAttachmentDebug(viewmodel)
	for idx, attachment in pairs(viewmodel:GetAttachments()) do
		local id = attachment.id
		local name = attachment.name
		local data = viewmodel:GetAttachment(id)

		debugoverlay.EntityTextAtPosition(data.Pos, 0, "*Attachment*", 0.05, Color(76, 98, 223))
		debugoverlay.EntityTextAtPosition(data.Pos, 1, "Name: " .. name, 0.05, color_white)

		debugoverlay.Line(data.Pos, data.Pos + data.Ang:Forward() * 4, 0.05, Color(255, 0, 0, 255), true)
		debugoverlay.Line(data.Pos, data.Pos + data.Ang:Right() * 4, 0.05, Color(0, 255, 0, 255), true)
		debugoverlay.Line(data.Pos, data.Pos + data.Ang:Up() * 4, 0.05, Color(0, 0, 255, 255), true)
	end
end

function SWEP:DrawBoneDebug(viewmodel)
	for i = 0, viewmodel:GetBoneCount() - 1 do
		local matrix = viewmodel:GetBoneMatrix(i)
		if not matrix then
			continue
		end

		local name = viewmodel:GetBoneName(i)
		local pos = matrix:GetTranslation()
		local ang = matrix:GetAngles()

		debugoverlay.EntityTextAtPosition(pos, 0, "*Bone*", 0.05, Color(223, 118, 76))
		debugoverlay.EntityTextAtPosition(pos, 1, "Name: " .. name, 0.05, color_white)

		debugoverlay.Line(pos, pos + ang:Forward() * 4, 0.05, Color(255, 0, 0, 255), true)
		debugoverlay.Line(pos, pos + ang:Right() * 4, 0.05, Color(0, 255, 0, 255), true)
		debugoverlay.Line(pos, pos + ang:Up() * 4, 0.05, Color(0, 0, 255, 255), true)
	end
end