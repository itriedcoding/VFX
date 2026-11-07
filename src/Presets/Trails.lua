--[[
	Trails - 24 ribbon effects. Every trail includes a motion track so the two
	attachments sweep through space and the ribbon actually renders; in game
	the trail follows whatever the rig is welded to.
]]

local DSL = require(script.Parent.DSL)

local P, B, T, L, M, A = DSL.P, DSL.B, DSL.T, DSL.L, DSL.M, DSL.A

local function preset(name: string, tags: { string }, duration: number, components: { any }, extra: any?)
	return DSL.preset(name, "Trails", tags, duration, components, extra)
end

local function ribbon(colors: { string }, width: number, light: number, extra: any?)
	local spec = {
		tex = "glow",
		col = colors,
		trn = { 0, 0.35, 1 },
		lifetime = 0.5,
		minLength = 0.1,
		widthScale = width,
		light = light,
		off0 = { 0, 0.3, 0 },
		off1 = { 0, -0.3, 0 },
		dur = 1,
	}
	for key, value in pairs(extra or {}) do
		spec[key] = value
	end
	return T(spec)
end

return {
	-- 01
	preset("Neon Trail", { "neon", "cyan", "loop" }, 1.6, {
		ribbon({ "#ffffff", "#48e6ff", "#0d5cff" }, 1.1, 1.4, { tex = "square", lifetime = 0.4 }),
		P { tex = "glow", col = { "#ffffff", "#48e6ff" }, sz = { 0.15, 0.5 }, life = { 0.3, 0.7 }, spd = { 0.5, 2 }, sprd = { 180, 180 }, rate = 20, light = 1.2, dur = 1.6 },
		A { name = "Sweep", target = "rig", property = "spin", from = 0, to = 360, dur = 1.6, easing = "Linear" },
		L { col = "#48e6ff", bright = 2, range = 10, dur = 1.6 },
	}, { loop = true }),
	-- 02
	preset("Fire Trail", { "fire", "hot", "loop" }, 1.8, {
		ribbon({ "#fff2c0", "#ff8a1f", "#c42a00" }, 1.4, 1.3, { tex = "fire", lifetime = 0.5 }),
		P { tex = "spark", col = { "#ffe8a0", "#ff5e00" }, sz = { 0.08, 0.28 }, life = { 0.4, 1 }, spd = { 1, 5 }, sprd = { 180, 180 }, rate = 24, accel = { 0, 5, 0 }, light = 1.2, dur = 1.8 },
		A { name = "Sweep", target = "rig", property = "spin", from = 0, to = 360, dur = 1.8, easing = "Linear" },
		L { col = "#ff8a2a", bright = 3, range = 12, dur = 1.8 },
	}, { loop = true }),
	-- 03
	preset("Ice Trail", { "ice", "cold", "loop" }, 2, {
		ribbon({ "#ffffff", "#c9ecff", "#5aa8e0" }, 1.2, 1.1, { tex = "glow", lifetime = 0.55 }),
		P { tex = "sparkle", col = { "#ffffff", "#a8e0ff" }, sz = { 0.06, 0.24 }, life = { 0.6, 1.4 }, spd = { 0.5, 3 }, sprd = { 180, 180 }, rate = 18, light = 1, dur = 2 },
		A { name = "Sweep", target = "rig", property = "spin", from = 0, to = 360, dur = 2, easing = "Linear" },
		L { col = "#a9e2ff", bright = 2, range = 10, dur = 2 },
	}, { loop = true }),
	-- 04
	preset("Electric Trail", { "electric", "zap", "loop" }, 1.4, {
		ribbon({ "#ffffff", "#a8d0ff", "#3a5aff" }, 1, 1.5, { tex = "electric", lifetime = 0.35 }),
		P { tex = "electric", col = { "#ffffff", "#8ab8ff" }, sz = { 0.15, 0.5 }, life = { 0.15, 0.45 }, spd = { 1, 5 }, sprd = { 180, 180 }, rate = 30, rotspd = { -300, 300 }, light = 1.3, dur = 1.4 },
		A { name = "Sweep", target = "rig", property = "spin", from = 0, to = 540, dur = 1.4, easing = "Linear" },
		L { col = "#8ab8ff", bright = 3, range = 10, dur = 1.4 },
	}, { loop = true }),
	-- 05
	preset("Smoke Trail", { "smoke", "soft", "loop" }, 2.4, {
		ribbon({ "#e0e0e0", "#9a9a9a", "#4a4a4a" }, 1.6, 0.4, { tex = "smoke", lifetime = 0.9 }),
		P { tex = "smoke", col = { "#e8e8e8", "#8a8a8a" }, trn = { 0.7, 0.95, 1 }, sz = { 0.4, 1.6 }, life = { 0.8, 1.6 }, spd = { 0.2, 1.5 }, sprd = { 180, 180 }, rate = 16, dur = 2.4 },
		A { name = "Sweep", target = "rig", property = "spin", from = 0, to = 360, dur = 2.4, easing = "Linear" },
	}, { loop = true }),
	-- 06
	preset("Rainbow Trail", { "rainbow", "prism", "loop" }, 2.2, {
		ribbon({ "#ff5a5a", "#ffd75a", "#5affb0", "#5a9dff", "#c95aff" }, 1.2, 1.2, { lifetime = 0.6 }),
		P { tex = "sparkle", col = { "#ffffff", "#ffb0f0" }, sz = { 0.06, 0.22 }, life = { 0.5, 1.2 }, spd = { 0.5, 3 }, sprd = { 180, 180 }, rate = 20, light = 1, dur = 2.2 },
		A { name = "Sweep", target = "rig", property = "spin", from = 0, to = 360, dur = 2.2, easing = "Linear" },
		L { col = "#ffb0f0", bright = 2, range = 10, dur = 2.2 },
	}, { loop = true }),
	-- 07
	preset("Shadow Trail", { "shadow", "dark", "loop" }, 2, {
		ribbon({ "#8a4dff", "#2a0d4d", "#05010d" }, 1.3, 0.8, { lifetime = 0.7, trn = { 0.1, 0.5, 1 } }),
		P { tex = "smoke", col = { "#3a1d5c", "#0d0418" }, trn = { 0.7, 0.95, 1 }, sz = { 0.4, 1.4 }, life = { 0.8, 1.6 }, spd = { 0.2, 1 }, sprd = { 180, 180 }, rate = 14, dur = 2 },
		A { name = "Sweep", target = "rig", property = "spin", from = 0, to = 360, dur = 2, easing = "Linear" },
		L { col = "#6b3fff", bright = 1.5, range = 10, dur = 2 },
	}, { loop = true }),
	-- 08
	preset("Golden Trail", { "gold", "holy", "loop" }, 2, {
		ribbon({ "#ffffff", "#ffe08a", "#c98a1f" }, 1.2, 1.3, { lifetime = 0.55 }),
		P { tex = "sparkle", col = { "#fff8d0", "#ffc94a" }, sz = { 0.06, 0.24 }, life = { 0.6, 1.4 }, spd = { 0.3, 2 }, sprd = { 180, 180 }, rate = 18, light = 1.2, dur = 2 },
		A { name = "Sweep", target = "rig", property = "spin", from = 0, to = 360, dur = 2, easing = "Linear" },
		L { col = "#ffd76a", bright = 2, range = 10, dur = 2 },
	}, { loop = true }),
	-- 09
	preset("Plasma Trail", { "plasma", "sci-fi", "loop" }, 1.5, {
		ribbon({ "#ffffff", "#9fd8ff", "#3a8aff" }, 1.1, 1.5, { lifetime = 0.4, trn = { 0, 0.2, 1 } }),
		P { tex = "glow", col = { "#ffffff", "#5ab0ff" }, sz = { 0.2, 0.6 }, life = { 0.2, 0.5 }, spd = { 1, 4 }, sprd = { 180, 180 }, rate = 26, light = 1.4, orient = "VelocityParallel", dur = 1.5 },
		A { name = "Sweep", target = "rig", property = "spin", from = 0, to = 450, dur = 1.5, easing = "Linear" },
		L { col = "#5ab0ff", bright = 3, range = 10, dur = 1.5 },
	}, { loop = true }),
	-- 10
	preset("Water Trail", { "water", "blue", "loop" }, 2.2, {
		ribbon({ "#ffffff", "#8ad0ff", "#2a6ab8" }, 1.3, 0.8, { tex = "glow", lifetime = 0.6, trn = { 0.2, 0.5, 1 } }),
		P { tex = "sparkle", col = { "#ffffff", "#a8e0ff" }, sz = { 0.05, 0.2 }, life = { 0.5, 1.2 }, spd = { 0.5, 2.5 }, sprd = { 180, 180 }, rate = 20, accel = { 0, -4, 0 }, dur = 2.2 },
		A { name = "Sweep", target = "rig", property = "spin", from = 0, to = 360, dur = 2.2, easing = "Linear" },
		L { col = "#8ad0ff", bright = 1.5, range = 10, dur = 2.2 },
	}, { loop = true }),
	-- 11
	preset("Crimson Trail", { "red", "blood", "loop" }, 2, {
		ribbon({ "#ffd0d0", "#ff3b5c", "#6b0a1a" }, 1.3, 1.1, { lifetime = 0.55 }),
		P { tex = "sparkle", col = { "#ffb0b0", "#ff2a4a" }, sz = { 0.05, 0.2 }, life = { 0.5, 1.2 }, spd = { 0.5, 2.5 }, sprd = { 180, 180 }, rate = 16, accel = { 0, -3, 0 }, dur = 2 },
		A { name = "Sweep", target = "rig", property = "spin", from = 0, to = 360, dur = 2, easing = "Linear" },
		L { col = "#ff3b5c", bright = 2, range = 10, dur = 2 },
	}, { loop = true }),
	-- 12
	preset("Slime Trail", { "slime", "green", "loop" }, 2.4, {
		ribbon({ "#e8ffb0", "#7ad63a", "#2a5c14" }, 1.5, 0.7, { tex = "glow", lifetime = 0.8, trn = { 0.1, 0.4, 1 } }),
		P { tex = "sparkle", col = { "#d8ffb0", "#6ac83a" }, sz = { 0.06, 0.24 }, life = { 0.6, 1.4 }, spd = { 0.2, 1.2 }, sprd = { 180, 180 }, rate = 16, accel = { 0, -5, 0 }, dur = 2.4 },
		A { name = "Sweep", target = "rig", property = "spin", from = 0, to = 300, dur = 2.4, easing = "Linear" },
		L { col = "#7ad63a", bright = 1.5, range = 10, dur = 2.4 },
	}, { loop = true }),
	-- 13
	preset("Energy Ribbon", { "energy", "ribbon", "loop" }, 1.8, {
		B { tex = "glow", col = { "#ffffff", "#8ad0ff", "#3a5aff" }, trn = { 0.1, 0.5, 1 }, w0 = 0.4, w1 = 0.1, segments = 24, curve = 2.4, light = 1.5, texlen = 0.4, texspd = 0.5, off0 = { -2, 0, 0 }, off1 = { 2, 1.5, 0 }, dur = 1.8 },
		P { tex = "spark", col = { "#ffffff", "#8ad0ff" }, sz = { 0.06, 0.2 }, life = { 0.4, 1 }, spd = { 0.5, 3 }, sprd = { 180, 180 }, rate = 18, light = 1.2, dur = 1.8 },
		A { name = "Sweep", target = "rig", property = "spin", from = 0, to = 360, dur = 1.8, easing = "Linear" },
		L { col = "#8ad0ff", bright = 2, range = 10, dur = 1.8 },
	}, { loop = true }),
	-- 14
	preset("Spark Trail", { "spark", "hot", "loop" }, 1.6, {
		ribbon({ "#fff8d0", "#ffb01f", "#c94a00" }, 0.9, 1.4, { tex = "spark", lifetime = 0.35 }),
		P { tex = "spark", col = { "#ffe8a0", "#ff6a00" }, sz = { 0.06, 0.2 }, life = { 0.3, 0.8 }, spd = { 1, 5 }, sprd = { 180, 180 }, rate = 26, light = 1.3, orient = "VelocityParallel", dur = 1.6 },
		A { name = "Sweep", target = "rig", property = "spin", from = 0, to = 480, dur = 1.6, easing = "Linear" },
		L { col = "#ffb01f", bright = 2, range = 10, dur = 1.6 },
	}, { loop = true }),
	-- 15
	preset("Stardust Trail", { "stars", "cosmic", "loop" }, 2.4, {
		ribbon({ "#ffffff", "#c9a6ff", "#5a2bd9" }, 1, 1.2, { tex = "glow", lifetime = 0.7 }),
		P { tex = "star", col = { "#ffffff", "#c9a6ff" }, sz = { 0.08, 0.3 }, life = { 0.8, 1.6 }, spd = { 0.2, 1.5 }, sprd = { 180, 180 }, rate = 18, rotspd = { -80, 80 }, light = 1.2, dur = 2.4 },
		A { name = "Sweep", target = "rig", property = "spin", from = 0, to = 360, dur = 2.4, easing = "Linear" },
		L { col = "#c9a6ff", bright = 2, range = 10, dur = 2.4 },
	}, { loop = true }),
	-- 16
	preset("Void Trail", { "void", "dark", "loop" }, 2.2, {
		ribbon({ "#8a4dff", "#1a0330", "#020008" }, 1.4, 1, { lifetime = 0.8, trn = { 0.2, 0.6, 1 } }),
		P { tex = "smoke", col = { "#2a0d4d", "#05010d" }, trn = { 0.75, 0.95, 1 }, sz = { 0.4, 1.4 }, life = { 0.8, 1.6 }, spd = { 0.2, 1 }, sprd = { 180, 180 }, rate = 14, light = -0.2, dur = 2.2 },
		A { name = "Sweep", target = "rig", property = "spin", from = 0, to = 360, dur = 2.2, easing = "Linear" },
		L { col = "#6b3fff", bright = 1.2, range = 10, dur = 2.2 },
	}, { loop = true }),
	-- 17
	preset("Poison Trail", { "poison", "gas", "loop" }, 2.4, {
		ribbon({ "#d8ff8a", "#6aa82a", "#1f3a0d" }, 1.4, 0.6, { tex = "glow", lifetime = 0.8, trn = { 0.3, 0.6, 1 } }),
		P { tex = "sparkle", col = { "#e8ffb0", "#7fe04a" }, sz = { 0.05, 0.2 }, life = { 0.6, 1.4 }, spd = { 0.2, 1.2 }, sprd = { 180, 180 }, rate = 18, light = 0.8, dur = 2.4 },
		A { name = "Sweep", target = "rig", property = "spin", from = 0, to = 320, dur = 2.4, easing = "Linear" },
		L { col = "#7fe04a", bright = 1.2, range = 10, dur = 2.4 },
	}, { loop = true }),
	-- 18
	preset("Sand Trail", { "sand", "desert", "loop" }, 2.4, {
		ribbon({ "#e6cf9e", "#b08a52", "#6b5230" }, 1.6, 0.5, { tex = "smoke", lifetime = 1 }),
		P { tex = "dust", col = { "#d8bd8a", "#8a6a3a" }, trn = { 0.5, 0.9, 1 }, sz = { 0.2, 0.8 }, life = { 0.6, 1.4 }, spd = { 0.2, 1.5 }, sprd = { 180, 180 }, rate = 18, accel = { 0, -3, 0 }, dur = 2.4 },
		A { name = "Sweep", target = "rig", property = "spin", from = 0, to = 300, dur = 2.4, easing = "Linear" },
	}, { loop = true }),
	-- 19
	preset("Leaf Trail", { "leaves", "nature", "loop" }, 2.6, {
		ribbon({ "#e8ffb0", "#7ac83a", "#2a5c14" }, 1.2, 0.6, { tex = "glow", lifetime = 0.9, trn = { 0.3, 0.7, 1 } }),
		P { tex = "debris", col = { "#d8ff9a", "#5aa82a" }, sz = { 0.1, 0.35 }, life = { 0.8, 1.8 }, spd = { 0.2, 1.2 }, sprd = { 180, 180 }, rate = 16, rotspd = { -100, 100 }, accel = { 0, -2, 0 }, light = 0.5, dur = 2.6 },
		A { name = "Sweep", target = "rig", property = "spin", from = 0, to = 280, dur = 2.6, easing = "Linear" },
	}, { loop = true }),
	-- 20
	preset("Bubble Trail", { "bubbles", "water", "loop" }, 2.6, {
		ribbon({ "#ffffff", "#bfe8ff", "#5aa8e0" }, 1.1, 0.9, { tex = "glow", lifetime = 0.7, trn = { 0.2, 0.6, 1 } }),
		P { tex = "sparkle", col = { "#ffffff", "#bfe8ff" }, sz = { 0.08, 0.3 }, life = { 0.8, 1.8 }, spd = { 0.3, 1.5 }, sprd = { 180, 180 }, rate = 18, accel = { 0, 3, 0 }, light = 1, dur = 2.6 },
		A { name = "Sweep", target = "rig", property = "spin", from = 0, to = 300, dur = 2.6, easing = "Linear" },
		L { col = "#bfe8ff", bright = 1.2, range = 10, dur = 2.6 },
	}, { loop = true }),
	-- 21
	preset("Laser Trail", { "laser", "thin", "loop" }, 1.2, {
		ribbon({ "#ffffff", "#ff4d4d", "#6b0000" }, 0.7, 1.6, { tex = "square", lifetime = 0.28, trn = { 0, 0.15, 1 } }),
		P { tex = "spark", col = { "#ffffff", "#ff6a6a" }, sz = { 0.06, 0.18 }, life = { 0.2, 0.5 }, spd = { 1, 4 }, sprd = { 180, 180 }, rate = 24, light = 1.4, orient = "VelocityParallel", dur = 1.2 },
		A { name = "Sweep", target = "rig", property = "spin", from = 0, to = 600, dur = 1.2, easing = "Linear" },
		L { col = "#ff4d4d", bright = 3, range = 10, dur = 1.2 },
	}, { loop = true }),
	-- 22
	preset("Ghost Trail", { "ghost", "spirit", "loop" }, 2.6, {
		ribbon({ "#ffffff", "#bfe0ff", "#5a7a9a" }, 1.3, 0.6, { tex = "smoke", lifetime = 1, trn = { 0.4, 0.7, 1 } }),
		P { tex = "smoke", col = { "#dff0ff", "#7a96b0" }, trn = { 0.85, 0.95, 1 }, sz = { 0.5, 1.8 }, life = { 1, 2 }, spd = { 0.1, 0.8 }, sprd = { 180, 180 }, rate = 12, dur = 2.6 },
		A { name = "Sweep", target = "rig", property = "spin", from = 0, to = 260, dur = 2.6, easing = "Linear" },
		L { col = "#bfe0ff", bright = 1, range = 10, dur = 2.6 },
	}, { loop = true }),
	-- 23
	preset("Molten Trail", { "lava", "molten", "loop" }, 2, {
		ribbon({ "#fff8d0", "#ff8a1f", "#7a1a00" }, 1.5, 1.5, { tex = "fire", lifetime = 0.7, trn = { 0.1, 0.4, 1 } }),
		P { tex = "fire", col = { "#ffb347", "#c42a00" }, trn = { 0.3, 0.9, 1 }, sz = { 0.3, 1.2 }, life = { 0.5, 1.2 }, spd = { 0.3, 2 }, sprd = { 180, 180 }, rate = 20, accel = { 0, 3, 0 }, light = 1.3, dur = 2 },
		A { name = "Sweep", target = "rig", property = "spin", from = 0, to = 360, dur = 2, easing = "Linear" },
		L { col = "#ff7a1f", bright = 3, range = 12, dur = 2 },
	}, { loop = true }),
	-- 24
	preset("Cosmic Trail", { "cosmic", "space", "loop" }, 2.8, {
		ribbon({ "#ffffff", "#9fd8ff", "#7a5aff" }, 1.2, 1.3, { tex = "glow", lifetime = 0.8 }),
		P { tex = "star", col = { "#ffffff", "#9fd8ff" }, sz = { 0.06, 0.26 }, life = { 1, 2 }, spd = { 0.1, 1 }, sprd = { 180, 180 }, rate = 16, rotspd = { -50, 50 }, light = 1.2, dur = 2.8 },
		A { name = "Sweep", target = "rig", property = "spin", from = 0, to = 240, dur = 2.8, easing = "Linear" },
		L { col = "#9fd8ff", bright = 2, range = 12, dur = 2.8 },
	}, { loop = true }),
}
