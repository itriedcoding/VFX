--[[
	Auras - 24 looping personal effects designed to sit on a character.
	They are built low and wide: emission from a disc at the feet, a slow rise,
	and an optional orbiting tween. Everything loops cleanly.
]]

local DSL = require(script.Parent.DSL)

local P, B, T, L, M, A = DSL.P, DSL.B, DSL.T, DSL.L, DSL.M, DSL.A

local function preset(name: string, tags: { string }, duration: number, components: { any }, extra: any?)
	return DSL.preset(name, "Auras", tags, duration, components, extra)
end

return {
	-- 01
	preset("Golden Aura", { "gold", "holy", "loop" }, 2.6, {
		P { tex = "sparkle", col = { "#ffffff", "#ffe08a", "#c98a1f" }, trn = { 0.2, 0.75, 1 }, sz = { 0.1, 0.4 }, life = { 1.2, 2.2 }, spd = { 0.4, 2 }, sprd = { 40, 40 }, rate = 34, accel = { 0, 5, 0 }, light = 1.2, shape = "Disc", dur = 2.6 },
		P { tex = "glow", col = { "#fff8d0", "#ffc94a" }, trn = { 0.9, 0.5, 1 }, sz = { 0.4, 1.4 }, life = { 0.8, 1.6 }, spd = { 0.2, 1 }, sprd = { 180, 180 }, rate = 12, dur = 2.6 },
		L { col = "#ffd76a", bright = 2, range = 12, dur = 2.6 },
	}, { loop = true }),
	-- 02
	preset("Fiery Aura", { "fire", "rage", "loop" }, 2.2, {
		P { tex = "fire", col = { "#ffe6a0", "#ff8a1f", "#c42a00" }, trn = { 0.25, 0.85, 1 }, sz = { 0.8, 2.4 }, life = { 0.5, 1 }, spd = { 1, 4 }, sprd = { 30, 30 }, rate = 60, accel = { 0, 8, 0 }, light = 1.3, shape = "Disc", dur = 2.2 },
		P { tex = "spark", col = { "#ffe8a0", "#ff5e00" }, sz = { 0.1, 0.3 }, life = { 0.8, 1.6 }, spd = { 1, 5 }, sprd = { 60, 60 }, rate = 20, accel = { 0, 6, 0 }, dur = 2.2 },
		L { col = "#ff7a2a", bright = 4, range = 14, dur = 2.2 },
	}, { loop = true }),
	-- 03
	preset("Frost Aura", { "ice", "cold", "loop" }, 2.8, {
		P { tex = "sparkle", col = { "#ffffff", "#c9ecff", "#5aa8e0" }, trn = { 0.2, 0.8, 1 }, sz = { 0.1, 0.4 }, life = { 1.4, 2.4 }, spd = { 0.3, 1.6 }, sprd = { 50, 50 }, rate = 30, accel = { 0, 2, 0 }, light = 1, shape = "Disc", dur = 2.8 },
		P { tex = "smoke", col = { "#eaffff", "#8fb6d0" }, trn = { 0.9, 0.6, 1 }, sz = { 0.8, 2.6 }, life = { 1.2, 2 }, spd = { 0.2, 1 }, sprd = { 180, 180 }, rate = 10, dur = 2.8 },
		L { col = "#a9e2ff", bright = 2, range = 12, dur = 2.8 },
	}, { loop = true }),
	-- 04
	preset("Electric Aura", { "electric", "charge", "loop" }, 2, {
		P { tex = "electric", col = { "#ffffff", "#a8d0ff" }, trn = { 0.2, 0.9, 1 }, sz = { 0.2, 0.8 }, life = { 0.15, 0.5 }, spd = { 1, 5 }, sprd = { 180, 180 }, rate = 46, rotspd = { -300, 300 }, light = 1.3, shape = "Sphere", dur = 2 },
		P { tex = "spark", col = { "#eaf6ff", "#6aa4ff" }, sz = { 0.06, 0.2 }, life = { 0.3, 0.8 }, spd = { 1, 4 }, sprd = { 180, 180 }, rate = 22, dur = 2 },
		L { col = "#8ab8ff", bright = 3, range = 12, dur = 2 },
	}, { loop = true }),
	-- 05
	preset("Shadow Aura", { "shadow", "dark", "loop" }, 3, {
		P { tex = "smoke", col = { "#4a2b6b", "#1a0d2b", "#05010a" }, trn = { 0.6, 0.9, 1 }, sz = { 1, 4 }, life = { 1.6, 2.8 }, spd = { 0.2, 2 }, sprd = { 180, 180 }, rate = 22, accel = { 0, 2, 0 }, shape = "Disc", light = -0.2, dur = 3 },
		P { tex = "sparkle", col = { "#a86bff", "#2a0d4d" }, trn = { 0.4, 0.9, 1 }, sz = { 0.08, 0.3 }, life = { 1, 2 }, spd = { 0.2, 1.4 }, sprd = { 180, 180 }, rate = 16, dur = 3 },
		L { col = "#5a2b8f", bright = 1.5, range = 10, dur = 3 },
	}, { loop = true }),
	-- 06
	preset("Holy Aura", { "holy", "divine", "loop" }, 3, {
		P { tex = "sparkle", col = { "#ffffff", "#fff8d0", "#ffd76a" }, trn = { 0.15, 0.7, 1 }, sz = { 0.12, 0.45 }, life = { 1.4, 2.6 }, spd = { 0.5, 2.5 }, sprd = { 30, 30 }, rate = 32, accel = { 0, 6, 0 }, light = 1.3, shape = "Disc", dur = 3 },
		B { tex = "glow", col = { "#fff8d0", "#ffd76a" }, trn = { 0.9, 0.6, 1 }, w0 = 0.2, w1 = 0.8, segments = 8, curve = 0, light = 1.2, off0 = { 0, 4.5, 0 }, off1 = { 0, 0.2, 0 }, dur = 3 },
		L { col = "#ffe8a0", bright = 3, range = 14, dur = 3 },
	}, { loop = true }),
	-- 07
	preset("Toxic Aura", { "toxic", "poison", "loop" }, 3, {
		P { tex = "smoke", col = { "#d8ff8a", "#6aa82a", "#1f3a0d" }, trn = { 0.55, 0.9, 1 }, sz = { 0.8, 3 }, life = { 1.4, 2.6 }, spd = { 0.3, 2 }, sprd = { 180, 180 }, rate = 24, accel = { 0, 2, 0 }, shape = "Disc", light = 0.5, dur = 3 },
		P { tex = "sparkle", col = { "#e8ffb0", "#7fe04a" }, sz = { 0.08, 0.28 }, life = { 1, 2 }, spd = { 0.2, 1.2 }, sprd = { 180, 180 }, rate = 18, dur = 3 },
		L { col = "#8ce05a", bright = 2, range = 10, dur = 3 },
	}, { loop = true }),
	-- 08
	preset("Nature Aura", { "nature", "leaves", "loop" }, 3.6, {
		P { tex = "debris", col = { "#e8ffb0", "#6ab82a", "#2a5c14" }, trn = { 0.2, 0.8, 1 }, sz = { 0.15, 0.5 }, life = { 1.6, 3 }, spd = { 0.5, 2.5 }, sprd = { 180, 180 }, rate = 22, accel = { 0, 1.5, 0 }, rotspd = { -80, 80 }, rot = { 0, 360 }, light = 0.6, shape = "Disc", dur = 3.6 },
		P { tex = "sparkle", col = { "#f0ffd0", "#a8e86a" }, sz = { 0.06, 0.22 }, life = { 1, 2 }, spd = { 0.2, 1 }, sprd = { 180, 180 }, rate = 20, dur = 3.6 },
		L { col = "#8ce05a", bright = 1.5, range = 10, dur = 3.6 },
	}, { loop = true }),
	-- 09
	preset("Void Aura", { "void", "dark", "loop" }, 3.2, {
		P { tex = "glow", col = { "#8a4dff", "#1a0330", "#020008" }, trn = { 0.3, 0.7, 0.95 }, sz = { 1, 3.4 }, life = { 1.4, 2.6 }, spd = { -2, -0.5 }, sprd = { 180, 180 }, rate = 24, io = "Inward", accel = { 0, 1, 0 }, light = -0.3, dur = 3.2 },
		P { tex = "star", col = { "#c9a6ff", "#4a1d8f" }, trn = { 0.3, 0.85, 1 }, sz = { 0.1, 0.4 }, life = { 1.2, 2.4 }, spd = { 0.2, 1.2 }, sprd = { 180, 180 }, rate = 16, rotspd = { -60, 60 }, dur = 3.2 },
		L { col = "#6b3fff", bright = 1.5, range = 12, dur = 3.2 },
	}, { loop = true }),
	-- 10
	preset("Crimson Aura", { "blood", "red", "loop" }, 2.6, {
		P { tex = "sparkle", col = { "#ffd0d0", "#ff3b5c", "#6b0a1a" }, trn = { 0.2, 0.8, 1 }, sz = { 0.1, 0.4 }, life = { 1.2, 2.2 }, spd = { 0.4, 2 }, sprd = { 40, 40 }, rate = 30, accel = { 0, 4, 0 }, light = 1.1, shape = "Disc", dur = 2.6 },
		P { tex = "smoke", col = { "#8a1a2a", "#2a050a" }, trn = { 0.85, 1 }, sz = { 0.6, 2 }, life = { 1.2, 2 }, spd = { 0.2, 1 }, sprd = { 180, 180 }, rate = 10, dur = 2.6 },
		L { col = "#ff3b5c", bright = 2, range = 10, dur = 2.6 },
	}, { loop = true }),
	-- 11
	preset("Rainbow Aura", { "rainbow", "prism", "loop" }, 3.4, {
		P { tex = "sparkle", col = { "#ff5a5a", "#ffd75a", "#5affb0", "#5a9dff", "#c95aff" }, trn = { 0.15, 0.7, 1 }, sz = { 0.1, 0.42 }, life = { 1.4, 2.6 }, spd = { 0.4, 2.2 }, sprd = { 50, 50 }, rate = 34, accel = { 0, 3, 0 }, light = 1.2, shape = "Disc", dur = 3.4 },
		L { col = "#ffb0f0", bright = 2, range = 12, dur = 3.4 },
	}, { loop = true }),
	-- 12
	preset("Cosmic Aura", { "cosmic", "space", "loop" }, 3.8, {
		P { tex = "star", col = { "#ffffff", "#9fd8ff", "#7a5aff" }, trn = { 0.15, 0.7, 1 }, sz = { 0.1, 0.4 }, life = { 1.8, 3.2 }, spd = { 0.1, 1 }, sprd = { 180, 180 }, rate = 26, rotspd = { -40, 40 }, light = 1.1, shape = "Sphere", dur = 3.8 },
		P { tex = "glow", col = { "#dff0ff", "#5a8aff" }, trn = { 0.9, 0.5, 1 }, sz = { 0.5, 2 }, life = { 1.6, 2.8 }, spd = { 0.1, 0.6 }, sprd = { 180, 180 }, rate = 8, dur = 3.8 },
		L { col = "#8ab8ff", bright = 1.5, range = 12, dur = 3.8 },
	}, { loop = true }),
	-- 13
	preset("Ember Aura", { "embers", "warm", "loop" }, 3, {
		P { tex = "spark", col = { "#ffe8a0", "#ff7a1f", "#8a1f00" }, trn = { 0.2, 0.8, 1 }, sz = { 0.08, 0.3 }, life = { 1.4, 2.6 }, spd = { 0.5, 2 }, sprd = { 60, 60 }, rate = 30, accel = { 0, 4, 0 }, light = 1.2, shape = "Disc", dur = 3 },
		L { col = "#ff9a3d", bright = 2, range = 10, dur = 3 },
	}, { loop = true }),
	-- 14
	preset("Storm Aura", { "storm", "wind", "loop" }, 2.6, {
		P { tex = "electric", col = { "#ffffff", "#a8d0ff" }, trn = { 0.3, 0.9, 1 }, sz = { 0.2, 0.8 }, life = { 0.2, 0.6 }, spd = { 2, 7 }, sprd = { 180, 180 }, rate = 30, rotspd = { -240, 240 }, light = 1.3, shape = "Cylinder", dur = 2.6 },
		P { tex = "smoke", col = { "#8a96a8", "#2a3038" }, trn = { 0.9, 1 }, sz = { 1, 3 }, life = { 1.2, 2 }, spd = { 0.5, 2 }, sprd = { 180, 180 }, rate = 12, dur = 2.6 },
		A { name = "StormSpin", target = "rig", property = "spin", from = 0, to = 360, dur = 2.6, easing = "Linear" },
		L { col = "#a8c8ff", bright = 2, range = 10, dur = 2.6 },
	}, { loop = true }),
	-- 15
	preset("Crystal Aura", { "crystal", "cyan", "loop" }, 3, {
		P { tex = "sparkle", col = { "#ffffff", "#a8f0ff", "#3aa8d9" }, trn = { 0.2, 0.75, 1 }, sz = { 0.1, 0.4 }, life = { 1.4, 2.4 }, spd = { 0.3, 1.6 }, sprd = { 40, 40 }, rate = 28, accel = { 0, 2.5, 0 }, light = 1.2, shape = "Disc", dur = 3 },
		P { tex = "debris", col = { "#eaffff", "#6ac8ff" }, trn = { 0.3, 0.9 }, sz = { 0.1, 0.35 }, life = { 1.6, 2.6 }, spd = { 0.2, 1 }, sprd = { 180, 180 }, rate = 12, rotspd = { -60, 60 }, light = 1, dur = 3 },
		L { col = "#8ae0ff", bright = 2, range = 12, dur = 3 },
	}, { loop = true }),
	-- 16
	preset("Dragon Aura", { "dragon", "fire", "loop" }, 3, {
		P { tex = "fire", col = { "#fff2c0", "#ff7a1f", "#8a1f00" }, trn = { 0.3, 0.85, 1 }, sz = { 0.6, 2.2 }, life = { 0.6, 1.2 }, spd = { 1, 3 }, sprd = { 60, 60 }, rate = 40, accel = { 0, 6, 0 }, light = 1.2, shape = "Disc", dur = 3 },
		P { tex = "spark", col = { "#ffe0a0", "#ff5e00" }, sz = { 0.08, 0.28 }, life = { 1, 2 }, spd = { 1, 4 }, sprd = { 80, 80 }, rate = 18, accel = { 0, 4, 0 }, dur = 3 },
		A { name = "DragonFloat", target = "rig", property = "float", from = 0, to = 0.6, dur = 1.5, repeatCount = -1, reverse = true, easing = "Sine" },
		L { col = "#ff8a2a", bright = 3, range = 14, dur = 3 },
	}, { loop = true }),
	-- 17
	preset("Ghost Aura", { "ghost", "spirit", "loop" }, 3.4, {
		P { tex = "smoke", col = { "#dff0ff", "#8ab0d0", "#3a4a5c" }, trn = { 0.75, 0.95, 1 }, sz = { 0.8, 3 }, life = { 1.8, 3 }, spd = { 0.2, 1.4 }, sprd = { 180, 180 }, rate = 18, accel = { 0, 2, 0 }, light = 0.3, dur = 3.4 },
		P { tex = "sparkle", col = { "#ffffff", "#bfe0ff" }, trn = { 0.3, 0.9, 1 }, sz = { 0.08, 0.26 }, life = { 1.2, 2.2 }, spd = { 0.2, 1 }, sprd = { 180, 180 }, rate = 16, dur = 3.4 },
		A { name = "GhostFloat", target = "rig", property = "float", from = 0, to = 0.5, dur = 2, repeatCount = -1, reverse = true, easing = "Sine" },
		L { col = "#bfe0ff", bright = 1.2, range = 10, dur = 3.4 },
	}, { loop = true }),
	-- 18
	preset("Rage Aura", { "rage", "pulse", "loop" }, 1.6, {
		P { tex = "spark", col = { "#ffd0d0", "#ff2a2a", "#6b0000" }, trn = { 0.2, 0.8, 1 }, sz = { 0.1, 0.4 }, life = { 0.6, 1.2 }, spd = { 1, 5 }, sprd = { 60, 60 }, rate = 40, accel = { 0, 7, 0 }, light = 1.4, shape = "Disc", dur = 1.6 },
		P { tex = "smoke", col = { "#6b0a0a", "#1a0202" }, trn = { 0.85, 1 }, sz = { 0.8, 2.4 }, life = { 0.8, 1.4 }, spd = { 0.5, 2 }, sprd = { 180, 180 }, rate = 14, dur = 1.6 },
		A { name = "RagePulse", target = "RageLight", property = "brightness", from = 2, to = 9, dur = 0.8, repeatCount = -1, reverse = true, easing = "Sine" },
		L { col = "#ff2a2a", bright = 4, range = 14, dur = 1.6 },
	}, { loop = true }),
	-- 19
	preset("Frost Mist Aura", { "frost", "mist", "loop" }, 3.4, {
		P { tex = "smoke", col = { "#ffffff", "#d6ecf8", "#8fb6d0" }, trn = { 0.85, 0.95, 1 }, sz = { 1.2, 4 }, life = { 1.8, 3 }, spd = { 0.1, 1 }, sprd = { 180, 180 }, rate = 16, shape = "Disc", light = 0.2, dur = 3.4 },
		P { tex = "sparkle", col = { "#ffffff", "#c9ecff" }, trn = { 0.3, 0.85, 1 }, sz = { 0.06, 0.22 }, life = { 1.4, 2.6 }, spd = { 0.1, 0.8 }, sprd = { 180, 180 }, rate = 14, dur = 3.4 },
		L { col = "#c9ecff", bright = 1.2, range = 10, dur = 3.4 },
	}, { loop = true }),
	-- 20
	preset("Lightning Crown", { "crown", "electric", "loop" }, 2.4, {
		P { tex = "electric", col = { "#ffffff", "#a8d0ff" }, trn = { 0.2, 0.9, 1 }, sz = { 0.2, 0.7 }, life = { 0.2, 0.6 }, spd = { 2, 8 }, sprd = { 40, 40 }, rate = 34, rotspd = { -280, 280 }, light = 1.4, shape = "Cylinder", style = "Surface", partial = 0.25, off = { 0, 2.6, 0 }, dur = 2.4 },
		P { tex = "spark", col = { "#eaf6ff", "#7ab8ff" }, sz = { 0.06, 0.2 }, life = { 0.4, 1 }, spd = { 1, 6 }, sprd = { 60, 60 }, rate = 16, off = { 0, 2.6, 0 }, dur = 2.4 },
		L { col = "#a8d0ff", bright = 2, range = 10, off = { 0, 2.6, 0 }, dur = 2.4 },
	}, { loop = true }),
	-- 21
	preset("Ground Ring Aura", { "ring", "ground", "loop" }, 2, {
		P { tex = "glow", col = { "#ffffff", "#9ac4ff", "#3a6aff" }, trn = { 0.4, 0.85, 1 }, sz = { 0.6, 2 }, life = { 0.8, 1.4 }, spd = { 6, 10 }, sprd = { 3, 3 }, shape = "Cylinder", style = "Surface", partial = 0.08, rate = 50, light = 1.2, off = { 0, 0.1, 0 }, dur = 2 },
		P { tex = "sparkle", col = { "#eaf6ff", "#8ab8ff" }, sz = { 0.06, 0.2 }, life = { 0.6, 1.2 }, spd = { 0.5, 3 }, sprd = { 180, 180 }, rate = 18, off = { 0, 0.2, 0 }, dur = 2 },
		L { col = "#9ac4ff", bright = 2, range = 10, off = { 0, 0.2, 0 }, dur = 2 },
	}, { loop = true }),
	-- 22
	preset("Runic Aura", { "runes", "magic", "loop" }, 3.2, {
		P { tex = "square", col = { "#ffffff", "#a8f0ff", "#3a8aff" }, trn = { 0.3, 0.85, 1 }, sz = { 0.15, 0.5 }, life = { 1.4, 2.4 }, spd = { 0.2, 1 }, sprd = { 5, 5 }, shape = "Cylinder", style = "Surface", partial = 0.3, rate = 34, rotspd = { -40, 40 }, light = 1.2, off = { 0, 1.1, 0 }, dur = 3.2 },
		P { tex = "sparkle", col = { "#dff8ff", "#6ac8ff" }, sz = { 0.06, 0.22 }, life = { 1, 2 }, spd = { 0.3, 1.5 }, sprd = { 180, 180 }, rate = 16, dur = 3.2, off = { 0, 1.1, 0 } },
		A { name = "RuneSpin", target = "rig", property = "spin", from = 0, to = 360, dur = 3.2, easing = "Linear" },
		L { col = "#6ac8ff", bright = 1.5, range = 10, off = { 0, 1.1, 0 }, dur = 3.2 },
	}, { loop = true }),
	-- 23
	preset("Radiant Pulse", { "pulse", "holy", "loop" }, 2, {
		P { tex = "glow", col = { "#ffffff", "#fff2c0", "#ffc94a" }, trn = { 0.6, 0.3, 0.95 }, sz = { 0.8, 2.6 }, life = { 0.6, 1.2 }, spd = { 2, 6 }, sprd = { 180, 180 }, rate = 30, light = 1.3, shape = "Sphere", dur = 2 },
		P { tex = "sparkle", col = { "#ffffff", "#ffe08a" }, trn = { 0.2, 0.8, 1 }, sz = { 0.06, 0.2 }, life = { 0.5, 1.2 }, spd = { 2, 8 }, sprd = { 180, 180 }, rate = 26, dur = 2 },
		A { name = "PulseScale", target = "PulseCore", property = "scale", from = 1, to = 1.3, dur = 1, repeatCount = -1, reverse = true, easing = "Sine" },
		M { name = "PulseCore", col = "#ffe8a0", transparency = 0.55, size = { 1.6, 1.6, 1.6 }, material = "Neon", dur = 2 },
		L { col = "#ffe8a0", bright = 3, range = 12, dur = 2 },
	}, { loop = true }),
	-- 24
	preset("Demonic Aura", { "demon", "dark", "loop" }, 3, {
		P { tex = "smoke", col = { "#ff3b1f", "#6b0a00", "#120200" }, trn = { 0.6, 0.9, 1 }, sz = { 1, 3.6 }, life = { 1.4, 2.6 }, spd = { 0.5, 2.5 }, sprd = { 180, 180 }, rate = 24, accel = { 0, 3, 0 }, shape = "Disc", light = 0.6, dur = 3 },
		P { tex = "spark", col = { "#ffb08a", "#ff2a00" }, trn = { 0.2, 0.85, 1 }, sz = { 0.08, 0.3 }, life = { 1.2, 2.2 }, spd = { 0.5, 2.5 }, sprd = { 60, 60 }, rate = 20, accel = { 0, 5, 0 }, dur = 3 },
		B { tex = "glow", col = { "#ff3b1f", "#2a0200" }, trn = { 0.85, 0.6, 1 }, w0 = 0.1, w1 = 0.5, segments = 8, curve = 0, light = 1, off0 = { 0, 3.6, 0 }, off1 = { 0, 0.2, 0 }, dur = 3 },
		L { col = "#ff3b1f", bright = 2, range = 12, dur = 3 },
	}, { loop = true }),
}
