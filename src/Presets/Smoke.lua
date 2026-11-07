--[[
	Smoke - 22 smoke, fog, steam and dust effects.

	Smoke is all about slow motion and soft shapes: low speed, long lifetimes,
	high transparency and gentle upward acceleration. Each preset varies the
	emission volume so plumes, banks, columns and rings all read differently.
]]

local DSL = require(script.Parent.DSL)

local P, B, T, L, M, A = DSL.P, DSL.B, DSL.T, DSL.L, DSL.M, DSL.A

local function preset(name: string, tags: { string }, duration: number, components: { any }, extra: any?)
	return DSL.preset(name, "Smoke", tags, duration, components, extra)
end

return {
	-- 01
	preset("Smoke Plume", { "plume", "column", "loop" }, 4, {
		P { tex = "smoke", col = { "#d8d8d8", "#9a9a9a", "#4a4a4a" }, trn = { 0.55, 0.85, 0.98 }, sz = { 3, 12 }, life = { 2.2, 3.6 }, spd = { 1.5, 4 }, sprd = { 10, 10 }, rate = 26, accel = { 0, 4, 0 }, shape = "Disc", dur = 4 },
		P { tex = "puff", col = { "#eeeeee", "#b0b0b0" }, trn = { 0.7, 0.95 }, sz = { 6, 16 }, life = { 2.6, 4 }, spd = { 0.5, 2 }, sprd = { 20, 20 }, rate = 8, at = 0.6, dur = 3.4 },
	}, { loop = true }),
	-- 02
	preset("Chimney Smoke", { "chimney", "thin", "loop" }, 3.4, {
		P { tex = "smoke", col = { "#b9b9b9", "#6e6e6e", "#2e2e2e" }, trn = { 0.6, 0.9, 1 }, sz = { 1.4, 5 }, life = { 1.8, 3 }, spd = { 2, 5 }, sprd = { 6, 6 }, rate = 14, accel = { 0, 2, 0 }, wind = true, dur = 3.4 },
		P { tex = "puff", col = { "#dcdcdc", "#9a9a9a" }, trn = { 0.8, 1 }, sz = { 3, 8 }, life = { 2.2, 3.2 }, spd = { 0.5, 2 }, sprd = { 12, 12 }, rate = 5, at = 0.8, dur = 2.6 },
	}, { loop = true }),
	-- 03
	preset("Dust Cloud", { "dust", "burst", "ground" }, 2.6, {
		P { tex = "dust", col = { "#d6c3a1", "#a68c66", "#6a5638" }, trn = { 0.35, 0.8, 1 }, sz = { 4, 16 }, life = { 1.4, 2.6 }, spd = { 8, 24 }, sprd = { 25, 25 }, rate = 80, accel = { 0, -2, 0 }, drag = 3, shape = "Disc", style = "Surface", dur = 1.8 },
		P { tex = "smoke", col = { "#c5b193", "#5c4c34" }, trn = { 0.7, 0.95 }, sz = { 6, 18 }, life = { 1.8, 2.8 }, spd = { 1, 4 }, sprd = { 180, 180 }, rate = 14, at = 0.4, dur = 2.2 },
	}),
	-- 04
	preset("Fog Bank", { "fog", "ambient", "wide" }, 6, {
		P { tex = "smoke", col = { "#e6eef7", "#b8c6d6", "#7d8b9c" }, trn = { 0.85, 0.95, 1 }, sz = { 18, 44 }, life = { 4, 6 }, spd = { 0.2, 1.2 }, sprd = { 180, 180 }, rate = 12, shape = "Box", dur = 6, squash = 0.6, light = -0.4 },
	}, { loop = true }),
	-- 05
	preset("Tear Gas", { "gas", "green", "tactical" }, 4.4, {
		P { tex = "smoke", col = { "#e8ffd0", "#a8e07a", "#4a7a2a" }, trn = { 0.45, 0.85, 1 }, sz = { 5, 18 }, life = { 2.4, 4 }, spd = { 2, 7 }, sprd = { 180, 180 }, rate = 28, shape = "Disc", dur = 4.4, accel = { 0, 1.5, 0 }, light = 0.3 },
		P { tex = "puff", col = { "#d8f0c0", "#7aa858" }, trn = { 0.7, 1 }, sz = { 8, 20 }, life = { 2.8, 4.2 }, spd = { 0.5, 2.5 }, sprd = { 180, 180 }, rate = 10, at = 1, dur = 3.4 },
	}, { loop = true }),
	-- 06
	preset("Steam Vent", { "steam", "jet", "vent" }, 3, {
		P { tex = "smoke", col = { "#ffffff", "#dce6ee", "#a8b5c0" }, trn = { 0.4, 0.9, 1 }, sz = { 2, 7 }, life = { 0.9, 1.8 }, spd = { 14, 26 }, sprd = { 8, 8 }, rate = 60, accel = { 0, 4, 0 }, dur = 1.4, dir = "Top" },
		P { tex = "smoke", col = { "#ffffff", "#c8d4de" }, trn = { 0.8, 1 }, sz = { 4, 12 }, life = { 2, 3 }, spd = { 0.5, 3 }, sprd = { 180, 180 }, rate = 12, at = 1.2, dur = 1.8 },
	}, { loop = true }),
	-- 07
	preset("Ground Mist", { "mist", "low", "ambient" }, 5, {
		P { tex = "smoke", col = { "#dfe8f2", "#a6b4c4", "#6b7887" }, trn = { 0.88, 0.96, 1 }, sz = { 10, 26 }, life = { 3, 5 }, spd = { 0.3, 1.5 }, sprd = { 180, 180 }, rate = 16, shape = "Box", dur = 5, squash = 0.75 },
	}, { loop = true }),
	-- 08
	preset("Ash Drift", { "ash", "falling", "ambient" }, 5, {
		P { tex = "dust", col = { "#8c8c8c", "#5a5a5a", "#2e2e2e" }, trn = { 0.3, 0.7, 0.9 }, sz = { 0.15, 0.5 }, life = { 3, 5 }, spd = { 0.5, 2 }, sprd = { 8, 8 }, rate = 40, accel = { 0, -3, 0 }, shape = "Box", off = { 0, 14, 0 }, rot = { 0, 360 }, rotspd = { -40, 40 }, light = 0.2, dur = 5 },
	}, { loop = true }),
	-- 09
	preset("Exhaust Fumes", { "exhaust", "engine", "loop" }, 2.4, {
		P { tex = "smoke", col = { "#6e6e6e", "#3a3a3a", "#141414" }, trn = { 0.5, 0.85, 1 }, sz = { 0.8, 3 }, life = { 1, 2 }, spd = { 6, 14 }, sprd = { 20, 20 }, rate = 26, accel = { 0, 2, 0 }, drag = 1.5, dur = 2.4, off = { 0, 0, -1.2 } },
		P { tex = "dust", col = { "#9a9a9a", "#4a4a4a" }, trn = { 0.6, 1 }, sz = { 0.1, 0.3 }, life = { 0.5, 1.2 }, spd = { 4, 10 }, sprd = { 30, 30 }, rate = 12, at = 0.2, dur = 2 },
	}, { loop = true }),
	-- 10
	preset("Tire Smoke", { "tire", "burnout", "ground" }, 2.2, {
		P { tex = "smoke", col = { "#ffffff", "#d0d0d0", "#8a8a8a" }, trn = { 0.35, 0.85, 1 }, sz = { 2, 8 }, life = { 1, 2 }, spd = { 8, 18 }, sprd = { 40, 40 }, rate = 90, shape = "Disc", style = "Surface", accel = { 0, 3, 0 }, drag = 4, dur = 1.6 },
		P { tex = "puff", col = { "#f0f0f0", "#b0b0b0" }, trn = { 0.6, 0.95 }, sz = { 4, 12 }, life = { 1.4, 2.4 }, spd = { 2, 6 }, sprd = { 180, 180 }, rate = 20, dur = 2.2 },
	}),
	-- 11
	preset("Dust Devil", { "vortex", "dust", "loop" }, 4, {
		P { tex = "dust", col = { "#cfb894", "#a08050", "#5a4526" }, trn = { 0.5, 0.9, 1 }, sz = { 1.5, 5 }, life = { 1.2, 2.2 }, spd = { 4, 9 }, sprd = { 10, 10 }, shape = "Cylinder", style = "Surface", partial = 0.8, rate = 70, accel = { 0, 12, 0 }, rotspd = { -90, 90 }, dur = 4 },
		A { target = "rig", property = "spin", from = 0, to = 360, dur = 4, easing = "Linear" },
	}, { loop = true }),
	-- 12
	preset("Smoke Screen", { "screen", "wall", "cover" }, 4, {
		P { tex = "smoke", col = { "#e0e0e0", "#a0a0a0", "#4f4f4f" }, trn = { 0.5, 0.88, 1 }, sz = { 6, 18 }, life = { 2.4, 3.6 }, spd = { 2, 8 }, sprd = { 180, 180 }, rate = 50, shape = "Block", style = "Surface", dur = 3 },
		P { tex = "puff", col = { "#f0f0f0", "#c0c0c0" }, trn = { 0.7, 0.98 }, sz = { 8, 22 }, life = { 2.8, 4 }, spd = { 0.5, 3 }, sprd = { 180, 180 }, rate = 16, at = 0.6, dur = 3.4 },
	}),
	-- 13
	preset("Gun Smoke", { "muzzle", "small", "wisp" }, 1.2, {
		P { tex = "smoke", col = { "#dcdcdc", "#8a8a8a" }, trn = { 0.4, 0.95, 1 }, sz = { 0.4, 1.8 }, life = { 0.4, 0.9 }, spd = { 4, 12 }, sprd = { 25, 25 }, rate = 0, burst = 10, accel = { 0, 3, 0 }, dur = 0.8, off = { 0, 0.2, -1 } },
		P { tex = "spark", col = { "#ffd9a0", "#ff8a1f" }, sz = { 0.06, 0.16 }, life = { 0.1, 0.3 }, spd = { 10, 20 }, sprd = { 30, 30 }, burst = 8, dur = 0.3, off = { 0, 0.2, -1 } },
	}),
	-- 14
	preset("Campfire Smoke", { "campfire", "thin", "loop" }, 3.4, {
		P { tex = "smoke", col = { "#c8c8c8", "#8a8a8a", "#4a4a4a" }, trn = { 0.7, 0.92, 1 }, sz = { 1.6, 5 }, life = { 1.8, 3 }, spd = { 1.5, 4 }, sprd = { 8, 8 }, rate = 12, accel = { 0, 3, 0 }, off = { 0, 2.2, 0 }, dur = 3.4 },
	}, { loop = true }),
	-- 15
	preset("Haze Drift", { "haze", "ambient", "subtle" }, 6, {
		P { tex = "smoke", col = { "#e8f0ff", "#c0ccdc", "#8a96a8" }, trn = { 0.92, 0.97, 1 }, sz = { 20, 40 }, life = { 4, 6 }, spd = { 0.1, 0.6 }, sprd = { 180, 180 }, rate = 8, shape = "Box", dur = 6, squash = 0.5 },
	}, { loop = true }),
	-- 16
	preset("Vapor Trail", { "vapor", "trail", "path" }, 2.6, {
		P { tex = "smoke", col = { "#ffffff", "#dfe8f0", "#b0bcc8" }, trn = { 0.45, 0.9, 1 }, sz = { 0.8, 3.4 }, life = { 1.2, 2.2 }, spd = { 0.4, 1.2 }, sprd = { 180, 180 }, rate = 40, accel = { 0, 1, 0 }, dur = 2.6 },
		T { tex = "glow", col = { "#ffffff", "#dbeafe" }, trn = { 0.6, 1 }, lifetime = 0.9, minLength = 0.2, widthScale = 1.6, light = 0.3, dur = 2.6 },
	}, { loop = true }),
	-- 17
	preset("Poison Cloud", { "poison", "green", "cloud" }, 4.4, {
		P { tex = "smoke", col = { "#d0ff9a", "#6aaa2a", "#2c4a12" }, trn = { 0.6, 0.9, 1 }, sz = { 5, 16 }, life = { 2.4, 4 }, spd = { 1, 4 }, sprd = { 180, 180 }, rate = 24, shape = "Sphere", dur = 4.4, light = 0.35 },
		P { tex = "sparkle", col = { "#e8ffb0", "#7ad63a" }, sz = { 0.15, 0.5 }, life = { 1.4, 2.6 }, spd = { 0.5, 3 }, sprd = { 180, 180 }, rate = 14, dur = 3.6, light = 0.8 },
	}, { loop = true }),
	-- 18
	preset("Volcanic Ash", { "ash", "volcano", "dark" }, 4, {
		P { tex = "smoke", col = { "#5a5048", "#2e2824", "#0f0d0b" }, trn = { 0.5, 0.88, 1 }, sz = { 5, 18 }, life = { 2.4, 4 }, spd = { 2, 7 }, sprd = { 14, 14 }, rate = 30, accel = { 0, 8, 0 }, dur = 4 },
		P { tex = "spark", col = { "#ff9a3d", "#c92a00" }, sz = { 0.2, 0.6 }, life = { 1.4, 2.6 }, spd = { 6, 16 }, sprd = { 30, 30 }, rate = 20, accel = { 0, -4, 0 }, drag = 0.8, light = 1, dur = 4 },
		L { col = "#ff6a1f", bright = 3, range = 22, dur = 4 },
	}, { loop = true }),
	-- 19
	preset("Smoke Ring", { "ring", "vortex", "expanding" }, 2.2, {
		P { tex = "smoke", col = { "#e0e6ec", "#a8b4c0", "#5e6a76" }, trn = { 0.5, 0.9, 1 }, sz = { 2, 7 }, life = { 0.9, 1.6 }, spd = { 14, 22 }, sprd = { 4, 4 }, shape = "Cylinder", style = "Surface", partial = 0.12, rate = 90, accel = { 0, 1, 0 }, dur = 1.6 },
		P { tex = "glow", col = { "#ffffff", "#c8d4e0" }, trn = { 0.7, 1 }, sz = { 1, 3 }, life = { 0.5, 1 }, spd = { 16, 24 }, sprd = { 2, 2 }, shape = "Cylinder", style = "Surface", partial = 0.05, rate = 40, light = 0.4, dur = 1.4 },
	}),
	-- 20
	preset("Soot Burst", { "soot", "burst", "impulse" }, 1.6, {
		P { tex = "smoke", col = { "#4a4a4a", "#222222", "#080808" }, trn = { 0.4, 0.85, 1 }, sz = { 3, 10 }, life = { 0.8, 1.6 }, spd = { 10, 26 }, sprd = { 180, 180 }, burst = 40, drag = 4, dur = 1.2 },
		P { tex = "dust", col = { "#6e6e6e", "#2a2a2a" }, trn = { 0.4, 0.9 }, sz = { 0.2, 0.6 }, life = { 0.5, 1.2 }, spd = { 14, 32 }, sprd = { 180, 180 }, burst = 30, dur = 1 },
	}),
	-- 21
	preset("Steam Jet", { "steam", "horizontal", "jet" }, 2.4, {
		P { tex = "smoke", col = { "#ffffff", "#d8e2ea", "#a0aebc" }, trn = { 0.35, 0.85, 1 }, sz = { 1.2, 4.4 }, life = { 0.5, 1.1 }, spd = { 22, 38 }, sprd = { 6, 6 }, rate = 120, dir = "Front", accel = { 0, 2, 0 }, drag = 2, dur = 2.4, off = { 0, 0.5, -1 } },
		P { tex = "sparkle", col = { "#ffffff", "#dbeafe" }, sz = { 0.08, 0.2 }, life = { 0.3, 0.8 }, spd = { 20, 40 }, sprd = { 12, 12 }, rate = 30, dur = 2, off = { 0, 0.5, -1 } },
	}, { loop = true }),
	-- 22
	preset("Dust Puff", { "small", "impact", "puff" }, 0.9, {
		P { tex = "dust", col = { "#d6c8b0", "#9a8a70", "#5e5240" }, trn = { 0.3, 0.85, 1 }, sz = { 0.8, 3.2 }, life = { 0.4, 0.9 }, spd = { 4, 12 }, sprd = { 180, 180 }, burst = 18, drag = 5, accel = { 0, 1.5, 0 }, dur = 0.8 },
	}),
}
