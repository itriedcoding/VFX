--[[
	Timeline - the emission timeline.

	One row per component with a draggable bar: drag the body to slide it in
	time, drag either edge to change its window. The playhead follows the live
	preview, and clicking a row selects that component everywhere in the UI.
]]

local Util = require(script.Parent.Parent.Core.Util)
local Theme = require(script.Parent.Parent.Core.Theme)
local Kit = require(script.Parent.Kit)

local Timeline = {}
Timeline.__index = Timeline

local ROW_HEIGHT = 24
local NAME_WIDTH = 118

local KIND_COLORS = {
	particle = Theme.color.accent,
	beam = Color3.fromRGB(96, 208, 255),
	trail = Color3.fromRGB(96, 226, 168),
	light = Theme.color.warn,
	part = Color3.fromRGB(184, 150, 255),
	tween = Theme.color.textMuted,
}

local KIND_GLYPHS = {
	particle = "\u{273b}",
	beam = "\u{2726}",
	trail = "\u{2192}",
	light = "\u{2600}",
	part = "\u{25c6}",
	tween = "\u{21bb}",
}

function Timeline.new(parent: Instance, ctx: any)
	local self = setmetatable({}, Timeline)
	self.ctx = ctx
	self.store = ctx.store
	self.preview = ctx.preview
	self.rows = {}
	self.span = 2
	self.progress = 0
	self.connections = {}

	local root = Kit.frame(parent, {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Theme.color.bg1,
		ClipsDescendants = true,
	})
	self.root = root

	local header = Kit.frame(root, {
		Size = UDim2.new(1, 0, 0, 30),
		BackgroundTransparency = 1,
		ClipsDescendants = false,
	})
	local title = Kit.label(header, "Timeline", {
		Position = UDim2.fromOffset(12, 6),
		Size = UDim2.fromOffset(70, 18),
		Font = Theme.font.bold,
		TextSize = Theme.text.small,
	})

	local durationLabel = Kit.caption(header, "Duration", {
		Position = UDim2.fromOffset(86, 6),
		Size = UDim2.fromOffset(56, 18),
		TextSize = Theme.text.tiny,
	})

	local durationHolder = Kit.frame(header, {
		Size = UDim2.fromOffset(58, 22),
		Position = UDim2.fromOffset(142, 4),
		BackgroundTransparency = 1,
	})
	local durationWrapper, durationField = Kit.numberBox(durationHolder, self.store:working().duration, {
		min = 0.2,
		max = 30,
		size = UDim2.new(1, 0, 0, 22),
		onChange = function(value)
			self.store:setSpecField("duration", value, true)
		end,
	})
	self.durationField = durationField
	durationWrapper.Parent = durationHolder

	Kit.label(header, "s", {
		Position = UDim2.fromOffset(204, 6),
		Size = UDim2.fromOffset(10, 18),
		TextColor3 = Theme.color.textMuted,
		TextSize = Theme.text.tiny,
	})

	local fitButton = Kit.button(header, "Fit", {
		variant = "ghost",
		height = 20,
		size = UDim2.fromOffset(38, 20),
		textSize = Theme.text.tiny,
		tooltip = "Set the duration to the last component end",
		onClick = function()
			local longest = 0.5
			for _, comp in ipairs(self.store:working().components) do
				longest = math.max(longest, (tonumber(comp.startTime) or 0) + (tonumber(comp.duration) or 0))
			end
			self.store:setSpecField("duration", math.max(0.5, Util.round(longest, 2)), true)
			self.durationField.Set(math.max(0.5, Util.round(longest, 2)))
			self:refresh()
		end,
	})
	fitButton.Position = UDim2.fromOffset(218, 4)

	self.progressLabel = Kit.label(header, "0.00s", {
		Size = UDim2.fromOffset(60, 18),
		Position = UDim2.new(1, -74, 0, 6),
		TextColor3 = Theme.color.textMuted,
		Font = Theme.font.mono,
		TextSize = Theme.text.tiny,
		TextXAlignment = Enum.TextXAlignment.Right,
	})
	self.playheadLabel = self.progressLabel

	local divider = Kit.divider(root)
	divider.Position = UDim2.fromOffset(0, 30)

	-- Ruler -------------------------------------------------------------------
	local ruler = Kit.frame(root, {
		Size = UDim2.new(1, -NAME_WIDTH - 16, 0, 16),
		Position = UDim2.fromOffset(NAME_WIDTH + 8, 32),
		BackgroundTransparency = 1,
	})
	self.ruler = ruler

	-- Rows --------------------------------------------------------------------
	local scroll, content = Kit.scroll(root, {
		Size = UDim2.new(1, 0, 1, -84),
		Position = UDim2.fromOffset(0, 50),
	}, 2)
	scroll.ScrollBarThickness = 3
	self.scroll = scroll
	self.rowHolder = content

	local rowsFrame = Kit.frame(content, {
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.Y,
	})
	local rowsLayout = Instance.new("UIListLayout")
	rowsLayout.Padding = UDim.new(0, 1)
	rowsLayout.SortOrder = Enum.SortOrder.LayoutOrder
	rowsLayout.Parent = rowsFrame
	self.rowsFrame = rowsFrame

	-- Playhead spans the row area.
	local playhead = Kit.frame(root, {
		Size = UDim2.fromOffset(1, 0),
		Position = UDim2.fromOffset(NAME_WIDTH + 8, 50),
		BackgroundColor3 = Theme.color.accentBright,
		BackgroundTransparency = 0.15,
		ZIndex = 5,
	})
	playhead.Size = UDim2.new(0, 1, 1, -86)
	self.playhead = playhead

	local headDot = Kit.frame(playhead, {
		Size = UDim2.fromOffset(7, 7),
		Position = UDim2.new(0.5, -3, 0, -3),
		BackgroundColor3 = Theme.color.accentBright,
		ZIndex = 6,
	})
	Theme.corner(headDot, Theme.radius.pill)

	-- Empty state / add --------------------------------------------------------
	local footer = Kit.hlist(root, 6, {
		Size = UDim2.new(1, -20, 0, 26),
		Position = UDim2.new(0, 10, 1, -32),
	})
	footer.AutomaticSize = Enum.AutomaticSize.None
	footer.Size = UDim2.new(1, -20, 0, 26)

	self.addButton = Kit.button(footer, "+ Add component", {
		variant = "accentSoft",
		height = 24,
		size = UDim2.new(0, 132, 0, 24),
		textSize = Theme.text.small,
		onClick = function()
			self.store:addComponent("particle")
		end,
	})
	Kit.caption(footer, "Drag bars to retime  \u{00b7}  drag an edge to resize", {
		Size = UDim2.new(1, -140, 0, 24),
		TextSize = Theme.text.tiny,
	})

	self.rulerTicks = {}
	self:refresh()
	self:bind()
	return self
end

function Timeline:bind()
	table.insert(self.connections, self.store.signals:on("spec", function()
		self:refresh()
		if self.durationField then
			self.durationField.Set(self.store:working().duration)
		end
	end))
	table.insert(self.connections, self.store.signals:on("selection", function(index)
		self:highlight(index)
	end))
	table.insert(self.connections, self.store.signals:on("field", function(payload)
		-- Never rebuild the rows while the developer is dragging one of them.
		if self.dragging then
			return
		end
		if payload and (payload.key == "startTime" or payload.key == "duration") then
			self:refresh()
		end
	end))
end

function Timeline:computeSpan(): number
	local spec = self.store:working()
	local span = math.max(0.5, tonumber(spec.duration) or 1)
	for _, comp in ipairs(spec.components or {}) do
		span = math.max(span, (tonumber(comp.startTime) or 0) + (tonumber(comp.duration) or 0))
	end
	-- A little headroom so the last bar is not glued to the edge.
	return span * 1.04
end

function Timeline:refresh()
	Kit.clear(self.rowsFrame)
	self.rows = {}
	self.span = self:computeSpan()
	self:renderRuler()

	local spec = self.store:working()
	local index = 0
	for _, comp in ipairs(spec.components or {}) do
		index += 1
		self:createRow(comp, index)
	end

	self:highlight(self.store.selection)

	if #spec.components == 0 then
		local empty = Kit.label(self.rowsFrame, "No components. Add one below, or load a preset.", {
			Size = UDim2.new(1, -20, 0, 24),
			Position = UDim2.fromOffset(12, 4),
			TextColor3 = Theme.color.textMuted,
			TextSize = Theme.text.small,
		})
		empty.LayoutOrder = -1
	end
end

function Timeline:renderRuler()
	for _, tick in ipairs(self.rulerTicks) do
		tick:Destroy()
	end
	self.rulerTicks = {}

	local span = self.span
	local steps = 6
	for index = 0, steps do
		local fraction = index / steps
		local x = math.floor(fraction * 1000) / 10
		local label = Kit.label(self.ruler, string.format("%.2fs", span * fraction), {
			Size = UDim2.fromOffset(42, 14),
			Position = UDim2.new(fraction, -21, 0, 0),
			TextColor3 = Theme.color.textFaint,
			TextSize = Theme.text.tiny,
			Font = Theme.font.mono,
			TextXAlignment = Enum.TextXAlignment.Center,
		})
		table.insert(self.rulerTicks, label)
	end
end

function Timeline:createRow(comp: any, index: number)
	local row = Kit.frame(self.rowsFrame, {
		Size = UDim2.new(1, 0, 0, ROW_HEIGHT),
		BackgroundColor3 = if index % 2 == 0 then Theme.color.bg2 else Theme.color.bg1,
		BackgroundTransparency = if index % 2 == 0 then 0.35 else 1,
		ClipsDescendants = false,
	})
	row.LayoutOrder = index

	local color = KIND_COLORS[comp.kind] or Theme.color.textDim

	local dot = Kit.frame(row, {
		Size = UDim2.fromOffset(5, 5),
		Position = UDim2.fromOffset(10, 10),
		BackgroundColor3 = color,
	})
	Theme.corner(dot, Theme.radius.pill)

	local name = Kit.label(row, string.format("%s %s", KIND_GLYPHS[comp.kind] or "\u{25c6}", tostring(comp.name)), {
		Size = UDim2.fromOffset(NAME_WIDTH - 16, ROW_HEIGHT),
		Position = UDim2.fromOffset(20, 0),
		TextColor3 = Theme.color.textDim,
		TextSize = Theme.text.tiny,
		TextTruncate = Enum.TextTruncate.AtEnd,
	})
	Kit.tooltip(name, tostring(comp.name))

	local track = Kit.frame(row, {
		Size = UDim2.new(1, -NAME_WIDTH - 16, 0, ROW_HEIGHT),
		Position = UDim2.fromOffset(NAME_WIDTH, 0),
		BackgroundTransparency = 1,
	})

	local lane = Kit.frame(track, {
		Size = UDim2.new(1, 0, 0, 8),
		Position = UDim2.new(0, 0, 0.5, -4),
		BackgroundColor3 = Theme.color.bg3,
	})
	lane.ZIndex = 1
	Theme.corner(lane, Theme.radius.pill)

	local startTime = tonumber(comp.startTime) or 0
	local duration = tonumber(comp.duration) or 0
	local bar = Kit.frame(track, {
		Size = UDim2.fromScale(math.max(0.006, duration / self.span), 1),
		Position = UDim2.fromScale(startTime / self.span, 0),
		BackgroundColor3 = color,
		BackgroundTransparency = 0.25,
		ZIndex = 2,
	})
	Theme.corner(bar, Theme.radius.sm)
	bar.Size = UDim2.new(math.max(0.006, duration / self.span), 0, 0, 16)
	bar.Position = UDim2.new(startTime / self.span, 0, 0.5, -8)

	local barLabel = Kit.label(bar, if duration > 0.08 then string.format("%.2fs", duration) else "", {
		Size = UDim2.new(1, -8, 1, 0),
		Position = UDim2.fromOffset(4, 0),
		TextColor3 = Theme.color.white,
		TextSize = Theme.text.tiny,
		Font = Theme.font.mono,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
	})

	local leftHandle = Kit.frame(bar, {
		Size = UDim2.new(0, 4, 1, 0),
		BackgroundColor3 = Theme.color.white,
		BackgroundTransparency = 0.6,
		ZIndex = 3,
	})
	local rightHandle = Kit.frame(bar, {
		Size = UDim2.new(0, 4, 1, 0),
		Position = UDim2.new(1, -4, 0, 0),
		BackgroundColor3 = Theme.color.white,
		BackgroundTransparency = 0.6,
		ZIndex = 3,
	})

	local function trackWidth(): number
		return math.max(24, track.AbsoluteSize.X)
	end

	local dragState: any = nil

	local function beginDrag(mode: string, startX: number)
		self.store:pushHistory("Adjust timing")
		self.dragging = true
		dragState = {
			mode = mode,
			startX = startX,
			startTime = tonumber(comp.startTime) or 0,
			startDuration = tonumber(comp.duration) or 0,
		}
		self.store:select(index)
	end

	local function moveDrag(mouseX: number)
		if not dragState then
			return
		end
		local delta = (mouseX - dragState.startX) / trackWidth() * self.span
		if dragState.mode == "move" then
			local newStart = math.max(0, Util.round(dragState.startTime + delta, 2))
			comp.startTime = newStart
			self.store:setField(index, "startTime", newStart)
		elseif dragState.mode == "left" then
			local newStart = math.clamp(Util.round(dragState.startTime + delta, 2), 0, dragState.startTime + dragState.startDuration - 0.05)
			local newDuration = math.max(0.05, Util.round(dragState.startDuration - (newStart - dragState.startTime), 2))
			comp.startTime = newStart
			comp.duration = newDuration
			self.store:setField(index, "startTime", newStart)
			self.store:setField(index, "duration", newDuration)
		elseif dragState.mode == "right" then
			local newDuration = math.max(0.05, Util.round(dragState.startDuration + delta, 2))
			comp.duration = newDuration
			self.store:setField(index, "duration", newDuration)
		end
		self:updateBar(index, bar, barLabel)
	end

	local function finishDrag()
		dragState = nil
		self.dragging = false
		self:refresh()
	end

	Kit.drag(bar, {
		begin = function(x)
			beginDrag("move", x)
		end,
		move = function(x)
			moveDrag(x)
		end,
		finish = finishDrag,
	})
	Kit.drag(leftHandle, {
		begin = function(x)
			beginDrag("left", x)
		end,
		move = function(x)
			moveDrag(x)
		end,
		finish = finishDrag,
	})
	Kit.drag(rightHandle, {
		begin = function(x)
			beginDrag("right", x)
		end,
		move = function(x)
			moveDrag(x)
		end,
		finish = finishDrag,
	})

	local selectClick = Instance.new("TextButton")
	selectClick.BackgroundTransparency = 1
	selectClick.Text = ""
	selectClick.Size = UDim2.new(1, -NAME_WIDTH, 1, 0)
	selectClick.Position = UDim2.fromOffset(NAME_WIDTH, 0)
	selectClick.ZIndex = 1
	selectClick.Parent = row
	selectClick.Activated:Connect(function()
		self.store:select(index)
	end)

	self.rows[index] = {
		frame = row,
		bar = bar,
		label = barLabel,
		comp = comp,
	}
end

function Timeline:updateBar(index: number, bar: Frame, label: TextLabel)
	local comp = self.rows[index] and self.rows[index].comp
	if not comp then
		return
	end
	local startTime = tonumber(comp.startTime) or 0
	local duration = tonumber(comp.duration) or 0
	bar.Position = UDim2.new(startTime / self.span, 0, 0.5, -8)
	bar.Size = UDim2.new(math.max(0.006, duration / self.span), 0, 0, 16)
	label.Text = if duration > 0.08 then string.format("%.2fs", duration) else ""
end

function Timeline:highlight(index: number)
	for rowIndex, row in pairs(self.rows) do
		if rowIndex == index then
			row.frame.BackgroundColor3 = Theme.color.bg3
			row.frame.BackgroundTransparency = 0
		else
			row.frame.BackgroundColor3 = if rowIndex % 2 == 0 then Theme.color.bg2 else Theme.color.bg1
			row.frame.BackgroundTransparency = if rowIndex % 2 == 0 then 0.35 else 1
		end
	end
end

function Timeline:setProgress(fraction: number, seconds: number)
	self.progress = math.clamp(fraction, 0, 1)
	local rulerWidth = self.ruler.AbsoluteSize.X
	self.playhead.Position = UDim2.new(
		0,
		NAME_WIDTH + 8 + math.floor(self.progress * rulerWidth),
		0,
		50
	)
	if self.playheadLabel then
		self.playheadLabel.Text = string.format("%.2fs", seconds or 0)
	end
end

function Timeline:destroy()
	for _, connection in ipairs(self.connections) do
		pcall(function()
			connection:Disconnect()
		end)
	end
	self.root:Destroy()
end

return Timeline
