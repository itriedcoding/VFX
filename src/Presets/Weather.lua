--[[
	Weather - 22 environmental systems. These are wide, high and looping: rain
	sheets, blizzards, sandstorms and storms built from layered emitters plus
	occasional bolt or flash tracks.
]]

local DSL = require(script.Parent.DSL)

local P, B, T, L, M, A = DSL.P, DSL.B, DSL.T, DSL.L, DSL.M, DSL.A

local function preset(name: string, tags: { string }, duration: number, components: { any }, extra: any?)
	return DSL.preset(name, "Weather", tags, duration, components, extra)
end

return {
	-- 01
	preset("Rain", { "rain", "loop", "ambient" }, 4, {
		P { tex = "spark", col = { "#dff0ff", "#a8c8e0", "#6a8aa8" }, trn = { 0.3, 0.6, 0.9 }, sz = { 0.06, 0.2 }, life = { 0.8, 1.4 }, spd = { 40, 55 }, sprd = { 2, 2 }, rate = 220, accel = { 0, -30, 0 }, shape = "Box", off = { 0, 20, 0 }, orient = "VelocityParallel", drag = 0.2, dur = 4 },
	}, { loop = true }),
	-- 02
	preset("Heavy Rain", { "rain", "storm", "loop" }, 4.4, {
		P { tex = "spark", col = { "#dff0ff", "#9ac0e0", "#5a7a98" }, trn = { 0.2, 0.55, 0.9 }, sz = { 0.08, 0.26 }, life = { 0.7, 1.2 }, spd = { 55, 75 }, sprd = { 2, 2 }, rate = 380, accel = { 0, -35, 0 }, shape = "Box", off = { 0, 22, 0 }, orient = "VelocityParallel", dur = 4.4 },
		P { tex = "smoke", col = { "#c8d8e8", "#7a8a9a" }, trn = { 0.92, 1 }, sz = { 6, 16 }, life = { 2, 3.4 }, spd = { 0.5, 2 }, sprd = { 180, 180 }, rate = 10, off = { 0, 2, 0 }, dur = 4.4 },
	}, { loop = true }),
	-- 03
	preset("Thunderstorm", { "storm", "thunder", "loop" }, 5, {
		P { tex = "spark", col = { "#dff0ff", "#a8c8e0" }, trn = { 0.2, 0.6, 0.9 }, sz = { 0.07, 0.24 }, life = { 0.7, 1.3 }, spd = { 45, 65 }, sprd = { 2, 2 }, rate = 300, accel = { 0, -32, 0 }, shape = "Box", off = { 0, 24, 0 }, orient = "VelocityParallel", dur = 5 },
		P { tex = "smoke", col = { "#5a6472", "#242a34" }, trn = { 0.6, 0.9, 1 }, sz = { 10, 30 }, life = { 3, 5 }, spd = { 1, 4 }, sprd = { 180, 180 }, rate = 16, off = { 0, 30, 0 }, dur = 5 },
		B { tex = "electric", col = { "#ffffff", "#c0d8ff" }, trn = { 0, 1 }, w0 = 1.6, w1 = 0.1, segments = 24, curve = 2.6, light = 1.8, off0 = { 0, 34, 0 }, off1 = { 2, 2, 1 }, at = 1.4, dur = 0.28 },
		B { tex = "electric", col = { "#ffffff", "#c0d8ff" }, trn = { 0, 1 }, w0 = 1.3, w1 = 0.08, segments = 22, curve = -2.2, light = 1.6, off0 = { 0, 34, 0 }, off1 = { -3, 3, -2 }, at = 3.2, dur = 0.28 },
		L { col = "#c0d8ff", bright = 8, range = 50, off = { 0, 24, 0 }, dur = 5 },
	}, { loop = true }),
	-- 04
	preset("Snowfall", { "snow", "winter", "loop" }, 6, {
		P { tex = "puff", col = { "#ffffff", "#e8f4ff", "#c0dcef" }, trn = { 0.1, 0.6, 1 }, sz = { 0.08, 0.3 }, life = { 4, 6 }, spd = { 0.4, 1.4 }, sprd = { 15, 15 }, rate = 120, accel = { 0, -1.5, 0 }, shape = "Box", off = { 0, 24, 0 }, rotspd = { -30, 30 }, dur = 6 },
	}, { loop = true }),
	-- 05
	preset("Blizzard", { "blizzard", "snow", "loop" }, 6, {
		P { tex = "puff", col = { "#ffffff", "#dff0ff", "#b0ccdf" }, trn = { 0.2, 0.7, 1 }, sz = { 0.1, 0.4 }, life = { 2.4, 4 }, spd = { 8, 18 }, sprd = { 20, 20 }, rate = 200, accel = { 0, -6, 0 }, shape = "Box", off = { 0, 18, 0 }, dur = 6 },
		P { tex = "smoke", col = { "#ffffff", "#dce8f4" }, trn = { 0.9, 1 }, sz = { 8, 22 }, life = { 2, 3.4 }, spd = { 6, 14 }, sprd = { 40, 40 }, rate = 20, off = { 0, 8, 0 }, dur = 6 },
		A { name = "BlizzardSpin", target = "rig", property = "spin", from = 0, to = 60, dur = 6, easing = "Linear" },
	}, { loop = true }),
	-- 06
	preset("Hail", { "hail", "ice", "loop" }, 3, {
		P { tex = "debris", col = { "#ffffff", "#dff4ff", "#9ac8e0" }, trn = { 0.05, 0.4, 1 }, sz = { 0.15, 0.5 }, life = { 0.5, 1 }, spd = { 50, 70 }, sprd = { 3, 3 }, rate = 90, accel = { 0, -40, 0 }, shape = "Box", off = { 0, 20, 0 }, orient = "VelocityParallel", light = 0.6, dur = 3 },
	}, { loop = true }),
	-- 07
	preset("Heavy Fog", { "fog", "ambient", "loop" }, 7, {
		P { tex = "smoke", col = { "#e6eef7", "#b8c6d6", "#7d8b9c" }, trn = { 0.88, 0.96, 1 }, sz = { 20, 46 }, life = { 5, 7 }, spd = { 0.1, 0.6 }, sprd = { 180, 180 }, rate = 14, shape = "Box", off = { 0, 3, 0 }, squash = 0.7, dur = 7 },
	}, { loop = true }),
	-- 08
	preset("Wind Gust", { "wind", "leaves", "loop" }, 3, {
		P { tex = "smoke", col = { "#dff0ff", "#a8c0d8" }, trn = { 0.92, 1 }, sz = { 4, 10 }, life = { 1.4, 2.4 }, spd = { 20, 34 }, sprd = { 12, 12 }, rate = 26, shape = "Box", off = { 0, 2, 0 }, orient = "VelocityParallel", dur = 3 },
		P { tex = "debris", col = { "#d8ff9a", "#8aa85a" }, trn = { 0.2, 0.8, 1 }, sz = { 0.08, 0.3 }, life = { 1.4, 2.6 }, spd = { 22, 38 }, sprd = { 20, 20 }, rate = 20, rotspd = { -120, 120 }, off = { 0, 1, 0 }, dur = 3 },
	}, { loop = true }),
	-- 09
	preset("Sandstorm", { "sand", "desert", "loop" }, 5, {
		P { tex = "dust", col = { "#e6cf9e", "#b08a52", "#6b5230" }, trn = { 0.5, 0.9, 1 }, sz = { 1, 4 }, life = { 1.6, 3 }, spd = { 22, 38 }, sprd = { 20, 20 }, rate = 140, accel = { 0, -2, 0 }, shape = "Box", off = { 0, 6, 0 }, light = 0.2, dur = 5 },
		P { tex = "smoke", col = { "#d8c2a0", "#7a6644" }, trn = { 0.9, 1 }, sz = { 10, 26 }, life = { 2.4, 4 }, spd = { 14, 24 }, sprd = { 40, 40 }, rate = 18, off = { 0, 4, 0 }, dur = 5 },
		A { name = "GustSpin", target = "rig", property = "spin", from = 0, to = 40, dur = 5, easing = "Linear" },
	}, { loop = true }),
	-- 10
	preset("Tornado", { "tornado", "vortex", "loop" }, 5, {
		P { tex = "smoke", col = { "#9aa4b0", "#5a6472", "#2a3038" }, trn = { 0.55, 0.9, 1 }, sz = { 4, 12 }, life = { 1.6, 2.8 }, spd = { 8, 16 }, sprd = { 10, 10 }, shape = "Cylinder", style = "Surface", partial = 0.9, rate = 120, accel = { 0, 16, 0 }, rotspd = { -140, 140 }, off = { 0, 6, 0 }, dur = 5 },
		P { tex = "debris", col = { "#8a7a62", "#3a3226" }, sz = { 0.2, 0.8 }, life = { 1.2, 2.4 }, spd = { 10, 22 }, sprd = { 30, 30 }, shape = "Cylinder", style = "Surface", partial = 0.6, rate = 30, accel = { 0, 10, 0 }, off = { 0, 4, 0 }, dur = 5 },
		A { name = "TornadoSpin", target = "rig", property = "spin", from = 0, to = 360, dur = 5, easing = "Linear" },
	}, { loop = true }),
	-- 11
	preset("Acid Rain", { "acid", "rain", "toxic" }, 4, {
		P { tex = "spark", col = { "#e8ffb0", "#a8d84a", "#4a7a1a" }, trn = { 0.2, 0.6, 0.9 }, sz = { 0.07, 0.24 }, life = { 0.8, 1.4 }, spd = { 40, 58 }, sprd = { 2, 2 }, rate = 180, accel = { 0, -30, 0 }, shape = "Box", off = { 0, 20, 0 }, orient = "VelocityParallel", light = 0.6, dur = 4 },
		P { tex = "smoke", col = { "#d8ffb0", "#5a8a2a" }, trn = { 0.9, 1 }, sz = { 3, 8 }, life = { 1.4, 2.4 }, spd = { 0.5, 2 }, sprd = { 180, 180 }, rate = 12, off = { 0, 1, 0 }, dur = 4 },
	}, { loop = true }),
	-- 12
	preset("Ash Fall", { "ash", "volcano", "loop" }, 6, {
		P { tex = "dust", col = { "#8a8a8a", "#5a5a5a", "#2e2e2e" }, trn = { 0.3, 0.7, 0.95 }, sz = { 0.1, 0.4 }, life = { 4, 6 }, spd = { 0.5, 2 }, sprd = { 10, 10 }, rate = 90, accel = { 0, -2, 0 }, shape = "Box", off = { 0, 24, 0 }, rotspd = { -40, 40 }, light = 0.2, dur = 6 },
		P { tex = "smoke", col = { "#5a5048", "#221e1a" }, trn = { 0.75, 0.95, 1 }, sz = { 12, 30 }, life = { 4, 6 }, spd = { 0.5, 2 }, sprd = { 180, 180 }, rate = 10, off = { 0, 14, 0 }, dur = 6 },
	}, { loop = true }),
	-- 13
	preset("Firestorm", { "fire", "storm", "loop" }, 4.6, {
		P { tex = "fire", col = { "#fff2c0", "#ff8a1f", "#c42a00" }, trn = { 0.2, 0.8, 1 }, sz = { 1.4, 4 }, life = { 0.8, 1.6 }, spd = { 10, 22 }, sprd = { 30, 30 }, rate = 90, accel = { 0, 8, 0 }, shape = "Box", off = { 0, 8, 0 }, light = 1.2, dur = 4.6 },
		P { tex = "spark", col = { "#ffe8a0", "#ff5e00" }, sz = { 0.06, 0.24 }, life = { 1.4, 2.6 }, spd = { 6, 18 }, sprd = { 60, 60 }, rate = 40, accel = { 0, 3, 0 }, off = { 0, 10, 0 }, light = 1.1, dur = 4.6 },
		L { col = "#ff7a2a", bright = 4, range = 34, off = { 0, 10, 0 }, dur = 4.6 },
	}, { loop = true }),
	-- 14
	preset("Heat Wave", { "heat", "shimmer", "loop" }, 4, {
		P { tex = "smoke", col = { "#fff4d0", "#ffd8a0", "#d8a868" }, trn = { 0.95, 0.97, 1 }, sz = { 6, 16 }, life = { 1.6, 3 }, spd = { 1, 4 }, sprd = { 30, 30 }, rate = 30, accel = { 0, 4, 0 }, shape = "Box", off = { 0, 1, 0 }, squash = 0.8, light = 0.5, dur = 4 },
	}, { loop = true }),
	-- 15
	preset("Misty Morning", { "mist", "dawn", "loop" }, 7, {
		P { tex = "smoke", col = { "#e8f0ff", "#c0d0e0", "#8a9aac" }, trn = { 0.9, 0.96, 1 }, sz = { 14, 34 }, life = { 5, 7 }, spd = { 0.1, 0.5 }, sprd = { 180, 180 }, rate = 12, shape = "Box", off = { 0, 2, 0 }, squash = 0.6, light = 0.3, dur = 7 },
		P { tex = "sparkle", col = { "#ffffff", "#ffe8c0" }, trn = { 0.4, 0.9, 1 }, sz = { 0.05, 0.2 }, life = { 3, 5 }, spd = { 0.05, 0.4 }, sprd = { 180, 180 }, rate = 10, shape = "Box", dur = 7 },
	}, { loop = true }),
	-- 16
	preset("Lightning Storm", { "lightning", "storm", "loop" }, 4.4, {
		P { tex = "smoke", col = { "#4a5462", "#242a34", "#0c1016" }, trn = { 0.5, 0.85, 0.98 }, sz = { 12, 32 }, life = { 2.6, 4.2 }, spd = { 1, 4 }, sprd = { 180, 180 }, rate = 18, off = { 0, 30, 0 }, dur = 4.4 },
		B { tex = "electric", col = { "#ffffff", "#c0d8ff" }, trn = { 0, 1 }, w0 = 1.4, w1 = 0.1, segments = 24, curve = 2.8, light = 1.8, off0 = { 0, 32, 0 }, off1 = { 1, 3, 1 }, at = 0.9, dur = 0.25 },
		B { tex = "electric", col = { "#ffffff", "#c0d8ff" }, trn = { 0, 1 }, w0 = 1.2, w1 = 0.08, segments = 20, curve = -2.4, light = 1.6, off0 = { 0, 32, 0 }, off1 = { -2, 4, -1 }, at = 2.4, dur = 0.25 },
		B { tex = "electric", col = { "#ffffff", "#c0d8ff" }, trn = { 0, 1 }, w0 = 1.5, w1 = 0.1, segments = 26, curve = 3, light = 1.9, off0 = { 0, 32, 0 }, off1 = { 3, 2, -2 }, at = 3.6, dur = 0.28 },
		L { col = "#c0d8ff", bright = 7, range = 46, off = { 0, 26, 0 }, dur = 4.4 },
	}, { loop = true }),
	-- 17
	preset("Meteor Shower", { "meteor", "space", "loop" }, 5, {
		P { tex = "fire", col = { "#ffffff", "#ffb01f", "#ff2a00" }, trn = { 0.05, 0.6, 1 }, sz = { 0.6, 2 }, life = { 1.4, 2.4 }, spd = { 34, 52 }, sprd = { 8, 8 }, rate = 26, accel = { 0, -10, 0 }, shape = "Box", off = { 0, 30, 0 }, orient = "VelocityParallel", light = 1.4, dur = 5 },
		P { tex = "spark", col = { "#ffe8a0", "#ff5e00" }, sz = { 0.1, 0.35 }, life = { 1.4, 2.6 }, spd = { 30, 50 }, sprd = { 10, 10 }, rate = 24, accel = { 0, -8, 0 }, off = { 0, 30, 0 }, light = 1.2, dur = 5 },
		P { tex = "smoke", col = { "#6a5a4a", "#2a221c" }, trn = { 0.85, 1 }, sz = { 3, 8 }, life = { 2, 3.4 }, spd = { 0.5, 2 }, sprd = { 180, 180 }, rate = 8, off = { 0, 18, 0 }, dur = 5 },
	}, { loop = true }),
	-- 18
	preset("Locust Swarm", { "insects", "swarm", "loop" }, 4, {
		P { tex = "square", col = { "#5a5040", "#2e2820", "#141210" }, trn = { 0.1, 0.6, 1 }, sz = { 0.08, 0.22 }, life = { 2, 3.4 }, spd = { 8, 18 }, sprd = { 60, 60 }, rate = 90, shape = "Box", off = { 0, 6, 0 }, rotspd = { -200, 200 }, dur = 4 },
		P { tex = "dust", col = { "#9a8a6a", "#4a4030" }, trn = { 0.7, 0.95, 1 }, sz = { 2, 6 }, life = { 1.6, 2.8 }, spd = { 4, 10 }, sprd = { 60, 60 }, rate = 16, off = { 0, 4, 0 }, dur = 4 },
	}, { loop = true }),
	-- 19
	preset("Petal Storm", { "petals", "spring", "loop" }, 5, {
		P { tex = "debris", col = { "#ffd0e0", "#ff8ab0", "#c94a7a" }, trn = { 0.1, 0.7, 1 }, sz = { 0.1, 0.36 }, life = { 3, 5 }, spd = { 4, 12 }, sprd = { 30, 30 }, rate = 60, accel = { 0, -2, 0 }, shape = "Box", off = { 0, 16, 0 }, rotspd = { -120, 120 }, rot = { 0, 360 }, dur = 5 },
	}, { loop = true }),
	-- 20
	preset("Pollen Cloud", { "pollen", "spring", "loop" }, 5, {
		P { tex = "sparkle", col = { "#ffffe0", "#e8f0a0", "#c8d86a" }, trn = { 0.4, 0.85, 1 }, sz = { 0.05, 0.2 }, life = { 3, 5 }, spd = { 0.5, 2 }, sprd = { 180, 180 }, rate = 40, shape = "Box", off = { 0, 4, 0 }, light = 0.5, dur = 5 },
	}, { loop = true }),
	-- 21
	preset("Snow Squall", { "snow", "wind", "loop" }, 4, {
		P { tex = "puff", col = { "#ffffff", "#e8f4ff" }, trn = { 0.2, 0.7, 1 }, sz = { 0.08, 0.3 }, life = { 1.6, 2.8 }, spd = { 12, 26 }, sprd = { 12, 12 }, rate = 150, accel = { 0, -4, 0 }, shape = "Box", off = { 0, 16, 0 }, dur = 4 },
		P { tex = "smoke", col = { "#ffffff", "#dce8f4" }, trn = { 0.92, 1 }, sz = { 6, 16 }, life = { 1.6, 2.6 }, spd = { 10, 20 }, sprd = { 30, 30 }, rate = 16, off = { 0, 6, 0 }, dur = 4 },
	}, { loop = true }),
	-- 22
	preset("Rain Splashes", { "rain", "splash", "ground" }, 3, {
		P { tex = "glow", col = { "#dff0ff", "#a8c8e0" }, trn = { 0.4, 0.9, 1 }, sz = { 0.15, 0.5 }, life = { 0.3, 0.6 }, spd = { 2, 6 }, sprd = { 20, 20 }, rate = 80, accel = { 0, -6, 0 }, shape = "Disc", style = "Surface", off = { 0, 0.1, 0 }, dur = 3 },
		P { tex = "smoke", col = { "#ffffff", "#c8d8e8" }, trn = { 0.9, 1 }, sz = { 0.4, 1.4 }, life = { 0.4, 0.9 }, spd = { 1, 3 }, sprd = { 30, 30 }, rate = 20, off = { 0, 0.2, 0 }, dur = 3 },
	}, { loop = true }),
}
