--[[
	Lightning - 22 electric effects.

	Bolts are real Beams with curvature and segments; the crackle around them
	is ParticleEmitters using the electric spark texture. Colour temperature,
	arc count and flash timing separate the presets.
]]

local DSL = require(script.Parent.DSL)

local P, B, T, L, M, A = DSL.P, DSL.B, DSL.T, DSL.L, DSL.M, DSL.A

local function preset(name: string, tags: { string }, duration: number, components: { any }, extra: any?)
	return DSL.preset(name, "Lightning", tags, duration, components, extra)
end

return {
	-- 01
	preset("Lightning Strike", { "strike", "bolt", "flash" }, 1.4, {
		B { tex = "electric", col = { "#ffffff", "#bcd8ff", "#4a7aff" }, trn = { 0, 0.7, 1 }, w0 = 1.6, w1 = 0.15, segments = 26, curve = 2.4, light = 1.8, texlen = 0.35, off0 = { 0, 32, 0 }, off1 = { 0, 0, 0 }, dur = 0.28 },
		B { tex = "glow", col = { "#ffffff", "#7fa8ff" }, trn = { 0, 0.95 }, w0 = 0.5, w1 = 0.05, segments = 14, curve = 1.2, light = 1.6, off0 = { 0, 32, 0 }, off1 = { 0, 0, 0 }, dur = 0.3 },
		P { tex = "electric", col = { "#ffffff", "#8ab8ff" }, sz = { 0.6, 2.2 }, life = { 0.2, 0.6 }, spd = { 20, 50 }, sprd = { 180, 180 }, burst = 45, light = 1.4, dur = 0.7 },
		P { tex = "spark", col = { "#eaf4ff", "#5a8aff" }, sz = { 0.15, 0.45 }, life = { 0.4, 1 }, spd = { 30, 70 }, sprd = { 180, 180 }, drag = 4, burst = 60, dur = 1 },
		L { col = "#a8c8ff", bright = 14, range = 44, dur = 0.35 },
	}),
	-- 02
	preset("Chain Lightning", { "chain", "multi", "sequenced" }, 1.6, {
		B { tex = "electric", col = { "#ffffff", "#9ac4ff" }, trn = { 0, 0.8, 1 }, w0 = 0.9, w1 = 0.2, segments = 20, curve = 1.8, light = 1.6, off0 = { 0, 0, 0 }, off1 = { 5, 2, 0 }, dur = 0.22 },
		B { tex = "electric", col = { "#ffffff", "#9ac4ff" }, trn = { 0, 0.8, 1 }, w0 = 0.7, w1 = 0.15, segments = 18, curve = -1.6, light = 1.4, off0 = { 5, 2, 0 }, off1 = { 10, 0.5, 2 }, at = 0.18, dur = 0.2 },
		B { tex = "electric", col = { "#ffffff", "#9ac4ff" }, trn = { 0, 0.85, 1 }, w0 = 0.6, w1 = 0.1, segments = 16, curve = 1.4, light = 1.2, off0 = { 10, 0.5, 2 }, off1 = { 14, 3, 0 }, at = 0.36, dur = 0.2 },
		P { tex = "electric", col = { "#dff0ff", "#7aaaff" }, sz = { 0.5, 1.8 }, life = { 0.2, 0.5 }, spd = { 12, 30 }, sprd = { 180, 180 }, burst = 22, at = 0.18, dur = 0.5, off = { 5, 2, 0 } },
		L { col = "#9ac4ff", bright = 7, range = 26, dur = 0.5 },
	}),
	-- 03
	preset("Ball Lightning", { "orb", "float", "loop" }, 3, {
		P { tex = "glow", col = { "#ffffff", "#9fd0ff", "#2a5aff" }, trn = { 0, 0.4, 0.9 }, sz = { 2.4, 5.2 }, life = { 0.5, 1 }, spd = { 0.5, 2 }, sprd = { 180, 180 }, rate = 40, light = 1.6, shape = "Sphere", dur = 3, off = { 0, 1.6, 0 } },
		P { tex = "electric", col = { "#eaf6ff", "#6aa4ff" }, sz = { 0.5, 1.6 }, life = { 0.3, 0.8 }, spd = { 3, 9 }, sprd = { 180, 180 }, rate = 26, rotspd = { -240, 240 }, dur = 3, off = { 0, 1.6, 0 }, light = 1.4 },
		P { tex = "spark", col = { "#ffffff", "#8ab8ff" }, sz = { 0.1, 0.3 }, life = { 0.4, 1 }, spd = { 4, 12 }, sprd = { 180, 180 }, rate = 20, accel = { 0, 2, 0 }, dur = 3, off = { 0, 1.6, 0 } },
		A { target = "rig", property = "float", from = 0, to = 1.2, dur = 1.6, repeatCount = -1, reverse = true, easing = "Sine" },
		L { col = "#8ab8ff", bright = 6, range = 18, off = { 0, 1.6, 0 }, dur = 3 },
	}, { loop = true }),
	-- 04
	preset("Electric Arc", { "arc", "small", "loop" }, 1.6, {
		B { tex = "electric", col = { "#ffffff", "#a8d0ff" }, trn = { 0, 0.85, 1 }, w0 = 0.35, w1 = 0.08, segments = 14, curve = 0.9, light = 1.4, off0 = { -1.2, 0, 0 }, off1 = { 1.2, 0.4, 0 }, dur = 1.6 },
		P { tex = "electric", col = { "#eaf6ff", "#8ab8ff" }, sz = { 0.2, 0.7 }, life = { 0.15, 0.4 }, spd = { 6, 18 }, sprd = { 180, 180 }, rate = 22, rotspd = { -300, 300 }, dur = 1.6, light = 1.2 },
		P { tex = "spark", col = { "#ffffff", "#6aa4ff" }, sz = { 0.08, 0.2 }, life = { 0.3, 0.7 }, spd = { 8, 20 }, sprd = { 180, 180 }, rate = 14, drag = 5, dur = 1.6 },
		L { col = "#8ab8ff", bright = 3, range = 12, dur = 1.6 },
	}, { loop = true }),
	-- 05
	preset("Tesla Coil", { "coil", "top", "loop" }, 2.6, {
		P { tex = "electric", col = { "#ffffff", "#c0d8ff" }, sz = { 0.4, 1.4 }, life = { 0.2, 0.6 }, spd = { 8, 22 }, sprd = { 60, 60 }, rate = 30, rotspd = { -260, 260 }, light = 1.5, off = { 0, 3.4, 0 }, dur = 2.6 },
		B { tex = "electric", col = { "#ffffff", "#9ac4ff" }, trn = { 0, 0.9 }, w0 = 0.25, w1 = 0.04, segments = 12, curve = 1.6, light = 1.4, off0 = { 0, 3.4, 0 }, off1 = { 1.8, 4.6, 0.4 }, at = 0.2, dur = 0.3 },
		B { tex = "electric", col = { "#ffffff", "#9ac4ff" }, trn = { 0, 0.9 }, w0 = 0.25, w1 = 0.04, segments = 12, curve = -1.4, light = 1.4, off0 = { 0, 3.4, 0 }, off1 = { -1.6, 4.2, -0.6 }, at = 1.1, dur = 0.3 },
		L { col = "#a8c8ff", bright = 5, range = 16, off = { 0, 3.4, 0 }, dur = 2.6 },
	}, { loop = true }),
	-- 06
	preset("Storm Bolt", { "storm", "sky", "strike" }, 1.8, {
		B { tex = "electric", col = { "#ffffff", "#cfe4ff", "#6a8aff" }, trn = { 0, 0.6, 1 }, w0 = 3, w1 = 0.3, segments = 30, curve = 3.2, light = 1.9, texlen = 0.25, off0 = { 0, 60, 0 }, off1 = { 0, 0, 0 }, dur = 0.35 },
		P { tex = "electric", col = { "#ffffff", "#a8c8ff" }, sz = { 1, 3 }, life = { 0.3, 0.8 }, spd = { 15, 40 }, sprd = { 180, 180 }, burst = 60, off = { 0, 30, 0 }, light = 1.4, dur = 1 },
		P { tex = "spark", col = { "#eff6ff", "#7aa8ff" }, sz = { 0.2, 0.6 }, life = { 0.6, 1.4 }, spd = { 20, 50 }, sprd = { 180, 180 }, drag = 3, burst = 80, dur = 1.4 },
		L { col = "#c0d8ff", bright = 18, range = 60, dur = 0.4 },
	}),
	-- 07
	preset("Static Discharge", { "static", "small", "spark" }, 1, {
		P { tex = "electric", col = { "#ffffff", "#c8e0ff" }, sz = { 0.15, 0.5 }, life = { 0.1, 0.3 }, spd = { 4, 14 }, sprd = { 180, 180 }, burst = 26, rotspd = { -300, 300 }, light = 1.1, dur = 0.6 },
		P { tex = "spark", col = { "#ffffff", "#9ac4ff" }, sz = { 0.06, 0.16 }, life = { 0.2, 0.5 }, spd = { 6, 18 }, sprd = { 180, 180 }, burst = 20, drag = 6, dur = 0.7 },
	}),
	-- 08
	preset("EMP Pulse", { "emp", "pulse", "tech" }, 1.8, {
		P { tex = "glow", col = { "#ffffff", "#8ab8ff", "#2a4aff" }, trn = { 0, 0.5, 1 }, sz = { 2, 10 }, life = { 0.6, 1 }, spd = { 40, 52 }, sprd = { 3, 3 }, shape = "Cylinder", style = "Surface", partial = 0.05, rate = 200, light = 1.5, dur = 1 },
		P { tex = "electric", col = { "#dff0ff", "#6a9aff" }, sz = { 0.4, 1.4 }, life = { 0.2, 0.6 }, spd = { 15, 40 }, sprd = { 180, 180 }, burst = 40, dur = 0.8 },
		B { tex = "electric", col = { "#ffffff", "#7aaaff" }, trn = { 0, 1 }, w0 = 0.5, w1 = 0.05, segments = 20, curve = 0, light = 1.6, off0 = { -10, 0, 0 }, off1 = { 10, 0, 0 }, at = 0.15, dur = 0.3 },
		L { col = "#8ab8ff", bright = 10, range = 34, dur = 0.5 },
	}),
	-- 09
	preset("Volt Surge", { "surge", "aura", "loop" }, 2.4, {
		P { tex = "spark", col = { "#ffffff", "#a8d0ff" }, sz = { 0.2, 0.6 }, life = { 0.4, 1 }, spd = { 2, 8 }, sprd = { 30, 30 }, rate = 40, accel = { 0, 12, 0 }, light = 1.2, dur = 2.4, shape = "Disc" },
		P { tex = "electric", col = { "#eaf6ff", "#8ab8ff" }, sz = { 0.3, 1 }, life = { 0.2, 0.5 }, spd = { 4, 14 }, sprd = { 180, 180 }, rate = 24, rotspd = { -240, 240 }, dur = 2.4 },
		L { col = "#9ac4ff", bright = 4, range = 14, dur = 2.4 },
	}, { loop = true }),
	-- 10
	preset("Thunder Cloud", { "cloud", "storm", "loop" }, 4.4, {
		P { tex = "smoke", col = { "#5a6472", "#2a3038", "#10141a" }, trn = { 0.4, 0.8, 0.95 }, sz = { 8, 26 }, life = { 2.6, 4.2 }, spd = { 1, 4 }, sprd = { 180, 180 }, rate = 22, off = { 0, 20, 0 }, dur = 4.4 },
		B { tex = "electric", col = { "#ffffff", "#a8c8ff" }, trn = { 0, 1 }, w0 = 1.2, w1 = 0.1, segments = 22, curve = 2.4, light = 1.6, off0 = { 0, 20, 0 }, off1 = { 2, 6, 1 }, at = 1.2, dur = 0.25 },
		B { tex = "electric", col = { "#ffffff", "#a8c8ff" }, trn = { 0, 1 }, w0 = 1, w1 = 0.08, segments = 20, curve = -2, light = 1.5, off0 = { 0, 20, 0 }, off1 = { -3, 7, -2 }, at = 2.8, dur = 0.25 },
		L { col = "#a8c8ff", bright = 6, range = 40, off = { 0, 18, 0 }, dur = 4.4 },
	}, { loop = true }),
	-- 11
	preset("Crackling Aura", { "aura", "crackle", "loop" }, 2, {
		P { tex = "electric", col = { "#e8f8ff", "#7ab8ff" }, trn = { 0.2, 0.9, 1 }, sz = { 0.25, 0.9 }, life = { 0.15, 0.5 }, spd = { 2, 8 }, sprd = { 180, 180 }, rate = 50, shape = "Sphere", rotspd = { -320, 320 }, light = 1.3, dur = 2 },
		P { tex = "sparkle", col = { "#ffffff", "#a8d0ff" }, sz = { 0.08, 0.22 }, life = { 0.3, 0.8 }, spd = { 1, 4 }, sprd = { 180, 180 }, rate = 30, dur = 2 },
		L { col = "#8ac0ff", bright = 3, range = 12, dur = 2 },
	}, { loop = true }),
	-- 12
	preset("Lightning Ring", { "ring", "aoe", "electric" }, 1.6, {
		P { tex = "electric", col = { "#ffffff", "#a8d0ff" }, trn = { 0, 0.85, 1 }, sz = { 0.4, 1.4 }, life = { 0.3, 0.7 }, spd = { 12, 26 }, sprd = { 4, 4 }, shape = "Cylinder", style = "Surface", partial = 0.15, rate = 120, rotspd = { -200, 200 }, light = 1.5, dur = 1.2 },
		B { tex = "glow", col = { "#ffffff", "#6a9aff" }, trn = { 0.1, 0.9 }, w0 = 0.5, w1 = 0.1, segments = 28, curve = 0, light = 1.4, off0 = { -6, 0.2, 0 }, off1 = { 6, 0.2, 0 }, dur = 0.9 },
		A { target = "rig", property = "spin", from = 0, to = 180, dur = 1.6, easing = "Linear" },
		L { col = "#9ac4ff", bright = 6, range = 22, dur = 1 },
	}),
	-- 13
	preset("Forked Bolt", { "fork", "branch", "bolt" }, 1.2, {
		B { tex = "electric", col = { "#ffffff", "#a8c8ff" }, trn = { 0, 0.7, 1 }, w0 = 1.8, w1 = 0.15, segments = 28, curve = 2.6, light = 1.7, off0 = { 0, 28, 0 }, off1 = { 0, 0, 0 }, dur = 0.25 },
		B { tex = "electric", col = { "#ffffff", "#a8c8ff" }, trn = { 0, 0.8, 1 }, w0 = 0.7, w1 = 0.05, segments = 18, curve = -2.2, light = 1.4, off0 = { 0, 28, 0 }, off1 = { 7, 10, 2 }, dur = 0.25 },
		P { tex = "electric", col = { "#ffffff", "#9ac4ff" }, sz = { 0.5, 1.8 }, life = { 0.2, 0.6 }, spd = { 20, 50 }, sprd = { 180, 180 }, burst = 40, light = 1.3, dur = 0.7 },
		L { col = "#a8c8ff", bright = 10, range = 34, dur = 0.3 },
	}),
	-- 14
	preset("Plasma Stream", { "stream", "plasma", "loop" }, 2, {
		P { tex = "glow", col = { "#ffffff", "#9fd8ff", "#3a8aff" }, trn = { 0, 0.6, 1 }, sz = { 0.8, 2.6 }, life = { 0.3, 0.7 }, spd = { 30, 46 }, sprd = { 5, 5 }, rate = 140, light = 1.6, orient = "VelocityParallel", dur = 2 },
		P { tex = "electric", col = { "#eaf8ff", "#7ab8ff" }, sz = { 0.2, 0.8 }, life = { 0.2, 0.5 }, spd = { 32, 52 }, sprd = { 8, 8 }, rate = 40, dur = 2 },
		L { col = "#8ac8ff", bright = 5, range = 16, dur = 2 },
	}, { loop = true }),
	-- 15
	preset("Electric Whip", { "whip", "beam", "melee" }, 1.4, {
		B { tex = "electric", col = { "#ffffff", "#9ac4ff", "#4a6aff" }, trn = { 0, 0.5, 1 }, w0 = 0.6, w1 = 0.08, segments = 24, curve = 2.8, light = 1.6, texlen = 0.3, texspd = 0.6, off0 = { 0, 0, 0 }, off1 = { 6, 1.8, 1.2 }, dur = 0.5 },
		P { tex = "electric", col = { "#ffffff", "#8ab8ff" }, sz = { 0.2, 0.7 }, life = { 0.15, 0.5 }, spd = { 8, 20 }, sprd = { 180, 180 }, burst = 30, dur = 0.5 },
		L { col = "#9ac4ff", bright = 5, range = 16, dur = 0.4 },
	}),
	-- 16
	preset("Storm Call", { "summon", "cloud", "loop" }, 5, {
		P { tex = "smoke", col = { "#4a5462", "#242a34", "#0c1016" }, trn = { 0.35, 0.8, 0.95 }, sz = { 10, 34 }, life = { 2.4, 4 }, spd = { 2, 6 }, sprd = { 180, 180 }, rate = 26, off = { 0, 26, 0 }, dur = 5 },
		B { tex = "electric", col = { "#ffffff", "#c0d8ff" }, trn = { 0, 1 }, w0 = 1.4, w1 = 0.1, segments = 24, curve = 2.8, light = 1.8, off0 = { 0, 26, 0 }, off1 = { 1, 4, 0 }, at = 0.8, dur = 0.25 },
		B { tex = "electric", col = { "#ffffff", "#c0d8ff" }, trn = { 0, 1 }, w0 = 1.2, w1 = 0.08, segments = 22, curve = -2.4, light = 1.6, off0 = { 0, 26, 0 }, off1 = { -4, 5, 2 }, at = 2, dur = 0.25 },
		B { tex = "electric", col = { "#ffffff", "#c0d8ff" }, trn = { 0, 1 }, w0 = 1.5, w1 = 0.1, segments = 26, curve = 3, light = 1.9, off0 = { 0, 26, 0 }, off1 = { 3, 2, -2 }, at = 3.4, dur = 0.3 },
		L { col = "#c0d8ff", bright = 9, range = 50, off = { 0, 24, 0 }, dur = 5 },
	}, { loop = true }),
	-- 17
	preset("Spark Shower", { "shower", "falling", "loop" }, 3, {
		P { tex = "spark", col = { "#ffffff", "#ffd98a", "#ff8a1f" }, trn = { 0.1, 0.7, 1 }, sz = { 0.12, 0.4 }, life = { 1, 2 }, spd = { 2, 10 }, sprd = { 10, 10 }, rate = 70, accel = { 0, -24, 0 }, off = { 0, 12, 0 }, shape = "Box", light = 1.2, orient = "VelocityParallel", dur = 3 },
		L { col = "#ffb347", bright = 2, range = 16, off = { 0, 8, 0 }, dur = 3 },
	}, { loop = true }),
	-- 18
	preset("Ion Trail", { "trail", "ion", "loop" }, 2.6, {
		T { tex = "glow", col = { "#ffffff", "#9fd8ff", "#3a8aff" }, trn = { 0, 0.4, 1 }, lifetime = 0.8, minLength = 0.1, widthScale = 1.4, light = 1.5, dur = 2.6 },
		P { tex = "electric", col = { "#eaf8ff", "#8ac8ff" }, sz = { 0.15, 0.5 }, life = { 0.2, 0.6 }, spd = { 1, 5 }, sprd = { 180, 180 }, rate = 26, dur = 2.6 },
		P { tex = "spark", col = { "#ffffff", "#7ab8ff" }, sz = { 0.06, 0.18 }, life = { 0.3, 0.8 }, spd = { 2, 6 }, sprd = { 180, 180 }, rate = 20, dur = 2.6 },
	}, { loop = true }),
	-- 19
	preset("Surge Impact", { "impact", "hit", "burst" }, 1, {
		P { tex = "electric", col = { "#ffffff", "#a8d0ff" }, sz = { 0.3, 1.2 }, life = { 0.15, 0.5 }, spd = { 14, 36 }, sprd = { 180, 180 }, burst = 34, rotspd = { -300, 300 }, light = 1.4, dur = 0.6 },
		P { tex = "spark", col = { "#ffffff", "#7ab8ff" }, sz = { 0.08, 0.25 }, life = { 0.25, 0.6 }, spd = { 20, 44 }, sprd = { 180, 180 }, drag = 6, burst = 28, dur = 0.7 },
		L { col = "#a8d0ff", bright = 7, range = 18, dur = 0.3 },
	}),
	-- 20
	preset("Arc Web", { "web", "multi", "trap" }, 1.6, {
		B { tex = "electric", col = { "#ffffff", "#9ac4ff" }, trn = { 0, 0.85 }, w0 = 0.3, w1 = 0.05, segments = 14, curve = 1.4, light = 1.4, off0 = { 0, 1, 0 }, off1 = { 3.4, 2.6, 0 }, dur = 1.2 },
		B { tex = "electric", col = { "#ffffff", "#9ac4ff" }, trn = { 0, 0.85 }, w0 = 0.3, w1 = 0.05, segments = 14, curve = -1.4, light = 1.4, off0 = { 0, 1, 0 }, off1 = { -3.2, 2.2, 1 }, dur = 1.2 },
		B { tex = "electric", col = { "#ffffff", "#9ac4ff" }, trn = { 0, 0.85 }, w0 = 0.3, w1 = 0.05, segments = 14, curve = 1.2, light = 1.4, off0 = { 0, 1, 0 }, off1 = { 0.6, 3, -3 }, dur = 1.2 },
		B { tex = "electric", col = { "#ffffff", "#9ac4ff" }, trn = { 0, 0.85 }, w0 = 0.3, w1 = 0.05, segments = 14, curve = -1.2, light = 1.4, off0 = { 0, 1, 0 }, off1 = { -1, 0.4, 3.2 }, dur = 1.2 },
		P { tex = "electric", col = { "#eaf8ff", "#8ab8ff" }, sz = { 0.2, 0.7 }, life = { 0.2, 0.6 }, spd = { 4, 12 }, sprd = { 180, 180 }, rate = 30, dur = 1.4 },
		L { col = "#9ac4ff", bright = 4, range = 14, dur = 1.2 },
	}),
	-- 21
	preset("Thunder Shockwave", { "shockwave", "thunder", "ring" }, 1.4, {
		P { tex = "glow", col = { "#ffffff", "#bcd8ff", "#4a6aff" }, trn = { 0, 0.6, 1 }, sz = { 1.5, 8 }, life = { 0.5, 0.9 }, spd = { 46, 56 }, sprd = { 3, 3 }, shape = "Cylinder", style = "Surface", partial = 0.05, rate = 160, light = 1.4, dur = 0.8 },
		P { tex = "smoke", col = { "#c8d4e4", "#7a8698" }, trn = { 0.8, 1 }, sz = { 4, 12 }, life = { 0.6, 1.2 }, spd = { 26, 34 }, sprd = { 6, 6 }, shape = "Cylinder", style = "Surface", partial = 0.08, rate = 60, dur = 1 },
		L { col = "#bcd8ff", bright = 6, range = 26, dur = 0.5 },
	}),
	-- 22
	preset("Volt Orb", { "orb", "pulse", "loop" }, 2.8, {
		P { tex = "glow", col = { "#ffffff", "#a8d0ff", "#3a5aff" }, trn = { 0, 0.35, 0.85 }, sz = { 2, 4 }, life = { 0.4, 0.9 }, spd = { 0.2, 1 }, sprd = { 180, 180 }, rate = 30, light = 1.6, shape = "Sphere", dur = 2.8, off = { 0, 1.5, 0 } },
		P { tex = "electric", col = { "#f0f8ff", "#8ab8ff" }, sz = { 0.3, 1 }, life = { 0.2, 0.6 }, spd = { 2, 8 }, sprd = { 180, 180 }, rate = 34, rotspd = { -280, 280 }, dur = 2.8, off = { 0, 1.5, 0 } },
		A { target = "OrbLight", property = "brightness", from = 3, to = 8, dur = 0.7, repeatCount = -1, reverse = true, easing = "Sine" },
		L { col = "#8ab8ff", bright = 5, range = 16, off = { 0, 1.5, 0 }, dur = 2.8 },
	}, { loop = true }),
}
