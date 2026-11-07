--[[
	ScriptGenerator - writes the Luau controller that ships with every exported
	effect.

	The generated ModuleScript is self-contained: it embeds the effect's
	timeline and drives the real instances with the same semantics as the
	editor's preview (enabled windows, bursts, repeats, loops and tween tracks).
]]

local Format = require(script.Parent.Format)

local ScriptGenerator = {}

local RUNTIME_TEMPLATE = [==[
--!nonstrict
--[[
	VFX Studio controller for "{{NAME}}"
	Generated {{VERSION}} - do not edit the timeline table by hand; re-export
	from the studio instead.

	Usage (client or server):
		local VFX = require(script.Parent)          -- this ModuleScript
		local handle = VFX.play(CFrame.new(0, 5, 0))
		handle:Pause()      -- stop emitting, let live particles fade
		handle:Play()       -- resume
		handle:Destroy()    -- clean up

		VFX.attach(workspace.SomePart)              -- follow a part
		VFX.playOnce()                              -- fire and forget
]]

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local TIMELINE = {{TIMELINE}}
local DURATION = {{DURATION}}
local LOOPING = {{LOOP}}
local PRESET_NAME = "{{NAME}}"

local Effect = script.Parent
local VFX = {}
VFX.presetName = PRESET_NAME
VFX.duration = DURATION
VFX.looping = LOOPING

local function resolveRig(model)
	for _, child in ipairs(model:GetChildren()) do
		if child:IsA("BasePart") and child.Name == "Rig" then
			return child
		end
	end
	return model:FindFirstChildWhichIsA("BasePart", true)
end

local function bindingsOf(model)
	local map = {}
	for _, descendant in ipairs(model:GetDescendants()) do
		local name = descendant:GetAttribute("VFXComponent")
		if name then
			map[name] = map[name] or {}
			table.insert(map[name], descendant)
			if descendant:IsA("ParticleEmitter")
				or descendant:IsA("Beam")
				or descendant:IsA("Trail")
				or descendant:IsA("PointLight")
				or (descendant:IsA("BasePart") and descendant.Name ~= "Rig")
			then
				map[name].primary = descendant
			end
		end
	end
	return map
end

local function setEnabled(entry, enabled)
	if not entry or not entry.primary then
		return
	end
	local target = entry.primary
	if target:IsA("ParticleEmitter") or target:IsA("Beam") or target:IsA("Trail") or target:IsA("PointLight") then
		target.Enabled = enabled
	end
end

local function fireBurst(entry, count)
	if not entry or not entry.primary or not entry.primary:IsA("ParticleEmitter") then
		return
	end
	if count > 0 then
		entry.primary:Emit(count)
	end
end

local function resetAll(model, bindings)
	for _, comp in ipairs(TIMELINE) do
		local entry = bindings[comp.name]
		if entry and entry.primary then
			if entry.primary:IsA("ParticleEmitter") then
				entry.primary.Enabled = false
				entry.primary:Clear()
			elseif entry.primary:IsA("ParticleEmitter") then
				entry.primary.Enabled = false
			end
		end
	end
end

local function runComponent(model, bindings, comp, token, state)
	local entry = bindings[comp.name]
	if not entry then
		return
	end

	if comp.kind == "tween" then
		local target = model:FindFirstChild("Rig")
		if comp.target ~= "rig" and bindings[comp.target] then
			target = bindings[comp.target].primary
		end
		if target then
			local style = Enum.EasingStyle[comp.easing] or Enum.EasingStyle.Quad
			local direction = Enum.EasingDirection[comp.direction] or Enum.EasingDirection.Out
			local info = TweenInfo.new(comp.duration, style, direction, comp.repeatCount, comp.reverse)
			if comp.property == "spin" and target:IsA("BasePart") then
				local base = target.CFrame
				target.CFrame = base * CFrame.Angles(0, math.rad(comp.from), 0)
				local tween = TweenService:Create(target, info, { CFrame = base * CFrame.Angles(0, math.rad(comp.to), 0) })
				tween:Play()
				table.insert(state.tweens, tween)
			elseif comp.property == "float" and target:IsA("BasePart") then
				local base = target.CFrame
				target.CFrame = base * CFrame.new(0, comp.from, 0)
				local tween = TweenService:Create(target, info, { CFrame = base * CFrame.new(0, comp.to, 0) })
				tween:Play()
				table.insert(state.tweens, tween)
			elseif comp.property == "brightness" and target:IsA("PointLight") then
				target.Brightness = comp.from
				local tween = TweenService:Create(target, info, { Brightness = comp.to })
				tween:Play()
				table.insert(state.tweens, tween)
			elseif comp.property == "transparency" and target:IsA("BasePart") then
				target.Transparency = comp.from
				local tween = TweenService:Create(target, info, { Transparency = comp.to })
				tween:Play()
				table.insert(state.tweens, tween)
			elseif comp.property == "scale" and target:IsA("BasePart") then
				local base = target.Size
				target.Size = base * math.max(0.01, comp.from)
				local tween = TweenService:Create(target, info, { Size = base * math.max(0.01, comp.to) })
				tween:Play()
				table.insert(state.tweens, tween)
			end
		end
		return
	end

	local start = math.max(0, comp.startTime) / state.speed
	if start > 0 then
		task.wait(start)
	end
	if token ~= state.token then
		return
	end

	local duration = math.max(0, comp.duration) / state.speed
	local repeats = math.max(1, math.floor(comp.repeats or 1))
	local isBurst = (comp.burst or 0) > 0
	local isContinuous = (comp.rate or 0) > 0

	if isBurst and repeats > 1 and duration > 0 then
		local interval = duration / repeats
		for index = 1, repeats do
			if token ~= state.token then
				return
			end
			fireBurst(entry, math.floor(comp.burst))
			if index < repeats then
				task.wait(math.max(0.02, interval))
			end
		end
		return
	end

	if isBurst then
		fireBurst(entry, math.floor(comp.burst))
	end
	if isContinuous then
		setEnabled(entry, true)
	end
	if duration > 0 then
		task.wait(duration)
	end
	if token ~= state.token then
		return
	end
	if isContinuous then
		setEnabled(entry, false)
	end
end

local Handle = {}
Handle.__index = Handle

function Handle:Play()
	if self.destroyed or self.playing then
		return self
	end
	self.playing = true
	self.token += 1
	local token = self.token
	local state = self.state
	state.token = token
	local model = self.model
	local bindings = self.bindings

	resetAll(model, bindings)

	for _, comp in ipairs(TIMELINE) do
		task.spawn(function()
			local ok, err = pcall(runComponent, model, bindings, comp, token, state)
			if not ok then
				warn("[VFX] " .. tostring(err))
			end
		end)
	end

	task.delay(DURATION / state.speed, function()
		if token ~= self.token or self.destroyed then
			return
		end
		if LOOPING then
			self.playing = false
			self:Play()
		else
			self.playing = false
		end
	end)
	return self
end

function Handle:Pause()
	self.token += 1
	self.playing = false
	for _, comp in ipairs(TIMELINE) do
		local entry = self.bindings[comp.name]
		if entry then
			setEnabled(entry, false)
		end
	end
	return self
end

function Handle:Destroy()
	self.destroyed = true
	self.token += 1
	self.playing = false
	for _, tween in ipairs(self.state.tweens) do
		pcall(function()
			tween:Cancel()
		end)
	end
	if self.connection then
		self.connection:Disconnect()
	end
	if self.model and self.model.Parent then
		self.model:Destroy()
	end
	return self
end

local function spawn(cframe, parent)
	local model = Effect:Clone()
	local rig = resolveRig(model)
	if rig then
		rig.CFrame = cframe
	end
	model.Parent = parent or workspace
	local handle = setmetatable({
		model = model,
		bindings = bindingsOf(model),
		state = { token = 0, speed = 1, tweens = {} },
		playing = false,
		destroyed = false,
		token = 0,
	}, Handle)
	return handle
end

function VFX.play(cframe, parent)
	return spawn(cframe or CFrame.new(), parent)
end

function VFX.playOnce(cframe, parent)
	local handle = spawn(cframe or CFrame.new(), parent)
	handle:Play()
	return handle
end

function VFX.attach(part)
	local handle = spawn(part.CFrame, part)
	local rig = resolveRig(handle.model)
	if rig then
		handle.connection = RunService.Heartbeat:Connect(function()
			if not part.Parent then
				handle:Destroy()
				return
			end
			rig.CFrame = part.CFrame
		end)
	end
	return handle
end

return VFX
]==]

ScriptGenerator.VERSION = "VFX Studio 1.0"

--- Serialises only what the controller needs at runtime.
function ScriptGenerator.timeline(spec: any): string
	local rows = {}
	for _, comp in ipairs(spec.components or {}) do
		table.insert(rows, string.format(
			'{ name = "%s", kind = "%s", startTime = %s, duration = %s, rate = %s, burst = %s, repeats = %s, target = "%s", property = "%s", from = %s, to = %s, easing = "%s", direction = "%s", repeatCount = %s, reverse = %s }',
			tostring(comp.name):gsub('"', "'"),
			tostring(comp.kind),
			tostring(tonumber(comp.startTime) or 0),
			tostring(tonumber(comp.duration) or 0),
			tostring(tonumber(comp.rate) or 0),
			tostring(tonumber(comp.burst) or 0),
			tostring(math.max(1, math.floor(tonumber(comp.repeats) or 1))),
			tostring(comp.target or "rig"),
			tostring(comp.property or ""),
			tostring(tonumber(comp.from) or 0),
			tostring(tonumber(comp.to) or 0),
			tostring(comp.easing or "Quad"),
			tostring(comp.direction or "Out"),
			tostring(math.floor(tonumber(comp.repeatCount) or 0)),
			tostring(comp.reverse == true)
		))
	end
	return "{\n\t" .. table.concat(rows, ",\n\t") .. "\n}"
end

--- Produces the text of the controller ModuleScript for a spec.
function ScriptGenerator.generate(spec: any): string
	local source = RUNTIME_TEMPLATE
	source = string.gsub(source, "{{NAME}}", (tostring(spec.name or "Effect"):gsub('"', "'")))
	source = string.gsub(source, "{{VERSION}}", ScriptGenerator.VERSION)
	source = string.gsub(source, "{{TIMELINE}}", ScriptGenerator.timeline(spec))
	source = string.gsub(source, "{{DURATION}}", tostring(math.max(0.1, tonumber(spec.duration) or 1.5)))
	source = string.gsub(source, "{{LOOP}}", tostring(spec.loop == true))
	return source
end

--- Short usage snippet shown next to the generated script in the UI.
function ScriptGenerator.usage(spec: any, modulePath: string?): string
	local path = modulePath or "ReplicatedStorage.VFXPresets." .. (spec.name or "Effect")
	local lines = {
		"-- Insert the effect, then control it from any script:",
		"local VFX = require(" .. path .. ")",
		"",
		"local handle = VFX.play(CFrame.new(0, 5, 0))",
		"handle:Play()      -- start",
		"handle:Pause()     -- stop emitting",
		"handle:Destroy()   -- remove the clone",
		"",
		"-- Or attach it to a moving part:",
		"VFX.attach(workspace.SomePart)",
	}
	return table.concat(lines, "\n")
end

return ScriptGenerator
