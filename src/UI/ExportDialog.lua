--[[
	ExportDialog - the shipping step.

	Pick a destination, review the pre-flight checks, generate the controller
	ModuleScript and either insert the effect into the place or save it as a
	.rbxm. Nothing happens until the developer presses Export.
]]

local Util = require(script.Parent.Parent.Core.Util)
local Theme = require(script.Parent.Parent.Core.Theme)
local Exporter = require(script.Parent.Parent.Core.Exporter)
local ScriptGenerator = require(script.Parent.Parent.Core.ScriptGenerator)
local Kit = require(script.Parent.Kit)

local ExportDialog = {}
ExportDialog.__index = ExportDialog

function ExportDialog.new(parent: Instance, ctx: any)
	local self = setmetatable({}, ExportDialog)
	self.ctx = ctx
	self.store = ctx.store
	self.destination = "ReplicatedStorage"
	self.withController = true

	local root = Kit.frame(parent, {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Theme.color.bg1,
	})
	self.root = root

	local header = Kit.frame(root, {
		Size = UDim2.new(1, 0, 0, 46),
		BackgroundTransparency = 1,
		ClipsDescendants = false,
	})
	Kit.label(header, "Export effect", {
		Position = UDim2.fromOffset(16, 9),
		Size = UDim2.new(1, -70, 0, 18),
		Font = Theme.font.bold,
		TextSize = Theme.text.title,
	})
	Kit.caption(header, "Real instances, a working controller and an undo step.", {
		Position = UDim2.fromOffset(16, 27),
		Size = UDim2.new(1, -70, 0, 14),
		TextSize = Theme.text.tiny,
	})
	local close = Kit.iconButton(header, "\u{00d7}", {
		size = UDim2.fromOffset(26, 26),
		tooltip = "Close",
		onClick = function()
			ctx.closeModal()
		end,
	})
	close.Position = UDim2.new(1, -38, 0, 10)

	local body = Kit.scroll(root, {
		Size = UDim2.new(1, 0, 1, -108),
		Position = UDim2.fromOffset(0, 46),
	}, 16)
	self.body = body

	local actionBar = Kit.hlist(root, 8, {
		Size = UDim2.new(1, -32, 0, 34),
		Position = UDim2.new(0, 16, 1, -48),
	})
	actionBar.AutomaticSize = Enum.AutomaticSize.None
	actionBar.Size = UDim2.new(1, -32, 0, 34)

	self.exportButton = Kit.button(actionBar, "Export to place", {
		variant = "primary",
		height = 34,
		size = UDim2.fromOffset(140, 34),
		onClick = function()
			self:export()
		end,
	})
	Kit.button(actionBar, "Save .rbxm", {
		variant = "secondary",
		height = 34,
		size = UDim2.fromOffset(104, 34),
		tooltip = "Save the effect as a model file through Studio's save dialog",
		onClick = function()
			self:saveFile()
		end,
	})
	self.actionHint = Kit.caption(actionBar, "", {
		Size = UDim2.new(1, -260, 0, 34),
		TextXAlignment = Enum.TextXAlignment.Right,
		TextWrapped = true,
		TextSize = Theme.text.tiny,
	})

	self:render()
	return self
end

function ExportDialog:render()
	Kit.clear(self.body)
	local spec = self.store:working()

	-- Preset summary
	local title = Kit.frame(self.body, {
		Size = UDim2.new(1, 0, 0, 48),
		BackgroundColor3 = Theme.color.bg2,
	})
	Theme.corner(title, Theme.radius.md)
	Kit.label(title, tostring(spec.name or "Effect"), {
		Position = UDim2.fromOffset(12, 7),
		Size = UDim2.new(1, -24, 0, 16),
		Font = Theme.font.medium,
		TextSize = Theme.text.body,
	})
	Kit.caption(title, string.format(
		"%s  \u{00b7}  %d components  \u{00b7}  %s  \u{00b7}  %s",
		tostring(spec.category or "Custom"),
		#(spec.components or {}),
		Util.formatDuration(spec.duration or 1),
		if spec.loop then "looping" else "one-shot"
	), {
		Position = UDim2.fromOffset(12, 25),
		Size = UDim2.new(1, -24, 0, 14),
		TextSize = Theme.text.tiny,
	})

	-- Destination
	Kit.sectionTitle(self.body, "Destination")
	local destinationRow, destinationHolder = Kit.row(self.body, "Parent to", "Where the exported Model is inserted.", 30)
	local destinationDropdown = Kit.dropdown(destinationHolder, {
		options = Exporter.DESTINATIONS,
		value = self.destination,
		height = 28,
		onChange = function(value)
			self.destination = tostring(value)
		end,
	})
	destinationDropdown.Parent = destinationHolder

	local nameRow, nameHolder = Kit.row(self.body, "Model name", "Duplicate names get a numeric suffix.", 30)
	local nameBox = Kit.textBox(nameHolder, tostring(spec.name or "VFX Effect"), {
		size = UDim2.new(1, 0, 0, 28),
		onSubmit = function(text)
			self.customName = Util.trim(text)
		end,
	})
	nameBox.Parent = nameHolder

	local controllerRow, controllerHolder = Kit.row(self.body, "Controller script", "Adds VFXController, a ready-to-use ModuleScript that plays the effect.", 30)
	local controllerToggle = Kit.toggle(controllerHolder, self.withController, function(value)
		self.withController = value
	end)
	controllerToggle.Parent = controllerHolder

	-- Validation
	Kit.sectionTitle(self.body, "Pre-flight checks")
	local issues = Exporter.validate(spec)
	for _, issue in ipairs(issues) do
		local color = if issue.severity == "high"
			then Theme.color.bad
			elseif issue.severity == "medium"
			then Theme.color.warn
			elseif issue.severity == "ok"
			then Theme.color.good
			else Theme.color.textMuted
		local row = Kit.frame(self.body, {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = Theme.color.bg2,
			ClipsDescendants = false,
		})
		Theme.corner(row, Theme.radius.xs)
		local pad = Instance.new("UIPadding")
		pad.PaddingTop = UDim.new(0, 6)
		pad.PaddingBottom = UDim.new(0, 6)
		pad.PaddingLeft = UDim.new(0, 8)
		pad.PaddingRight = UDim.new(0, 8)
		pad.Parent = row

		local dot = Kit.frame(row, {
			Size = UDim2.fromOffset(6, 6),
			Position = UDim2.fromOffset(0, 6),
			BackgroundColor3 = color,
		})
		Theme.corner(dot, Theme.radius.pill)

		Kit.label(row, issue.message, {
			Size = UDim2.new(1, -16, 0, 0),
			Position = UDim2.fromOffset(14, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			TextWrapped = true,
			TextSize = Theme.text.small,
			TextColor3 = if issue.severity == "ok" then Theme.color.good else Theme.color.text,
			TextYAlignment = Enum.TextYAlignment.Top,
		})
	end

	-- Controller source
	Kit.sectionTitle(self.body, "Generated controller")
	local sourceCard = Kit.frame(self.body, {
		Size = UDim2.new(1, 0, 0, 168),
		BackgroundColor3 = Theme.color.bg0,
		ClipsDescendants = true,
	})
	Theme.corner(sourceCard, Theme.radius.sm)
	Theme.stroke(sourceCard, Theme.color.line, 1, 0.4)

	local source = Kit.textBox(sourceCard, ScriptGenerator.generate(spec), {
		size = UDim2.new(1, -16, 1, -16),
		font = Theme.font.mono,
		textSize = 10,
	})
	source.Position = UDim2.fromOffset(8, 8)
	source.TextWrapped = false
	source.TextYAlignment = Enum.TextYAlignment.Top
	source.TextXAlignment = Enum.TextXAlignment.Left
	source.ClearTextOnFocus = false

	Kit.sectionTitle(self.body, "Usage")
	local usageCard = Kit.frame(self.body, {
		Size = UDim2.new(1, 0, 0, 128),
		BackgroundColor3 = Theme.color.bg0,
	})
	Theme.corner(usageCard, Theme.radius.sm)
	local usage = Kit.textBox(usageCard, ScriptGenerator.usage(spec), {
		size = UDim2.new(1, -16, 1, -16),
		font = Theme.font.mono,
		textSize = 10,
	})
	usage.Position = UDim2.fromOffset(8, 8)
	usage.TextYAlignment = Enum.TextYAlignment.Top
	usage.TextWrapped = false

	Kit.caption(self.body, "Tip: select the exported model and press Import in the Inspector to pull it back in for more edits.", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		TextWrapped = true,
		TextSize = Theme.text.tiny,
	})
end

function ExportDialog:export()
	local spec = self.store:working()
	local model, err = Exporter.export(spec, {
		destination = self.destination,
		name = self.customName or spec.name,
		withController = self.withController,
	})
	if not model then
		self.ctx.toast(err or "Export failed", "error")
		return
	end
	Util.Selection:Set({ model })
	self.ctx.toast("Exported " .. model:GetFullName(), "success")
	self.ctx.closeModal()
end

function ExportDialog:saveFile()
	local ok, err = Exporter.saveToFile(self.store:working(), self.ctx.plugin)
	if not ok then
		self.ctx.toast(err or "Save failed", "error")
		return
	end
	self.ctx.toast("Save dialog opened", "info")
end

function ExportDialog:destroy()
	self.root:Destroy()
end

return ExportDialog
