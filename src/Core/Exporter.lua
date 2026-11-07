--[[
	Exporter - writes real effects into the place and keeps Studio's undo
	history intact.

	An export is a Model containing:
	  * the compiled rig (parts, attachments, emitters, beams, trails, lights)
	  * a "VFXController" ModuleScript that plays it at runtime
	  * the full spec as a VFXSpec attribute (re-importable and editable)
]]

local Util = require(script.Parent.Util)
local Compiler = require(script.Parent.Compiler)
local ScriptGenerator = require(script.Parent.ScriptGenerator)
local Performance = require(script.Parent.Performance)
local History = require(script.Parent.History)
local Assets = require(script.Parent.Assets)

local Exporter = {}

Exporter.DESTINATIONS = {
	{ name = "ReplicatedStorage", label = "ReplicatedStorage", service = "ReplicatedStorage" },
	{ name = "ServerStorage", label = "ServerStorage", service = "ServerStorage" },
	{ name = "Workspace", label = "Workspace", service = "Workspace" },
}

function Exporter.destination(name: string): Instance
	for _, entry in ipairs(Exporter.DESTINATIONS) do
		if entry.name == name then
			return game:GetService(entry.service)
		end
	end
	return game:GetService("ReplicatedStorage")
end

--- Pre-flight checks. Returns a list of { severity, message }.
function Exporter.validate(spec: any): { any }
	local issues = {}
	if type(spec) ~= "table" or type(spec.components) ~= "table" or #spec.components == 0 then
		table.insert(issues, { severity = "high", message = "The effect has no components." })
		return issues
	end

	local report = Performance.analyze(spec)
	if report.alive > 2000 then
		table.insert(issues, {
			severity = "high",
			message = string.format("About %d concurrent particles - well above the 2000 budget.", math.floor(report.alive)),
		})
	elseif report.alive > 900 then
		table.insert(issues, {
			severity = "medium",
			message = string.format("About %d concurrent particles - consider optimising.", math.floor(report.alive)),
		})
	end

	for _, comp in ipairs(spec.components) do
		if comp.kind == "particle" and type(comp.texture) ~= "string" then
			table.insert(issues, { severity = "high", message = tostring(comp.name) .. " has no texture." })
		elseif comp.kind == "particle" and Assets.isRemote(tostring(comp.texture)) then
			table.insert(issues, {
				severity = "low",
				message = tostring(comp.name) .. " uses a marketplace texture; verify it is still owned by the experience.",
			})
		end
	end

	if #issues == 0 then
		table.insert(issues, { severity = "ok", message = "All checks passed." })
	end
	return issues
end

local function uniqueModelName(parent: Instance, base: string): string
	local name = base
	local index = 2
	while parent:FindFirstChild(name) do
		name = base .. " (" .. index .. ")"
		index += 1
	end
	return name
end

--- Compiles and parents an effect model, wrapping the change in undo history.
--- `options`: { destination = "ReplicatedStorage"|"ServerStorage"|"Workspace",
---              name = string, withController = boolean, parent = Instance }
function Exporter.export(spec: any, options: any?): (Model?, string?)
	local opts = options or {}
	local destination = opts.parent or Exporter.destination(opts.destination or "ReplicatedStorage")
	if not destination then
		return nil, "No destination selected."
	end

	local requestedName = Util.trim(tostring(opts.name or spec.name or "VFX Effect"))
	if requestedName == "" then
		requestedName = "VFX Effect"
	end

	local recording = History.beginRecording("VFX Studio Export")
	local ok, result = pcall(function()
		local model = Compiler.build(spec, nil)
		model.Name = uniqueModelName(destination, requestedName)
		model.Parent = destination

		if opts.withController ~= false then
			local controller = Instance.new("ModuleScript")
			controller.Name = "VFXController"
			controller.Source = ScriptGenerator.generate(spec)
			controller.Parent = model
		end

		-- A short README so the exported folder is self-explanatory.
		local readme = Instance.new("StringValue")
		readme.Name = "README"
		readme.Value = table.concat({
			"VFX Studio export: " .. tostring(spec.name),
			"Controller: VFXController (ModuleScript)",
			"  local VFX = require(script.Parent.VFXController)",
			"  local handle = VFX.play(CFrame.new(0, 5, 0))",
			"  handle:Play() / handle:Pause() / handle:Destroy()",
			"Re-import this model with VFX Studio to keep editing it.",
		}, "\n")
		readme.Parent = model

		return model
	end)

	if not ok then
		History.endRecording(recording, false)
		return nil, "Export failed: " .. tostring(result)
	end

	History.endRecording(recording, true)
	return result, nil
end

--- Saves the effect as a .rbxm model file on disk via Studio's save dialog.
function Exporter.saveToFile(spec: any, pluginInstance: Plugin?): (boolean, string?)
	local model = Compiler.build(spec, nil)
	local controller = Instance.new("ModuleScript")
	controller.Name = "VFXController"
	controller.Source = ScriptGenerator.generate(spec)
	controller.Parent = model
	model.Parent = nil

	local previous = Util.Selection:Get()
	Util.Selection:Set({ model })
	local ok, err = pcall(function()
		if pluginInstance and pluginInstance.PromptSaveSelection then
			pluginInstance:PromptSaveSelection((spec.name or "VFX Effect") .. ".rbxm")
		elseif pluginInstance and pluginInstance.SaveSelectedToFile then
			pluginInstance:SaveSelectedToFile((spec.name or "VFX Effect") .. ".rbxm")
		else
			error("this Studio build does not expose PromptSaveSelection")
		end
	end)
	Util.Selection:Set(previous)
	model:Destroy()

	if not ok then
		return false, tostring(err)
	end
	return true, nil
end

--- Places the effect at the camera/selection for an immediate look.
function Exporter.insertIntoWorkspace(spec: any): (Model?, string?)
	return Exporter.export(spec, { destination = "Workspace", withController = false })
end

--- Re-inserts an imported spec so the user can compare before/after.
function Exporter.replaceModel(spec: any, existing: Instance?): (Model?, string?)
	if not existing or not existing.Parent then
		return Exporter.insertIntoWorkspace(spec)
	end
	local parent = existing.Parent
	local name = existing.Name
	local recording = History.beginRecording("VFX Studio Replace")
	existing:Destroy()
	local model, err = Exporter.export(spec, { parent = parent, name = name })
	History.endRecording(recording, true)
	return model, err
end

return Exporter
