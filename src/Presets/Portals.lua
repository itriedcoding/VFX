--[[
	Portals - 22 gates and rifts. Every portal is a disc/ring pair plus rising
	energy, with a spin track so the ring reads as rotating geometry.
]]

local DSL = require(script.Parent.DSL)

local P, B, T, L, M, A = DSL.P, DSL.B, DSL.T, DSL.L, DSL.M, DSL.A

local function preset(name: string, tags: { string }, duration: number, components: { any }, extra: any?)
	return DSL.preset(name, "Portals", tags, duration, components, extra)
end

local function gate(colors: { string }, radius: number, discColor: string, extra: any?): { any }
	local options = extra or {}
	local comps = {
		M { name = "Surface", col = discColor, transparency = 0.55, size = { radius * 2, 0.15, radius * 2 }, material = "Neon", dur = options.duration or 3 },
		P { name = "Rim", tex = "glow", col = colors, trn = { 0.2, 0.75, 1 }, sz = { 0.5, 1.6 }, life = { 0.8, 1.6 }, spd = { 1, 3 }, sprd = { 4, 4 }, shape = "Cylinder", style = "Surface", partial = 0.3, rate = 70, radius = radius, light = 1.4, off = { 0, 0.2, 0 }, dur = options.duration or 3 },
		P { name = "Motes", tex = "sparkle", col = colors, trn = { 0.2, 0.8, 1 }, sz = { 0.06, 0.25 }, life = { 1, 2.2 }, spd = { 0.5, 2.5 }, sprd = { 180, 180 }, rate = 24, accel = { 0, 2, 0 }, light = 1.2, dur = options.duration or 3 },
		A { name = "GateSpin", target = "rig", property = "spin", from = 0, to = 360, dur = options.spin or 4, easing = "Linear" },
		L { name = "GateLight", col = options.lightColor or colors[#colors], bright = 3, range = 16, dur = options.duration or 3 },
	}
	return comps
end

return {
	-- 01
	preset("Portal Swirl", { "portal", "swirl", "loop" }, 3, gate({ "#ffffff", "#8ad0ff", "#3a6aff" }, 2.4, "#3a8aff")),
	-- 02
	preset("Nether Gate", { "nether", "fire", "loop" }, 3.2, gate({ "#ffffff", "#ff9a1f", "#8a1a00" }, 2.6, "#c42a00", { lightColor = "#ff7a1f" })),
	-- 03
	preset("Void Rift", { "void", "dark", "loop" }, 3.4, gate({ "#c9a6ff", "#4a1d8f", "#05010d" }, 2.2, "#1a0330", { lightColor = "#6b3fff" })),
	-- 04
	preset("Teleport Gate", { "teleport", "blue", "loop" }, 2.6, gate({ "#ffffff", "#bfe8ff", "#2a6aff" }, 2, "#3a8aff", { lightColor = "#8ad0ff" })),
	-- 05
	preset("Magic Portal", { "magic", "purple", "loop" }, 3, gate({ "#ffffff", "#d0b0ff", "#6a35ff" }, 2.2, "#7a3aff", { lightColor = "#b88aff" })),
	-- 06
	preset("Ancient Gateway", { "ancient", "stone", "loop" }, 4, {
		M { name = "Surface", col = "#c9b896", transparency = 0.6, size = { 4.4, 0.18, 4.4 }, material = "Neon", dur = 4 },
		P { name = "Rim", tex = "glow", col = { "#ffffff", "#ffe8c0", "#c9a06a" }, trn = { 0.3, 0.8, 1 }, sz = { 0.5, 1.4 }, life = { 1, 2 }, spd = { 0.5, 2 }, sprd = { 4, 4 }, shape = "Cylinder", style = "Surface", partial = 0.28, rate = 50, light = 1.1, off = { 0, 0.2, 0 }, dur = 4 },
		P { name = "Dust", tex = "dust", col = { "#d6c8b0", "#8a7a62" }, trn = { 0.5, 0.9, 1 }, sz = { 0.3, 1.2 }, life = { 1.6, 3 }, spd = { 0.5, 2 }, sprd = { 180, 180 }, rate = 14, accel = { 0, 1.5, 0 }, dur = 4 },
		A { name = "GateSpin", target = "rig", property = "spin", from = 0, to = 360, dur = 6, easing = "Linear" },
		L { name = "GateLight", col = "#ffd9a0", bright = 2, range = 14, dur = 4 },
	}, { loop = true }),
	-- 07
	preset("Dimensional Rift", { "rift", "electric", "loop" }, 2.6, {
		B { tex = "electric", col = { "#ffffff", "#8affff", "#2a6aff" }, trn = { 0, 0.4, 0.9 }, w0 = 0.2, w1 = 1, segments = 14, curve = 0.8, light = 1.6, texlen = 0.5, texspd = 0.4, off0 = { 0, -3, 0 }, off1 = { 0, 3.4, 0 }, dur = 2.6 },
		P { name = "Rim", tex = "electric", col = { "#eaffff", "#6ae8ff" }, trn = { 0.2, 0.85, 1 }, sz = { 0.2, 0.8 }, life = { 0.3, 0.8 }, spd = { 1, 6 }, sprd = { 60, 60 }, rate = 34, light = 1.4, dur = 2.6 },
		P { name = "Motes", tex = "spark", col = { "#ffffff", "#8affff" }, sz = { 0.06, 0.22 }, life = { 0.6, 1.4 }, spd = { 2, 8 }, sprd = { 180, 180 }, rate = 20, accel = { 0, 2, 0 }, dur = 2.6 },
		L { name = "GateLight", col = "#6ae8ff", bright = 4, range = 18, dur = 2.6 },
	}, { loop = true }),
	-- 08
	preset("Fairy Ring", { "fairy", "nature", "loop" }, 3.4, {
		M { name = "Surface", col = "#c8ffb0", transparency = 0.75, size = { 3.6, 0.12, 3.6 }, material = "Neon", dur = 3.4 },
		P { name = "Rim", tex = "sparkle", col = { "#ffffff", "#e8ffb0", "#7ad63a" }, trn = { 0.2, 0.8, 1 }, sz = { 0.1, 0.4 }, life = { 1.2, 2.4 }, spd = { 0.3, 1.6 }, sprd = { 4, 4 }, shape = "Cylinder", style = "Surface", partial = 0.3, rate = 40, light = 1.1, off = { 0, 0.1, 0 }, dur = 3.4 },
		P { name = "Motes", tex = "sparkle", col = { "#ffffff", "#d8ffb0" }, trn = { 0.3, 0.9, 1 }, sz = { 0.05, 0.2 }, life = { 1.4, 2.6 }, spd = { 0.2, 1.2 }, sprd = { 180, 180 }, rate = 18, accel = { 0, 1.5, 0 }, dur = 3.4 },
		A { name = "GateSpin", target = "rig", property = "spin", from = 0, to = 360, dur = 6, easing = "Linear" },
	}, { loop = true }),
	-- 09
	preset("Spirit Gate", { "spirit", "ghost", "loop" }, 3.6, {
		M { name = "Surface", col = "#bfe0ff", transparency = 0.7, size = { 4, 0.14, 4 }, material = "Neon", dur = 3.6 },
		P { name = "Rim", tex = "smoke", col = { "#ffffff", "#bfe0ff", "#5a7a9a" }, trn = { 0.6, 0.9, 1 }, sz = { 0.6, 2 }, life = { 1.4, 2.6 }, spd = { 0.3, 1.4 }, sprd = { 4, 4 }, shape = "Cylinder", style = "Surface", partial = 0.3, rate = 30, light = 0.6, off = { 0, 0.2, 0 }, dur = 3.6 },
		P { name = "Motes", tex = "sparkle", col = { "#ffffff", "#dff0ff" }, trn = { 0.3, 0.9, 1 }, sz = { 0.06, 0.24 }, life = { 1.6, 3 }, spd = { 0.2, 1 }, sprd = { 180, 180 }, rate = 16, accel = { 0, 1.2, 0 }, dur = 3.6 },
		L { name = "GateLight", col = "#bfe0ff", bright = 1.5, range = 14, dur = 3.6 },
	}, { loop = true }),
	-- 10
	preset("Time Rift", { "time", "clock", "loop" }, 3, {
		M { name = "Surface", col = "#a8f0ff", transparency = 0.6, size = { 3.8, 0.16, 3.8 }, material = "Neon", dur = 3 },
		P { name = "Rim", tex = "glow", col = { "#ffffff", "#a8f0ff", "#3a6aff" }, trn = { 0.3, 0.8, 1 }, sz = { 0.4, 1.2 }, life = { 0.8, 1.6 }, spd = { 4, 10 }, sprd = { 3, 3 }, shape = "Cylinder", style = "Surface", partial = 0.2, rate = 60, light = 1.2, off = { 0, 0.2, 0 }, dur = 3 },
		P { name = "Motes", tex = "sparkle", col = { "#eaffff", "#8ad0ff" }, sz = { 0.05, 0.2 }, life = { 1, 2 }, spd = { -4, -1 }, sprd = { 4, 4 }, shape = "Cylinder", style = "Surface", partial = 0.2, rate = 26, io = "Inward", dur = 3 },
		A { name = "GateSpin", target = "rig", property = "spin", from = 0, to = -360, dur = 5, easing = "Linear" },
		L { name = "GateLight", col = "#8ad0ff", bright = 3, range = 16, dur = 3 },
	}, { loop = true }),
	-- 11
	preset("Cyber Portal", { "cyber", "tech", "loop" }, 2.4, {
		M { name = "Surface", col = "#48e6ff", transparency = 0.5, size = { 4.2, 0.16, 4.2 }, material = "Neon", dur = 2.4 },
		P { name = "Rim", tex = "square", col = { "#ffffff", "#48e6ff", "#0d5cff" }, trn = { 0, 0.5, 1 }, sz = { 0.15, 0.55 }, life = { 0.5, 1.2 }, spd = { 1, 3 }, sprd = { 4, 4 }, shape = "Cylinder", style = "Surface", partial = 0.35, rate = 56, rot = { 0, 360 }, light = 1.4, off = { 0, 0.2, 0 }, dur = 2.4 },
		P { name = "Motes", tex = "square", col = { "#ffffff", "#48e6ff" }, trn = { 0.2, 0.9, 1 }, sz = { 0.06, 0.24 }, life = { 0.6, 1.4 }, spd = { 0.5, 2 }, sprd = { 180, 180 }, rate = 20, dur = 2.4 },
		A { name = "GateSpin", target = "rig", property = "spin", from = 0, to = 360, dur = 3, easing = "Linear" },
		L { name = "GateLight", col = "#48e6ff", bright = 3, range = 16, dur = 2.4 },
	}, { loop = true }),
	-- 12
	preset("Nature Portal", { "nature", "green", "loop" }, 3.4, {
		M { name = "Surface", col = "#8ae05a", transparency = 0.65, size = { 4, 0.14, 4 }, material = "Neon", dur = 3.4 },
		P { name = "Rim", tex = "sparkle", col = { "#ffffff", "#d8ffb0", "#4aa82a" }, trn = { 0.2, 0.8, 1 }, sz = { 0.1, 0.4 }, life = { 1.2, 2.4 }, spd = { 0.5, 2 }, sprd = { 4, 4 }, shape = "Cylinder", style = "Surface", partial = 0.3, rate = 40, light = 1.1, off = { 0, 0.2, 0 }, dur = 3.4 },
		P { name = "Leaves", tex = "debris", col = { "#e8ffb0", "#6ab82a" }, sz = { 0.08, 0.3 }, life = { 1.6, 3 }, spd = { 0.2, 1.2 }, sprd = { 180, 180 }, rate = 14, rotspd = { -80, 80 }, accel = { 0, -1.5, 0 }, light = 0.5, dur = 3.4 },
		A { name = "GateSpin", target = "rig", property = "spin", from = 0, to = 300, dur = 6, easing = "Linear" },
		L { name = "GateLight", col = "#8ae05a", bright = 2, range = 14, dur = 3.4 },
	}, { loop = true }),
	-- 13
	preset("Ice Portal", { "ice", "frost", "loop" }, 3.2, {
		M { name = "Surface", col = "#bfe8ff", transparency = 0.55, size = { 3.8, 0.16, 3.8 }, material = "Neon", dur = 3.2 },
		P { name = "Rim", tex = "sparkle", col = { "#ffffff", "#c9ecff", "#5aa8e0" }, trn = { 0.2, 0.8, 1 }, sz = { 0.1, 0.4 }, life = { 1, 2.2 }, spd = { 0.3, 1.6 }, sprd = { 4, 4 }, shape = "Cylinder", style = "Surface", partial = 0.3, rate = 46, light = 1.2, off = { 0, 0.2, 0 }, dur = 3.2 },
		P { name = "Mist", tex = "smoke", col = { "#ffffff", "#c9e8f8" }, trn = { 0.9, 1 }, sz = { 0.8, 2.6 }, life = { 1.4, 2.6 }, spd = { 0.1, 1 }, sprd = { 180, 180 }, rate = 12, dur = 3.2 },
		A { name = "GateSpin", target = "rig", property = "spin", from = 0, to = 360, dur = 6, easing = "Linear" },
		L { name = "GateLight", col = "#a9e2ff", bright = 2.5, range = 16, dur = 3.2 },
	}, { loop = true }),
	-- 14
	preset("Fire Portal", { "fire", "hot", "loop" }, 2.8, {
		M { name = "Surface", col = "#ff8a1f", transparency = 0.5, size = { 4, 0.16, 4 }, material = "Neon", dur = 2.8 },
		P { name = "Rim", tex = "fire", col = { "#fff2c0", "#ff8a1f", "#8a1a00" }, trn = { 0.15, 0.8, 1 }, sz = { 0.6, 2 }, life = { 0.5, 1.2 }, spd = { 1, 4 }, sprd = { 4, 4 }, shape = "Cylinder", style = "Surface", partial = 0.3, rate = 70, light = 1.4, off = { 0, 0.2, 0 }, dur = 2.8 },
		P { name = "Embers", tex = "spark", col = { "#ffe8a0", "#ff5e00" }, sz = { 0.05, 0.2 }, life = { 0.8, 1.8 }, spd = { 1, 4 }, sprd = { 180, 180 }, rate = 22, accel = { 0, 4, 0 }, light = 1.2, dur = 2.8 },
		A { name = "GateSpin", target = "rig", property = "spin", from = 0, to = 360, dur = 4, easing = "Linear" },
		L { name = "GateLight", col = "#ff8a2a", bright = 5, range = 20, dur = 2.8 },
	}, { loop = true }),
	-- 15
	preset("Shadow Gate", { "shadow", "dark", "loop" }, 3.4, {
		M { name = "Surface", col = "#2a0d4d", transparency = 0.45, size = { 3.6, 0.16, 3.6 }, material = "Neon", dur = 3.4 },
		P { name = "Rim", tex = "smoke", col = { "#8a4dff", "#2a0d4d", "#05010d" }, trn = { 0.6, 0.9, 1 }, sz = { 0.6, 2.2 }, life = { 1.2, 2.4 }, spd = { 0.3, 1.6 }, sprd = { 4, 4 }, shape = "Cylinder", style = "Surface", partial = 0.3, rate = 34, light = 0.2, off = { 0, 0.2, 0 }, dur = 3.4 },
		P { name = "Motes", tex = "star", col = { "#c9a6ff", "#4a1d8f" }, trn = { 0.3, 0.85, 1 }, sz = { 0.06, 0.26 }, life = { 1.2, 2.4 }, spd = { 0.2, 1.2 }, sprd = { 180, 180 }, rate = 14, rotspd = { -60, 60 }, dur = 3.4 },
		L { name = "GateLight", col = "#6b3fff", bright = 1.5, range = 14, dur = 3.4 },
	}, { loop = true }),
	-- 16
	preset("Celestial Portal", { "celestial", "stars", "loop" }, 4, {
		M { name = "Surface", col = "#9fd8ff", transparency = 0.6, size = { 4.4, 0.18, 4.4 }, material = "Neon", dur = 4 },
		P { name = "Rim", tex = "star", col = { "#ffffff", "#9fd8ff", "#7a5aff" }, trn = { 0.2, 0.8, 1 }, sz = { 0.12, 0.45 }, life = { 1.4, 2.8 }, spd = { 0.3, 1.4 }, sprd = { 4, 4 }, shape = "Cylinder", style = "Surface", partial = 0.32, rate = 36, rotspd = { -50, 50 }, light = 1.3, off = { 0, 0.2, 0 }, dur = 4 },
		P { name = "Motes", tex = "sparkle", col = { "#ffffff", "#dff0ff" }, trn = { 0.2, 0.85, 1 }, sz = { 0.05, 0.22 }, life = { 1.6, 3 }, spd = { 0.1, 1 }, sprd = { 180, 180 }, rate = 18, accel = { 0, 1, 0 }, dur = 4 },
		A { name = "GateSpin", target = "rig", property = "spin", from = 0, to = 360, dur = 8, easing = "Linear" },
		L { name = "GateLight", col = "#9fd8ff", bright = 3, range = 18, dur = 4 },
	}, { loop = true }),
	-- 17
	preset("Chaos Portal", { "chaos", "glitch", "loop" }, 2.2, {
		M { name = "Surface", col = "#ff3bd0", transparency = 0.5, size = { 4, 0.16, 4 }, material = "Neon", dur = 2.2 },
		P { name = "Rim", tex = "square", col = { "#00ffd0", "#ff00a8", "#100020" }, trn = { 0, 0.5, 1 }, sz = { 0.15, 0.6 }, life = { 0.15, 0.5 }, spd = { 2, 10 }, sprd = { 4, 4 }, shape = "Cylinder", style = "Surface", partial = 0.4, rate = 90, rot = { 0, 360 }, light = 1.4, off = { 0, 0.2, 0 }, dur = 2.2 },
		P { name = "Glitch", tex = "square", col = { "#ffffff", "#00ffd0", "#ff00a8" }, trn = { 0.2, 0.9, 1 }, sz = { 0.05, 0.3 }, life = { 0.1, 0.4 }, spd = { 4, 14 }, sprd = { 180, 180 }, rate = 40, rot = { 0, 360 }, light = 1.2, dur = 2.2 },
		A { name = "GateSpin", target = "rig", property = "spin", from = 0, to = 720, dur = 2.2, easing = "Linear" },
		L { name = "GateLight", col = "#ff3bd0", bright = 4, range = 16, dur = 2.2 },
	}, { loop = true }),
	-- 18
	preset("Summoning Gate", { "summon", "rune", "loop" }, 3.6, {
		M { name = "Surface", col = "#ffb347", transparency = 0.6, size = { 4.2, 0.16, 4.2 }, material = "Neon", dur = 3.6 },
		P { name = "Rim", tex = "star", col = { "#ffffff", "#ffd08a", "#ff6a1f" }, trn = { 0.2, 0.8, 1 }, sz = { 0.14, 0.5 }, life = { 1.2, 2.4 }, spd = { 0.4, 2 }, sprd = { 4, 4 }, shape = "Cylinder", style = "Surface", partial = 0.28, rate = 44, rotspd = { -50, 50 }, light = 1.4, off = { 0, 0.2, 0 }, dur = 3.6 },
		B { name = "RuneA", tex = "glow", col = { "#ffd08a", "#ff6a1f" }, trn = { 0.2, 0.9 }, w0 = 0.3, w1 = 0.1, segments = 18, curve = 0, light = 1.3, off0 = { -2.2, 0.12, -2.2 }, off1 = { 2.2, 0.12, 2.2 }, dur = 3.6 },
		B { name = "RuneB", tex = "glow", col = { "#ffd08a", "#ff6a1f" }, trn = { 0.2, 0.9 }, w0 = 0.3, w1 = 0.1, segments = 18, curve = 0, light = 1.3, off0 = { -2.2, 0.12, 2.2 }, off1 = { 2.2, 0.12, -2.2 }, dur = 3.6 },
		P { name = "Motes", tex = "spark", col = { "#ffe8c0", "#ff8a1f" }, sz = { 0.06, 0.22 }, life = { 1.2, 2.4 }, spd = { 1, 4 }, sprd = { 60, 60 }, rate = 20, accel = { 0, 5, 0 }, light = 1.2, dur = 3.6 },
		A { name = "GateSpin", target = "rig", property = "spin", from = 0, to = -360, dur = 6, easing = "Linear" },
		L { name = "GateLight", col = "#ffb347", bright = 4, range = 18, dur = 3.6 },
	}, { loop = true }),
	-- 19
	preset("Warp Tunnel", { "warp", "tunnel", "loop" }, 2.4, {
		P { name = "Rings", tex = "glow", col = { "#ffffff", "#8ad0ff", "#3a5aff" }, trn = { 0, 0.7, 1 }, sz = { 0.6, 2.4 }, life = { 0.8, 1.2 }, spd = { -50, -30 }, sprd = { 3, 3 }, shape = "Cylinder", style = "Surface", partial = 0.06, rate = 90, light = 1.3, io = "Inward", off = { 0, 0, -6 }, dur = 2.4 },
		P { name = "Streaks", tex = "spark", col = { "#ffffff", "#bfe8ff" }, trn = { 0.1, 0.7, 1 }, sz = { 0.06, 0.24 }, life = { 0.6, 1.2 }, spd = { -60, -40 }, sprd = { 8, 8 }, rate = 50, orient = "VelocityParallel", light = 1.2, off = { 0, 0, -6 }, dur = 2.4 },
		L { name = "GateLight", col = "#8ad0ff", bright = 3, range = 16, off = { 0, 0, 2 }, dur = 2.4 },
	}, { loop = true }),
	-- 20
	preset("Astral Gate", { "astral", "cosmic", "loop" }, 4, {
		M { name = "Surface", col = "#c9a6ff", transparency = 0.6, size = { 4.6, 0.18, 4.6 }, material = "Neon", dur = 4 },
		P { name = "Rim", tex = "star", col = { "#ffffff", "#c9a6ff", "#5a2bd9" }, trn = { 0.2, 0.8, 1 }, sz = { 0.12, 0.45 }, life = { 1.4, 2.8 }, spd = { 0.2, 1.2 }, sprd = { 4, 4 }, shape = "Cylinder", style = "Surface", partial = 0.3, rate = 34, rotspd = { -50, 50 }, light = 1.4, off = { 0, 0.2, 0 }, dur = 4 },
		P { name = "Motes", tex = "glow", col = { "#ffffff", "#c9a6ff" }, trn = { 0.4, 0.9, 1 }, sz = { 0.08, 0.3 }, life = { 1.8, 3.2 }, spd = { 0.1, 0.8 }, sprd = { 180, 180 }, rate = 16, accel = { 0, 1, 0 }, dur = 4 },
		A { name = "GateSpin", target = "rig", property = "spin", from = 0, to = 360, dur = 9, easing = "Linear" },
		L { name = "GateLight", col = "#c9a6ff", bright = 3, range = 18, dur = 4 },
	}, { loop = true }),
	-- 21
	preset("Crimson Gate", { "crimson", "blood", "loop" }, 3, {
		M { name = "Surface", col = "#ff3b5c", transparency = 0.55, size = { 3.8, 0.16, 3.8 }, material = "Neon", dur = 3 },
		P { name = "Rim", tex = "smoke", col = { "#ffd0d0", "#ff3b5c", "#6b0a1a" }, trn = { 0.5, 0.9, 1 }, sz = { 0.6, 2 }, life = { 1.2, 2.2 }, spd = { 0.3, 1.6 }, sprd = { 4, 4 }, shape = "Cylinder", style = "Surface", partial = 0.3, rate = 32, light = 0.8, off = { 0, 0.2, 0 }, dur = 3 },
		P { name = "Motes", tex = "sparkle", col = { "#ffb0b0", "#ff2a4a" }, sz = { 0.05, 0.22 }, life = { 1, 2.2 }, spd = { 0.5, 2 }, sprd = { 180, 180 }, rate = 18, accel = { 0, -2, 0 }, light = 1, dur = 3 },
		A { name = "GateSpin", target = "rig", property = "spin", from = 0, to = 360, dur = 7, easing = "Linear" },
		L { name = "GateLight", col = "#ff3b5c", bright = 2.5, range = 16, dur = 3 },
	}, { loop = true }),
	-- 22
	preset("Arcane Gateway", { "arcane", "rune", "loop" }, 3.8, {
		M { name = "Surface", col = "#8a5cff", transparency = 0.55, size = { 4.4, 0.18, 4.4 }, material = "Neon", dur = 3.8 },
		P { name = "Rim", tex = "star", col = { "#ffffff", "#c9a6ff", "#5a2bd9" }, trn = { 0.2, 0.8, 1 }, sz = { 0.14, 0.5 }, life = { 1.2, 2.4 }, spd = { 0.4, 2 }, sprd = { 4, 4 }, shape = "Cylinder", style = "Surface", partial = 0.3, rate = 40, rotspd = { -50, 50 }, light = 1.4, off = { 0, 0.2, 0 }, dur = 3.8 },
		P { name = "Glyphs", tex = "square", col = { "#ffffff", "#c9a6ff" }, trn = { 0.2, 0.9, 1 }, sz = { 0.1, 0.4 }, life = { 1.4, 2.6 }, spd = { 0.2, 1 }, sprd = { 5, 5 }, shape = "Cylinder", style = "Surface", partial = 0.3, rate = 24, rotspd = { -40, 40 }, light = 1.2, off = { 0, 1, 0 }, dur = 3.8 },
		A { name = "GateSpin", target = "rig", property = "spin", from = 0, to = -360, dur = 7, easing = "Linear" },
		L { name = "GateLight", col = "#9b6bff", bright = 3.5, range = 18, dur = 3.8 },
	}, { loop = true }),
}
