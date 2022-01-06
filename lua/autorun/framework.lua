AddCSLuaFile()

function UTIL_UnitsToMeters(units)
	return units * 0.01905
end
function UTIL_MetersToUnits(meters)
	return meters / 0.01905
end
function UTIL_UnitsToFeet(units)
	return units / 16
end
function UTIL_FeetToUnits(feet)
	return feet * 16
end

if not util.ImpactTraceW then
	function util.ImpactTraceW(tr, iDamageType, effect)
		if not tr.Entity or tr.HitSky then
			return end
		if tr.Fraction == 1 then
			return end
		if tr.HitNoDraw then
			return end

		local data = EffectData()
		data:SetOrigin(tr.HitPos)
		data:SetStart(tr.StartPos)
		data:SetSurfaceProp(tr.SurfaceProps)
		data:SetDamageType(iDamageType)
		data:SetHitBox(tr.HitBox)
		data:SetEntity(tr.Entity)


		util.Effect(effect or "Impact", data, not game.SinglePlayer())
	end
end

local FX_WATER_IN_SLIME = 0x1
function util.BulletImpactW(tr, ply)
	-- see if the bullet ended up underwater and started out of the water
	if bit.band(util.PointContents(tr.HitPos), bit.bor(CONTENTS_WATER, CONTENTS_SLIME)) ~= 0 then
		local waterTrace = {}
		util.TraceLine({
			start = tr.StartPos,
			endpos = tr.HitPos,
			mask = bit.bor(CONTENTS_WATER,CONTENTS_SLIME),
			filter = ply,
			collisiongroup = COLLISION_GROUP_NONE,
			output = waterTrace,
		})

		if not waterTrace.AllSolid then
			local data = EffectData()
			data:SetOrigin(waterTrace.HitPos)
			data:SetNormal(waterTrace.HitNormal)
			data:SetScale(math.Rand(8, 12))

			if bit.band(waterTrace.Contents, CONTENTS_SLIME) ~= 0 then
				data:SetFlags(bit.bor(data:GetFlags(), FX_WATER_IN_SLIME))
			else
				data:SetFlags(bit.bnot(FX_WATER_IN_SLIME))
			end

			if SERVER and IsValid(ply) and ply:IsPlayer() then
				SuppressHostEvents(ply)
			end


			util.Effect("gunshotsplash", data, not game.SinglePlayer())
		end
	end

	--if SERVER and IsValid(ply) and ply:IsPlayer() then
	--	SuppressHostEvents(ply)
	--end

	util.ImpactTraceW(tr, DMG_BULLET)
end

BlacksCW = {}
BlacksCW.PhysBullets = {}
BlacksCW.BulletGravity = Vector(0, 0, -800)
BlacksCW.AirDensity = 0.0765
BlacksCW.CurrentTime = 0
BlacksCW.UpdateRate = 240
BlacksCW.TickInterval = 1 / BlacksCW.UpdateRate
BlacksCW.TimeScale = 1

local host_timescale = GetConVar("host_timescale")
function BlacksCW.GetSimulationTimeScale()
	return BlacksCW.TimeScale * host_timescale:GetFloat()
end

if SERVER then
	util.AddNetworkString("BlacksCW_NetworkBullets")
	util.AddNetworkString("BlacksCW_BulletImpact")

	net.Receive("BlacksCW_BulletImpact", function(length, ply)
		local inflictor = net.ReadEntity()
		local victim = net.ReadEntity()
		local hitpos = net.ReadVector()
		local velocity = net.ReadVector()
		local hitgroup	= net.ReadUInt(4)

		if not IsValid(inflictor) or not inflictor.IsBCWWeapon then
			return
		end

		if not IsValid(victim) then
			return
		end

		local damageInfo = DamageInfo()
		damageInfo:SetAttacker(ply)
		damageInfo:SetInflictor(inflictor)
		damageInfo:SetDamage(inflictor.Primary.Damage)
		damageInfo:SetDamagePosition(hitpos)
		damageInfo:SetDamageForce(velocity)
		damageInfo:SetReportedPosition(hitpos)
		damageInfo:SetDamageType(DMG_BULLET)
		damageInfo:SetAmmoType(game.GetAmmoID(inflictor.Primary.Ammo))

		if victim:IsPlayer() then
			hook.Run("ScalePlayerDamage", victim, hitgroup, damageInfo)
		elseif victim:IsNPC() or victim:IsNextBot() then
			hook.Run("ScaleNPCDamage", victim, hitgroup, damageInfo)
		end

		victim:TakeDamageInfo(damageInfo)
	end)
end

if CLIENT then
	net.Receive("BlacksCW_NetworkBullets", function(length, ply)
		local attacker = net.ReadEntity()
		local inflictor = net.ReadEntity()
		local position = net.ReadVector()
		local velocity = net.ReadNormal()
		local speed = net.ReadFloat()

		if not IsValid(inflictor) then
			return
		end

		velocity:Mul(speed)

		local bulletInfo		= {}
		local projectileInfo	= inflictor.Projectile

		bulletInfo.Attacker			= attacker
		bulletInfo.Inflictor		= inflictor
		bulletInfo.Position			= position
		bulletInfo.Velocity			= velocity
		bulletInfo.Mass				= projectileInfo.Mass / 15432.3584 -- Christ fucking kill me  [One kilogram has 15,432.3584 grains]
		bulletInfo.Diameter			= projectileInfo.Caliber / 25.4 -- One inch has 25.4 milimeters.
		bulletInfo.Gravity			= projectileInfo.Gravity
		bulletInfo.DragCoefficient	= projectileInfo.Drag
		bulletInfo.Initialize		= projectileInfo.Initialize
		bulletInfo.Draw				= projectileInfo.Draw
		bulletInfo.OnImpact			= projectileInfo.OnImpact

		BlacksCW.FireBullets(bulletInfo)
	end)
end

	-- Ths needs change, badly.
	-- if SERVER then
	--	 net.Start("BlacksCW_NetworkBullets", true)
	--	 net.WriteEntity(bulletInfo.Attacker)
	--	 net.WriteEntity(bulletInfo.Inflictor)
	--	 net.WriteVector(bulletInfo.Position)
	--	 net.WriteNormal(bulletInfo.Velocity:GetNormalized())
	--	 net.WriteFloat(bulletInfo.Velocity:Length())
	--	 net.SendOmit(bulletInfo.Attacker)
	--	 return
	-- end


function BlacksCW.FireBullets(bulletInfo)
	local bullet = {}

	bullet.Index			= #BlacksCW.PhysBullets
	bullet.Attacker			= bulletInfo.Attacker
	bullet.Inflictor		= bulletInfo.Inflictor
	bullet.Position			= bulletInfo.Position
	bullet.Velocity			= bulletInfo.Velocity
	bullet.Gravity			= Vector(0, 0, -bulletInfo.Gravity)
	bullet.DragCoefficient	= bulletInfo.DragCoefficient
	bullet.ReferenceArea	= math.pi * ((0.5 * bulletInfo.Diameter) ^ 2)
	bullet.Mass				= bulletInfo.Mass
	bullet.TraceData		= {
		mask	= MASK_SHOT,
		filter	= bulletInfo.Attacker
	}
	bullet.TraceResult		= {}
	bullet.IsMarkedForRemoval	= false
	bullet.SimulationTime		= BlacksCW.CurrentTime
	bullet.Draw = bulletInfo.Draw
	bullet.OnImpact = bulletInfo.OnImpact

	bulletInfo.Initialize(bullet)

	table.insert(BlacksCW.PhysBullets, bullet)
end

function BlacksCW.SimulateBullet(bullet)
	local localplayer = LocalPlayer()

	while (BlacksCW.CurrentTime > bullet.SimulationTime) do
		local position = bullet.Position
		local velocity = bullet.Velocity * BlacksCW.TickInterval

		-- Air Drag
		local speedsqr = velocity:LengthSqr()
		local dragforce = bullet.DragCoefficient * ((BlacksCW.AirDensity * speedsqr) * 0.5) * bullet.ReferenceArea  -- D = Cd * A * .5 * r * V^2

		-- Updoot!
		local nextposition = bullet.Position + bullet.Velocity * BlacksCW.TickInterval
		local acceleration = ((bullet.Gravity * BlacksCW.TickInterval) - (velocity:GetNormalized() * dragforce / bullet.Mass))
		local nextvelocity = velocity + acceleration * BlacksCW.TickInterval

		bullet.TraceData.start = position
		bullet.TraceData.endpos= nextposition
		bullet.TraceResult = util.TraceLine(bullet.TraceData)

		debugoverlay.Line(bullet.TraceResult.StartPos, bullet.TraceResult.HitPos, 4, Color(0, 255, 0, 255), true)
		debugoverlay.BoxAngles(bullet.TraceResult.HitPos, Vector(-32, -1, -1), Vector(32, 1, 1), velocity:Angle(), 4, Color(0, 255, 0, 127))

		if bullet.TraceResult.Hit then
			local hitEntity = bullet.TraceResult.Entity
			if IsValid(hitEntity) and bullet.Attacker == localplayer then
				net.Start("BlacksCW_BulletImpact", true)
				net.WriteEntity(bullet.Inflictor)
				net.WriteEntity(hitEntity)
				net.WriteVector(bullet.TraceResult.HitPos)
				net.WriteVector(velocity)
				net.WriteUInt(bullet.TraceResult.HitGroup, 4)
				net.SendToServer()
			end

			bullet.OnImpact(bullet, bullet.TraceResult)
			bullet.IsMarkedForRemoval = true
			break
		end

		bullet.Position = bullet.TraceResult.HitPos
		bullet.Velocity = nextvelocity / BlacksCW.TickInterval
		bullet.SimulationTime = bullet.SimulationTime + (BlacksCW.TickInterval / BlacksCW.GetSimulationTimeScale())
	end

end

function BlacksCW.SimulatePhysBullets(arguments)
	BlacksCW.CurrentTime = SysTime()
	BlacksCW.TickInterval = (1 / BlacksCW.UpdateRate) * BlacksCW.GetSimulationTimeScale()

	for bulletId, bullet in pairs(BlacksCW.PhysBullets) do

		BlacksCW.SimulateBullet(bullet)

		if bullet.IsMarkedForRemoval then
			table.remove(BlacksCW.PhysBullets, bulletId)
		end
	end
end

hook.Add("Think", "BlacksCW_SimulatePhysBullets", BlacksCW.SimulatePhysBullets)

local bullet_mat = Material("effects/spark")
hook.Add( "PostDrawTranslucentRenderables", "test", function(hasDepth, isDrawingSkyBox)
	if isDrawingSkyBox then
		return
	end

	for bulletId, bullet in pairs(BlacksCW.PhysBullets) do
		bullet.Draw(bullet)
	end
end)


-- hook.Add("HUDPaint", "debugbullets", function()
--	 local mins = -Vector(1, 1, 1)
--	 local maxs = Vector(1, 1, 1)
--	 local color_red = Color(255, 0, 0, 127)
--	 local color_green = Color(0, 255, 0, 127)
--	 local color_yellow = Color(255, 238, 0, 127)
--	 local color_blue = Color(87, 148, 240, 127)

--	 cam.Start3D()
--	 for bulletId, bullet in pairs(BlacksCW.PhysBullets) do
--		 if not bullet.TraceResult.StartPos then
--			 continue
--		 end

--		 local frac = (bullet.SimulationTime - BlacksCW.CurrentTime) / (BlacksCW.TickInterval / BlacksCW.TimeScale)
--		 frac = math.Clamp(frac, 0, 1)

--		 local renderPos = LerpVector(1 - frac, bullet.TraceResult.StartPos, bullet.TraceResult.HitPos)

--		 render.DrawWireframeBox(bullet.TraceResult.StartPos, angle_zero, mins, maxs, color_red, true)
--		 render.DrawWireframeBox(bullet.TraceResult.HitPos, angle_zero, mins, maxs, color_green, true)
--		 render.DrawWireframeBox(renderPos, angle_zero, mins, maxs, color_yellow, true)
--		 render.DrawLine(bullet.TraceResult.StartPos, bullet.TraceResult.HitPos, color_blue, true)
--	 end
--	 cam.End3D()
-- end)