--[[
	Theme - the single source of truth for VFX Studio's visual language.
	Deep charcoal surfaces, layered blues, one accent colour, generous
	spacing. Everything in the UI reads from here so restyling is one edit.
]]

local Util = require(script.Parent.Util)

local Theme = {}

Theme.color = {
	bg0 = Color3.fromRGB(9, 11, 16),
	bg1 = Color3.fromRGB(13, 16, 23),
	bg2 = Color3.fromRGB(18, 22, 32),
	bg3 = Color3.fromRGB(24, 29, 41),
	bg4 = Color3.fromRGB(33, 40, 55),
	bg5 = Color3.fromRGB(44, 53, 71),

	line = Color3.fromRGB(38, 47, 63),
	lineSoft = Color3.fromRGB(27, 34, 46),
	lineBright = Color3.fromRGB(58, 71, 94),

	text = Color3.fromRGB(233, 238, 247),
	textDim = Color3.fromRGB(154, 166, 188),
	textMuted = Color3.fromRGB(108, 120, 141),
	textFaint = Color3.fromRGB(79, 89, 107),

	accent = Color3.fromRGB(58, 128, 246),
	accentBright = Color3.fromRGB(104, 169, 255),
	accentDeep = Color3.fromRGB(31, 88, 205),
	accentSoft = Color3.fromRGB(32, 55, 96),

	good = Color3.fromRGB(52, 211, 153),
	goodSoft = Color3.fromRGB(20, 63, 50),
	warn = Color3.fromRGB(250, 190, 68),
	warnSoft = Color3.fromRGB(66, 51, 20),
	bad = Color3.fromRGB(248, 113, 113),
	badSoft = Color3.fromRGB(68, 30, 33),

	white = Color3.new(1, 1, 1),
	black = Color3.new(0, 0, 0),
	shadow = Color3.fromRGB(3, 5, 9),
}

Theme.font = {
	display = Enum.Font.GothamBlack,
	title = Enum.Font.GothamBold,
	bold = Enum.Font.GothamBold,
	medium = Enum.Font.GothamMedium,
	body = Enum.Font.Gotham,
	mono = Enum.Font.Code,
}

Theme.radius = {
	xs = UDim.new(0, 3),
	sm = UDim.new(0, 5),
	md = UDim.new(0, 7),
	lg = UDim.new(0, 10),
	xl = UDim.new(0, 14),
	pill = UDim.new(1, 0),
}

Theme.space = {
	xxs = 2,
	xs = 4,
	sm = 6,
	md = 9,
	lg = 13,
	xl = 18,
	xxl = 26,
}

Theme.text = {
	hero = 21,
	title = 15,
	subtitle = 13,
	body = 12,
	small = 11,
	tiny = 10,
}

function Theme.corner(inst: Instance, radius: UDim?): UICorner
	local corner = Instance.new("UICorner")
	corner.CornerRadius = radius or Theme.radius.md
	corner.Parent = inst
	return corner
end

function Theme.stroke(inst: Instance, color: Color3?, thickness: number?, transparency: number?): UIStroke
	local stroke = Instance.new("UIStroke")
	stroke.Color = color or Theme.color.line
	stroke.Thickness = thickness or 1
	stroke.Transparency = transparency or 0
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = inst
	return stroke
end

function Theme.padding(inst: Instance, top: number, right: number?, bottom: number?, left: number?): UIPadding
	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, top)
	padding.PaddingRight = UDim.new(0, right or top)
	padding.PaddingBottom = UDim.new(0, bottom or top)
	padding.PaddingLeft = UDim.new(0, left or right or top)
	padding.Parent = inst
	return padding
end

function Theme.linearGradient(inst: Instance, from: Color3, to: Color3, rotation: number?): UIGradient
	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new(from, to)
	gradient.Rotation = rotation or 90
	gradient.Parent = inst
	return gradient
end

function Theme.mix(a: Color3, b: Color3, alpha: number): Color3
	return a:Lerp(b, math.clamp(alpha, 0, 1))
end

--- Scales a colour towards black (positive) or white (negative).
function Theme.shade(color: Color3, amount: number): Color3
	if amount >= 0 then
		return color:Lerp(Theme.color.black, math.clamp(amount, 0, 1))
	end
	return color:Lerp(Theme.color.white, math.clamp(-amount, 0, 1))
end

function Theme.surface(parent: Instance, props: { [string]: any }?): Frame
	local frame = Instance.new("Frame")
	frame.BackgroundColor3 = Theme.color.bg2
	frame.BorderSizePixel = 0
	if props then
		for key, value in pairs(props) do
			(frame :: any)[key] = value
		end
	end
	frame.Parent = parent
	return frame
end

function Theme.label(parent: Instance, text: string, props: { [string]: any }?): TextLabel
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Theme.color.text
	label.Font = Theme.font.body
	label.TextSize = Theme.text.body
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.RichText = false
	if props then
		for key, value in pairs(props) do
			(label :: any)[key] = value
		end
	end
	label.Parent = parent
	return label
end

--- Palette used for the generated thumbnail art of a preset.
function Theme.paletteFromKeypoints(colorKeypoints: { any }?): (Color3, Color3)
	if not colorKeypoints or #colorKeypoints == 0 then
		return Theme.color.accent, Theme.color.accentDeep
	end
	local function at(index: number): Color3
		local kp = colorKeypoints[math.clamp(index, 1, #colorKeypoints)]
		if type(kp) == "table" then
			local value = kp[2] or kp.value or kp[1]
			if type(value) == "string" then
				return Util.hex(value)
			end
		elseif type(kp) == "string" then
			return Util.hex(kp)
		end
		return Theme.color.accent
	end
	return at(1), at(#colorKeypoints)
end

return Theme
