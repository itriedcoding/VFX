--[[
	Fire - 24 open flames, jets, embers and heat effects.
	Variety comes from emission geometry (disc/cylinder/surface/volume), motion
	(upward acceleration vs. locked drag), colour temperature and layering.
]]

local DSL = require(script.Parent.DSL)

local P, B, T, L, M, A = DSL.P, DSL.B, DSL.T, DSL.L, DSL.M, DSL.A

local function preset(name: string, tags: { string }, duration: number, components: { any }, extra: any?)
	return DSL.preset(name, "Fire", tags, duration, components, extra)
end

return {
	-- 01
	preset("Campfire", { "campfire", "loop", "ambient" }, 2.4, {
		P { tex = "fire", col = { "#fff2c0", "#ff9d21", "#c92d00" }, trn = { 0.25, 0.85, 1 }, sz = { 2.4, 5 }, life = { 0.6, 1.1 }, spd = { 3, 7 }, sprd = { 12, 12 }, rate = 45, light = 1.2, accel = { 0, 8, 0 }, dur = 2.4 },
		P { tex = "spark", col = { "#ffe8a0", "#ff7a00" }, sz = { 0.12, 0.3 }, life = { 1, 2 }, spd = { 3, 9 }, sprd = { 20, 20 }, rate = 12, accel = { 0, 6, 0 }, drag = 0.6, light = 0.8, dur = 2.4 },
		P { tex = "smoke", col = { "#4a4038", "#1a1512" }, trn = { 0.85, 1 }, sz = { 3, 8 }, life = { 1.6, 2.6 }, spd = { 2, 5 }, sprd = { 15, 15 }, rate = 8, off = { 0, 2, 0 }, dur = 2.4 },
		L { col = "#ff9a3d", bright = 4, range = 18, dur = 2.4 },
	}, { loop = true }),
	-- 02
	preset("Torch Flame", { "torch", "wall", "loop" }, 2, {
		P { tex = "fire", col = { "#fffbe0", "#ffb347", "#e03a00" }, trn = { 0.1, 0.9, 1 }, sz = { 0.8, 2.2 }, life = { 0.35, 0.7 }, spd = { 2, 5 }, sprd = { 8, 8 }, rate = 55, light = 1.3, accel = { 0, 10, 0 }, shape = "Disc", dur = 2 },
		P { tex = "smoke", col = { "#3a3028", "#0f0c0a" }, trn = { 0.9, 1 }, sz = { 1, 2.6 }, life = { 0.9, 1.6 }, spd = { 1, 3 }, sprd = { 6, 6 }, rate = 10, off = { 0, 1.2, 0 }, dur = 2 },
		L { col = "#ffa84a", bright = 3, range = 12, dur = 2 },
	}, { loop = true }),
	-- 03
	preset("Inferno Wall", { "wall", "barrier", "loop" }, 3, {
		P { tex = "fire", col = { "#fff3c4", "#ff9a1f", "#b81f00" }, trn = { 0.15, 0.8, 1 }, sz = { 2.5, 6 }, life = { 0.6, 1.2 }, spd = { 4, 12 }, sprd = { 10, 10 }, shape = "Block", style = "Surface", rate = 160, light = 1.2, accel = { 0, 12, 0 }, dur = 3 },
		P { tex = "spark", col = { "#ffe08a", "#ff5e00" }, sz = { 0.15, 0.4 }, life = { 0.8, 1.6 }, spd = { 5, 14 }, sprd = { 25, 25 }, rate = 40, accel = { 0, 8, 0 }, dur = 3 },
		L { col = "#ff7a1f", bright = 5, range = 26, dur = 3 },
	}, { loop = true }),
	-- 04
	preset("Flame Jet", { "jet", "thruster", "directional" }, 1.2, {
		P { tex = "fire", col = { "#ffffff", "#ffd24a", "#ff3d00" }, trn = { 0.05, 0.7, 1 }, sz = { 1.4, 4.5 }, life = { 0.25, 0.5 }, spd = { 28, 42 }, sprd = { 6, 6 }, rate = 220, light = 1.4, accel = { 0, -4, 0 }, dir = "Top", dur = 1.2 },
		P { tex = "spark", col = { "#fff0b0", "#ff6a00" }, sz = { 0.15, 0.4 }, life = { 0.4, 0.9 }, spd = { 34, 60 }, sprd = { 12, 12 }, rate = 60, drag = 1, dur = 1.2 },
		L { col = "#ff8a2a", bright = 6, range = 20, dur = 1.2 },
	}, { loop = true }),
	-- 05
	preset("Ember Drift", { "embers", "floating", "ambient" }, 4, {
		P { tex = "spark", col = { "#ffe3a0", "#ff6a00", "#7a1a00" }, trn = { 0.2, 0.8, 1 }, sz = { 0.1, 0.28 }, life = { 2, 4 }, spd = { 0.5, 2 }, sprd = { 180, 180 }, rate = 24, light = 0.9, accel = { 0, 0.8, 0 }, drag = 0.2, shape = "Box", dur = 4 },
		L { col = "#ff7a2a", bright = 1.2, range = 14, dur = 4 },
	}, { loop = true }),
	-- 06
	preset("Blue Flame", { "blue", "cold-burn", "loop" }, 2.4, {
		P { tex = "fire", col = { "#eaffff", "#63c8ff", "#0d3fa8" }, trn = { 0.15, 0.85, 1 }, sz = { 1.6, 4.4 }, life = { 0.5, 1 }, spd = { 3, 8 }, sprd = { 10, 10 }, rate = 70, light = 1.4, accel = { 0, 9, 0 }, dur = 2.4 },
		P { tex = "spark", col = { "#d6f4ff", "#3a9bff" }, sz = { 0.12, 0.3 }, life = { 0.8, 1.6 }, spd = { 3, 10 }, sprd = { 16, 16 }, rate = 18, accel = { 0, 7, 0 }, dur = 2.4 },
		L { col = "#4fb6ff", bright = 5, range = 18, dur = 2.4 },
	}, { loop = true }),
	-- 07
	preset("Green Flame", { "green", "cursed", "loop" }, 2.4, {
		P { tex = "fire", col = { "#eaffd0", "#7dff4a", "#0f6b18" }, trn = { 0.15, 0.85, 1 }, sz = { 1.6, 4.2 }, life = { 0.5, 1 }, spd = { 3, 7 }, sprd = { 12, 12 }, rate = 65, light = 1.2, accel = { 0, 8, 0 }, dur = 2.4 },
		P { tex = "sparkle", col = { "#d8ffb0", "#4ade50" }, sz = { 0.1, 0.35 }, life = { 1, 2 }, spd = { 1, 5 }, sprd = { 30, 30 }, rate = 22, dur = 2.4 },
		L { col = "#6bff6b", bright = 4, range = 16, dur = 2.4 },
	}, { loop = true }),
	-- 08
	preset("Arcane Fire", { "magic", "flame", "loop" }, 2.6, {
		P { tex = "fire", col = { "#ffffff", "#c9a6ff", "#5a2bd9" }, trn = { 0.1, 0.8, 1 }, sz = { 1.8, 4.6 }, life = { 0.5, 1.1 }, spd = { 3, 9 }, sprd = { 10, 10 }, rate = 70, light = 1.5, accel = { 0, 10, 0 }, dur = 2.6 },
		P { tex = "star", col = { "#efe0ff", "#8a5cff" }, sz = { 0.2, 0.6 }, life = { 0.8, 1.6 }, spd = { 2, 7 }, sprd = { 40, 40 }, rotspd = { -120, 120 }, rate = 20, dur = 2.6 },
		L { col = "#9b6bff", bright = 6, range = 20, dur = 2.6 },
	}, { loop = true }),
	-- 09
	preset("Lava Bubble", { "lava", "molten", "pop" }, 1.8, {
		P { tex = "fire", col = { "#ffffff", "#ffae1f", "#8c1a00" }, trn = { 0.05, 0.6, 1 }, sz = { 1.4, 3.4 }, life = { 0.4, 0.8 }, spd = { 12, 24 }, sprd = { 30, 30 }, burst = 45, burstY = 0, light = 1.4, accel = { 0, -22, 0 }, dur = 1.2 },
		P { tex = "debris", col = { "#ff8a1f", "#7a1500" }, sz = { 0.2, 0.7 }, life = { 0.6, 1.2 }, spd = { 10, 22 }, sprd = { 60, 60 }, accel = { 0, -40, 0 }, burst = 20, dur = 1.4 },
		L { col = "#ff6a1f", bright = 7, range = 16, dur = 1 },
	}),
	-- 10
	preset("Fire Whip", { "whip", "beam", "melee" }, 1.2, {
		B { tex = "fire", col = { "#fff2c0", "#ff8a1f", "#c42a00" }, trn = { 0.1, 0.6, 1 }, w0 = 0.7, w1 = 0.15, segments = 18, curve = 1.4, light = 1.5, texlen = 0.6, textureSpeed = 0.4, off0 = { 0, 0.6, 0 }, off1 = { 4.5, 1.6, 1.5 }, dur = 0.5 },
		P { tex = "spark", col = { "#ffe8a0", "#ff5e00" }, sz = { 0.15, 0.5 }, life = { 0.3, 0.7 }, spd = { 8, 20 }, sprd = { 180, 180 }, burst = 40, light = 1, dur = 0.6 },
		L { col = "#ff8a3d", bright = 5, range = 16, dur = 0.4 },
	}),
	-- 11
	preset("Fire Ring", { "ring", "spin", "aoe" }, 2, {
		P { tex = "fire", col = { "#fff0b0", "#ff9a1f", "#b82000" }, trn = { 0.2, 0.8, 1 }, sz = { 1.8, 4.4 }, life = { 0.6, 1.1 }, spd = { 2, 7 }, sprd = { 10, 10 }, shape = "Cylinder", style = "Surface", partial = 0.7, rate = 120, light = 1.2, accel = { 0, 9, 0 }, dur = 2 },
		A { target = "rig", property = "spin", from = 0, to = 360, dur = 2, easing = "Linear" },
		L { col = "#ff8a2a", bright = 5, range = 22, dur = 2 },
	}, { loop = true }),
	-- 12
	preset("Wildfire Spread", { "spread", "ground", "loop" }, 3.2, {
		P { tex = "fire", col = { "#ffe6a0", "#ff7a1f", "#a81c00" }, trn = { 0.3, 0.9, 1 }, sz = { 1.2, 3 }, life = { 0.7, 1.4 }, spd = { 2, 8 }, sprd = { 20, 20 }, shape = "Disc", style = "Surface", rate = 90, light = 1, accel = { 0, 6, 0 }, dur = 3.2 },
		P { tex = "smoke", col = { "#514539", "#161210" }, trn = { 0.8, 1 }, sz = { 4, 10 }, life = { 1.8, 3 }, spd = { 1, 4 }, sprd = { 180, 180 }, rate = 14, dur = 3.2 },
		L { col = "#ff6a1f", bright = 3, range = 20, dur = 3.2 },
	}, { loop = true }),
	-- 13
	preset("Fire Tornado", { "tornado", "vortex", "huge" }, 3.4, {
		P { tex = "fire", col = { "#fff3c0", "#ff9a1f", "#c42a00" }, trn = { 0.2, 0.85, 1 }, sz = { 3, 9 }, life = { 0.8, 1.4 }, spd = { 6, 10 }, sprd = { 6, 6 }, shape = "Cylinder", style = "Surface", partial = 0.9, rate = 200, light = 1.3, accel = { 0, 24, 0 }, rotspd = { -120, 120 }, dur = 3.4 },
		P { tex = "spark", col = { "#ffe8a0", "#ff5e00" }, sz = { 0.2, 0.5 }, life = { 1, 2 }, spd = { 8, 18 }, sprd = { 25, 25 }, rate = 50, accel = { 0, 30, 0 }, dur = 3.4 },
		P { tex = "smoke", col = { "#3d332b", "#0f0c0a" }, trn = { 0.85, 1 }, sz = { 6, 16 }, life = { 1.8, 3 }, spd = { 2, 6 }, sprd = { 180, 180 }, off = { 0, 12, 0 }, rate = 20, dur = 3.4 },
		A { target = "rig", property = "spin", from = 0, to = 360, dur = 3.4, easing = "Linear" },
		L { col = "#ff7a2a", bright = 7, range = 30, dur = 3.4 },
	}, { loop = true }),
	-- 14
	preset("Candle Flicker", { "candle", "small", "loop" }, 2, {
		P { tex = "fire", col = { "#fffdf0", "#ffd27a", "#d96a00" }, trn = { 0.2, 0.9, 1 }, sz = { 0.35, 0.95 }, life = { 0.25, 0.5 }, spd = { 1.2, 2.4 }, sprd = { 3, 3 }, rate = 30, light = 1.1, accel = { 0, 5, 0 }, shape = "Disc", dur = 2 },
		L { col = "#ffcf8a", bright = 2, range = 8, dur = 2 },
	}, { loop = true }),
	-- 15
	preset("Pilot Light", { "pilot", "idle", "engine" }, 1.6, {
		P { tex = "glow", col = { "#d6f0ff", "#4aa8ff", "#0a3a8a" }, trn = { 0.2, 0.8 }, sz = { 0.4, 1 }, life = { 0.3, 0.6 }, spd = { 0.5, 1.5 }, sprd = { 6, 6 }, rate = 20, light = 1.2, dur = 1.6 },
		P { tex = "spark", col = { "#ffffff", "#7ecbff" }, sz = { 0.08, 0.2 }, life = { 0.4, 0.9 }, spd = { 2, 6 }, sprd = { 10, 10 }, rate = 8, dur = 1.6 },
		L { col = "#5ab4ff", bright = 2, range = 10, dur = 1.6 },
	}, { loop = true }),
	-- 16
	preset("Flamethrower", { "stream", "weapon", "directional" }, 1.4, {
		P { tex = "fire", col = { "#ffffff", "#ffb01f", "#ff2a00" }, trn = { 0, 0.55, 1 }, sz = { 1, 3.4 }, life = { 0.35, 0.7 }, spd = { 36, 52 }, sprd = { 9, 9 }, rate = 260, light = 1.4, drag = 1.6, dur = 1.4 },
		P { tex = "smoke", col = { "#3a332c", "#0d0b09" }, trn = { 0.9, 1 }, sz = { 2, 5 }, life = { 0.8, 1.5 }, spd = { 6, 16 }, sprd = { 30, 30 }, rate = 30, off = { 0, 0, -4 }, dur = 1.4 },
		L { col = "#ff8a2a", bright = 5, range = 18, dur = 1.4 },
	}, { loop = true }),
	-- 17
	preset("Burning Debris", { "debris", "smoulder", "aftermath" }, 4, {
		P { tex = "fire", col = { "#ffb347", "#c93a00", "#3a0f00" }, trn = { 0.3, 0.9, 1 }, sz = { 0.6, 1.6 }, life = { 0.5, 1 }, spd = { 1, 4 }, sprd = { 30, 30 }, rate = 40, light = 1, accel = { 0, 4, 0 }, dur = 4 },
		P { tex = "smoke", col = { "#4a4238", "#131010" }, trn = { 0.85, 1 }, sz = { 2, 6 }, life = { 2, 3.4 }, spd = { 0.5, 2 }, sprd = { 180, 180 }, rate = 12, dur = 4 },
	}, { loop = true }),
	-- 18
	preset("Phoenix Rise", { "phoenix", "rebirth", "magic" }, 3.4, {
		P { tex = "fire", col = { "#ffffff", "#ffd24a", "#ff3d00" }, trn = { 0, 0.7, 1 }, sz = { 2, 7 }, life = { 0.8, 1.6 }, spd = { 8, 20 }, sprd = { 40, 40 }, rate = 90, light = 1.6, accel = { 0, 18, 0 }, dur = 3 },
		P { tex = "star", col = { "#fff0b0", "#ff9a1f" }, sz = { 0.4, 1.4 }, life = { 1, 2 }, spd = { 6, 16 }, sprd = { 180, 180 }, rotspd = { -160, 160 }, burst = 40, at = 0.3, dur = 2.4 },
		P { tex = "spark", col = { "#ffe8a0", "#ff5e00" }, sz = { 0.15, 0.4 }, life = { 1.4, 2.4 }, spd = { 4, 12 }, sprd = { 60, 60 }, rate = 30, accel = { 0, 10, 0 }, dur = 3.4 },
		L { col = "#ffb347", bright = 9, range = 34, dur = 2.4 },
	}),
	-- 19
	preset("Molten Core", { "molten", "core", "energy" }, 2.6, {
		P { tex = "glow", col = { "#fff8d0", "#ff9a1f", "#7a1a00" }, trn = { 0.1, 0.5, 0.9 }, sz = { 3, 7 }, life = { 0.6, 1.2 }, spd = { 0, 2 }, sprd = { 180, 180 }, rate = 60, light = 1.5, shape = "Sphere", dur = 2.6 },
		P { tex = "fire", col = { "#fff0b0", "#ff7a1f" }, sz = { 1, 2.6 }, life = { 0.5, 1 }, spd = { 4, 10 }, sprd = { 60, 60 }, rate = 40, accel = { 0, 5, 0 }, dur = 2.6 },
		P { tex = "spark", col = { "#ffe6a0", "#ff4d00" }, sz = { 0.15, 0.4 }, life = { 0.8, 1.6 }, spd = { 6, 16 }, sprd = { 180, 180 }, rate = 24, dur = 2.6 },
		L { col = "#ff6a1f", bright = 8, range = 26, dur = 2.6 },
	}, { loop = true }),
	-- 20
	preset("Hellfire", { "dark", "hell", "loop" }, 3, {
		P { tex = "fire", col = { "#ffd0d0", "#ff2a2a", "#4a0000" }, trn = { 0.15, 0.85, 1 }, sz = { 2.4, 6 }, life = { 0.6, 1.2 }, spd = { 3, 9 }, sprd = { 14, 14 }, rate = 90, light = 1.3, accel = { 0, 11, 0 }, dur = 3 },
		P { tex = "smoke", col = { "#2a1010", "#080202" }, trn = { 0.85, 1 }, sz = { 5, 14 }, life = { 1.6, 2.8 }, spd = { 1, 4 }, sprd = { 180, 180 }, rate = 16, dur = 3 },
		L { col = "#ff2a2a", bright = 6, range = 24, dur = 3 },
	}, { loop = true }),
	-- 21
	preset("Fire Arc", { "arc", "beam", "sweep" }, 1, {
		B { tex = "fire", col = { "#fff4d0", "#ff8a1f", "#b81f00" }, trn = { 0.05, 0.8 }, w0 = 0.5, w1 = 0.05, segments = 22, curve = 2.2, light = 1.4, texlen = 0.4, off0 = { -3, 0, 0 }, off1 = { 3, 2.4, 0 }, dur = 0.45 },
		P { tex = "spark", col = { "#ffe8a0", "#ff6a00" }, sz = { 0.12, 0.4 }, life = { 0.3, 0.8 }, spd = { 6, 18 }, sprd = { 180, 180 }, burst = 30, dur = 0.5 },
		L { col = "#ff9a3d", bright = 4, range = 14, dur = 0.35 },
	}),
	-- 22
	preset("Small Fire Burst", { "burst", "small", "hit" }, 0.9, {
		P { tex = "fire", col = { "#fff6c8", "#ff9a1f", "#d92200" }, trn = { 0.05, 0.8 }, sz = { 1.4, 3.6 }, life = { 0.2, 0.45 }, spd = { 8, 20 }, sprd = { 180, 180 }, burst = 26, light = 1.1, dur = 0.5 },
		P { tex = "spark", col = { "#ffe8a0", "#ff5e00" }, sz = { 0.1, 0.3 }, life = { 0.3, 0.7 }, spd = { 14, 28 }, sprd = { 180, 180 }, drag = 3, burst = 18, dur = 0.7 },
	}),
	-- 23
	preset("Ground Fire Trail", { "ground", "trail", "path" }, 2.4, {
		P { tex = "fire", col = { "#ffe6a0", "#ff7a1f", "#8c1a00" }, trn = { 0.35, 0.9, 1 }, sz = { 0.9, 2.2 }, life = { 0.5, 1 }, spd = { 0.5, 2 }, sprd = { 25, 25 }, shape = "Disc", style = "Surface", rate = 70, light = 0.9, accel = { 0, 5, 0 }, dur = 2.4 },
		P { tex = "smoke", col = { "#453b32", "#120f0d" }, trn = { 0.9, 1 }, sz = { 2, 5 }, life = { 1.4, 2.4 }, spd = { 0.5, 2 }, sprd = { 180, 180 }, rate = 10, dur = 2.4 },
	}, { loop = true }),
	-- 24
	preset("Fire Pillar", { "pillar", "eruption", "huge" }, 2.6, {
		P { tex = "fire", col = { "#ffffff", "#ffb01f", "#c42a00" }, trn = { 0.05, 0.7, 1 }, sz = { 2.6, 7 }, life = { 0.5, 1.1 }, spd = { 22, 42 }, sprd = { 5, 5 }, rate = 200, light = 1.5, accel = { 0, 16, 0 }, dur = 2.2 },
		P { tex = "spark", col = { "#fff0b0", "#ff6a00" }, sz = { 0.2, 0.5 }, life = { 1, 2 }, spd = { 30, 55 }, sprd = { 12, 12 }, rate = 40, accel = { 0, -8, 0 }, dur = 2.4 },
		P { tex = "smoke", col = { "#3f362f", "#100d0b" }, trn = { 0.85, 1 }, sz = { 6, 16 }, life = { 2, 3 }, spd = { 2, 6 }, sprd = { 180, 180 }, off = { 0, 14, 0 }, rate = 18, dur = 2.6 },
		L { col = "#ff8a2a", bright = 8, range = 30, dur = 1.8 },
	}),
}
