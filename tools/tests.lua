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
	version = "1.0.2",
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
		assets = { { name = "manifest.json", browser_download_url = "https://example.com/manifest.json" } },
	}),
}
local info = updater:check()
check(info ~= nil, "check returns release info")
checkEqual(info.version, "1.0.1", "check reads the release tag")
checkEqual(info.manifestUrl, "https://example.com/manifest.json", "check finds the manifest asset")
check(updater:hasUpdate() == false, "the applied version is not offered again")
check(not updater:shouldAutoCheck(), "automatic checks are throttled after one check")

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

MOCK_HTTP.responses = {}
local offline = Updater.new(fakeUpdatePlugin, pluginRoot)
local offlineInfo = offline:check()
check(offlineInfo == nil, "an offline check returns nothing")
checkEqual(offline.state, "error", "an offline check reports an error state")
check(type(offline.lastError) == "string" and #offline.lastError > 10, "the offline error is human readable")
print("  manifest validation, hot swap, rollback, save and offline handling verified")

section("warnings")
checkEqual(#warnings, 0, "engine warnings: " .. table.concat(warnings, " | "))

print(string.format("\n%d checks passed, 0 failures", checks))
print("HARNESS OK")
