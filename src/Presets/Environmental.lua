--[[
	Environmental - 22 scene effects: water, lava, geysers, foliage and cave
	atmosphere. These are designed to sit on level geometry and sell a place
	rather than an action.
]]

local DSL = require(script.Parent.DSL)

local P, B, T, L, M, A = DSL.P, DSL.B, DSL.T, DSL.L, DSL.M, DSL.A

local function preset(name: string, tags: { string }, duration: number, components: { any }, extra: any?)
	return DSL.preset(name, "Environmental", tags, duration, components, extra)
end

return {
	-- 01
	preset("Waterfall", { "water", "falls", "loop" }, 3.4, {
		P { name = "Flow", tex = "smoke", col = { "#ffffff", "#c8e8f8", "#8ab8d0" }, trn = { 0.35, 0.75, 0.95 }, sz = { 2, 6 }, life = { 0.8, 1.4 }, spd = { 20, 32 }, sprd = { 4, 4 }, rate = 120, accel = { 0, -40, 0 }, shape = "Block", style = "Surface", off = { 0, 10, 0 }, dur = 3.4 },
		P { name = "Mist", tex = "smoke", col = { "#ffffff", "#d8eef8" }, trn = { 0.85, 0.98, 1 }, sz = { 3, 9 }, life = { 1.2, 2.2 }, spd = { 1, 5 }, sprd = { 60, 60 }, rate = 20, off = { 0, 0.4, 0 }, dur = 3.4 },
		P { name = "Spray", tex = "sparkle", col = { "#ffffff", "#dff4ff" }, trn = { 0.2, 0.8, 1 }, sz = { 0.06, 0.24 }, life = { 0.5, 1.2 }, spd = { 4, 12 }, sprd = { 180, 180 }, rate = 24, accel = { 0, -12, 0 }, off = { 0, 0.4, 0 }, light = 0.4, dur = 3.4 },
	}, { loop = true }),
	-- 02
	preset("Lava Flow", { "lava", "ground", "loop" }, 4, {
		P { name = "Bubbles", tex = "fire", col = { "#fff2c0", "#ff8a1f", "#a81f00" }, trn = { 0.1, 0.7, 1 }, sz = { 0.8, 2.6 }, life = { 0.6, 1.4 }, spd = { 0.5, 3 }, sprd = { 180, 180 }, rate = 40, shape = "Disc", style = "Surface", off = { 0, 0.1, 0 }, light = 1.4, dur = 4 },
		P { name = "Embers", tex = "spark", col = { "#ffe8a0", "#ff5e00" }, sz = { 0.05, 0.22 }, life = { 1, 2 }, spd = { 1, 4 }, sprd = { 60, 60 }, rate = 24, accel = { 0, 5, 0 }, light = 1.2, dur = 4 },
		P { name = "Heat", tex = "smoke", col = { "#ff9a3d", "#c42a00" }, trn = { 0.92, 1 }, sz = { 2, 6 }, life = { 1.4, 2.4 }, spd = { 1, 3 }, sprd = { 180, 180 }, rate = 10, accel = { 0, 3, 0 }, off = { 0, 0.4, 0 }, light = 0.8, dur = 4 },
		L { name = "LavaLight", col = "#ff6a1f", bright = 4, range = 20, off = { 0, 0.5, 0 }, dur = 4 },
	}, { loop = true }),
	-- 03
	preset("Volcano Eruption", { "volcano", "eruption", "loop" }, 4.4, {
		P { name = "Plume", tex = "smoke", col = { "#5a5048", "#2e2824", "#0f0d0b" }, trn = { 0.5, 0.88, 1 }, sz = { 8, 26 }, life = { 2.4, 4 }, spd = { 12, 26 }, sprd = { 20, 20 }, rate = 40, accel = { 0, 6, 0 }, off = { 0, 8, 0 }, dur = 4.4 },
		P { name = "Lava", tex = "fire", col = { "#ffffff", "#ffb01f", "#c42a00" }, trn = { 0, 0.6, 1 }, sz = { 1.4, 4 }, life = { 1, 2 }, spd = { 26, 46 }, sprd = { 16, 16 }, rate = 50, accel = { 0, -30, 0 }, off = { 0, 8, 0 }, drag = 1, light = 1.5, dur = 4.4 },
		P { name = "Ash", tex = "dust", col = { "#8a8a8a", "#3a3a3a" }, trn = { 0.4, 0.8, 1 }, sz = { 0.1, 0.4 }, life = { 3, 4.4 }, spd = { 0.5, 3 }, sprd = { 30, 30 }, rate = 30, accel = { 0, -1.5, 0 }, off = { 0, 10, 0 }, dur = 4.4 },
		L { name = "VolcanoLight", col = "#ff7a1f", bright = 6, range = 34, off = { 0, 8, 0 }, dur = 4.4 },
	}, { loop = true }),
	-- 04
	preset("Swamp Mist", { "swamp", "mist", "loop" }, 6, {
		P { name = "Mist", tex = "smoke", col = { "#c8e0b0", "#7a9a6a", "#3a4a32" }, trn = { 0.88, 0.96, 1 }, sz = { 8, 22 }, life = { 4, 6 }, spd = { 0.1, 0.6 }, sprd = { 180, 180 }, rate = 14, shape = "Box", off = { 0, 1.2, 0 }, squash = 0.6, light = 0.2, dur = 6 },
		P { name = "Spores", tex = "sparkle", col = { "#e8ffb0", "#8ac85a" }, trn = { 0.3, 0.9, 1 }, sz = { 0.05, 0.2 }, life = { 2.4, 4 }, spd = { 0.1, 0.6 }, sprd = { 180, 180 }, rate = 12, accel = { 0, 0.3, 0 }, light = 0.9, dur = 6 },
	}, { loop = true }),
	-- 05
	preset("Bioluminescence", { "bioluminescent", "glow", "loop" }, 5, {
		P { name = "Glow", tex = "glow", col = { "#8affff", "#2ad0c8", "#0d4a6a" }, trn = { 0.2, 0.7, 1 }, sz = { 0.1, 0.4 }, life = { 2, 3.6 }, spd = { 0.1, 0.8 }, sprd = { 180, 180 }, rate = 26, shape = "Box", accel = { 0.1, 0.2, 0 }, light = 1.4, dur = 5 },
		P { name = "Sparkles", tex = "sparkle", col = { "#ffffff", "#8affff" }, trn = { 0.3, 0.9, 1 }, sz = { 0.04, 0.16 }, life = { 1.6, 3 }, spd = { 0.05, 0.4 }, sprd = { 180, 180 }, rate = 16, light = 1.1, dur = 5 },
		L { name = "GlowLight", col = "#2ad0c8", bright = 1.5, range = 12, dur = 5 },
	}, { loop = true }),
	-- 06
	preset("Falling Leaves", { "leaves", "autumn", "loop" }, 5, {
		P { name = "Leaves", tex = "debris", col = { "#ffd08a", "#d98a3a", "#7a4a1a" }, trn = { 0.1, 0.7, 1 }, sz = { 0.12, 0.4 }, life = { 3, 5 }, spd = { 0.5, 2.5 }, sprd = { 60, 60 }, rate = 30, accel = { 0, -1.5, 0 }, shape = "Box", off = { 0, 14, 0 }, rot = { 0, 360 }, rotspd = { -120, 120 }, dur = 5 },
	}, { loop = true }),
	-- 07
	preset("Dust Storm", { "dust", "desert", "loop" }, 5, {
		P { name = "Dust", tex = "dust", col = { "#e6cf9e", "#b08a52", "#6b5230" }, trn = { 0.6, 0.9, 1 }, sz = { 1.4, 5 }, life = { 1.6, 3 }, spd = { 18, 32 }, sprd = { 20, 20 }, rate = 120, accel = { 0, -1, 0 }, shape = "Box", off = { 0, 3, 0 }, light = 0.1, dur = 5 },
		P { name = "Debris", tex = "debris", col = { "#8a7a62", "#3a3226" }, sz = { 0.1, 0.4 }, life = { 1.6, 2.8 }, spd = { 20, 36 }, sprd = { 30, 30 }, rate = 20, rotspd = { -160, 160 }, off = { 0, 2, 0 }, dur = 5 },
		A { name = "GustSpin", target = "rig", property = "spin", from = 0, to = 30, dur = 5, easing = "Linear" },
	}, { loop = true }),
	-- 08
	preset("Geyser", { "geyser", "water", "loop" }, 3.6, {
		P { name = "Jet", tex = "smoke", col = { "#ffffff", "#d8eef8", "#a8c8d8" }, trn = { 0.3, 0.8, 1 }, sz = { 1.4, 4.4 }, life = { 0.8, 1.6 }, spd = { 26, 42 }, sprd = { 6, 6 }, rate = 90, accel = { 0, -20, 0 }, dur = 2.6 },
		P { name = "Mist", tex = "smoke", col = { "#ffffff", "#c8e0f0" }, trn = { 0.9, 1 }, sz = { 4, 10 }, life = { 1.6, 2.8 }, spd = { 1, 4 }, sprd = { 60, 60 }, rate = 16, at = 1, dur = 2.6 },
		P { name = "Spray", tex = "sparkle", col = { "#ffffff", "#dff4ff" }, sz = { 0.05, 0.2 }, life = { 1, 2 }, spd = { 20, 36 }, sprd = { 10, 10 }, rate = 30, accel = { 0, -30, 0 }, light = 0.5, dur = 2.6 },
	}, { loop = true }),
	-- 09
	preset("Quicksand", { "quicksand", "sand", "loop" }, 4, {
		P { name = "Swirl", tex = "dust", col = { "#c9b088", "#8a6f44", "#4a381e" }, trn = { 0.4, 0.85, 1 }, sz = { 0.6, 2.4 }, life = { 1.6, 2.8 }, spd = { 2, 6 }, sprd = { 180, 180 }, rate = 40, accel = { 0, 1, 0 }, shape = "Disc", style = "Surface", off = { 0, 0.1, 0 }, dur = 4 },
		P { name = "Bubbles", tex = "smoke", col = { "#a89470", "#5a4a30" }, trn = { 0.7, 0.95, 1 }, sz = { 0.3, 1.2 }, life = { 1, 1.8 }, spd = { 0.2, 1 }, sprd = { 20, 20 }, rate = 18, accel = { 0, -0.5, 0 }, shape = "Disc", style = "Surface", off = { 0, 0.1, 0 }, dur = 4 },
		A { name = "QuicksandSpin", target = "rig", property = "spin", from = 0, to = 360, dur = 8, easing = "Linear" },
	}, { loop = true }),
	-- 10
	preset("Caustic Light", { "caustics", "water", "loop" }, 4.4, {
		P { name = "Caustics", tex = "glow", col = { "#dff8ff", "#8ae0d0", "#2a8a9a" }, trn = { 0.85, 0.95, 1 }, sz = { 2, 6 }, life = { 2, 3.4 }, spd = { 0.1, 0.6 }, sprd = { 180, 180 }, rate = 18, shape = "Box", squash = 0.9, light = 0.8, dur = 4.4 },
		P { name = "Sparkles", tex = "sparkle", col = { "#ffffff", "#bfe8ff" }, trn = { 0.4, 0.9, 1 }, sz = { 0.05, 0.2 }, life = { 1.6, 3 }, spd = { 0.1, 0.8 }, sprd = { 180, 180 }, rate = 14, light = 0.6, dur = 4.4 },
	}, { loop = true }),
	-- 11
	preset("Glowing Spores", { "spores", "forest", "loop" }, 5, {
		P { name = "Spores", tex = "glow", col = { "#e8ffb0", "#a8e86a", "#4a8a2a" }, trn = { 0.3, 0.8, 1 }, sz = { 0.06, 0.24 }, life = { 2.4, 4.4 }, spd = { 0.1, 0.7 }, sprd = { 180, 180 }, rate = 22, shape = "Box", accel = { 0.1, 0.3, 0 }, light = 1.2, dur = 5 },
		P { name = "Drift", tex = "sparkle", col = { "#ffffff", "#d8ffb0" }, trn = { 0.4, 0.9, 1 }, sz = { 0.04, 0.16 }, life = { 2, 3.6 }, spd = { 0.05, 0.4 }, sprd = { 180, 180 }, rate = 14, light = 0.9, dur = 5 },
	}, { loop = true }),
	-- 12
	preset("Snow Bank Drift", { "snow", "drift", "loop" }, 5, {
		P { name = "Snow", tex = "puff", col = { "#ffffff", "#e8f4ff", "#c0dcef" }, trn = { 0.4, 0.85, 1 }, sz = { 0.6, 2.4 }, life = { 2.4, 4 }, spd = { 2, 6 }, sprd = { 30, 30 }, rate = 30, accel = { 0, -0.8, 0 }, shape = "Box", off = { 0, 1.4, 0 }, dur = 5 },
		P { name = "Crystals", tex = "sparkle", col = { "#ffffff", "#dff0ff" }, trn = { 0.3, 0.9, 1 }, sz = { 0.04, 0.16 }, life = { 1.6, 3 }, spd = { 0.2, 1 }, sprd = { 180, 180 }, rate = 14, light = 0.5, dur = 5 },
	}, { loop = true }),
	-- 13
	preset("Desert Heat Shimmer", { "heat", "desert", "loop" }, 4, {
		P { name = "Shimmer", tex = "smoke", col = { "#fff4d0", "#ffd8a0", "#d8a868" }, trn = { 0.95, 0.98, 1 }, sz = { 4, 12 }, life = { 1.4, 2.6 }, spd = { 0.5, 3 }, sprd = { 20, 20 }, rate = 30, accel = { 0, 5, 0 }, shape = "Block", off = { 0, 0.8, 0 }, squash = 0.85, light = 0.3, dur = 4 },
	}, { loop = true }),
	-- 14
	preset("Cave Drip", { "cave", "drip", "loop" }, 3.4, {
		P { name = "Drips", tex = "glow", col = { "#dff4ff", "#8ac0d8", "#3a6a7a" }, trn = { 0.1, 0.6, 0.9 }, sz = { 0.06, 0.2 }, life = { 0.6, 1.2 }, spd = { 0, 2 }, sprd = { 2, 2 }, rate = 12, accel = { 0, -30, 0 }, shape = "Box", off = { 0, 6, 0 }, orient = "VelocityParallel", light = 0.6, dur = 3.4 },
		P { name = "Splash", tex = "sparkle", col = { "#ffffff", "#bfe8ff" }, sz = { 0.04, 0.16 }, life = { 0.3, 0.7 }, spd = { 2, 6 }, sprd = { 40, 40 }, rate = 8, accel = { 0, -10, 0 }, off = { 0, 0.1, 0 }, light = 0.6, dur = 3.4 },
		P { name = "Mist", tex = "smoke", col = { "#bfe0e8", "#4a6a72" }, trn = { 0.92, 1 }, sz = { 2, 6 }, life = { 2, 3.4 }, spd = { 0.1, 0.6 }, sprd = { 180, 180 }, rate = 6, off = { 0, 0.4, 0 }, dur = 3.4 },
	}, { loop = true }),
	-- 15
	preset("River Rapids", { "water", "river", "loop" }, 3, {
		P { name = "Foam", tex = "smoke", col = { "#ffffff", "#d8eef8", "#a8c8d8" }, trn = { 0.6, 0.9, 1 }, sz = { 0.8, 3 }, life = { 0.8, 1.6 }, spd = { 12, 22 }, sprd = { 20, 20 }, rate = 60, shape = "Block", off = { 0, 0.2, 0 }, dur = 3 },
		P { name = "Spray", tex = "sparkle", col = { "#ffffff", "#dff4ff" }, trn = { 0.2, 0.8, 1 }, sz = { 0.05, 0.2 }, life = { 0.4, 1 }, spd = { 10, 20 }, sprd = { 30, 30 }, rate = 26, accel = { 0, -14, 0 }, off = { 0, 0.3, 0 }, light = 0.5, dur = 3 },
	}, { loop = true }),
	-- 16
	preset("Volcanic Vent", { "vent", "steam", "loop" }, 3.6, {
		P { name = "Steam", tex = "smoke", col = { "#e8e0d8", "#9a8e84", "#4a423c" }, trn = { 0.7, 0.92, 1 }, sz = { 1.4, 5 }, life = { 1.6, 2.8 }, spd = { 6, 14 }, sprd = { 8, 8 }, rate = 40, accel = { 0, 3, 0 }, off = { 0, 0.2, 0 }, dur = 3.6 },
		P { name = "Sparks", tex = "spark", col = { "#ffb347", "#c42a00" }, sz = { 0.05, 0.2 }, life = { 0.6, 1.4 }, spd = { 6, 16 }, sprd = { 20, 20 }, rate = 16, accel = { 0, -8, 0 }, off = { 0, 0.2, 0 }, light = 1.1, dur = 3.6 },
		L { name = "VentLight", col = "#ff7a1f", bright = 3, range = 14, off = { 0, 0.4, 0 }, dur = 3.6 },
	}, { loop = true }),
	-- 17
	preset("Crystal Cave Glow", { "crystal", "cave", "loop" }, 4.4, {
		P { name = "Glow", tex = "glow", col = { "#ffffff", "#c9f0ff", "#3aa8d9" }, trn = { 0.5, 0.85, 1 }, sz = { 1, 4 }, life = { 2, 3.6 }, spd = { 0.1, 0.6 }, sprd = { 180, 180 }, rate = 18, shape = "Box", light = 1.2, dur = 4.4 },
		P { name = "Sparkles", tex = "sparkle", col = { "#ffffff", "#a8e8ff" }, trn = { 0.2, 0.8, 1 }, sz = { 0.05, 0.2 }, life = { 1.8, 3.2 }, spd = { 0.05, 0.5 }, sprd = { 180, 180 }, rate = 20, light = 1, dur = 4.4 },
		L { name = "CrystalLight", col = "#6ac8ff", bright = 2, range = 14, dur = 4.4 },
	}, { loop = true }),
	-- 18
	preset("Windblown Grass", { "grass", "wind", "loop" }, 3.4, {
		P { name = "Blades", tex = "debris", col = { "#e8ffb0", "#8ac85a", "#3a6a2a" }, trn = { 0.2, 0.8, 1 }, sz = { 0.06, 0.24 }, life = { 1.2, 2.4 }, spd = { 8, 18 }, sprd = { 30, 30 }, rate = 40, accel = { 0, -1, 0 }, shape = "Box", off = { 0, 0.6, 0 }, rotspd = { -160, 160 }, dur = 3.4 },
		P { name = "Dust", tex = "dust", col = { "#d8cbb0", "#8a7a62" }, trn = { 0.85, 1 }, sz = { 0.3, 1.2 }, life = { 1, 2 }, spd = { 6, 14 }, sprd = { 40, 40 }, rate = 10, off = { 0, 0.4, 0 }, dur = 3.4 },
	}, { loop = true }),
	-- 19
	preset("Ocean Spray", { "ocean", "spray", "loop" }, 3.6, {
		P { name = "Spray", tex = "smoke", col = { "#ffffff", "#d8eef8", "#a8c8d8" }, trn = { 0.7, 0.92, 1 }, sz = { 1, 4 }, life = { 1, 2 }, spd = { 6, 16 }, sprd = { 30, 30 }, rate = 40, shape = "Block", off = { 0, 0.4, 0 }, accel = { 0, -4, 0 }, dur = 3.6 },
		P { name = "Drops", tex = "sparkle", col = { "#ffffff", "#dff4ff" }, trn = { 0.1, 0.7, 1 }, sz = { 0.05, 0.2 }, life = { 0.6, 1.4 }, spd = { 8, 18 }, sprd = { 40, 40 }, rate = 30, accel = { 0, -18, 0 }, off = { 0, 0.4, 0 }, light = 0.5, dur = 3.6 },
	}, { loop = true }),
	-- 20
	preset("Pollen Field", { "pollen", "field", "loop" }, 5, {
		P { name = "Pollen", tex = "sparkle", col = { "#ffffe0", "#e8f0a0", "#c8d86a" }, trn = { 0.4, 0.9, 1 }, sz = { 0.05, 0.2 }, life = { 3, 5 }, spd = { 0.1, 0.8 }, sprd = { 180, 180 }, rate = 30, shape = "Box", off = { 0, 1.6, 0 }, accel = { 0.2, 0.2, 0 }, light = 0.5, dur = 5 },
	}, { loop = true }),
	-- 21
	preset("Moss Spores", { "moss", "spores", "loop" }, 4.6, {
		P { name = "Spores", tex = "sparkle", col = { "#d8ffb0", "#8ac85a", "#4a7a2a" }, trn = { 0.3, 0.85, 1 }, sz = { 0.05, 0.18 }, life = { 2.4, 4 }, spd = { 0.1, 0.6 }, sprd = { 180, 180 }, rate = 18, accel = { 0, 0.2, 0 }, shape = "Box", off = { 0, 0.6, 0 }, light = 0.7, dur = 4.6 },
		P { name = "Mist", tex = "smoke", col = { "#c8e0b0", "#5a7a4a" }, trn = { 0.94, 1 }, sz = { 1.4, 4 }, life = { 2.4, 3.8 }, spd = { 0.1, 0.4 }, sprd = { 180, 180 }, rate = 8, off = { 0, 0.3, 0 }, dur = 4.6 },
	}, { loop = true }),
	-- 22
	preset("Sinkhole Dust", { "sinkhole", "collapse", "loop" }, 4.4, {
		P { name = "Dust", tex = "dust", col = { "#c2b096", "#8a7250", "#4a3a26" }, trn = { 0.5, 0.9, 1 }, sz = { 1.4, 5 }, life = { 1.8, 3.2 }, spd = { 2, 8 }, sprd = { 180, 180 }, rate = 34, accel = { 0, -1.5, 0 }, shape = "Box", off = { 0, 0.6, 0 }, dur = 4.4 },
		P { name = "Debris", tex = "debris", col = { "#8a7a62", "#3a3226" }, sz = { 0.1, 0.4 }, life = { 1.4, 2.6 }, spd = { 2, 8 }, sprd = { 60, 60 }, rate = 14, accel = { 0, -18, 0 }, rotspd = { -160, 160 }, off = { 0, 0.4, 0 }, dur = 4.4 },
	}, { loop = true }),
}
