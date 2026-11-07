--[[
	Weapons - 24 attack effects: melee arcs, muzzle flashes, projectiles and
	charge-ups. Each one is built around the weapon's silhouette so a slash reads
	as a slash and a railgun reads as a railgun.
]]

local DSL = require(script.Parent.DSL)

local P, B, T, L, M, A = DSL.P, DSL.B, DSL.T, DSL.L, DSL.M, DSL.A

local function preset(name: string, tags: { string }, duration: number, components: { any }, extra: any?)
	return DSL.preset(name, "Weapons", tags, duration, components, extra)
end

return {
	-- 01
	preset("Sword Slash", { "sword", "slash", "melee" }, 0.8, {
		B { tex = "glow", col = { "#ffffff", "#dff0ff", "#8ac8ff" }, trn = { 0, 0.5, 1 }, w0 = 0.9, w1 = 0.05, segments = 20, curve = 2.4, light = 1.4, texlen = 0.5, off0 = { -2.4, 0.4, 0 }, off1 = { 2.4, 1.6, 0 }, dur = 0.35 },
		P { tex = "spark", col = { "#ffffff", "#bfe0ff" }, sz = { 0.05, 0.2 }, life = { 0.2, 0.5 }, spd = { 6, 18 }, sprd = { 180, 180 }, burst = 18, light = 1.2, orient = "VelocityParallel", dur = 0.5 },
		L { col = "#8ac8ff", bright = 3, range = 12, dur = 0.3 },
	}),
	-- 02
	preset("Greatsword Cleave", { "greatsword", "cleave", "heavy" }, 1.1, {
		B { tex = "glow", col = { "#ffffff", "#ffe8c0", "#ff9a1f" }, trn = { 0, 0.45, 1 }, w0 = 1.6, w1 = 0.1, segments = 24, curve = 3.2, light = 1.5, texlen = 0.6, off0 = { -3.6, 0.2, 0 }, off1 = { 3.6, 2.4, 0 }, dur = 0.45 },
		P { tex = "spark", col = { "#fff2c0", "#ffa21f" }, sz = { 0.08, 0.28 }, life = { 0.3, 0.8 }, spd = { 8, 22 }, sprd = { 180, 180 }, burst = 30, accel = { 0, -10, 0 }, light = 1.3, dur = 0.8 },
		P { tex = "smoke", col = { "#e0d8c8", "#8a8070" }, trn = { 0.85, 1 }, sz = { 0.6, 2 }, life = { 0.4, 0.9 }, spd = { 2, 6 }, sprd = { 180, 180 }, burst = 8, dur = 0.8 },
		L { col = "#ffb347", bright = 4, range = 16, dur = 0.4 },
	}),
	-- 03
	preset("Axe Swing", { "axe", "swing", "heavy" }, 1, {
		B { tex = "glow", col = { "#ffffff", "#ffd0b0", "#c95a2a" }, trn = { 0, 0.6, 1 }, w0 = 1.1, w1 = 0.08, segments = 18, curve = -2.6, light = 1.2, off0 = { 2.6, 1.8, 0 }, off1 = { -2.2, 0.2, 0 }, dur = 0.4 },
		P { tex = "debris", col = { "#c9a06a", "#6a4a28" }, sz = { 0.1, 0.35 }, life = { 0.3, 0.8 }, spd = { 6, 16 }, sprd = { 60, 60 }, burst = 12, accel = { 0, -26, 0 }, rotspd = { -200, 200 }, dur = 0.8 },
		L { col = "#ffb08a", bright = 2, range = 10, dur = 0.3 },
	}),
	-- 04
	preset("Spear Thrust", { "spear", "thrust", "pierce" }, 0.9, {
		B { tex = "glow", col = { "#ffffff", "#dff0ff", "#6aaaff" }, trn = { 0, 0.4, 1 }, w0 = 0.35, w1 = 0.02, segments = 12, curve = 0, light = 1.4, off0 = { 0, 0.4, 0 }, off1 = { 0, 0.4, -6 }, dur = 0.4 },
		P { tex = "spark", col = { "#ffffff", "#bfe0ff" }, sz = { 0.04, 0.16 }, life = { 0.15, 0.4 }, spd = { 14, 30 }, sprd = { 12, 12 }, burst = 12, light = 1.2, orient = "VelocityParallel", dir = "Front", dur = 0.4 },
	}),
	-- 05
	preset("Hammer Smash", { "hammer", "smash", "aoe" }, 1.5, {
		P { tex = "glow", col = { "#ffffff", "#ffe0b0", "#ffa21f" }, trn = { 0.2, 0.8, 1 }, sz = { 0.8, 3 }, life = { 0.4, 0.9 }, spd = { 20, 32 }, sprd = { 6, 6 }, shape = "Cylinder", style = "Surface", partial = 0.06, rate = 80, light = 1.2, off = { 0, 0.1, 0 }, dur = 0.8 },
		P { tex = "dust", col = { "#d6c8b0", "#8a7a62" }, trn = { 0.5, 0.9, 1 }, sz = { 1, 3.6 }, life = { 0.8, 1.5 }, spd = { 8, 18 }, sprd = { 30, 30 }, rate = 26, dur = 1.2 },
		P { tex = "debris", col = { "#b0a084", "#4a4030" }, sz = { 0.2, 0.7 }, life = { 0.8, 1.4 }, spd = { 10, 24 }, sprd = { 45, 45 }, burst = 22, accel = { 0, -34, 0 }, dur = 1.2 },
	}),
	-- 06
	preset("Dagger Stab", { "dagger", "stab", "fast" }, 0.6, {
		P { tex = "spark", col = { "#ffffff", "#ffd0d0", "#ff3b5c" }, sz = { 0.03, 0.14 }, life = { 0.12, 0.3 }, spd = { 10, 24 }, sprd = { 210, 210 }, burst = 10, light = 1.2, dur = 0.4 },
		P { tex = "glow", col = { "#ffffff", "#ff3b5c" }, trn = { 0.4, 1 }, sz = { 0.2, 0.6 }, life = { 0.08, 0.18 }, spd = { 1, 3 }, sprd = { 180, 180 }, burst = 2, dur = 0.25 },
	}),
	-- 07
	preset("Bow Shot", { "bow", "arrow", "ranged" }, 1, {
		B { tex = "glow", col = { "#ffffff", "#dff0ff", "#8ac8ff" }, trn = { 0.1, 0.7, 1 }, w0 = 0.2, w1 = 0.02, segments = 10, curve = 0, light = 1.2, off0 = { 0, 1.4, 0 }, off1 = { 0, 1.4, -5 }, dur = 0.35 },
		P { tex = "spark", col = { "#ffffff", "#cfe4ff" }, sz = { 0.04, 0.16 }, life = { 0.2, 0.6 }, spd = { 10, 24 }, sprd = { 10, 10 }, burst = 14, light = 1.1, orient = "VelocityParallel", dur = 0.5 },
	}),
	-- 08
	preset("Arrow Trail", { "arrow", "trail", "ranged" }, 1.2, {
		T { tex = "glow", col = { "#ffffff", "#cfe4ff", "#6aaaff" }, trn = { 0.1, 0.6, 1 }, lifetime = 0.4, minLength = 0.05, widthScale = 0.8, light = 1.2, off0 = { 0, 0.15, 0 }, off1 = { 0, -0.15, 0 }, dur = 1.2 },
		P { tex = "sparkle", col = { "#ffffff", "#bfe0ff" }, sz = { 0.03, 0.12 }, life = { 0.3, 0.8 }, spd = { 0.5, 2 }, sprd = { 180, 180 }, rate = 14, light = 1, dur = 1.2 },
		A { name = "Flight", target = "rig", property = "spin", from = 0, to = 180, dur = 1.2, easing = "Linear" },
	}, { loop = true }),
	-- 09
	preset("Muzzle Flash", { "muzzle", "gun", "flash" }, 0.5, {
		P { tex = "glow", col = { "#ffffff", "#ffe0a0", "#ff8a1f" }, trn = { 0, 0.3, 1 }, sz = { 0.5, 1.8 }, life = { 0.06, 0.14 }, spd = { 2, 6 }, sprd = { 20, 20 }, burst = 4, light = 1.5, off = { 0, 0.2, -1.2 }, dur = 0.2 },
		P { tex = "spark", col = { "#fff2c0", "#ff9a1f" }, sz = { 0.04, 0.16 }, life = { 0.1, 0.3 }, spd = { 12, 28 }, sprd = { 20, 20 }, burst = 10, drag = 6, light = 1.2, off = { 0, 0.2, -1.2 }, dur = 0.3 },
		P { tex = "smoke", col = { "#e0e0e0", "#8a8a8a" }, trn = { 0.6, 0.95, 1 }, sz = { 0.2, 0.8 }, life = { 0.3, 0.7 }, spd = { 2, 6 }, sprd = { 20, 20 }, burst = 4, off = { 0, 0.2, -1.3 }, dur = 0.5 },
	}),
	-- 10
	preset("Assault Rifle Flash", { "rifle", "burst", "gun" }, 0.6, {
		P { tex = "glow", col = { "#ffffff", "#ffe8b0" }, trn = { 0, 0.4, 1 }, sz = { 0.35, 1 }, life = { 0.05, 0.12 }, spd = { 2, 5 }, sprd = { 14, 14 }, burst = 3, light = 1.4, off = { 0, 0.2, -1.1 }, dur = 0.15 },
		P { tex = "spark", col = { "#ffe8b0", "#ff8a1f" }, sz = { 0.03, 0.1 }, life = { 0.08, 0.22 }, spd = { 14, 28 }, sprd = { 16, 16 }, burst = 6, drag = 8, off = { 0, 0.2, -1.1 }, dur = 0.25 },
	}),
	-- 11
	preset("Shotgun Blast", { "shotgun", "wide", "gun" }, 0.8, {
		P { tex = "glow", col = { "#ffffff", "#ffe0a0", "#ff7a1f" }, trn = { 0, 0.35, 1 }, sz = { 0.8, 2.4 }, life = { 0.08, 0.18 }, spd = { 4, 10 }, sprd = { 30, 30 }, burst = 6, light = 1.6, off = { 0, 0.3, -1.2 }, dur = 0.25 },
		P { tex = "spark", col = { "#fff2c0", "#ff9a1f" }, sz = { 0.04, 0.16 }, life = { 0.12, 0.4 }, spd = { 16, 34 }, sprd = { 35, 35 }, burst = 20, drag = 4, light = 1.2, off = { 0, 0.3, -1.2 }, dur = 0.4 },
		P { tex = "smoke", col = { "#e8e8e8", "#9a9a9a" }, trn = { 0.5, 0.95, 1 }, sz = { 0.4, 1.4 }, life = { 0.4, 0.9 }, spd = { 2, 8 }, sprd = { 30, 30 }, burst = 8, off = { 0, 0.3, -1.4 }, dur = 0.7 },
	}),
	-- 12
	preset("Sniper Shot", { "sniper", "beam", "long" }, 1.4, {
		B { tex = "glow", col = { "#ffffff", "#ffe0a0", "#ffb347" }, trn = { 0, 0.2, 1 }, w0 = 0.35, w1 = 0.02, segments = 6, curve = 0, light = 1.7, texlen = 1, off0 = { 0, 1.4, 0 }, off1 = { 0, 1.4, -80 }, dur = 0.5 },
		P { tex = "spark", col = { "#fff2c0", "#ff9a1f" }, sz = { 0.05, 0.2 }, life = { 0.2, 0.6 }, spd = { 20, 44 }, sprd = { 8, 8 }, burst = 20, light = 1.4, off = { 0, 1.4, -1 }, dur = 0.6 },
		P { tex = "smoke", col = { "#e0e0e0", "#8a8a8a" }, trn = { 0.7, 1 }, sz = { 0.3, 1.2 }, life = { 0.5, 1 }, spd = { 1, 5 }, sprd = { 20, 20 }, burst = 5, off = { 0, 1.4, -1 }, dur = 0.8 },
		L { col = "#ffc06a", bright = 8, range = 24, off = { 0, 1.4, -1 }, dur = 0.3 },
	}),
	-- 13
	preset("Rocket Launch", { "rocket", "launch", "explosive" }, 1.6, {
		P { tex = "fire", col = { "#ffffff", "#ffb01f", "#ff2a00" }, trn = { 0, 0.6, 1 }, sz = { 0.8, 2.6 }, life = { 0.2, 0.5 }, spd = { 22, 40 }, sprd = { 8, 8 }, rate = 120, light = 1.5, off = { 0, 0.4, 1.2 }, dur = 0.6 },
		P { tex = "smoke", col = { "#c8c8c8", "#5a5a5a" }, trn = { 0.6, 0.95, 1 }, sz = { 1, 3 }, life = { 0.8, 1.6 }, spd = { 1, 5 }, sprd = { 30, 30 }, rate = 20, at = 0.1, off = { 0, 0.4, 1.6 }, dur = 1.4 },
		L { col = "#ff9a3d", bright = 5, range = 18, off = { 0, 0.4, 1.2 }, dur = 0.5 },
	}),
	-- 14
	preset("Grenade Toss", { "grenade", "toss", "small" }, 0.8, {
		P { tex = "spark", col = { "#ffe8a0", "#ff7a1f" }, sz = { 0.03, 0.12 }, life = { 0.2, 0.5 }, spd = { 4, 12 }, sprd = { 60, 60 }, burst = 8, accel = { 0, -20, 0 }, light = 1, off = { 0, 1.2, 0 }, dur = 0.6 },
		P { tex = "smoke", col = { "#d0d0d0", "#8a8a8a" }, trn = { 0.8, 1 }, sz = { 0.3, 1 }, life = { 0.4, 0.9 }, spd = { 1, 4 }, sprd = { 40, 40 }, burst = 4, off = { 0, 1.2, 0 }, dur = 0.7 },
	}),
	-- 15
	preset("Laser Rifle", { "laser", "energy", "sci-fi" }, 1, {
		B { tex = "glow", col = { "#ffffff", "#48e6ff", "#0d5cff" }, trn = { 0, 0.15, 1 }, w0 = 0.3, w1 = 0.02, segments = 4, curve = 0, light = 1.8, texlen = 1, off0 = { 0, 1.3, 0 }, off1 = { 0, 1.3, -40 }, dur = 0.35 },
		P { tex = "spark", col = { "#dffbff", "#48e6ff" }, sz = { 0.04, 0.16 }, life = { 0.15, 0.4 }, spd = { 10, 24 }, sprd = { 8, 8 }, burst = 12, light = 1.3, off = { 0, 1.3, -1 }, dur = 0.4 },
		L { col = "#48e6ff", bright = 6, range = 18, off = { 0, 1.3, -1 }, dur = 0.25 },
	}),
	-- 16
	preset("Plasma Cannon", { "plasma", "cannon", "heavy" }, 1.8, {
		P { tex = "glow", col = { "#ffffff", "#a8d0ff", "#3a6aff" }, trn = { 0, 0.4, 1 }, sz = { 1.4, 4 }, life = { 0.3, 0.7 }, spd = { 16, 30 }, sprd = { 14, 14 }, burst = 24, light = 1.7, off = { 0, 1.6, -1.4 }, dur = 0.7 },
		P { tex = "electric", col = { "#eaf8ff", "#7ab8ff" }, sz = { 0.3, 1 }, life = { 0.2, 0.5 }, spd = { 10, 26 }, sprd = { 20, 20 }, burst = 16, light = 1.4, off = { 0, 1.6, -1.4 }, dur = 0.6 },
		P { tex = "smoke", col = { "#c8dcff", "#4a6a9a" }, trn = { 0.8, 1 }, sz = { 0.8, 2.6 }, life = { 0.6, 1.2 }, spd = { 2, 8 }, sprd = { 30, 30 }, burst = 8, off = { 0, 1.6, -1.6 }, dur = 1 },
		L { col = "#6a9aff", bright = 8, range = 26, off = { 0, 1.6, -1.4 }, dur = 0.4 },
	}),
	-- 17
	preset("Staff Cast", { "staff", "cast", "magic" }, 1.4, {
		P { tex = "star", col = { "#ffffff", "#c9a6ff", "#5a2bd9" }, trn = { 0, 0.4, 1 }, sz = { 0.3, 1.2 }, life = { 0.4, 1 }, spd = { 6, 16 }, sprd = { 180, 180 }, burst = 26, rotspd = { -180, 180 }, light = 1.5, off = { 0, 1.6, -0.6 }, dur = 0.9 },
		P { tex = "sparkle", col = { "#efe0ff", "#8a5cff" }, sz = { 0.06, 0.24 }, life = { 0.4, 1 }, spd = { 4, 12 }, sprd = { 180, 180 }, burst = 20, off = { 0, 1.6, -0.6 }, dur = 0.9 },
		L { col = "#a86bff", bright = 5, range = 16, off = { 0, 1.6, -0.6 }, dur = 0.4 },
	}),
	-- 18
	preset("Wand Zap", { "wand", "zap", "magic" }, 0.8, {
		B { tex = "glow", col = { "#ffffff", "#dfb0ff", "#8a3aff" }, trn = { 0, 0.4, 1 }, w0 = 0.25, w1 = 0.02, segments = 10, curve = 0.8, light = 1.6, off0 = { 0, 1.2, 0 }, off1 = { 0, 1.4, -8 }, dur = 0.3 },
		P { tex = "sparkle", col = { "#ffffff", "#d0b0ff" }, sz = { 0.05, 0.2 }, life = { 0.15, 0.45 }, spd = { 8, 20 }, sprd = { 20, 20 }, burst = 14, light = 1.3, off = { 0, 1.2, -0.4 }, dur = 0.4 },
	}),
	-- 19
	preset("Whip Crack", { "whip", "crack", "melee" }, 0.9, {
		B { tex = "glow", col = { "#ffffff", "#ffe0a0", "#ff9a1f" }, trn = { 0, 0.5, 1 }, w0 = 0.3, w1 = 0.02, segments = 22, curve = 3, light = 1.4, off0 = { 0, 0.6, 0 }, off1 = { 4, 1.6, -2 }, dur = 0.35 },
		P { tex = "spark", col = { "#fff2c0", "#ff9a1f" }, sz = { 0.04, 0.16 }, life = { 0.1, 0.35 }, spd = { 8, 22 }, sprd = { 180, 180 }, burst = 12, light = 1.2, off = { 4, 1.6, -2 }, dur = 0.4 },
	}),
	-- 20
	preset("Shield Bash", { "shield", "bash", "impact" }, 0.9, {
		P { tex = "glow", col = { "#ffffff", "#cfe4ff", "#6a9aff" }, trn = { 0.1, 0.6, 1 }, sz = { 0.5, 1.8 }, life = { 0.2, 0.5 }, spd = { 8, 20 }, sprd = { 60, 60 }, burst = 16, light = 1.4, off = { 0, 1.4, -1 }, dur = 0.5 },
		P { tex = "spark", col = { "#ffffff", "#bfe0ff" }, sz = { 0.05, 0.18 }, life = { 0.15, 0.45 }, spd = { 10, 24 }, sprd = { 60, 60 }, burst = 14, light = 1.2, off = { 0, 1.4, -1 }, dur = 0.5 },
		L { col = "#9ac4ff", bright = 4, range = 12, off = { 0, 1.4, -1 }, dur = 0.25 },
	}),
	-- 21
	preset("Cannon Fire", { "cannon", "boom", "heavy" }, 1.8, {
		P { tex = "fire", col = { "#fff2c0", "#ff9a1f", "#c42a00" }, trn = { 0, 0.6, 1 }, sz = { 1.6, 5 }, life = { 0.3, 0.7 }, spd = { 20, 40 }, sprd = { 14, 14 }, burst = 30, light = 1.6, off = { 0, 1.6, -2 }, dur = 0.8 },
		P { tex = "smoke", col = { "#d8d8d8", "#6a6a6a" }, trn = { 0.5, 0.9, 1 }, sz = { 2, 6 }, life = { 1, 2 }, spd = { 2, 10 }, sprd = { 40, 40 }, burst = 14, off = { 0, 1.6, -2.2 }, dur = 1.6 },
		P { tex = "debris", col = { "#8a8a8a", "#3a3a3a" }, sz = { 0.2, 0.8 }, life = { 0.8, 1.6 }, spd = { 20, 44 }, sprd = { 30, 30 }, burst = 16, accel = { 0, -30, 0 }, off = { 0, 1.6, -2 }, dur = 1.4 },
		L { col = "#ff9a3d", bright = 10, range = 30, off = { 0, 1.6, -2 }, dur = 0.5 },
	}),
	-- 22
	preset("Minigun Spin", { "minigun", "spin", "sustained" }, 1.6, {
		P { tex = "glow", col = { "#ffffff", "#ffe8b0", "#ff9a1f" }, trn = { 0, 0.5, 1 }, sz = { 0.3, 1 }, life = { 0.06, 0.15 }, spd = { 4, 10 }, sprd = { 18, 18 }, rate = 120, light = 1.4, off = { 0, 0.3, -1.4 }, dur = 1.6 },
		P { tex = "spark", col = { "#fff2c0", "#ff8a1f" }, sz = { 0.03, 0.1 }, life = { 0.1, 0.28 }, spd = { 12, 26 }, sprd = { 20, 20 }, rate = 60, drag = 6, off = { 0, 0.3, -1.5 }, dur = 1.6 },
		P { tex = "smoke", col = { "#e0e0e0", "#9a9a9a" }, trn = { 0.75, 1 }, sz = { 0.3, 1 }, life = { 0.5, 1 }, spd = { 1, 4 }, sprd = { 20, 20 }, rate = 12, off = { 0, 0.4, -1.6 }, dur = 1.6 },
	}, { loop = true }),
	-- 23
	preset("Railgun Charge", { "railgun", "charge", "sci-fi" }, 2, {
		P { tex = "glow", col = { "#ffffff", "#8affff", "#2a6aff" }, trn = { 0.8, 0.2, 0 }, sz = { 0.4, 2.4 }, life = { 1.4, 1.8 }, spd = { -16, -8 }, sprd = { 8, 8 }, rate = 60, io = "Inward", light = 1.6, off = { 0, 1.4, -2 }, dur = 1.8 },
		P { tex = "electric", col = { "#eaffff", "#6ae8ff" }, sz = { 0.2, 0.8 }, life = { 0.2, 0.6 }, spd = { 2, 8 }, sprd = { 40, 40 }, rate = 34, light = 1.4, off = { 0, 1.4, -2 }, dur = 1.8 },
		P { tex = "spark", col = { "#ffffff", "#8affff" }, sz = { 0.04, 0.2 }, life = { 0.3, 0.8 }, spd = { 4, 12 }, sprd = { 60, 60 }, rate = 20, off = { 0, 1.4, -2 }, dur = 1.8 },
		L { col = "#6ae8ff", bright = 3, range = 16, off = { 0, 1.4, -2 }, dur = 1.8 },
	}),
	-- 24
	preset("Blade Parry Flash", { "parry", "clash", "flash" }, 0.7, {
		P { tex = "star", col = { "#ffffff", "#ffe8a0" }, trn = { 0, 0.3, 1 }, sz = { 0.2, 0.9 }, life = { 0.12, 0.35 }, spd = { 4, 14 }, sprd = { 180, 180 }, burst = 12, light = 1.5, rotspd = { -240, 240 }, dur = 0.35 },
		P { tex = "spark", col = { "#ffffff", "#ffd08a" }, sz = { 0.04, 0.16 }, life = { 0.2, 0.5 }, spd = { 16, 34 }, sprd = { 180, 180 }, burst = 22, drag = 6, light = 1.3, dur = 0.5 },
		L { col = "#ffe8a0", bright = 6, range = 16, dur = 0.22 },
	}),
}
