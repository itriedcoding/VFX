--[[
	DSL - the authoring layer used by the preset library.

	Presets are written as compact component builders (`P{ ... }`) and this
	module expands them into the canonical, fully-populated spec format the
	editor and compiler understand. Every field is always present, which is
	what lets the properties panel render any component generically.

	Stored values stay JSON-safe: colours are "#rrggbb" strings, sequences are
	`{ {time, value}, ... }` arrays, ranges are `{min, max}`.
]]

local Assets = require(script.Parent.Parent.Core.Assets)

local DSL = {}

local function clamp01(value: number): number
	if value ~= value then
		return 0
	end
	return math.clamp(value, 0, 1)
end

local function number(value: any, fallback: number): number
	local parsed = tonumber(value)
	if parsed == nil then
		return fallback
	end
	return parsed
end

--- Colour list -> keypoints. Accepts "#fff", {"#fff","#f00"}, {{0,"#fff"}}.
local function colorKeypoints(color: any): { any }
	if type(color) == "string" then
		return { { 0, color }, { 1, color } }
	end
	if type(color) ~= "table" or #color == 0 then
		return { { 0, "#ffffff" }, { 1, "#ffffff" } }
	end
	local points = {}
	for index, value in ipairs(color) do
		if type(value) == "table" then
			table.insert(points, { clamp01(number(value[1], 0)), tostring(value[2] or "#ffffff") })
		elseif type(value) == "string" then
			local time = if #color == 1 then 0 else (index - 1) / (#color - 1)
			table.insert(points, { time, value })
		elseif type(value) == "number" then
			-- Single channel grey shorthand: 0..1 -> hex.
			local c = math.floor(clamp01(value) * 255 + 0.5)
			local hex = string.format("#%02x%02x%02x", c, c, c)
			local time = if #color == 1 then 0 else (index - 1) / (#color - 1)
			table.insert(points, { time, hex })
		end
	end
	if #points == 0 then
		return { { 0, "#ffffff" }, { 1, "#ffffff" } }
	elseif #points == 1 then
		table.insert(points, { 1, points[1][2] })
	end
	return points
end

--- Numbers -> keypoints. `{0.5, 2}` means "grow from 0.5 to 2".
local function numberKeypoints(values: any, fallback: { any }): { any }
	if type(values) == "number" then
		return { { 0, values }, { 1, values } }
	end
	if type(values) ~= "table" or #values == 0 then
		return fallback
	end
	local points = {}
	for index, value in ipairs(values) do
		if type(value) == "table" then
			table.insert(points, { clamp01(number(value[1], 0)), math.max(0, number(value[2], 0)) })
		else
			local time = if #values == 1 then 0 else (index - 1) / (#values - 1)
			table.insert(points, { time, math.max(0, number(value, 0)) })
		end
	end
	if #points == 1 then
		table.insert(points, { 1, points[1][2] })
	end
	return points
end

local function range(values: any, fallbackMin: number, fallbackMax: number): { number }
	if type(values) == "number" then
		return { values, values }
	end
	if type(values) ~= "table" then
		return { fallbackMin, fallbackMax }
	end
	local min = number(values[1], fallbackMin)
	local max = number(values[2], min)
	if max < min then
		min, max = max, min
	end
	return { min, max }
end

local function vec3(values: any, fallbackY: number?): { number }
	if type(values) == "number" then
		return { values, values, values }
	end
	if type(values) ~= "table" then
		return { 0, fallbackY or 0, 0 }
	end
	return { number(values[1], 0), number(values[2], fallbackY or 0), number(values[3], 0) }
end

local function vec2(values: any, fallbackY: number?): { number }
	if type(values) == "number" then
		return { values, values }
	end
	if type(values) ~= "table" then
		return { 0, fallbackY or 0 }
	end
	return { number(values[1], 0), number(values[2], fallbackY or 0) }
end

--- Maps author-friendly short keys onto canonical spec field names.
local KEY_ALIASES = {
	tex = "texture",
	col = "color",
	colours = "color",
	colors = "color",
	trn = "transparency",
	alpha = "transparency",
	sz = "size",
	life = "lifetime",
	spd = "speed",
	sprd = "spread",
	rot = "rotation",
	rotspd = "rotSpeed",
	accel = "acceleration",
	le = "lightEmission",
	li = "lightInfluence",
	off = "offset",
	off0 = "offset0",
	off1 = "offset1",
	at = "startTime",
	dur = "duration",
	z = "zOffset",
	fb = "flipbookLayout",
	fbr = "flipbookFramerate",
	fbrnd = "flipbookRandom",
	locked = "lockedToPart",
	inherit = "velocityInheritance",
	ts = "timeScale",
	io = "shapeInOut",
	partial = "shapePartial",
	dir = "emissionDirection",
	style = "shapeStyle",
	orient = "orientation",
	wind = "windAffectsDrag",
	reps = "repeats",
	shadows = "shadows",
	bright = "brightness",
	curve = "curveSize0",
	curve1 = "curveSize1",
	texlen = "textureLength",
	texspd = "textureSpeed",
	seg = "segments",
	w0 = "width0",
	w1 = "width1",
	mat = "material",
};

local function expand(opts: { [string]: any }): { [string]: any }
	local out = {}
	for key, value in pairs(opts) do
		local canonical = KEY_ALIASES[key] or key
		out[canonical] = value
	end
	return out
end

local PARTICLE_DEFAULTS = {
	kind = "particle",
	name = "Particles",
	offset = { 0, 0, 0 },
	startTime = 0,
	duration = 1,
	texture = "sparkle",
	color = { { 0, "#ffffff" }, { 1, "#ffffff" } },
	transparency = { { 0, 0 }, { 1, 1 } },
	size = { { 0, 1 }, { 1, 0 } },
	lifetime = { 0.5, 1 },
	speed = { 4, 8 },
	spread = { 0, 0 },
	rotation = { 0, 0 },
	rotSpeed = { 0, 0 },
	drag = 0,
	acceleration = { 0, 0, 0 },
	rate = 20,
	burst = 0,
	repeats = 1,
	lightEmission = 0.5,
	lightInfluence = 0.2,
	shape = "Sphere",
	shapeStyle = "Volume",
	shapeInOut = "Outward",
	shapePartial = 1,
	emissionDirection = "Top",
	zOffset = 0,
	squash = 0,
	windAffectsDrag = false,
	orientation = "FacingCamera",
	flipbookLayout = "None",
	flipbookFramerate = { 30, 30 },
	flipbookRandom = true,
	lockedToPart = false,
	velocityInheritance = 0,
	timeScale = 1,
};

local BEAM_DEFAULTS = {
	kind = "beam",
	name = "Beam",
	offset0 = { 0, 0, 0 },
	offset1 = { 0, 1, 0 },
	startTime = 0,
	duration = 1,
	texture = "glow",
	color = { { 0, "#ffffff" }, { 1, "#ffffff" } },
	transparency = { { 0, 0 }, { 1, 0 } },
	width0 = 0.4,
	width1 = 0.4,
	curveSize0 = 0,
	curveSize1 = 0,
	segments = 10,
	brightness = 1,
	lightEmission = 1,
	lightInfluence = 0,
	textureLength = 0.5,
	textureSpeed = 0,
	textureMode = "Stretch",
	faceCamera = true,
	zOffset = 0,
};

local TRAIL_DEFAULTS = {
	kind = "trail",
	name = "Trail",
	offset0 = { 0, 0.4, 0 },
	offset1 = { 0, -0.4, 0 },
	startTime = 0,
	duration = 1,
	texture = "glow",
	color = { { 0, "#ffffff" }, { 1, "#ffffff" } },
	transparency = { { 0, 0.1 }, { 1, 1 } },
	lifetime = 0.5,
	minLength = 0.1,
	widthScale = 1,
	faceCamera = true,
	lightEmission = 0.6,
};

local LIGHT_DEFAULTS = {
	kind = "light",
	name = "Light",
	offset = { 0, 0, 0 },
	startTime = 0,
	duration = 1,
	color = "#ffffff",
	brightness = 2,
	range = 16,
	shadows = false,
};

local PART_DEFAULTS = {
	kind = "part",
	name = "Mesh",
	offset = { 0, 0, 0 },
	startTime = 0,
	duration = 1,
	size = { 1, 1, 1 },
	color = "#ffffff",
	transparency = 0.2,
	material = "Neon",
	shape = "Ball",
	rotation = { 0, 0, 0 },
	spin = { 0, 0, 0 },
	float = 0,
	texture = "",
};

local TWEEN_DEFAULTS = {
	kind = "tween",
	name = "Animation",
	target = "rig",
	property = "spin",
	from = 0,
	to = 360,
	startTime = 0,
	duration = 1,
	easing = "Quad",
	direction = "Out",
	repeatCount = 0,
	reverse = false,
};

local function merge(defaults: { [string]: any }, opts: { [string]: any }): { [string]: any }
	local merged = {}
	for key, value in pairs(defaults) do
		merged[key] = value
	end
	for key, value in pairs(opts) do
		merged[key] = value
	end
	return merged
end

--- Particle emitter component.
function DSL.P(opts: { [string]: any })
	local raw = expand(opts or {})
	local comp = merge(PARTICLE_DEFAULTS, raw)
	comp.kind = "particle"
	comp.texture = Assets.resolve(comp.texture)
	comp.color = colorKeypoints(comp.color)
	comp.transparency = numberKeypoints(comp.transparency, { { 0, 0 }, { 1, 1 } })
	comp.size = numberKeypoints(comp.size, { { 0, 1 }, { 1, 0 } })
	comp.lifetime = range(comp.lifetime, 0.5, 1)
	comp.speed = range(comp.speed, 0, 0)
	comp.spread = vec2(comp.spread, 0)
	comp.rotation = range(comp.rotation, 0, 0)
	comp.rotSpeed = range(comp.rotSpeed, 0, 0)
	comp.acceleration = vec3(comp.acceleration, 0)
	comp.offset = vec3(comp.offset, 0)
	comp.rate = math.max(0, number(comp.rate, 0))
	comp.burst = math.max(0, number(comp.burst, 0))
	comp.repeats = math.max(1, math.floor(number(comp.repeats, 1)))
	comp.lightEmission = clamp01(number(comp.lightEmission, 0))
	comp.lightInfluence = clamp01(number(comp.lightInfluence, 0))
	comp.shapePartial = clamp01(number(comp.shapePartial, 1))
	comp.squash = clamp01(number(comp.squash, 0))
	comp.velocityInheritance = clamp01(number(comp.velocityInheritance, 0))
	comp.flipbookFramerate = range(comp.flipbookFramerate, 30, 30)
	comp.zOffset = number(comp.zOffset, 0)
	comp.startTime = math.max(0, number(comp.startTime, 0))
	comp.duration = math.max(0, number(comp.duration, 0))
	comp.drag = math.max(0, number(comp.drag, 0))
	comp.timeScale = math.max(0.05, number(comp.timeScale, 1))
	return comp
end

function DSL.B(opts: { [string]: any })
	local comp = merge(BEAM_DEFAULTS, expand(opts or {}))
	comp.kind = "beam"
	comp.texture = Assets.resolve(comp.texture)
	comp.color = colorKeypoints(comp.color)
	comp.transparency = numberKeypoints(comp.transparency, { { 0, 0 }, { 1, 0 } })
	comp.offset0 = vec3(comp.offset0, 0)
	comp.offset1 = vec3(comp.offset1, 1)
	comp.width0 = math.max(0, number(comp.width0, 0.4))
	comp.width1 = math.max(0, number(comp.width1, 0.4))
	comp.curveSize0 = math.clamp(number(comp.curveSize0, 0), -5, 5)
	comp.curveSize1 = math.clamp(number(comp.curveSize1, 0), -5, 5)
	comp.segments = math.clamp(math.floor(number(comp.segments, 10)), 1, 100)
	comp.brightness = math.max(0, number(comp.brightness, 1))
	comp.lightEmission = clamp01(number(comp.lightEmission, 1))
	comp.lightInfluence = clamp01(number(comp.lightInfluence, 0))
	comp.textureLength = math.max(0.01, number(comp.textureLength, 0.5))
	comp.textureSpeed = number(comp.textureSpeed, 0)
	comp.zOffset = number(comp.zOffset, 0)
	comp.startTime = math.max(0, number(comp.startTime, 0))
	comp.duration = math.max(0, number(comp.duration, 0))
	return comp
end

function DSL.T(opts: { [string]: any })
	local comp = merge(TRAIL_DEFAULTS, expand(opts or {}))
	comp.kind = "trail"
	comp.texture = Assets.resolve(comp.texture)
	comp.color = colorKeypoints(comp.color)
	comp.transparency = numberKeypoints(comp.transparency, { { 0, 0.1 }, { 1, 1 } })
	comp.offset0 = vec3(comp.offset0, 0.4)
	comp.offset1 = vec3(comp.offset1, -0.4)
	comp.lifetime = math.clamp(number(comp.lifetime, 0.5), 0, 10)
	comp.minLength = math.max(0, number(comp.minLength, 0.1))
	comp.widthScale = math.max(0, number(comp.widthScale, 1))
	comp.lightEmission = clamp01(number(comp.lightEmission, 0.6))
	comp.startTime = math.max(0, number(comp.startTime, 0))
	comp.duration = math.max(0, number(comp.duration, 0))
	return comp
end

function DSL.L(opts: { [string]: any })
	local comp = merge(LIGHT_DEFAULTS, expand(opts or {}))
	comp.kind = "light"
	comp.offset = vec3(comp.offset, 0)
	comp.brightness = math.max(0, number(comp.brightness, 2))
	comp.range = math.max(0, number(comp.range, 16))
	comp.startTime = math.max(0, number(comp.startTime, 0))
	comp.duration = math.max(0, number(comp.duration, 0))
	return comp
end

function DSL.M(opts: { [string]: any })
	local comp = merge(PART_DEFAULTS, expand(opts or {}))
	-- Mesh-part components reuse the `size` key as a vector, not a sequence.
	comp.kind = "part"
	comp.offset = vec3(comp.offset, 0)
	comp.size = vec3(comp.size, 1)
	comp.rotation = vec3(comp.rotation, 0)
	comp.spin = vec3(comp.spin, 0)
	comp.transparency = math.clamp(number(comp.transparency, 0.2), 0, 1)
	comp.float = number(comp.float, 0)
	comp.startTime = math.max(0, number(comp.startTime, 0))
	comp.duration = math.max(0, number(comp.duration, 0))
	return comp
end

function DSL.A(opts: { [string]: any })
	local comp = merge(TWEEN_DEFAULTS, expand(opts or {}))
	comp.kind = "tween"
	comp.from = number(comp.from, 0)
	comp.to = number(comp.to, 1)
	comp.startTime = math.max(0, number(comp.startTime, 0))
	comp.duration = math.max(0.05, number(comp.duration, 1))
	comp.repeatCount = math.floor(number(comp.repeatCount, 0))
	return comp
end

--- Component names must be unique inside a preset: they are the instance
--- names, the inspector keys and what motion tracks target. Presets that use
--- several emitters without naming them would all be called "Particles", so
--- the surplus ones get a numeric suffix. A tween that targeted the original
--- name keeps pointing at the first component of that name, which is the only
--- component it could have meant before the rename existed.
local function uniqueNames(list: { any }): { any }
	local used = {}
	for _, comp in ipairs(list) do
		local base = tostring(comp.name or comp.kind or "Component")
		if used[base] then
			local index = 2
			while used[base .. " " .. index] do
				index += 1
			end
			comp.name = base .. " " .. index
			used[comp.name] = true
		else
			used[base] = true
		end
	end
	return list
end

--- Declares a preset. `extra` supports { loop, hint }.
function DSL.preset(name: string, category: string, tags: { string }?, duration: any, components: { any }?, extra: any?)
	local list = components
	if type(duration) == "table" then
		-- preset(name, category, tags, components, extra)
		list = duration
		duration = nil
	end
	return {
		name = name,
		category = category,
		tags = tags or {},
		duration = math.max(0.1, number(duration, 1.5)),
		loop = type(extra) == "table" and extra.loop == true,
		hint = type(extra) == "table" and extra.hint or nil,
		components = uniqueNames(list or {}),
	}
end

DSL.helpers = {
	colorKeypoints = colorKeypoints,
	numberKeypoints = numberKeypoints,
	range = range,
	vec3 = vec3,
	vec2 = vec2,
}

return DSL
