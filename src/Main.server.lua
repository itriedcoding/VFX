--[[
	VFX Studio - plugin entry point.

	Creates the toolbar button and the dock widget, then hands control to the
	App shell. The UI folder is resolved at start time (not captured) so the
	in-Studio updater can replace Core/Presets/UI and the editor can be rebuilt
	against the new modules without restarting Studio.
]]

local TOOLBAR_NAME = "VFX Studio"
local WIDGET_ID = "VFXStudioMain"

local toolbar = plugin:CreateToolbar(TOOLBAR_NAME)
local button = toolbar:CreateButton(
	"VFX Studio",
	"Open the VFX Studio effect editor",
	"rbxasset://textures/particles/sparkles_main.dds"
)
button.ClickableWhenViewportHidden = true

local widgetInfo = DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Float,
	false,
	false,
	1180,
	780,
	860,
	560
)
local widget = plugin:CreateDockWidgetPluginGui(WIDGET_ID, widgetInfo)
widget.Title = "VFX Studio"
widget.Name = "VFX Studio"
widget.Enabled = false

local app = nil

local function showFatalError(message: string)
	pcall(function()
		for _, child in ipairs(widget:GetChildren()) do
			child:Destroy()
		end
	end)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundColor3 = Color3.fromRGB(9, 11, 16)
	frame.BorderSizePixel = 0
	frame.Parent = widget

	local title = Instance.new("TextLabel")
	title.BackgroundTransparency = 1
	title.Position = UDim2.fromOffset(24, 24)
	title.Size = UDim2.new(1, -48, 0, 24)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 18
	title.TextColor3 = Color3.fromRGB(248, 113, 113)
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Text = "VFX Studio could not start"
	title.Parent = frame

	local body = Instance.new("TextLabel")
	body.BackgroundTransparency = 1
	body.Position = UDim2.fromOffset(24, 58)
	body.Size = UDim2.new(1, -48, 1, -90)
	body.Font = Enum.Font.Code
	body.TextSize = 13
	body.TextWrapped = true
	body.TextYAlignment = Enum.TextYAlignment.Top
	body.TextXAlignment = Enum.TextXAlignment.Left
	body.TextColor3 = Color3.fromRGB(233, 238, 247)
	body.Text = message
	body.Parent = frame
end

-- Re-resolved on every (re)start so a hot update is picked up.
local function resolveUI(): Instance?
	return script.Parent and script.Parent:FindFirstChild("UI")
end

local buildApp

local function restart()
	if app then
		local ok = pcall(function()
			app:destroy()
		end)
		if not ok then
			warn("[VFX Studio] previous editor failed to shut down cleanly")
		end
		app = nil
	end
	local ok, result = pcall(buildApp)
	if ok then
		app = result
	else
		warn("[VFX Studio] rebuild after update failed: " .. tostring(result))
		showFatalError("The updated editor failed to start.\n\n" .. tostring(result) .. "\n\nReplace the plugin file with the previous version, or open the Output window for the traceback.")
	end
end

buildApp = function()
	local ui = resolveUI()
	if not ui then
		error("the UI folder is missing from the plugin")
	end
	local App = require(ui.App)
	return App.new(plugin, widget, script.Parent, restart)
end

local function ensureApp(): boolean
	if app then
		return true
	end
	local ok, result = pcall(buildApp)
	if not ok then
		warn("[VFX Studio] startup failed: " .. tostring(result))
		showFatalError(tostring(result) .. "\n\nOpen the Output window for the full traceback.")
		return false
	end
	app = result
	return true
end

local function toggle()
	if not ensureApp() then
		widget.Enabled = true
		return
	end
	widget.Enabled = not widget.Enabled
	button:SetActive(widget.Enabled)
end

button.Click:Connect(toggle)

widget:GetPropertyChangedSignal("Enabled"):Connect(function()
	button:SetActive(widget.Enabled)
end)

plugin.Unloading:Connect(function()
	if app then
		local ok, err = pcall(function()
			app:destroy()
		end)
		if not ok then
			warn("[VFX Studio] cleanup error: " .. tostring(err))
		end
		app = nil
	end
end)

-- Studio remembers whether the widget was open; do not force it open on load.
if widget.Enabled then
	ensureApp()
end

warn("[VFX Studio] loaded. Click the VFX Studio button in the Plugins tab to open the editor.")
