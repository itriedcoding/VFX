--[[
	Store - the editor's single source of truth.

	Holds the working spec, selection, undo stack, favourites and the
	developer's saved custom presets, and persists the parts that should
	survive a Studio restart through plugin settings.
]]

local Util = require(script.Parent.Util)
local Signals = require(script.Parent.Signals)
local History = require(script.Parent.History)
local Format = require(script.Parent.Format)
local DSL = require(script.Parent.Parent.Presets.DSL)

local Store = {}
Store.__index = Store

local SETTING_KEY = "VFXStudio.state.v2"
local SAVE_DEBOUNCE = 0.6

function Store.new(pluginInstance: Plugin, presets: any)
	local self = setmetatable({
		plugin = pluginInstance,
		presets = presets,
		signals = Signals.new(),
		history = History.new(80),
		spec = Util.deepCopy(presets.all[1]),
		selection = 1,
		favorites = {} :: { [string]: boolean },
		custom = {} :: { any },
		prefs = {
			speed = 1,
			loop = false,
			autoPlay = true,
			background = "studio",
			leftWidth = 286,
			rightWidth = 322,
			lastPresetId = "",
			lastCategory = "All",
		},
		saveToken = 0,
	}, Store)

	self:load()
	return self
end

--------------------------------------------------------------------------------
-- validation / normalisation
--------------------------------------------------------------------------------

local COMPONENT_DEFAULTS = {
	particle = function(name: string)
		return DSL.P({ name = name })
	end,
	beam = function(name: string)
		return DSL.B({ name = name })
	end,
	trail = function(name: string)
		return DSL.T({ name = name })
	end,
	light = function(name: string)
		return DSL.L({ name = name })
	end,
	part = function(name: string)
		return DSL.M({ name = name })
	end,
	tween = function(name: string)
		return DSL.A({ name = name })
	end,
}

--- Colour is stored as { {time, "#rrggbb"}, ... } everywhere in the editor.
--- Some component defaults and imported specs use a single hex string, which
--- the gradient editor cannot read, so it is widened here once.
local function normalizeColor(value: any): any
	if type(value) == "string" then
		return { { 0, value }, { 1, value } }
	end
	if type(value) == "table" then
		if #value == 0 then
			return { { 0, "#ffffff" }, { 1, "#ffffff" } }
		end
		if type(value[1]) == "string" then
			local points = {}
			for index, hex in ipairs(value) do
				points[index] = { (index - 1) / math.max(1, #value - 1), hex }
			end
			return points
		end
	end
	return value
end

--- Fills in any missing field on a custom/imported component so the inspector
--- can always render it, without discarding values a newer version added.
function Store.normalizeComponent(comp: any): any
	if type(comp) ~= "table" then
		return nil
	end
	local kind = comp.kind
	local factory = COMPONENT_DEFAULTS[kind]
	if not factory then
		return nil
	end
	local base = factory(tostring(comp.name or kind))
	for key, value in pairs(comp) do
		base[key] = value
	end
	base.kind = kind
	if base.color ~= nil then
		base.color = normalizeColor(base.color)
	end
	return base
end

function Store.normalizeSpec(spec: any): any
	local normalized = {
		id = spec.id or ("custom_" .. Util.slug(tostring(spec.name or "effect"))),
		name = tostring(spec.name or "Custom Effect"),
		category = tostring(spec.category or "Custom"),
		tags = type(spec.tags) == "table" and spec.tags or { "custom" },
		description = spec.description,
		duration = math.max(0.1, tonumber(spec.duration) or 1.5),
		loop = spec.loop == true,
		components = {},
	}
	for _, comp in ipairs(spec.components or {}) do
		local fixed = Store.normalizeComponent(comp)
		if fixed then
			table.insert(normalized.components, fixed)
		end
	end
	if #normalized.components == 0 then
		table.insert(normalized.components, DSL.P({ name = "Particles" }))
	end
	return normalized
end

--------------------------------------------------------------------------------
-- persistence
--------------------------------------------------------------------------------

function Store:load()
	local raw = self.plugin:GetSetting(SETTING_KEY)
	local data = Format.jsonDecode(if type(raw) == "string" then raw else nil)
	if type(data) ~= "table" then
		return
	end

	if type(data.favorites) == "table" then
		for id, enabled in pairs(data.favorites) do
			if enabled == true and type(id) == "string" then
				self.favorites[id] = true
			end
		end
	end

	if type(data.custom) == "table" then
		for _, entry in ipairs(data.custom) do
			local ok, normalized = pcall(Store.normalizeSpec, entry)
			if ok and normalized then
				normalized.category = "Custom"
				table.insert(self.custom, normalized)
			end
		end
	end

	if type(data.prefs) == "table" then
		for key, value in pairs(data.prefs) do
			if self.prefs[key] ~= nil or key == "lastPresetId" then
				self.prefs[key] = value
			end
		end
	end
end

function Store:save()
	local payload = {
		favorites = self.favorites,
		custom = self.custom,
		prefs = self.prefs,
	}
	local encoded = Format.jsonEncode(payload)
	if encoded then
		local ok, err = pcall(function()
			self.plugin:SetSetting(SETTING_KEY, encoded)
		end)
		if not ok then
			warn("[VFX Studio] could not save settings: " .. tostring(err))
		end
	end
end

function Store:scheduleSave()
	self.saveToken += 1
	local token = self.saveToken
	task.delay(SAVE_DEBOUNCE, function()
		if token == self.saveToken then
			self:save()
		end
	end)
end

function Store:getPref(key: string, fallback: any): any
	local value = self.prefs[key]
	if value == nil then
		return fallback
	end
	return value
end

function Store:setPref(key: string, value: any, options: any?)
	self.prefs[key] = value
	self:scheduleSave()
	if not options or options.silent ~= true then
		self.signals:fire("pref", { key = key, value = value })
	end
end

--------------------------------------------------------------------------------
-- working spec
--------------------------------------------------------------------------------

function Store:_snapshot(): any
	return {
		spec = Util.deepCopy(self.spec),
		selection = self.selection,
	}
end

function Store:_restore(snapshot: any)
	if not snapshot or not snapshot.spec then
		return
	end
	self.spec = Util.deepCopy(snapshot.spec)
	self.selection = math.clamp(snapshot.selection or 1, 1, math.max(1, #self.spec.components))
	self.signals:fire("spec")
	self.signals:fire("selection", self.selection)
	self.signals:fire("history")
end

function Store:working(): any
	return self.spec
end

function Store:currentComponent(): any?
	return self.spec.components[self.selection]
end

function Store:pushHistory(label: string)
	self.history:record(label, self:_snapshot())
	self.signals:fire("history")
end

function Store:undo()
	local snapshot, label = self.history:undo(self:_snapshot())
	if snapshot then
		self:_restore(snapshot)
		self.signals:fire("status", "Undid " .. tostring(label):lower())
	end
end

function Store:redo()
	local snapshot, label = self.history:redo(self:_snapshot())
	if snapshot then
		self:_restore(snapshot)
		self.signals:fire("status", "Redid " .. tostring(label):lower())
	end
end

function Store:applyPreset(spec: any, label: string?)
	local copy = Util.deepCopy(spec)
	copy = Store.normalizeSpec(copy)
	copy.id = spec.id
	copy.category = spec.category
	copy.tags = spec.tags
	copy.description = spec.description
	copy.loop = spec.loop
	self:pushHistory(label or ("Load " .. tostring(spec.name)))
	self.spec = copy
	self.selection = 1
	self.prefs.lastPresetId = spec.id or ""
	self:scheduleSave()
	self.signals:fire("spec")
	self.signals:fire("selection", self.selection)
	self.signals:fire("history")
end

function Store:select(index: number)
	local count = #self.spec.components
	if count == 0 then
		self.selection = 1
	else
		self.selection = math.clamp(index, 1, count)
	end
	self.signals:fire("selection", self.selection)
end

--- Mutates a single field without rebuilding the whole editor.
--- `record` pushes an undo entry first (used by discrete controls).
function Store:setField(index: number, key: string, value: any, record: boolean?)
	local comp = self.spec.components[index]
	if not comp then
		return
	end
	if record then
		self:pushHistory("Change " .. tostring(key))
	end
	comp[key] = value
	self.signals:fire("field", { index = index, key = key, value = value })
end

function Store:setSpecField(key: string, value: any, record: boolean?)
	if record then
		self:pushHistory("Change " .. tostring(key))
	end
	self.spec[key] = value
	self.signals:fire("spec")
end

function Store:addComponent(kind: string): number
	local factory = COMPONENT_DEFAULTS[kind]
	if not factory then
		return 0
	end
	self:pushHistory("Add " .. kind)
	local count = #self.spec.components + 1
	local name = kind:sub(1, 1):upper() .. kind:sub(2) .. " " .. count
	local used = {}
	for _, comp in ipairs(self.spec.components) do
		used[comp.name] = true
	end
	local attempt = 1
	while used[name] do
		attempt += 1
		name = kind:sub(1, 1):upper() .. kind:sub(2) .. " " .. count .. " (" .. attempt .. ")"
	end
	local comp = factory(name)
	comp.name = name
	table.insert(self.spec.components, comp)
	self.selection = #self.spec.components
	self.signals:fire("spec")
	self.signals:fire("selection", self.selection)
	return self.selection
end

function Store:removeComponent(index: number)
	local comp = self.spec.components[index]
	if not comp then
		return
	end
	self:pushHistory("Delete " .. tostring(comp.name))
	table.remove(self.spec.components, index)
	self.selection = math.clamp(self.selection, 1, math.max(1, #self.spec.components))
	self.signals:fire("spec")
	self.signals:fire("selection", self.selection)
end

function Store:duplicateComponent(index: number)
	local comp = self.spec.components[index]
	if not comp then
		return
	end
	self:pushHistory("Duplicate " .. tostring(comp.name))
	local copy = Util.deepCopy(comp)
	local base = copy.name .. " Copy"
	local used = {}
	for _, item in ipairs(self.spec.components) do
		used[item.name] = true
	end
	local name = base
	local suffix = 2
	while used[name] do
		name = base .. " " .. suffix
		suffix += 1
	end
	copy.name = name
	table.insert(self.spec.components, index + 1, copy)
	self.selection = index + 1
	self.signals:fire("spec")
	self.signals:fire("selection", self.selection)
end

function Store:moveComponent(from: number, to: number)
	local count = #self.spec.components
	if from < 1 or from > count or to < 1 or to > count or from == to then
		return
	end
	self:pushHistory("Reorder components")
	local comp = table.remove(self.spec.components, from)
	table.insert(self.spec.components, to, comp)
	self.selection = to
	self.signals:fire("spec")
	self.signals:fire("selection", self.selection)
end

function Store:renameComponent(index: number, newName: string)
	local comp = self.spec.components[index]
	if not comp then
		return
	end
	local trimmed = Util.trim(newName)
	if trimmed == "" or trimmed == comp.name then
		return
	end
	self:pushHistory("Rename component")
	comp.name = trimmed
	self.signals:fire("spec")
end

--------------------------------------------------------------------------------
-- favourites
--------------------------------------------------------------------------------

function Store:isFavorite(id: string): boolean
	return self.favorites[id] == true
end

function Store:toggleFavorite(id: string)
	if not id or id == "" then
		return
	end
	if self.favorites[id] then
		self.favorites[id] = nil
	else
		self.favorites[id] = true
	end
	self:scheduleSave()
	self.signals:fire("favorites", id)
end

--------------------------------------------------------------------------------
-- custom presets
--------------------------------------------------------------------------------

function Store:customPresets(): { any }
	return self.custom
end

function Store:findCustom(id: string): any?
	for _, spec in ipairs(self.custom) do
		if spec.id == id then
			return spec
		end
	end
	return nil
end

function Store:saveCustomPreset(name: string, description: string?): any
	local trimmed = Util.trim(name)
	if trimmed == "" then
		trimmed = "My Effect"
	end
	local copy = Store.normalizeSpec(Util.deepCopy(self.spec))
	copy.name = trimmed
	copy.category = "Custom"
	copy.description = description or ("Custom effect saved from " .. tostring(self.spec.name) .. ".")
	copy.id = "custom_" .. Util.slug(trimmed)
	local suffix = 2
	while self:findCustom(copy.id) do
		copy.id = "custom_" .. Util.slug(trimmed) .. "_" .. suffix
		suffix += 1
	end
	copy.tags = table.clone(self.spec.tags or {})
	if #copy.tags == 0 then
		copy.tags = { "custom" }
	end
	table.insert(self.custom, copy)
	self.prefs.lastPresetId = copy.id
	self:scheduleSave()
	self.signals:fire("custom")
	self.signals:fire("status", "Saved preset \"" .. trimmed .. "\"")
	return copy
end

function Store:updateCustomPreset(id: string, name: string?): any?
	local spec = self:findCustom(id)
	if not spec then
		return nil
	end
	self:pushHistory("Update custom preset")
	local copy = Store.normalizeSpec(Util.deepCopy(self.spec))
	copy.id = spec.id
	copy.name = name or spec.name
	copy.category = "Custom"
	copy.description = spec.description
	copy.tags = table.clone(self.spec.tags or {})
	spec.name = copy.name
	spec.components = copy.components
	spec.duration = copy.duration
	spec.tags = copy.tags
	self:scheduleSave()
	self.signals:fire("custom")
	self.signals:fire("status", "Updated \"" .. tostring(spec.name) .. "\"")
	return spec
end

function Store:deleteCustomPreset(id: string): boolean
	for index, spec in ipairs(self.custom) do
		if spec.id == id then
			table.remove(self.custom, index)
			self.favorites[id] = nil
			self:scheduleSave()
			self.signals:fire("custom")
			self.signals:fire("status", "Deleted \"" .. tostring(spec.name) .. "\"")
			return true
		end
	end
	return false
end

--------------------------------------------------------------------------------
-- library access helpers
--------------------------------------------------------------------------------

function Store:search(query: string?, options: any?): { any }
	local opts = options or {}
	opts.favorites = self.favorites
	-- "Favourites" and "Custom" are store-level views, not preset categories.
	if opts.category == "Favorites" or opts.category == "Custom" then
		opts.category = "All"
	end
	local results = self.presets.search(query, opts)
	if not opts.category or opts.category == "All" or opts.category == "Custom" or opts.category == "Favorites" then
		local customResults = {}
		local terms = Util.trim(string.lower(query or ""))
		for _, spec in ipairs(self.custom) do
			local include = true
			if opts.favoritesOnly and not self.favorites[spec.id] then
				include = false
			end
			if opts.category == "Favorites" and not self.favorites[spec.id] then
				include = false
			end
			if opts.category == "Custom" and not self:findCustom(spec.id) then
				include = false
			end
			if opts.category ~= "Custom" and opts.category ~= "Favorites" and opts.category ~= "All" then
				include = false
			end
			if include and terms ~= "" then
				local haystack = string.lower(spec.name .. " " .. table.concat(spec.tags or {}, " ") .. " custom")
				if not string.find(haystack, terms, 1, true) then
					include = false
				end
			end
			if include then
				table.insert(customResults, spec)
			end
		end
		for _, spec in ipairs(customResults) do
			table.insert(results, 1, spec)
		end
	end
	return results
end

function Store:categories(): { any }
	local list = {
		{ name = "All", label = "All Effects", count = #self.presets.all + #self.custom },
		{ name = "Favorites", label = "Favourites", count = Util.count(Util.fromSet(self.favorites)) },
		{ name = "Custom", label = "My Presets", count = #self.custom },
	}
	for _, category in ipairs(self.presets.categories) do
		table.insert(list, category)
	end
	return list
end

function Store:destroy()
	self.signals:clear()
end

return Store
