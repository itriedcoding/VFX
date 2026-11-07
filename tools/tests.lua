--------------------------------------------------------------------------------
-- tests
--------------------------------------------------------------------------------

section("preset library")
local Presets = require(root.Presets)
check(#Presets.all >= 300, string.format("expected 300+ presets, got %d", #Presets.all))
checkEqual(#Presets.errors, 0, "preset validation errors: " .. table.concat(Presets.errors, " | "))
checkEqual(#Presets.categories, 14, "category count")
print(string.format("  %d presets across %d categories, %d tags", #Presets.all, #Presets.categories, #Presets.tagList))

local seenIds = {}
local seenNames = {}
local duplicateNames = {}
for _, spec in ipairs(Presets.all) do
	check(seenIds[spec.id] == nil, "duplicate preset id " .. tostring(spec.id))
	seenIds[spec.id] = true
	if seenNames[spec.name] then
		table.insert(duplicateNames, spec.category .. "/" .. tostring(spec.name))
	end
	seenNames[spec.name] = true
	check(type(spec.description) == "string" and #spec.description > 10, "missing description for " .. spec.name)
	check(#spec.tags > 0, "missing tags for " .. spec.name)
	check(spec.duration > 0, "invalid duration for " .. spec.name)
end

checkEqual(#duplicateNames, 0, "duplicate preset names: " .. table.concat(duplicateNames, ", "))

local categoryTotal = 0
for _, category in ipairs(Presets.categories) do
	categoryTotal += category.count
	check(category.count > 0, "empty category " .. category.name)
end
checkEqual(categoryTotal, #Presets.all, "category counts sum to the library size")

section("compiling every preset")
local Compiler = require(root.Core.Compiler)
local Assets = require(root.Core.Assets)
local ScriptGenerator = require(root.Core.ScriptGenerator)
local compiled = 0
local totalComponents = 0

for _, spec in ipairs(Presets.all) do
	local ok, model = pcall(Compiler.build, spec)
	check(ok, "compile failed for " .. spec.id .. ": " .. tostring(model))
	local bindings = Compiler.resolve(model)

	local expected = 0
	for _, comp in ipairs(spec.components) do
		if comp.kind ~= "tween" then
			expected += 1
		end
		if comp.kind == "particle" or comp.kind == "beam" or comp.kind == "trail" then
			check(Assets.resolve(comp.texture) ~= "", "unresolved texture in " .. spec.id)
		end
	end

	local actual = 0
	for _, entry in pairs(bindings) do
		if entry.kind ~= "tween" then
			actual += 1
		end
	end
	checkEqual(actual, expected, "component count for " .. spec.id)

	local stored = Compiler.readSpec(model)
	check(stored ~= nil, "spec attribute missing for " .. spec.id)
	if stored then
		checkEqual(#stored.components, #spec.components, "round-trip component count for " .. spec.id)
		checkEqual(stored.name, spec.name, "round-trip name for " .. spec.id)
	end

	local source = ScriptGenerator.generate(spec)
	local chunk = loadstring(source)
	check(chunk ~= nil, "generated controller for " .. spec.id .. " is invalid Luau")

	compiled += 1
	totalComponents += #spec.components
	model:Destroy()
end
print(string.format("  compiled %d presets (%d components) with zero property errors", compiled, totalComponents))

section("decompile round-trip")
local Decompiler = require(root.Core.Decompiler)
local importedCount = 0
for index = 1, 24 do
	local spec = Presets.all[index]
	local model = Compiler.build(spec)
	model:SetAttribute("VFXSpec", nil) -- force the property-scanning path
	local imported = Decompiler.fromInstance(model)
	check(imported ~= nil, "decompile returned nil for " .. spec.id)
	if imported then
		check(#imported.components > 0, "decompile found no components for " .. spec.id)
		for _, comp in ipairs(imported.components) do
			check(comp.name ~= nil and comp.name ~= "", "decompiled component without a name in " .. spec.id)
			check(comp.kind ~= nil, "decompiled component without a kind in " .. spec.id)
		end
		local okRebuild, rebuilt = pcall(Compiler.build, imported)
		check(okRebuild, "could not rebuild decompiled spec for " .. spec.id .. ": " .. tostring(rebuilt))
		if okRebuild then
			rebuilt:Destroy()
		end
		importedCount += 1
	end
	model:Destroy()
end
print(string.format("  decompiled and recompiled %d effects", importedCount))

section("performance analysis")
local Performance = require(root.Core.Performance)
for _, spec in ipairs(Presets.all) do
	local report = Performance.analyze(spec)
	check(report.score >= 0 and report.score <= 100, "score out of range for " .. spec.id)
	check(report.alive >= 0, "negative particle estimate for " .. spec.id)
	check(report.grade == "A" or report.grade == "B" or report.grade == "C" or report.grade == "D", "bad grade for " .. spec.id)
end
local sampleReport = Performance.analyze(Presets.all[1])
print(string.format("  first preset grades %s (%d/100, ~%d particles alive)", sampleReport.grade, math.floor(sampleReport.score), math.floor(sampleReport.alive)))

section("store + persistence")
local Store = require(root.Core.Store)
local settings = {}
local fakePlugin = {
	GetSetting = function(_, key)
		return settings[key]
	end,
	SetSetting = function(_, key, value)
		settings[key] = value
	end,
}

local store = Store.new(fakePlugin, Presets)
store:applyPreset(Presets.all[5])
checkEqual(store:working().name, Presets.all[5].name, "applyPreset name")

store:setField(1, "rate", 42, true)
checkEqual(store:working().components[1].rate, 42, "setField rate")
store:undo()
check(store:working().components[1].rate ~= 42, "undo restored the old rate")
store:redo()
checkEqual(store:working().components[1].rate, 42, "redo restored the new rate")

local before = #store:working().components
store:addComponent("beam")
checkEqual(#store:working().components, before + 1, "addComponent")
store:duplicateComponent(store.selection)
checkEqual(#store:working().components, before + 2, "duplicateComponent")
store:removeComponent(store.selection)
checkEqual(#store:working().components, before + 1, "removeComponent")

store:toggleFavorite(Presets.all[1].id)
check(store:isFavorite(Presets.all[1].id), "favourite toggled on")

local saved = store:saveCustomPreset("Harness Effect")
check(saved ~= nil, "saveCustomPreset returned nil")
checkEqual(#store:customPresets(), 1, "custom preset count")
store:save()
check(type(settings["VFXStudio.state.v2"]) == "string", "settings were not persisted")

local store2 = Store.new(fakePlugin, Presets)
checkEqual(#store2:customPresets(), 1, "custom preset survived a reload")
check(store2:isFavorite(Presets.all[1].id), "favourite survived a reload")
checkEqual(store2:customPresets()[1].name, "Harness Effect", "custom preset name survived a reload")

local results = store2:search("fire", { category = "All" })
check(#results > 0, "search found no fire presets")
local customResults = store2:search("Harness", { category = "Custom" })
checkEqual(#customResults, 1, "custom preset search")

section("export")
local Exporter = require(root.Core.Exporter)
local exported, exportError = Exporter.export(Presets.all[2], {
	destination = "ReplicatedStorage",
	withController = true,
})
check(exported ~= nil, "export failed: " .. tostring(exportError))
check(exported.Parent ~= nil, "exported model was not parented")
local controller = exported:FindFirstChild("VFXController")
check(controller ~= nil, "controller ModuleScript missing")
if controller then
	check(string.find(controller.Source, "VFX.play", 1, true) ~= nil, "controller has no play API")
	check(loadstring(controller.Source) ~= nil, "exported controller is invalid Luau")
end
check(exported:FindFirstChild("README") ~= nil, "README missing")
check(exported:GetAttribute("VFXSpec") ~= nil, "exported model has no spec attribute")
exported:Destroy()

local issues = Exporter.validate(Presets.all[3])
check(#issues > 0, "validate returned no issues")

section("module wiring")
for _, name in ipairs({ "Core.Util", "Core.Format", "Core.Compiler", "Core.Performance", "Core.ScriptGenerator", "Core.Decompiler", "Core.Exporter", "Core.Store", "Core.History", "Core.Assets", "Core.Player", "Core.Theme", "Presets.DSL", "Presets" }) do
	local segments = split(name, ".")
	local node = root
	local walked = {}
	for _, segment in ipairs(segments) do
		table.insert(walked, segment)
		local nextNode = if node then functions.FindFirstChild(node, segment) else nil
		check(nextNode ~= nil, "module not found: " .. name .. " (at " .. table.concat(walked, ".") .. ")")
		node = nextNode
	end
end

section("version")
local Version = require(root.Core.Version)
checkEqual(Version.compare("1.0.0", "1.0.0"), 0, "equal versions compare equal")
checkEqual(Version.compare("1.2.0", "1.1.9"), 1, "higher minor is newer")
checkEqual(Version.compare("1.0.0", "1.0.1"), -1, "lower patch is older")
checkEqual(Version.compare("1.0.0-beta.1", "1.0.0"), -1, "prerelease sorts below its release")
checkEqual(Version.clean("v2.3.4"), "2.3.4", "clean strips a leading v")
check(Version.isNewer("1.0.1", "1.0.0"), "1.0.1 is newer than 1.0.0")
check(not Version.isNewer("1.0.0", "1.0.0"), "equal versions are not newer")
check(Version.parse("not-a-version") == nil, "garbage does not parse")
print("  " .. Version.display(Version.VERSION) .. " parses, compares and formats correctly")

section("updater")
local Updater = require(root.Core.Updater)

local function stubFile(path: string, name: string, source: string): any
	return { path = path, name = name, class = "ModuleScript", source = source }
end

local manifest = {
	version = "1.0.1",
	files = {
		stubFile("Core/Version", "Version", "return { VERSION = '1.0.1' }"),
		stubFile("Presets/init", "Presets", "return { count = 0 }"),
		stubFile("UI/App", "App", "return { stub = true, version = '1.0.1' }"),
		{ path = "Main.server", name = "Main", class = "Script", source = "return nil" },
	},
}

local valid, problem = Updater.validateManifest(manifest)
check(valid, "a well-formed manifest validates: " .. tostring(problem))

local missingUI = { version = "1.0.1", files = { stubFile("Core/Version", "Version", "return {}"), stubFile("Presets/init", "Presets", "return {}") } }
check(not Updater.validateManifest(missingUI), "a manifest without the UI folder is rejected")

local badClass = {
	version = "1.0.1",
	files = {
		stubFile("Core/Version", "Version", "return {}"),
		stubFile("Presets/init", "Presets", "return {}"),
		{ path = "UI/App", name = "App", class = "LocalScript", source = "" },
	},
}
check(not Updater.validateManifest(badClass), "LocalScripts are rejected")

local traversal = {
	version = "1.0.1",
	files = {
		stubFile("Core/Version", "Version", "return {}"),
		stubFile("Presets/init", "Presets", "return {}"),
		stubFile("UI/App", "App", "return {}"),
		stubFile("UI/../../evil", "evil", "return {}"),
	},
}
check(not Updater.validateManifest(traversal), "path traversal is rejected")

local tree = Updater.buildTree(manifest)
checkEqual(tree.Name, "VFXStudio", "built tree root name")
check(tree:FindFirstChild("Core"):FindFirstChild("Version") ~= nil, "built tree contains Core.Version")
check(tree:FindFirstChild("UI"):FindFirstChild("App") ~= nil, "built tree contains UI.App")
check(tree:FindFirstChild("Main") ~= nil, "built tree contains the Main script")
check(tree:FindFirstChild("Presets"):FindFirstChild("DSL") == nil, "built tree has no stray modules")
tree:Destroy()

local pluginSettings = {}
local fakeUpdatePlugin = {
	GetSetting = function(_, key)
		return pluginSettings[key]
	end,
	SetSetting = function(_, key, value)
		pluginSettings[key] = value
	end,
	PromptSaveSelection = function() end,
}

local pluginRoot = makeNode("VFXStudio", "Folder", nil)
local oldCore = makeNode("Core", "Folder", pluginRoot)
makeNode("Util", "ModuleScript", oldCore).Source = "return { old = true }"
local oldPresets = makeNode("Presets", "Folder", pluginRoot)
makeNode("Presets", "ModuleScript", oldPresets).Source = "return {}"
local oldUI = makeNode("UI", "Folder", pluginRoot)
makeNode("App", "ModuleScript", oldUI).Source = "return { stub = true, version = '1.0.0' }"

local updater = Updater.new(fakeUpdatePlugin, pluginRoot)
checkEqual(updater:installedVersion(), Version.VERSION, "installed version starts at the build version")
check(updater:hasUpdate() == false, "no update before a check")

local appliedOk, applyError = updater:apply(manifest)
check(appliedOk, "apply failed: " .. tostring(applyError))
check(pluginRoot:FindFirstChild("Core"):FindFirstChild("Version") ~= nil, "Core folder was swapped")
check(pluginRoot:FindFirstChild("UI"):FindFirstChild("App") ~= nil, "UI folder was swapped")
check(require(pluginRoot.UI.App).stub == true, "the new App module loads")
checkEqual(updater.appliedVersion, "1.0.1", "applied version is recorded")
check(pluginRoot:FindFirstChild("Core__previous") == nil, "old folders are removed after a good update")

local broken = {
	version = newerVersion,
	files = {
		stubFile("Core/Version", "Version", "return {}"),
		stubFile("Presets/init", "Presets", "return {}"),
		stubFile("UI/App", "App", "error('boom')"),
	},
}
local brokenOk, brokenError = updater:apply(broken)
check(not brokenOk, "a build that fails to load must not apply")
check(string.find(tostring(brokenError), "failed to load", 1, true) ~= nil, "the failure explains itself")
checkEqual(pluginRoot:FindFirstChild("UI").Name, "UI", "UI folder restored after rollback")
check(pluginRoot:FindFirstChild("UI__previous") == nil, "no half-swapped folders remain")
checkEqual(require(pluginRoot.UI.App).version, "1.0.1", "the previous build still loads")

MOCK_HTTP.responses[Version.API_URL] = {
	Success = true,
	StatusCode = 200,
	Body = MOCK_JSON_ENCODE({
		tag_name = "v1.0.1",
		body = "Fixed things.",
		html_url = "https://example.com/release",
		assets = {
			{ name = "manifest.json", browser_download_url = "https://example.com/manifest.json" },
			{ name = "VFXStudio.rbxmx", browser_download_url = "https://example.com/VFXStudio.rbxmx" },
			{ name = "VFXStudio.zip", browser_download_url = "https://example.com/VFXStudio.zip" },
			{ name = "notes.md", browser_download_url = "http://insecure.example.com/notes.md" },
		},
	}),
}
local info = updater:check()
check(info ~= nil, "check returns release info")
checkEqual(info.version, "1.0.1", "check reads the release tag")
checkEqual(info.manifestUrl, "https://example.com/manifest.json", "check finds the manifest asset")
checkEqual(info.download.zip, "https://example.com/VFXStudio.zip", "check finds the plugin zip asset")
checkEqual(info.download.model, "https://example.com/VFXStudio.rbxmx", "check finds the plugin model asset")
checkEqual(info.download.page, "https://example.com/release", "check links the release page")
check(updater:hasUpdate() == false, "the applied version is not offered again")
check(not updater:shouldAutoCheck(), "automatic checks are throttled after one check")

checkEqual(Updater.downloadLinks(nil).model, Version.MODEL_URL, "download links fall back to the stable release URLs")
checkEqual(Updater.downloadLinks(nil).zip, Version.PLUGIN_ZIP_URL, "the plugin zip has a stable release URL")
checkEqual(
	Updater.downloadLinks({ download = { zip = "http://insecure.example.com/z.zip" } }).zip,
	Version.PLUGIN_ZIP_URL,
	"non-https download links are ignored"
)
checkEqual(
	Updater.downloadLinks({ download = { model = "https://example.com/custom.rbxmx" } }).model,
	"https://example.com/custom.rbxmx",
	"a manifest can override the download link"
)

MOCK_HTTP.responses["https://example.com/manifest.json"] = { Success = true, StatusCode = 200, Body = MOCK_JSON_ENCODE(manifest) }
local downloaded, downloadError = updater:downloadManifest()
check(downloaded == nil, "a manifest that is not newer is rejected")
check(type(downloadError) == "string", "the rejection explains itself")

local throttled = Updater.new(fakeUpdatePlugin, pluginRoot)
check(not throttled:shouldAutoCheck(), "a reopened editor honours the check cache")
throttled:setAutoCheck(false)
check(not throttled:shouldAutoCheck(), "auto check can be disabled")
throttled:setAutoCheck(true)

local savedOk, savedError = updater:saveToDisk(manifest)
check(savedOk, "saveToDisk failed: " .. tostring(savedError))
check(updater.tempHolder ~= nil, "saveToDisk builds a temporary model")
updater:cleanupTemp()
check(updater.tempHolder == nil, "the temporary model is cleaned up")

local newerVersion = string.gsub(Version.VERSION, "(%d+)%.(%d+)%.(%d+)", function(major, minor, patch)
	return major .. "." .. minor .. "." .. tostring(tonumber(patch) + 1)
end)

MOCK_HTTP.responses = {}
MOCK_HTTP.responses[Version.API_URL] = { Success = false, StatusCode = 404, Body = "" }
MOCK_HTTP.responses[Version.FALLBACK_MANIFEST_URL] = {
	Success = true,
	StatusCode = 200,
	Body = MOCK_JSON_ENCODE({
		version = newerVersion,
		download = {
			zip = "https://example.com/build.zip",
			model = "https://example.com/build.rbxmx",
			page = "https://example.com/releases",
		},
		files = manifest.files,
	}),
}
local fallback = Updater.new(fakeUpdatePlugin, pluginRoot)
local fallbackInfo = fallback:check()
check(fallbackInfo ~= nil and fallbackInfo.source == "main", "with no release the main manifest is used")
checkEqual(fallbackInfo.download.zip, "https://example.com/build.zip", "the main manifest advertises its own zip")
checkEqual(fallbackInfo.download.page, "https://example.com/releases", "the main manifest advertises its release page")
check(fallback:hasUpdate(), "a newer main build is offered as an update")

MOCK_HTTP.responses = {}
local offline = Updater.new(fakeUpdatePlugin, pluginRoot)
local offlineInfo = offline:check()
check(offlineInfo == nil, "an offline check returns nothing")
checkEqual(offline.state, "error", "an offline check reports an error state")
check(type(offline.lastError) == "string" and #offline.lastError > 10, "the offline error is human readable")
print("  manifest validation, download links, hot swap, rollback, save and offline handling verified")

section("warnings")
checkEqual(#warnings, 0, "engine warnings: " .. table.concat(warnings, " | "))

section("editor ui")

local uiSettings = {}
local widgetNode = makeNode("VFX Studio", "DockWidgetPluginGui", nil)
widgetNode.Enabled = true
widgetNode.Title = "VFX Studio"

local uiPlugin = {
	GetSetting = function(_, key)
		return uiSettings[key]
	end,
	SetSetting = function(_, key, value)
		uiSettings[key] = value
	end,
	PromptSaveSelection = function() end,
	Unloading = {
		Connect = function()
			return { Disconnect = function() end }
		end,
	},
}

local App = require(root.UI.App)
local warningsBefore = #warnings
local okApp, app = pcall(App.new, uiPlugin, widgetNode, root, function() end)
check(okApp, "the editor shell must construct in a plugin: " .. tostring(app))
if okApp and app then
	check(app.root ~= nil and #app.root:GetChildren() > 0, "the editor built a root frame with content")
	check(app.library ~= nil, "the preset library panel built")
	for index = warningsBefore + 1, #warnings do
		print("  panel warning: " .. tostring(warnings[index]))
	end
	check(app.preview ~= nil, "the live preview built")
	check(app.timeline ~= nil, "the timeline built")
	check(app.inspector ~= nil, "the inspector built")
	check(app.store ~= nil and app.updater ~= nil, "store and updater are owned by the shell")
	check(#warnings == warningsBefore, "no panel failed to build: " .. tostring(warnings[#warnings]))

	app.store:applyPreset(Presets.all[1], "Smoke test")
	check(#app.store:working().components > 0, "applying a preset gives the editor components")
	app:refreshLayout()
	app:updateStatus()
	app:toast("Smoke test toast", "info")

	app:openExportDialog()
	check(app.modalContent ~= nil, "the export dialog opened")
	app:closeModal()
	app:openAssetPicker(nil)
	check(app.modalContent ~= nil, "the asset panel opened")
	app:closeModal()
	app:openUpdateDialog()
	check(app.modalContent ~= nil, "the update panel opened")
	app:closeModal()
	app:promptSavePreset()
	check(app.modalCard ~= nil and app.modalLayer.Visible == true, "the save-preset prompt opened")
	app:closeModal()
	check(app.modalLayer.Visible == false, "closing a modal hides the modal layer")

	-- Interactions, not just construction: every panel runs its real code path.
	app.store:select(2)
	app.store:setField(1, "rate", 12)
	app.store:setField(1, "color", "#FF8800")
	app.store:duplicateComponent(1)
	app.store:moveComponent(1, 2)
	app.store:undo()
	app.store:redo()
	app.store:removeComponent(#app.store:working().components)
	check(#app.store:working().components > 0, "component edits leave a usable effect")

	app.preview:togglePlay()
	app.preview:togglePlay()
	app.preview:restart()
	app.preview:setSpeed(2)
	app.preview:setBackground("studio")
	app.preview:frameCamera()
	app.preview:zoom(1.1)
	check(app.preview:progress() >= 0, "playback reports progress")

	local RunService = game:GetService("RunService")
	for _ = 1, 120 do
		RunService.Heartbeat:Fire(1 / 60)
	end

	app.timeline:refresh()
	app.timeline:setProgress(0.5, 1)
	app.inspector:showTab("curves")
	app.inspector:showTab("cost")
	app.inspector:showTab("properties")
	app.inspector:rebuild()
	app.library:setQuery("fire")
	app.library:refresh()
	app.library:setQuery("")
	app.library:refresh()

	app:openAssetPicker(nil)
	if app.modalContent then
		app.modalContent:render()
		check(#app.modalContent:visibleAssets() > 0, "the asset panel lists textures")
	end
	app:closeModal()

	app:openExportDialog()
	if app.modalContent then
		app.modalContent:render()
	end
	app:closeModal()

	app:openUpdateDialog()
	if app.modalContent then
		app.modalContent:refresh()
	end
	app:closeModal()

	for index = warningsBefore + 1, #warnings do
		print("  ui warning: " .. tostring(warnings[index]))
	end
	check(#warnings == warningsBefore, "no UI interaction warned")

	app:destroy()
	check(#widgetNode:GetChildren() == 0, "closing the editor removes its widget contents")
end

print(string.format("\n%d checks passed, 0 failures", checks))

print("HARNESS OK")
