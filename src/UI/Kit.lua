--[[
	Kit - the widget toolkit every VFX Studio panel is built from.

	Everything here is real interactive UI: buttons with hover animation,
	sliders with drag handling, dropdowns that expand inline, toggles, tabs,
	number fields, tooltips, drag-and-drop, and scroll containers that behave
	inside Roblox Studio's dock widgets.
]]

local Util = require(script.Parent.Parent.Core.Util)
local Theme = require(script.Parent.Parent.Core.Theme)

local UserInputService = game:GetService("UserInputService")

local Kit = {}

Kit.Theme = Theme
Kit.new = Util.new

local overlay: Frame? = nil

--- All tooltips and floating menus render into this full-size overlay.
function Kit.setOverlay(root: Frame?)
	overlay = root
end

local function guard(connection: RBXScriptConnection, object: GuiObject): RBXScriptConnection
	return connection
end

function Kit.disconnectAll(list: { RBXScriptConnection })
	for _, connection in ipairs(list) do
		pcall(function()
			connection:Disconnect()
		end)
	end
end

--------------------------------------------------------------------------------
-- containers
--------------------------------------------------------------------------------

function Kit.frame(parent: Instance, props: { [string]: any }?): Frame
	local frame = Instance.new("Frame")
	frame.BackgroundColor3 = Theme.color.bg2
	frame.BorderSizePixel = 0
	frame.ClipsDescendants = true
	if props then
		for key, value in pairs(props) do
			(frame :: any)[key] = value
		end
	end
	frame.Parent = parent
	return frame
end

function Kit.transparent(parent: Instance, props: { [string]: any }?): Frame
	local frame = Kit.frame(parent, props)
	frame.BackgroundTransparency = 1
	frame.ClipsDescendants = false
	return frame
end

--- ScrollFrame with a vertical list layout and padding baked in.
function Kit.scroll(parent: Instance, props: { [string]: any }?, padding: number?): (ScrollingFrame, Frame)
	local scroll = Instance.new("ScrollingFrame")
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.ScrollBarThickness = 4
	scroll.ScrollBarImageColor3 = Theme.color.lineBright
	scroll.ScrollBarImageTransparency = 0.35
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.ScrollingDirection = Enum.ScrollingDirection.Y
	scroll.ScrollingEnabled = true
	scroll.ElasticBehavior = Enum.ElasticBehavior.Never
	if props then
		for key, value in pairs(props) do
			(scroll :: any)[key] = value
		end
	end
	scroll.Parent = parent

	local pad = padding or 10
	local list = Instance.new("UIListLayout")
	list.Padding = UDim.new(0, 6)
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.FillDirection = Enum.FillDirection.Vertical
	list.Parent = scroll

	local paddingObject = Instance.new("UIPadding")
	paddingObject.PaddingTop = UDim.new(0, pad)
	paddingObject.PaddingBottom = UDim.new(0, pad + 4)
	paddingObject.PaddingLeft = UDim.new(0, pad)
	paddingObject.PaddingRight = UDim.new(0, pad)
	paddingObject.Parent = scroll

	return scroll, scroll
end

function Kit.hlist(parent: Instance, gap: number?, props: { [string]: any }?): Frame
	local frame = Kit.transparent(parent, props)
	frame.Size = UDim2.new(1, 0, 0, 0)
	frame.AutomaticSize = Enum.AutomaticSize.XY
	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.Padding = UDim.new(0, gap or 6)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.Parent = frame
	return frame
end

function Kit.vlist(parent: Instance, gap: number?, props: { [string]: any }?): Frame
	local frame = Kit.transparent(parent, props)
	frame.Size = UDim2.new(1, 0, 0, 0)
	frame.AutomaticSize = Enum.AutomaticSize.Y
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, gap or 6)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = frame
	return frame
end

function Kit.divider(parent: Instance, opacity: number?): Frame
	local frame = Kit.frame(parent, {
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = Theme.color.line,
		BackgroundTransparency = opacity or 0.35,
	})
	return frame
end

--------------------------------------------------------------------------------
-- text
--------------------------------------------------------------------------------

function Kit.label(parent: Instance, text: string, props: { [string]: any }?): TextLabel
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Theme.color.text
	label.Font = Theme.font.body
	label.TextSize = Theme.text.body
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.Size = UDim2.new(1, 0, 0, 16)
	label.TextTruncate = Enum.TextTruncate.AtEnd
	label.RichText = false
	if props then
		for key, value in pairs(props) do
			(label :: any)[key] = value
		end
	end
	label.Parent = parent
	return label
end

function Kit.caption(parent: Instance, text: string, props: { [string]: any }?): TextLabel
	local label = Kit.label(parent, text, {
		TextColor3 = Theme.color.textDim,
		TextSize = Theme.text.small,
		Font = Theme.font.body,
	})
	if props then
		for key, value in pairs(props) do
			(label :: any)[key] = value
		end
	end
	return label
end

function Kit.sectionTitle(parent: Instance, text: string, accessory: GuiObject?): Frame
	local row = Kit.hlist(parent, 8)
	row.Size = UDim2.new(1, 0, 0, 20)
	local label = Kit.label(row, string.upper(text), {
		TextColor3 = Theme.color.textMuted,
		TextSize = Theme.text.tiny,
		Font = Theme.font.bold,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.new(0, 0, 1, 0),
	})
	label.LayoutOrder = 1
	if accessory then
		accessory.LayoutOrder = 2
		accessory.Parent = row
	end
	return row
end

--------------------------------------------------------------------------------
-- hover helpers
--------------------------------------------------------------------------------

function Kit.hoverFX(object: GuiObject, normal: Color3, hover: Color3, duration: number?)
	local active = Util.tween
	object.MouseEnter:Connect(function()
		if object.BackgroundColor3 == normal then
			active(object, { BackgroundColor3 = hover }, duration or 0.12)
		end
	end)
	object.MouseLeave:Connect(function()
		if object.BackgroundColor3 == hover then
			active(object, { BackgroundColor3 = normal }, duration or 0.12)
		end
	end)
end

function Kit.tooltip(object: GuiObject, text: string)
	if not text or text == "" then
		return
	end
	local tip: TextLabel? = nil
	object.MouseEnter:Connect(function()
		if not overlay or tip then
			return
		end
		local label = Instance.new("TextLabel")
		label.BackgroundColor3 = Theme.color.bg0
		label.BackgroundTransparency = 0.05
		label.BorderSizePixel = 0
		label.Text = text
		label.TextColor3 = Theme.color.text
		label.Font = Theme.font.body
		label.TextSize = Theme.text.small
		label.TextWrapped = true
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.AutomaticSize = Enum.AutomaticSize.XY
		label.Size = UDim2.fromOffset(0, 0)
		label.ZIndex = 200
		Theme.corner(label, Theme.radius.sm)
		Theme.stroke(label, Theme.color.lineBright, 1, 0.2)
		local paddingObject = Instance.new("UIPadding")
		paddingObject.PaddingTop = UDim.new(0, 5)
		paddingObject.PaddingBottom = UDim.new(0, 5)
		paddingObject.PaddingLeft = UDim.new(0, 7)
		paddingObject.PaddingRight = UDim.new(0, 7)
		paddingObject.Parent = label
		local constraint = Instance.new("UISizeConstraint")
		constraint.MaxSize = Vector2.new(260, 200)
		constraint.Parent = label
		label.Parent = overlay
		tip = label

		local mouse = UserInputService:GetMouseLocation()
		local rootPosition = overlay.AbsolutePosition
		label.Position = UDim2.fromOffset(mouse.X - rootPosition.X + 14, mouse.Y - rootPosition.Y + 20)
	end)
	object.MouseLeave:Connect(function()
		if tip then
			tip:Destroy()
			tip = nil
		end
	end)
end

--------------------------------------------------------------------------------
-- buttons
--------------------------------------------------------------------------------

export type ButtonOptions = {
	variant: string?,
	width: number?,
	height: number?,
	icon: string?,
	tooltip: string?,
	onClick: (() -> ())?,
	size: UDim2?,
	font: Enum.Font?,
	textSize: number?,
}

function Kit.button(parent: Instance, text: string, options: ButtonOptions?): TextButton
	local opts = options or {}
	local variant = opts.variant or "secondary"
	local height = opts.height or 28

	local button = Instance.new("TextButton")
	button.AutoButtonColor = false
	button.BorderSizePixel = 0
	button.Font = opts.font or Theme.font.medium
	button.TextSize = opts.textSize or Theme.text.body
	button.TextColor3 = Theme.color.text
	button.Text = text
	button.Size = opts.size or UDim2.new(opts.width and 0 or 1, opts.width or 0, 0, height)
	button.BackgroundColor3 = Theme.color.bg3
	button.ClipsDescendants = true

	if variant == "primary" then
		button.BackgroundColor3 = Theme.color.accent
		button.TextColor3 = Theme.color.white
		button.Font = Theme.font.bold
	elseif variant == "ghost" then
		button.BackgroundTransparency = 1
		button.TextColor3 = Theme.color.textDim
	elseif variant == "danger" then
		button.BackgroundColor3 = Theme.color.badSoft
		button.TextColor3 = Theme.color.bad
	elseif variant == "accentSoft" then
		button.BackgroundColor3 = Theme.color.accentSoft
		button.TextColor3 = Theme.color.accentBright
	end

	Theme.corner(button, Theme.radius.sm)
	button.Parent = parent

	local normalColor = button.BackgroundColor3
	local hoverColor = if variant == "primary"
		then Theme.color.accentBright
		elseif variant == "ghost"
		then Theme.color.bg3
		elseif variant == "danger"
		then Theme.color.bad
		else Theme.color.bg4

	button.MouseEnter:Connect(function()
		if variant == "ghost" then
			button.BackgroundTransparency = 0
		end
		Util.tween(button, { BackgroundColor3 = hoverColor }, 0.1)
	end)
	button.MouseLeave:Connect(function()
		Util.tween(button, { BackgroundColor3 = normalColor }, 0.12)
		if variant == "ghost" then
			Util.tween(button, { BackgroundTransparency = 1 }, 0.12)
		end
	end)

	if opts.onClick then
		button.Activated:Connect(function()
			local ok, err = pcall(opts.onClick :: () -> ())
			if not ok then
				warn("[VFX Studio] button error: " .. tostring(err))
			end
		end)
	end
	if opts.tooltip then
		Kit.tooltip(button, opts.tooltip)
	end
	return button
end

function Kit.iconButton(parent: Instance, glyph: string, options: ButtonOptions?): TextButton
	local opts = options or {}
	local button = Kit.button(parent, glyph, {
		variant = opts.variant or "ghost",
		size = opts.size or UDim2.fromOffset(opts.width or 26, opts.height or 26),
		onClick = opts.onClick,
		tooltip = opts.tooltip,
		font = Theme.font.bold,
		textSize = opts.textSize or 14,
	})
	button.TextColor3 = if opts.variant == "primary" then Theme.color.white else Theme.color.textDim
	return button
end

--------------------------------------------------------------------------------
-- inputs
--------------------------------------------------------------------------------

function Kit.searchBox(parent: Instance, placeholder: string, onChange: (string) -> (), width: UDim2?): TextBox
	local container = Kit.frame(parent, {
		Size = width or UDim2.new(1, 0, 0, 30),
		BackgroundColor3 = Theme.color.bg1,
	})
	Theme.corner(container, Theme.radius.sm)
	Theme.stroke(container, Theme.color.line, 1, 0.3)

	local icon = Kit.label(container, "\u{2315}", {
		Size = UDim2.fromOffset(26, 30),
		Position = UDim2.fromOffset(6, 0),
		TextColor3 = Theme.color.textMuted,
		TextSize = 15,
		TextXAlignment = Enum.TextXAlignment.Center,
	})

	local box = Instance.new("TextBox")
	box.BackgroundTransparency = 1
	box.Size = UDim2.new(1, -34, 1, 0)
	box.Position = UDim2.fromOffset(30, 0)
	box.ClearTextOnFocus = false
	box.PlaceholderText = placeholder
	box.PlaceholderColor3 = Theme.color.textMuted
	box.TextColor3 = Theme.color.text
	box.Font = Theme.font.body
	box.TextSize = Theme.text.body
	box.TextXAlignment = Enum.TextXAlignment.Left
	box.Text = ""
	box.Parent = container

	box:GetPropertyChangedSignal("Text"):Connect(function()
		local ok, err = pcall(onChange, box.Text)
		if not ok then
			warn("[VFX Studio] search error: " .. tostring(err))
		end
	end)
	box.Focused:Connect(function()
		Theme.stroke(container, Theme.color.accent, 1, 0)
	end)
	box.FocusLost:Connect(function()
		Theme.stroke(container, Theme.color.line, 1, 0.3)
	end)
	return box
end

function Kit.textBox(parent: Instance, value: string, options: any?): TextBox
	local opts = options or {}
	local box = Instance.new("TextBox")
	box.BackgroundColor3 = Theme.color.bg1
	box.BorderSizePixel = 0
	box.Size = opts.size or UDim2.new(1, 0, 0, opts.height or 26)
	box.ClearTextOnFocus = false
	box.Text = value or ""
	box.PlaceholderText = opts.placeholder or ""
	box.PlaceholderColor3 = Theme.color.textMuted
	box.TextColor3 = Theme.color.text
	box.Font = opts.font or Theme.font.body
	box.TextSize = opts.textSize or Theme.text.body
	box.TextXAlignment = opts.align or Enum.TextXAlignment.Left
	box.TextTruncate = Enum.TextTruncate.AtEnd
	box.Parent = parent
	Theme.corner(box, Theme.radius.xs)

	local paddingObject = Instance.new("UIPadding")
	paddingObject.PaddingLeft = UDim.new(0, 8)
	paddingObject.PaddingRight = UDim.new(0, 8)
	paddingObject.Parent = box

	if opts.onSubmit then
		box.FocusLost:Connect(function(enterPressed)
			if enterPressed then
				local ok, err = pcall(opts.onSubmit, box.Text)
				if not ok then
					warn("[VFX Studio] input error: " .. tostring(err))
				end
			end
		end)
	end
	return box
end

--- Numeric field with commit-on-enter and optional drag-free steppers.
function Kit.numberBox(parent: Instance, value: number, options: any?): (Frame, any)
	local opts = options or {}
	local wrapper = Kit.frame(parent, {
		Size = opts.size or UDim2.fromOffset(64, 26),
		BackgroundColor3 = Theme.color.bg1,
	})
	Theme.corner(wrapper, Theme.radius.xs)
	Theme.stroke(wrapper, Theme.color.line, 1, 0.45)

	local box = Instance.new("TextBox")
	box.BackgroundTransparency = 1
	box.Size = UDim2.new(1, -8, 1, 0)
	box.Position = UDim2.fromOffset(4, 0)
	box.ClearTextOnFocus = false
	box.Text = tostring(Util.round(value, 3))
	box.TextColor3 = Theme.color.text
	box.Font = Theme.font.mono
	box.TextSize = Theme.text.small
	box.TextXAlignment = if opts.align == "right" then Enum.TextXAlignment.Right else Enum.TextXAlignment.Center
	box.Parent = wrapper

	local api = { value = value }

	local function commit(text: string)
		local parsed = tonumber(text)
		if parsed == nil then
			box.Text = tostring(Util.round(api.value, 3))
			return
		end
		if opts.min then
			parsed = math.max(opts.min, parsed)
		end
		if opts.max then
			parsed = math.min(opts.max, parsed)
		end
		api.value = parsed
		box.Text = tostring(Util.round(parsed, 3))
		if opts.onChange then
			local ok, err = pcall(opts.onChange, parsed)
			if not ok then
				warn("[VFX Studio] number field error: " .. tostring(err))
			end
		end
	end

	box.FocusLost:Connect(function(enterPressed)
		commit(box.Text)
	end)

	function api.Set(newValue: number)
		api.value = newValue
		box.Text = tostring(Util.round(newValue, 3))
	end

	function api.Get(): number
		return api.value
	end

	return wrapper, api
end

export type SliderOptions = {
	min: number?,
	max: number?,
	step: number?,
	value: number?,
	onChange: ((number) -> ())?,
	onStart: (() -> ())?,
	onFinish: (() -> ())?,
	height: number?,
	showValue: boolean?,
	format: ((number) -> string)?,
}

function Kit.slider(parent: Instance, options: SliderOptions): any
	local opts = options
	local min = opts.min or 0
	local max = opts.max or 1
	if max <= min then
		max = min + 1
	end
	local step = opts.step or 0
	local value = math.clamp(opts.value or min, min, max)

	local container = Kit.frame(parent, {
		Size = UDim2.new(1, 0, 0, opts.height or 22),
		BackgroundTransparency = 1,
		ClipsDescendants = false,
	})

	local track = Kit.frame(container, {
		Size = UDim2.new(1, -46, 0, 5),
		Position = UDim2.new(0, 0, 0.5, -2),
		BackgroundColor3 = Theme.color.bg4,
	})
	Theme.corner(track, Theme.radius.pill)

	local fill = Kit.frame(track, {
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = Theme.color.accent,
	})
	Theme.corner(fill, Theme.radius.pill)

	local knob = Kit.frame(container, {
		Size = UDim2.fromOffset(11, 11),
		Position = UDim2.new(0, 0, 0.5, -5),
		BackgroundColor3 = Theme.color.white,
	})
	Theme.corner(knob, Theme.radius.pill)

	local valueLabel = Kit.label(container, "", {
		Size = UDim2.new(0, 42, 1, 0),
		Position = UDim2.new(1, -42, 0, 0),
		TextColor3 = Theme.color.textDim,
		Font = Theme.font.mono,
		TextSize = Theme.text.small,
		TextXAlignment = Enum.TextXAlignment.Right,
	})

	local api = { value = value }
	local dragging = false

	local function format(v: number): string
		if opts.format then
			return opts.format(v)
		end
		return Util.pretty(v)
	end

	local function applyVisual(newValue: number)
		local alpha = (newValue - min) / (max - min)
		fill.Size = UDim2.fromScale(alpha, 1)
		knob.Position = UDim2.new(alpha, -5, 0.5, -5)
		valueLabel.Text = format(newValue)
	end

	local function quantize(raw: number): number
		local clamped = math.clamp(raw, min, max)
		if step > 0 then
			clamped = min + math.floor((clamped - min) / step + 0.5) * step
		end
		return math.clamp(clamped, min, max)
	end

	local function setFromInput(inputX: number)
		local absolute = track.AbsolutePosition.X
		local width = math.max(1, track.AbsoluteSize.X)
		local alpha = math.clamp((inputX - absolute) / width, 0, 1)
		local newValue = quantize(min + alpha * (max - min))
		if newValue == api.value then
			return
		end
		api.value = newValue
		applyVisual(newValue)
		if opts.onChange then
			local ok, err = pcall(opts.onChange, newValue)
			if not ok then
				warn("[VFX Studio] slider error: " .. tostring(err))
			end
		end
	end

	local hitArea = Kit.frame(container, {
		Size = UDim2.new(1, -46, 1, 0),
		BackgroundTransparency = 1,
	})
	hitArea.ZIndex = 3

	hitArea.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			if opts.onStart then
				opts.onStart()
			end
			setFromInput(input.Position.X)
		end
	end)

	local moveConnection: RBXScriptConnection
	moveConnection = UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			setFromInput(input.Position.X)
		end
	end)
	local endConnection: RBXScriptConnection
	endConnection = UserInputService.InputEnded:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
			if opts.onFinish then
				opts.onFinish()
			end
		end
	end)

	container.AncestryChanged:Connect(function()
		if not container.Parent then
			moveConnection:Disconnect()
			endConnection:Disconnect()
		end
	end)

	function api.Set(newValue: number)
		api.value = quantize(newValue)
		applyVisual(api.value)
	end

	function api.Get(): number
		return api.value
	end

	applyVisual(value)
	return api
end

--------------------------------------------------------------------------------
-- dropdown
--------------------------------------------------------------------------------

export type DropdownOptions = {
	options: { any },
	value: any?,
	onChange: ((any) -> ())?,
	placeholder: string?,
	height: number?,
	maxHeight: number?,
}

--- Inline-expanding dropdown (no clipping issues inside scroll frames).
function Kit.dropdown(parent: Instance, options: DropdownOptions): any
	local opts = options
	local choices = opts.options or {}
	local current = opts.value

	local container = Kit.vlist(parent, 2)
	container.Size = UDim2.new(1, 0, 0, 0)

	local button = Kit.button(container, "", {
		variant = "secondary",
		height = opts.height or 26,
		size = UDim2.new(1, 0, 0, opts.height or 26),
	})
	button.TextXAlignment = Enum.TextXAlignment.Left
	button.Text = ""

	local paddingObject = Instance.new("UIPadding")
	paddingObject.PaddingLeft = UDim.new(0, 9)
	paddingObject.Parent = button

	local caret = Kit.label(button, "\u{25be}", {
		Size = UDim2.new(0, 18, 1, 0),
		Position = UDim2.new(1, -20, 0, 0),
		TextColor3 = Theme.color.textMuted,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextSize = 12,
	})

	local list = Kit.frame(container, {
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundColor3 = Theme.color.bg1,
		Visible = false,
	})
	Theme.corner(list, Theme.radius.sm)
	Theme.stroke(list, Theme.color.line, 1, 0.25)

	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 1)
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Parent = list

	local listPadding = Instance.new("UIPadding")
	listPadding.PaddingTop = UDim.new(0, 4)
	listPadding.PaddingBottom = UDim.new(0, 4)
	listPadding.PaddingLeft = UDim.new(0, 4)
	listPadding.PaddingRight = UDim.new(0, 4)
	listPadding.Parent = list

	local scroller = Instance.new("ScrollingFrame")
	scroller.BackgroundTransparency = 1
	scroller.BorderSizePixel = 0
	scroller.ScrollBarThickness = 3
	scroller.Size = UDim2.new(1, 0, 1, 0)
	scroller.CanvasSize = UDim2.new(0, 0, 0, 0)
	scroller.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroller.ScrollingDirection = Enum.ScrollingDirection.Y
	scroller.Parent = list

	local scrollerLayout = Instance.new("UIListLayout")
	scrollerLayout.Padding = UDim.new(0, 1)
	scrollerLayout.Parent = scroller

	local api = { value = current, open = false }

	local function labelFor(value: any): string
		for _, choice in ipairs(choices) do
			if choice.value == value then
				return choice.label or tostring(choice.value)
			end
		end
		return opts.placeholder or "Select..."
	end

	local function render()
		for _, child in ipairs(scroller:GetChildren()) do
			if child:IsA("TextButton") then
				child:Destroy()
			end
		end
		local count = 0
		for _, choice in ipairs(choices) do
			count += 1
			local selected = choice.value == api.value
			local option = Kit.button(scroller, choice.label or tostring(choice.value), {
				variant = if selected then "accentSoft" else "ghost",
				height = 24,
				size = UDim2.new(1, -4, 0, 24),
				textSize = Theme.text.small,
				onClick = function()
					api.value = choice.value
					button.Text = labelFor(api.value)
					api.open = false
					list.Visible = false
					if opts.onChange then
						opts.onChange(choice.value)
					end
					render()
				end,
			})
			option.TextXAlignment = Enum.TextXAlignment.Left
			option.LayoutOrder = count
			local pad = Instance.new("UIPadding")
			pad.PaddingLeft = UDim.new(0, 8)
			pad.Parent = option
		end
		list.Size = UDim2.new(1, 0, 0, math.min(opts.maxHeight or 160, 32 + count * 25))
		list.Visible = api.open
		scroller.CanvasSize = UDim2.new(0, 0, 0, count * 25)
	end

	button.Text = labelFor(api.value)
	button.Activated:Connect(function()
		api.open = not api.open
		list.Visible = api.open
		if api.open then
			render()
		end
	end)

	function api.Set(value: any)
		api.value = value
		button.Text = labelFor(value)
		if api.open then
			render()
		end
	end

	function api.Get(): any
		return api.value
	end

	render()
	list.Visible = false
	return api
end

--------------------------------------------------------------------------------
-- toggle
--------------------------------------------------------------------------------

function Kit.toggle(parent: Instance, value: boolean, onChange: ((boolean) -> ())?): any
	local track = Kit.frame(parent, {
		Size = UDim2.fromOffset(34, 18),
		BackgroundColor3 = if value then Theme.color.accent else Theme.color.bg4,
	})
	Theme.corner(track, Theme.radius.pill)

	local knob = Kit.frame(track, {
		Size = UDim2.fromOffset(14, 14),
		Position = if value then UDim2.new(1, -16, 0.5, -7) else UDim2.fromOffset(2, 2),
		BackgroundColor3 = Theme.color.white,
	})
	Theme.corner(knob, Theme.radius.pill)

	local button = Kit.frame(track, {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
	})
	button.ZIndex = 2

	local api = { value = value }
	local click = Instance.new("TextButton")
	click.BackgroundTransparency = 1
	click.Text = ""
	click.Size = UDim2.fromScale(1, 1)
	click.ZIndex = 3
	click.Parent = track

	local function apply(newValue: boolean)
		api.value = newValue
		Util.tween(track, { BackgroundColor3 = if newValue then Theme.color.accent else Theme.color.bg4 }, 0.12)
		knob.Position = if newValue then UDim2.new(1, -16, 0.5, -7) else UDim2.fromOffset(2, 2)
	end

	click.Activated:Connect(function()
		apply(not api.value)
		if onChange then
			onChange(api.value)
		end
	end)

	function api.Set(newValue: boolean)
		apply(newValue)
	end

	function api.Get(): boolean
		return api.value
	end

	return api
end

--------------------------------------------------------------------------------
-- labelled row helper
--------------------------------------------------------------------------------

--- Row with a label on the left and an arbitrary control on the right.
function Kit.row(parent: Instance, labelText: string, tooltipText: string?, height: number?): Frame
	local row = Kit.frame(parent, {
		Size = UDim2.new(1, 0, 0, height or 26),
		BackgroundTransparency = 1,
		ClipsDescendants = false,
	})
	local label = Kit.label(row, labelText, {
		Size = UDim2.new(0.52, -6, 1, 0),
		TextColor3 = Theme.color.textDim,
		TextSize = Theme.text.small,
	})
	if tooltipText then
		Kit.tooltip(label, tooltipText)
	end
	local holder = Kit.frame(row, {
		Size = UDim2.new(0.48, -6, 1, 0),
		Position = UDim2.new(0.52, 6, 0, 0),
		BackgroundTransparency = 1,
		ClipsDescendants = false,
	})
	return row, holder
end

function Kit.badge(parent: Instance, text: string, color: Color3?): Frame
	local bg = color or Theme.color.bg4
	local pill = Kit.frame(parent, {
		Size = UDim2.fromOffset(0, 18),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundColor3 = bg,
		BackgroundTransparency = 0.55,
		ClipsDescendants = false,
	})
	Theme.corner(pill, Theme.radius.pill)
	local pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0, 7)
	pad.PaddingRight = UDim.new(0, 7)
	pad.Parent = pill
	local label = Kit.label(pill, text, {
		Size = UDim2.new(0, 0, 1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		TextColor3 = Theme.color.text,
		TextSize = Theme.text.tiny,
		Font = Theme.font.bold,
		TextXAlignment = Enum.TextXAlignment.Center,
	})
	return pill
end

--------------------------------------------------------------------------------
-- drag helper
--------------------------------------------------------------------------------

export type DragCallbacks = {
	begin: ((number, number) -> ())?,
	move: ((number, number) -> ())?,
	finish: ((number, number) -> ())?,
}

--- Mouse drag tracking for a GuiObject. Coordinates are absolute screen pixels.
function Kit.drag(object: GuiObject, callbacks: DragCallbacks)
	local dragging = false
	local startX, startY = 0, 0

	local beginConnection = object.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
			return
		end
		dragging = true
		startX = input.Position.X
		startY = input.Position.Y
		if callbacks.begin then
			callbacks.begin(startX, startY)
		end
	end)

	local moveConnection = UserInputService.InputChanged:Connect(function(input)
		if not dragging or input.UserInputType ~= Enum.UserInputType.MouseMovement then
			return
		end
		if callbacks.move then
			callbacks.move(input.Position.X, input.Position.Y)
		end
	end)

	local endConnection = UserInputService.InputEnded:Connect(function(input)
		if not dragging or input.UserInputType ~= Enum.UserInputType.MouseButton1 then
			return
		end
		dragging = false
		if callbacks.finish then
			callbacks.finish(input.Position.X, input.Position.Y)
		end
	end)

	object.AncestryChanged:Connect(function()
		if not object.Parent then
			beginConnection:Disconnect()
			moveConnection:Disconnect()
			endConnection:Disconnect()
		end
	end)
end

--- Converts a mouse X coordinate into 0..1 along a GuiObject.
function Kit.fractionAlong(object: GuiObject, mouseX: number): number
	local width = math.max(1, object.AbsoluteSize.X)
	return math.clamp((mouseX - object.AbsolutePosition.X) / width, 0, 1)
end

--------------------------------------------------------------------------------
-- misc
--------------------------------------------------------------------------------

function Kit.progressBar(parent: Instance, height: number?): any
	local track = Kit.frame(parent, {
		Size = UDim2.new(1, 0, 0, height or 6),
		BackgroundColor3 = Theme.color.bg4,
	})
	Theme.corner(track, Theme.radius.pill)
	local fill = Kit.frame(track, {
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = Theme.color.accent,
	})
	Theme.corner(fill, Theme.radius.pill)
	local api = { track = track, fill = fill }
	function api.Set(fraction: number, color: Color3?)
		fill.Size = UDim2.fromScale(math.clamp(fraction, 0, 1), 1)
		if color then
			fill.BackgroundColor3 = color
		end
	end
	return api
end

function Kit.chip(parent: Instance, text: string, onClick: (() -> ())?, active: boolean?): TextButton
	local button = Kit.button(parent, text, {
		variant = if active then "accentSoft" else "secondary",
		height = 22,
		width = 0,
		size = UDim2.fromOffset(0, 22),
		textSize = Theme.text.tiny,
		onClick = onClick,
	})
	button.AutomaticSize = Enum.AutomaticSize.X
	local pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0, 9)
	pad.PaddingRight = UDim.new(0, 9)
	pad.Parent = button
	return button
end

function Kit.clear(container: Instance)
	for _, child in ipairs(container:GetChildren()) do
		if not child:IsA("UIListLayout") and not child:IsA("UIPadding") and not child:IsA("UIGridLayout") and not child:IsA("UIGradient") then
			child:Destroy()
		end
	end
end

function Kit.applyListPadding(scroll: ScrollingFrame, amount: number)
	local existing = scroll:FindFirstChildOfClass("UIPadding")
	if existing then
		existing.PaddingTop = UDim.new(0, amount)
		existing.PaddingBottom = UDim.new(0, amount + 4)
		existing.PaddingLeft = UDim.new(0, amount)
		existing.PaddingRight = UDim.new(0, amount)
	end
end

function Kit.colorSwatch(parent: Instance, color: Color3, size: UDim2?): Frame
	local swatch = Kit.frame(parent, {
		Size = size or UDim2.fromOffset(18, 18),
		BackgroundColor3 = color,
	})
	Theme.corner(swatch, Theme.radius.xs)
	Theme.stroke(swatch, Theme.color.black, 1, 0.7)
	return swatch
end

--- Small key/value stat line used by the cost panel and export dialog.
function Kit.statRow(parent: Instance, labelText: string, valueText: string, color: Color3?): Frame
	local row = Kit.frame(parent, {
		Size = UDim2.new(1, 0, 0, 20),
		BackgroundTransparency = 1,
		ClipsDescendants = false,
	})
	Kit.caption(row, labelText, { Size = UDim2.new(0.6, 0, 1, 0) })
	Kit.label(row, valueText, {
		Size = UDim2.new(0.4, 0, 1, 0),
		Position = UDim2.new(0.6, 0, 0, 0),
		TextColor3 = color or Theme.color.text,
		Font = Theme.font.mono,
		TextSize = Theme.text.small,
		TextXAlignment = Enum.TextXAlignment.Right,
	})
	return row
end

return Kit
