--[[
	Inspector - the right-hand panel.

	Three tabs:
	  Properties  effect metadata, the component stack (drag to reorder) and
	              every real property of the selected component.
	  Curves      colour gradient editor, opacity curve and size curve, with a
	              real HSV picker and per-keypoint editing.
	  Cost        live performance report with actionable fixes.
]]

local Util = require(script.Parent.Parent.Core.Util)
local Theme = require(script.Parent.Parent.Core.Theme)
local Format = require(script.Parent.Parent.Core.Format)
local Assets = require(script.Parent.Parent.Core.Assets)
local Performance = require(script.Parent.Parent.Core.Performance)
local Kit = require(script.Parent.Kit)

local UserInputService = game:GetService("UserInputService")

local Inspector = {}
Inspector.__index = Inspector

local KIND_LABELS = {
	particle = "Particles",
	beam = "Beam",
	trail = "Trail",
	light = "Light",
	part = "Mesh part",
	tween = "Motion",
}

local KIND_GLYPHS = {
	particle = "\u{273b}",
	beam = "\u{2726}",
	trail = "\u{2192}",
	light = "\u{2600}",
	part = "\u{25c6}",
	tween = "\u{21bb}",
}

local ADD_OPTIONS = {
	{ value = "particle", label = "Particle emitter" },
	{ value = "beam", label = "Beam" },
	{ value = "trail", label = "Trail" },
	{ value = "light", label = "Point light" },
	{ value = "part", label = "Mesh part" },
	{ value = "tween", label = "Motion track" },
}

local PARTICLE_FIELDS = {
	{ key = "texture", label = "Texture", type = "texture" },
	{ key = "rate", label = "Rate", type = "number", min = 0, max = 600, step = 1, unit = "/s" },
	{ key = "lifetime", label = "Lifetime", type = "range", min = 0.05, max = 10, step = 0.05, unit = "s" },
	{ key = "speed", label = "Speed", type = "range", min = 0, max = 120, step = 0.5 },
	{ key = "spread", label = "Spread", type = "vector2", min = 0, max = 180 },
	{ key = "acceleration", label = "Acceleration", type = "vector3", min = -100, max = 100 },
	{ key = "drag", label = "Drag", type = "number", min = 0, max = 20, step = 0.05 },
	{ key = "rotation", label = "Rotation", type = "range", min = -360, max = 360, step = 1 },
	{ key = "rotSpeed", label = "Spin", type = "range", min = -720, max = 720, step = 5 },
	{ key = "size", label = "Size over life", type = "curve" },
	{ key = "transparency", label = "Opacity over life", type = "curve01" },
	{ key = "color", label = "Colour over life", type = "color" },
	{ key = "lightEmission", label = "Light emission", type = "number", min = 0, max = 1, step = 0.01 },
	{ key = "lightInfluence", label = "Light influence", type = "number", min = 0, max = 1, step = 0.01 },
	{ key = "shape", label = "Shape", type = "enum", enum = "ParticleEmitterShape" },
	{ key = "shapeStyle", label = "Shape style", type = "enum", enum = "ParticleEmitterShapeStyle" },
	{ key = "shapeInOut", label = "Shape in/out", type = "enum", enum = "ParticleEmitterShapeInOut" },
	{ key = "shapePartial", label = "Shape partial", type = "number", min = 0, max = 1, step = 0.01 },
	{ key = "emissionDirection", label = "Emission dir", type = "enum", enum = "ParticleEmitterEmissionDirection" },
	{ key = "orientation", label = "Orientation", type = "enum", enum = "ParticleOrientation" },
	{ key = "squash", label = "Squash", type = "number", min = 0, max = 1, step = 0.01 },
	{ key = "zOffset", label = "Z offset", type = "number", min = -20, max = 20, step = 0.1 },
	{ key = "velocityInheritance", label = "Velocity inherit", type = "number", min = 0, max = 1, step = 0.01 },
	{ key = "lockedToPart", label = "Locked to part", type = "boolean" },
	{ key = "windAffectsDrag", label = "Wind affects drag", type = "boolean" },
}

local BEAM_FIELDS = {
	{ key = "texture", label = "Texture", type = "texture" },
	{ key = "width0", label = "Width start", type = "number", min = 0, max = 20, step = 0.05 },
	{ key = "width1", label = "Width end", type = "number", min = 0, max = 20, step = 0.05 },
	{ key = "curveSize0", label = "Curve start", type = "number", min = -5, max = 5, step = 0.1 },
	{ key = "curveSize1", label = "Curve end", type = "number", min = -5, max = 5, step = 0.1 },
	{ key = "segments", label = "Segments", type = "number", min = 1, max = 100, step = 1 },
	{ key = "brightness", label = "Brightness", type = "number", min = 0, max = 10, step = 0.1 },
	{ key = "lightEmission", label = "Light emission", type = "number", min = 0, max = 1, step = 0.01 },
	{ key = "lightInfluence", label = "Light influence", type = "number", min = 0, max = 1, step = 0.01 },
	{ key = "textureLength", label = "Texture length", type = "number", min = 0.01, max = 20, step = 0.05 },
	{ key = "textureSpeed", label = "Texture speed", type = "number", min = -10, max = 10, step = 0.1 },
	{ key = "textureMode", label = "Texture mode", type = "enum", enum = "TextureMode" },
	{ key = "faceCamera", label = "Face camera", type = "boolean" },
	{ key = "zOffset", label = "Z offset", type = "number", min = -20, max = 20, step = 0.1 },
	{ key = "color", label = "Colour", type = "color" },
	{ key = "transparency", label = "Opacity", type = "curve01" },
	{ key = "offset1", label = "End offset", type = "vector3", min = -40, max = 40 },
}

local TRAIL_FIELDS = {
	{ key = "texture", label = "Texture", type = "texture" },
	{ key = "lifetime", label = "Lifetime", type = "number", min = 0.05, max = 10, step = 0.05, unit = "s" },
	{ key = "minLength", label = "Min length", type = "number", min = 0, max = 10, step = 0.05 },
	{ key = "widthScale", label = "Width scale", type = "number", min = 0, max = 8, step = 0.05 },
	{ key = "lightEmission", label = "Light emission", type = "number", min = 0, max = 1, step = 0.01 },
	{ key = "faceCamera", label = "Face camera", type = "boolean" },
	{ key = "color", label = "Colour", type = "color" },
	{ key = "transparency", label = "Opacity", type = "curve01" },
	{ key = "offset0", label = "Start offset", type = "vector3", min = -20, max = 20 },
	{ key = "offset1", label = "End offset", type = "vector3", min = -20, max = 20 },
}

local LIGHT_FIELDS = {
	{ key = "color", label = "Colour", type = "swatch" },
	{ key = "brightness", label = "Brightness", type = "number", min = 0, max = 20, step = 0.1 },
	{ key = "range", label = "Range", type = "number", min = 0, max = 80, step = 0.5 },
	{ key = "shadows", label = "Shadows", type = "boolean" },
	{ key = "offset", label = "Offset", type = "vector3", min = -40, max = 40 },
}

local PART_FIELDS = {
	{ key = "color", label = "Colour", type = "swatch" },
	{ key = "size", label = "Size", type = "vector3", min = 0.1, max = 40 },
	{ key = "transparency", label = "Transparency", type = "number", min = 0, max = 1, step = 0.01 },
	{ key = "material", label = "Material", type = "enum", enum = "Material" },
	{ key = "shape", label = "Shape", type = "options", options = { "Block", "Ball", "Cylinder", "Wedge" } },
	{ key = "rotation", label = "Rotation", type = "vector3", min = -360, max = 360 },
	{ key = "spin", label = "Spin", type = "vector3", min = -360, max = 360 },
	{ key = "float", label = "Float", type = "number", min = -20, max = 20, step = 0.1 },
	{ key = "offset", label = "Offset", type = "vector3", min = -40, max = 40 },
}

local TWEEN_FIELDS = {
	{ key = "property", label = "Property", type = "options", options = { "spin", "float", "brightness", "transparency", "scale" } },
	{ key = "target", label = "Target", type = "target" },
	{ key = "from", label = "From", type = "number", min = -720, max = 720, step = 1 },
	{ key = "to", label = "To", type = "number", min = -720, max = 720, step = 1 },
	{ key = "easing", label = "Easing", type = "enum", enum = "EasingStyle" },
	{ key = "direction", label = "Direction", type = "enum", enum = "EasingDirection" },
	{ key = "repeatCount", label = "Repeat count", type = "number", min = 0, max = 100, step = 1 },
	{ key = "reverse", label = "Reverse", type = "boolean" },
}

local SCHEMA = {
	particle = PARTICLE_FIELDS,
	beam = BEAM_FIELDS,
	trail = TRAIL_FIELDS,
	light = LIGHT_FIELDS,
	part = PART_FIELDS,
	tween = TWEEN_FIELDS,
}

local COLOR_PRESETS = {
	{ name = "Inferno", colors = { "#fff3b0", "#ff9a1f", "#e02c00" } },
	{ name = "Ice", colors = { "#ffffff", "#9fe4ff", "#2a6fff" } },
	{ name = "Toxic", colors = { "#eaffb0", "#8dff3d", "#1fa34a" } },
	{ name = "Gold", colors = { "#fffbe0", "#ffd75e", "#c98a00" } },
	{ name = "Void", colors = { "#e3c6ff", "#8a4bff", "#2c0f52" } },
	{ name = "Arcane", colors = { "#d9fbff", "#46e0ff", "#5f3bff" } },
	{ name = "Blood", colors = { "#ffb0b0", "#e02020", "#5d0000" } },
	{ name = "Plasma", colors = { "#fdffe0", "#5cffb0", "#0f7bff" } },
}

--------------------------------------------------------------------------------
-- colour helpers
--------------------------------------------------------------------------------

local function sampleColor(points: { any }, alpha: number): Color3
	if not points or #points == 0 then
		return Theme.color.white
	end
	if #points == 1 then
		return Util.hex(points[1][2])
	end
	local low = points[1]
	local high = points[#points]
	for index = 1, #points - 1 do
		if alpha >= (points[index][1] or 0) and alpha <= (points[index + 1][1] or 0) then
			low = points[index]
			high = points[index + 1]
			break
		end
	end
	local timeLow = tonumber(low[1]) or 0
	local timeHigh = tonumber(high[1]) or 1
	local span = timeHigh - timeLow
	local fraction = if span <= 0 then 0 else (alpha - timeLow) / span
	return Util.hex(low[2]):Lerp(Util.hex(high[2]), math.clamp(fraction, 0, 1))
end

local function sampleNumber(points: { any }, alpha: number): number
	if not points or #points == 0 then
		return 0
	end
	if #points == 1 then
		return tonumber(points[1][2]) or 0
	end
	local low = points[1]
	local high = points[#points]
	for index = 1, #points - 1 do
		if alpha >= (points[index][1] or 0) and alpha <= (points[index + 1][1] or 0) then
			low = points[index]
			high = points[index + 1]
			break
		end
	end
	local timeLow = tonumber(low[1]) or 0
	local timeHigh = tonumber(high[1]) or 1
	local span = timeHigh - timeLow
	local fraction = if span <= 0 then 0 else (alpha - timeLow) / span
	return Util.lerp(tonumber(low[2]) or 0, tonumber(high[2]) or 0, math.clamp(fraction, 0, 1))
end

local function sorted(points: { any }): { any }
	local copy = {}
	for _, point in ipairs(points) do
		table.insert(copy, { tonumber(point[1]) or 0, point[2] })
	end
	table.sort(copy, function(a, b)
		return a[1] < b[1]
	end)
	return copy
end

--------------------------------------------------------------------------------
-- construction
--------------------------------------------------------------------------------

function Inspector.new(parent: Instance, ctx: any)
	local self = setmetatable({}, Inspector)
	self.ctx = ctx
	self.store = ctx.store
	self.tab = "Properties"		self.curveMode = "color"
		self.activeStop = 1
		self.interacting = false
		self.connections = {}
		self.leftWidth = 286

	local root = Kit.frame(parent, {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Theme.color.bg1,
	})
	self.root = root

	local header = Kit.frame(root, {
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundTransparency = 1,
		ClipsDescendants = false,
	})
	Kit.label(header, "Inspector", {
		Position = UDim2.fromOffset(12, 8),
		Size = UDim2.new(1, -24, 0, 16),
		Font = Theme.font.bold,
		TextSize = Theme.text.title,
	})

	self.tabBar = Kit.hlist(root, 4, {
		Size = UDim2.new(1, -20, 0, 26),
		Position = UDim2.fromOffset(10, 34),
	})
	self.tabBar.AutomaticSize = Enum.AutomaticSize.None
	self.tabBar.Size = UDim2.new(1, -20, 0, 26)

	self.tabButtons = {}
	local tabNames = {
		{ name = "Properties", label = "Properties" },
		{ name = "Curves", label = "Curves" },
		{ name = "Cost", label = "Cost" },
	}
	for _, entry in ipairs(tabNames) do
		local button = Kit.button(self.tabBar, entry.label, {
			variant = "ghost",
			height = 24,
			size = UDim2.fromOffset(entry.name == "Properties" and 82 or 62, 24),
			textSize = Theme.text.small,
			onClick = function()
				self:showTab(entry.name)
			end,
		})
		button.TextColor3 = if entry.name == self.tab then Theme.color.text else Theme.color.textMuted
		self.tabButtons[entry.name] = button
	end

	local content = Kit.frame(root, {
		Size = UDim2.new(1, 0, 1, -68),
		Position = UDim2.fromOffset(0, 66),
		BackgroundTransparency = 1,
	})
	self.content = content

	local properties = Kit.scroll(content, {
		Size = UDim2.new(1, 0, 1, 0),
	}, 9)
	self.properties = properties

	local curves = Kit.scroll(content, {
		Size = UDim2.new(1, 0, 1, 0),
		Visible = false,
	}, 9)
	self.curves = curves

	local cost = Kit.scroll(content, {
		Size = UDim2.new(1, 0, 1, 0),
		Visible = false,
	}, 9)
	self.cost = cost

	self:bind()
	self:rebuild()
	return self
end

function Inspector:bind()
	table.insert(self.connections, self.store.signals:on("spec", function()
		self:rebuild()
	end))
	table.insert(self.connections, self.store.signals:on("selection", function()
		self:rebuild()
	end))
	table.insert(self.connections, self.store.signals:on("field", function(payload)
		if self.tab == "Cost" then
			self:renderCost()
		end
		if payload and payload.key == "color" and self.tab == "Curves" and not self.interacting then
			self:renderCurves()
		end
	end))
end

function Inspector:showTab(name: string)
	self.tab = name
	for tabName, button in pairs(self.tabButtons) do
		button.TextColor3 = if tabName == name then Theme.color.text else Theme.color.textMuted
	end
	self.properties.Visible = name == "Properties"
	self.curves.Visible = name == "Curves"
	self.cost.Visible = name == "Cost"
	if name == "Curves" then
		self:renderCurves()
	elseif name == "Cost" then
		self:renderCost()
	else
		self:rebuild()
	end
end

function Inspector:rebuild()
	Kit.clear(self.properties)
	self:renderMeta()
	self:renderComponentStack()
	self:renderFields()
	if self.tab == "Curves" then
		self:renderCurves()
	elseif self.tab == "Cost" then
		self:renderCost()
	end
end

--------------------------------------------------------------------------------
-- effect metadata
--------------------------------------------------------------------------------

function Inspector:renderMeta()
	local spec = self.store:working()
	local section = Kit.sectionTitle(self.properties, "Effect")
	section.LayoutOrder = 1

	local nameBox = Kit.textBox(self.properties, tostring(spec.name or ""), {
		placeholder = "Effect name",
		size = UDim2.new(1, 0, 0, 26),
		onSubmit = function(text)
			local trimmed = Util.trim(text)
			if trimmed ~= "" and trimmed ~= spec.name then
				self.store:pushHistory("Rename effect")
				spec.name = trimmed
				self.store.signals:fire("spec")
			end
		end,
	})
	nameBox.LayoutOrder = 2

	local info = Kit.caption(self.properties, string.format(
		"%s  \u{00b7}  %d components  \u{00b7}  %s",
		tostring(spec.category or "Custom"),
		#spec.components,
		Util.formatDuration(spec.duration or 1)
	), {
		Size = UDim2.new(1, 0, 0, 14),
		LayoutOrder = 3,
	})
	info.TextWrapped = false

	if spec.description then
		local description = Kit.caption(self.properties, spec.description, {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			TextWrapped = true,
			TextYAlignment = Enum.TextYAlignment.Top,
		})
		description.LayoutOrder = 4
	end

	local actions = Kit.hlist(self.properties, 6)
	actions.LayoutOrder = 5
	actions.Size = UDim2.new(1, 0, 0, 26)
	Kit.button(actions, "Save as preset", {
		variant = "secondary",
		height = 26,
		size = UDim2.new(0, 108, 0, 26),
		textSize = Theme.text.small,
		onClick = function()
			self.ctx.promptSavePreset()
		end,
	})
	Kit.button(actions, "Import", {
		variant = "ghost",
		height = 26,
		size = UDim2.new(0, 62, 0, 26),
		textSize = Theme.text.small,
		tooltip = "Import the selected instance as an editable effect",
		onClick = function()
			self.ctx.importSelection()
		end,
	})
	Kit.button(actions, "Reset", {
		variant = "ghost",
		height = 26,
		size = UDim2.new(0, 56, 0, 26),
		textSize = Theme.text.small,
		onClick = function()
			self.ctx.reloadPreset()
		end,
	})

	local divider = Kit.divider(self.properties)
	divider.LayoutOrder = 6
end

--------------------------------------------------------------------------------
-- component stack
--------------------------------------------------------------------------------

function Inspector:renderComponentStack()
	local spec = self.store:working()
	local header = Kit.hlist(self.properties, 8)
	header.LayoutOrder = 7
	header.Size = UDim2.new(1, 0, 0, 20)
	Kit.label(header, string.upper("Components"), {
		Size = UDim2.new(0, 90, 1, 0),
		TextColor3 = Theme.color.textMuted,
		TextSize = Theme.text.tiny,
		Font = Theme.font.bold,
	})

	local addHolder = Kit.frame(header, {
		Size = UDim2.new(0, 104, 0, 20),
		BackgroundTransparency = 1,
	})
	local addDropdown = Kit.dropdown(addHolder, {
		options = ADD_OPTIONS,
		placeholder = "+ Add",
		value = nil,
		height = 20,
		maxHeight = 150,
		onChange = function(value)
			self.store:addComponent(tostring(value))
		end,
	})
	addDropdown.Set(nil)
	local addLabel = Kit.label(addHolder, "+ Add component", {
		Size = UDim2.new(1, 0, 1, 0),
		TextColor3 = Theme.color.accentBright,
		TextSize = Theme.text.tiny,
		Font = Theme.font.bold,
	})

	local stack = Kit.frame(self.properties, {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		ClipsDescendants = false,
	})
	stack.LayoutOrder = 8
	local stackLayout = Instance.new("UIListLayout")
	stackLayout.Padding = UDim.new(0, 2)
	stackLayout.SortOrder = Enum.SortOrder.LayoutOrder
	stackLayout.Parent = stack
	self.stack = stack

	if #spec.components == 0 then
		Kit.caption(stack, "No components yet - add one above.", {
			Size = UDim2.new(1, 0, 0, 20),
		})
	end

	local rows = {}
	for index, comp in ipairs(spec.components) do
		local active = index == self.store.selection
		local row = Kit.frame(stack, {
			Size = UDim2.new(1, 0, 0, 26),
			BackgroundColor3 = if active then Theme.color.accentSoft else Theme.color.bg2,
			BackgroundTransparency = if active then 0 else 0.25,
		})
		row.LayoutOrder = index
		Theme.corner(row, Theme.radius.xs)

		local handle = Kit.label(row, "\u{2261}", {
			Size = UDim2.fromOffset(16, 26),
			Position = UDim2.fromOffset(4, 0),
			TextColor3 = Theme.color.textFaint,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Center,
		})
		handle.ZIndex = 4

		Kit.label(row, string.format("%s  %s", KIND_GLYPHS[comp.kind] or "\u{25c6}", tostring(comp.name)), {
			Size = UDim2.new(1, -92, 1, 0),
			Position = UDim2.fromOffset(22, 0),
			TextColor3 = if active then Theme.color.text else Theme.color.textDim,
			TextSize = Theme.text.small,
			TextTruncate = Enum.TextTruncate.AtEnd,
		})

		local duplicate = Kit.iconButton(row, "\u{29c9}", {
			size = UDim2.fromOffset(20, 20),
			tooltip = "Duplicate component",
			onClick = function()
				self.store:duplicateComponent(index)
			end,
		})
		duplicate.Position = UDim2.new(1, -46, 0, 3)
		duplicate.ZIndex = 4

		local remove = Kit.iconButton(row, "\u{00d7}", {
			size = UDim2.fromOffset(20, 20),
			tooltip = "Delete component",
			onClick = function()
				self.store:removeComponent(index)
			end,
		})
		remove.Position = UDim2.new(1, -24, 0, 3)
		remove.ZIndex = 4
		remove.TextColor3 = Theme.color.bad

		local click = Instance.new("TextButton")
		click.BackgroundTransparency = 1
		click.Text = ""
		click.Size = UDim2.new(1, -50, 1, 0)
		click.Position = UDim2.fromOffset(20, 0)
		click.ZIndex = 2
		click.Parent = row
		click.Activated:Connect(function()
			self.store:select(index)
		end)

		Kit.drag(handle, {
			begin = function()
				self.store:select(index)
				self.dragRow = index
			end,
			move = function(_, y)
				if not self.dragRow then
					return
				end
				local target = math.clamp(math.floor((y - stack.AbsolutePosition.Y) / 28) + 1, 1, #spec.components)
				if target ~= self.dragRow then
					self.store:moveComponent(self.dragRow, target)
					self.dragRow = target
				end
			end,
			finish = function()
				self.dragRow = nil
			end,
		})

		rows[index] = row
	end

	local divider = Kit.divider(self.properties)
	divider.LayoutOrder = 9
end

--------------------------------------------------------------------------------
-- field rendering
--------------------------------------------------------------------------------

function Inspector:renderFields()
	local spec = self.store:working()
	local comp = spec.components[self.store.selection]
	local header = Kit.sectionTitle(self.properties, if comp then "Properties - " .. tostring(comp.name) else "Properties")
	header.LayoutOrder = 10

	if not comp then
		Kit.caption(self.properties, "Select a component to edit it.", { LayoutOrder = 11 })
		return
	end

	local schema = SCHEMA[comp.kind] or {}
	local order = 10

	-- Component name + timing are shared by every kind.
	order += 1
	local nameRow, nameHolder = Kit.row(self.properties, "Name")
	nameRow.LayoutOrder = order
	local nameBox = Kit.textBox(nameHolder, tostring(comp.name), {
		size = UDim2.new(1, 0, 0, 24),
		onSubmit = function(text)
			self.store:renameComponent(self.store.selection, text)
		end,
	})
	nameBox.Size = UDim2.new(1, 0, 0, 24)

	order += 1
	local startRow, startHolder = Kit.row(self.properties, "Start time", "When this component begins emitting, in seconds.")
	startRow.LayoutOrder = order
	local startBox = Kit.numberBox(startHolder, tonumber(comp.startTime) or 0, {
		min = 0,
		max = 30,
		size = UDim2.new(1, 0, 0, 24),
		onChange = function(value)
			self.store:setField(self.store.selection, "startTime", value, true)
		end,
	})
	startBox.Parent = startHolder

	order += 1
	local durationRow, durationHolder = Kit.row(self.properties, "Duration", "How long the component stays active. 0 means a single burst.")
	durationRow.LayoutOrder = order
	local compDuration = Kit.numberBox(durationHolder, tonumber(comp.duration) or 0, {
		min = 0,
		max = 30,
		size = UDim2.new(1, 0, 0, 24),
		onChange = function(value)
			self.store:setField(self.store.selection, "duration", value, true)
		end,
	})
	compDuration.Parent = durationHolder

	if comp.kind == "particle" then
		order += 1
		local burstRow, burstHolder = Kit.row(self.properties, "Burst count", "Particles emitted at once when the component starts.")
		burstRow.LayoutOrder = order
		local burstBox = Kit.numberBox(burstHolder, tonumber(comp.burst) or 0, {
			min = 0,
			max = 2000,
			size = UDim2.new(1, 0, 0, 24),
			onChange = function(value)
				self.store:setField(self.store.selection, "burst", value, true)
			end,
		})
		burstBox.Parent = burstHolder

		order += 1
		local repeatsRow, repeatsHolder = Kit.row(self.properties, "Burst repeats", "How many bursts play across the duration.")
		repeatsRow.LayoutOrder = order
		local repeatsBox = Kit.numberBox(repeatsHolder, tonumber(comp.repeats) or 1, {
			min = 1,
			max = 50,
			size = UDim2.new(1, 0, 0, 24),
			onChange = function(value)
				self.store:setField(self.store.selection, "repeats", math.max(1, math.floor(value)), true)
			end,
		})
		repeatsBox.Parent = repeatsHolder
	end

	if comp.kind == "tween" then
		order += 1
		local reverseRow, reverseHolder = Kit.row(self.properties, "Reverse")
		reverseRow.LayoutOrder = order
		local reverseToggle = Kit.toggle(reverseHolder, comp.reverse == true, function(value)
			self.store:setField(self.store.selection, "reverse", value, true)
		end)
		reverseToggle.Parent = reverseHolder
	end

	for _, field in ipairs(schema) do
		order += 1
		local ok, err = pcall(function()
			self:renderField(field, comp, order)
		end)
		if not ok then
			warn("[VFX Studio] field '" .. tostring(field.key) .. "' failed: " .. tostring(err))
		end
	end
end

function Inspector:renderField(field: any, comp: any, order: number)
	local key = field.key
	local label = field.label
	local value = comp[key]

	if field.type == "number" then
		local row, holder = Kit.row(self.properties, label, field.hint)
		row.LayoutOrder = order
		local box = Kit.numberBox(holder, tonumber(value) or 0, {
			min = field.min,
			max = field.max,
			size = UDim2.new(1, 0, 0, 24),
			onChange = function(newValue)
				self.store:setField(self.store.selection, key, newValue)
			end,
		})
		box.Parent = holder
		return
	elseif field.type == "boolean" then
		local row, holder = Kit.row(self.properties, label, field.hint)
		row.LayoutOrder = order
		local toggle = Kit.toggle(holder, value == true, function(newValue)
			self.store:setField(self.store.selection, key, newValue, true)
		end)
		toggle.Parent = holder
		return
	elseif field.type == "range" then
		local row = Kit.vlist(self.properties, 3)
		row.LayoutOrder = order
		row.Size = UDim2.new(1, 0, 0, 0)
		local head = Kit.hlist(row, 6)
		head.Size = UDim2.new(1, 0, 0, 14)
		Kit.caption(head, label, { Size = UDim2.new(1, -60, 1, 0) })
		local minValue = tonumber((value or {})[1]) or 0
		local maxValue = tonumber((value or {})[2]) or minValue
		Kit.label(head, string.format("%s - %s", Util.pretty(minValue), Util.pretty(maxValue)), {
			Size = UDim2.fromOffset(60, 14),
			TextColor3 = Theme.color.textMuted,
			Font = Theme.font.mono,
			TextSize = Theme.text.tiny,
			TextXAlignment = Enum.TextXAlignment.Right,
		})
		local controls = Kit.hlist(row, 4)
		controls.Size = UDim2.new(1, 0, 0, 24)
		local minBox = Kit.numberBox(controls, minValue, {
			min = field.min,
			max = field.max,
			size = UDim2.new(0.5, -2, 0, 24),
			onChange = function(newMin)
				local current = comp[key] or { 0, 0 }
				local upper = tonumber(current[2]) or newMin
				self.store:setField(self.store.selection, key, { newMin, math.max(newMin, upper) })
			end,
		})
		minBox.Parent = controls
		local maxBox = Kit.numberBox(controls, maxValue, {
			min = field.min,
			max = field.max,
			size = UDim2.new(0.5, -2, 0, 24),
			onChange = function(newMax)
				local current = comp[key] or { 0, 0 }
				local lower = tonumber(current[1]) or 0
				self.store:setField(self.store.selection, key, { math.min(lower, newMax), newMax })
			end,
		})
		maxBox.Parent = controls
		return
	elseif field.type == "vector2" or field.type == "vector3" then
		local row = Kit.vlist(self.properties, 3)
		row.LayoutOrder = order
		row.Size = UDim2.new(1, 0, 0, 0)
		Kit.caption(row, label, { Size = UDim2.new(1, 0, 0, 14) })
		local controls = Kit.hlist(row, 4)
		controls.Size = UDim2.new(1, 0, 0, 24)
		local count = if field.type == "vector2" then 2 else 3
		local axes = { "X", "Y", "Z" }
		local boxes = {}
		for index = 1, count do
			local holder = Kit.frame(controls, {
				Size = UDim2.new(1 / count, -3, 0, 24),
				BackgroundColor3 = Theme.color.bg1,
			})
			Theme.corner(holder, Theme.radius.xs)
			local box = Kit.numberBox(holder, tonumber((value or {})[index]) or 0, {
				min = field.min,
				max = field.max,
				size = UDim2.new(1, 0, 0, 24),
				onChange = function(newValue)
					local current = {}
					for i = 1, count do
						current[i] = tonumber((comp[key] or {})[i]) or 0
					end
					current[index] = newValue
					self.store:setField(self.store.selection, key, current)
				end,
			})
			box.Parent = holder
			table.insert(boxes, box)
		end
		return
	elseif field.type == "enum" then
		local row, holder = Kit.row(self.properties, label)
		row.LayoutOrder = order
		local enumType = (Enum :: any)[field.enum]
		local options = {}
		if enumType then
			for _, item in ipairs(enumType:GetEnumItems()) do
				table.insert(options, { value = item.Name, label = item.Name })
			end
		end
		local dropdown = Kit.dropdown(holder, {
			options = options,
			value = tostring(value or ""),
			height = 24,
			maxHeight = 150,
			onChange = function(newValue)
				self.store:setField(self.store.selection, key, tostring(newValue), true)
			end,
		})
		dropdown.Parent = holder
		return
	elseif field.type == "options" then
		local row, holder = Kit.row(self.properties, label)
		row.LayoutOrder = order
		local options = {}
		for _, option in ipairs(field.options) do
			table.insert(options, { value = option, label = option })
		end
		local dropdown = Kit.dropdown(holder, {
			options = options,
			value = tostring(value or field.options[1]),
			height = 24,
			maxHeight = 150,
			onChange = function(newValue)
				self.store:setField(self.store.selection, key, tostring(newValue), true)
			end,
		})
		dropdown.Parent = holder
		return
	elseif field.type == "target" then
		local row, holder = Kit.row(self.properties, label, "Which component this motion track drives.")
		row.LayoutOrder = order
		local options = { { value = "rig", label = "Whole effect" } }
		for _, other in ipairs(self.store:working().components) do
			if other.kind ~= "tween" then
				table.insert(options, { value = other.name, label = other.name })
			end
		end
		local dropdown = Kit.dropdown(holder, {
			options = options,
			value = tostring(value or "rig"),
			height = 24,
			maxHeight = 150,
			onChange = function(newValue)
				self.store:setField(self.store.selection, key, tostring(newValue), true)
			end,
		})
		dropdown.Parent = holder
		return
	elseif field.type == "texture" then
		self:renderTextureField(field, comp, order)
		return
	elseif field.type == "color" or field.type == "curve01" or field.type == "curve" then
		self:renderCurveField(field, comp, order)
		return
	elseif field.type == "swatch" then
		local block = Kit.vlist(self.properties, 4)
		block.LayoutOrder = order
		block.Size = UDim2.new(1, 0, 0, 0)

		local head = Kit.hlist(block, 6)
		head.Size = UDim2.new(1, 0, 0, 24)

		local swatch = Kit.colorSwatch(head, Util.hex(tostring(value or "#ffffff")), UDim2.fromOffset(24, 24))
		local hexBox = Kit.textBox(head, tostring(value or "#ffffff"), {
			size = UDim2.new(0, 84, 0, 24),
			font = Theme.font.mono,
			onSubmit = function(text)
				local trimmed = Util.trim(text)
				if string.match(trimmed, "^#?%x%x%x%x%x%x$") then
					local normalized = "#" .. string.gsub(trimmed, "#", "")
					self.store:setField(self.store.selection, key, normalized, true)
					swatch.BackgroundColor3 = Util.hex(normalized)
				else
					self.ctx.toast("Enter a hex colour like #ff8800", "warn")
				end
			end,
		})
		hexBox.Parent = head

		local palette = Kit.hlist(block, 4)
		palette.Size = UDim2.new(1, 0, 0, 18)
		for _, preset in ipairs(COLOR_PRESETS) do
			local dot = Kit.colorSwatch(palette, Util.hex(preset.colors[2]), UDim2.fromOffset(18, 18))
			local click = Instance.new("TextButton")
			click.BackgroundTransparency = 1
			click.Text = ""
			click.Size = UDim2.fromScale(1, 1)
			click.Parent = dot
			click.Activated:Connect(function()
				self.store:setField(self.store.selection, key, preset.colors[2], true)
				swatch.BackgroundColor3 = Util.hex(preset.colors[2])
				hexBox.Text = preset.colors[2]
			end)
			Kit.tooltip(click, preset.name)
		end
		return
	end
end

function Inspector:renderTextureField(field: any, comp: any, order: number)
	local container = Kit.frame(self.properties, {
		Size = UDim2.new(1, 0, 0, 58),
		BackgroundTransparency = 1,
		ClipsDescendants = false,
	})
	container.LayoutOrder = order

	Kit.caption(container, field.label, {
		Size = UDim2.new(1, 0, 0, 14),
	})

	local preview = Kit.frame(container, {
		Size = UDim2.new(1, -74, 0, 38),
		Position = UDim2.fromOffset(0, 18),
		BackgroundColor3 = Theme.color.bg0,
	})
	Theme.corner(preview, Theme.radius.xs)

	local image = Instance.new("ImageLabel")
	image.BackgroundTransparency = 1
	image.Size = UDim2.new(1, -8, 1, -8)
	image.Position = UDim2.fromOffset(4, 4)
	image.Image = Assets.resolve(comp[field.key])
	image.ImageColor3 = Theme.color.white
	image.ScaleType = Enum.ScaleType.Fit
	image.Parent = preview

	Kit.label(preview, Assets.describe(Assets.resolve(comp[field.key])), {
		Size = UDim2.new(1, -12, 0, 12),
		Position = UDim2.new(0, 6, 1, -14),
		TextColor3 = Theme.color.textMuted,
		TextSize = Theme.text.tiny,
		TextTruncate = Enum.TextTruncate.AtEnd,
	})

	local browse = Kit.button(container, "Change", {
		variant = "secondary",
		height = 38,
		size = UDim2.fromOffset(68, 38),
		textSize = Theme.text.small,
		onClick = function()
			self.ctx.openAssetPicker(function(uri: string)
				self.store:setField(self.store.selection, field.key, uri, true)
				image.Image = uri
			end)
		end,
	})
	browse.Position = UDim2.new(1, -68, 0, 18)
end

function Inspector:renderCurveField(field: any, comp: any, order: number)
	local container = Kit.frame(self.properties, {
		Size = UDim2.new(1, 0, 0, 52),
		BackgroundTransparency = 1,
		ClipsDescendants = false,
	})
	container.LayoutOrder = order

	Kit.caption(container, field.label, {
		Size = UDim2.new(1, -60, 0, 14),
	})

	local edit = Kit.button(container, "Edit", {
		variant = "ghost",
		height = 16,
		size = UDim2.fromOffset(44, 16),
		textSize = Theme.text.tiny,
		onClick = function()
			self.curveMode = if field.type == "color" then "color" elseif field.key == "size" then "size" else "transparency"
			self.showTab("Curves")
			self:renderCurves()
		end,
	})
	edit.Position = UDim2.new(1, -44, 0, -1)

	local strip = Kit.frame(container, {
		Size = UDim2.new(1, 0, 0, 34),
		Position = UDim2.fromOffset(0, 16),
		BackgroundColor3 = Theme.color.bg0,
	})
	Theme.corner(strip, Theme.radius.xs)

	if field.type == "color" then
		local keypoints = sorted(comp[field.key] or {})
		for index = 1, 32 do
			local alpha = (index - 1) / 31
			local sample = Kit.frame(strip, {
				Size = UDim2.new(1 / 32, 1, 1, 0),
				Position = UDim2.fromScale((index - 1) / 32, 0),
				BackgroundColor3 = sampleColor(keypoints, alpha),
			})
		end
	else
		local keypoints = comp[field.key] or {}
		local peak = 0.0001
		if field.key == "transparency" then
			peak = 1
		else
			for _, kp in ipairs(keypoints) do
				peak = math.max(peak, tonumber(kp[2]) or 0)
			end
		end
		for index = 1, 32 do
			local alpha = (index - 1) / 31
			local value = sampleNumber(keypoints, alpha)
			local height = math.clamp(if field.key == "transparency" then 1 - value else value / (peak * 1.15), 0, 1)
			local bar = Kit.frame(strip, {
				Size = UDim2.new(1 / 32, 1, height, 0),
				Position = UDim2.new((index - 1) / 32, 0, 1, 0),
				BackgroundColor3 = if field.key == "transparency" then Theme.color.accentBright else Theme.color.accent,
				AnchorPoint = Vector2.new(0, 1),
			})
			bar.BackgroundTransparency = 0.15
		end
	end
end

--------------------------------------------------------------------------------
-- curves tab
--------------------------------------------------------------------------------

function Inspector:renderCurves()
	Kit.clear(self.curves)
	local comp = self.store:currentComponent()

	local modeRow = Kit.hlist(self.curves, 4)
	modeRow.Size = UDim2.new(1, 0, 0, 24)
	local modes = {
		{ key = "color", label = "Colour" },
		{ key = "transparency", label = "Opacity" },
		{ key = "size", label = "Size" },
	}
	for _, mode in ipairs(modes) do
		local button = Kit.button(modeRow, mode.label, {
			variant = if self.curveMode == mode.key then "accentSoft" else "ghost",
			height = 22,
			size = UDim2.fromOffset(66, 22),
			textSize = Theme.text.tiny,
			onClick = function()
				self.curveMode = mode.key
				self.activeStop = 1
				self:renderCurves()
			end,
		})
	end

	if not comp then
		Kit.caption(self.curves, "Select a component first.")
		return
	end

	if self.curveMode == "color" then
		self:renderColorEditor(comp)
	else
		self:renderNumberCurve(comp, self.curveMode)
	end
end

function Inspector:renderColorEditor(comp: any)
	local single = self.colorSingle
	local keypoints = sorted(comp.color or {})
	self.activeStop = math.clamp(self.activeStop, 1, math.max(1, #keypoints))

	local header = Kit.hlist(self.curves, 6)
	header.Size = UDim2.new(1, 0, 0, 18)
	Kit.caption(header, "GRADIENT", { Size = UDim2.new(1, -80, 1, 0), Font = Theme.font.bold, TextSize = Theme.text.tiny })
	local countLabel = Kit.caption(header, string.format("%d stops", #keypoints), {
		Size = UDim2.fromOffset(62, 18),
		TextXAlignment = Enum.TextXAlignment.Right,
	})

	local bar = Kit.frame(self.curves, {
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundColor3 = Theme.color.bg0,
	})
	Theme.corner(bar, Theme.radius.xs)
	self.gradientBar = bar

	for index = 1, 40 do
		local alpha = (index - 1) / 39
		Kit.frame(bar, {
			Size = UDim2.new(1 / 40, 1, 1, 0),
			Position = UDim2.fromScale((index - 1) / 40, 0),
			BackgroundColor3 = sampleColor(keypoints, alpha),
		})
	end

	local stopMarkers = {}
	for index, point in ipairs(keypoints) do
		local marker = Kit.frame(bar, {
			Size = UDim2.fromOffset(10, 40),
			Position = UDim2.new(tonumber(point[1]) or 0, -5, 0, 0),
			BackgroundColor3 = if index == self.activeStop then Theme.color.white else Theme.color.black,
			BackgroundTransparency = if index == self.activeStop then 0 else 0.55,
			ZIndex = 3,
		})
		Theme.stroke(marker, if index == self.activeStop then Theme.color.accentBright else Theme.color.white, 1, 0)
		marker.ZIndex = 3

		local click = Instance.new("TextButton")
		click.BackgroundTransparency = 1
		click.Text = ""
		click.Size = UDim2.fromScale(1, 1)
		click.ZIndex = 4
		click.Parent = marker
		click.Activated:Connect(function()
			self.activeStop = index
			self:renderCurves()
		end)

		local startTime = tonumber(point[1]) or 0
		Kit.drag(marker, {
			begin = function()
				self.store:pushHistory("Move colour stop")
				self.activeStop = index
			end,
			move = function(x)
				local fraction = Kit.fractionAlong(bar, x)
				local points = comp.color
				points[index][1] = math.floor(fraction * 1000 + 0.5) / 1000
				self.store:setField(self.store.selection, "color", sorted(points))
			end,
			finish = function()
				comp.color = sorted(comp.color)
				self.store:setField(self.store.selection, "color", comp.color, true)
				self:renderCurves()
			end,
		})

		table.insert(stopMarkers, marker)
	end

	local actions = Kit.hlist(self.curves, 6)
	actions.Size = UDim2.new(1, 0, 0, 24)
	Kit.button(actions, "+ Add stop", {
		variant = "secondary",
		height = 22,
		size = UDim2.fromOffset(80, 22),
		textSize = Theme.text.tiny,
		onClick = function()
			self.store:pushHistory("Add colour stop")
			local points = comp.color
			local insertAt = 0.5
			local color = sampleColor(points, insertAt)
			table.insert(points, { insertAt, Util.toHex(color) })
			comp.color = sorted(points)
			self.activeStop = 1
			self.store:setField(self.store.selection, "color", comp.color)
			self:renderCurves()
		end,
	})
	local removeButton = Kit.button(actions, "Remove stop", {
		variant = "ghost",
		height = 22,
		size = UDim2.fromOffset(80, 22),
		textSize = Theme.text.tiny,
		onClick = function()
			if #comp.color <= 2 then
				self.ctx.toast("A gradient needs at least two stops", "warn")
				return
			end
			self.store:pushHistory("Remove colour stop")
			table.remove(comp.color, self.activeStop)
			self.activeStop = math.clamp(self.activeStop, 1, #comp.color)
			self.store:setField(self.store.selection, "color", comp.color)
			self:renderCurves()
		end,
	})
	removeButton.TextColor3 = Theme.color.bad

	-- HSV picker ----------------------------------------------------------------
	local selected = keypoints[self.activeStop]
	local currentColor = Util.hex(selected and selected[2] or "#ffffff")
	local h, s, v = currentColor:ToHSV()

	local sv = Kit.frame(self.curves, {
		Size = UDim2.new(1, 0, 0, 110),
		BackgroundColor3 = Color3.fromHSV(h, 1, 1),
	})
	Theme.corner(sv, Theme.radius.xs)

	local whiteOverlay = Kit.frame(sv, {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 0,
	})
	local whiteGradient = Instance.new("UIGradient")
	whiteGradient.Color = ColorSequence.new(Color3.new(1, 1, 1))
	whiteGradient.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) })
	whiteGradient.Rotation = 0
	whiteGradient.Parent = whiteOverlay

	local blackOverlay = Kit.frame(sv, {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(0, 0, 0),
	})
	local blackGradient = Instance.new("UIGradient")
	blackGradient.Color = ColorSequence.new(Color3.new(0, 0, 0))
	blackGradient.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) })
	blackGradient.Rotation = 90
	blackGradient.Parent = blackOverlay

	local cursor = Kit.frame(sv, {
		Size = UDim2.fromOffset(10, 10),
		Position = UDim2.new(s, -5, 1 - v, -5),
		BackgroundColor3 = currentColor,
		ZIndex = 4,
	})
	Theme.corner(cursor, Theme.radius.pill)
	Theme.stroke(cursor, Theme.color.white, 2, 0)

	local function commitColor(newColor: Color3)
		local points = comp.color
		if not points[self.activeStop] then
			return
		end
		points[self.activeStop][2] = Util.toHex(newColor)
		self.store:setField(self.store.selection, "color", sorted(points))
	end

	local function updateFromPosition(x: number, y: number)
		local sx = Kit.fractionAlong(sv, x)
		local height = math.max(1, sv.AbsoluteSize.Y)
		local sy = 1 - math.clamp((y - sv.AbsolutePosition.Y) / height, 0, 1)
		cursor.Position = UDim2.new(sx, -5, 1 - sy, -5)
		local newColor = Color3.fromHSV(h, sx, sy)
		cursor.BackgroundColor3 = newColor
		commitColor(newColor)
	end

	local svHit = Instance.new("TextButton")
	svHit.BackgroundTransparency = 1
	svHit.Text = ""
	svHit.Size = UDim2.fromScale(1, 1)
	svHit.ZIndex = 3
	svHit.Parent = sv
	Kit.drag(svHit, {
		begin = function(x, y)
			self.store:pushHistory("Pick colour")
			updateFromPosition(x, y)
		end,
		move = function(x, y)
			updateFromPosition(x, y)
		end,
		finish = function()
			self:renderCurves()
		end,
	})

	-- Hue strip
	local hueStrip = Kit.frame(self.curves, {
		Size = UDim2.new(1, 0, 0, 14),
		BackgroundColor3 = Color3.fromHSV(0, 1, 1),
	})
	Theme.corner(hueStrip, Theme.radius.pill)
	local hueGradient = Instance.new("UIGradient")
	hueGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
		ColorSequenceKeypoint.new(1 / 6, Color3.fromHSV(1 / 6, 1, 1)),
		ColorSequenceKeypoint.new(2 / 6, Color3.fromHSV(2 / 6, 1, 1)),
		ColorSequenceKeypoint.new(3 / 6, Color3.fromHSV(3 / 6, 1, 1)),
		ColorSequenceKeypoint.new(4 / 6, Color3.fromHSV(4 / 6, 1, 1)),
		ColorSequenceKeypoint.new(5 / 6, Color3.fromHSV(5 / 6, 1, 1)),
		ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1)),
	})
	hueGradient.Parent = hueStrip

	local hueCursor = Kit.frame(hueStrip, {
		Size = UDim2.new(0, 3, 1, 0),
		Position = UDim2.new(h, -1, 0, 0),
		BackgroundColor3 = Theme.color.white,
		ZIndex = 3,
	})

	local hueHit = Instance.new("TextButton")
	hueHit.BackgroundTransparency = 1
	hueHit.Text = ""
	hueHit.Size = UDim2.fromScale(1, 1)
	hueHit.ZIndex = 2
	hueHit.Parent = hueStrip
	Kit.drag(hueHit, {
		begin = function(x)
			self.store:pushHistory("Pick hue")
		end,
		move = function(x)
			local fraction = Kit.fractionAlong(hueStrip, x)
			h = fraction
			hueCursor.Position = UDim2.new(fraction, -1, 0, 0)
			sv.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
			local newColor = Color3.fromHSV(h, s, v)
			cursor.BackgroundColor3 = newColor
			commitColor(newColor)
		end,
		finish = function()
			self:renderCurves()
		end,
	})

	-- Hex + presets --------------------------------------------------------------
	local hexRow = Kit.hlist(self.curves, 6)
	hexRow.Size = UDim2.new(1, 0, 0, 26)
	Kit.caption(hexRow, "Hex", { Size = UDim2.fromOffset(24, 26) })
	local hexBox = Kit.textBox(hexRow, Util.toHex(currentColor), {
		size = UDim2.new(1, -40, 0, 26),
		onSubmit = function(text)
			local trimmed = Util.trim(text)
			if string.match(trimmed, "^#?%x%x%x%x%x%x$") then
				self.store:pushHistory("Set hex colour")
				commitColor(Util.hex(trimmed))
				self:renderCurves()
			else
				self.ctx.toast("Enter a hex colour like #ff8800", "warn")
				hexBox.Text = Util.toHex(currentColor)
			end
		end,
	})
	hexBox.Parent = hexRow

	Kit.caption(self.curves, "PALETTES", { Size = UDim2.new(1, 0, 0, 14), Font = Theme.font.bold, TextSize = Theme.text.tiny })
	local presetGrid = Kit.frame(self.curves, {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
	})
	local grid = Instance.new("UIGridLayout")
	grid.CellSize = UDim2.new(0.5, -3, 0, 24)
	grid.CellPadding = UDim2.fromOffset(4, 4)
	grid.SortOrder = Enum.SortOrder.LayoutOrder
	grid.Parent = presetGrid

	for index, preset in ipairs(COLOR_PRESETS) do
		local button = Kit.button(presetGrid, preset.name, {
			variant = "secondary",
			height = 24,
			size = UDim2.new(1, 0, 0, 24),
			textSize = Theme.text.tiny,
			onClick = function()
				self.store:pushHistory("Apply palette")
				local points = {}
				for stopIndex, hex in ipairs(preset.colors) do
					table.insert(points, { (stopIndex - 1) / (#preset.colors - 1), hex })
				end
				comp.color = points
				self.activeStop = 1
				self.store:setField(self.store.selection, "color", points)
				self:renderCurves()
			end,
		})
		button.LayoutOrder = index
		button.TextXAlignment = Enum.TextXAlignment.Left
		local pad = Instance.new("UIPadding")
		pad.PaddingLeft = UDim.new(0, 7)
		pad.Parent = button

		local dots = Kit.hlist(button, 2, {
			Size = UDim2.new(0, 0, 0, 10),
			AutomaticSize = Enum.AutomaticSize.X,
		})
		dots.Position = UDim2.new(1, -34, 0.5, -5)
		for _, hex in ipairs(preset.colors) do
			Kit.colorSwatch(dots, Util.hex(hex), UDim2.fromOffset(9, 9))
		end
	end
end

function Inspector:renderNumberCurve(comp: any, mode: string)
	local key = mode
	local keypoints = comp[key]
	if type(keypoints) ~= "table" then
		Kit.caption(self.curves, "This component has no " .. mode .. " curve.")
		return
	end

	if #keypoints < 2 then
		table.insert(keypoints, { 1, tonumber(keypoints[1] and keypoints[1][2]) or 0 })
	end

	local peak = 1
	if mode == "size" then
		peak = 0.0001
		for _, kp in ipairs(keypoints) do
			peak = math.max(peak, tonumber(kp[2]) or 0)
		end
		peak *= 1.2
	end

	local header = Kit.hlist(self.curves, 6)
	header.Size = UDim2.new(1, 0, 0, 18)
	Kit.caption(header, string.upper(mode == "size" and "SIZE CURVE" or "OPACITY CURVE"), {
		Size = UDim2.new(1, -70, 1, 0),
		Font = Theme.font.bold,
		TextSize = Theme.text.tiny,
	})
	Kit.caption(header, string.format("%d keys", #keypoints), {
		Size = UDim2.fromOffset(60, 18),
		TextXAlignment = Enum.TextXAlignment.Right,
	})

	local area = Kit.frame(self.curves, {
		Size = UDim2.new(1, 0, 0, 108),
		BackgroundColor3 = Theme.color.bg0,
		ClipsDescendants = false,
	})
	Theme.corner(area, Theme.radius.xs)
	self.curveArea = area

	-- Grid lines
	for index = 1, 4 do
		Kit.frame(area, {
			Size = UDim2.new(1, 0, 0, 1),
			Position = UDim2.new(0, 0, index / 4, 0),
			BackgroundColor3 = Theme.color.line,
			BackgroundTransparency = 0.7,
		})
	end

	-- Bars
	for index = 1, 32 do
		local alpha = (index - 1) / 31
		local value = sampleNumber(keypoints, alpha)
		local fraction = math.clamp(if mode == "transparency" then 1 - value else value / peak, 0, 1)
		Kit.frame(area, {
			Size = UDim2.new(1 / 32, 1, math.max(0.004, fraction), 0),
			Position = UDim2.new((index - 1) / 32, 0, 1, 0),
			BackgroundColor3 = if mode == "transparency" then Theme.color.accentBright else Theme.color.accent,
			BackgroundTransparency = 0.35,
			AnchorPoint = Vector2.new(0, 1),
		})
	end

	local function valueFromY(y: number): number
		local height = math.max(1, area.AbsoluteSize.Y)
		local fraction = math.clamp(1 - (y - area.AbsolutePosition.Y) / height, 0, 1)
		if mode == "transparency" then
			return Util.round(1 - fraction, 3)
		end
		return Util.round(fraction * peak, 3)
	end

	for index, kp in ipairs(keypoints) do
		local time = tonumber(kp[1]) or 0
		local value = tonumber(kp[2]) or 0
		local yFraction = if mode == "transparency" then 1 - value else math.clamp(value / peak, 0, 1)

		local dot = Kit.frame(area, {
			Size = UDim2.fromOffset(9, 9),
			Position = UDim2.new(time, -4, 1 - yFraction, -4),
			BackgroundColor3 = Theme.color.white,
			ZIndex = 4,
		})
		Theme.corner(dot, Theme.radius.pill)
		Theme.stroke(dot, Theme.color.accent, 2, 0)

		Kit.drag(dot, {
			begin = function()
				self.store:pushHistory("Edit " .. mode .. " curve")
			end,
			move = function(x, y)
				local newTime = math.clamp(Util.round(Kit.fractionAlong(area, x), 3), 0, 1)
				local newValue = valueFromY(y)
				keypoints[index][1] = newTime
				keypoints[index][2] = newValue
				self.store:setField(self.store.selection, key, keypoints)
			end,
			finish = function()
				comp[key] = sorted(keypoints)
				self.store:setField(self.store.selection, key, comp[key], true)
				self:renderCurves()
			end,
		})
	end

	local hit = Instance.new("TextButton")
	hit.BackgroundTransparency = 1
	hit.Text = ""
	hit.Size = UDim2.fromScale(1, 1)
	hit.ZIndex = 2
	hit.Parent = area
	hit.Activated:Connect(function()
		local mouse = UserInputService:GetMouseLocation()
		local newTime = math.clamp(Util.round(Kit.fractionAlong(area, mouse.X), 3), 0, 1)
		local newValue = valueFromY(mouse.Y)
		self.store:pushHistory("Add curve key")
		table.insert(keypoints, { newTime, newValue })
		comp[key] = sorted(keypoints)
		self.store:setField(self.store.selection, key, comp[key])
		self:renderCurves()
	end)

	local actions = Kit.hlist(self.curves, 6)
	actions.Size = UDim2.new(1, 0, 0, 24)
	Kit.button(actions, "+ Add key", {
		variant = "secondary",
		height = 22,
		size = UDim2.fromOffset(74, 22),
		textSize = Theme.text.tiny,
		onClick = function()
			self.store:pushHistory("Add curve key")
			local last = keypoints[#keypoints]
			table.insert(keypoints, { 1, tonumber(last and last[2]) or 0 })
			comp[key] = sorted(keypoints)
			self.store:setField(self.store.selection, key, comp[key])
			self:renderCurves()
		end,
	})
	Kit.button(actions, "Reset", {
		variant = "ghost",
		height = 22,
		size = UDim2.fromOffset(52, 22),
		textSize = Theme.text.tiny,
		onClick = function()
			self.store:pushHistory("Reset curve")
			if mode == "transparency" then
				comp[key] = { { 0, 0 }, { 1, 1 } }
			else
				comp[key] = { { 0, 1 }, { 1, 0 } }
			end
			self.store:setField(self.store.selection, key, comp[key])
			self:renderCurves()
		end,
	})

	Kit.caption(self.curves, "Click the graph to add a key, drag keys to shape the curve.", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		TextWrapped = true,
		TextSize = Theme.text.tiny,
	})
end

--------------------------------------------------------------------------------
-- cost tab
--------------------------------------------------------------------------------

function Inspector:renderCost()
	Kit.clear(self.cost)
	local report = Performance.analyze(self.store:working())

	local scoreCard = Kit.frame(self.cost, {
		Size = UDim2.new(1, 0, 0, 64),
		BackgroundColor3 = Theme.color.bg2,
	})
	Theme.corner(scoreCard, Theme.radius.md)

	local gradeColor = Theme.color.good
	if report.grade == "B" then
		gradeColor = Theme.color.accentBright
	elseif report.grade == "C" then
		gradeColor = Theme.color.warn
	elseif report.grade == "D" then
		gradeColor = Theme.color.bad
	end

	Kit.label(scoreCard, report.grade, {
		Size = UDim2.fromOffset(52, 52),
		Position = UDim2.fromOffset(8, 6),
		TextColor3 = gradeColor,
		Font = Theme.font.display,
		TextSize = 34,
		TextXAlignment = Enum.TextXAlignment.Center,
	})
	Kit.label(scoreCard, string.format("%d / 100", math.floor(report.score)), {
		Size = UDim2.new(1, -76, 0, 18),
		Position = UDim2.fromOffset(66, 10),
		Font = Theme.font.bold,
		TextSize = Theme.text.subtitle,
	})
	Kit.caption(scoreCard, string.format("%d concurrent particles", math.floor(report.alive)), {
		Size = UDim2.new(1, -76, 0, 14),
		Position = UDim2.fromOffset(66, 28),
	})
	local bar = Kit.progressBar(scoreCard, 6)
	bar.track.Position = UDim2.fromOffset(66, 48)
	bar.track.Size = UDim2.new(1, -76, 0, 6)
	bar.Set(report.score / 100, gradeColor)

	local stats = Kit.frame(self.cost, {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
	})
	local statsLayout = Instance.new("UIListLayout")
	statsLayout.Padding = UDim.new(0, 1)
	statsLayout.Parent = stats

	local rows = {
		{ "Components", tostring(report.components) },
		{ "Emitters", tostring(report.emitters) },
		{ "Peak alive", tostring(math.floor(report.alive)) },
		{ "Burst peak", tostring(math.floor(report.burstPeak)) },
		{ "Beams", tostring(report.beams) },
		{ "Trails", tostring(report.trails) },
		{ "Lights", tostring(report.lights) },
		{ "Parts", tostring(report.parts) },
		{ "Unique textures", tostring(report.textures) },
		{ "Remote textures", tostring(report.remoteTextures), report.remoteTextures > 0 and Theme.color.warn or nil },
	}
	for _, row in ipairs(rows) do
		local stat = Kit.statRow(stats, row[1], row[2], row[3])
		stat.Parent = stats
	end

	Kit.sectionTitle(self.cost, string.format("Issues (%d)", #report.issues))

	if #report.issues == 0 then
		Kit.caption(self.cost, "No problems found. This effect is within a healthy budget.", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			TextWrapped = true,
			TextColor3 = Theme.color.good,
		})
	end

	for _, issue in ipairs(report.issues) do
		local card = Kit.frame(self.cost, {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = Theme.color.bg2,
			ClipsDescendants = false,
		})
		Theme.corner(card, Theme.radius.sm)
		local pad = Instance.new("UIPadding")
		pad.PaddingTop = UDim.new(0, 7)
		pad.PaddingBottom = UDim.new(0, 7)
		pad.PaddingLeft = UDim.new(0, 9)
		pad.PaddingRight = UDim.new(0, 9)
		pad.Parent = card

		local color = if issue.severity == "high" then Theme.color.bad elseif issue.severity == "medium" then Theme.color.warn else Theme.color.accentBright
		local stripe = Kit.frame(card, {
			Size = UDim2.new(0, 2, 1, 0),
			Position = UDim2.fromOffset(0, 0),
			BackgroundColor3 = color,
		})
		Theme.corner(stripe, Theme.radius.pill)

		local body = Kit.vlist(card, 2, {
			Size = UDim2.new(1, -8, 0, 0),
			Position = UDim2.fromOffset(8, 0),
		})
		body.AutomaticSize = Enum.AutomaticSize.Y

		Kit.label(body, issue.title, {
			Size = UDim2.new(1, 0, 0, 15),
			TextColor3 = Theme.color.text,
			TextSize = Theme.text.small,
			Font = Theme.font.medium,
		})
		Kit.caption(body, issue.detail, {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			TextWrapped = true,
			TextYAlignment = Enum.TextYAlignment.Top,
		})
		if issue.fix then
			Kit.caption(body, "\u{2192} " .. issue.fix, {
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				TextWrapped = true,
				TextColor3 = Theme.color.textMuted,
				TextYAlignment = Enum.TextYAlignment.Top,
			})
		end
	end

	local actions = Kit.vlist(self.cost, 6)
	actions.Size = UDim2.new(1, 0, 0, 0)
	actions.AutomaticSize = Enum.AutomaticSize.Y

	Kit.button(actions, "Optimise effect", {
		variant = "primary",
		height = 30,
		size = UDim2.new(1, 0, 0, 30),
		onClick = function()
			local optimized, changes = Performance.optimize(self.store:working())
			if not optimized or #changes == 0 then
				self.ctx.toast("Already optimised - nothing to change", "info")
				return
			end
			self.store:pushHistory("Optimise effect")
			self.store.spec = optimized
			self.store.signals:fire("spec")
			self.ctx.toast(string.format("Applied %d optimisation(s)", #changes), "success")
		end,
	})

	Kit.button(actions, "Analyse selection", {
		variant = "secondary",
		height = 28,
		size = UDim2.new(1, 0, 0, 28),
		tooltip = "Score the instances currently selected in Explorer",
		onClick = function()
			local selection = Util.Selection:Get()
			if #selection == 0 then
				self.ctx.toast("Select an effect in the Explorer first", "warn")
				return
			end
			local total = { alive = 0, components = 0, emitters = 0, lights = 0 }
			for _, instance in ipairs(selection) do
				local result = Performance.analyzeInstances(instance)
				total.alive += result.alive
				total.components += result.components
				total.emitters += result.emitters
				total.lights += result.lights
			end
			self.ctx.toast(string.format(
				"Selection: %d emitters, ~%d particles alive",
				total.emitters,
				math.floor(total.alive)
			), "info")
		end,
	})

	Kit.caption(self.cost, "Estimates use emitter rate x average lifetime plus burst peaks. Test on a low-end device before shipping.", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		TextWrapped = true,
		TextSize = Theme.text.tiny,
	})
end

function Inspector:destroy()
	for _, connection in ipairs(self.connections) do
		pcall(function()
			connection:Disconnect()
		end)
	end
	self.root:Destroy()
end

return Inspector
