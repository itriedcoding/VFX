--[[
	Format - converts between the plain, JSON-safe VFX spec format and real
	Roblox datatypes. Every value a preset stores is a number, string, boolean
	or array, which keeps presets serialisable, copy/paste-able and diffable.
]]

local Util = require(script.Parent.Util)

local HttpService = game:GetService("HttpService")

local Format = {}

local MAX_KEYPOINTS = 20

local function clamp01(value: number): number
	if value ~= value then
		return 0
	end
	return math.clamp(value, 0, 1)
end

--- Colour keypoints are stored as { {time, "#rrggbb"}, ... }.
--- Returns a valid ColorSequence (0 and 1 endpoints guaranteed).
function Format.colorSequence(keypoints: any): ColorSequence
	local fallback = ColorSequence.new(Util.hex("#ffffff"))
	if type(keypoints) ~= "table" or #keypoints == 0 then
		return fallback
	end

	local points = {}
	for _, kp in ipairs(keypoints) do
		local time, hex
		if type(kp) == "table" then
			time = tonumber(kp[1]) or 0
			hex = kp[2] or kp.color or kp.value
		elseif type(kp) == "string" then
			time = (#points) / math.max(1, #keypoints - 1)
			hex = kp
		end
		if type(hex) == "string" then
			table.insert(points, { clamp01(time), Util.hex(hex) })
		end
	end

	if #points == 0 then
		return fallback
	end
	if #points == 1 then
		return ColorSequence.new(points[1][2])
	end

	table.sort(points, function(a, b)
		return a[1] < b[1]
	end)

	if points[1][1] > 0 then
		table.insert(points, 1, { 0, points[1][2] })
	end
	if points[#points][1] < 1 then
		table.insert(points, { 1, points[#points][2] })
	end

	-- Roblox requires strictly increasing keypoint times.
	local cleaned = {}
	for _, point in ipairs(points) do
		if #cleaned > 0 and point[1] <= cleaned[#cleaned][1] then
			cleaned[#cleaned] = point
		else
			table.insert(cleaned, point)
		end
	end
	if cleaned[1][1] > 0 then
		cleaned[1] = { 0, cleaned[1][2] }
	end
	if cleaned[#cleaned][1] < 1 then
		cleaned[#cleaned] = { 1, cleaned[#cleaned][2] }
	end
	while #cleaned > MAX_KEYPOINTS do
		table.remove(cleaned, math.floor(#cleaned / 2))
	end

	local keypointsOut = {}
	for _, point in ipairs(cleaned) do
		table.insert(keypointsOut, ColorSequenceKeypoint.new(point[1], point[2]))
	end
	return ColorSequence.new(keypointsOut)
end

--- Number keypoints are stored as { {time, value}, ... }.
function Format.numberSequence(keypoints: any): NumberSequence
	if type(keypoints) == "number" then
		return NumberSequence.new(keypoints)
	end
	if type(keypoints) ~= "table" or #keypoints == 0 then
		return NumberSequence.new(1)
	end

	local points = {}
	for index, kp in ipairs(keypoints) do
		local time, value
		if type(kp) == "table" then
			time = tonumber(kp[1]) or 0
			value = tonumber(kp[2]) or 0
		elseif type(kp) == "number" then
			time = (index - 1) / math.max(1, #keypoints - 1)
			value = kp
		end
		if value then
			table.insert(points, { clamp01(time), math.max(0, value) })
		end
	end

	if #points == 0 then
		return NumberSequence.new(1)
	end
	if #points == 1 then
		return NumberSequence.new(points[1][2])
	end

	table.sort(points, function(a, b)
		return a[1] < b[1]
	end)
	if points[1][1] > 0 then
		table.insert(points, 1, { 0, points[1][2] })
	end
	if points[#points][1] < 1 then
		table.insert(points, { 1, points[#points][2] })
	end

	local cleaned = {}
	for _, point in ipairs(points) do
		if #cleaned > 0 and point[1] <= cleaned[#cleaned][1] then
			cleaned[#cleaned] = point
		else
			table.insert(cleaned, point)
		end
	end
	if cleaned[1][1] > 0 then
		cleaned[1] = { 0, cleaned[1][2] }
	end
	if cleaned[#cleaned][1] < 1 then
		cleaned[#cleaned] = { 1, cleaned[#cleaned][2] }
	end
	while #cleaned > MAX_KEYPOINTS do
		table.remove(cleaned, math.floor(#cleaned / 2))
	end

	local keypointsOut = {}
	for _, point in ipairs(cleaned) do
		table.insert(keypointsOut, NumberSequenceKeypoint.new(point[1], point[2]))
	end
	return NumberSequence.new(keypointsOut)
end

--- Transparency is stored as increasing opacity values (0 = opaque).
function Format.transparency(value: any): NumberSequence
	if type(value) == "number" then
		return NumberSequence.new(clamp01(value))
	end
	if type(value) ~= "table" then
		return NumberSequence.new(0)
	end
	local points = {}
	for index, v in ipairs(value) do
		if type(v) == "table" then
			table.insert(points, { clamp01(tonumber(v[1]) or 0), clamp01(tonumber(v[2]) or 0) })
		else
			table.insert(points, { (index - 1) / math.max(1, #value - 1), clamp01(tonumber(v) or 0) })
		end
	end
	return Format.numberSequence(points)
end

function Format.numberRange(value: any, default: number?): NumberRange
	local fallback = default or 1
	if type(value) == "number" then
		return NumberRange.new(value)
	end
	if type(value) == "table" then
		local min = tonumber(value[1]) or fallback
		local max = tonumber(value[2]) or min
		if max < min then
			min, max = max, min
		end
		return NumberRange.new(min, max)
	end
	return NumberRange.new(fallback)
end

function Format.vector2(value: any, defaultY: number?): Vector2
	if type(value) == "table" then
		return Vector2.new(tonumber(value[1]) or 0, tonumber(value[2]) or defaultY or 0)
	elseif type(value) == "number" then
		return Vector2.new(value, value)
	end
	return Vector2.new(0, defaultY or 0)
end

function Format.vector3(value: any): Vector3
	if type(value) == "table" then
		return Vector3.new(tonumber(value[1]) or 0, tonumber(value[2]) or 0, tonumber(value[3]) or 0)
	elseif type(value) == "number" then
		return Vector3.new(value, value, value)
	end
	return Vector3.new(0, 0, 0)
end

--- Enum lookup that degrades to a default instead of erroring on older clients.
function Format.enum(enumType: Enum, name: any, defaultName: string): EnumItem
	local safeName = if type(name) == "string" then name else defaultName
	local ok, item = pcall(function()
		return (enumType :: any)[safeName]
	end)
	if ok and item then
		return item
	end
	local okDefault, fallback = pcall(function()
		return (enumType :: any)[defaultName]
	end)
	if okDefault and fallback then
		return fallback
	end
	local okItems, items = pcall(function()
		return enumType:GetEnumItems()
	end)
	if okItems and items and items[1] then
		return items[1]
	end
	error("VFX Studio: empty enum " .. tostring(enumType))
end

function Format.jsonEncode(value: any): string?
	local ok, encoded = pcall(function()
		return HttpService:JSONEncode(value)
	end)
	if ok then
		return encoded
	end
	warn("[VFX Studio] JSON encode failed: " .. tostring(encoded))
	return nil
end

function Format.jsonDecode(text: string?): any
	if type(text) ~= "string" or text == "" then
		return nil
	end
	local ok, decoded = pcall(function()
		return HttpService:JSONDecode(text)
	end)
	if ok then
		return decoded
	end
	return nil
end

--- True when a stored keypoint list is flat (needed by the curve editor).
function Format.isFlat(list: any): boolean
	if type(list) ~= "table" then
		return true
	end
	local first = list[1]
	for _, value in ipairs(list) do
		if type(value) == "table" then
			if value ~= first then
				return false
			end
		elseif value ~= first then
			return false
		end
	end
	return true
end

return Format
