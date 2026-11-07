--[[
	Explosions - 24 detonations, from campfire-scale pops to world-ending blooms.
	Each one is tuned individually: different palettes, emission shapes, drag,
	gravity and timing, so no two read the same in motion.
]]

local DSL = require(script.Parent.DSL)

local P, B, T, L, M, A = DSL.P, DSL.B, DSL.T, DSL.L, DSL.M, DSL.A

local function preset(name: string, tags: { string }, duration: number, components: { any }, extra: any?)
	return DSL.preset(name, "Explosions", tags, duration, components, extra)
end

return {
	-- 01
	preset("Inferno Burst", { "fire", "burst", "core" }, 1.5, {
		P { tex = "fire", col = { "#fff6c8", "#ff9a1f", "#d92200" }, trn = { 0.02, 0.78, 1 }, sz = { 6, 15 }, life = { 0.35, 0.8 }, spd = { 10, 30 }, sprd = 180, drag = 3, rate = 240, light = 1.4, dur = 0.75 },
		P { tex = "spark", col = { "#fff0b0", "#ff6a00" }, sz = { 0.35, 0.85 }, life = { 0.5, 1.2 }, spd = { 26, 52 }, sprd = 180, drag = 5, accel = { 0, -18, 0 }, burst = 90, dur = 1.2 },
		P { tex = "smoke", col = { "#3b2a20", "#120e0b" }, trn = { 0.55, 0.95, 1 }, sz = { 8, 22 }, life = { 1.2, 2.2 }, spd = { 4, 14 }, sprd = 180, rate = 0, burst = 14, dur = 1.5 },
		L { col = "#ff7a2a", bright = 7, range = 26, dur = 0.45 },
	}),
	-- 02
	preset("Nuclear Bloom", { "fire", "huge", "mushroom" }, 4.5, {
		P { tex = "blast", col = { "#ffffff", "#ffd76a", "#ff5a00" }, trn = { 0, 0.2, 1 }, sz = { 20, 90 }, life = { 1.6, 3.2 }, spd = { 30, 70 }, sprd = 180, shape = "Sphere", drag = 2, rate = 90, light = 1.5, dur = 1.6 },
		P { tex = "smoke", col = { "#5b5048", "#241f1c" }, trn = { 0.4, 0.85, 1 }, sz = { 30, 120 }, life = { 2.5, 4.4 }, spd = { 12, 34 }, sprd = 120, accel = { 0, 12, 0 }, rate = 40, dur = 3.4 },
		P { tex = "debris", col = { "#4a4038", "#1b1714" }, sz = { 1, 3 }, life = { 1.5, 2.8 }, spd = { 60, 110 }, sprd = 100, accel = { 0, -60, 0 }, burst = 60, dur = 2.6, orientation = "VelocityParallel" },
		P { tex = "spark", col = { "#fff3c0", "#ffb000" }, sz = { 0.4, 1.2 }, life = { 1.4, 3 }, spd = { 70, 140 }, sprd = 180, drag = 1, accel = { 0, -30, 0 }, burst = 160, dur = 3 },
		L { col = "#ffd9a0", bright = 14, range = 80, dur = 1.2 },
	}),
	-- 03
	preset("Shockwave Ring", { "ring", "shockwave", "air" }, 1.1, {
		P { tex = "glow", col = { "#dff0ff", "#7fb6ff", "#2a5cbf" }, trn = { 0, 0.55, 1 }, sz = { 2, 9 }, life = { 0.5, 0.9 }, spd = { 55, 62 }, sprd = { 4, 4 }, shape = "Cylinder", style = "Surface", io = "Outward", partial = 0.06, rate = 260, light = 1.2, dur = 0.7 },
		P { tex = "smoke", col = { "#c9d6e6", "#7d8b9c" }, trn = { 0.75, 0.95, 1 }, sz = { 4, 10 }, life = { 0.6, 1.1 }, spd = { 40, 48 }, sprd = { 6, 6 }, shape = "Cylinder", style = "Surface", partial = 0.08, rate = 80, dur = 0.9 },
		B { tex = "glow", col = { "#ffffff", "#4d8bff" }, trn = { 0.1, 0.9 }, w0 = 0.6, w1 = 0.2, segments = 24, curve = 0, light = 1.5, off0 = { -9, 0.2, 0 }, off1 = { 9, 0.2, 0 }, dur = 0.45 },
	}),
	-- 04
	preset("Debris Scatter", { "debris", "impact", "rock" }, 2.4, {
		P { tex = "debris", col = { "#6b5a49", "#2c241d" }, sz = { 0.8, 2.6 }, life = { 1.4, 2.6 }, spd = { 30, 75 }, sprd = 110, accel = { 0, -70, 0 }, rot = { 0, 360 }, rotspd = { -180, 180 }, burst = 55, dur = 2.2, orientation = "VelocityParallel", squash = 0.4 },
		P { tex = "dust", col = { "#b8a894", "#6d6053" }, trn = { 0.6, 0.95, 1 }, sz = { 3, 9 }, life = { 1, 2 }, spd = { 6, 18 }, sprd = 180, rate = 45, dur = 1.8 },
		L { col = "#c9b9a4", bright = 2, range = 14, dur = 0.3 },
	}),
	-- 05
	preset("Plasma Detonation", { "plasma", "energy", "sci-fi" }, 1.6, {
		P { tex = "glow", col = { "#e8fbff", "#48e6ff", "#0d5cff" }, trn = { 0, 0.3, 1 }, sz = { 8, 24 }, life = { 0.4, 0.9 }, spd = { 20, 55 }, sprd = 180, drag = 4, rate = 200, light = 1.6, dur = 0.6 },
		P { tex = "electric", col = { "#c9f7ff", "#3ab8ff" }, sz = { 1.5, 5 }, life = { 0.3, 0.8 }, spd = { 25, 60 }, sprd = 180, rotspd = { -220, 220 }, burst = 40, dur = 0.8, orientation = "VelocityParallel" },
		P { tex = "spark", col = { "#ffffff", "#8ff0ff" }, sz = { 0.3, 0.7 }, life = { 0.6, 1.3 }, spd = { 45, 90 }, sprd = 180, drag = 3, burst = 70, dur = 1.2 },
		L { col = "#5fd8ff", bright = 9, range = 30, dur = 0.5 },
	}),
	-- 06
	preset("Overcharge Blast", { "electric", "shock", "overload" }, 1.3, {
		P { tex = "electric", col = { "#ffffff", "#9bd4ff", "#2f6bff" }, sz = { 2, 7 }, life = { 0.25, 0.6 }, spd = { 40, 85 }, sprd = 180, rotspd = { -300, 300 }, burst = 70, light = 1.4, dur = 0.6, orientation = "VelocityPerpendicular" },
		P { tex = "spark", col = { "#eaf7ff", "#6aa9ff" }, sz = { 0.25, 0.6 }, life = { 0.4, 0.9 }, spd = { 60, 110 }, sprd = 180, drag = 6, burst = 90, dur = 0.9 },
		B { tex = "glow", col = { "#ffffff", "#2f6bff" }, trn = { 0, 0.85 }, w0 = 0.35, w1 = 0.05, segments = 16, light = 1.6, off0 = { 0, 0, 0 }, off1 = { 0, 7, 0 }, at = 0.1, dur = 0.25 },
		L { col = "#8ac2ff", bright = 8, range = 24, dur = 0.35 },
	}),
	-- 07
	preset("Frost Shatter", { "ice", "frost", "burst" }, 1.7, {
		P { tex = "sparkle", col = { "#ffffff", "#c9ecff", "#5aa8e0" }, trn = { 0, 0.35, 1 }, sz = { 1, 4.5 }, life = { 0.7, 1.5 }, spd = { 18, 46 }, sprd = 180, drag = 2, accel = { 0, -12, 0 }, burst = 110, light = 1.1, dur = 1.3 },
		P { tex = "smoke", col = { "#dff2ff", "#8fb6d0" }, trn = { 0.7, 0.95, 1 }, sz = { 4, 12 }, life = { 0.8, 1.6 }, spd = { 6, 16 }, sprd = 180, rate = 50, dur = 1.4 },
		P { tex = "debris", col = { "#eaffff", "#9fd8f0" }, sz = { 0.4, 1.4 }, life = { 0.9, 1.6 }, spd = { 35, 65 }, sprd = 100, accel = { 0, -55, 0 }, rot = { 0, 360 }, burst = 45, dur = 1.5, material = "Ice" },
		L { col = "#a9e2ff", bright = 5, range = 20, dur = 0.5 },
	}),
	-- 08
	preset("Toxic Bloom", { "poison", "gas", "toxic" }, 3.2, {
		P { tex = "puff", col = { "#d7ff8a", "#65c22a", "#245c14" }, trn = { 0.25, 0.7, 1 }, sz = { 6, 24 }, life = { 1.6, 3 }, spd = { 5, 16 }, sprd = 180, rate = 60, light = 0.5, dur = 2.6 },
		P { tex = "smoke", col = { "#8fa06a", "#3a4626" }, trn = { 0.6, 0.92, 1 }, sz = { 10, 26 }, life = { 2, 3.4 }, spd = { 2, 8 }, sprd = 180, accel = { 0, 3, 0 }, rate = 24, dur = 3 },
		P { tex = "sparkle", col = { "#e8ffb0", "#7fe04a" }, sz = { 0.2, 0.6 }, life = { 1, 2 }, spd = { 3, 10 }, sprd = 180, rate = 30, dur = 2.8 },
		L { col = "#8ce05a", bright = 3, range = 18, dur = 1.2 },
	}),
	-- 09
	preset("Void Collapse", { "void", "implosion", "dark" }, 2.2, {
		P { tex = "glow", col = { "#6b3fff", "#1b0a3d", "#05010f" }, trn = { 0.9, 0.4, 0 }, sz = { 12, 1 }, life = { 0.9, 1.4 }, spd = { -34, -22 }, sprd = 180, shape = "Sphere", io = "Inward", rate = 120, light = -0.6, dur = 1.6 },
		P { tex = "smoke", col = { "#2a1650", "#080310" }, trn = { 1, 0.6, 0.1 }, sz = { 20, 4 }, life = { 1, 1.8 }, spd = { -18, -10 }, sprd = 180, io = "Inward", rate = 40, dur = 1.8 },
		P { tex = "sparkle", col = { "#c9a6ff", "#6b3fff" }, sz = { 0.3, 1 }, life = { 0.6, 1.2 }, spd = { -55, -30 }, sprd = 180, burst = 70, dur = 1.4 },
		L { col = "#7a3fff", bright = -4, range = 22, dur = 1.4 },
	}),
	-- 10
	preset("Meteor Impact", { "meteor", "impact", "fire" }, 3, {
		P { tex = "fire", col = { "#ffffff", "#ffa41f", "#ff3b00" }, trn = { 0, 0.4, 0.9 }, sz = { 4, 10 }, life = { 0.5, 1.1 }, spd = { 0, 6 }, sprd = 40, rate = 120, light = 1.3, off = { 0, 26, 0 }, dur = 0.9, accel = { 0, -40, 0 } },
		P { tex = "smoke", col = { "#4a3a2e", "#1a1310" }, trn = { 0.5, 0.9, 1 }, sz = { 10, 30 }, life = { 1.8, 3 }, spd = { 3, 10 }, sprd = 180, rate = 25, at = 0.6, dur = 2.4 },
		P { tex = "debris", col = { "#6a5642", "#2a211a" }, sz = { 0.6, 2.2 }, life = { 1.2, 2.2 }, spd = { 40, 80 }, sprd = 120, accel = { 0, -65, 0 }, burst = 50, at = 0.55, dur = 2, orientation = "VelocityParallel" },
		P { tex = "spark", col = { "#ffe9a0", "#ff7a00" }, sz = { 0.3, 0.9 }, life = { 0.7, 1.6 }, spd = { 30, 70 }, sprd = 180, drag = 2, burst = 120, at = 0.55, dur = 1.6 },
		L { col = "#ff8a3a", bright = 10, range = 40, at = 0.55, dur = 0.6 },
	}),
	-- 11
	preset("Frag Grenade", { "grenade", "frag", "military" }, 1.8, {
		P { tex = "fire", col = { "#ffe2a0", "#ff8a1f" }, trn = { 0.1, 0.9 }, sz = { 3, 8 }, life = { 0.25, 0.6 }, spd = { 14, 34 }, sprd = 180, rate = 180, light = 1, dur = 0.4 },
		P { tex = "debris", col = { "#5a5a5a", "#242424" }, sz = { 0.3, 0.9 }, life = { 0.6, 1.4 }, spd = { 50, 95 }, sprd = 130, accel = { 0, -70, 0 }, rotspd = { -400, 400 }, burst = 70, dur = 1.3, orientation = "VelocityParallel" },
		P { tex = "smoke", col = { "#8a8a8a", "#2e2e2e" }, trn = { 0.5, 0.9, 1 }, sz = { 4, 12 }, life = { 0.9, 1.7 }, spd = { 5, 14 }, sprd = 180, rate = 40, dur = 1.4 },
	}),
	-- 12
	preset("Proximity Mine", { "mine", "trap", "tech" }, 1.4, {
		P { tex = "glow", col = { "#ff4d4d", "#7a0000" }, trn = { 0, 0.6, 1 }, sz = { 3, 10 }, life = { 0.3, 0.7 }, spd = { 22, 45 }, sprd = 180, rate = 200, light = 0.9, dur = 0.5 },
		P { tex = "spark", col = { "#ffd1d1", "#ff2a2a" }, sz = { 0.3, 0.8 }, life = { 0.4, 1 }, spd = { 40, 85 }, sprd = 180, drag = 5, burst = 60, dur = 0.9 },
		P { tex = "square", col = { "#ff3b3b", "#5a0000" }, trn = { 0.2, 1 }, sz = { 0.4, 1.4 }, life = { 0.5, 0.9 }, spd = { 10, 30 }, sprd = 180, rotspd = { -200, 200 }, burst = 40, dur = 0.8 },
		L { col = "#ff3b3b", bright = 5, range = 18, dur = 0.4 },
	}),
	-- 13
	preset("Barrel Blast", { "barrel", "fire", "explosive" }, 2.2, {
		P { tex = "fire", col = { "#fff0b8", "#ff9010", "#c42a00" }, trn = { 0.05, 0.85 }, sz = { 5, 13 }, life = { 0.4, 0.9 }, spd = { 12, 32 }, sprd = 180, rate = 200, light = 1.3, dur = 0.7 },
		P { tex = "debris", col = { "#b07a3c", "#4a2f14" }, sz = { 0.5, 1.8 }, life = { 1, 2 }, spd = { 35, 70 }, sprd = 120, accel = { 0, -60, 0 }, rotspd = { -240, 240 }, burst = 45, dur = 1.7, orientation = "VelocityParallel" },
		P { tex = "smoke", col = { "#3a3028", "#100c09" }, trn = { 0.5, 0.92, 1 }, sz = { 7, 18 }, life = { 1.4, 2.4 }, spd = { 4, 12 }, sprd = 180, rate = 30, at = 0.25, dur = 1.8 },
		L { col = "#ff8a2a", bright = 6, range = 22, dur = 0.5 },
	}),
	-- 14
	preset("Airburst Flare", { "flare", "air", "flash" }, 2.6, {
		P { tex = "glow", col = { "#ffffff", "#fff1a0", "#ffb300" }, trn = { 0, 0.3, 1 }, sz = { 14, 30 }, life = { 0.25, 0.5 }, spd = { 0, 2 }, sprd = 10, burst = 3, light = 1.8, off = { 0, 30, 0 }, dur = 0.45 },
		P { tex = "spark", col = { "#fff6c0", "#ffae00" }, sz = { 0.3, 0.9 }, life = { 1.4, 2.2 }, spd = { 18, 30 }, sprd = 180, drag = 1.5, accel = { 0, -22, 0 }, burst = 90, off = { 0, 30, 0 }, dur = 2.2 },
		P { tex = "smoke", col = { "#8a8478", "#2a2723" }, trn = { 0.85, 1 }, sz = { 4, 12 }, life = { 1.6, 2.4 }, spd = { 1, 4 }, sprd = 90, rate = 18, at = 0.2, off = { 0, 31, 0 }, dur = 2.2 },
		L { col = "#ffe9a0", bright = 12, range = 45, off = { 0, 30, 0 }, dur = 0.5 },
	}),
	-- 15
	preset("Cluster Salvo", { "cluster", "multiple", "sequenced" }, 3.2, {
		P { tex = "fire", col = { "#ffe6b0", "#ff7a00" }, trn = { 0.05, 0.85 }, sz = { 3, 8 }, life = { 0.3, 0.7 }, spd = { 12, 28 }, sprd = 180, rate = 160, dur = 0.4 },
		P { tex = "fire", col = { "#ffd6a0", "#ff5500" }, trn = { 0.1, 0.9 }, sz = { 3, 7 }, life = { 0.3, 0.7 }, spd = { 12, 26 }, sprd = 180, rate = 160, off = { 6, 0, 3 }, at = 0.45, dur = 0.4 },
		P { tex = "fire", col = { "#ffdcb0", "#ff3b00" }, trn = { 0.1, 0.9 }, sz = { 3, 7 }, life = { 0.3, 0.7 }, spd = { 12, 26 }, sprd = 180, rate = 160, off = { -5, 1, -4 }, at = 0.9, dur = 0.4 },
		P { tex = "smoke", col = { "#4a423a", "#141210" }, trn = { 0.6, 0.95 }, sz = { 6, 16 }, life = { 1.4, 2.4 }, spd = { 3, 9 }, sprd = 180, rate = 30, at = 0.5, dur = 2.2 },
	}),
	-- 16
	preset("Sonic Boom", { "sonic", "ring", "speed" }, 1.2, {
		P { tex = "glow", col = { "#ffffff", "#bcd8ff", "#5a86c8" }, trn = { 0.15, 0.75, 1 }, sz = { 1.5, 7 }, life = { 0.4, 0.75 }, spd = { 60, 68 }, sprd = { 2, 2 }, shape = "Cylinder", style = "Surface", partial = 0.04, rate = 200, light = 1, orient = "FacingCamera", dur = 0.6 },
		P { tex = "smoke", col = { "#dfe8f4", "#8895a6" }, trn = { 0.8, 1 }, sz = { 3, 9 }, life = { 0.5, 1 }, spd = { 30, 40 }, sprd = { 8, 8 }, shape = "Disc", style = "Surface", rate = 50, dur = 0.8 },
		B { tex = "glow", col = { "#ffffff", "#9fc4ff" }, trn = { 0, 1 }, w0 = 0.3, w1 = 0.05, segments = 12, light = 1.4, off0 = { -7, 0, 0 }, off1 = { 7, 0, 0 }, dur = 0.3 },
	}),
	-- 17
	preset("Arcane Detonation", { "magic", "arcane", "rune" }, 2.2, {
		P { tex = "star", col = { "#ffffff", "#c9a6ff", "#6a35ff" }, trn = { 0, 0.4, 1 }, sz = { 3, 11 }, life = { 0.5, 1.2 }, spd = { 16, 40 }, sprd = 180, rotspd = { -160, 160 }, rate = 140, light = 1.4, dur = 1 },
		P { tex = "sparkle", col = { "#e6d6ff", "#8a4dff" }, sz = { 0.25, 0.8 }, life = { 1, 2 }, spd = { 6, 18 }, sprd = 180, rate = 60, dur = 1.8 },
		P { tex = "glow", col = { "#9b6bff", "#2a0d63" }, trn = { 0.2, 0.8, 1 }, sz = { 10, 26 }, life = { 0.6, 1.3 }, spd = { 4, 12 }, sprd = 180, rate = 24, dur = 1.2 },
		P { tex = "star", col = { "#ffffff", "#c9a6ff" }, sz = { 0.8, 2 }, life = { 1.2, 2 }, spd = { 0, 3 }, sprd = 180, sprd = { 180, 180 }, burst = 22, at = 0.15, dur = 1.8, rotspd = { -60, 60 } },
		L { col = "#9b6bff", bright = 7, range = 26, dur = 0.6 },
	}),
	-- 18
	preset("Vapor Burst", { "steam", "vapor", "white" }, 2, {
		P { tex = "smoke", col = { "#ffffff", "#d3dbe3", "#9aa5b0" }, trn = { 0.2, 0.8, 1 }, sz = { 5, 18 }, life = { 1, 2 }, spd = { 10, 26 }, sprd = 90, rate = 90, dur = 1.4, accel = { 0, 6, 0 } },
		P { tex = "puff", col = { "#f2f7ff", "#b9c6d4" }, trn = { 0.3, 0.9, 1 }, sz = { 8, 20 }, life = { 1.2, 2.2 }, spd = { 4, 12 }, sprd = 180, rate = 30, dur = 1.8 },
		P { tex = "sparkle", col = { "#ffffff", "#dbeafe" }, sz = { 0.15, 0.5 }, life = { 0.5, 1 }, spd = { 20, 40 }, sprd = 60, burst = 30, dur = 0.9 },
	}),
	-- 19
	preset("Sand Geyser", { "sand", "desert", "geyser" }, 2.6, {
		P { tex = "dust", col = { "#e6cf9e", "#b08a52", "#6b5230" }, trn = { 0.3, 0.85, 1 }, sz = { 4, 16 }, life = { 1.2, 2.2 }, spd = { 18, 46 }, sprd = 40, rate = 110, dur = 1.8, accel = { 0, -8, 0 } },
		P { tex = "debris", col = { "#d8bd8a", "#7a5f36" }, sz = { 0.4, 1.2 }, life = { 0.8, 1.6 }, spd = { 30, 60 }, sprd = 60, accel = { 0, -40, 0 }, burst = 40, dur = 1.5 },
		P { tex = "smoke", col = { "#cbb391", "#5e4c34" }, trn = { 0.75, 0.95 }, sz = { 8, 20 }, life = { 1.6, 2.4 }, spd = { 2, 8 }, sprd = 180, rate = 20, at = 0.4, dur = 2.2 },
	}),
	-- 20
	preset("Snow Burst", { "snow", "cold", "powder" }, 2.4, {
		P { tex = "puff", col = { "#ffffff", "#e6f4ff", "#b9d8ec" }, trn = { 0.15, 0.7, 1 }, sz = { 3, 12 }, life = { 1, 2 }, spd = { 8, 24 }, sprd = 180, rate = 90, dur = 1.6, accel = { 0, -6, 0 } },
		P { tex = "sparkle", col = { "#ffffff", "#d6ecff" }, sz = { 0.2, 0.7 }, life = { 1, 2.2 }, spd = { 6, 18 }, sprd = 180, rotspd = { -70, 70 }, rate = 50, dur = 2 },
		P { tex = "smoke", col = { "#ffffff", "#dbe8f2" }, trn = { 0.8, 1 }, sz = { 6, 16 }, life = { 1.4, 2.2 }, spd = { 2, 6 }, sprd = 180, rate = 16, dur = 2.2 },
	}),
	-- 21
	preset("Glitch Fracture", { "glitch", "digital", "tech" }, 1.6, {
		P { tex = "square", col = { "#00ffd0", "#ff00a8", "#100020" }, trn = { 0, 0.5, 1 }, sz = { 0.4, 2.2 }, life = { 0.15, 0.45 }, spd = { 20, 60 }, sprd = 180, rot = { 0, 360 }, burst = 120, light = 1.2, dur = 0.8, orient = "FacingCamera", drag = 8 },
		P { tex = "square", col = { "#ffffff", "#00ffd0" }, trn = { 0.2, 1 }, sz = { 0.15, 0.5 }, life = { 0.1, 0.3 }, spd = { 40, 90 }, sprd = 180, burst = 80, at = 0.25, dur = 0.5 },
		P { tex = "electric", col = { "#ff00a8", "#00ffd0" }, sz = { 1, 3 }, life = { 0.2, 0.5 }, spd = { 10, 30 }, sprd = 180, burst = 20, dur = 0.6 },
		L { col = "#00ffd0", bright = 6, range = 16, dur = 0.3 },
	}),
	-- 22
	preset("Flash Bang", { "flash", "blind", "utility" }, 1.1, {
		P { tex = "glow", col = { "#ffffff", "#fffbd0" }, trn = { 0, 0.1, 1 }, sz = { 18, 40 }, life = { 0.15, 0.3 }, spd = { 0, 1 }, burst = 2, light = 1, dur = 0.3 },
		P { tex = "spark", col = { "#ffffff", "#fff3a0" }, sz = { 0.3, 0.8 }, life = { 0.5, 1 }, spd = { 40, 80 }, sprd = 180, drag = 8, burst = 60, dur = 0.9 },
		L { col = "#ffffff", bright = 16, range = 40, dur = 0.35 },
	}),
	-- 23
	preset("Smoke Charge", { "smoke", "screen", "tactical" }, 4, {
		P { tex = "smoke", col = { "#cfd6de", "#8b95a1", "#4a5158" }, trn = { 0.35, 0.8, 0.95 }, sz = { 8, 26 }, life = { 2.4, 3.8 }, spd = { 3, 10 }, sprd = 180, rate = 40, dur = 3.6 },
		P { tex = "puff", col = { "#e6ecf2", "#9aa4b0" }, trn = { 0.5, 0.95 }, sz = { 12, 30 }, life = { 2.6, 4 }, spd = { 1, 5 }, sprd = 180, rate = 14, at = 0.5, dur = 3.4 },
		P { tex = "spark", col = { "#ffd9a0", "#ff7a00" }, sz = { 0.3, 0.8 }, life = { 0.2, 0.5 }, spd = { 20, 40 }, sprd = 180, burst = 40, dur = 0.4 },
	}),
	-- 24
	preset("Firework Shell", { "firework", "celebration", "sequenced" }, 3.4, {
		P { tex = "spark", col = { "#ffffff", "#ffe66b", "#ff5a9e" }, sz = { 0.3, 1 }, life = { 1.2, 2 }, spd = { 30, 55 }, sprd = 180, drag = 2.5, accel = { 0, -14, 0 }, burst = 100, off = { 0, 24, 0 }, dur = 2.2 },
		P { tex = "star", col = { "#ffffff", "#8ad6ff" }, sz = { 0.8, 2 }, life = { 0.8, 1.6 }, spd = { 12, 26 }, sprd = 180, burst = 26, at = 0.35, off = { 0, 24, 0 }, dur = 1.8 },
		P { tex = "smoke", col = { "#8a8a8a", "#3a3a3a" }, trn = { 0.9, 1 }, sz = { 3, 9 }, life = { 1.6, 2.4 }, spd = { 2, 6 }, sprd = 180, rate = 14, at = 0.2, off = { 0, 24, 0 }, dur = 2.4 },
		L { col = "#ffd9a8", bright = 5, range = 30, off = { 0, 24, 0 }, dur = 0.4 },
	}),
}
