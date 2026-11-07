--[[
	Compiler - turns a VFX spec into real Roblox instances, and keeps those
	instances in sync while the developer edits.

	Effect hierarchy (what gets exported):

		Model "Inferno Core"          attributes: VFXSpec, VFXStudio, ...
			Part "Rig"                invisible anchored host
				Attachment "Core"
					ParticleEmitter "Core"
				Attachment "Arc_A"
				Attachment "Arc_B"
					Beam "Arc"
				Part "Shockwave"       mesh/visual parts
]]

local Util = require(script.Parent.Util)
local Format = require(script.Parent.Format)
local Assets = require(script.Parent.Assets)

local Compiler = {}

Compiler.SCHEMA_VERSION = 2
Compiler.RIG_NAME = "Rig"

local function clamp01(value: any): number
	local parsed = tonumber(value) or 0
	return math.clamp(parsed, 0, 1)
end

local function positive(value: any, fallback: number): number
	local parsed = tonumber(value)
	if parsed == nil then
		return fallback
	end
	return math.max(0, parsed)
end

local function safeName(name: any): string
	local text = tostring(name or "Effect")
	text = text:gsub("[%c]", "")
	if #text > 80 then
		text = text:sub(1, 80)
	end
	if text == "" then
		text = "Effect"
	end
	return text
end

local function uniqueName(model: Instance, base: string): string
	if not model:FindFirstChild(base, true) then
		return base
	end
	local index = 2
	while model:FindFirstChild(base .. " " .. index, true) do
		index += 1
	end
	return base .. " " .. index
end

function Compiler.rigOf(model: Instance): Part?
	local rig = model:FindFirstChild(Compiler.RIG_NAME)
	if rig and rig:IsA("BasePart") then
		return rig
	end
	return nil
end

--------------------------------------------------------------------------------
-- property application
--------------------------------------------------------------------------------

local function applyParticle(emitter: ParticleEmitter, comp: any)
	Util.apply(emitter, {
		Texture = Assets.resolve(comp.texture),
		Color = Format.colorSequence(comp.color),
		Transparency = Format.transparency(comp.transparency),
		Size = Format.numberSequence(comp.size),
		Lifetime = Format.numberRange(comp.lifetime, 1),
		Speed = Format.numberRange(comp.speed, 0),
		SpreadAngle = Format.vector2(comp.spread, 0),
		Rotation = Format.numberRange(comp.rotation, 0),
		RotSpeed = Format.numberRange(comp.rotSpeed, 0),
		Drag = positive(comp.drag, 0),
		Acceleration = Format.vector3(comp.acceleration),
		Rate = positive(comp.rate, 0),
		LightEmission = clamp01(comp.lightEmission),
		LightInfluence = clamp01(comp.lightInfluence),
		Shape = Format.enum(Enum.ParticleEmitterShape, comp.shape, "Sphere"),
		ShapeStyle = Format.enum(Enum.ParticleEmitterShapeStyle, comp.shapeStyle, "Volume"),
		ShapeInOut = Format.enum(Enum.ParticleEmitterShapeInOut, comp.shapeInOut, "Outward"),
		ShapePartial = clamp01(comp.shapePartial),
		EmissionDirection = Format.enum(Enum.NormalId, comp.emissionDirection, "Top"),
		ZOffset = tonumber(comp.zOffset) or 0,
		Squash = NumberSequence.new(clamp01(comp.squash)),
		WindAffectsDrag = comp.windAffectsDrag == true,
		Orientation = Format.enum(Enum.ParticleOrientation, comp.orientation, "FacingCamera"),
		FlipbookLayout = Format.enum(Enum.ParticleFlipbookLayout, comp.flipbookLayout, "None"),
		FlipbookFramerate = Format.numberRange(comp.flipbookFramerate, 30),
		FlipbookStartRandom = comp.flipbookRandom ~= false,
		LockedToPart = comp.lockedToPart == true,
		VelocityInheritance = clamp01(comp.velocityInheritance),
		TimeScale = math.max(0.05, tonumber(comp.timeScale) or 1),
	})
	emitter.Enabled = positive(comp.rate, 0) > 0
end

local function applyBeam(beam: Beam, comp: any)
	Util.apply(beam, {
		Texture = Assets.resolve(comp.texture),
		Color = Format.colorSequence(comp.color),
		Transparency = Format.transparency(comp.transparency),
		Width0 = positive(comp.width0, 0.2),
		Width1 = positive(comp.width1, 0.2),
		CurveSize0 = math.clamp(tonumber(comp.curveSize0) or 0, -5, 5),
		CurveSize1 = math.clamp(tonumber(comp.curveSize1) or 0, -5, 5),
		Segments = math.clamp(math.floor(tonumber(comp.segments) or 10), 1, 100),
		Brightness = positive(comp.brightness, 1),
		LightEmission = clamp01(comp.lightEmission),
		LightInfluence = clamp01(comp.lightInfluence),
		TextureLength = math.max(0.01, tonumber(comp.textureLength) or 1),
		TextureSpeed = tonumber(comp.textureSpeed) or 0,
		TextureMode = Format.enum(Enum.TextureMode, comp.textureMode, "Stretch"),
		FaceCamera = comp.faceCamera ~= false,
		ZOffset = tonumber(comp.zOffset) or 0,
	})
end

local function applyTrail(trail: Trail, comp: any)
	Util.apply(trail, {
		Texture = Assets.resolve(comp.texture),
		Color = Format.colorSequence(comp.color),
		Transparency = Format.transparency(comp.transparency),
		Lifetime = math.clamp(tonumber(comp.lifetime) or 0.5, 0, 20),
		MinLength = positive(comp.minLength, 0),
		WidthScale = positive(comp.widthScale, 1),
		LightEmission = clamp01(comp.lightEmission),
		FaceCamera = comp.faceCamera ~= false,
	})
end

local function applyLight(light: PointLight, comp: any)
	Util.apply(light, {
		Color = Util.hex(comp.color),
		Brightness = positive(comp.brightness, 1),
		Range = math.max(0, tonumber(comp.range) or 16),
		Shadows = comp.shadows == true,
	})
end

local function applyPart(part: BasePart, comp: any)
	local size = Format.vector3(comp.size)
	Util.apply(part, {
		Size = Vector3.new(math.max(0.05, size.X), math.max(0.05, size.Y), math.max(0.05, size.Z)),
		Color = Util.hex(comp.color),
		Transparency = math.clamp(tonumber(comp.transparency) or 0, 0, 1),
		Material = Format.enum(Enum.Material, comp.material, "Neon"),
		Shape = Format.enum(Enum.PartType, comp.shape, "Ball"),
		CFrame = CFrame.new(Format.vector3(comp.offset))
			* CFrame.Angles(
				math.rad(tonumber((comp.rotation :: any)[1]) or 0),
				math.rad(tonumber((comp.rotation :: any)[2]) or 0),
				math.rad(tonumber((comp.rotation :: any)[3]) or 0)
			),
	})
	if comp.shape == "Cylinder" then
		part.Shape = Enum.PartType.Cylinder
	elseif comp.shape == "Wedge" then
		-- Wedge is a different class; keep Ball/Block/Cylinder safe.
		part.Shape = Enum.PartType.Block
	end
end

--- Applies the visual properties of a component to its created instances.
function Compiler.apply(entry: any, comp: any)
	if comp.kind == "particle" then
		if entry.primary:IsA("ParticleEmitter") then
			applyParticle(entry.primary, comp)
		end
		if entry.attachment then
			entry.attachment.Position = Format.vector3(comp.offset)
		end
	elseif comp.kind == "beam" then
		if entry.primary:IsA("Beam") then
			applyBeam(entry.primary, comp)
		end
		if entry.attachmentA and entry.attachmentB then
			entry.attachmentA.Position = Format.vector3(comp.offset0)
			entry.attachmentB.Position = Format.vector3(comp.offset1)
			entry.primary.Attachment0 = entry.attachmentA
			entry.primary.Attachment1 = entry.attachmentB
		end
	elseif comp.kind == "trail" then
		if entry.primary:IsA("Trail") then
			applyTrail(entry.primary, comp)
		end
		if entry.attachmentA and entry.attachmentB then
			entry.attachmentA.Position = Format.vector3(comp.offset0)
			entry.attachmentB.Position = Format.vector3(comp.offset1)
			entry.primary.Attachment0 = entry.attachmentA
			entry.primary.Attachment1 = entry.attachmentB
		end
	elseif comp.kind == "light" then
		if entry.primary:IsA("PointLight") then
			applyLight(entry.primary, comp)
		end
		if entry.attachment then
			entry.attachment.Position = Format.vector3(comp.offset)
		end
	elseif comp.kind == "part" then
		if entry.primary:IsA("BasePart") then
			applyPart(entry.primary, comp)
		end
	end
end

--------------------------------------------------------------------------------
-- instance creation
--------------------------------------------------------------------------------

local function markInstances(entry: any, comp: any)
	local name = safeName(comp.name)
	for _, inst in ipairs(entry.all or {}) do
		inst:SetAttribute("VFXComponent", name)
		inst:SetAttribute("VFXKind", comp.kind)
	end
end

local function newAttachment(rig: BasePart, name: string, position: Vector3): Attachment
	local attachment = Instance.new("Attachment")
	attachment.Name = name
	attachment.Position = position
	attachment.Visible = false
	attachment.Parent = rig
	return attachment
end

local function createComponent(model: Instance, rig: BasePart, comp: any): any
	local name = safeName(comp.name)
	if comp.kind == "particle" then
		local attachment = newAttachment(rig, name, Format.vector3(comp.offset))
		local emitter = Instance.new("ParticleEmitter")
		emitter.Name = name
		emitter.Parent = attachment
		local entry = { primary = emitter, attachment = attachment, all = { attachment, emitter }, kind = comp.kind, name = name }
		markInstances(entry, comp)
		return entry
	elseif comp.kind == "beam" or comp.kind == "trail" then
		local a = newAttachment(rig, name .. "_A", Format.vector3(comp.offset0))
		local b = newAttachment(rig, name .. "_B", Format.vector3(comp.offset1))
		local fx
		if comp.kind == "beam" then
			fx = Instance.new("Beam")
		else
			fx = Instance.new("Trail")
		end
		fx.Name = name
		fx.Parent = rig
		local entry = { primary = fx, attachmentA = a, attachmentB = b, all = { a, b, fx }, kind = comp.kind, name = name }
		markInstances(entry, comp)
		if fx:IsA("Beam") then
			fx.Attachment0 = a
			fx.Attachment1 = b
		elseif fx:IsA("Trail") then
			fx.Attachment0 = a
			fx.Attachment1 = b
		end
		return entry
	elseif comp.kind == "light" then
		local attachment = newAttachment(rig, name, Format.vector3(comp.offset))
		local light = Instance.new("PointLight")
		light.Name = name
		light.Parent = attachment
		local entry = { primary = light, attachment = attachment, all = { attachment, light }, kind = comp.kind, name = name }
		markInstances(entry, comp)
		return entry
	elseif comp.kind == "part" then
		local part = Instance.new("Part")
		part.Name = name
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.CastShadow = false
		part.Massless = true
		part.TopSurface = Enum.SurfaceType.Smooth
		part.BottomSurface = Enum.SurfaceType.Smooth
		part.Parent = model
		local entry = { primary = part, all = { part }, kind = comp.kind, name = name }
		markInstances(entry, comp)
		return entry
	elseif comp.kind == "tween" then
		-- Timeline tracks are data only; the player interprets them.
		local entry = { primary = rig, kind = comp.kind, name = name, all = {}, virtual = true }
		return entry
	end
	return nil
end

--------------------------------------------------------------------------------
-- public API
--------------------------------------------------------------------------------

--- Builds a fresh effect model. Does not parent to the DataModel unless asked.
function Compiler.build(spec: any, parent: Instance?): Model
	local model = Instance.new("Model")
	model.Name = safeName(spec.name)

	local rig = Instance.new("Part")
	rig.Name = Compiler.RIG_NAME
	rig.Anchored = true
	rig.CanCollide = false
	rig.CanQuery = false
	rig.CanTouch = false
	rig.CastShadow = false
	rig.Massless = true
	rig.Locked = true
	rig.Transparency = 1
	rig.Size = Vector3.new(0.2, 0.2, 0.2)
	rig.Material = Enum.Material.SmoothPlastic
	rig.TopSurface = Enum.SurfaceType.Smooth
	rig.BottomSurface = Enum.SurfaceType.Smooth
	rig.CFrame = CFrame.new(0, 0, 0)
	rig.Parent = model

	local bindings = {}
	for _, comp in ipairs(spec.components or {}) do
		local entry = createComponent(model, rig, comp)
		if entry then
			Compiler.apply(entry, comp)
			bindings[entry.name] = entry
		end
	end

	model:SetAttribute("VFXStudio", true)
	model:SetAttribute("VFXSchema", Compiler.SCHEMA_VERSION)
	Compiler.writeSpecAttribute(model, spec)

	if parent then
		model.Parent = parent
	end
	return model
end

function Compiler.writeSpecAttribute(model: Instance, spec: any)
	local json = Format.jsonEncode({
		name = spec.name,
		category = spec.category,
		tags = spec.tags,
		description = spec.description,
		duration = spec.duration,
		loop = spec.loop,
		components = spec.components,
	})
	if json then
		model:SetAttribute("VFXSpec", json)
	end
	model:SetAttribute("VFXCategory", tostring(spec.category or ""))
	model:SetAttribute("VFXTags", table.concat(spec.tags or {}, ", "))
	model:SetAttribute("VFXDuration", tonumber(spec.duration) or 1)
	model:SetAttribute("VFXPresetId", tostring(spec.id or ""))
	model:SetAttribute("VFXComponentCount", #(spec.components or {}))
end

--- Collects the existing component instances of a compiled model.
function Compiler.resolve(model: Instance): { [string]: any }
	local bindings = {}
	local rig = Compiler.rigOf(model)
	local attachments: { [string]: Attachment } = {}
	if rig then
		for _, descendant in ipairs(rig:GetDescendants()) do
			if descendant:IsA("Attachment") then
				attachments[descendant.Name] = descendant
			end
		end
	end

	for _, descendant in ipairs(model:GetDescendants()) do
		local name = descendant:GetAttribute("VFXComponent")
		local kind = descendant:GetAttribute("VFXKind")
		if name and kind then
			local entry = bindings[name]
			if not entry then
				entry = { name = name, kind = kind, all = {} }
				bindings[name] = entry
			end
			table.insert(entry.all, descendant)
			if descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("Trail") or descendant:IsA("PointLight") then
				entry.primary = descendant
				entry.attachment = descendant.Parent
			elseif descendant:IsA("Attachment") then
				if string.sub(descendant.Name, -2) == "_A" then
					entry.attachmentA = descendant
				elseif string.sub(descendant.Name, -2) == "_B" then
					entry.attachmentB = descendant
				else
					entry.attachment = descendant
				end
			elseif descendant:IsA("BasePart") and descendant ~= rig then
				entry.primary = descendant
			end
		end
	end

	-- Beam/trail attachments were created with a "_A"/"_B" suffix so a
	-- component owns exactly one pair; reconstruct them by name if needed.
	for name, entry in pairs(bindings) do
		if entry.kind == "beam" or entry.kind == "trail" then
			entry.attachmentA = entry.attachmentA or attachments[name .. "_A"]
			entry.attachmentB = entry.attachmentB or attachments[name .. "_B"]
		end
		if entry.kind == "tween" then
			entry.primary = rig
			entry.virtual = true
		end
	end
	return bindings
end

--- Brings an existing model up to date with `spec`, recreating only the
--- components whose structure changed (keeps particle continuity while
--- tweaking properties, which matters for live preview).
function Compiler.reconcile(model: Model, spec: any): { [string]: any }
	local rig = Compiler.rigOf(model)
	if not rig then
		error("VFX Studio: model has no Rig part")
	end

	local existing = Compiler.resolve(model)
	local wanted: { [string]: boolean } = {}
	local bindings: { [string]: any } = {}

	for _, comp in ipairs(spec.components or {}) do
		local name = safeName(comp.name)
		wanted[name] = true
		local entry = existing[name]
		if entry and entry.kind == comp.kind and comp.kind ~= "tween" then
			Compiler.apply(entry, comp)
			entry.name = name
			markInstances(entry, comp)
			-- Keep the display name in sync when the component was renamed in
			-- place (same entry) - skip, rename creates a new entry.
			bindings[name] = entry
		elseif comp.kind == "tween" then
			local tweenEntry = entry or { name = name, kind = "tween", all = {}, virtual = true }
			tweenEntry.primary = rig
			bindings[name] = tweenEntry
		else
			if entry then
				for _, inst in ipairs(entry.all) do
					inst:Destroy()
				end
			end
			local created = createComponent(model, rig, comp)
			if created then
				Compiler.apply(created, comp)
				bindings[name] = created
			end
		end
	end

	-- Remove components that no longer exist in the spec.
	for name, entry in pairs(existing) do
		if not wanted[name] then
			for _, inst in ipairs(entry.all) do
				if inst and inst.Parent then
					inst:Destroy()
				end
			end
		end
	end

	model.Name = safeName(spec.name)
	Compiler.writeSpecAttribute(model, spec)
	return bindings
end

--- Returns the spec stored on a compiled/exported model, if any.
function Compiler.readSpec(model: Instance): any?
	local json = model:GetAttribute("VFXSpec")
	local decoded = Format.jsonDecode(if type(json) == "string" then json else nil)
	if type(decoded) == "table" and type(decoded.components) == "table" then
		return decoded
	end
	return nil
end

--- Positions an effect model at a CFrame (used by preview and insertion).
function Compiler.place(model: Model, cframe: CFrame)
	local rig = Compiler.rigOf(model)
	if rig then
		rig.CFrame = cframe
	end
end

return Compiler
