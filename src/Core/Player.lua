--[[
	Player - the timeline runtime. Drives a compiled effect model through its
	emission windows, bursts, loops and tween tracks.

	The same semantics are emitted into generated controller scripts, so what
	the viewport previews is what ships in the game.
]]

local Util = require(script.Parent.Util)
local Format = require(script.Parent.Format)
local Compiler = require(script.Parent.Compiler)

local TweenService = game:GetService("TweenService")

local Player = {}
Player.__index = Player

local function clamp01(value: any): number
	return math.clamp(tonumber(value) or 0, 0, 1)
end

function Player.new(model: Model, spec: any?)
	local resolvedSpec = spec or Compiler.readSpec(model)
	if not resolvedSpec then
		error("VFX Studio: cannot play an effect without a spec")
	end
	local self = setmetatable({
		model = model,
		spec = resolvedSpec,
		bindings = Compiler.resolve(model),
		playing = false,
		token = 0,
		speed = 1,
		loop = resolvedSpec.loop == true,
		tweens = {} :: { Tween },
		_onStateChange = nil,
	}, Player)
	return self
end

function Player:SetSpeed(speed: number)
	self.speed = math.clamp(speed or 1, 0.1, 4)
end

function Player:IsPlaying(): boolean
	return self.playing
end

function Player:_entryFor(comp: any): any?
	return self.bindings[comp.name]
end

--- Creates a tween that is cancelled automatically when playback stops.
function Player:_tweenTo(instance: Instance, info: TweenInfo, props: any): Tween
	local tween = TweenService:Create(instance, info, props)
	table.insert(self.tweens, tween)
	tween.Completed:Connect(function()
		for index, item in ipairs(self.tweens) do
			if item == tween then
				table.remove(self.tweens, index)
				break
			end
		end
	end)
	tween:Play()
	return tween
end

function Player:_cancelTweens()
	for _, tween in ipairs(self.tweens) do
		pcall(function()
			tween:Cancel()
		end)
	end
	self.tweens = {}
end

function Player:_resetOne(comp: any)
	local entry = self:_entryFor(comp)
	if not entry then
		return
	end
	if comp.kind == "particle" and entry.primary:IsA("ParticleEmitter") then
		entry.primary.Enabled = false
		entry.primary:Clear()
	elseif comp.kind == "beam" and entry.primary:IsA("Beam") then
		entry.primary.Enabled = false
	elseif comp.kind == "trail" and entry.primary:IsA("Trail") then
		entry.primary.Enabled = false
	elseif comp.kind == "light" and entry.primary:IsA("PointLight") then
		entry.primary.Enabled = false
	elseif comp.kind == "part" and entry.primary:IsA("BasePart") then
		entry.primary.Transparency = 1
	end
end

function Player:Reset()
	self:_cancelTweens()
	for _, comp in ipairs(self.spec.components or {}) do
		self:_resetOne(comp)
	end
end

function Player:_burst(comp: any)
	local entry = self:_entryFor(comp)
	if not entry or not entry.primary:IsA("ParticleEmitter") then
		return
	end
	local count = math.floor(tonumber(comp.burst) or 0)
	if count > 0 then
		entry.primary:Emit(count)
	end
end

function Player:_activate(comp: any)
	local entry = self:_entryFor(comp)
	if not entry then
		return
	end
	if comp.kind == "particle" then
		if not entry.primary:IsA("ParticleEmitter") then
			return
		end
		local emitter = entry.primary :: ParticleEmitter
		if (tonumber(comp.burst) or 0) > 0 then
			emitter:Emit(math.floor(tonumber(comp.burst) or 0))
		end
		if (tonumber(comp.rate) or 0) > 0 then
			emitter.Enabled = true
		end
	elseif comp.kind == "beam" and entry.primary:IsA("Beam") then
		(entry.primary :: Beam).Enabled = true
	elseif comp.kind == "trail" and entry.primary:IsA("Trail") then
		(entry.primary :: Trail).Enabled = true
	elseif comp.kind == "light" and entry.primary:IsA("PointLight") then
		(entry.primary :: PointLight).Enabled = true
	elseif comp.kind == "part" and entry.primary:IsA("BasePart") then
		local part = entry.primary :: BasePart
		part.Transparency = 1
		Util.tween(part, { Transparency = clamp01(comp.transparency) }, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local base = CFrame.new(Format.vector3(comp.offset))
		if (tonumber(comp.float) or 0) ~= 0 then
			local duration = math.max(0.05, tonumber(comp.duration) or 1)
			part.CFrame = base
			Util.tween(part, { CFrame = base * CFrame.new(0, tonumber(comp.float) or 0, 0) }, duration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
		end
	end
end

function Player:_deactivate(comp: any)
	local entry = self:_entryFor(comp)
	if not entry then
		return
	end
	if comp.kind == "particle" and entry.primary:IsA("ParticleEmitter") then
		(entry.primary :: ParticleEmitter).Enabled = false
	elseif comp.kind == "beam" and entry.primary:IsA("Beam") then
		(entry.primary :: Beam).Enabled = false
	elseif comp.kind == "trail" and entry.primary:IsA("Trail") then
		(entry.primary :: Trail).Enabled = false
	elseif comp.kind == "light" and entry.primary:IsA("PointLight") then
		(entry.primary :: PointLight).Enabled = false
	elseif comp.kind == "part" and entry.primary:IsA("BasePart") then
		local part = entry.primary :: BasePart
		local tween = Util.tween(part, { Transparency = 1 }, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		tween.Completed:Once(function()
			if part.Parent then
				part.CFrame = CFrame.new(Format.vector3(comp.offset))
			end
		end)
	end
end

function Player:_runTween(comp: any)
	local targetName = tostring(comp.target or "rig")
	local target: Instance? = nil
	if targetName == "rig" then
		target = self.model:FindFirstChild(Compiler.RIG_NAME)
	else
		local entry = self.bindings[targetName]
		if entry then
			target = entry.primary
		end
	end
	if not target then
		return
	end

	local style = Format.enum(Enum.EasingStyle, comp.easing, "Quad")
	local direction = Format.enum(Enum.EasingDirection, comp.direction, "Out")
	local duration = math.max(0.05, (tonumber(comp.duration) or 1) / self.speed)
	local repeatCount = math.floor(tonumber(comp.repeatCount) or 0)
	local reverse = comp.reverse == true
	local info = TweenInfo.new(duration, style, direction, repeatCount, reverse)

	local from = tonumber(comp.from) or 0
	local to = tonumber(comp.to) or 0
	local property = tostring(comp.property or "spin")

	if property == "spin" or property == "float" then
		local rig = self.model:FindFirstChild(Compiler.RIG_NAME)
		if not rig or not rig:IsA("BasePart") then
			return
		end
		local base = rig.CFrame
		local goal: CFrame
		if property == "spin" then
			goal = base * CFrame.Angles(0, math.rad(to), 0)
			rig.CFrame = base * CFrame.Angles(0, math.rad(from), 0)
		else
			goal = base * CFrame.new(0, to, 0)
			rig.CFrame = base * CFrame.new(0, from, 0)
		end
		self:_tweenTo(rig, info, { CFrame = goal })
		return
	elseif property == "brightness" and target:IsA("PointLight") then
		target.Brightness = from
		self:_tweenTo(target, info, { Brightness = to })
		return
	elseif property == "transparency" and target:IsA("BasePart") then
		target.Transparency = clamp01(from)
		self:_tweenTo(target, info, { Transparency = clamp01(to) })
		return
	elseif property == "scale" and target:IsA("BasePart") then
		local baseSize = target.Size
		target.Size = baseSize * math.max(0.01, from)
		self:_tweenTo(target, info, { Size = baseSize * math.max(0.01, to) })
		return
	elseif property == "color" and target:IsA("PointLight") then
		target.Color = Util.hex(tostring(comp.fromColor or "#ffffff"))
		self:_tweenTo(target, info, { Color = Util.hex(tostring(comp.toColor or "#ffffff")) })
		return
	end
end

--- Plays the effect. Returns self.
function Player:Play(options: any?)
	local opts = options or {}
	self:Stop(false)
	self.token += 1
	local token = self.token
	self.playing = true
	if opts.loop ~= nil then
		self.loop = opts.loop == true
	end
	if self._onStateChange then
		self._onStateChange(true)
	end

	self:Reset()

	local total = math.max(0.1, tonumber(self.spec.duration) or 1)
	local components = self.spec.components or {}

	local function alive(): boolean
		return self.token == token
	end

	local function runComponent(comp: any)
		local start = math.max(0, tonumber(comp.startTime) or 0) / self.speed
		if start > 0 then
			task.wait(start)
		end
		if not alive() then
			return
		end

		if comp.kind == "tween" then
			self:_runTween(comp)
			return
		end

		local duration = math.max(0, tonumber(comp.duration) or 0) / self.speed
		local repeats = math.max(1, math.floor(tonumber(comp.repeats) or 1))
		local isBurst = (tonumber(comp.burst) or 0) > 0
		local isContinuous = (tonumber(comp.rate) or 0) > 0

		if isBurst and repeats > 1 and duration > 0 then
			local interval = duration / repeats
			for index = 1, repeats do
				if not alive() then
					return
				end
				self:_burst(comp)
				if index < repeats then
					task.wait(math.max(0.02, interval))
				end
			end
			if isContinuous then
				self:_deactivate(comp)
			end
			return
		end

		self:_activate(comp)
		if duration > 0 then
			task.wait(duration)
		end
		if not alive() then
			return
		end
		self:_deactivate(comp)
	end

	local function cycle()
		for _, comp in ipairs(components) do
			task.spawn(runComponent, comp)
		end
		task.wait(total / self.speed)
		if not alive() then
			return
		end
		if self.loop then
			self:Reset()
			cycle()
		else
			for _, comp in ipairs(components) do
				self:_deactivate(comp)
			end
			self.playing = false
			if self._onStateChange then
				self._onStateChange(false)
			end
		end
	end

	task.spawn(cycle)
	return self
end

function Player:Stop(notify: boolean?)
	self.token += 1
	self.playing = false
	self:_cancelTweens()
	for _, comp in ipairs(self.spec.components or {}) do
		self:_deactivate(comp)
		self:_resetOne(comp)
	end
	if notify ~= false and self._onStateChange then
		self._onStateChange(false)
	end
end

function Player:Destroy()
	self:Stop(false)
	self._onStateChange = nil
end

function Player:OnStateChange(callback: ((boolean) -> ())?)
	self._onStateChange = callback
end

return Player
