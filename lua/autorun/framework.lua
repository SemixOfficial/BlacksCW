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
BlacksCW.GainsToKilograms = 15432.3584

BlacksCW.BaseProjectile = {
	Mass        = 1,	-- Grains
	Drag        = 0.3,	-- No-Unit (multiplier)
	Gravity     = 800,	-- Inches per second
	Velocity    = 400,   -- Meters per second
	Caliber     = 9,	-- Milimeters
	Count		= 1,

	Initialize	= function(self)
		-- Called when bullet is initialized.
		self.TracerMaterial = Material("effects/spark")
		self.HeadMaterial = Material("effects/yellowflare")
		self.TracerLength = 128
		self.TracerWidth = 8
	end,
	Draw		= function(self)
		-- do not render for the first 10ms, to prevent bullets in ur eyeballs!
		if (self.Attacker == LocalPlayer() and not self.Attacker:ShouldDrawLocalPlayer()) and self.CreationTime + 0.075 > BlacksCW.CurrentTime then
			return
		end

		local heading = self.Velocity:GetNormalized()

		-- Called every frame when bullet is about to be drawn.
		render.SetMaterial(self.TracerMaterial)
		render.DrawBeam(self.Position, self.Position - heading * 128, self.TracerWidth, 1, 0, color_white)

		local bulletDir = self.Position - (self.Position - heading * 128)

		local degAway = 90 - math.abs(math.deg(math.asin(bulletDir:Dot(EyeAngles():Forward()) / bulletDir:Length())))

		local w = (self.TracerWidth * 2) * (math.max(15 - degAway, 0) / 15)
		local h = (self.TracerWidth * 2) * (math.max(15 - degAway, 0) / 15)

		render.SetMaterial(self.HeadMaterial)
		render.DrawSprite(self.Position, w, h, color_white)
	end,
	OnImpact	= function(self)
		-- Called when bullet hits a solid object.
		util.BulletImpactW(self.TraceResult, self.Attacker)
	end
}

BLACKCW_DIRECTION_SCALEUP = 100

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
		local velocity = net.ReadNormal() -- FIXME: This is fucked
		local speed = net.ReadFloat()
		local hitgroup	= net.ReadUInt(4)

		velocity:Mul(speed)

		if not IsValid(inflictor) or not inflictor.IsBCWWeapon then
			return
		end

		if not IsValid(victim) then
			return
		end

		-- debugoverlay.Line(hitpos, hitpos + velocity, 4, Color( 255, 255, 255 ), false)
		local damageInfo = DamageInfo()
		damageInfo:SetAttacker(ply)
		damageInfo:SetInflictor(inflictor)
		damageInfo:SetDamage(inflictor.Primary.Damage)
		damageInfo:SetDamagePosition(hitpos)
		damageInfo:SetDamageForce(((inflictor.Projectile.Mass / BlacksCW.GainsToKilograms) * velocity * 0.5) * 10)
		damageInfo:SetReportedPosition(hitpos)
		damageInfo:SetDamageType(DMG_BULLET)
		damageInfo:SetAmmoType(game.GetAmmoID(inflictor.Primary.Ammo))

		if victim:IsPlayer() then
			victim:SetLastHitGroup(hitgroup)
			damageInfo:SetDamageForce(Vector(0, 0, 1))
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
		local velocity = net.ReadVector() / BLACKCW_DIRECTION_SCALEUP
		local speed = net.ReadFloat()

		velocity:Mul(speed)

		if not IsValid(inflictor) then
			return
		end

		local bulletInfo		= {}
		local projectileInfo	= inflictor.Projectile

		bulletInfo.Attacker			= attacker
		bulletInfo.Inflictor		= inflictor
		bulletInfo.Position			= position
		bulletInfo.Velocity			= velocity
		bulletInfo.Mass				= projectileInfo.Mass / BlacksCW.GainsToKilograms
		bulletInfo.Diameter			= projectileInfo.Caliber / 25.4 -- One inch has 25.4 milimeters.
		bulletInfo.Gravity			= projectileInfo.Gravity
		bulletInfo.DragCoefficient	= projectileInfo.Drag
		bulletInfo.Initialize		= projectileInfo.Initialize
		bulletInfo.Draw				= projectileInfo.Draw
		bulletInfo.OnImpact			= projectileInfo.OnImpact
		bulletInfo.CreationTime 	= BlacksCW.CurrentTime

		BlacksCW.FireBullets(bulletInfo)
	end)
end

function BlacksCW.FireBullets(bulletInfo)
	local bullet = {}

	local tracefilter		= {bulletInfo.Attacker}
	if g_CapsuleHitboxes then
		tracefilter = g_CapsuleHitboxes:GetEntitiesWithCapsuleHitboxes()
	end

	bullet.Index			= #BlacksCW.PhysBullets
	bullet.Attacker			= bulletInfo.Attacker
	bullet.Inflictor		= bulletInfo.Inflictor
	bullet.Position			= bulletInfo.Position
	bullet.Velocity			= bulletInfo.Velocity
	bullet.Gravity			= Vector(0, 0, -bulletInfo.Gravity)
	bullet.InitialVelocity	= bulletInfo.Velocity
	bullet.DragCoefficient	= bulletInfo.DragCoefficient
	bullet.ReferenceArea	= math.pi * ((0.5 * bulletInfo.Diameter) ^ 2)
	bullet.IsInSolid		= false
	bullet.Mass				= bulletInfo.Mass
	bullet.TraceData		= {
		mask = MASK_SHOT,
		filter = tracefilter
	}
	bullet.TraceResult		= {}
	bullet.IsMarkedForRemoval	= false
	bullet.CreationTime 		= BlacksCW.CurrentTime
	bullet.SimulationTime		= BlacksCW.CurrentTime
	bullet.Draw = bulletInfo.Draw
	bullet.OnImpact = bulletInfo.OnImpact

	bulletInfo.Initialize(bullet)

	table.insert(BlacksCW.PhysBullets, bullet)
end

function BlacksCW.BulletTrace(bullet, startPos, direction, maxDistance)
	local distanceTravelled = 0
	local traceFilter = {bullet.Attacker}
	local enterTraceData = {
		mask = MASK_SHOT,
		filter = traceFilter
	}
	local exitTraceData = table.Copy(enterTraceData)
	local mins, maxs = Vector(-0.25, -0.25, -0.25), Vector(0.25, 0.25, 0.25)

	while (maxDistance > distanceTravelled) do
		local distanceLeft = maxDistance - distanceTravelled

		enterTraceData.start = startPos
		enterTraceData.endpos = startPos + direction * distanceLeft

		local enterTrace = util.TraceLine(enterTraceData)
		debugoverlay.Line(enterTrace.StartPos, enterTrace.HitPos, 0.05, Color(0, 255, 0, 255), true)
		debugoverlay.Line(enterTraceData.start, enterTraceData.endpos, 0.05, Color(255, 0, 0, 103), true)
		debugoverlay.Box(enterTrace.StartPos, mins, maxs, 0.05, Color(228, 150, 60, 134))
		debugoverlay.Box(enterTrace.HitPos, mins, maxs, 0.05, Color(102, 206, 247, 134))
		-- Bullet didn't hit anything and travelled the entire simulated path.
		if enterTrace.Fraction == 1 then
			return
		end

		local hitEntity = enterTrace.Entity
		if IsValid(hitEntity) then
			table.insert(enterTraceData.filter, hitEntity)
		end

		distanceTravelled = distanceTravelled + distanceLeft * enterTrace.Fraction
		distanceLeft = maxDistance - distanceTravelled

		local rayDepth = 0
		local rayExtension = 4
		local rayStartPos = enterTrace.HitPos
		local exitTrace

		while (rayDepth < distanceLeft) do
			rayDepth = rayDepth + math.min(rayExtension, distanceLeft)
			exitTraceData.start = rayStartPos + direction * rayDepth
			exitTraceData.endpos = exitTraceData.start - direction * rayExtension
			exitTrace = util.TraceLine(exitTraceData)


			debugoverlay.Line(exitTrace.StartPos, exitTrace.HitPos, 0.05, Color(255, 0, 157, 225), true)
			debugoverlay.Box(exitTrace.StartPos, mins, maxs, 0.05, Color(56, 16, 236, 134))
			debugoverlay.Box(exitTrace.HitPos, mins, maxs, 0.05, Color(12, 204, 146, 134))

			if exitTrace.Hit and not exitTrace.StartSolid then
				local wallThickness = (exitTrace.HitPos - enterTrace.HitPos):Length()
				distanceTravelled = distanceTravelled + wallThickness
				distanceLeft = maxDistance - distanceTravelled
				startPos = exitTrace.HitPos
				break
			elseif exitTrace.Hit and exitTrace.StartSolid then
				local hitEntity = exitTrace.Entity
				print(hitEntity, IsValid(hitEntity))
				-- We've exited into an entity's hitbox
				if IsValid(hitEntity) then
					exitTraceData.filter = hitEntity
					exitTrace = util.TraceLine(exitTraceData)

					local wallThickness = (exitTrace.HitPos - enterTrace.HitPos):Length()
					distanceTravelled = distanceTravelled + wallThickness
					distanceLeft = maxDistance - distanceTravelled
					startPos = exitTrace.HitPos

					break
				end
			elseif not exitTrace.Hit and not exitTrace.StartSolid then
				local wallThickness = (exitTrace.HitPos - enterTrace.HitPos):Length()
				distanceTravelled = distanceTravelled + wallThickness
				distanceLeft = maxDistance - distanceTravelled
				startPos = exitTrace.HitPos
				break
			end
		end

	end

	return true
end

function BlacksCW.SimulateBullet(bullet)
	local localplayer = LocalPlayer()

	while (BlacksCW.CurrentTime > bullet.SimulationTime) do
		local position	= bullet.Position
		local velocity	= bullet.Velocity * BlacksCW.TickInterval
		local forward	= velocity:GetNormalized()

		-- Air Drag
		local speed		= velocity:Length()
		local speedsqr	= speed * speed
		local dragforce	= bullet.DragCoefficient * ((BlacksCW.AirDensity * speedsqr) * 0.5) * bullet.ReferenceArea  -- D = Cd * A * .5 * r * V^2

		-- Updoot!
		local nextposition = bullet.Position + velocity
		local acceleration = ((bullet.Gravity * BlacksCW.TickInterval) - (forward * dragforce / bullet.Mass))
		local nextvelocity = velocity + acceleration * BlacksCW.TickInterval

		--debugoverlay.Line(position,  position + (forward * speed), 4, Color(255, 234, 34, 255), true)
		-- BlacksCW.BulletTrace(bullet, position, forward, speed)

		bullet.TraceData.start  = position
		bullet.TraceData.endpos = nextposition
		bullet.TraceResult      = util.TraceLine(bullet.TraceData)

		g_CapsuleHitboxes:IntersectRayWithEntities(bullet.TraceResult, {[bullet.Attacker] = true})

		local speedfrac = 1 - (speed / (bullet.InitialVelocity:Length() * BlacksCW.TickInterval))
		debugoverlay.Line(bullet.TraceResult.StartPos, bullet.TraceResult.HitPos, 4, Color(255 * speedfrac, 255, 255 * speedfrac, 255), true)
		--debugoverlay.BoxAngles(bullet.TraceResult.HitPos, Vector(-32, -1, -1), Vector(32, 1, 1), velocity:Angle(), 4, Color(0, 255, 0, 127))

		if bullet.TraceResult.Hit then
			debugoverlay.Cross(bullet.TraceResult.HitPos, 8, 4, Color(255 * speedfrac, 255, 255 * speedfrac, 255), true)
			local hitEntity = bullet.TraceResult.Entity
			if IsValid(hitEntity) and bullet.Attacker == localplayer then
				net.Start("BlacksCW_BulletImpact", true)
				net.WriteEntity(bullet.Inflictor)
				net.WriteEntity(hitEntity)
				net.WriteVector(bullet.TraceResult.HitPos)
				net.WriteNormal(velocity:GetNormalized())
				net.WriteFloat(velocity:Length() / BlacksCW.TickInterval)
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


-- -- see if we enter water during this simulation period
-- elseif bit.band(util.PointContents(bullet.TraceResult.HitPos), bit.bor(CONTENTS_WATER, CONTENTS_SLIME)) ~= 0 and
-- bit.band(util.PointContents(bullet.TraceResult.StartPos), bit.bor(CONTENTS_WATER, CONTENTS_SLIME)) == 0
-- then
-- local waterTrace = util.TraceLine({
--     start = bullet.TraceResult.StartPos,
--     endpos = bullet.TraceResult.HitPos,
--     mask = bit.bor(CONTENTS_WATER,CONTENTS_SLIME),
--     collisiongroup = COLLISION_GROUP_NONE,
-- })

-- if not waterTrace.AllSolid then
--     local data = EffectData()
--     data:SetOrigin(waterTrace.HitPos)
--     data:SetNormal(waterTrace.HitNormal)
--     data:SetScale(math.Rand(8, 12))

--     if bit.band(waterTrace.Contents, CONTENTS_SLIME) ~= 0 then
--         data:SetFlags(bit.bor(data:GetFlags(), FX_WATER_IN_SLIME))
--     else
--         data:SetFlags(bit.bnot(FX_WATER_IN_SLIME))
--     end

--     if SERVER and IsValid(ply) and ply:IsPlayer() then
--         SuppressHostEvents(ply)
--     end


--     util.Effect("gunshotsplash", data, not game.SinglePlayer())
-- end
-- end