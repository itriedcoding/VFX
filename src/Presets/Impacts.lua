--[[
	Impacts - 24 hit reactions, all short and punchy. Impacts are the effects
	players feel most often, so they stay cheap: bursts instead of sustained
	rates, tight lifetimes and small particle budgets.
]]

local DSL = require(script.Parent.DSL)

local P, B, T, L, M, A = DSL.P, DSL.B, DSL.T, DSL.L, DSL.M, DSL.A

local function preset(name: string, tags: { string }, duration: number, components: { any }, extra: any?)
	return DSL.preset(name, "Impacts", tags, duration, components, extra)
end

return {
	-- 01
	preset("Bullet Hit", { "bullet", "sparks", "small" }, 0.8, {
		P { tex = "spark", col = { "#fff6c0", "#ffae1f", "#c94a00" }, sz = { 0.06, 0.2 }, life = { 0.15, 0.4 }, spd = { 10, 26 }, sprd = { 40, 40 }, burst = 16, drag = 6, accel = { 0, -20, 0 }, light = 1.2, orient = "VelocityParallel", dir = "Front", dur = 0.5 },
		P { tex = "smoke", col = { "#d8d8d8", "#8a8a8a" }, trn = { 0.6, 0.95, 1 }, sz = { 0.2, 0.8 }, life = { 0.3, 0.7 }, spd = { 1, 4 }, sprd = { 30, 30 }, burst = 5, dur = 0.6 },
	}),
	-- 02
	preset("Metal Sparks", { "metal", "sparks", "hit" }, 0.9, {
		P { tex = "spark", col = { "#ffffff", "#ffe08a", "#ff8a1f" }, sz = { 0.05, 0.18 }, life = { 0.25, 0.6 }, spd = { 14, 34 }, sprd = { 50, 50 }, burst = 26, drag = 4, accel = { 0, -28, 0 }, rot = { 0, 360 }, light = 1.4, orient = "VelocityParallel", dur = 0.7 },
		P { tex = "glow", col = { "#ffffff", "#ffb347" }, trn = { 0.2, 0.9, 1 }, sz = { 0.2, 0.7 }, life = { 0.1, 0.25 }, spd = { 2, 6 }, sprd = { 180, 180 }, burst = 3, light = 1.3, dur = 0.3 },
		L { col = "#ffb347", bright = 4, range = 12, dur = 0.2 },
	}),
	-- 03
	preset("Dust Kick", { "dust", "ground", "kick" }, 1.2, {
		P { tex = "dust", col = { "#d6c8b0", "#a89478", "#6a5c48" }, trn = { 0.4, 0.85, 1 }, sz = { 0.5, 2.4 }, life = { 0.5, 1.1 }, spd = { 2, 8 }, sprd = { 40, 40 }, burst = 16, drag = 5, accel = { 0, 1, 0 }, shape = "Disc", dur = 1 },
		P { tex = "debris", col = { "#b0a084", "#5a4f3c" }, sz = { 0.1, 0.35 }, life = { 0.4, 0.9 }, spd = { 5, 14 }, sprd = { 50, 50 }, burst = 10, accel = { 0, -20, 0 }, dur = 0.9 },
	}),
	-- 04
	preset("Wood Splinter", { "wood", "splinter", "hit" }, 1.1, {
		P { tex = "debris", col = { "#c9a06a", "#8a6a3a", "#4a3418" }, sz = { 0.15, 0.5 }, life = { 0.5, 1.1 }, spd = { 8, 20 }, sprd = { 45, 45 }, burst = 20, accel = { 0, -30, 0 }, rot = { 0, 360 }, rotspd = { -300, 300 }, orient = "VelocityParallel", dur = 1 },
		P { tex = "smoke", col = { "#e0d0b8", "#9a8468" }, trn = { 0.7, 0.95, 1 }, sz = { 0.3, 1 }, life = { 0.4, 0.9 }, spd = { 1, 4 }, sprd = { 60, 60 }, burst = 6, dur = 0.9 },
	}),
	-- 05
	preset("Stone Crack", { "stone", "crack", "impact" }, 1.4, {
		P { tex = "debris", col = { "#a8a8a8", "#6a6a6a", "#2e2e2e" }, sz = { 0.2, 0.7 }, life = { 0.6, 1.3 }, spd = { 8, 22 }, sprd = { 50, 50 }, burst = 24, accel = { 0, -34, 0 }, rotspd = { -240, 240 }, orient = "VelocityParallel", dur = 1.2 },
		P { tex = "dust", col = { "#c8c8c8", "#8a8a8a" }, trn = { 0.5, 0.9, 1 }, sz = { 0.5, 2.2 }, life = { 0.6, 1.2 }, spd = { 1, 5 }, sprd = { 180, 180 }, rate = 30, dur = 1.2 },
	}),
	-- 06
	preset("Water Splash", { "water", "splash", "hit" }, 1.2, {
		P { tex = "glow", col = { "#ffffff", "#bfe8ff", "#5aa8e0" }, trn = { 0.1, 0.6, 1 }, sz = { 0.08, 0.3 }, life = { 0.4, 1 }, spd = { 10, 24 }, sprd = { 35, 35 }, burst = 30, accel = { 0, -30, 0 }, dur = 1 },
		P { tex = "smoke", col = { "#ffffff", "#c8e0f0" }, trn = { 0.85, 0.95, 1 }, sz = { 0.4, 1.4 }, life = { 0.5, 1 }, spd = { 1, 4 }, sprd = { 180, 180 }, burst = 8, dur = 0.9 },
	}),
	-- 07
	preset("Glass Shatter", { "glass", "shatter", "sharp" }, 1.4, {
		P { tex = "debris", col = { "#ffffff", "#dff4ff", "#8ab8d0" }, trn = { 0.1, 0.5, 1 }, sz = { 0.1, 0.45 }, life = { 0.6, 1.3 }, spd = { 10, 26 }, sprd = { 90, 90 }, burst = 34, accel = { 0, -38, 0 }, rot = { 0, 360 }, rotspd = { -400, 400 }, light = 0.8, orient = "VelocityParallel", dur = 1.2 },
		P { tex = "sparkle", col = { "#ffffff", "#eaffff" }, sz = { 0.05, 0.18 }, life = { 0.4, 1 }, spd = { 6, 18 }, sprd = { 180, 180 }, burst = 20, drag = 4, dur = 1 },
	}),
	-- 08
	preset("Damage Spark", { "damage", "hit", "flash" }, 0.7, {
		P { tex = "sparkle", col = { "#ffffff", "#ffd0d0", "#ff3b3b" }, trn = { 0, 0.4, 1 }, sz = { 0.1, 0.4 }, life = { 0.15, 0.4 }, spd = { 6, 18 }, sprd = { 180, 180 }, burst = 14, light = 1.3, dur = 0.4 },
		P { tex = "glow", col = { "#ffffff", "#ff3b3b" }, trn = { 0.2, 0.9, 1 }, sz = { 0.3, 1.2 }, life = { 0.1, 0.3 }, spd = { 0, 2 }, sprd = { 180, 180 }, burst = 3, light = 1.2, dur = 0.3 },
	}),
	-- 09
	preset("Shield Block", { "shield", "block", "energy" }, 1.1, {
		P { tex = "glow", col = { "#ffffff", "#9fd8ff", "#3a8aff" }, trn = { 0.2, 0.7, 1 }, sz = { 0.3, 1.2 }, life = { 0.3, 0.7 }, spd = { 6, 16 }, sprd = { 60, 60 }, burst = 24, light = 1.4, shape = "Sphere", dur = 0.8 },
		P { tex = "spark", col = { "#ffffff", "#bfe0ff" }, sz = { 0.05, 0.2 }, life = { 0.2, 0.6 }, spd = { 10, 24 }, sprd = { 90, 90 }, burst = 20, drag = 5, dur = 0.7 },
		L { col = "#9fd8ff", bright = 4, range = 14, dur = 0.35 },
	}),
	-- 10
	preset("Force Push", { "force", "push", "wave" }, 1.2, {
		P { tex = "glow", col = { "#ffffff", "#d0e8ff", "#6a9aff" }, trn = { 0.3, 0.8, 1 }, sz = { 0.4, 2 }, life = { 0.4, 0.8 }, spd = { 18, 30 }, sprd = { 30, 30 }, rate = 80, light = 1.2, shape = "Disc", dur = 0.8 },
		P { tex = "smoke", col = { "#e0e8f0", "#8a96a8" }, trn = { 0.85, 1 }, sz = { 1, 3.4 }, life = { 0.5, 1 }, spd = { 8, 18 }, sprd = { 40, 40 }, rate = 24, dur = 1 },
	}),
	-- 11
	preset("Ground Shockwave", { "shockwave", "ground", "aoe" }, 1.6, {
		P { tex = "glow", col = { "#ffffff", "#e0d0b0", "#a08a64" }, trn = { 0.2, 0.8, 1 }, sz = { 0.4, 2.4 }, life = { 0.6, 1.1 }, spd = { 24, 32 }, sprd = { 2, 2 }, shape = "Cylinder", style = "Surface", partial = 0.05, rate = 90, light = 0.8, off = { 0, 0.1, 0 }, dur = 1 },
		P { tex = "dust", col = { "#d6c8b0", "#8a7a62" }, trn = { 0.5, 0.9, 1 }, sz = { 1, 3.4 }, life = { 0.6, 1.2 }, spd = { 12, 22 }, sprd = { 20, 20 }, shape = "Cylinder", style = "Surface", partial = 0.1, rate = 40, off = { 0, 0.2, 0 }, dur = 1.2 },
	}),
	-- 12
	preset("Crater Dust", { "crater", "dust", "ground" }, 2, {
		P { tex = "dust", col = { "#c2b096", "#8a7250", "#4a3a26" }, trn = { 0.4, 0.85, 1 }, sz = { 2, 7 }, life = { 0.9, 1.8 }, spd = { 6, 16 }, sprd = { 25, 25 }, rate = 50, accel = { 0, 2, 0 }, drag = 4, shape = "Disc", dur = 1.4 },
		P { tex = "debris", col = { "#8a7a62", "#3a3226" }, sz = { 0.2, 0.8 }, life = { 0.8, 1.6 }, spd = { 10, 24 }, sprd = { 40, 40 }, burst = 18, accel = { 0, -30, 0 }, dur = 1.4 },
	}),
	-- 13
	preset("Ricochet", { "ricochet", "spark", "metal" }, 0.8, {
		P { tex = "spark", col = { "#ffffff", "#ffe0a0", "#ff9a1f" }, sz = { 0.04, 0.14 }, life = { 0.2, 0.5 }, spd = { 18, 40 }, sprd = { 25, 25 }, burst = 12, drag = 3, accel = { 0, -24, 0 }, light = 1.3, orient = "VelocityParallel", dir = "Front", dur = 0.5 },
		P { tex = "glow", col = { "#ffffff", "#ffb347" }, trn = { 0.4, 1 }, sz = { 0.1, 0.4 }, life = { 0.08, 0.2 }, spd = { 1, 4 }, sprd = { 180, 180 }, burst = 2, dur = 0.25 },
	}),
	-- 14
	preset("Hammer Slam", { "hammer", "slam", "heavy" }, 1.6, {
		P { tex = "glow", col = { "#ffffff", "#ffe8c0", "#ffb347" }, trn = { 0.2, 0.8, 1 }, sz = { 0.6, 2.6 }, life = { 0.4, 0.9 }, spd = { 18, 30 }, sprd = { 8, 8 }, shape = "Cylinder", style = "Surface", partial = 0.08, rate = 70, light = 1, off = { 0, 0.15, 0 }, dur = 0.9 },
		P { tex = "dust", col = { "#d6c8b0", "#8a7a62" }, trn = { 0.5, 0.9, 1 }, sz = { 1.2, 4.4 }, life = { 0.8, 1.5 }, spd = { 8, 18 }, sprd = { 30, 30 }, rate = 30, dur = 1.2 },
		P { tex = "debris", col = { "#b0a084", "#5a4f3c" }, sz = { 0.2, 0.7 }, life = { 0.8, 1.4 }, spd = { 10, 22 }, sprd = { 40, 40 }, burst = 20, accel = { 0, -34, 0 }, dur = 1.2 },
	}),
	-- 15
	preset("Stun Impact", { "stun", "electric", "hit" }, 1, {
		P { tex = "star", col = { "#ffffff", "#ffe08a", "#ffb347" }, sz = { 0.15, 0.5 }, life = { 0.3, 0.7 }, spd = { 4, 10 }, sprd = { 180, 180 }, burst = 10, rotspd = { -200, 200 }, light = 1.2, off = { 0, 1.8, 0 }, dur = 0.7 },
		P { tex = "electric", col = { "#ffffff", "#ffe08a" }, sz = { 0.1, 0.4 }, life = { 0.15, 0.4 }, spd = { 6, 16 }, sprd = { 180, 180 }, burst = 12, off = { 0, 1.8, 0 }, dur = 0.5 },
	}),
	-- 16
	preset("Lightning Hit", { "lightning", "hit", "electric" }, 1, {
		B { tex = "electric", col = { "#ffffff", "#a8d0ff" }, trn = { 0, 0.8, 1 }, w0 = 0.5, w1 = 0.05, segments = 12, curve = 1.2, light = 1.6, off0 = { 0, 4, 0 }, off1 = { 0, 0, 0 }, dur = 0.2 },
		P { tex = "electric", col = { "#ffffff", "#8ab8ff" }, sz = { 0.2, 0.7 }, life = { 0.15, 0.4 }, spd = { 8, 20 }, sprd = { 180, 180 }, burst = 24, light = 1.4, dur = 0.5 },
		L { col = "#a8d0ff", bright = 6, range = 18, dur = 0.2 },
	}),
	-- 17
	preset("Fire Hit", { "fire", "hit", "burn" }, 1.1, {
		P { tex = "fire", col = { "#fff6c8", "#ff9a1f", "#d92200" }, trn = { 0.05, 0.8, 1 }, sz = { 0.5, 2 }, life = { 0.25, 0.6 }, spd = { 6, 16 }, sprd = { 180, 180 }, burst = 18, light = 1.2, dur = 0.7 },
		P { tex = "spark", col = { "#ffe8a0", "#ff5e00" }, sz = { 0.06, 0.2 }, life = { 0.3, 0.8 }, spd = { 10, 24 }, sprd = { 180, 180 }, burst = 16, accel = { 0, -12, 0 }, dur = 0.8 },
	}),
	-- 18
	preset("Ice Hit", { "ice", "hit", "frost" }, 1.1, {
		P { tex = "sparkle", col = { "#ffffff", "#c9ecff", "#5aa8e0" }, sz = { 0.1, 0.4 }, life = { 0.3, 0.8 }, spd = { 8, 20 }, sprd = { 180, 180 }, burst = 22, light = 1, dur = 0.8 },
		P { tex = "smoke", col = { "#eaffff", "#9fc8e0" }, trn = { 0.8, 1 }, sz = { 0.5, 1.8 }, life = { 0.5, 1 }, spd = { 1, 4 }, sprd = { 180, 180 }, burst = 6, dur = 0.9 },
		L { col = "#a9e2ff", bright = 3, range = 12, dur = 0.35 },
	}),
	-- 19
	preset("Poison Hit", { "poison", "hit", "toxic" }, 1.2, {
		P { tex = "smoke", col = { "#d8ff8a", "#6aa82a", "#2a4a12" }, trn = { 0.5, 0.9, 1 }, sz = { 0.6, 2.4 }, life = { 0.5, 1.1 }, spd = { 2, 8 }, sprd = { 180, 180 }, burst = 14, light = 0.5, dur = 1 },
		P { tex = "sparkle", col = { "#e8ffb0", "#7fe04a" }, sz = { 0.05, 0.2 }, life = { 0.4, 1 }, spd = { 3, 10 }, sprd = { 180, 180 }, burst = 14, accel = { 0, -6, 0 }, dur = 1 },
	}),
	-- 20
	preset("Holy Hit", { "holy", "hit", "light" }, 1.1, {
		P { tex = "sparkle", col = { "#ffffff", "#fff2c0", "#ffd76a" }, sz = { 0.1, 0.4 }, life = { 0.3, 0.8 }, spd = { 6, 18 }, sprd = { 180, 180 }, burst = 24, light = 1.4, dur = 0.8 },
		B { tex = "glow", col = { "#ffffff", "#ffd76a" }, trn = { 0.2, 1 }, w0 = 0.2, w1 = 1, segments = 6, curve = 0, light = 1.3, off0 = { 0, 6, 0 }, off1 = { 0, 0, 0 }, dur = 0.35 },
		L { col = "#ffe8a0", bright = 5, range = 16, dur = 0.3 },
	}),
	-- 21
	preset("Void Hit", { "void", "hit", "dark" }, 1.2, {
		P { tex = "glow", col = { "#8a4dff", "#2a0d4d", "#05010d" }, trn = { 0.4, 0.8, 1 }, sz = { 0.5, 2 }, life = { 0.3, 0.8 }, spd = { -12, -4 }, sprd = { 180, 180 }, burst = 16, io = "Inward", light = -0.2, dur = 0.8 },
		P { tex = "star", col = { "#c9a6ff", "#5a2bd9" }, sz = { 0.1, 0.35 }, life = { 0.4, 1 }, spd = { 4, 12 }, sprd = { 180, 180 }, burst = 14, rotspd = { -160, 160 }, dur = 0.9 },
	}),
	-- 22
	preset("Bullet Hole Smoke", { "smoke", "wisp", "aftermath" }, 1.6, {
		P { tex = "smoke", col = { "#c8c8c8", "#7a7a7a" }, trn = { 0.6, 0.9, 1 }, sz = { 0.15, 0.7 }, life = { 0.6, 1.2 }, spd = { 0.5, 2 }, sprd = { 30, 30 }, rate = 8, accel = { 0, 2, 0 }, dur = 1.4 },
		P { tex = "spark", col = { "#ffd08a", "#ff7a1f" }, sz = { 0.04, 0.12 }, life = { 0.1, 0.3 }, spd = { 2, 6 }, sprd = { 40, 40 }, burst = 4, dur = 0.4 },
	}),
	-- 23
	preset("Blade Parry", { "parry", "clash", "sparks" }, 0.9, {
		P { tex = "spark", col = { "#ffffff", "#ffe8a0", "#ffb347" }, sz = { 0.05, 0.2 }, life = { 0.2, 0.5 }, spd = { 16, 36 }, sprd = { 60, 60 }, burst = 26, drag = 5, accel = { 0, -26, 0 }, light = 1.4, orient = "VelocityParallel", dur = 0.6 },
		P { tex = "glow", col = { "#ffffff", "#ffd08a" }, trn = { 0.2, 1 }, sz = { 0.3, 1 }, life = { 0.08, 0.2 }, spd = { 1, 3 }, sprd = { 180, 180 }, burst = 3, light = 1.4, dur = 0.3 },
		L { col = "#ffe8a0", bright = 5, range = 14, dur = 0.25 },
	}),
	-- 24
	preset("Neon Impact", { "neon", "sci-fi", "hit" }, 0.9, {
		P { tex = "square", col = { "#ffffff", "#48e6ff", "#0d5cff" }, trn = { 0, 0.4, 1 }, sz = { 0.08, 0.35 }, life = { 0.2, 0.6 }, spd = { 10, 26 }, sprd = { 180, 180 }, burst = 26, rotspd = { -300, 300 }, light = 1.4, dur = 0.6 },
		P { tex = "glow", col = { "#ffffff", "#48e6ff" }, trn = { 0.2, 0.9, 1 }, sz = { 0.3, 1.4 }, life = { 0.15, 0.4 }, spd = { 1, 5 }, sprd = { 180, 180 }, burst = 4, light = 1.3, dur = 0.4 },
		L { col = "#48e6ff", bright = 5, range = 14, dur = 0.25 },
	}),
}
