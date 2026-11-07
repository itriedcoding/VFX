--[[
	Magic - 24 spellcasting effects: sparkles, runes, missiles, wards and
	conjurations. Each uses multi-stop colour sequences so the hue shift over a
	particle's life does the storytelling (violet -> white, gold -> amber...).
]]

local DSL = require(script.Parent.DSL)

local P, B, T, L, M, A = DSL.P, DSL.B, DSL.T, DSL.L, DSL.M, DSL.A

local function preset(name: string, tags: { string }, duration: number, components: { any }, extra: any?)
	return DSL.preset(name, "Magic", tags, duration, components, extra)
end

return {
	-- 01
	preset("Arcane Sparkles", { "sparkles", "ambient", "loop" }, 3, {
		P { tex = "sparkle", col = { "#ffffff", "#c9a6ff", "#5a2bd9" }, trn = { 0.1, 0.6, 1 }, sz = { 0.15, 0.55 }, life = { 1, 2.2 }, spd = { 0.5, 3 }, sprd = { 180, 180 }, rate = 26, rotspd = { -90, 90 }, light = 1.2, shape = "Sphere", dur = 3 },
		P { tex = "star", col = { "#efe0ff", "#8a5cff" }, sz = { 0.2, 0.7 }, life = { 0.8, 1.6 }, spd = { 0.2, 1.5 }, sprd = { 180, 180 }, rate = 8, rotspd = { -140, 140 }, dur = 3 },
		L { col = "#9b6bff", bright = 2, range = 12, dur = 3 },
	}, { loop = true }),
	-- 02
	preset("Spell Charge", { "charge", "gather", "cast" }, 1.6, {
		P { tex = "sparkle", col = { "#ffffff", "#a8d0ff", "#3a5aff" }, trn = { 0.9, 0.3, 0 }, sz = { 0.2, 0.9 }, life = { 1, 1.4 }, spd = { -28, -12 }, sprd = { 180, 180 }, rate = 90, light = 1.3, io = "Inward", shape = "Sphere", dur = 1.4 },
		P { tex = "glow", col = { "#dff0ff", "#5a8aff" }, trn = { 0.9, 0.2 }, sz = { 0.3, 1.6 }, life = { 0.8, 1.2 }, spd = { -14, -6 }, sprd = { 180, 180 }, rate = 30, io = "Inward", dur = 1.4 },
		L { col = "#8ab8ff", bright = 1, range = 10, dur = 1.4 },
	}),
	-- 03
	preset("Healing Aura", { "heal", "support", "loop" }, 2.6, {
		P { tex = "sparkle", col = { "#ffffff", "#b6ffd0", "#2ecf7a" }, trn = { 0.2, 0.7, 1 }, sz = { 0.15, 0.5 }, life = { 1.2, 2.2 }, spd = { 1, 4 }, sprd = { 40, 40 }, rate = 40, accel = { 0, 6, 0 }, light = 1.1, shape = "Disc", dur = 2.6 },
		P { tex = "glow", col = { "#dfffe8", "#4ae08a" }, trn = { 0.8, 0.3, 0.9 }, sz = { 0.6, 2 }, life = { 1, 1.8 }, spd = { 0.5, 2 }, sprd = { 180, 180 }, rate = 12, dur = 2.6 },
		L { col = "#5ce89a", bright = 2, range = 12, dur = 2.6 },
	}, { loop = true }),
	-- 04
	preset("Rune Circle", { "rune", "circle", "loop" }, 3.4, {
		P { tex = "star", col = { "#ffffff", "#c9a6ff", "#6a35ff" }, trn = { 0.2, 0.7, 1 }, sz = { 0.25, 0.8 }, life = { 1, 2 }, spd = { 0.3, 2 }, sprd = { 5, 5 }, shape = "Cylinder", style = "Surface", partial = 0.22, rate = 50, rotspd = { -60, 60 }, light = 1.3, dur = 3.4, off = { 0, 0.1, 0 } },
		P { tex = "glow", col = { "#d0b0ff", "#5a2bd9" }, trn = { 0.5, 0.9, 1 }, sz = { 0.8, 2.4 }, life = { 0.8, 1.6 }, spd = { 0.2, 1 }, sprd = { 5, 5 }, shape = "Cylinder", style = "Surface", partial = 0.2, rate = 20, dur = 3.4, off = { 0, 0.1, 0 } },
		A { name = "RuneSpin", target = "rig", property = "spin", from = 0, to = 360, dur = 3.4, easing = "Linear" },
		L { col = "#9b6bff", bright = 3, range = 14, off = { 0, 0.3, 0 }, dur = 3.4 },
	}, { loop = true }),
	-- 05
	preset("Magic Missile", { "missile", "projectile", "cast" }, 1.4, {
		M { name = "MissileCore", col = "#c9a6ff", transparency = 0.1, size = { 0.5, 0.5, 0.5 }, material = "Neon", dur = 1.2, float = 3 },
		P { tex = "glow", col = { "#ffffff", "#a86bff", "#3a0d8f" }, trn = { 0, 0.5, 1 }, sz = { 0.6, 1.8 }, life = { 0.25, 0.6 }, spd = { 6, 14 }, sprd = { 180, 180 }, rate = 70, light = 1.5, dur = 1.2 },
		P { tex = "star", col = { "#efe0ff", "#8a5cff" }, sz = { 0.2, 0.6 }, life = { 0.4, 0.9 }, spd = { 10, 22 }, sprd = { 180, 180 }, rate = 20, dur = 1.2 },
		T { tex = "glow", col = { "#d0b0ff", "#5a2bd9" }, trn = { 0, 0.7, 1 }, lifetime = 0.35, minLength = 0.1, widthScale = 1.2, light = 1.2, off0 = { 0, 0.2, 0 }, off1 = { 0, -0.2, 0 }, dur = 1.2 },
		L { col = "#a86bff", bright = 4, range = 14, dur = 1.2 },
	}),
	-- 06
	preset("Teleport Flash", { "teleport", "flash", "blink" }, 1.2, {
		P { tex = "glow", col = { "#ffffff", "#a8d0ff", "#3a5aff" }, trn = { 0, 0.4, 1 }, sz = { 4, 14 }, life = { 0.2, 0.5 }, spd = { 4, 12 }, sprd = { 180, 180 }, burst = 24, light = 1.6, dur = 0.5 },
		P { tex = "sparkle", col = { "#ffffff", "#bfe0ff" }, trn = { 0.9, 0.4, 0 }, sz = { 0.2, 1 }, life = { 0.5, 1 }, spd = { -22, -8 }, sprd = { 180, 180 }, burst = 50, io = "Inward", dur = 0.9 },
		P { tex = "smoke", col = { "#cfe4ff", "#5a8aff" }, trn = { 0.85, 1 }, sz = { 3, 9 }, life = { 0.8, 1.4 }, spd = { 2, 6 }, sprd = { 180, 180 }, rate = 20, at = 0.2, dur = 1 },
		L { col = "#a8d0ff", bright = 9, range = 26, dur = 0.35 },
	}),
	-- 07
	preset("Enchant Glow", { "enchant", "weapon", "loop" }, 2.4, {
		P { tex = "sparkle", col = { "#ffffff", "#c9a6ff", "#7a3aff" }, trn = { 0.3, 0.8, 1 }, sz = { 0.1, 0.35 }, life = { 0.8, 1.6 }, spd = { 0.3, 1.6 }, sprd = { 180, 180 }, rate = 30, light = 1.2, dur = 2.4, off = { 0, 0.6, 0 } },
		P { tex = "glow", col = { "#e8d8ff", "#8a5cff" }, trn = { 0.9, 0.5, 1 }, sz = { 0.3, 1.2 }, life = { 0.6, 1.2 }, spd = { 0.2, 1 }, sprd = { 180, 180 }, rate = 16, dur = 2.4, off = { 0, 0.6, 0 } },
		L { col = "#b88aff", bright = 2, range = 10, off = { 0, 0.6, 0 }, dur = 2.4 },
	}, { loop = true }),
	-- 08
	preset("Hex Curse", { "curse", "dark", "hex" }, 3, {
		P { tex = "smoke", col = { "#8a2bd9", "#3a0d63", "#0d0218" }, trn = { 0.4, 0.85, 1 }, sz = { 1.5, 6 }, life = { 1.6, 2.8 }, spd = { 1, 4 }, sprd = { 180, 180 }, rate = 30, accel = { 0, 3, 0 }, light = 0.6, dur = 3, off = { 0, 1.2, 0 } },
		P { tex = "square", col = { "#c9a6ff", "#5a2bd9" }, trn = { 0.2, 0.9, 1 }, sz = { 0.2, 0.6 }, life = { 1.4, 2.4 }, spd = { 0.5, 2 }, sprd = { 180, 180 }, rate = 24, rot = { 0, 360 }, rotspd = { -60, 60 }, dur = 3, off = { 0, 1.6, 0 } },
		L { col = "#7a2bd9", bright = 2, range = 14, off = { 0, 1.5, 0 }, dur = 3 },
	}, { loop = true }),
	-- 09
	preset("Summoning Circle", { "summon", "circle", "ritual" }, 3.6, {
		P { tex = "star", col = { "#ffffff", "#ffd08a", "#ff6a1f" }, trn = { 0.2, 0.75, 1 }, sz = { 0.3, 1 }, life = { 1.2, 2.2 }, spd = { 0.3, 2 }, sprd = { 4, 4 }, shape = "Cylinder", style = "Surface", partial = 0.25, rate = 60, rotspd = { -80, 80 }, light = 1.4, dur = 3.6, off = { 0, 0.05, 0 } },
		B { tex = "glow", col = { "#ffd08a", "#ff6a1f" }, trn = { 0.2, 0.9 }, w0 = 0.4, w1 = 0.1, segments = 20, curve = 0, light = 1.4, off0 = { -2, 0.1, -2 }, off1 = { 2, 0.1, 2 }, dur = 3.6 },
		B { tex = "glow", col = { "#ffd08a", "#ff6a1f" }, trn = { 0.2, 0.9 }, w0 = 0.4, w1 = 0.1, segments = 20, curve = 0, light = 1.4, off0 = { -2, 0.1, 2 }, off1 = { 2, 0.1, -2 }, dur = 3.6 },
		P { tex = "spark", col = { "#ffe8c0", "#ff8a1f" }, trn = { 0.1, 0.8, 1 }, sz = { 0.1, 0.4 }, life = { 1, 2 }, spd = { 1, 5 }, sprd = { 20, 20 }, rate = 30, accel = { 0, 8, 0 }, light = 1.2, dur = 3.6 },
		A { name = "RitualSpin", target = "rig", property = "spin", from = 0, to = -360, dur = 3.6, easing = "Linear" },
		L { col = "#ff9a3d", bright = 4, range = 16, off = { 0, 0.4, 0 }, dur = 3.6 },
	}, { loop = true }),
	-- 10
	preset("Mana Fountain", { "fountain", "mana", "loop" }, 3, {
		P { tex = "sparkle", col = { "#ffffff", "#8ad0ff", "#3a5aff" }, trn = { 0.1, 0.6, 1 }, sz = { 0.15, 0.5 }, life = { 1, 2 }, spd = { 12, 22 }, sprd = { 14, 14 }, rate = 60, accel = { 0, -12, 0 }, light = 1.3, shape = "Disc", dur = 3 },
		P { tex = "glow", col = { "#dff0ff", "#4a8aff" }, trn = { 0.7, 0.3, 1 }, sz = { 0.4, 1.4 }, life = { 0.8, 1.4 }, spd = { 8, 16 }, sprd = { 20, 20 }, rate = 20, accel = { 0, -10, 0 }, dur = 3 },
		L { col = "#6aa8ff", bright = 3, range = 14, dur = 3 },
	}, { loop = true }),
	-- 11
	preset("Divine Light", { "holy", "beams", "loop" }, 3, {
		B { tex = "glow", col = { "#ffffff", "#fff2c0", "#ffd76a" }, trn = { 0.6, 0.2, 0.9 }, w0 = 1.6, w1 = 3.2, segments = 6, curve = 0, light = 1.5, texlen = 1, off0 = { 0, 22, 0 }, off1 = { 0, 0, 0 }, dur = 3 },
		B { tex = "glow", col = { "#ffffff", "#fff2c0" }, trn = { 0.8, 0.4, 1 }, w0 = 0.4, w1 = 1.2, segments = 4, curve = 0, light = 1.3, off0 = { 2.6, 20, 1.6 }, off1 = { 2.6, 0, 1.6 }, dur = 3 },
		P { tex = "sparkle", col = { "#ffffff", "#fff0b0" }, trn = { 0.2, 0.7, 1 }, sz = { 0.15, 0.6 }, life = { 1, 2.2 }, spd = { 1, 4 }, sprd = { 180, 180 }, rate = 26, accel = { 0, -2, 0 }, light = 1.3, shape = "Cylinder", dur = 3 },
		L { col = "#ffe8a0", bright = 5, range = 24, dur = 3 },
	}, { loop = true }),
	-- 12
	preset("Shadow Bolt", { "shadow", "bolt", "dark" }, 1.3, {
		P { tex = "glow", col = { "#8a4dff", "#2a0d4d", "#05010d" }, trn = { 0, 0.5, 1 }, sz = { 0.6, 2 }, life = { 0.25, 0.6 }, spd = { 8, 18 }, sprd = { 180, 180 }, rate = 60, light = -0.2, dur = 1.1 },
		P { tex = "smoke", col = { "#3a1d5c", "#0d0418" }, trn = { 0.6, 0.9, 1 }, sz = { 1, 3 }, life = { 0.5, 1.1 }, spd = { 2, 8 }, sprd = { 180, 180 }, rate = 24, dur = 1.2 },
		T { tex = "glow", col = { "#8a4dff", "#1a0330" }, trn = { 0.2, 0.9, 1 }, lifetime = 0.4, minLength = 0.1, widthScale = 1.3, light = 1, off0 = { 0, 0.2, 0 }, off1 = { 0, -0.2, 0 }, dur = 1.2 },
	}),
	-- 13
	preset("Crystal Shards", { "crystal", "shards", "summon" }, 1.8, {
		P { tex = "debris", col = { "#ffffff", "#a8f0ff", "#2a8ab8" }, sz = { 0.2, 0.9 }, life = { 0.8, 1.6 }, spd = { 8, 22 }, sprd = { 40, 40 }, rate = 0, burst = 40, light = 1.2, orient = "VelocityParallel", squash = 0.7, dur = 1.4, rot = { 0, 360 } },
		P { tex = "sparkle", col = { "#eaffff", "#8ae0ff" }, sz = { 0.1, 0.4 }, life = { 0.6, 1.4 }, spd = { 2, 8 }, sprd = { 180, 180 }, rate = 26, light = 1.1, dur = 1.6 },
		P { tex = "glow", col = { "#d0f8ff", "#3aa8d9" }, trn = { 0.7, 0.2, 1 }, sz = { 0.4, 1.2 }, life = { 0.5, 1 }, spd = { 0.5, 3 }, sprd = { 180, 180 }, rate = 16, dur = 1.6 },
		L { col = "#8ae0ff", bright = 4, range = 16, dur = 1.2 },
	}),
	-- 14
	preset("Fairy Dust", { "fairy", "dust", "ambient" }, 4, {
		P { tex = "sparkle", col = { "#ffffff", "#ffe6a0", "#ff9ad9" }, trn = { 0.2, 0.8, 1 }, sz = { 0.08, 0.28 }, life = { 1.6, 3 }, spd = { 0.3, 1.6 }, sprd = { 180, 180 }, rate = 34, accel = { 0, 0.4, 0 }, rotspd = { -50, 50 }, light = 1.1, shape = "Box", dur = 4 },
		P { tex = "star", col = { "#ffffff", "#ffd0f0" }, sz = { 0.1, 0.35 }, life = { 1, 2 }, spd = { 0.2, 1 }, sprd = { 180, 180 }, rate = 10, dur = 4 },
	}, { loop = true }),
	-- 15
	preset("Astral Dust", { "astral", "cosmic", "ambient" }, 4.4, {
		P { tex = "star", col = { "#ffffff", "#9fd8ff", "#7a5aff" }, trn = { 0.15, 0.7, 1 }, sz = { 0.12, 0.45 }, life = { 2, 3.6 }, spd = { 0.2, 1.4 }, sprd = { 180, 180 }, rate = 28, rotspd = { -40, 40 }, light = 1.2, shape = "Box", dur = 4.4 },
		P { tex = "glow", col = { "#dff0ff", "#5a8aff" }, trn = { 0.9, 0.5, 1 }, sz = { 0.5, 2 }, life = { 1.6, 2.8 }, spd = { 0.1, 0.8 }, sprd = { 180, 180 }, rate = 8, dur = 4.4 },
	}, { loop = true }),
	-- 16
	preset("Reality Tear", { "tear", "rift", "dark" }, 2.4, {
		B { tex = "glow", col = { "#ffffff", "#c9a6ff", "#2a0d4d" }, trn = { 0, 0.35, 0.85 }, w0 = 0.2, w1 = 0.9, segments = 12, curve = 0.6, light = 1.5, texlen = 0.6, texspd = 0.3, off0 = { 0, -3, 0 }, off1 = { 0, 5, 0 }, dur = 2.2 },
		P { tex = "electric", col = { "#e8d8ff", "#8a4dff" }, sz = { 0.2, 0.8 }, life = { 0.3, 0.8 }, spd = { 1, 6 }, sprd = { 40, 40 }, rate = 40, light = 1.3, orient = "VelocityPerpendicular", dur = 2.2 },
		P { tex = "smoke", col = { "#5c2b8f", "#0d0218" }, trn = { 0.7, 0.95, 1 }, sz = { 1.5, 5 }, life = { 1.2, 2 }, spd = { 0.5, 2 }, sprd = { 180, 180 }, rate = 18, dur = 2.4 },
		L { col = "#9b6bff", bright = 4, range = 18, dur = 2.2 },
	}),
	-- 17
	preset("Blessing", { "holy", "buff", "loop" }, 2.8, {
		P { tex = "sparkle", col = { "#ffffff", "#fff2c0", "#ffc94a" }, trn = { 0.15, 0.7, 1 }, sz = { 0.12, 0.45 }, life = { 1.2, 2.4 }, spd = { 0.5, 3 }, sprd = { 30, 30 }, rate = 36, accel = { 0, 5, 0 }, light = 1.2, shape = "Disc", dur = 2.8 },
		P { tex = "glow", col = { "#fff8d0", "#ffc94a" }, trn = { 0.8, 0.4, 0.9 }, sz = { 0.5, 1.6 }, life = { 1, 1.8 }, spd = { 0.3, 1.5 }, sprd = { 180, 180 }, rate = 14, dur = 2.8 },
		B { tex = "glow", col = { "#fff2c0", "#ffc94a" }, trn = { 0.8, 0.5, 1 }, w0 = 0.2, w1 = 0.6, segments = 8, curve = 0, light = 1.2, off0 = { 0, 5, 0 }, off1 = { 0, 0.2, 0 }, dur = 2.8 },
		L { col = "#ffe08a", bright = 3, range = 14, dur = 2.8 },
	}, { loop = true }),
	-- 18
	preset("Soul Wisp", { "wisp", "soul", "loop" }, 3.2, {
		P { tex = "glow", col = { "#ffffff", "#8affd0", "#1f8a6a" }, trn = { 0, 0.4, 0.9 }, sz = { 0.5, 1.6 }, life = { 1.2, 2 }, spd = { 0.3, 1.5 }, sprd = { 180, 180 }, rate = 20, light = 1.4, shape = "Sphere", dur = 3.2, off = { 0, 1.4, 0 } },
		T { tex = "glow", col = { "#c8ffe8", "#2ecf9a" }, trn = { 0.3, 0.9, 1 }, lifetime = 0.6, minLength = 0.1, widthScale = 1, light = 1.2, off0 = { 0, 0.2, 0 }, off1 = { 0, -0.2, 0 }, dur = 3.2 },
		P { tex = "sparkle", col = { "#e8fff4", "#5ce8b0" }, sz = { 0.08, 0.25 }, life = { 0.8, 1.6 }, spd = { 0.2, 1.2 }, sprd = { 180, 180 }, rate = 18, dur = 3.2 },
		A { name = "WispFloat", target = "rig", property = "float", from = 0, to = 1.2, dur = 1.6, repeatCount = -1, reverse = true, easing = "Sine" },
		L { col = "#4ae0b0", bright = 3, range = 12, off = { 0, 1.4, 0 }, dur = 3.2 },
	}, { loop = true }),
	-- 19
	preset("Mystic Runes", { "runes", "glyphs", "loop" }, 3.6, {
		P { tex = "square", col = { "#ffffff", "#a8f0ff", "#3a8aff" }, trn = { 0.2, 0.8, 1 }, sz = { 0.2, 0.6 }, life = { 1.4, 2.4 }, spd = { 0.2, 1 }, sprd = { 6, 6 }, shape = "Cylinder", style = "Surface", partial = 0.3, rate = 40, rotspd = { -40, 40 }, light = 1.2, dur = 3.6, off = { 0, 1.2, 0 } },
		P { tex = "sparkle", col = { "#dff8ff", "#6ac8ff" }, sz = { 0.08, 0.25 }, life = { 1, 2 }, spd = { 0.5, 2 }, sprd = { 180, 180 }, rate = 20, dur = 3.6 },
		A { name = "RuneSpin", target = "rig", property = "spin", from = 0, to = 360, dur = 3.6, easing = "Linear" },
		L { col = "#6ac8ff", bright = 2, range = 12, off = { 0, 1.2, 0 }, dur = 3.6 },
	}, { loop = true }),
	-- 20
	preset("Spell Impact", { "impact", "burst", "cast" }, 1.1, {
		P { tex = "star", col = { "#ffffff", "#c9a6ff", "#5a2bd9" }, trn = { 0, 0.5, 1 }, sz = { 0.4, 2 }, life = { 0.4, 0.9 }, spd = { 10, 28 }, sprd = { 180, 180 }, burst = 40, rotspd = { -200, 200 }, light = 1.4, dur = 0.7 },
		P { tex = "sparkle", col = { "#efe0ff", "#8a5cff" }, sz = { 0.1, 0.4 }, life = { 0.5, 1.2 }, spd = { 14, 34 }, sprd = { 180, 180 }, drag = 4, burst = 50, dur = 1 },
		P { tex = "glow", col = { "#e0d0ff", "#4a1d8f" }, trn = { 0.4, 0.9, 1 }, sz = { 1.5, 5 }, life = { 0.3, 0.8 }, spd = { 4, 12 }, sprd = { 180, 180 }, burst = 12, dur = 0.8 },
		L { col = "#a86bff", bright = 7, range = 18, dur = 0.35 },
	}),
	-- 21
	preset("Levitation Glow", { "levitate", "float", "loop" }, 3, {
		P { tex = "glow", col = { "#ffffff", "#c9e0ff", "#4a8aff" }, trn = { 0.8, 0.4, 0.9 }, sz = { 0.3, 1.2 }, life = { 0.8, 1.6 }, spd = { 0.2, 1 }, sprd = { 4, 4 }, shape = "Cylinder", style = "Surface", partial = 0.2, rate = 24, light = 1.3, off = { 0, -1, 0 }, dur = 3 },
		P { tex = "sparkle", col = { "#ffffff", "#a8d0ff" }, trn = { 0.2, 0.8, 1 }, sz = { 0.08, 0.3 }, life = { 1, 2 }, spd = { 0.2, 1.2 }, sprd = { 180, 180 }, rate = 20, accel = { 0, 2, 0 }, dur = 3, off = { 0, -0.6, 0 } },
		A { name = "Levitate", target = "rig", property = "float", from = 0, to = 0.8, dur = 1.5, repeatCount = -1, reverse = true, easing = "Sine" },
		L { col = "#8ac0ff", bright = 2, range = 10, off = { 0, -0.8, 0 }, dur = 3 },
	}, { loop = true }),
	-- 22
	preset("Prismatic Burst", { "rainbow", "burst", "celebration" }, 1.8, {
		P { tex = "sparkle", col = { "#ff5a5a", "#ffd75a", "#5affb0", "#5a9dff", "#c95aff" }, trn = { 0, 0.4, 1 }, sz = { 0.3, 1.4 }, life = { 0.7, 1.5 }, spd = { 14, 36 }, sprd = { 180, 180 }, burst = 80, light = 1.4, dur = 1.4 },
		P { tex = "glow", col = { "#ffffff", "#ff9ad9", "#5a9dff" }, trn = { 0.3, 0.8, 1 }, sz = { 1.5, 6 }, life = { 0.5, 1.2 }, spd = { 6, 18 }, sprd = { 180, 180 }, burst = 16, dur = 1.2 },
		L { col = "#ffb0f0", bright = 6, range = 22, dur = 0.6 },
	}),
	-- 23
	preset("Necrotic Mist", { "necro", "mist", "loop" }, 3.8, {
		P { tex = "smoke", col = { "#a8ff8a", "#3a6b2a", "#0d1a08" }, trn = { 0.5, 0.88, 1 }, sz = { 3, 12 }, life = { 2, 3.4 }, spd = { 0.5, 3 }, sprd = { 180, 180 }, rate = 22, shape = "Sphere", light = 0.4, dur = 3.8, off = { 0, 1, 0 } },
		P { tex = "sparkle", col = { "#d8ffb0", "#6aa84a" }, sz = { 0.1, 0.4 }, life = { 1.4, 2.6 }, spd = { 0.2, 1.2 }, sprd = { 180, 180 }, rate = 14, dur = 3.8, off = { 0, 1, 0 } },
		L { col = "#6aa84a", bright = 1.5, range = 12, off = { 0, 1.2, 0 }, dur = 3.8 },
	}, { loop = true }),
	-- 24
	preset("Chronomancy Ripple", { "time", "ripple", "rings" }, 2.6, {
		P { tex = "glow", col = { "#ffffff", "#a8f0ff", "#3a6aff" }, trn = { 0, 0.7, 1 }, sz = { 0.8, 3 }, life = { 0.8, 1.4 }, spd = { 14, 20 }, sprd = { 3, 3 }, shape = "Cylinder", style = "Surface", partial = 0.06, rate = 70, light = 1.3, dur = 1.2 },
		P { tex = "glow", col = { "#dff8ff", "#6ab0ff" }, trn = { 0, 0.75, 1 }, sz = { 0.6, 2.4 }, life = { 0.8, 1.4 }, spd = { 14, 20 }, sprd = { 3, 3 }, shape = "Cylinder", style = "Surface", partial = 0.06, rate = 70, at = 0.5, dur = 1.2 },
		P { tex = "glow", col = { "#ffffff", "#8ad0ff" }, trn = { 0, 0.8, 1 }, sz = { 0.5, 2 }, life = { 0.8, 1.4 }, spd = { 14, 20 }, sprd = { 3, 3 }, shape = "Cylinder", style = "Surface", partial = 0.06, rate = 70, at = 1, dur = 1.2 },
		P { tex = "sparkle", col = { "#eaffff", "#8ad0ff" }, sz = { 0.08, 0.3 }, life = { 0.4, 1 }, spd = { 2, 8 }, sprd = { 180, 180 }, rate = 20, dur = 2.4 },
		L { col = "#8ad0ff", bright = 3, range = 16, dur = 2.4 },
	}),
}
