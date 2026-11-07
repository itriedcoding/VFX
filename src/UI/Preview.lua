--[[
	Preview - the live 3D stage.

	A ViewportFrame with a WorldModel renders the real compiled instances:
	ParticleEmitters, Beams, Trails and PointLights all behave exactly as they
	will in-game. Orbit with the mouse, zoom with the wheel or the buttons,
	play/pause the timeline, and switch the lighting rig for context.
]]

local Util = require(script.Parent.Parent.Core.Util)
local Theme = require(script.Parent.Parent.Core.Theme)
local Compiler = require(script.Parent.Parent.Core.Compiler)
local Player = require(script.Parent.Parent.Core.Player)
local Performance = require(script.Parent.Parent.Core.Performance)
local Kit = require(script.Parent.Kit)

local UserInputService = game:GetService("UserInputService")

local Preview = {}
Preview.__index = Preview

local BACKGROUNDS = {
	{
		value = "studio",
		label = "Studio dark",
		ambient = Color3.fromRGB(66, 74, 92),
		light = Color3.fromRGB(150, 168, 200),
		direction = Vector3.new(-0.4, -1, -0.6),
		background = Color3.fromRGB(12, 15, 22),
		floor = Color3.fromRGB(26, 32, 45),
		floorTransparency = 0.15,
	},
	{
		value = "night",
		label = "Night",
		ambient = Color3.fromRGB(38, 44, 66),
		light = Color3.fromRGB(96, 116, 168),
		direction = Vector3.new(-0.3, -1, 0.4),
		background = Color3.fromRGB(6, 8, 14),
		floor = Color3.fromRGB(16, 20, 32),
		floorTransparency = 0.3,
	},
	{
		value = "day",
		label = "Daylight",
		ambient = Color3.fromRGB(150, 156, 168),
		light = Color3.fromRGB(255, 246, 230),
		direction = Vector3.new(-0.6, -1, -0.3),
		background = Color3.fromRGB(148, 164, 190),
		floor = Color3.fromRGB(120, 126, 136),
		floorTransparency = 0.05,
	},
	{
		value = "void",
		label = "Void",
		ambient = Color3.fromRGB(20, 22, 30),
		light = Color3.fromRGB(70, 80, 110),
		direction = Vector3.new(0, -1, 0),
		background = Color3.fromRGB(2, 3, 6),
		floor = Color3.fromRGB(8, 10, 16),
		floorTransparency = 0.6,
	},
}

local SPEEDS = {
	{ value = 0.25, label = "0.25x" },
	{ value = 0.5, label = "0.5x" },
	{ value = 1, label = "1.0x" },
	{ value = 1.5, label = "1.5x" },
	{ value = 2, label = "2.0x" },
}

local function radiusOf(spec: any): number
	local radius = 3
	for _, comp in ipairs(spec.components or {}) do
		local offset = comp.offset or comp.offset1 or { 0, 0, 0 }
		local reach = math.sqrt((tonumber(offset[1]) or 0) ^ 2 + (tonumber(offset[2]) or 0) ^ 2 + (tonumber(offset[3]) or 0) ^ 2)
		if comp.kind == "particle" then
			local largest = 0
			for _, kp in ipairs(comp.size or {}) do
				largest = math.max(largest, tonumber(kp[2]) or 0)
			end
			reach += largest * 0.5
		elseif comp.kind == "part" then
			local size = comp.size or { 1, 1, 1 }
			reach += math.sqrt((tonumber(size[1]) or 1) ^ 2 + (tonumber(size[2]) or 1) ^ 2 + (tonumber(size[3]) or 1) ^ 2) * 0.5
		elseif comp.kind == "beam" then
			reach += math.abs(tonumber(comp.width0) or 0) + math.abs(tonumber(comp.curveSize0) or 0)
		end
		radius = math.max(radius, reach)
	end
	return math.clamp(radius, 3, 80)
end

function Preview.new(parent: Instance, ctx: any)
	local self = setmetatable({}, Preview)
	self.ctx = ctx
	self.store = ctx.store
	self.azimuth = 32
	self.elevation = 16
	self.distance = 16
	self.target = Vector3.new(0, 0.4, 0)
	self.autoFrame = true
	self.speed = 1
	self.playStarted = 0
	self.lastProgress = 0
	self.hovering = false
	self.dragging = false
	self.connections = {}

	local root = Kit.frame(parent, {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Theme.color.bg0,
		ClipsDescendants = true,
	})
	self.root = root

	local viewport = Instance.new("ViewportFrame")
	viewport.Size = UDim2.new(1, 0, 1, -44)
	viewport.Position = UDim2.fromOffset(0, 0)
	viewport.BackgroundColor3 = Theme.color.bg0
	viewport.BorderSizePixel = 0
	viewport.Ambient = BACKGROUNDS[1].ambient
	viewport.LightColor = BACKGROUNDS[1].light
	viewport.LightDirection = BACKGROUNDS[1].direction
	viewport.Parent = root
	self.viewport = viewport

	local world = Instance.new("WorldModel")
	world.Parent = viewport
	self.world = world

	local camera = Instance.new("Camera")
	camera.FieldOfView = 50
	camera.Parent = viewport
	viewport.CurrentCamera = camera
	self.camera = camera

	local floor = Instance.new("Part")
	floor.Name = "PreviewFloor"
	floor.Anchored = true
	floor.CanCollide = false
	floor.CanQuery = false
	floor.CanTouch = false
	floor.CastShadow = false
	floor.Material = Enum.Material.SmoothPlastic
	floor.Color = BACKGROUNDS[1].floor
	floor.Transparency = BACKGROUNDS[1].floorTransparency
	floor.Size = Vector3.new(0.2, 44, 44)
	floor.CFrame = CFrame.new(0, -1.15, 0) * CFrame.Angles(0, 0, math.pi / 2)
	floor.Parent = world
	self.floor = floor

	local rim = Instance.new("PointLight")
	rim.Brightness = 1.4
	rim.Range = 40
	rim.Color = Color3.fromRGB(150, 180, 255)
	rim.Shadows = false
	rim.Parent = floor

	-- Overlay: preset identity ------------------------------------------------
	local identity = Kit.frame(root, {
		Size = UDim2.new(1, -24, 0, 42),
		Position = UDim2.fromOffset(12, 10),
		BackgroundColor3 = Theme.color.bg0,
		BackgroundTransparency = 0.35,
		ClipsDescendants = false,
	})
	Theme.corner(identity, Theme.radius.sm)
	self.identity = identity

	self.nameLabel = Kit.label(identity, "Loading...", {
		Size = UDim2.new(1, -110, 0, 18),
		Position = UDim2.fromOffset(10, 4),
		Font = Theme.font.bold,
		TextSize = Theme.text.subtitle,
	})
	self.metaLabel = Kit.label(identity, "", {
		Size = UDim2.new(1, -110, 0, 14),
		Position = UDim2.fromOffset(10, 22),
		TextColor3 = Theme.color.textMuted,
		TextSize = Theme.text.tiny,
	})
	self.costButton = Kit.button(identity, "", {
		variant = "secondary",
		height = 24,
		size = UDim2.fromOffset(86, 24),
		textSize = Theme.text.tiny,
		onClick = function()
			ctx.openPanel("Cost")
		end,
		tooltip = "Open the performance report",
	})
	self.costButton.Position = UDim2.new(1, -96, 0, 9)

	-- Overlay: orbit hint ------------------------------------------------------
	self.hint = Kit.caption(viewport, "Drag to orbit  \u{00b7}  Scroll to zoom", {
		Size = UDim2.new(1, 0, 0, 14),
		Position = UDim2.new(0, 0, 1, -20),
		TextXAlignment = Enum.TextXAlignment.Center,
		TextColor3 = Theme.color.textFaint,
		TextSize = Theme.text.tiny,
	})

	-- Overlay: compile error ---------------------------------------------------
	self.errorFrame = Kit.frame(viewport, {
		Size = UDim2.new(1, -40, 0, 0),
		Position = UDim2.new(0, 20, 0.5, -30),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.color.badSoft,
		Visible = false,
		ClipsDescendants = false,
	})
	Theme.corner(self.errorFrame, Theme.radius.sm)
	self.errorLabel = Kit.label(self.errorFrame, "", {
		Size = UDim2.new(1, -20, 0, 0),
		Position = UDim2.fromOffset(10, 10),
		AutomaticSize = Enum.AutomaticSize.Y,
		TextWrapped = true,
		TextColor3 = Theme.color.bad,
		TextSize = Theme.text.small,
		TextYAlignment = Enum.TextYAlignment.Top,
	})

	-- Control bar --------------------------------------------------------------
	local bar = Kit.frame(root, {
		Size = UDim2.new(1, 0, 0, 44),
		Position = UDim2.new(0, 0, 1, -44),
		BackgroundColor3 = Theme.color.bg1,
	})
	self.bar = bar
	Theme.stroke(bar, Theme.color.line, 1, 0.5)

	local controls = Kit.hlist(bar, 6, {
		Size = UDim2.new(1, -20, 1, 0),
		Position = UDim2.fromOffset(10, 0),
	})
	controls.AutomaticSize = Enum.AutomaticSize.None
	controls.Size = UDim2.new(1, -20, 1, 0)

	self.playButton = Kit.button(controls, "\u{25b6}", {
		variant = "primary",
		size = UDim2.fromOffset(34, 28),
		textSize = 13,
		tooltip = "Play / pause  (Space)",
		onClick = function()
			self:togglePlay()
		end,
	})
	self.restartButton = Kit.iconButton(controls, "\u{21bb}", {
		size = UDim2.fromOffset(28, 28),
		tooltip = "Restart timeline  (R)",
		onClick = function()
			self:restart()
		end,
	})

	local speedHolder = Kit.frame(controls, {
		Size = UDim2.fromOffset(74, 28),
		BackgroundTransparency = 1,
	})
	local speedDropdown = Kit.dropdown(speedHolder, {
		options = SPEEDS,
		value = 1,
		height = 28,
		maxHeight = 140,
		onChange = function(value)
			self:setSpeed(tonumber(value) or 1)
		end,
	})
	speedDropdown.Set(1)
	speedHolder.Size = UDim2.fromOffset(74, 28)
	speedDropdown.Set(1)

	local loopToggle = Kit.toggle(controls, self.store:getPref("loop", false), function(value)
		self.store:setPref("loop", value)
		if self.player then
			self.player.loop = value
		end
		if value and self.player and not self.player:IsPlaying() then
			self:play()
		end
	end, "Loop the effect")
	self.loopToggle = loopToggle

	Kit.label(controls, "Loop", {
		Size = UDim2.fromOffset(30, 28),
		TextColor3 = Theme.color.textMuted,
		TextSize = Theme.text.tiny,
	})

	-- Spacer pushes the view controls to the right.
	local spacer = Kit.frame(controls, {
		Size = UDim2.fromOffset(8, 28),
		BackgroundTransparency = 1,
	})
	spacer.LayoutOrder = 50

	local zoomOut = Kit.iconButton(controls, "\u{2212}", {
		size = UDim2.fromOffset(26, 26),
		tooltip = "Zoom out",
		onClick = function()
			self:zoom(1.18)
		end,
	})
	local zoomIn = Kit.iconButton(controls, "+", {
		size = UDim2.fromOffset(26, 26),
		tooltip = "Zoom in",
		onClick = function()
			self:zoom(1 / 1.18)
		end,
	})
	local frameButton = Kit.iconButton(controls, "\u{25a3}", {
		size = UDim2.fromOffset(26, 26),
		tooltip = "Frame the effect",
		onClick = function()
			self:frameCamera()
		end,
	})

	local bgHolder = Kit.frame(controls, {
		Size = UDim2.fromOffset(112, 28),
		BackgroundTransparency = 1,
	})
	local backgroundDropdown = Kit.dropdown(bgHolder, {
		options = (function()
			local list = {}
			for _, entry in ipairs(BACKGROUNDS) do
				table.insert(list, { value = entry.value, label = entry.label })
			end
			return list
		end)(),
		value = self.store:getPref("background", "studio"),
		height = 28,
		maxHeight = 130,
		onChange = function(value)
			self:setBackground(tostring(value))
			self.store:setPref("background", tostring(value), { silent = true })
		end,
	})
	self.backgroundDropdown = backgroundDropdown

	-- Interactions -------------------------------------------------------------
	viewport.MouseEnter:Connect(function()
		self.hovering = true
		self.hint.Visible = false
	end)
	viewport.MouseLeave:Connect(function()
		self.hovering = false
	end)

	local orbitConnection
	viewport.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 then
			self.dragging = true
			self.dragOrigin = Vector2.new(input.Position.X, input.Position.Y)
		end
	end)

	table.insert(self.connections, UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement and self.dragging and self.dragOrigin then
			local delta = Vector2.new(input.Position.X, input.Position.Y) - self.dragOrigin
			self.dragOrigin = Vector2.new(input.Position.X, input.Position.Y)
			self.azimuth -= delta.X * 0.45
			self.elevation = math.clamp(self.elevation + delta.Y * 0.35, -78, 82)
			self:updateCamera()
		elseif input.UserInputType == Enum.UserInputType.MouseWheel and self.hovering then
			self:zoom(1 - input.Position.Z * 0.12)
		end
	end))

	table.insert(self.connections, UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 then
			self.dragging = false
		end
	end))

	-- Store bindings ------------------------------------------------------------
	table.insert(self.connections, self.store.signals:on("spec", function()
		self:rebuild(true)
	end))
	table.insert(self.connections, self.store.signals:on("field", function(payload)
		self:onField(payload)
	end))

	self:setBackground(self.store:getPref("background", "studio"))
	self:rebuild(true)
	return self
end

--------------------------------------------------------------------------------
-- model lifecycle
--------------------------------------------------------------------------------

function Preview:showError(message: string?)
	if message and message ~= "" then
		self.errorLabel.Text = "Preview error\n" .. message
		self.errorFrame.Visible = true
	else
		self.errorFrame.Visible = false
	end
end

function Preview:destroyModel()
	if self.player then
		pcall(function()
			self.player:Destroy()
		end)
		self.player = nil
	end
	if self.model then
		pcall(function()
			self.model:Destroy()
		end)
		self.model = nil
	end
end

function Preview:rebuild(restartPlayback: boolean?)
	local spec = self.store:working()
	local wasPlaying = self.player ~= nil and self.player:IsPlaying()

	if not self.model then
		local ok, result = pcall(Compiler.build, spec, self.world)
		if not ok then
			self:showError(tostring(result))
			self.ctx.toast("Could not build the preview", "error")
			return
		end
		self.model = result
	else
		local ok, err = pcall(Compiler.reconcile, self.model, spec)
		if not ok then
			-- A structural change it cannot reconcile: rebuild from scratch.
			self:destroyModel()
			local retryOk, result = pcall(Compiler.build, spec, self.world)
			if not retryOk then
				self:showError(tostring(result))
				return
			end
			self.model = result
			err = nil
		end
		if err then
			self:showError(tostring(err))
			return
		end
	end

	self:showError(nil)
	self.model.Name = tostring(spec.name or "Effect")

	local playerOk, playerOrError = pcall(Player.new, self.model, spec)
	if not playerOk then
		self:showError(tostring(playerOrError))
		return
	end
	if self.player then
		pcall(function()
			self.player:Destroy()
		end)
	end
	self.player = playerOrError
	self.player.loop = self.store:getPref("loop", false)
	self.player:SetSpeed(self.speed)

	self:updateIdentity()
	self:updateCost()

	local shouldPlay = wasPlaying or (restartPlayback and self.store:getPref("autoPlay", true))
	if shouldPlay then
		self:play()
	else
		self.player:Reset()
		self.lastProgress = 0
		self.playButton.Text = "\u{25b6}"
	end
end

function Preview:onField(payload: any)
	if not self.model then
		self:rebuild(false)
		return
	end
	local ok, err = pcall(Compiler.reconcile, self.model, self.store:working())
	if not ok then
		self:rebuild(false)
		return
	end
	if err then
		self:showError(tostring(err))
	else
		self:showError(nil)
	end
	if self.player then
		if payload and (payload.key == "startTime" or payload.key == "duration") then
			if self.player:IsPlaying() then
				self:play()
			end
		end
	end
	self:updateCost()
end

function Preview:updateIdentity()
	local spec = self.store:working()
	self.nameLabel.Text = tostring(spec.name or "Untitled")
	local tags = table.concat(spec.tags or {}, "  \u{00b7}  ")
	self.metaLabel.Text = string.format(
		"%s  \u{00b7}  %s  \u{00b7}  %d components",
		tostring(spec.category or "Custom"),
		Util.formatDuration(spec.duration or 1),
		#(spec.components or {})
	)
	if tags ~= "" then
		self.metaLabel.Text ..= "  \u{00b7}  " .. tags
	end
end

function Preview:updateCost()
	local report = Performance.analyze(self.store:working())
	local color = Theme.color.good
	if report.grade == "B" then
		color = Theme.color.accentBright
	elseif report.grade == "C" then
		color = Theme.color.warn
	elseif report.grade == "D" then
		color = Theme.color.bad
	end
	self.costButton.Text = string.format("%s  %d%%", report.grade, math.floor(report.score))
	self.costButton.TextColor3 = color
end

--------------------------------------------------------------------------------
-- playback
--------------------------------------------------------------------------------

function Preview:play()
	if not self.player then
		return
	end
	self.player.loop = self.store:getPref("loop", false)
	self.player:SetSpeed(self.speed)
	self.player:Reset()
	self.player:Play()
	self.playStarted = os.clock()
	self.lastProgress = 0
	self.playButton.Text = "\u{2016}\u{2016}"
end

function Preview:pause()
	if not self.player then
		return
	end
	self.lastProgress = self:progress()
	self.player:Stop()
	self.playButton.Text = "\u{25b6}"
end

function Preview:togglePlay()
	if not self.player then
		return
	end
	if self.player:IsPlaying() then
		self:pause()
	else
		self:play()
	end
end

function Preview:restart()
	self:play()
end

function Preview:setSpeed(speed: number)
	self.speed = math.clamp(speed or 1, 0.1, 4)
	if self.player then
		self.player:SetSpeed(self.speed)
	end
end

function Preview:progress(): number
	if not self.player or not self.player:IsPlaying() then
		return self.lastProgress or 0
	end
	local duration = math.max(0.1, tonumber(self.store:working().duration) or 1)
	local elapsed = (os.clock() - self.playStarted) * self.speed
	local fraction = elapsed / duration
	if self.player.loop then
		fraction = fraction % 1
	elseif fraction > 1 then
		fraction = 1
		self.lastProgress = 1
		self.playButton.Text = "\u{25b6}"
	end
	return math.clamp(fraction, 0, 1)
end

function Preview:isPlaying(): boolean
	return self.player ~= nil and self.player:IsPlaying()
end

--- Keeps the play glyph honest when a one-shot effect ends on its own.
function Preview:syncPlayState()
	if not self.player then
		return
	end
	local playing = self.player:IsPlaying()
	local glyph = if playing then "\u{2016}\u{2016}" else "\u{25b6}"
	if self.playButton.Text ~= glyph then
		self.playButton.Text = glyph
	end
end

--------------------------------------------------------------------------------
-- camera / environment
--------------------------------------------------------------------------------

function Preview:updateCamera()
	local azimuth = math.rad(self.azimuth)
	local elevation = math.rad(self.elevation)
	local direction = Vector3.new(
		math.cos(elevation) * math.sin(azimuth),
		math.sin(elevation),
		math.cos(elevation) * math.cos(azimuth)
	)
	self.camera.CFrame = CFrame.lookAt(self.target + direction * self.distance, self.target)
end

function Preview:frameCamera()
	local spec = self.store:working()
	local radius = radiusOf(spec)
	self.distance = math.clamp(radius * 2.7, 6, 220)
	self.target = Vector3.new(0, math.min(radius * 0.35, 8), 0)
	self:updateCamera()
end

function Preview:zoom(multiplier: number)
	self.distance = math.clamp(self.distance * multiplier, 3, 300)
	self:updateCamera()
end

function Preview:setBackground(name: string)
	local entry = BACKGROUNDS[1]
	for _, candidate in ipairs(BACKGROUNDS) do
		if candidate.value == name then
			entry = candidate
			break
		end
	end
	self.viewport.BackgroundColor3 = entry.background
	self.viewport.Ambient = entry.ambient
	self.viewport.LightColor = entry.light
	self.viewport.LightDirection = entry.direction
	self.floor.Color = entry.floor
	self.floor.Transparency = entry.floorTransparency
end

function Preview:destroy()
	for _, connection in ipairs(self.connections) do
		pcall(function()
			connection:Disconnect()
		end)
	end
	self:destroyModel()
	self.root:Destroy()
end

return Preview
