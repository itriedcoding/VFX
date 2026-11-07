--[[
	App - the editor shell.

	Owns the layout (resizable library / stage / inspector), the toolbar, the
	toast stack, modals, keyboard shortcuts and the heartbeat that drives the
	playhead. Panels are created defensively so a failure in one never takes
	the whole plugin down.
]]

local Util = require(script.Parent.Parent.Core.Util)
local Theme = require(script.Parent.Parent.Core.Theme)
local Assets = require(script.Parent.Parent.Core.Assets)
local Store = require(script.Parent.Parent.Core.Store)
local Presets = require(script.Parent.Parent.Presets)
local Decompiler = require(script.Parent.Parent.Core.Decompiler)
local Kit = require(script.Parent.Kit)
local Library = require(script.Parent.Library)
local Preview = require(script.Parent.Preview)
local Timeline = require(script.Parent.Timeline)
local Inspector = require(script.Parent.Inspector)
local AssetsPanel = require(script.Parent.AssetsPanel)
local ExportDialog = require(script.Parent.ExportDialog)

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local App = {}
App.__index = App

local TOP_HEIGHT = 48
local STATUS_HEIGHT = 22
local TIMELINE_HEIGHT = 172
local MIN_LEFT = 230
local MAX_LEFT = 400
local MIN_RIGHT = 280
local MAX_RIGHT = 440

function App.new(pluginInstance: Plugin, widget: DockWidgetPluginGui)
	local self = setmetatable({}, App)
	self.plugin = pluginInstance
	self.widget = widget
	self.connections = {}
	self.leftEnabled = true
	self.rightEnabled = true
	self.leftWidth = 286
	self.rightWidth = 322

	local store = Store.new(pluginInstance, Presets)
	Assets.setCustom(store:getPref("customAssets", {}))
	store.prefs.background = store:getPref("background", "studio")
	self.store = store

	Kit.setOverlay(nil)

	local root = Kit.frame(widget, {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Theme.color.bg0,
		ClipsDescendants = true,
	})
	self.root = root
	Kit.setOverlay(root)

	self.toastLayer = Kit.frame(root, {
		Size = UDim2.fromOffset(300, 0),
		Position = UDim2.new(1, -312, 1, -STATUS_HEIGHT - 8),
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.Y,
		ClipsDescendants = false,
		ZIndex = 60,
	})
	self.toastLayer.AnchorPoint = Vector2.new(0, 1)
	local toastLayout = Instance.new("UIListLayout")
	toastLayout.Padding = UDim.new(0, 6)
	toastLayout.SortOrder = Enum.SortOrder.LayoutOrder
	toastLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	toastLayout.Parent = self.toastLayer

	local ctx = {
		plugin = pluginInstance,
		store = store,
		presets = Presets,
		toast = function(message: string, kind: string?)
			self:toast(message, kind)
		end,
		closeModal = function()
			self:closeModal()
		end,
		openPanel = function(name: string)
			if self.inspector then
				self.inspector:showTab(name)
			end
		end,
		openAssetPicker = function(callback: (string) -> ())
			self:openAssetPicker(callback)
		end,
		promptSavePreset = function()
			self:promptSavePreset()
		end,
		importSelection = function()
			self:importSelection()
		end,
		reloadPreset = function()
			self:reloadPreset()
		end,
	}
	self.ctx = ctx

	-- Top bar -----------------------------------------------------------------
	local topBar = Kit.frame(root, {
		Size = UDim2.new(1, 0, 0, TOP_HEIGHT),
		BackgroundColor3 = Theme.color.bg1,
	})
	self.topBar = topBar
	Theme.stroke(topBar, Theme.color.line, 1, 0.35)

	local logo = Kit.frame(topBar, {
		Size = UDim2.fromOffset(26, 26),
		Position = UDim2.fromOffset(12, 11),
		BackgroundColor3 = Theme.color.accent,
	})
	Theme.corner(logo, Theme.radius.sm)
	Kit.label(logo, "\u{273b}", {
		Size = UDim2.fromScale(1, 1),
		TextColor3 = Theme.color.white,
		TextSize = 15,
		Font = Theme.font.bold,
		TextXAlignment = Enum.TextXAlignment.Center,
	})
	local logoGradient = Instance.new("UIGradient")
	logoGradient.Color = ColorSequence.new(Theme.color.accentBright, Theme.color.accentDeep)
	logoGradient.Rotation = 130
	logoGradient.Parent = logo

	Kit.label(topBar, "VFX Studio", {
		Position = UDim2.fromOffset(46, 8),
		Size = UDim2.fromOffset(110, 18),
		Font = Theme.font.bold,
		TextSize = Theme.text.title,
	})
	Kit.caption(topBar, "Roblox visual effects editor", {
		Position = UDim2.fromOffset(46, 26),
		Size = UDim2.fromOffset(180, 12),
		TextSize = Theme.text.tiny,
	})

	self.leftToggle = Kit.iconButton(topBar, "\u{25a4}", {
		size = UDim2.fromOffset(26, 26),
		tooltip = "Toggle the preset library",
		onClick = function()
			self.leftEnabled = not self.leftEnabled
			self:refreshLayout()
		end,
	})
	self.leftToggle.Position = UDim2.fromOffset(206, 11)

	self.rightToggle = Kit.iconButton(topBar, "\u{25a5}", {
		size = UDim2.fromOffset(26, 26),
		tooltip = "Toggle the inspector",
		onClick = function()
			self.rightEnabled = not self.rightEnabled
			self:refreshLayout()
		end,
	})
	self.rightToggle.Position = UDim2.fromOffset(236, 11)

	local rightGroup = Kit.hlist(topBar, 6, {
		Size = UDim2.new(0, 0, 0, 28),
		Position = UDim2.new(1, -12, 0, 10),
		AutomaticSize = Enum.AutomaticSize.X,
	})
	rightGroup.AutomaticSize = Enum.AutomaticSize.X
	rightGroup.Size = UDim2.fromOffset(0, 28)
	rightGroup.AnchorPoint = Vector2.new(1, 0)
	rightGroup.Position = UDim2.new(1, -12, 0, 10)

	self.undoButton = Kit.iconButton(rightGroup, "\u{21b6}", {
		size = UDim2.fromOffset(28, 28),
		tooltip = "Undo  (Ctrl+Z)",
		onClick = function()
			self.store:undo()
		end,
	})
	self.redoButton = Kit.iconButton(rightGroup, "\u{21b7}", {
		size = UDim2.fromOffset(28, 28),
		tooltip = "Redo  (Ctrl+Y)",
		onClick = function()
			self.store:redo()
		end,
	})

	Kit.button(rightGroup, "Import", {
		variant = "ghost",
		height = 28,
		size = UDim2.fromOffset(62, 28),
		tooltip = "Import the selected instance",
		onClick = function()
			self:importSelection()
		end,
	})
	self.assetsButton = Kit.button(rightGroup, "Assets", {
		variant = "secondary",
		height = 28,
		size = UDim2.fromOffset(60, 28),
		onClick = function()
			self:openAssetPicker(nil)
		end,
	})
	self.exportButton = Kit.button(rightGroup, "Export", {
		variant = "primary",
		height = 28,
		size = UDim2.fromOffset(68, 28),
		onClick = function()
			self:openExportDialog()
		end,
	})

	-- Panels ------------------------------------------------------------------
	local leftPanel = Kit.frame(root, {
		Size = UDim2.fromOffset(self.leftWidth, 1),
		Position = UDim2.fromOffset(0, TOP_HEIGHT),
		BackgroundColor3 = Theme.color.bg1,
	})
	self.leftPanel = leftPanel

	local rightPanel = Kit.frame(root, {
		Size = UDim2.fromOffset(self.rightWidth, 1),
		Position = UDim2.new(1, -self.rightWidth, 0, TOP_HEIGHT),
		BackgroundColor3 = Theme.color.bg1,
	})
	self.rightPanel = rightPanel

	local center = Kit.frame(root, {
		Size = UDim2.new(1, 0, 1, 0),
		Position = UDim2.fromOffset(0, TOP_HEIGHT),
		BackgroundColor3 = Theme.color.bg0,
	})
	self.center = center

	local stage = Kit.frame(center, {
		Size = UDim2.new(1, 0, 1, -TIMELINE_HEIGHT),
		BackgroundColor3 = Theme.color.bg0,
	})
	self.stage = stage

	local timelineHolder = Kit.frame(center, {
		Size = UDim2.new(1, 0, 0, TIMELINE_HEIGHT),
		Position = UDim2.new(0, 0, 1, -TIMELINE_HEIGHT),
		BackgroundColor3 = Theme.color.bg1,
	})
	Theme.stroke(timelineHolder, Theme.color.line, 1, 0.4)

	local leftResizer = Kit.frame(root, {
		Size = UDim2.fromOffset(5, 1),
		Position = UDim2.fromOffset(self.leftWidth, TOP_HEIGHT),
		BackgroundTransparency = 1,
		ZIndex = 20,
	})
	self.leftResizer = leftResizer

	local rightResizer = Kit.frame(root, {
		Size = UDim2.fromOffset(5, 1),
		Position = UDim2.new(1, -self.rightWidth - 5, 0, TOP_HEIGHT),
		BackgroundTransparency = 1,
		ZIndex = 20,
	})
	self.rightResizer = rightResizer

	local leftGrip = Kit.frame(leftResizer, {
		Size = UDim2.new(0, 1, 1, 0),
		Position = UDim2.new(0.5, -0.5, 0, 0),
		BackgroundColor3 = Theme.color.line,
		BackgroundTransparency = 0.5,
	})
	local rightGrip = Kit.frame(rightResizer, {
		Size = UDim2.new(0, 1, 1, 0),
		Position = UDim2.new(0.5, -0.5, 0, 0),
		BackgroundColor3 = Theme.color.line,
		BackgroundTransparency = 0.5,
	})

	Kit.drag(leftResizer, {
		begin = function()
			self.resizing = "left"
		end,
		move = function(x)
			local width = math.clamp(x - root.AbsolutePosition.X, MIN_LEFT, MAX_LEFT)
			self.leftWidth = width
			self:refreshLayout()
		end,
		finish = function()
			self.resizing = nil
			self.store:setPref("leftWidth", self.leftWidth, { silent = true })
		end,
	})
	Kit.drag(rightResizer, {
		begin = function()
			self.resizing = "right"
		end,
		move = function(x)
			local width = math.clamp(root.AbsolutePosition.X + root.AbsoluteSize.X - x, MIN_RIGHT, MAX_RIGHT)
			self.rightWidth = width
			self:refreshLayout()
		end,
		finish = function()
			self.resizing = nil
			self.store:setPref("rightWidth", self.rightWidth, { silent = true })
		end,
	})

	-- Status bar ---------------------------------------------------------------
	local status = Kit.frame(root, {
		Size = UDim2.new(1, 0, 0, STATUS_HEIGHT),
		Position = UDim2.new(0, 0, 1, -STATUS_HEIGHT),
		BackgroundColor3 = Theme.color.bg1,
	})
	Theme.stroke(status, Theme.color.line, 1, 0.6)
	self.statusText = Kit.caption(status, "", {
		Position = UDim2.fromOffset(10, 0),
		Size = UDim2.new(0.6, 0, 1, 0),
		TextSize = Theme.text.tiny,
	})
	local shortcuts = Kit.caption(status, "Space play  \u{00b7}  R restart  \u{00b7}  Del remove  \u{00b7}  Ctrl+Z undo", {
		Position = UDim2.new(0.4, 0, 0, 0),
		Size = UDim2.new(0.6, -12, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Right,
		TextSize = Theme.text.tiny,
	})

	-- Modal layer --------------------------------------------------------------
	local modalLayer = Kit.frame(root, {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Theme.color.black,
		BackgroundTransparency = 0.45,
		Visible = false,
		ZIndex = 50,
		ClipsDescendants = false,
	})
	self.modalLayer = modalLayer

	-- Panels ------------------------------------------------------------------
	self.ctx.store = store
	store.signals:on("status", function(message: string)
		self:toast(message, "info")
	end)

	local okLibrary, libraryOrError = pcall(Library.new, leftPanel, ctx)
	if okLibrary then
		self.library = libraryOrError
	else
		warn("[VFX Studio] library failed: " .. tostring(libraryOrError))
		Kit.label(leftPanel, "The preset library failed to load.\n" .. tostring(libraryOrError), {
			Size = UDim2.new(1, -24, 0, 80),
			Position = UDim2.fromOffset(12, 60),
			TextWrapped = true,
			TextColor3 = Theme.color.bad,
			TextYAlignment = Enum.TextYAlignment.Top,
		})
	end

	local okPreview, previewOrError = pcall(Preview.new, stage, ctx)
	if okPreview then
		self.preview = previewOrError
		ctx.preview = self.preview
	else
		warn("[VFX Studio] preview failed: " .. tostring(previewOrError))
		Kit.label(stage, "The live preview failed to start.\n" .. tostring(previewOrError), {
			Size = UDim2.new(1, -40, 0, 100),
			Position = UDim2.fromOffset(20, 40),
			TextWrapped = true,
			TextColor3 = Theme.color.bad,
			TextYAlignment = Enum.TextYAlignment.Top,
		})
	end

	local okTimeline, timelineOrError = pcall(Timeline.new, timelineHolder, ctx)
	if okTimeline then
		self.timeline = timelineOrError
	else
		warn("[VFX Studio] timeline failed: " .. tostring(timelineOrError))
		Kit.label(timelineHolder, "Timeline unavailable: " .. tostring(timelineOrError), {
			Size = UDim2.new(1, -24, 0, 40),
			Position = UDim2.fromOffset(12, 12),
			TextWrapped = true,
			TextColor3 = Theme.color.bad,
		})
	end

	local okInspector, inspectorOrError = pcall(Inspector.new, rightPanel, ctx)
	if okInspector then
		self.inspector = inspectorOrError
	else
		warn("[VFX Studio] inspector failed: " .. tostring(inspectorOrError))
		Kit.label(rightPanel, "The inspector failed to load.\n" .. tostring(inspectorOrError), {
			Size = UDim2.new(1, -24, 0, 80),
			Position = UDim2.fromOffset(12, 44),
			TextWrapped = true,
			TextColor3 = Theme.color.bad,
			TextYAlignment = Enum.TextYAlignment.Top,
		})
	end

	self:bindHistory()
	self:bindShortcuts()
	self:refreshLayout()
	self:updateStatus()
	self:startHeartbeat()
	store:scheduleSave()
	return self
end

--------------------------------------------------------------------------------
-- layout
--------------------------------------------------------------------------------

function App:refreshLayout()
	local width = self.root.AbsoluteSize.X
	local showLeft = self.leftEnabled and width >= 780
	local showRight = self.rightEnabled and width >= 700

	if showLeft ~= self.leftVisible then
		self.leftVisible = showLeft
	end
	if showRight ~= self.rightVisible then
		self.rightVisible = showRight
	end

	local leftWidth = if showLeft then self.leftWidth else 0
	local rightWidth = if showRight then self.rightWidth else 0

	self.leftPanel.Visible = showLeft
	self.leftPanel.Size = UDim2.new(0, leftWidth, 1, -TOP_HEIGHT - STATUS_HEIGHT)
	self.leftResizer.Visible = showLeft
	self.leftResizer.Position = UDim2.fromOffset(leftWidth, TOP_HEIGHT)
	self.leftResizer.Size = UDim2.new(0, 5, 1, -TOP_HEIGHT - STATUS_HEIGHT)

	self.rightPanel.Visible = showRight
	self.rightPanel.Size = UDim2.new(0, rightWidth, 1, -TOP_HEIGHT - STATUS_HEIGHT)
	self.rightPanel.Position = UDim2.new(1, -rightWidth, 0, TOP_HEIGHT)
	self.rightResizer.Visible = showRight
	self.rightResizer.Position = UDim2.new(1, -rightWidth - 5, 0, TOP_HEIGHT)
	self.rightResizer.Size = UDim2.new(0, 5, 1, -TOP_HEIGHT - STATUS_HEIGHT)

	self.center.Position = UDim2.fromOffset(leftWidth, TOP_HEIGHT)
	self.center.Size = UDim2.new(1, -(leftWidth + rightWidth), 1, -TOP_HEIGHT - STATUS_HEIGHT)

	self.leftToggle.TextColor3 = if showLeft then Theme.color.accentBright else Theme.color.textFaint
	self.rightToggle.TextColor3 = if showRight then Theme.color.accentBright else Theme.color.textFaint
	Kit.setOverlay(self.root)
end

--------------------------------------------------------------------------------
-- history + status
--------------------------------------------------------------------------------

function App:bindHistory()
	self.store.signals:on("history", function()
		if self.undoButton then
			self.undoButton.TextColor3 = if self.store.history:canUndo() then Theme.color.text else Theme.color.textFaint
		end
		if self.redoButton then
			self.redoButton.TextColor3 = if self.store.history:canRedo() then Theme.color.text else Theme.color.textFaint
		end
		self:updateStatus()
	end)
	self.store.signals:on("spec", function()
		self:updateStatus()
	end)
	self.store.signals:on("selection", function()
		self:updateStatus()
	end)
	self.store.signals:on("pref", function()
		self:updateStatus()
	end)
	self.undoButton.TextColor3 = Theme.color.textFaint
	self.redoButton.TextColor3 = Theme.color.textFaint
end

function App:updateStatus()
	if not self.statusText then
		return
	end
	local spec = self.store:working()
	local undoLabel = self.store.history:peekUndo()
	self.statusText.Text = string.format(
		"%d presets  \u{00b7}  %s  \u{00b7}  %d/%d components%s",
		#self.store.presets.all + #self.store.custom,
		tostring(spec.name or "Untitled"),
		self.store.selection,
		#spec.components,
		if undoLabel then "  \u{00b7}  undo: " .. tostring(undoLabel) else ""
	)
end

function App:startHeartbeat()
	table.insert(self.connections, RunService.Heartbeat:Connect(function()
		if not self.preview or not self.timeline then
			return
		end
		local fraction = self.preview:progress()
		local duration = math.max(0.1, tonumber(self.store:working().duration) or 1)
		self.timeline:setProgress(fraction, fraction * duration)
		if self.preview.syncPlayState then
			self.preview:syncPlayState()
		end
	end))

	table.insert(self.connections, self.root:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:refreshLayout()
	end))
end

--------------------------------------------------------------------------------
-- shortcuts
--------------------------------------------------------------------------------

function App:bindShortcuts()
	table.insert(self.connections, UserInputService.InputBegan:Connect(function(input, processed)
		if processed or UserInputService:GetFocusedTextBox() then
			return
		end
		local key = input.KeyCode
		if key == Enum.KeyCode.Space then
			if self.preview then
				self.preview:togglePlay()
			end
		elseif key == Enum.KeyCode.R then
			if self.preview then
				self.preview:restart()
			end
		elseif key == Enum.KeyCode.Delete or key == Enum.KeyCode.Backspace then
			if #self.store:working().components > 1 then
				self.store:removeComponent(self.store.selection)
			else
				self:toast("An effect needs at least one component", "warn")
			end
		elseif key == Enum.KeyCode.Z and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
			self.store:undo()
		elseif key == Enum.KeyCode.Y and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
			self.store:redo()
		elseif key == Enum.KeyCode.D and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
			self.store:duplicateComponent(self.store.selection)
		end
	end))
end

--------------------------------------------------------------------------------
-- toasts
--------------------------------------------------------------------------------

function App:toast(message: string, kind: string?)
	if not message or message == "" then
		return
	end
	local color = Theme.color.accent
	if kind == "success" then
		color = Theme.color.good
	elseif kind == "error" then
		color = Theme.color.bad
	elseif kind == "warn" then
		color = Theme.color.warn
	end

	local toast = Kit.frame(self.toastLayer, {
		Size = UDim2.new(1, 0, 0, 30),
		BackgroundColor3 = Theme.color.bg2,
		BackgroundTransparency = 0.05,
		ClipsDescendants = true,
		ZIndex = 61,
	})
	Theme.corner(toast, Theme.radius.sm)
	Theme.stroke(toast, Theme.color.lineBright, 1, 0.4)

	local stripe = Kit.frame(toast, {
		Size = UDim2.new(0, 3, 1, 0),
		BackgroundColor3 = color,
	})
	Kit.label(toast, message, {
		Size = UDim2.new(1, -20, 1, 0),
		Position = UDim2.fromOffset(11, 0),
		TextSize = Theme.text.small,
		TextWrapped = true,
		TextTruncate = Enum.TextTruncate.AtEnd,
	})

	task.delay(3.4, function()
		if not toast.Parent then
			return
		end
		Util.tween(toast, { BackgroundTransparency = 1 }, 0.25)
		task.delay(0.28, function()
			if toast.Parent then
				toast:Destroy()
			end
		end)
	end)
end

--------------------------------------------------------------------------------
-- modals
--------------------------------------------------------------------------------

function App:closeModal()
	if self.modalContent then
		pcall(function()
			self.modalContent:destroy()
		end)
		self.modalContent = nil
	end
	if self.modalCard then
		self.modalCard:Destroy()
		self.modalCard = nil
	end
	self.modalLayer.Visible = false
end

function App:openModal(width: number, height: number, kind: string?): Frame
	self:closeModal()
	self.modalLayer.Visible = true
	local card = Kit.frame(self.modalLayer, {
		Size = UDim2.fromOffset(width, height),
		Position = UDim2.new(0.5, -width / 2, 0.5, -height / 2),
		BackgroundColor3 = if kind == "assets" then Theme.color.bg1 else Theme.color.bg1,
		ClipsDescendants = true,
		ZIndex = 51,
	})
	Theme.corner(card, Theme.radius.lg)
	Theme.stroke(card, Theme.color.lineBright, 1, 0.3)
	self.modalCard = card
	return card
end

function App:openAssetPicker(callback: ((string) -> ())?)
	local card = self:openModal(660, 560, "assets")
	local panel = AssetsPanel.new(card, {
		store = self.store,
		toast = function(message: string, kind: string?)
			self:toast(message, kind)
		end,
		closeModal = function()
			self:closeModal()
		end,
	}, function(uri: string)
		self:closeModal()
		if callback then
			callback(uri)
		else
			self:toast("Texture selected: " .. uri, "info")
		end
	end)
	self.modalContent = panel
end

function App:openExportDialog()
	local card = self:openModal(600, 640)
	local dialog = ExportDialog.new(card, self.ctx)
	self.modalContent = dialog
end

function App:promptSavePreset()
	local card = self:openModal(380, 216)
	local store = self.store

	local header = Kit.hlist(card, 8, {
		Size = UDim2.new(1, -32, 0, 24),
		Position = UDim2.fromOffset(16, 14),
	})
	header.AutomaticSize = Enum.AutomaticSize.None
	header.Size = UDim2.new(1, -32, 0, 24)
	Kit.label(header, "Save as preset", {
		Size = UDim2.new(1, -30, 1, 0),
		Font = Theme.font.bold,
		TextSize = Theme.text.title,
	})
	Kit.caption(card, "Stored in this Studio install and available under My Presets.", {
		Size = UDim2.new(1, -32, 0, 14),
		Position = UDim2.fromOffset(16, 40),
		TextSize = Theme.text.tiny,
	})

	local nameBox = Kit.textBox(card, tostring(store:working().name or "My Effect"), {
		placeholder = "Preset name",
		size = UDim2.new(1, -32, 0, 30),
	})
	;(nameBox :: TextBox).Position = UDim2.fromOffset(16, 62)

	local actions = Kit.hlist(card, 8, {
		Size = UDim2.new(1, -32, 0, 30),
		Position = UDim2.new(0, 16, 1, -46),
	})
	actions.AutomaticSize = Enum.AutomaticSize.None
	actions.Size = UDim2.new(1, -32, 0, 30)

	Kit.button(actions, "Cancel", {
		variant = "ghost",
		height = 30,
		size = UDim2.fromOffset(78, 30),
		onClick = function()
			self:closeModal()
		end,
	})
	Kit.button(actions, "Save preset", {
		variant = "primary",
		height = 30,
		size = UDim2.fromOffset(104, 30),
		onClick = function()
			local saved = store:saveCustomPreset(nameBox.Text)
			if self.library then
				self.library:refreshCategories()
				self.library:refresh()
			end
			self:toast("Saved preset \"" .. tostring(saved.name) .. "\"", "success")
			self:closeModal()
		end,
	})

	nameBox:CaptureFocus()
end

--------------------------------------------------------------------------------
-- actions
--------------------------------------------------------------------------------

function App:importSelection()
	local selection = Util.Selection:Get()
	if #selection == 0 then
		self:toast("Select a ParticleEmitter, model or effect in the Explorer first", "warn")
		return
	end

	local spec
	local errors = {}
	for _, instance in ipairs(selection) do
		local ok, result = pcall(Decompiler.fromInstance, instance)
		if ok and result then
			spec = result
			break
		elseif not ok then
			table.insert(errors, tostring(result))
		end
	end

	if not spec then
		self:toast("Nothing importable in that selection", "error")
		if errors[1] then
			warn("[VFX Studio] import failed: " .. errors[1])
		end
		return
	end

	self.store:applyPreset(spec, "Import " .. tostring(spec.name))
	self:toast(string.format("Imported %d component(s)", #spec.components), "success")
end

function App:reloadPreset()
	local id = self.store.prefs.lastPresetId
	local spec = Presets.get(id) or self.store:findCustom(id)
	if not spec then
		self:toast("This effect has no stored preset to reload", "info")
		return
	end
	self.store:applyPreset(spec, "Reload " .. tostring(spec.name))
	self:toast("Reloaded " .. tostring(spec.name), "info")
end

function App:destroy()
	for _, connection in ipairs(self.connections) do
		pcall(function()
			connection:Disconnect()
		end)
	end
	if self.preview then
		pcall(function()
			self.preview:destroy()
		end)
	end
	if self.timeline then
		pcall(function()
			self.timeline:destroy()
		end)
	end
	if self.inspector then
		pcall(function()
			self.inspector:destroy()
		end)
	end
	if self.library then
		pcall(function()
			self.library:destroy()
		end)
	end
	self.store:save()
	self.root:Destroy()
end

return App
