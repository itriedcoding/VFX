--[[
	Updater - release-synced self-update, entirely inside Roblox Studio.

	Flow:
	  1. Ask GitHub for the latest release (falls back to the manifest on the
	     main branch before the first release exists).
	  2. Download `manifest.json`, which carries every module's real source.
	  3. Validate it hard (sizes, classes, paths, top-level folders).
	  4. Hot-swap the running plugin's Core/Presets/UI folders for freshly
	     created ModuleScripts and verify the new App module loads. On any
	     failure the previous folders are restored untouched.
	  5. Offer "Save plugin file" so the update survives a Studio restart:
	     Studio has no API for writing plugin files, so this selects the rebuilt
	     model and opens Studio's own save dialog.

	Studio allows plugin HTTP per-domain; the user is prompted once for
	api.github.com / github.com / raw.githubusercontent.com. HttpEnabled is
	irrelevant to plugins.
]]

local HttpService = game:GetService("HttpService")
local ServerStorage = game:GetService("ServerStorage")
local Selection = game:GetService("Selection")

local Version = require(script.Parent.Version)
local Format = require(script.Parent.Format)
local Signals = require(script.Parent.Signals)

local Updater = {}
Updater.__index = Updater

local SETTING_KEY = "VFXStudio.update.v2"
local CONTAINER_FOLDER = "VFXStudio"

function Updater.new(pluginInstance: Plugin, root: Instance?)
	local self = setmetatable({
		plugin = pluginInstance,
		root = root,
		signals = Signals.new(),
		state = "idle",
		info = nil,
		lastError = nil,
		appliedManifest = nil,
		appliedVersion = nil,
		tempHolder = nil,
		cache = {},
	}, Updater)
	self:loadCache()
	return self
end

--------------------------------------------------------------------------------
-- state + cache
--------------------------------------------------------------------------------

function Updater:setState(state: string, message: string?)
	self.state = state
	self.stateMessage = message
	self.lastError = if state == "error" then message else nil
	self.signals:fire("state", { state = state, message = message })
end

function Updater:loadCache()
	local raw = self.plugin and self.plugin:GetSetting(SETTING_KEY)
	local decoded = Format.jsonDecode(if type(raw) == "string" then raw else nil)
	if type(decoded) == "table" then
		self.cache = decoded
	end
end

function Updater:saveCache()
	local encoded = Format.jsonEncode(self.cache)
	if not encoded or not self.plugin then
		return
	end
	pcall(function()
		self.plugin:SetSetting(SETTING_KEY, encoded)
	end)
end

function Updater:isAutoCheckEnabled(): boolean
	return self.cache.autoCheck ~= false
end

function Updater:setAutoCheck(enabled: boolean)
	self.cache.autoCheck = enabled == true
	self:saveCache()
	self.signals:fire("state", { state = self.state, message = self.stateMessage })
end

function Updater:shouldAutoCheck(): boolean
	if not self:isAutoCheckEnabled() then
		return false
	end
	local last = tonumber(self.cache.checkedAt) or 0
	return (os.time() - last) >= Version.MIN_CHECK_INTERVAL
end

function Updater:markChecked(version: string)
	self.cache.checkedAt = os.time()
	self.cache.latest = version
	self.cache.installed = Version.VERSION
	self:saveCache()
end

function Updater:installedVersion(): string
	return self.appliedVersion or Version.VERSION
end

function Updater:hasUpdate(): boolean
	return self.info ~= nil and Version.isNewer(self.info.version, self:installedVersion())
end

--------------------------------------------------------------------------------
-- http
--------------------------------------------------------------------------------

function Updater.explainHttpError(message: string): string
	local lower = string.lower(message)
	if string.find(lower, "not enabled", 1, true) or string.find(lower, "http requests are not", 1, true) then
		return "Studio blocked web requests for this plugin. Open Plugins → Manage Plugins, allow HTTP access for github.com, then retry."
	elseif string.find(lower, "permission", 1, true) or string.find(lower, "denied", 1, true) or string.find(lower, "not permitted", 1, true) then
		return "Studio denied this plugin's web access. Allow it under Plugins → Manage Plugins, then press Check again."
	elseif string.find(lower, "timeout", 1, true) or string.find(lower, "timed out", 1, true) then
		return "GitHub did not respond in time. Check your connection and retry."
	elseif string.find(lower, "not allowed to access", 1, true) then
		return "Studio blocked that domain for plugins. Allow it in Plugin Management and retry."
	end
	return message
end

--- Returns (body, nil) or (nil, message). `notfound` is returned for 404.
function Updater:httpGet(url: string, accept: string?): (string?, string?)
	local ok, response = pcall(function()
		return HttpService:RequestAsync({
			Url = url,
			Method = "GET",
			Headers = {
				["User-Agent"] = "VFX-Studio/" .. Version.VERSION,
				["Accept"] = accept or "application/json",
			},
			Timeout = Version.HTTP_TIMEOUT,
		})
	end)
	if not ok then
		return nil, Updater.explainHttpError(tostring(response))
	end
	if type(response) ~= "table" then
		return nil, "Studio returned no response for " .. url
	end
	if not response.Success then
		local status = tonumber(response.StatusCode) or 0
		if status == 404 then
			return nil, "notfound"
		elseif status == 403 then
			return nil, "GitHub rate limit reached (60 checks/hour). Try again later."
		elseif status == 0 then
			return nil, "Could not reach GitHub. Check your connection and plugin HTTP permissions."
		end
		return nil, string.format("GitHub returned HTTP %d for %s", status, url)
	end
	return response.Body or "", nil
end

--------------------------------------------------------------------------------
-- manifest validation / construction
--------------------------------------------------------------------------------

local function splitPath(value: string): { string }
	local list = {}
	for part in string.gmatch(value .. "/", "(.-)/") do
		table.insert(list, part)
	end
	return list
end

local function safeNodeName(value: any): boolean
	if type(value) ~= "string" or value == "" or #value > 80 then
		return false
	end
	if string.find(value, "[%c]") then
		return false
	end
	if string.find(value, "%.%.") or string.find(value, "[/\\]") then
		return false
	end
	return true
end

--- Hard validation of a downloaded manifest. Returns (true) or (false, message).
function Updater.validateManifest(manifest: any): (boolean, string?)
	if type(manifest) ~= "table" then
		return false, "The manifest is not a JSON object."
	end
	if type(manifest.version) ~= "string" or Version.parse(manifest.version) == nil then
		return false, "The manifest has no valid version."
	end
	if type(manifest.files) ~= "table" then
		return false, "The manifest has no file list."
	end
	local count = #manifest.files
	if count < 1 or count > Version.MAX_FILES then
		return false, string.format("The manifest lists %d files (expected 1-%d).", count, Version.MAX_FILES)
	end

	local total = 0
	local roots: { [string]: boolean } = {}
	for _, file in ipairs(manifest.files) do
		if type(file) ~= "table" then
			return false, "A manifest entry is not an object."
		end
		if type(file.path) ~= "string" or file.path == "" or string.find(file.path, "..", 1, true) then
			return false, "A manifest entry has an unsafe path."
		end
		if file.class ~= "ModuleScript" and file.class ~= "Script" then
			return false, "Unsupported class '" .. tostring(file.class) .. "' in " .. file.path
		end
		if not safeNodeName(file.name) then
			return false, "Unsafe instance name in " .. file.path
		end
		if type(file.source) ~= "string" then
			return false, "Missing source for " .. file.path
		end
		local size = #file.source
		if size > Version.MAX_SOURCE_BYTES then
			return false, "File too large: " .. file.path
		end
		total += size
		local segments = splitPath(file.path)
		if #segments < 1 then
			return false, "Path is empty: " .. file.path
		end
		roots[segments[1]] = true
	end

	if total > Version.MAX_TOTAL_BYTES then
		return false, string.format("The manifest is too large (%.1f MB).", total / (1024 * 1024))
	end
	for _, required in ipairs({ "Core", "Presets", "UI" }) do
		if not roots[required] then
			return false, "The manifest is missing the " .. required .. " folder."
		end
	end
	return true, nil
end

--- Builds a detached Folder tree from a validated manifest.
function Updater.buildTree(manifest: any): Folder
	local root = Instance.new("Folder")
	root.Name = CONTAINER_FOLDER

	local folders: { [string]: Folder } = {}
	local function folderAt(segments: { string }): Folder
		local parent = root
		local key = ""
		for _, segment in ipairs(segments) do
			key = key .. "/" .. segment
			local existing = folders[key]
			if not existing then
				existing = Instance.new("Folder")
				existing.Name = segment
				existing.Parent = parent
				folders[key] = existing
			end
			parent = existing
		end
		return parent
	end

	for _, file in ipairs(manifest.files) do
		local segments = splitPath(file.path)
		table.remove(segments)
		local parent = folderAt(segments)
		local instance = Instance.new(file.class)
		instance.Name = file.name
		instance.Source = file.source
		instance.Parent = parent
	end
	return root
end

--------------------------------------------------------------------------------
-- checking
--------------------------------------------------------------------------------

local function releaseNotes(value: any): string
	if type(value) ~= "string" then
		return ""
	end
	local trimmed = string.gsub(value, "%s+$", "")
	if #trimmed > 4000 then
		trimmed = string.sub(trimmed, 1, 4000) .. "\n\n..."
	end
	return trimmed
end

local function httpsUrl(value: any): string?
	if type(value) == "string" and string.sub(value, 1, 8) == "https://" then
		return value
	end
	return nil
end

--- Maps release asset names to their download URLs (https only).
local function releaseAssets(release: any): { [string]: string }
	local urls = {}
	if type(release.assets) ~= "table" then
		return urls
	end
	for _, asset in ipairs(release.assets) do
		if type(asset) == "table" and type(asset.name) == "string" then
			local url = httpsUrl(asset.browser_download_url)
			if url then
				urls[asset.name] = url
			end
		end
	end
	return urls
end

--- Where to download the published plugin file for a build. Manifests and
--- releases carry these when they can; otherwise the stable release URLs are
--- used, so the links always resolve for the latest published build.
function Updater.downloadLinks(source: any?): { model: string, zip: string, page: string }
	local block = if type(source) == "table" then source.download else nil
	local function pick(value: any, fallback: string): string
		return httpsUrl(value) or fallback
	end
	local model = if type(block) == "table" then block.model else nil
	local zip = if type(block) == "table" then block.zip else nil
	local page = if type(block) == "table" then block.page else nil
	return {
		model = pick(model, Version.MODEL_URL),
		zip = pick(zip, Version.PLUGIN_ZIP_URL),
		page = pick(page, Version.RELEASES_URL),
	}
end

--- Checks for a newer build. Yields while requesting. Returns the release info.
function Updater:check(): any?
	if self.state == "checking" or self.state == "downloading" or self.state == "applying" then
		return self.info
	end
	self:setState("checking", "Contacting GitHub...")

	local body, err = self:httpGet(Version.API_URL, "application/vnd.github+json")
	if body then
		local release = Format.jsonDecode(body)
		if type(release) == "table" and (release.tag_name or release.name) then
			local version = Version.clean(release.tag_name or release.name)
			if Version.parse(version) then
				local assets = releaseAssets(release)
				self.info = {
					version = version,
					notes = releaseNotes(release.body),
					url = httpsUrl(release.html_url) or Version.RELEASES_URL,
					publishedAt = release.published_at,
					manifestUrl = assets[Version.MANIFEST_ASSET] or Version.MANIFEST_URL,
					download = {
						model = assets[Version.MODEL_ASSET] or Version.MODEL_URL,
						zip = assets[Version.PLUGIN_ZIP_ASSET] or Version.PLUGIN_ZIP_URL,
						page = httpsUrl(release.html_url) or Version.RELEASES_URL,
					},
					source = "release",
				}
				self:markChecked(version)
				self:setState("idle", nil)
				return self.info
			end
			err = "The latest release tag is not a version number."
		else
			err = "GitHub returned an unexpected release payload."
		end
	end

	-- No releases yet (or the API is blocked): fall back to the manifest that
	-- is published from the main branch.
	self:setState("checking", "No release found - checking the main branch manifest...")
	local fallbackBody, fallbackErr = self:httpGet(Version.FALLBACK_MANIFEST_URL)
	if fallbackBody then
		local manifest = Format.jsonDecode(fallbackBody)
		local valid, problem = Updater.validateManifest(manifest)
		if valid then				self.info = {
					version = Version.clean(manifest.version),
					notes = "Build from the main branch (no tagged release yet).",
					url = Version.RELEASES_URL,
					publishedAt = manifest.generatedAt,
					manifestUrl = Version.FALLBACK_MANIFEST_URL,
					download = Updater.downloadLinks(manifest),
					source = "main",
				}
			self:markChecked(self.info.version)
			self:setState("idle", nil)
			return self.info
		end
		self:setState("error", problem)
		return nil
	end

	local message = err
	if message == nil or message == "notfound" then
		message = "No published builds yet. Tag a commit with v" .. Version.VERSION .. " to publish one."
	end
	if fallbackErr and fallbackErr ~= "notfound" then
		message = tostring(message) .. "\n" .. tostring(fallbackErr)
	end
	self:setState("error", message)
	return nil
end

--------------------------------------------------------------------------------
-- applying
--------------------------------------------------------------------------------

function Updater:downloadManifest(url: string?): (any?, string?)
	local target = url or (self.info and self.info.manifestUrl)
	if not target then
		return nil, "Check for updates first."
	end
	self:setState("downloading", "Downloading the new build...")
	local body, err = self:httpGet(target)
	if not body then
		self:setState("error", err or "Download failed.")
		return nil, err
	end
	local manifest = Format.jsonDecode(body)
	local valid, problem = Updater.validateManifest(manifest)
	if not valid then
		self:setState("error", problem)
		return nil, problem
	end
	if not Version.isNewer(manifest.version, self:installedVersion()) then
		local message = string.format("The downloaded build (v%s) is not newer than v%s.", Version.clean(manifest.version), self:installedVersion())
		self:setState("error", message)
		return nil, message
	end
	self:setState("downloading", "Downloaded v" .. Version.clean(manifest.version) .. ".")
	return manifest, nil
end

--- Swaps the running plugin's folders for the downloaded sources.
function Updater:apply(manifest: any): (boolean, string?)
	if not self.root then
		return false, "The plugin root folder is unavailable."
	end
	self:setState("applying", "Installing v" .. Version.clean(manifest.version) .. "...")

	local preview = Updater.buildTree(manifest)
	local swapped = {}

	local function rollback()
		for _, item in ipairs(swapped) do
			pcall(function()
				item.new:Destroy()
			end)
			item.old.Name = item.name
		end
		if preview.Parent == nil then
			preview:Destroy()
		end
	end

	for _, name in ipairs({ "Core", "Presets", "UI" }) do
		local newFolder = preview:FindFirstChild(name)
		local oldFolder = self.root:FindFirstChild(name)
		if not newFolder then
			rollback()
			return false, "The build is missing the " .. name .. " folder."
		end
		if not oldFolder then
			rollback()
			return false, "The installed plugin is missing the " .. name .. " folder."
		end
		oldFolder.Name = name .. "__previous"
		newFolder.Name = name
		newFolder.Parent = self.root
		table.insert(swapped, { old = oldFolder, new = newFolder, name = name })
	end

	-- Verify the new build actually loads before deleting the old one.
	local ok, err = pcall(function()
		local ui = self.root:FindFirstChild("UI")
		return require(ui.App)
	end)
	if not ok then
		rollback()
		local message = "The new build failed to load: " .. tostring(err)
		self:setState("error", message)
		return false, message
	end

	for _, item in ipairs(swapped) do
		item.old:Destroy()
	end
	preview:Destroy()

	self.appliedManifest = manifest
	self.appliedVersion = Version.clean(manifest.version)
	self:setState("ready", "Updated to v" .. self.appliedVersion .. ".")
	return true, nil
end

--------------------------------------------------------------------------------
-- persistence
--------------------------------------------------------------------------------

--- Rebuilds the model and opens Studio's save dialog. Studio has no API that
--- writes plugin files directly, so this is the only persistence path.
function Updater:saveToDisk(manifest: any): (boolean, string?)
	local target = manifest or self.appliedManifest
	if not target then
		return false, "Update first, or check for updates."
	end
	if self.tempHolder then
		self:cleanupTemp()
	end

	local tree = Updater.buildTree(target)
	local holder = Instance.new("Folder")
	holder.Name = "VFXStudio Update (delete after saving)"
	tree.Parent = holder
	holder.Parent = ServerStorage
	self.tempHolder = holder

	local previous = Selection:Get()
	Selection:Set({ tree })

	local ok, err = pcall(function()
		if self.plugin and self.plugin.PromptSaveSelection then
			self.plugin:PromptSaveSelection(Version.MODEL_ASSET)
		elseif self.plugin and self.plugin.SaveSelectedToFile then
			self.plugin:SaveSelectedToFile(Version.MODEL_ASSET)
		else
			error("this Studio build has no save-selection API")
		end
	end)
	Selection:Set(previous)

	if not ok then
		return false, tostring(err)
	end
	return true, nil
end

function Updater:cleanupTemp()
	if self.tempHolder then
		pcall(function()
			self.tempHolder:Destroy()
		end)
		self.tempHolder = nil
	end
end

function Updater:destroy()
	self:cleanupTemp()
	self.signals:clear()
end

return Updater
