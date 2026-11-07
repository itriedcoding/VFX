--[[
	Decompiler - turns existing instances in the place back into an editable VFX
	spec. Used by "Import from selection", so any ParticleEmitter/Beam/Trail
	behaviour a developer already built can be opened in the studio, retuned,
	saved as a preset and exported again.

	Effects exported by VFX Studio carry their spec in the VFXSpec attribute,
	so those round-trip losslessly. Third-party effects are reconstructed from
	real Roblox properties.
]]

local Util = require(script.Parent.Util)
local Format = require(script.Parent.Format)
local Compiler = require(script.Parent.Compiler)

local Decompiler = {}

local function colorKeypoints(sequence: ColorSequence): { any }
	local points = {}
	for _, keypoint in ipairs(sequence.Keypoints) do
		table.insert(points, { Util.round(keypoint.Time, 3), Util.toHex(keypoint.Value) })
	end
	if #points == 0 then
		return { { 0, "#ffffff" }, { 1, "#ffffff" } }
	end
	return points
end

local function numberKeypoints(sequence: NumberSequence): { any }
	local points = {}
	for _, keypoint in ipairs(sequence.Keypoints) do
		table.insert(points, { Util.round(keypoint.Time, 3), Util.round(keypoint.Value, 4) })
	end
	if #points == 0 then
		return { { 0, 1 }, { 1, 1 } }
	end
	return points
end

local function rangeOf(numberRange: NumberRange): { number }
	return { Util.round(numberRange.Min, 3), Util.round(numberRange.Max, 3) }
end

local function vectorToTable(vector: Vector3): { number }
	return { Util.round(vector.X, 3), Util.round(vector.Y, 3), Util.round(vector.Z, 3) }
end

local function relativePosition(a: Vector3?): { number }
	local offset = a or Vector3.new()
	return { Util.round(offset.X, 3), Util.round(offset.Y, 3), Util.round(offset.Z, 3) }
end

local function uniqueName(used: { [string]: boolean }, base: string): string
	local name = base
	if name == "" then
		name = "Component"
	end
	local suffix = 2
	while used[name] do
		name = base .. " " .. suffix
		suffix += 1
	end
	used[name] = true
	return name
end

local function squashOf(emitter: ParticleEmitter): number
	local ok, value = pcall(function()
		return emitter.Squash.Keypoints[1].Value
	end)
	if ok and type(value) == "number" then
		return Util.round(value, 3)
	end
	return 0
end

local function decompileParticle(emitter: ParticleEmitter, used: { [string]: boolean }): any
	return {
		kind = "particle",
		name = uniqueName(used, emitter.Name),
		offset = relativePosition(emitter.Parent and emitter.Parent:IsA("Attachment") and emitter.Parent.Position or nil),
		startTime = 0,
		duration = math.max(0.2, (emitter.Lifetime.Min + emitter.Lifetime.Max) * 0.5 * 2.4),
		texture = emitter.Texture,
		color = colorKeypoints(emitter.Color),
		transparency = numberKeypoints(emitter.Transparency),
		size = numberKeypoints(emitter.Size),
		lifetime = rangeOf(emitter.Lifetime),
		speed = rangeOf(emitter.Speed),
		spread = { Util.round(emitter.SpreadAngle.X, 1), Util.round(emitter.SpreadAngle.Y, 1) },
		rotation = rangeOf(emitter.Rotation),
		rotSpeed = rangeOf(emitter.RotSpeed),
		drag = Util.round(emitter.Drag, 3),
		acceleration = vectorToTable(emitter.Acceleration),
		rate = Util.round(emitter.Rate, 2),
		burst = 0,
		repeats = 1,
		lightEmission = Util.round(emitter.LightEmission, 3),
		lightInfluence = Util.round(emitter.LightInfluence, 3),
		shape = emitter.Shape.Name,
		shapeStyle = emitter.ShapeStyle.Name,
		shapeInOut = emitter.ShapeInOut.Name,
		shapePartial = Util.round(emitter.ShapePartial, 3),
		emissionDirection = emitter.EmissionDirection.Name,
		zOffset = Util.round(emitter.ZOffset, 3),
		squash = squashOf(emitter),
		windAffectsDrag = emitter.WindAffectsDrag,
		orientation = emitter.Orientation.Name,
		flipbookLayout = emitter.FlipbookLayout.Name,
		flipbookFramerate = rangeOf(emitter.FlipbookFramerate),
		flipbookRandom = emitter.FlipbookStartRandom,
		lockedToPart = emitter.LockedToPart,
		velocityInheritance = Util.round(emitter.VelocityInheritance, 3),
		timeScale = 1,
	}
end

local function decompileBeam(beam: Beam, used: { [string]: boolean }): any
	local a = beam.Attachment0
	local b = beam.Attachment1
	return {
		kind = "beam",
		name = uniqueName(used, beam.Name),
		offset0 = relativePosition(a and a.Position),
		offset1 = relativePosition(b and b.Position),
		startTime = 0,
		duration = 1,
		texture = beam.Texture,
		color = colorKeypoints(beam.Color),
		transparency = numberKeypoints(beam.Transparency),
		width0 = Util.round(beam.Width0, 3),
		width1 = Util.round(beam.Width1, 3),
		curveSize0 = Util.round(beam.CurveSize0, 3),
		curveSize1 = Util.round(beam.CurveSize1, 3),
		segments = beam.Segments,
		brightness = Util.round(beam.Brightness, 2),
		lightEmission = Util.round(beam.LightEmission, 3),
		lightInfluence = Util.round(beam.LightInfluence, 3),
		textureLength = Util.round(beam.TextureLength, 3),
		textureSpeed = Util.round(beam.TextureSpeed, 3),
		textureMode = beam.TextureMode.Name,
		faceCamera = beam.FaceCamera,
		zOffset = Util.round(beam.ZOffset, 3),
	}
end

local function decompileTrail(trail: Trail, used: { [string]: boolean }): any
	local a = trail.Attachment0
	local b = trail.Attachment1
	return {
		kind = "trail",
		name = uniqueName(used, trail.Name),
		offset0 = relativePosition(a and a.Position),
		offset1 = relativePosition(b and b.Position),
		startTime = 0,
		duration = 1,
		texture = trail.Texture,
		color = colorKeypoints(trail.Color),
		transparency = numberKeypoints(trail.Transparency),
		lifetime = Util.round(trail.Lifetime, 3),
		minLength = Util.round(trail.MinLength, 3),
		widthScale = Util.round(trail.WidthScale, 3),
		faceCamera = trail.FaceCamera,
		lightEmission = Util.round(trail.LightEmission, 3),
	}
end

local function decompileLight(light: PointLight, used: { [string]: boolean }): any
	return {
		kind = "light",
		name = uniqueName(used, light.Name),
		offset = relativePosition(light.Parent and light.Parent:IsA("Attachment") and light.Parent.Position or nil),
		startTime = 0,
		duration = 1,
		color = Util.toHex(light.Color),
		brightness = Util.round(light.Brightness, 2),
		range = Util.round(light.Range, 1),
		shadows = light.Shadows,
	}
end

local function decompilePart(part: BasePart, origin: CFrame, used: { [string]: boolean }): any
	local offset = origin:ToObjectSpace(part.CFrame).Position
	return {
		kind = "part",
		name = uniqueName(used, part.Name),
		offset = { Util.round(offset.X, 3), Util.round(offset.Y, 3), Util.round(offset.Z, 3) },
		startTime = 0,
		duration = 1,
		size = { Util.round(part.Size.X, 3), Util.round(part.Size.Y, 3), Util.round(part.Size.Z, 3) },
		color = Util.toHex(part.Color),
		transparency = Util.round(part.Transparency, 3),
		material = part.Material.Name,
		shape = if part:IsA("Part") and part.Shape == Enum.PartType.Ball then "Ball" elseif part:IsA("Part") and part.Shape == Enum.PartType.Cylinder then "Cylinder" else "Block",
		rotation = { 0, 0, 0 },
		spin = { 0, 0, 0 },
		float = 0,
	}
end

--- Returns true when the instance tree contains anything VFX Studio can read.
function Decompiler.canImport(root: Instance): boolean
	if Compiler.readSpec(root) then
		return true
	end
	if root:IsA("ParticleEmitter") or root:IsA("Beam") or root:IsA("Trail") or root:IsA("PointLight") then
		return true
	end
	for _, descendant in ipairs(root:GetDescendants()) do
		if descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("Trail") or descendant:IsA("PointLight") then
			return true
		end
	end
	return false
end

--- Converts a selected instance (or model) into a spec.
function Decompiler.fromInstance(root: Instance): any?
	if not root then
		return nil
	end

	-- Fast path: effects exported by VFX Studio keep their spec.
	local stored = Compiler.readSpec(root)
	if stored then
		return {
			id = "imported_" .. Util.slug(root.Name),
			name = tostring(stored.name or root.Name),
			category = "Custom",
			tags = { "imported" },
			description = "Imported from " .. root:GetFullName() .. ".",
			duration = tonumber(stored.duration) or 1.5,
			loop = stored.loop == true,
			components = stored.components,
		}
	end

	local origin: CFrame
	if root:IsA("BasePart") then
		origin = root.CFrame
	else
		local rig = Compiler.rigOf(root)
		origin = rig and rig.CFrame or CFrame.new()
	end

	local used: { [string]: boolean } = {}
	local components = {}
	local maxLifetime = 0.6

	local function consider(instance: Instance)
		local ok, comp = pcall(function()
			if instance:IsA("ParticleEmitter") then
				return decompileParticle(instance, used)
			elseif instance:IsA("Beam") then
				return decompileBeam(instance, used)
			elseif instance:IsA("Trail") then
				return decompileTrail(instance, used)
			elseif instance:IsA("PointLight") then
				return decompileLight(instance, used)
			end
			return nil
		end)
		if ok and comp then
			if comp.kind == "particle" then
				maxLifetime = math.max(maxLifetime, tonumber(comp.lifetime[2]) or 0.6)
			end
			table.insert(components, comp)
		elseif not ok then
			warn("[VFX Studio] could not import " .. instance:GetFullName() .. ": " .. tostring(comp))
		end
	end

	consider(root)
	for _, descendant in ipairs(root:GetDescendants()) do
		consider(descendant)
	end

	-- Include decorative mesh parts (non-Rig, visible geometry) as components.
	local rootPart = if root:IsA("BasePart") then root else Compiler.rigOf(root)
	for _, descendant in ipairs(root:GetDescendants()) do
		if descendant:IsA("BasePart") and descendant ~= rootPart and descendant.Transparency < 1 then
			local ok, comp = pcall(decompilePart, descendant, origin, used)
			if ok and comp then
				table.insert(components, comp)
			end
		end
	end

	if #components == 0 then
		return nil
	end

	return {
		id = "imported_" .. Util.slug(root.Name),
		name = tostring(root.Name ~= "" and root.Name or "Imported Effect"),
		category = "Custom",
		tags = { "imported" },
		description = "Imported from " .. root:GetFullName() .. " with " .. #components .. " component(s).",
		duration = math.clamp(maxLifetime * 2.2, 0.8, 8),
		loop = false,
		components = components,
	}
end

--- Imports every effect found inside a selection, merging them into one spec.
function Decompiler.fromSelection(): { any }
	local imported = {}
	for _, instance in ipairs(Util.Selection:Get()) do
		local ok, spec = pcall(Decompiler.fromInstance, instance)
		if ok and spec then
			table.insert(imported, spec)
		end
	end
	return imported
end

return Decompiler
