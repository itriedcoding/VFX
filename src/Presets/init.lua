--[[
	Presets - the indexed, validated preset library.

	Every category file returns an array of specs built with the DSL. This
	module assigns stable ids, builds search indexes and validates the whole
	library at load time so a malformed preset can never reach the viewport.
]]

local Util = require(script.Parent.Core.Util)
local DSL = require(script.DSL)

local Presets = {}

Presets.order = {
	"Explosions",
	"Fire",
	"Smoke",
	"Lightning",
	"Magic",
	"Auras",
	"Trails",
	"Particles",
	"Impacts",
	"Weapons",
	"Portals",
	"Weather",
	"Energy",
	"Environmental",
}

local modules = {
	Explosions = script.Explosions,
	Fire = script.Fire,
	Smoke = script.Smoke,
	Lightning = script.Lightning,
	Magic = script.Magic,
	Auras = script.Auras,
	Trails = script.Trails,
	Particles = script.Particles,
	Impacts = script.Impacts,
	Weapons = script.Weapons,
	Portals = script.Portals,
	Weather = script.Weather,
	Energy = script.Energy,
	Environmental = script.Environmental,
}

Presets.all = {}
Presets.byId = {}
Presets.byCategory = {}
Presets.categories = {}
Presets.tags = {}
Presets.errors = {}

local function describe(spec: any): string
	local emitters, beams, trails, lights, parts = 0, 0, 0, 0, 0
	for _, comp in ipairs(spec.components or {}) do
		if comp.kind == "particle" then
			emitters += 1
		elseif comp.kind == "beam" then
			beams += 1
		elseif comp.kind == "trail" then
			trails += 1
		elseif comp.kind == "light" then
			lights += 1
		elseif comp.kind == "part" then
			parts += 1
		end
	end
	local bits = {}
	local function push(count: number, singular: string, plural: string)
		if count > 0 then
			table.insert(bits, tostring(count) .. " " .. if count == 1 then singular else plural)
		end
	end
	push(emitters, "particle system", "particle systems")
	push(beams, "beam", "beams")
	push(trails, "trail", "trails")
	push(lights, "light", "lights")
	push(parts, "mesh part", "mesh parts")
	if #bits == 0 then
		table.insert(bits, "no geometry")
	end
	return string.format(
		"%s preset running %s over %s.",
		spec.category,
		table.concat(bits, ", "),
		Util.formatDuration(spec.duration)
	)
end

--- Structural validation. Returns a flat list of human-readable problems.
function Presets.validate(spec: any, id: string?): { string }
	local problems = {}
	local label = id or tostring(spec and spec.name)

	local function fail(message: string)
		table.insert(problems, label .. ": " .. message)
	end

	if type(spec) ~= "table" then
		table.insert(problems, tostring(id) .. ": preset is not a table")
		return problems
	end
	if type(spec.name) ~= "string" or Util.trim(spec.name) == "" then
		fail("missing name")
	end
	if type(spec.category) ~= "string" or not table.find(Presets.order, spec.category) then
		fail("unknown category " .. tostring(spec.category))
	end
	if type(spec.duration) ~= "number" or spec.duration <= 0 or spec.duration > 60 then
		fail("duration must be between 0 and 60 seconds")
	end
	if type(spec.components) ~= "table" or #spec.components == 0 then
		fail("has no components")
		return problems
	end

	local seenNames = {}
	for index, comp in ipairs(spec.components) do
		local where = "component " .. index
		if type(comp) ~= "table" then
			fail(where .. " is not a table")
			continue
		end
		if type(comp.name) ~= "string" or Util.trim(comp.name) == "" then
			fail(where .. " has no name")
		elseif seenNames[comp.name] then
			fail("duplicate component name '" .. comp.name .. "'")
		else
			seenNames[comp.name] = true
		end
		if not table.find({ "particle", "beam", "trail", "light", "part", "tween" }, comp.kind) then
			fail(where .. " has unknown kind " .. tostring(comp.kind))
			continue
		end
		if type(comp.startTime) ~= "number" or comp.startTime < 0 then
			fail(where .. " has a negative startTime")
		end
		if comp.kind == "particle" then
			if type(comp.rate) ~= "number" or comp.rate < 0 then
				fail(where .. " has an invalid rate")
			end
			local lifetime = comp.lifetime
			if type(lifetime) ~= "table" or #lifetime ~= 2 or (lifetime :: any)[1] <= 0 or (lifetime :: any)[2] < (lifetime :: any)[1] then
				fail(where .. " has an invalid lifetime range")
			end
			local speed = comp.speed
			if type(speed) ~= "table" or #speed ~= 2 or (speed :: any)[2] < (speed :: any)[1] then
				fail(where .. " has an invalid speed range")
			end
			if type(comp.texture) ~= "string" or comp.texture == "" then
				fail(where .. " has no texture")
			end
			if (comp.rate > 0 or comp.burst > 0) and comp.duration <= 0 then
				fail(where .. " cannot emit with a zero duration")
			end
		end
		if comp.kind == "light" then
			if type(comp.range) ~= "number" or comp.range <= 0 then
				fail(where .. " has an invalid light range")
			end
		end
		if comp.kind == "tween" then
			if not table.find({ "spin", "float", "brightness", "transparency", "scale", "color" }, comp.property) then
				fail(where .. " has unknown tween property " .. tostring(comp.property))
			end
		end
	end
	return problems
end

-- Build the index.
for _, categoryName in ipairs(Presets.order) do
	local moduleScript = modules[categoryName]
	local specs = {}
	if not moduleScript then
		table.insert(Presets.errors, "missing category module: " .. categoryName)
	else
		local ok, result = pcall(require, moduleScript)
		if ok and type(result) == "table" then
			specs = result
		else
			table.insert(Presets.errors, "category '" .. categoryName .. "' failed to load: " .. tostring(result))
		end
	end

	local bucket = {}
	Presets.byCategory[categoryName] = bucket

	for _, spec in ipairs(specs) do
		local id = Util.slug(categoryName) .. "_" .. Util.slug(spec.name)
		if Presets.byId[id] then
			local suffix = 2
			while Presets.byId[id .. "_" .. suffix] do
				suffix += 1
			end
			id = id .. "_" .. suffix
		end
		spec.id = id
		spec.category = categoryName
		spec.tags = spec.tags or {}
		spec.description = spec.hint or describe(spec)

		local problems = Presets.validate(spec, id)
		for _, problem in ipairs(problems) do
			table.insert(Presets.errors, problem)
		end

		table.insert(bucket, spec)
		table.insert(Presets.all, spec)
		Presets.byId[id] = spec

		for _, tag in ipairs(spec.tags) do
			Presets.tags[tag] = (Presets.tags[tag] or 0) + 1
		end
	end

	local displayNames = {
		Explosions = "Explosions",
		Fire = "Fire",
		Smoke = "Smoke & Fog",
		Lightning = "Lightning",
		Magic = "Magic",
		Auras = "Auras",
		Trails = "Trails",
		Particles = "Particles",
		Impacts = "Impacts",
		Weapons = "Weapons",
		Portals = "Portals",
		Weather = "Weather",
		Energy = "Energy",
		Environmental = "Environmental",
	}
	table.insert(Presets.categories, {
		name = categoryName,
		label = displayNames[categoryName] or categoryName,
		count = #bucket,
	})
end

Presets.tagList = Util.fromSet(Presets.tags)

if #Presets.errors > 0 then
	warn("[VFX Studio] preset validation found " .. #Presets.errors .. " issue(s):")
	for _, problem in ipairs(Presets.errors) do
		warn("  - " .. problem)
	end
end

function Presets.get(id: string): any?
	return Presets.byId[id]
end

function Presets.count(): number
	return #Presets.all
end

local function scoreMatch(spec: any, query: string): number
	local name = string.lower(spec.name)
	if string.sub(name, 1, #query) == query then
		return 3
	elseif string.find(name, query, 1, true) then
		return 2
	end
	for _, tag in ipairs(spec.tags) do
		if string.find(string.lower(tag), query, 1, true) then
			return 1
		end
	end
	return 0
end

--- Search + filter. `options`: { category, favorites, favoritesOnly, tags, sort }
function Presets.search(query: string?, options: any?): { any }
	local opts = options or {}
	local favorites = opts.favorites or {}
	local terms = Util.trim(string.lower(query or ""))
	local results = {}

	for _, spec in ipairs(Presets.all) do
		local include = true
		if opts.category and opts.category ~= "All" and spec.category ~= opts.category then
			include = false
		end
		if include and opts.favoritesOnly and not favorites[spec.id] then
			include = false
		end
		if include and opts.tag and opts.tag ~= "" then
			local hasTag = false
			for _, tag in ipairs(spec.tags) do
				if tag == opts.tag then
					hasTag = true
					break
				end
			end
			if not hasTag then
				include = false
			end
		end
		if include and terms ~= "" then
			local haystack = string.lower(
				spec.name .. " " .. spec.category .. " " .. table.concat(spec.tags, " ") .. " " .. spec.description
			)
			if not string.find(haystack, terms, 1, true) then
				include = false
			end
		end
		if include then
			table.insert(results, spec)
		end
	end

	table.sort(results, function(a, b)
		local favoriteA = favorites[a.id] and 1 or 0
		local favoriteB = favorites[b.id] and 1 or 0
		if favoriteA ~= favoriteB then
			return favoriteA > favoriteB
		end
		local scoreA = scoreMatch(a, terms)
		local scoreB = scoreMatch(b, terms)
		if scoreA ~= scoreB then
			return scoreA > scoreB
		end
		if a.category ~= b.category then
			return (table.find(Presets.order, a.category) or 99) < (table.find(Presets.order, b.category) or 99)
		end
		return string.lower(a.name) < string.lower(b.name)
	end)

	return results
end

return Presets
