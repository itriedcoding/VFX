--[[
	Headless verification harness.

	test.js prepends `local FILES = { ... }` (every src module with its source)
	and runs this file with the standalone Luau interpreter. The mock below
	implements enough of the Roblox API for the real modules to execute, and
	importantly rejects writes to properties that do not exist on the class, so
	a typo like `emitter.Spread` (instead of `SpreadAngle`) fails the build.

	What is verified:
	  * every preset loads and validates with zero errors
	  * ids are unique, counts are real, textures resolve
	  * every preset compiles to instances with the expected components
	  * the spec JSON attribute round-trips through the compiler
	  * generated controller scripts are syntactically valid Luau
	  * decompiling a compiled model recovers its components
	  * store undo/redo, favourites and custom-preset persistence
	  * exporter inserts a model with controller + undo recording
]]

--------------------------------------------------------------------------------
-- warnings are assertions: any engine-level warning fails the run
--------------------------------------------------------------------------------

local warnings: { string } = {}
local deferred: { () -> () } = {}

local function capture(...)
	local parts = {}
	for index = 1, select("#", ...) do
		table.insert(parts, tostring(select(index, ...)))
	end
	table.insert(warnings, table.concat(parts, " "))
end

warn = capture

--------------------------------------------------------------------------------
-- datatypes
--------------------------------------------------------------------------------

-- Datatypes are globals, exactly as they are in Roblox.
Color3 = {}
Color3.__index = Color3

function Color3.new(r: number?, g: number?, b: number?): any
	return setmetatable({ R = r or 0, G = g or 0, B = b or 0 }, Color3)
end

function Color3.fromRGB(r: number, g: number, b: number): any
	return Color3.new((r or 0) / 255, (g or 0) / 255, (b or 0) / 255)
end

function Color3.fromHSV(h: number, s: number, v: number): any
	local i = math.floor(h * 6)
	local f = h * 6 - i
	local p = v * (1 - s)
	local q = v * (1 - f * s)
	local t = v * (1 - (1 - f) * s)
	local r, g, b
	local sector = i % 6
	if sector == 0 then
		r, g, b = v, t, p
	elseif sector == 1 then
		r, g, b = q, v, p
	elseif sector == 2 then
		r, g, b = p, v, t
	elseif sector == 3 then
		r, g, b = p, q, v
	elseif sector == 4 then
		r, g, b = t, p, v
	else
		r, g, b = v, p, q
	end
	return Color3.new(r, g, b)
end

function Color3:Lerp(other: any, alpha: number): any
	return Color3.new(
		self.R + (other.R - self.R) * alpha,
		self.G + (other.G - self.G) * alpha,
		self.B + (other.B - self.B) * alpha
	)
end

function Color3:ToHSV(): (number, number, number)
	local max = math.max(self.R, self.G, self.B)
	local min = math.min(self.R, self.G, self.B)
	local delta = max - min
	local h = 0
	if delta > 0 then
		if max == self.R then
			h = ((self.G - self.B) / delta) % 6
		elseif max == self.G then
			h = (self.B - self.R) / delta + 2
		else
			h = (self.R - self.G) / delta + 4
		end
		h /= 6
	end
	return h, (max == 0 and 0 or delta / max), max
end

ColorSequenceKeypoint = {}
function ColorSequenceKeypoint.new(time: number, value: any): any
	return { Time = time, Value = value }
end

ColorSequence = {}
function ColorSequence.new(a: any, b: any?): any
	local keypoints = {}
	if type(a) == "table" then
		for _, point in ipairs(a) do
			table.insert(keypoints, point)
		end
	elseif b then
		table.insert(keypoints, ColorSequenceKeypoint.new(0, a))
		table.insert(keypoints, ColorSequenceKeypoint.new(1, b))
	else
		table.insert(keypoints, ColorSequenceKeypoint.new(0, a))
		table.insert(keypoints, ColorSequenceKeypoint.new(1, a))
	end
	return { Keypoints = keypoints }
end

NumberSequenceKeypoint = {}
function NumberSequenceKeypoint.new(time: number, value: number): any
	return { Time = time, Value = value }
end

NumberSequence = {}
function NumberSequence.new(a: any, b: any?): any
	local keypoints = {}
	if type(a) == "table" then
		for _, point in ipairs(a) do
			table.insert(keypoints, point)
		end
	elseif b ~= nil then
		table.insert(keypoints, NumberSequenceKeypoint.new(0, a))
		table.insert(keypoints, NumberSequenceKeypoint.new(1, b))
	else
		table.insert(keypoints, NumberSequenceKeypoint.new(0, a))
		table.insert(keypoints, NumberSequenceKeypoint.new(1, a))
	end
	return { Keypoints = keypoints }
end

NumberRange = {}
function NumberRange.new(min: number, max: number?): any
	return { Min = min, Max = max or min }
end

Vector2 = {}
Vector2.__index = Vector2
function Vector2.new(x: number?, y: number?): any
	return setmetatable({ X = x or 0, Y = y or 0 }, Vector2)
end
function Vector2.__sub(a: any, b: any): any
	return Vector2.new(a.X - b.X, a.Y - b.Y)
end

Vector3 = {}
Vector3.__index = Vector3
function Vector3.new(x: number?, y: number?, z: number?): any
	return setmetatable({ X = x or 0, Y = y or 0, Z = z or 0 }, Vector3)
end
function Vector3.__add(a: any, b: any): any
	return Vector3.new(a.X + b.X, a.Y + b.Y, a.Z + b.Z)
end
function Vector3.__sub(a: any, b: any): any
	return Vector3.new(a.X - b.X, a.Y - b.Y, a.Z - b.Z)
end
function Vector3.__mul(a: any, b: any): any
	if type(b) == "number" then
		return Vector3.new(a.X * b, a.Y * b, a.Z * b)
	end
	return Vector3.new(a.X * b.X, a.Y * b.Y, a.Z * b.Z)
end

CFrame = {}
CFrame.__index = CFrame
function CFrame.new(x: any?, y: number?, z: number?): any
	local position
	if type(x) == "table" then
		position = x
	else
		position = Vector3.new(x or 0, y or 0, z or 0)
	end
	return setmetatable({ Position = position, _rotation = { 0, 0, 0 } }, CFrame)
end
function CFrame.Angles(rx: number, ry: number, rz: number): any
	local frame = CFrame.new(0, 0, 0)
	frame._rotation = { rx, ry, rz }
	return frame
end
function CFrame:ToObjectSpace(other: any): any
	return CFrame.new(self.Position.X - other.Position.X, self.Position.Y - other.Position.Y, self.Position.Z - other.Position.Z)
end
function CFrame.__mul(a: any, b: any): any
	return CFrame.new(
		a.Position.X + b.Position.X,
		a.Position.Y + b.Position.Y,
		a.Position.Z + b.Position.Z
	)
end

UDim = {}
function UDim.new(scale: number?, offset: number?): any
	return { Scale = scale or 0, Offset = offset or 0 }
end

UDim2 = {}
function UDim2.new(xs: number?, xo: number?, ys: number?, yo: number?): any
	return { X = UDim.new(xs, xo), Y = UDim.new(ys, yo) }
end

TweenInfo = {}
function TweenInfo.new(...: any): any
	return { ... }
end

--------------------------------------------------------------------------------
-- enums: any member resolves, comparison is by cache identity
--------------------------------------------------------------------------------

local enumItems: { [string]: any } = {}
local function enumItem(typeName: string, name: string): any
	local key = typeName .. "." .. name
	if not enumItems[key] then
		enumItems[key] = { Name = name, Value = 0, EnumType = typeName }
	end
	return enumItems[key]
end

local function enumType(typeName: string): any
	return setmetatable({}, {
		__index = function(_, key)
			if key == "GetEnumItems" then
				return function()
					return { enumItem(typeName, "Item") }
				end
			end
			return enumItem(typeName, tostring(key))
		end,
	})
end

Enum = setmetatable({}, {
	__index = function(self, key)
		local value = enumType(tostring(key))
		rawset(self, key, value)
		return value
	end,
})

--------------------------------------------------------------------------------
-- instances with a property whitelist
--------------------------------------------------------------------------------

local COMMON = {
	Name = true,
	Parent = true,
	Archivable = true,
}

local ALLOWED: { [string]: { [string]: boolean } } = {
	Model = { PrimaryPart = true, WorldPivot = true },
	Part = {
		Anchored = true, CanCollide = true, CanQuery = true, CanTouch = true,
		CastShadow = true, Massless = true, Locked = true, Transparency = true,
		Size = true, Material = true, TopSurface = true, BottomSurface = true,
		CFrame = true, Color = true, Shape = true, Reflectance = true,
	},
	Attachment = { Position = true, Visible = true, Orientation = true, CFrame = true, Axis = true },
	ParticleEmitter = {
		Texture = true, Color = true, Transparency = true, Size = true, Lifetime = true,
		Speed = true, SpreadAngle = true, Rotation = true, RotSpeed = true, Drag = true,
		Acceleration = true, Rate = true, LightEmission = true, LightInfluence = true,
		Shape = true, ShapeStyle = true, ShapeInOut = true, ShapePartial = true,
		EmissionDirection = true, ZOffset = true, Squash = true, WindAffectsDrag = true,
		Orientation = true, FlipbookLayout = true, FlipbookFramerate = true,
		FlipbookStartRandom = true, LockedToPart = true, VelocityInheritance = true,
		TimeScale = true, Enabled = true,
	},
	Beam = {
		Texture = true, Color = true, Transparency = true, Width0 = true, Width1 = true,
		CurveSize0 = true, CurveSize1 = true, Segments = true, Brightness = true,
		LightEmission = true, LightInfluence = true, TextureLength = true,
		TextureSpeed = true, TextureMode = true, FaceCamera = true, ZOffset = true,
		Attachment0 = true, Attachment1 = true, Enabled = true,
	},
	Trail = {
		Texture = true, Color = true, Transparency = true, Lifetime = true,
		MinLength = true, WidthScale = true, LightEmission = true, FaceCamera = true,
		Attachment0 = true, Attachment1 = true, Enabled = true,
	},
	PointLight = { Color = true, Brightness = true, Range = true, Shadows = true, Enabled = true },
	ModuleScript = { Source = true },
	Script = { Source = true, Disabled = true },
	StringValue = { Value = true },
	Folder = {},
}

local INSTANCE = {}

local functions = {}

local function newInstance(className: string, parent: any?): any
	local self = {
		__class = className,
		__children = {},
		__attributes = {},
		__props = {},
		__emitted = 0,
	}
	setmetatable(self, INSTANCE)
	if parent then
		self.Parent = parent
	end
	return self
end

function INSTANCE.__index(self: any, key: string): any
	if key == "ClassName" then
		return self.__class
	end
	if key == "Name" then
		return self.__name or self.__class
	end
	if key == "Parent" then
		return self.__parent
	end
	if key == "Children" then
		return self.__children
	end
	local method = functions[key]
	if method then
		return method
	end
	local value = self.__props[key]
	if value ~= nil then
		return value
	end
	-- Child lookup, exactly like Roblox: script.Parent.Core.Util.
	for _, child in ipairs(self.__children) do
		if child.Name == key then
			return child
		end
	end
	return nil
end

function INSTANCE.__newindex(self: any, key: string, value: any)
	-- Internal bookkeeping fields (__parent, __name, ...) bypass the whitelist.
	if string.sub(key, 1, 2) == "__" then
		rawset(self, key, value)
		return
	end
	if key == "Name" then
		self.__name = value
		return
	end
	if key == "Parent" then
		local previous = self.__parent
		if previous then
			for index, child in ipairs(previous.__children) do
				if child == self then
					table.remove(previous.__children, index)
					break
				end
			end
		end
		self.__parent = value
		if value then
			table.insert(value.__children, self)
		end
		return
	end
	if key == "Archivable" then
		self.__props.Archivable = value
		return
	end
	local allowed = ALLOWED[self.__class]
	if not allowed then
		error(string.format("mock has no property table for class %s (setting %s)", tostring(self.__class), tostring(key)), 2)
	end
	if not allowed[key] then
		error(string.format("%s has no property '%s'", tostring(self.__class), tostring(key)), 2)
	end
	self.__props[key] = value
end

local CLASS_CHAIN: { [string]: { string } } = {
	Part = { "Part", "BasePart", "PVInstance", "Instance" },
	MeshPart = { "MeshPart", "BasePart", "PVInstance", "Instance" },
	Model = { "Model", "PVInstance", "Instance" },
	Folder = { "Folder", "Instance" },
	Attachment = { "Attachment", "Instance" },
	ParticleEmitter = { "ParticleEmitter", "Instance" },
	Beam = { "Beam", "Instance" },
	Trail = { "Trail", "Instance" },
	PointLight = { "PointLight", "Instance" },
	ModuleScript = { "ModuleScript", "LuaSourceContainer", "Instance" },
	Script = { "Script", "BaseScript", "LuaSourceContainer", "Instance" },
	StringValue = { "StringValue", "ValueBase", "Instance" },
	WorldModel = { "WorldModel", "Instance" },
}

function functions:IsA(className: string): boolean
	local chain = CLASS_CHAIN[self.__class] or { self.__class, "Instance" }
	for _, name in ipairs(chain) do
		if name == className then
			return true
		end
	end
	return false
end

function functions:GetChildren(): { any }
	return table.clone(self.__children)
end

function functions:GetDescendants(): { any }
	local list = {}
	local function walk(node)
		for _, child in ipairs(node.__children) do
			table.insert(list, child)
			walk(child)
		end
	end
	walk(self)
	return list
end

function functions:FindFirstChild(name: string, recursive: boolean?): any?
	for _, child in ipairs(self.__children) do
		if child.Name == name then
			return child
		end
	end
	if recursive then
		for _, child in ipairs(self.__children) do
			local found = functions.FindFirstChild(child, name, true)
			if found then
				return found
			end
		end
	end
	return nil
end

function functions:FindFirstChildWhichIsA(className: string, recursive: boolean?): any?
	for _, child in ipairs(self.__children) do
		if child:IsA(className) then
			return child
		end
	end
	if recursive then
		for _, child in ipairs(self.__children) do
			local found = functions.FindFirstChildWhichIsA(child, className, true)
			if found then
				return found
			end
		end
	end
	return nil
end

function functions:FindFirstChildOfClass(className: string): any?
	for _, child in ipairs(self.__children) do
		if child.ClassName == className then
			return child
		end
	end
	return nil
end

function functions:WaitForChild(name: string): any?
	return functions.FindFirstChild(self, name)
end

function functions:GetFullName(): string
	if not self then
		return "<nil>"
	end
	if self.__parent then
		return functions.GetFullName(self.__parent) .. "." .. self.Name
	end
	return self.Name
end

function functions:SetAttribute(name: string, value: any)
	self.__attributes[name] = value
end

function functions:GetAttribute(name: string): any
	return self.__attributes[name]
end

function functions:GetAttributes(): { [string]: any }
	return table.clone(self.__attributes)
end

function functions:GetPropertyChangedSignal(_name: string): any
	return {
		Connect = function()
			return { Disconnect = function() end }
		end,
	}
end

function functions:Destroy()
	self.Parent = nil
end

function functions:Clear()
	self.__emitted = 0
end

function functions:Emit(count: number)
	self.__emitted += count or 1
end

function functions:Clone(): any
	local copy = newInstance(self.__class, nil)
	copy.__name = self.__name
	for key, value in pairs(self.__props) do
		copy.__props[key] = value
	end
	for key, value in pairs(self.__attributes) do
		copy.__attributes[key] = value
	end
	for _, child in ipairs(self.__children) do
		local childCopy = functions.Clone(child)
		childCopy.Parent = copy
	end
	return copy
end

Instance = { new = newInstance }

--------------------------------------------------------------------------------
-- services
--------------------------------------------------------------------------------

local function fakeSignal()
	return {
		Connect = function()
			return { Disconnect = function() end }
		end,
		Once = function()
			return { Disconnect = function() end }
		end,
	}
end

local jsonEncode

local function jsonEncodeString(value: string): string
	local escaped = string.gsub(value, '[%c"\\]', function(char)
		if char == '"' then
			return '\\"'
		elseif char == "\\" then
			return "\\\\"
		elseif char == "\n" then
			return "\\n"
		elseif char == "\r" then
			return "\\r"
		elseif char == "\t" then
			return "\\t"
		end
		return ""
	end)
	return '"' .. escaped .. '"'
end

function jsonEncode(value: any): string
	local kind = type(value)
	if kind == "table" then
		if #value > 0 then
			local parts = {}
			for _, item in ipairs(value) do
				table.insert(parts, jsonEncode(item))
			end
			return "[" .. table.concat(parts, ",") .. "]"
		end
		local keys = {}
		for key in pairs(value) do
			if type(key) == "string" then
				table.insert(keys, key)
			end
		end
		table.sort(keys)
		local parts = {}
		for _, key in ipairs(keys) do
			table.insert(parts, jsonEncodeString(key) .. ":" .. jsonEncode(value[key]))
		end
		return "{" .. table.concat(parts, ",") .. "}"
	elseif kind == "number" then
		if value ~= value or value == math.huge or value == -math.huge then
			return "0"
		end
		return tostring(value)
	elseif kind == "string" then
		return jsonEncodeString(value)
	elseif kind == "boolean" then
		return value and "true" or "false"
	end
	return "null"
end

local function jsonDecode(text: string): any
	local position = 1
	local length = #text

	local function skip()
		while position <= length do
			local char = string.sub(text, position, position)
			if char == " " or char == "\n" or char == "\r" or char == "\t" then
				position += 1
			else
				break
			end
		end
	end

	local parseValue

	local function parseString(): string
		position += 1
		local buffer = {}
		while position <= length do
			local char = string.sub(text, position, position)
			if char == '"' then
				position += 1
				return table.concat(buffer)
			elseif char == "\\" then
				local nextChar = string.sub(text, position + 1, position + 1)
				if nextChar == "n" then
					table.insert(buffer, "\n")
				elseif nextChar == "t" then
					table.insert(buffer, "\t")
				elseif nextChar == "r" then
					table.insert(buffer, "\r")
				elseif nextChar == '"' then
					table.insert(buffer, '"')
				elseif nextChar == "\\" then
					table.insert(buffer, "\\")
				elseif nextChar == "/" then
					table.insert(buffer, "/")
				else
					table.insert(buffer, nextChar)
				end
				position += 2
			else
				table.insert(buffer, char)
				position += 1
			end
		end
		error("json: unterminated string")
	end

	local function parseArray(): any
		position += 1
		local list = {}
		skip()
		if string.sub(text, position, position) == "]" then
			position += 1
			return list
		end
		while true do
			table.insert(list, parseValue())
			skip()
			local char = string.sub(text, position, position)
			position += 1
			if char == "]" then
				return list
			elseif char ~= "," then
				error("json: expected , or ] at " .. tostring(position))
			end
			skip()
		end
	end

	local function parseObject(): any
		position += 1
		local object = {}
		skip()
		if string.sub(text, position, position) == "}" then
			position += 1
			return object
		end
		while true do
			skip()
			if string.sub(text, position, position) ~= '"' then
				error("json: expected key at " .. tostring(position))
			end
			local key = parseString()
			skip()
			position += 1 -- colon
			object[key] = parseValue()
			skip()
			local char = string.sub(text, position, position)
			position += 1
			if char == "}" then
				return object
			elseif char ~= "," then
				error("json: expected , or } at " .. tostring(position))
			end
		end
	end

	parseValue = function(): any
		skip()
		local char = string.sub(text, position, position)
		if char == "{" then
			return parseObject()
		elseif char == "[" then
			return parseArray()
		elseif char == '"' then
			return parseString()
		elseif string.sub(text, position, position + 3) == "true" then
			position += 4
			return true
		elseif string.sub(text, position, position + 4) == "false" then
			position += 5
			return false
		elseif string.sub(text, position, position + 3) == "null" then
			position += 4
			return nil
		else
			local numberText = string.match(text, "^-?%d+%.?%d*[eE]?[-+]?%d*", position)
			if not numberText then
				error("json: unexpected token at " .. tostring(position) .. ": " .. string.sub(text, position, position + 12))
			end
			position += #numberText
			return tonumber(numberText)
		end
	end

	local result = parseValue()
	return result
end

MOCK_HTTP = { responses = {}, requests = {} }

-- Responses injected by tools/release-check.js (real network, same code path).
if LIVE_HTTP then
	for url, response in pairs(LIVE_HTTP) do
		MOCK_HTTP.responses[url] = response
	end
end
MOCK_JSON_ENCODE = jsonEncode

local HttpService = {
	JSONEncode = function(_, value)
		return jsonEncode(value)
	end,
	JSONDecode = function(_, text)
		return jsonDecode(text)
	end,
	RequestAsync = function(_, request)
		table.insert(MOCK_HTTP.requests, request)
		local response = MOCK_HTTP.responses[request.Url]
		if response then
			return response
		end
		return { Success = false, StatusCode = 404, Body = "" }
	end,
}

local TweenService = {
	Create = function(_, _instance, _info, _props)
		return {
			Play = function() end,
			Cancel = function() end,
			Completed = fakeSignal(),
		}
	end,
}

ChangeHistoryService = {
	TryBeginRecording = function(_, name)
		return { name = name }
	end,
	FinishRecording = function() end,
	SetWaypoint = function() end,
}

local services: { [string]: any } = {}
local serviceInstances: { [string]: any } = {}

local function service(name: string): any
	if services[name] then
		return services[name]
	end
	local instance = newInstance("Folder")
	instance.__name = name
	services[name] = instance
	return instance
end

services.HttpService = HttpService
services.TweenService = TweenService
services.ChangeHistoryService = ChangeHistoryService
services.ContentProvider = {
	PreloadAsync = function() end,
}
services.Selection = {
	Get = function()
		return {}
	end,
	Set = function() end,
}
services.RunService = { Heartbeat = fakeSignal(), RenderStepped = fakeSignal() }
services.UserInputService = {
	InputBegan = fakeSignal(),
	InputChanged = fakeSignal(),
	InputEnded = fakeSignal(),
	GetFocusedTextBox = function()
		return nil
	end,
	IsKeyDown = function()
		return false
	end,
	GetMouseLocation = function()
		return Vector2.new(0, 0)
	end,
}

game = {
	GetService = function(_, name)
		return service(name)
	end,
}

task = {
	spawn = function(callback, ...)
		local ok, err = pcall(callback, ...)
		if not ok then
			table.insert(warnings, "task.spawn error: " .. tostring(err))
		end
	end,
	defer = function(callback)
		table.insert(deferred, callback)
	end,
	delay = function(_seconds, callback)
		table.insert(deferred, callback)
	end,
	wait = function()
		return 0
	end,
	cancel = function() end,
}

--------------------------------------------------------------------------------
-- module tree + require
--------------------------------------------------------------------------------

local SOURCES: { [any]: string } = {}

local function makeNode(name: string, className: string, parent: any?): any
	local node = newInstance(className, nil)
	node.Name = name
	if parent then
		node.Parent = parent
	end
	return node
end

local root = makeNode("VFXStudio", "Folder", nil)

local function split(value: string, separator: string): { string }
	local list = {}
	local escaped = string.gsub(separator, "([%p])", "%%%1")
	for part in string.gmatch(value .. separator, "(.-)" .. escaped) do
		table.insert(list, part)
	end
	return list
end

local function addEntry(entry: any)
	local segments = split(entry.path, "/")
	if segments[#segments] == "init" then
		table.remove(segments)
	end
	local parent = root
	for index = 1, #segments - 1 do
		local folderName = segments[index]
		local existing = functions.FindFirstChild(parent, folderName)
		if not existing then
			existing = makeNode(folderName, "Folder", parent)
		end
		parent = existing
	end
	local node = functions.FindFirstChild(parent, entry.name)
	if not node then
		node = makeNode(entry.name, entry.class, parent)
	end
	SOURCES[node] = entry.source
end

-- init modules define their folder's node, so they must be created first.
for _, entry in ipairs(FILES) do
	if string.sub(entry.path, -5) == "/init" then
		addEntry(entry)
	end
end
for _, entry in ipairs(FILES) do
	if string.sub(entry.path, -5) ~= "/init" then
		addEntry(entry)
	end
end

local loaded: { [any]: any } = {}
local loading: { [any]: boolean } = {}

local function loadModule(node: any): any
	if loaded[node] ~= nil then
		return loaded[node]
	end
	if loading[node] then
		error("circular require: " .. tostring(functions.GetFullName(node)))
	end
	local source = SOURCES[node]
	if not source then
		-- Modules created at runtime (by the updater) carry their source directly.
		local inline = node.Source
		if type(inline) == "string" then
			source = inline
			SOURCES[node] = inline
		end
	end
	if not source then
		error("no source registered for " .. tostring(functions.GetFullName(node)))
	end

	loading[node] = true
	local previous = script
	script = node
	local chunk, compileError = loadstring(source, "=" .. tostring(functions.GetFullName(node)))
	if not chunk then
		script = previous
		loading[node] = nil
		error(compileError, 0)
	end
	local ok, result = pcall(chunk)
	script = previous
	loading[node] = nil
	if not ok then
		error(result, 0)
	end
	if result == nil then
		result = true
	end
	loaded[node] = result
	return result
end

require = loadModule

--------------------------------------------------------------------------------
-- assertions
--------------------------------------------------------------------------------

local checks = 0

local function check(condition: any, message: string)
	checks += 1
	if not condition then
		error("CHECK FAILED: " .. message, 2)
	end
end

local function checkEqual(actual: any, expected: any, message: string)
	checks += 1
	if actual ~= expected then
		error(string.format("CHECK FAILED: %s (expected %s, got %s)", message, tostring(expected), tostring(actual)), 2)
	end
end

local function section(name: string)
	print("\n[" .. name .. "]")
end

