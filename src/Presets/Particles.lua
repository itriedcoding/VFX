--[[
	Particles - 22 standalone particle systems for ambience, fountains,
	celebrations and fills. These are the building blocks developers reach for
	when decorating a scene rather than detonating it.
]]

local DSL = require(script.Parent.DSL)

local P, B, T, L, M, A = DSL.P, DSL.B, DSL.T, DSL.L, DSL.M, DSL.A

local function preset(name: string, tags: { string }, duration: number, components: { any }, extra: any?)
	return DSL.preset(name, "Particles", tags, duration, components, extra)
end

return {
	-- 01
	preset("Floating Motes", { "ambient", "motes", "loop" }, 5, {
		P { tex = "glow", col = { "#ffffff", "#d8e8ff", "#8aa8d0" }, trn = { 0.4, 0.85, 1 }, sz = { 0.06, 0.24 }, life = { 2.5, 4.5 }, spd = { 0.05, 0.6 }, sprd = { 180, 180 }, rate = 22, accel = { 0.1, 0.2, 0 }, shape = "Box", light = 0.8, dur = 5 },
	}, { loop = true }),
	-- 02
	preset("Spark Fountain", { "fountain", "sparks", "loop" }, 2.6, {
		P { tex = "spark", col = { "#fff8d0", "#ffb01f", "#c94a00" }, trn = { 0, 0.6, 1 }, sz = { 0.1, 0.35 }, life = { 0.8, 1.6 }, spd = { 14, 26 }, sprd = { 12, 12 }, rate = 70, accel = { 0, -30, 0 }, light = 1.3, orient = "VelocityParallel", shape = "Disc", dur = 2.6 },
		P { tex = "glow", col = { "#fff8d0", "#ffb01f" }, trn = { 0.6, 0.9, 1 }, sz = { 0.2, 0.6 }, life = { 0.6, 1.2 }, spd = { 10, 20 }, sprd = { 14, 14 }, rate = 24, accel = { 0, -28, 0 }, dur = 2.6 },
		L { col = "#ffb01f", bright = 2, range = 12, dur = 2.6 },
	}, { loop = true }),
	-- 03
	preset("Bubble Column", { "bubbles", "water", "loop" }, 3, {
		P { tex = "glow", col = { "#ffffff", "#bfe8ff", "#5aa8e0" }, trn = { 0.3, 0.7, 1 }, sz = { 0.2, 0.8 }, life = { 1.6, 3 }, spd = { 2, 6 }, sprd = { 8, 8 }, rate = 26, accel = { 0, 4, 0 }, shape = "Disc", light = 1, dur = 3 },
		P { tex = "sparkle", col = { "#ffffff", "#dff4ff" }, trn = { 0.2, 0.8, 1 }, sz = { 0.06, 0.2 }, life = { 1, 2 }, spd = { 3, 7 }, sprd = { 10, 10 }, rate = 18, accel = { 0, 5, 0 }, dur = 3 },
	}, { loop = true }),
	-- 04
	preset("Confetti Burst", { "confetti", "celebration", "party" }, 2.4, {
		P { tex = "square", col = { "#ff5a5a", "#ffd75a", "#5aff8a", "#5a9dff", "#c95aff" }, trn = { 0, 0.3, 1 }, sz = { 0.2, 0.5 }, life = { 1.2, 2.4 }, spd = { 10, 30 }, sprd = { 180, 180 }, burst = 90, accel = { 0, -25, 0 }, rot = { 0, 360 }, rotspd = { -400, 400 }, drag = 1.5, dur = 2.2, orient = "VelocityParallel" },
		P { tex = "square", col = { "#ffffff", "#ffd75a" }, trn = { 0.2, 0.8, 1 }, sz = { 0.1, 0.3 }, life = { 1.6, 2.6 }, spd = { 4, 12 }, sprd = { 180, 180 }, burst = 30, accel = { 0, -18, 0 }, rotspd = { -200, 200 }, dur = 2.4 },
	}),
	-- 05
	preset("Glitter Burst", { "glitter", "sparkle", "shimmer" }, 1.6, {
		P { tex = "sparkle", col = { "#ffffff", "#ffe8a0", "#ffb0f0" }, trn = { 0, 0.4, 1 }, sz = { 0.08, 0.35 }, life = { 0.8, 1.6 }, spd = { 8, 24 }, sprd = { 180, 180 }, burst = 70, drag = 4, light = 1.3, rotspd = { -120, 120 }, dur = 1.4 },
		L { col = "#ffe8a0", bright = 3, range = 14, dur = 0.5 },
	}),
	-- 06
	preset("Fireflies", { "fireflies", "ambient", "loop" }, 5, {
		P { tex = "glow", col = { "#f0ffb0", "#a8e04a", "#3a7a1f" }, trn = { 0.1, 0.7, 1 }, sz = { 0.08, 0.28 }, life = { 2.4, 4 }, spd = { 0.1, 0.8 }, sprd = { 180, 180 }, rate = 14, shape = "Box", light = 1.2, accel = { 0.1, 0.15, 0.1 }, dur = 5 },
	}, { loop = true }),
	-- 07
	preset("Dust Motes", { "dust", "ambient", "loop" }, 5, {
		P { tex = "dust", col = { "#e6dccb", "#b8a88f", "#7a6d58" }, trn = { 0.5, 0.85, 1 }, sz = { 0.05, 0.2 }, life = { 3, 5 }, spd = { 0.05, 0.5 }, sprd = { 180, 180 }, rate = 18, shape = "Box", dur = 5 },
	}, { loop = true }),
	-- 08
	preset("Star Field", { "stars", "space", "loop" }, 6, {
		P { tex = "star", col = { "#ffffff", "#d8e8ff", "#a8c8ff" }, trn = { 0.2, 0.75, 1 }, sz = { 0.06, 0.26 }, life = { 3, 6 }, spd = { 0.02, 0.2 }, sprd = { 180, 180 }, rate = 16, shape = "Box", rotspd = { -20, 20 }, light = 1, dur = 6 },
	}, { loop = true }),
	-- 09
	preset("Pollen Drift", { "pollen", "nature", "loop" }, 5, {
		P { tex = "sparkle", col = { "#ffffe0", "#e8f0a0", "#c8d86a" }, trn = { 0.3, 0.8, 1 }, sz = { 0.05, 0.2 }, life = { 2.5, 4.5 }, spd = { 0.1, 0.7 }, sprd = { 180, 180 }, rate = 20, shape = "Box", accel = { 0.2, 0.1, 0 }, light = 0.4, dur = 5 },
	}, { loop = true }),
	-- 10
	preset("Bubble Pop", { "bubble", "pop", "small" }, 1, {
		P { tex = "glow", col = { "#ffffff", "#bfe8ff" }, trn = { 0.2, 0.8, 1 }, sz = { 0.2, 0.6 }, life = { 0.15, 0.35 }, spd = { 2, 6 }, sprd = { 180, 180 }, burst = 14, dur = 0.4 },
		P { tex = "sparkle", col = { "#ffffff", "#dff4ff" }, sz = { 0.05, 0.16 }, life = { 0.3, 0.7 }, spd = { 3, 9 }, sprd = { 180, 180 }, burst = 12, dur = 0.7 },
	}),
	-- 11
	preset("Waterfall Splash", { "water", "splash", "loop" }, 3, {
		P { tex = "glow", col = { "#ffffff", "#bfe8ff", "#5aa8e0" }, trn = { 0.2, 0.7, 1 }, sz = { 0.1, 0.4 }, life = { 0.6, 1.2 }, spd = { 6, 16 }, sprd = { 30, 30 }, rate = 60, accel = { 0, -18, 0 }, dur = 3 },
		P { tex = "smoke", col = { "#ffffff", "#c8e0f0" }, trn = { 0.85, 0.95, 1 }, sz = { 0.6, 2.2 }, life = { 0.8, 1.6 }, spd = { 2, 6 }, sprd = { 40, 40 }, rate = 16, dur = 3 },
	}, { loop = true }),
	-- 12
	preset("Sand Swirl", { "sand", "swirl", "loop" }, 3.4, {
		P { tex = "dust", col = { "#e6cf9e", "#b08a52", "#6b5230" }, trn = { 0.4, 0.85, 1 }, sz = { 0.2, 0.8 }, life = { 1.2, 2.2 }, spd = { 3, 8 }, sprd = { 30, 30 }, rate = 40, shape = "Cylinder", style = "Surface", partial = 0.5, accel = { 0, 4, 0 }, dur = 3.4 },
		A { name = "Swirl", target = "rig", property = "spin", from = 0, to = 360, dur = 3.4, easing = "Linear" },
	}, { loop = true }),
	-- 13
	preset("Plasma Motes", { "plasma", "motes", "loop" }, 3, {
		P { tex = "glow", col = { "#ffffff", "#8affff", "#2a6aff" }, trn = { 0.2, 0.7, 1 }, sz = { 0.08, 0.3 }, life = { 1.4, 2.6 }, spd = { 0.2, 1.2 }, sprd = { 180, 180 }, rate = 22, shape = "Sphere", light = 1.4, dur = 3 },
		L { col = "#4affff", bright = 1.5, range = 10, dur = 3 },
	}, { loop = true }),
	-- 14
	preset("Crystal Motes", { "crystal", "motes", "loop" }, 3, {
		P { tex = "sparkle", col = { "#ffffff", "#c9f0ff", "#5ab0d9" }, trn = { 0.2, 0.75, 1 }, sz = { 0.06, 0.24 }, life = { 1.6, 3 }, spd = { 0.1, 0.8 }, sprd = { 180, 180 }, rate = 18, rotspd = { -40, 40 }, light = 1.1, shape = "Box", dur = 3 },
	}, { loop = true }),
	-- 15
	preset("Magic Bubbles", { "bubbles", "magic", "loop" }, 3, {
		P { tex = "glow", col = { "#ffffff", "#d0b0ff", "#7a3aff" }, trn = { 0.25, 0.75, 1 }, sz = { 0.15, 0.6 }, life = { 1.4, 2.6 }, spd = { 1, 4 }, sprd = { 20, 20 }, rate = 22, accel = { 0, 2, 0 }, light = 1.2, shape = "Disc", dur = 3 },
		P { tex = "sparkle", col = { "#efe0ff", "#b88aff" }, sz = { 0.05, 0.18 }, life = { 0.8, 1.8 }, spd = { 1, 3 }, sprd = { 30, 30 }, rate = 14, dur = 3 },
		L { col = "#b88aff", bright = 1.5, range = 10, dur = 3 },
	}, { loop = true }),
	-- 16
	preset("Snow Drift", { "snow", "winter", "loop" }, 5, {
		P { tex = "puff", col = { "#ffffff", "#e8f4ff", "#c0dcef" }, trn = { 0.2, 0.7, 1 }, sz = { 0.08, 0.3 }, life = { 3, 5 }, spd = { 0.2, 1.2 }, sprd = { 20, 20 }, rate = 30, accel = { 0, -1.2, 0 }, shape = "Box", rotspd = { -40, 40 }, dur = 5 },
	}, { loop = true }),
	-- 17
	preset("Petal Fall", { "petals", "nature", "loop" }, 5, {
		P { tex = "debris", col = { "#ffd0e0", "#ff8ab0", "#c94a7a" }, trn = { 0.1, 0.7, 1 }, sz = { 0.12, 0.4 }, life = { 2.5, 4.5 }, spd = { 0.2, 1.4 }, sprd = { 60, 60 }, rate = 22, accel = { 0, -1, 0 }, rot = { 0, 360 }, rotspd = { -90, 90 }, shape = "Box", dur = 5 },
	}, { loop = true }),
	-- 18
	preset("Ash Motes", { "ash", "dark", "loop" }, 4, {
		P { tex = "dust", col = { "#8a8a8a", "#5a5a5a", "#2e2e2e" }, trn = { 0.4, 0.8, 1 }, sz = { 0.06, 0.24 }, life = { 2, 3.6 }, spd = { 0.1, 0.8 }, sprd = { 180, 180 }, rate = 24, accel = { 0.1, -0.4, 0 }, shape = "Box", light = 0.2, dur = 4 },
	}, { loop = true }),
	-- 19
	preset("Energy Motes", { "energy", "motes", "loop" }, 2.6, {
		P { tex = "spark", col = { "#ffffff", "#8ad0ff", "#3a5aff" }, trn = { 0.1, 0.7, 1 }, sz = { 0.06, 0.24 }, life = { 0.8, 1.8 }, spd = { 1, 5 }, sprd = { 60, 60 }, rate = 30, accel = { 0, 4, 0 }, light = 1.3, shape = "Disc", dur = 2.6 },
		L { col = "#8ad0ff", bright = 1.5, range = 10, dur = 2.6 },
	}, { loop = true }),
	-- 20
	preset("Sparkle Rain", { "rain", "sparkle", "falling" }, 3, {
		P { tex = "sparkle", col = { "#ffffff", "#c9e8ff", "#8ab8ff" }, trn = { 0.1, 0.6, 1 }, sz = { 0.06, 0.24 }, life = { 1.2, 2.2 }, spd = { 4, 10 }, sprd = { 8, 8 }, rate = 50, accel = { 0, -12, 0 }, shape = "Box", off = { 0, 10, 0 }, light = 1.1, dur = 3 },
	}),
	-- 21
	preset("Orbiting Sparks", { "orbit", "sparks", "loop" }, 2.4, {
		P { tex = "spark", col = { "#ffffff", "#ffd08a", "#ff8a1f" }, trn = { 0.1, 0.8, 1 }, sz = { 0.06, 0.22 }, life = { 1.2, 2 }, spd = { 0.2, 1 }, sprd = { 4, 4 }, rate = 40, shape = "Cylinder", style = "Surface", partial = 0.4, light = 1.2, off = { 0, 1, 0 }, dur = 2.4 },
		A { name = "Orbit", target = "rig", property = "spin", from = 0, to = 360, dur = 2.4, easing = "Linear" },
		L { col = "#ffb347", bright = 1.5, range = 10, off = { 0, 1, 0 }, dur = 2.4 },
	}, { loop = true }),
	-- 22
	preset("Glint Burst", { "glint", "flash", "small" }, 0.8, {
		P { tex = "star", col = { "#ffffff", "#e8f4ff" }, trn = { 0, 0.3, 1 }, sz = { 0.1, 0.5 }, life = { 0.25, 0.6 }, spd = { 2, 8 }, sprd = { 180, 180 }, burst = 16, light = 1.4, dur = 0.5 },
		L { col = "#ffffff", bright = 3, range = 8, dur = 0.25 },
	}),
}
