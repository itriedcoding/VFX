--[[
	Assets - the texture catalogue behind every preset, plus runtime
	validation for textures the developer adds themselves.

	Three engine-shipped textures are guaranteed to exist on every client and
	are used as the backbone of the preset library. The rest are sample
	textures published in Roblox's own documentation; the Asset Manager
	validates them on demand and reports anything that fails to load instead
	of silently emitting invisible particles.
]]

local Util = require(script.Parent.Util)

local Assets = {}

Assets.groups = { "Fire", "Smoke", "Magic", "Energy", "Utility" }

-- `key` is what presets use (tex = "fire"); `id` is the canonical asset uri.
Assets.textures = {
	{
		id = "builtin_fire",
		key = "fire",
		name = "Fire Flame",
		uri = "rbxasset://textures/particles/fire_main.dds",
		group = "Fire",
		builtin = true,
		tags = { "flame", "heat", "ember" },
	},
	{
		id = "builtin_smoke",
		key = "smoke",
		name = "Smoke Puff",
		uri = "rbxasset://textures/particles/smoke_main.dds",
		group = "Smoke",
		builtin = true,
		tags = { "cloud", "dust", "fog" },
	},
	{
		id = "builtin_sparkle",
		key = "sparkle",
		name = "Sparkle",
		uri = "rbxasset://textures/particles/sparkles_main.dds",
		group = "Magic",
		builtin = true,
		tags = { "star", "glint", "shimmer" },
	},
	{
		id = "doc_glow",
		key = "glow",
		name = "Soft Glow",
		uri = "rbxassetid://6823766871",
		group = "Energy",
		tags = { "circle", "soft", "light" },
	},
	{
		id = "doc_square",
		key = "square",
		name = "Soft Square",
		uri = "rbxassetid://2282042320",
		group = "Utility",
		tags = { "quad", "block", "pixel" },
	},
	{
		id = "doc_puff",
		key = "puff",
		name = "Cloud Puff",
		uri = "rbxassetid://1084981840",
		group = "Smoke",
		tags = { "cloud", "soft", "billow" },
	},
	{
		id = "doc_star",
		key = "star",
		name = "Star Spark",
		uri = "rbxassetid://2273547790",
		group = "Magic",
		tags = { "star", "sparkle", "twinkle" },
	},
	{
		id = "doc_electric",
		key = "electric",
		name = "Electric Spark",
		uri = "rbxassetid://6101261905",
		group = "Energy",
		tags = { "lightning", "zap", "arc" },
	},
	{
		id = "doc_blast",
		key = "blast",
		name = "Explosion Cloud",
		uri = "rbxassetid://5860841663",
		group = "Fire",
		tags = { "explosion", "boom", "blast" },
	},
	{
		id = "doc_spark",
		key = "spark",
		name = "Spark",
		uri = "rbxassetid://5833323391",
		group = "Energy",
		tags = { "spark", "hot", "trail" },
	},
	{
		id = "doc_debris",
		key = "debris",
		name = "Debris Chunk",
		uri = "rbxassetid://6711256324",
		group = "Utility",
		tags = { "rock", "chunk", "impact" },
	},
	{
		id = "doc_dust",
		key = "dust",
		name = "Dust Mote",
		uri = "rbxassetid://14302399641",
		group = "Smoke",
		tags = { "mote", "ambient", "spore" },
	},
}

Assets.byKey = {}
Assets.byId = {}
Assets.byUri = {}
for _, entry in ipairs(Assets.textures) do
	Assets.byKey[entry.key] = entry
	Assets.byId[entry.id] = entry
	Assets.byUri[entry.uri] = entry
end

Assets.defaultUri = Assets.byKey.sparkle.uri

--- Resolves a preset shorthand ("fire"), a full uri, or an asset id string.
function Assets.resolve(value: any): string
	if type(value) ~= "string" or value == "" then
		return Assets.defaultUri
	end
	local entry = Assets.byKey[string.lower(value)] or Assets.byId[value] or Assets.byUri[value]
	if entry then
		return entry.uri
	end
	if string.match(value, "^%d+$") then
		return "rbxassetid://" .. value
	end
	return value
end

function Assets.describe(uri: string): string
	local entry = Assets.byUri[uri]
	if entry then
		return entry.name
	end
	local id = string.match(uri or "", "rbxassetid://(%d+)")
	if id then
		return "Asset " .. id
	end
	if string.find(uri or "", "rbxasset://", 1, true) then
		return (string.match(uri, "([^/]+%.%w+)$") or uri)
	end
	return uri
end

function Assets.isBuiltin(uri: string): boolean
	local entry = Assets.byUri[uri]
	return entry ~= nil and entry.builtin == true
end

--- True when the uri points at a user-published asset that can disappear.
function Assets.isRemote(uri: string): boolean
	return type(uri) == "string" and string.find(uri, "rbxassetid://", 1, true) ~= nil
end

--- Asset ids the developer saved themselves (persisted by the store).
Assets.custom = {}
Assets.customById = {}

function Assets.setCustom(list: { any })
	Assets.custom = {}
	Assets.customById = {}
	for _, entry in ipairs(list or {}) do
		if type(entry) == "table" and type(entry.uri) == "string" and entry.uri ~= "" then
			local record = {
				id = entry.id or Util.uuid("asset"),
				name = entry.name or Assets.describe(entry.uri),
				uri = entry.uri,
				group = entry.group or "Utility",
				tags = entry.tags or {},
				custom = true,
			}
			table.insert(Assets.custom, record)
			Assets.customById[record.id] = record
			Assets.byId[record.id] = record
			Assets.byUri[record.uri] = record
		end
	end
end

function Assets.all(): { any }
	local list = {}
	for _, entry in ipairs(Assets.textures) do
		table.insert(list, entry)
	end
	for _, entry in ipairs(Assets.custom) do
		table.insert(list, entry)
	end
	return list
end

--- Search across name, group and tags.
function Assets.search(query: string): { any }
	local trimmed = Util.trim(query or "")
	if trimmed == "" then
		return Assets.all()
	end
	local results = {}
	for _, entry in ipairs(Assets.all()) do
		local haystack = table.concat({ entry.name, entry.group, table.concat(entry.tags or {}, " ") }, " ")
		if Util.contains(haystack, trimmed) or Util.contains(entry.uri, trimmed) then
			table.insert(results, entry)
		end
	end
	return results
end

local statusCache: { [string]: string } = {}

--- Validates a texture against the content provider. Yields.
--- Returns "ok", "missing" or "unknown". `host` is any GUI parent.
function Assets.validate(uri: string, host: Instance?): string
	if type(uri) ~= "string" or uri == "" then
		return "missing"
	end
	if statusCache[uri] then
		return statusCache[uri]
	end
	if not host or uri:sub(1, 10) == "rbxasset:/" then
		-- rbxasset:// ships with the client; nothing to fetch.
		statusCache[uri] = if uri:sub(1, 10) == "rbxasset:/" then "ok" else "unknown"
		return statusCache[uri]
	end

	local probe = Instance.new("ImageLabel")
	probe.Image = uri
	probe.Visible = false
	probe.Size = UDim2.fromOffset(2, 2)
	probe.BackgroundTransparency = 1
	probe.Parent = host

	local status = "unknown"
	local ok = pcall(function()
		Util.ContentProvider:PreloadAsync({ probe }, function(_, fetchStatus)
			if fetchStatus == Enum.AssetFetchStatus.Success then
				status = "ok"
			elseif fetchStatus == Enum.AssetFetchStatus.TimedOut then
				status = "unknown"
			else
				status = "missing"
			end
		end)
	end)
	if not ok then
		status = "unknown"
	end
	probe:Destroy()

	-- Only cache definitive answers so a "TimedOut" can be retried.
	if status ~= "unknown" then
		statusCache[uri] = status
	end
	return status
end

function Assets.forget(uri: string)
	statusCache[uri] = nil
end

return Assets
