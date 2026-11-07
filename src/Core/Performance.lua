--[[
	Performance - budget analysis for effects. Works on both the live spec
	(while editing) and arbitrary instances in the place (Analyzer panel).

	The numbers are estimates of *concurrent particles*, which is the metric
	that actually costs frame time: steady-state emissions are rate x lifetime,
	bursts add their count on top.
]]

local Util = require(script.Parent.Util)
local Compiler = require(script.Parent.Compiler)

local Performance = {}

local SEVERITY_WEIGHT = { high = 20, medium = 11, low = 5 }

local function addIssue(report: any, severity: string, title: string, detail: string, fix: string?)
	table.insert(report.issues, {
		severity = severity,
		title = title,
		detail = detail,
		fix = fix,
	})
end

local function emptyReport(): any
	return {
		score = 100,
		grade = "A",
		alive = 0,
		burstPeak = 0,
		emitters = 0,
		beams = 0,
		trails = 0,
		lights = 0,
		parts = 0,
		textures = 0,
		remoteTextures = 0,
		components = 0,
		issues = {},
	}
end

local function finalize(report: any)
	for _, issue in ipairs(report.issues) do
		report.score -= SEVERITY_WEIGHT[issue.severity] or 4
	end
	if report.alive > 400 then
		report.score -= math.min(25, report.alive / 220)
	end
	report.score = math.clamp(math.floor(report.score + 0.5), 1, 100)
	if report.score >= 90 then
		report.grade = "A"
	elseif report.score >= 75 then
		report.grade = "B"
	elseif report.score >= 58 then
		report.grade = "C"
	else
		report.grade = "D"
	end
	return report
end

--- Analyzes a preset spec.
function Performance.analyze(spec: any): any
	local report = emptyReport()
	local components = spec and spec.components or {}
	report.components = #components
	local seenTextures: { [string]: boolean } = {}

	for _, comp in ipairs(components) do
		if comp.kind == "particle" then
			report.emitters += 1
			local rate = math.max(0, tonumber(comp.rate) or 0)
			local lifetime = tonumber((comp.lifetime :: any)[1]) or 1
			local lifetimeMax = tonumber((comp.lifetime :: any)[2]) or lifetime
			local alive = rate * ((lifetime + lifetimeMax) * 0.5)
			report.alive += alive
			report.burstPeak += math.max(0, tonumber(comp.burst) or 0) * math.max(1, tonumber(comp.repeats) or 1)
			if alive > 700 then
				addIssue(
					report,
					"high",
					"Emitter \"" .. tostring(comp.name) .. "\" is heavy",
					string.format("about %d particles alive at once (rate %d x lifetime %s)", math.floor(alive + 0.5), rate, Util.pretty(lifetime)),
					"Lower the rate or use a longer lifetime with a lower rate."
				)
			elseif alive > 350 then
				addIssue(
					report,
					"medium",
					"Emitter \"" .. tostring(comp.name) .. "\" is warm",
					string.format("%d concurrent particles", math.floor(alive + 0.5)),
					"Consider trimming the rate below 350/lifetime."
				)
			end
			if (tonumber(comp.rate) or 0) <= 0 and (tonumber(comp.burst) or 0) <= 0 then
				addIssue(report, "low", "Emitter \"" .. tostring(comp.name) .. "\" never emits", "Rate and burst are both zero.", "Set a rate or a burst count.")
			end
			if tonumber(comp.zOffset) and math.abs(tonumber(comp.zOffset) or 0) > 40 then
				addIssue(report, "low", "Extreme ZOffset", "Large ZOffset values fight depth sorting on low-end devices.", "Keep ZOffset within +/- 20.")
			end
			local texture = tostring(comp.texture or "")
			if not seenTextures[texture] then
				seenTextures[texture] = true
				report.textures += 1
				if string.find(texture, "rbxassetid://", 1, true) then
					report.remoteTextures += 1
				end
			end
		elseif comp.kind == "beam" then
			report.beams += 1
			if (tonumber(comp.segments) or 0) > 30 then
				addIssue(report, "low", "Beam \"" .. tostring(comp.name) .. "\" has many segments", "Segments above 30 cost geometry for very little visual gain.", "Reduce segments to 24 or fewer.")
			end
		elseif comp.kind == "trail" then
			report.trails += 1
			if (tonumber(comp.lifetime) or 0) > 4 then
				addIssue(report, "low", "Long trail lifetime", "Trail \"" .. tostring(comp.name) .. "\" keeps geometry for a long time.", "Lower lifetime to ~1.5s.")
			end
		elseif comp.kind == "light" then
			report.lights += 1
			if comp.shadows == true then
				addIssue(report, "medium", "Shadow-casting light", "Shadowed PointLights are expensive per frame.", "Disable Shadows for effect lights.")
			end
			if (tonumber(comp.range) or 0) > 40 then
				addIssue(report, "low", "Large light range", "Range above 40 keeps the light relevant to many parts.", "Reduce range to ~24 studs.")
			end
		elseif comp.kind == "part" then
			report.parts += 1
			if (tonumber(comp.transparency) or 0) < 0.05 and tostring(comp.material) ~= "Neon" then
				addIssue(report, "low", "Opaque effect part", "Solid parts inside VFX hide the effect behind them.", "Increase transparency or use Neon.")
			end
		end
	end

	if report.lights > 4 then
		addIssue(report, "medium", "Many dynamic lights", string.format("%d PointLights in one effect", report.lights), "Cap effect lights at 4, or bake the glow into particles.")
	end
	if report.alive > 1500 then
		addIssue(report, "high", "Particle budget exceeded", string.format("%d concurrent particles in one effect", math.floor(report.alive + 0.5)), "Split the effect or lower the heaviest rates.")
	end
	if report.remoteTextures > 6 then
		addIssue(report, "low", "Many remote textures", string.format("%d asset textures to download", report.remoteTextures), "Reuse textures across emitters; each unique asset is a download.")
	end
	if report.components > 14 then
		addIssue(report, "medium", "Very complex effect", string.format("%d components", report.components), "Consolidate emitters that share settings.")
	end

	return finalize(report)
end

--- Analyzes real instances (selection, folder, model).
function Performance.analyzeInstances(root: Instance): any
	local report = emptyReport()
	local seenTextures: { [string]: boolean } = {}

	local function scan(inst: Instance)
		if inst:IsA("ParticleEmitter") then
			report.emitters += 1
			report.components += 1
			local lifetime = (inst.Lifetime.Min + inst.Lifetime.Max) * 0.5
			report.alive += inst.Rate * lifetime
			if inst.Rate * lifetime > 700 then
				addIssue(report, "high", "Heavy emitter: " .. inst:GetFullName(), string.format("%d concurrent particles", math.floor(inst.Rate * lifetime + 0.5)), "Reduce Rate or Lifetime.")
			end
			local texture = inst.Texture
			if not seenTextures[texture] then
				seenTextures[texture] = true
				report.textures += 1
				if string.find(texture, "rbxassetid://", 1, true) then
					report.remoteTextures += 1
				end
			end
		elseif inst:IsA("Beam") then
			report.beams += 1
			report.components += 1
			if inst.Segments > 30 then
				addIssue(report, "low", "High segment beam: " .. inst.Name, inst.Segments .. " segments", "Reduce Segments to 24.")
			end
		elseif inst:IsA("Trail") then
			report.trails += 1
			report.components += 1
		elseif inst:IsA("PointLight") then
			report.lights += 1
			report.components += 1
			if inst.Shadows then
				addIssue(report, "medium", "Shadowed light: " .. inst.Name, "Shadows enabled on an effect light.", "Disable Shadows.")
			end
		elseif inst:IsA("BasePart") and inst.Transparency < 1 and inst.Name ~= "Rig" then
			report.parts += 1
			report.components += 1
		end
	end

	scan(root)
	for _, descendant in ipairs(root:GetDescendants()) do
		scan(descendant)
	end

	if report.lights > 4 then
		addIssue(report, "medium", "Many dynamic lights", string.format("%d PointLights", report.lights), "Cap effect lights at 4.")
	end
	return finalize(report)
end

--- Produces an optimized copy of the spec plus a human readable change list.
function Performance.optimize(spec: any): (any, { string })
	local optimized = Util.deepCopy(spec)
	local changes = {}

	for _, comp in ipairs(optimized.components or {}) do
		if comp.kind == "particle" then
			local rate = tonumber(comp.rate) or 0
			if rate > 60 then
				comp.rate = 60
				table.insert(changes, string.format("%s: rate %d -> 60", comp.name, math.floor(rate)))
			end
			local lifetimeMax = tonumber((comp.lifetime :: any)[2]) or 1
			if lifetimeMax > 3 then
				comp.lifetime = { 0.4, 3 }
				table.insert(changes, string.format("%s: lifetime capped at 3s", comp.name))
			end
			if (tonumber(comp.repeats) or 1) > 3 then
				comp.repeats = 3
				table.insert(changes, string.format("%s: repeats capped at 3", comp.name))
			end
			if math.abs(tonumber(comp.zOffset) or 0) > 20 then
				comp.zOffset = math.clamp(tonumber(comp.zOffset) or 0, -20, 20)
				table.insert(changes, string.format("%s: ZOffset clamped", comp.name))
			end
		elseif comp.kind == "beam" then
			if (tonumber(comp.segments) or 0) > 24 then
				comp.segments = 24
				table.insert(changes, string.format("%s: segments -> 24", comp.name))
			end
		elseif comp.kind == "light" then
			if comp.shadows == true then
				comp.shadows = false
				table.insert(changes, string.format("%s: shadows disabled", comp.name))
			end
			if (tonumber(comp.range) or 0) > 32 then
				comp.range = 32
				table.insert(changes, string.format("%s: range -> 32", comp.name))
			end
		elseif comp.kind == "part" then
			if (tonumber(comp.transparency) or 0) < 0.05 then
				comp.transparency = 0.15
				table.insert(changes, string.format("%s: transparency raised", comp.name))
			end
		end
	end

	if #changes == 0 then
		table.insert(changes, "Nothing to optimize - this effect is already within budget.")
	end
	return optimized, changes
end

--- Live particle estimate for a single component (used by the properties panel).
function Performance.componentCost(comp: any): number
	if comp.kind ~= "particle" then
		return 0
	end
	local rate = math.max(0, tonumber(comp.rate) or 0)
	local min = tonumber((comp.lifetime :: any)[1]) or 1
	local max = tonumber((comp.lifetime :: any)[2]) or min
	return rate * ((min + max) * 0.5) + math.max(0, tonumber(comp.burst) or 0)
end

function Performance.analyzeModel(model: Instance): any
	return Performance.analyzeInstances(model)
end

function Performance.analyzeSpec(spec: any): any
	return Performance.analyze(spec)
end

function Performance.fromModel(model: Instance): any
	local spec = Compiler.readSpec(model)
	if spec then
		return Performance.analyze(spec)
	end
	return Performance.analyzeInstances(model)
end

return Performance
