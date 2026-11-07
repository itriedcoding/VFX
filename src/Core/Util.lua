--!strict
--[[
	Util - small, dependency-free helpers shared by every VFX Studio module.
]]

local Util = {}

local TweenService = game:GetService("TweenService")
local Selection = game:GetService("Selection")
local ContentProvider = game:GetService("ContentProvider")

local function warnProps(inst: Instance, key: string, err: string)
	warn(("[VFX Studio] could not set %s.%s: %s"):format(inst.ClassName, key, err))
end

--- Creates an instance and applies properties safely, parenting last.
function Util.new(className: string, props: { [string]: any }?, children: { Instance }?): Instance
	local inst = Instance.new(className)
	if props then
		local parent = props.Parent
		for key, value in pairs(props) do
			if key ~= "Parent" then
				local ok, err = pcall(function()
					(inst :: any)[key] = value
				end)
				if not ok then
					warnProps(inst, tostring(key), tostring(err))
				end
			end
		end
		if parent then
			inst.Parent = parent
		end
	end
	if children then
		for _, child in ipairs(children) do
			child.Parent = inst
		end
	end
	return inst
end

--- Applies properties that might not exist on every client version.
function Util.apply(inst: Instance, props: { [string]: any })
	for key, value in pairs(props) do
		local ok, err = pcall(function()
			(inst :: any)[key] = value
		end)
		if not ok then
			warnProps(inst, tostring(key), tostring(err))
		end
	end
end

function Util.hex(value: string): Color3
	if type(value) ~= "string" then
		return Color3.new(1, 1, 1)
	end
	local digits = value:gsub("#", "")
	if #digits == 3 then
		digits = digits:sub(1, 1):rep(2) .. digits:sub(2, 2):rep(2) .. digits:sub(3, 3):rep(2)
	end
	local number = tonumber(digits, 16)
	if not number then
		return Color3.new(1, 1, 1)
	end
	return Color3.fromRGB(
		bit32.band(bit32.rshift(number, 16), 255),
		bit32.band(bit32.rshift(number, 8), 255),
		bit32.band(number, 255)
	)
end

function Util.toHex(color: Color3): string
	local function channel(v: number): string
		local n = math.clamp(math.floor(v * 255 + 0.5), 0, 255)
		return string.format("%02x", n)
	end
	return "#" .. channel(color.R) .. channel(color.G) .. channel(color.B)
end

function Util.clamp(value: number, min: number, max: number): number
	if value < min then
		return min
	elseif value > max then
		return max
	end
	return value
end

function Util.lerp(a: number, b: number, alpha: number): number
	return a + (b - a) * alpha
end

function Util.round(value: number, decimals: number?): number
	local mult = 10 ^ (decimals or 0)
	return math.floor(value * mult + 0.5) / mult
end

--- Compact number formatting used by sliders / cost readouts.
function Util.pretty(value: number): string
	if value ~= value or value == math.huge or value == -math.huge then
		return "0"
	end
	local abs = math.abs(value)
	if abs >= 1e6 then
		return string.format("%.1fM", value / 1e6)
	elseif abs >= 1e4 then
		return string.format("%.1fk", value / 1e3)
	elseif abs >= 100 then
		return string.format("%d", math.floor(value + 0.5))
	elseif abs >= 10 then
		return string.format("%.1f", value)
	elseif abs >= 1 then
		return (string.format("%.2f", value):gsub("%.?0+$", ""))
	end
	return (string.format("%.3f", value):gsub("%.?0+$", ""))
end

function Util.deepCopy<T>(value: T): T
	if type(value) ~= "table" then
		return value
	end
	local copy = {}
	for key, item in pairs(value :: any) do
		if type(key) == "table" then
			copy[Util.deepCopy(key)] = Util.deepCopy(item)
		else
			copy[key] = Util.deepCopy(item)
		end
	end
	return (copy :: any) :: T
end

function Util.deepEqual(a: any, b: any): boolean
	if a == b then
		return true
	end
	if type(a) ~= "table" or type(b) ~= "table" then
		return false
	end
	for key, value in pairs(a) do
		if not Util.deepEqual(value, b[key]) then
			return false
		end
	end
	for key in pairs(b) do
		if a[key] == nil then
			return false
		end
	end
	return true
end

function Util.tween(inst: Instance, props: { [string]: any }, duration: number?, style: Enum.EasingStyle?, direction: Enum.EasingDirection?): Tween
	local info = TweenInfo.new(
		duration or 0.15,
		style or Enum.EasingStyle.Quad,
		direction or Enum.EasingDirection.Out
	)
	local tweenInstance = TweenService:Create(inst, info, props)
	tweenInstance:Play()
	return tweenInstance
end

function Util.destroyChildren(parent: Instance)
	for _, child in ipairs(parent:GetChildren()) do
		child:Destroy()
	end
end

function Util.clear(parent: Instance)
	for _, child in ipairs(parent:GetChildren()) do
		child:Destroy()
	end
end

function Util.sortStrings(list: { string })
	table.sort(list, function(a, b)
		return a:lower() < b:lower()
	end)
end

function Util.slug(value: string): string
	local slug = string.lower(value):gsub("[^%w]+", "_"):gsub("^_+", ""):gsub("_+$", "")
	return slug
end

function Util.trim(value: string): string
	return (string.gsub(value, "^%s*(.-)%s*$", "%1"))
end

function Util.contains(haystack: string, needle: string): boolean
	return string.find(string.lower(haystack), string.lower(needle), 1, true) ~= nil
end

local idCounter = 0
function Util.uuid(prefix: string?): string
	idCounter += 1
	return string.format("%s_%d_%d", prefix or "id", os.time(), idCounter)
end

function Util.descendantOf(inst: Instance, ancestor: Instance): boolean
	local current: Instance? = inst
	while current do
		if current == ancestor then
			return true
		end
		current = current.Parent
	end
	return false
end

function Util.closestAnchor(): Instance?
	local selection = Selection:Get()
	if #selection > 0 then
		return selection[1]
	end
	return nil
end

function Util.formatDuration(seconds: number): string
	if seconds < 1 then
		return string.format("%d ms", math.floor(seconds * 1000 + 0.5))
	end
	return (string.format("%.2fs", seconds):gsub("%.00s", "s"))
end

function Util.toArraySet(list: { string }): { [string]: boolean }
	local set = {}
	for _, value in ipairs(list or {}) do
		set[value] = true
	end
	return set
end

function Util.fromSet(set: { [string]: boolean }): { string }
	local list = {}
	for key, enabled in pairs(set) do
		if enabled then
			table.insert(list, key)
		end
	end
	table.sort(list)
	return list
end

function Util.count(list: { any }): number
	return #list
end

Util.TweenService = TweenService
Util.Selection = Selection
Util.ContentProvider = ContentProvider

return Util
