--[[
	Energy - 24 high-tech and arcane power effects: cores, beams, shields,
	reactors and overloads. These lean on LightEmission and neon mesh parts so
	they glow correctly with any lighting technology.
]]

local DSL = require(script.Parent.DSL)

local P, B, T, L, M, A = DSL.P, DSL.B, DSL.T, DSL.L, DSL.M, DSL.A

local function preset(name: string, tags: { string }, duration: number, components: { any }, extra: any?)
	return DSL.preset(name, "Energy", tags, duration, components, extra)
end

return {
	-- 01
	preset("Energy Core", { "core", "orb", "loop" }, 3, {
		M { name = "Core", col = "#8af0ff", transparency = 0.35, size = { 1.4, 1.4, 1.4 }, material = "Neon", dur = 3 },
		P { name = "Halo", tex = "glow", col = { "#ffffff", "#8af0ff", "#2a6aff" }, trn = { 0.2, 0.7, 0.95 }, sz = { 1.6, 3.4 }, life = { 0.6, 1.2 }, spd = { 0.5, 2 }, sprd = { 180, 180 }, rate = 40, light = 1.5, shape = "Sphere", dur = 3 },
		P { name = "Motes", tex = "spark", col = { "#ffffff", "#8af0ff" }, sz = { 0.06, 0.24 }, life = { 0.8, 1.8 }, spd = { 1, 4 }, sprd = { 180, 180 }, rate = 24, accel = { 0, 2, 0 }, light = 1.2, dur = 3 },
		A { name = "CorePulse", target = "Core", property = "scale", from = 1, to = 1.15, dur = 1.2, repeatCount = -1, reverse = true, easing = "Sine" },
		L { name = "CoreLight", col = "#8af0ff", bright = 5, range = 18, dur = 3 },
	}, { loop = true }),
	-- 02
	preset("Power Up", { "powerup", "buff", "burst" }, 1.8, {
		P { name = "Rise", tex = "glow", col = { "#ffffff", "#8affd0", "#2acf9a" }, trn = { 0.2, 0.7, 1 }, sz = { 0.6, 2.2 }, life = { 0.6, 1.2 }, spd = { 8, 18 }, sprd = { 30, 30 }, rate = 60, accel = { 0, 12, 0 }, shape = "Disc", light = 1.4, dur = 1.4 },
		P { name = "Sparks", tex = "spark", col = { "#ffffff", "#8affd0" }, sz = { 0.06, 0.24 }, life = { 0.6, 1.4 }, spd = { 6, 16 }, sprd = { 60, 60 }, rate = 30, accel = { 0, 8, 0 }, light = 1.3, dur = 1.4 },
		B { name = "Pillar", tex = "glow", col = { "#ffffff", "#8affd0" }, trn = { 0.3, 0.9 }, w0 = 1.6, w1 = 0.4, segments = 8, curve = 0, light = 1.4, off0 = { 0, 0, 0 }, off1 = { 0, 9, 0 }, dur = 0.8 },
		L { name = "PowerLight", col = "#8affd0", bright = 7, range = 24, dur = 1.4 },
	}),
	-- 03
	preset("Energy Blast", { "blast", "energy", "burst" }, 1.2, {
		P { name = "Burst", tex = "glow", col = { "#ffffff", "#8ad0ff", "#3a5aff" }, trn = { 0, 0.4, 1 }, sz = { 3, 10 }, life = { 0.3, 0.7 }, spd = { 20, 40 }, sprd = { 180, 180 }, burst = 30, light = 1.6, dur = 0.8 },
		P { name = "Sparks", tex = "spark", col = { "#ffffff", "#8ad0ff" }, sz = { 0.06, 0.24 }, life = { 0.4, 1 }, spd = { 26, 54 }, sprd = { 180, 180 }, burst = 50, drag = 3, light = 1.3, dur = 1 },
		L { name = "BlastLight", col = "#8ad0ff", bright = 8, range = 26, dur = 0.5 },
	}),
	-- 04
	preset("Laser Beam", { "laser", "beam", "loop" }, 2, {
		B { name = "BeamCore", tex = "square", col = { "#ffffff", "#ff4d4d", "#8a0000" }, trn = { 0, 0.1, 0.9 }, w0 = 0.3, w1 = 0.3, segments = 4, curve = 0, light = 1.8, texlen = 1, texspd = 0.6, off0 = { 0, 0, 0 }, off1 = { 0, 0, -60 }, dur = 2 },
		B { name = "BeamGlow", tex = "glow", col = { "#ff8a8a", "#ff1a1a" }, trn = { 0.3, 0.6, 0.95 }, w0 = 1.4, w1 = 1.4, segments = 4, curve = 0, light = 1.5, off0 = { 0, 0, 0 }, off1 = { 0, 0, -60 }, dur = 2 },
		P { name = "Muzzle", tex = "spark", col = { "#ffffff", "#ff6a6a" }, sz = { 0.06, 0.22 }, life = { 0.2, 0.6 }, spd = { 6, 16 }, sprd = { 20, 20 }, rate = 30, light = 1.3, off = { 0, 0, -1 }, dur = 2 },
		L { name = "BeamLight", col = "#ff3b3b", bright = 4, range = 18, dur = 2 },
	}, { loop = true }),
	-- 05
	preset("Plasma Ball", { "plasma", "orb", "loop" }, 2.6, {
		M { name = "PlasmaCore", col = "#c8f0ff", transparency = 0.25, size = { 1.8, 1.8, 1.8 }, material = "Neon", dur = 2.6 },
		P { name = "Arcs", tex = "electric", col = { "#ffffff", "#8ae8ff" }, trn = { 0.2, 0.85, 1 }, sz = { 0.3, 1 }, life = { 0.2, 0.6 }, spd = { 3, 9 }, sprd = { 180, 180 }, rate = 34, rotspd = { -260, 260 }, light = 1.5, shape = "Sphere", dur = 2.6 },
		P { name = "Halo", tex = "glow", col = { "#ffffff", "#5ac8ff", "#1a5aff" }, trn = { 0.5, 0.85, 0.98 }, sz = { 2.4, 4.4 }, life = { 0.6, 1.2 }, spd = { 0.5, 2 }, sprd = { 180, 180 }, rate = 22, light = 1.4, shape = "Sphere", dur = 2.6 },
		A { name = "PlasmaPulse", target = "PlasmaCore", property = "scale", from = 1, to = 1.12, dur = 0.9, repeatCount = -1, reverse = true, easing = "Sine" },
		L { name = "PlasmaLight", col = "#5ac8ff", bright = 6, range = 20, dur = 2.6 },
	}, { loop = true }),
	-- 06
	preset("Energy Shield", { "shield", "defense", "loop" }, 2.8, {
		M { name = "Shield", col = "#8ad0ff", transparency = 0.85, size = { 5, 5, 0.2 }, material = "ForceField", dur = 2.8, off = { 0, 1.4, -1 } },
		P { name = "Surface", tex = "electric", col = { "#ffffff", "#8ad0ff" }, trn = { 0.5, 0.9, 1 }, sz = { 0.15, 0.5 }, life = { 0.4, 1 }, spd = { 0.5, 2 }, sprd = { 180, 180 }, rate = 30, light = 1.2, off = { 0, 1.4, -1 }, dur = 2.8 },
		P { name = "Rim", tex = "glow", col = { "#ffffff", "#8ad0ff" }, trn = { 0.7, 0.95, 1 }, sz = { 0.4, 1.4 }, life = { 0.6, 1.2 }, spd = { 2, 6 }, sprd = { 180, 180 }, rate = 18, light = 1.1, off = { 0, 1.4, -1 }, dur = 2.8 },
		L { name = "ShieldLight", col = "#8ad0ff", bright = 2, range = 14, off = { 0, 1.4, -1 }, dur = 2.8 },
	}, { loop = true }),
	-- 07
	preset("Warp Speed", { "warp", "speed", "loop" }, 2, {
		P { name = "Streaks", tex = "spark", col = { "#ffffff", "#8ad0ff", "#3a5aff" }, trn = { 0, 0.6, 0.95 }, sz = { 0.06, 0.22 }, life = { 0.5, 1 }, spd = { 80, 120 }, sprd = { 6, 6 }, rate = 120, orient = "VelocityParallel", off = { 0, 0, -8 }, light = 1.4, dur = 2 },
		P { name = "Tunnel", tex = "glow", col = { "#ffffff", "#5aa8ff" }, trn = { 0.4, 0.9, 1 }, sz = { 3, 8 }, life = { 0.6, 1 }, spd = { 60, 90 }, sprd = { 4, 4 }, shape = "Cylinder", style = "Surface", partial = 0.12, rate = 60, light = 1.2, off = { 0, 0, -14 }, dur = 2 },
		L { name = "WarpLight", col = "#8ad0ff", bright = 3, range = 20, dur = 2 },
	}, { loop = true }),
	-- 08
	preset("Antimatter", { "antimatter", "void", "loop" }, 3, {
		M { name = "Core", col = "#c95aff", transparency = 0.2, size = { 1.6, 1.6, 1.6 }, material = "Neon", dur = 3 },
		P { name = "Collapse", tex = "glow", col = { "#ffffff", "#c95aff", "#2a0d4d" }, trn = { 0.9, 0.3, 0 }, sz = { 3, 1 }, life = { 0.6, 1.2 }, spd = { -22, -12 }, sprd = { 180, 180 }, rate = 60, io = "Inward", shape = "Sphere", light = 1.4, dur = 3 },
		P { name = "Sparks", tex = "spark", col = { "#ffffff", "#c95aff" }, sz = { 0.06, 0.22 }, life = { 0.4, 1 }, spd = { 6, 16 }, sprd = { 180, 180 }, rate = 24, light = 1.2, dur = 3 },
		A { name = "AntiPulse", target = "Core", property = "scale", from = 1.05, to = 0.9, dur = 1, repeatCount = -1, reverse = true, easing = "Sine" },
		L { name = "AntiLight", col = "#c95aff", bright = 5, range = 20, dur = 3 },
	}, { loop = true }),
	-- 09
	preset("Fusion Pulse", { "fusion", "pulse", "burst" }, 1.6, {
		P { name = "Wave", tex = "glow", col = { "#ffffff", "#ffe08a", "#ff9a1f" }, trn = { 0, 0.5, 1 }, sz = { 1, 6 }, life = { 0.5, 0.9 }, spd = { 34, 44 }, sprd = { 3, 3 }, shape = "Cylinder", style = "Surface", partial = 0.06, rate = 140, light = 1.6, dur = 0.8 },
		P { name = "Sparks", tex = "spark", col = { "#fff2c0", "#ff9a1f" }, sz = { 0.06, 0.24 }, life = { 0.4, 1.2 }, spd = { 20, 44 }, sprd = { 180, 180 }, rate = 40, drag = 3, light = 1.3, dur = 1 },
		L { name = "FusionLight", col = "#ffd08a", bright = 8, range = 28, dur = 0.6 },
	}),
	-- 10
	preset("Kinetic Charge", { "charge", "kinetic", "gather" }, 2, {
		P { name = "Gather", tex = "spark", col = { "#ffffff", "#8affd0" }, trn = { 0.9, 0.4, 0 }, sz = { 0.08, 0.3 }, life = { 0.8, 1.4 }, spd = { -24, -10 }, sprd = { 180, 180 }, rate = 70, io = "Inward", shape = "Sphere", light = 1.3, dur = 1.6 },
		P { name = "Halo", tex = "glow", col = { "#ffffff", "#8affd0" }, trn = { 0.9, 0.5, 0.2 }, sz = { 1, 2.4 }, life = { 0.6, 1.2 }, spd = { -8, -3 }, sprd = { 180, 180 }, rate = 24, io = "Inward", dur = 1.6 },
		L { name = "ChargeLight", col = "#8affd0", bright = 2, range = 12, dur = 1.8 },
	}),
	-- 11
	preset("Arc Reactor", { "reactor", "core", "loop" }, 3.2, {
		M { name = "Ring", col = "#8af0ff", transparency = 0.4, size = { 2.6, 0.2, 2.6 }, material = "Neon", dur = 3.2 },
		M { name = "Core", col = "#ffffff", transparency = 0.2, size = { 0.9, 0.9, 0.9 }, material = "Neon", dur = 3.2 },
		P { name = "Motes", tex = "spark", col = { "#ffffff", "#8af0ff" }, sz = { 0.06, 0.22 }, life = { 0.6, 1.4 }, spd = { 1, 5 }, sprd = { 60, 60 }, rate = 30, accel = { 0, 3, 0 }, light = 1.3, dur = 3.2 },
		A { name = "ReactorSpin", target = "rig", property = "spin", from = 0, to = 360, dur = 3.2, easing = "Linear" },
		L { name = "ReactorLight", col = "#8af0ff", bright = 4, range = 16, dur = 3.2 },
	}, { loop = true }),
	-- 12
	preset("Energy Wave", { "wave", "ring", "aoe" }, 1.8, {
		P { name = "Wave", tex = "glow", col = { "#ffffff", "#8ad0ff", "#3a5aff" }, trn = { 0.1, 0.6, 1 }, sz = { 0.8, 4 }, life = { 0.8, 1.2 }, spd = { 26, 36 }, sprd = { 2, 2 }, shape = "Cylinder", style = "Surface", partial = 0.05, rate = 120, light = 1.5, off = { 0, 0.1, 0 }, dur = 1.2 },
		P { name = "Ripple", tex = "glow", col = { "#cfe8ff", "#6aaaff" }, trn = { 0.4, 0.85, 1 }, sz = { 0.5, 2.4 }, life = { 0.6, 1 }, spd = { 30, 40 }, sprd = { 2, 2 }, shape = "Cylinder", style = "Surface", partial = 0.04, rate = 80, at = 0.25, light = 1.2, off = { 0, 0.1, 0 }, dur = 1 },
		L { name = "WaveLight", col = "#8ad0ff", bright = 5, range = 24, dur = 0.8 },
	}),
	-- 13
	preset("Ion Storm", { "ion", "storm", "loop" }, 3, {
		P { name = "Ions", tex = "electric", col = { "#ffffff", "#8ae8ff", "#2a8aff" }, trn = { 0.2, 0.85, 1 }, sz = { 0.2, 0.7 }, life = { 0.3, 0.9 }, spd = { 4, 14 }, sprd = { 180, 180 }, rate = 50, shape = "Sphere", rotspd = { -240, 240 }, light = 1.4, dur = 3 },
		P { name = "Motes", tex = "spark", col = { "#ffffff", "#8ae8ff" }, sz = { 0.06, 0.22 }, life = { 0.6, 1.4 }, spd = { 1, 6 }, sprd = { 180, 180 }, rate = 26, accel = { 0, 2, 0 }, light = 1.2, dur = 3 },
		L { name = "IonLight", col = "#8ae8ff", bright = 3, range = 16, dur = 3 },
	}, { loop = true }),
	-- 14
	preset("Photon Beam", { "photon", "beam", "loop" }, 1.8, {
		B { name = "Beam", tex = "glow", col = { "#ffffff", "#fff2c0", "#ffd08a" }, trn = { 0, 0.15, 0.85 }, w0 = 0.5, w1 = 0.5, segments = 4, curve = 0, light = 1.8, texlen = 1, texspd = 0.8, off0 = { 0, 1, -1 }, off1 = { 0, 1, -50 }, dur = 1.8 },
		P { name = "Sparkles", tex = "sparkle", col = { "#ffffff", "#fff2c0" }, sz = { 0.06, 0.24 }, life = { 0.4, 1 }, spd = { 2, 8 }, sprd = { 10, 10 }, rate = 26, light = 1.3, off = { 0, 1, -1 }, dur = 1.8 },
		L { name = "PhotonLight", col = "#fff2c0", bright = 5, range = 20, off = { 0, 1, -1 }, dur = 1.8 },
	}, { loop = true }),
	-- 15
	preset("Tesla Field", { "tesla", "field", "loop" }, 2.6, {
		P { name = "Arcs", tex = "electric", col = { "#ffffff", "#a8d0ff" }, trn = { 0.3, 0.9, 1 }, sz = { 0.2, 0.8 }, life = { 0.15, 0.5 }, spd = { 2, 8 }, sprd = { 180, 180 }, rate = 60, shape = "Sphere", rotspd = { -300, 300 }, light = 1.4, dur = 2.6 },
		B { name = "FieldA", tex = "electric", col = { "#ffffff", "#9ac4ff" }, trn = { 0.4, 0.95 }, w0 = 0.2, w1 = 0.05, segments = 12, curve = 1.6, light = 1.3, off0 = { -3, 0.2, 0 }, off1 = { 3, 0.6, 0 }, dur = 2.6 },
		B { name = "FieldB", tex = "electric", col = { "#ffffff", "#9ac4ff" }, trn = { 0.4, 0.95 }, w0 = 0.2, w1 = 0.05, segments = 12, curve = -1.6, light = 1.3, off0 = { 0, 0.2, -3 }, off1 = { 0, 0.6, 3 }, dur = 2.6 },
		L { name = "FieldLight", col = "#9ac4ff", bright = 3, range = 14, off = { 0, 0.5, 0 }, dur = 2.6 },
	}, { loop = true }),
	-- 16
	preset("Quantum Flare", { "quantum", "flare", "burst" }, 2, {
		P { name = "Flare", tex = "glow", col = { "#ffffff", "#8affff", "#c95aff" }, trn = { 0, 0.4, 1 }, sz = { 2, 8 }, life = { 0.4, 1 }, spd = { 10, 30 }, sprd = { 180, 180 }, burst = 30, light = 1.7, dur = 1.2 },
		P { name = "Particles", tex = "star", col = { "#ffffff", "#8affff", "#c95aff" }, sz = { 0.1, 0.4 }, life = { 0.6, 1.6 }, spd = { 14, 36 }, sprd = { 180, 180 }, burst = 40, rotspd = { -200, 200 }, light = 1.4, dur = 1.6 },
		L { name = "FlareLight", col = "#8affff", bright = 9, range = 30, dur = 0.7 },
	}),
	-- 17
	preset("Overload", { "overload", "warning", "loop" }, 1.6, {
		P { name = "Arcs", tex = "electric", col = { "#ffffff", "#ffb01f", "#ff2a00" }, trn = { 0.2, 0.9, 1 }, sz = { 0.2, 0.9 }, life = { 0.1, 0.4 }, spd = { 4, 16 }, sprd = { 180, 180 }, rate = 80, rotspd = { -320, 320 }, light = 1.5, dur = 1.6 },
		P { name = "Embers", tex = "spark", col = { "#ffe8a0", "#ff5e00" }, sz = { 0.06, 0.22 }, life = { 0.4, 1 }, spd = { 4, 12 }, sprd = { 180, 180 }, rate = 34, accel = { 0, 4, 0 }, light = 1.3, dur = 1.6 },
		L { name = "WarnLight", col = "#ff9a1f", bright = 5, range = 18, dur = 1.6 },
	}, { loop = true }),
	-- 18
	preset("Energy Drain", { "drain", "absorb", "loop" }, 2.2, {
		P { name = "Drain", tex = "spark", col = { "#ffffff", "#8affd0", "#2aa87a" }, trn = { 0.9, 0.4, 0 }, sz = { 0.08, 0.3 }, life = { 0.8, 1.4 }, spd = { -26, -12 }, sprd = { 180, 180 }, rate = 80, io = "Inward", shape = "Sphere", light = 1.3, dur = 2.2, off = { 0, 1.2, 0 } },
		P { name = "Wisps", tex = "glow", col = { "#ffffff", "#8affd0" }, trn = { 0.8, 0.4, 0.1 }, sz = { 0.4, 1.4 }, life = { 0.6, 1.2 }, spd = { -10, -4 }, sprd = { 180, 180 }, rate = 20, io = "Inward", light = 1.2, dur = 2.2, off = { 0, 1.2, 0 } },
		L { name = "DrainLight", col = "#8affd0", bright = 2, range = 12, off = { 0, 1.2, 0 }, dur = 2.2 },
	}, { loop = true }),
	-- 19
	preset("Cyber Glitch", { "glitch", "digital", "loop" }, 1.4, {
		P { name = "Blocks", tex = "square", col = { "#00ffd0", "#ff00a8", "#100020" }, trn = { 0, 0.6, 1 }, sz = { 0.2, 1 }, life = { 0.1, 0.4 }, spd = { 2, 12 }, sprd = { 180, 180 }, rate = 60, rot = { 0, 360 }, light = 1.3, dur = 1.4 },
		P { name = "Scanlines", tex = "square", col = { "#ffffff", "#00ffd0" }, trn = { 0.3, 0.9, 1 }, sz = { 0.05, 0.3 }, life = { 0.2, 0.6 }, spd = { 0, 2 }, sprd = { 180, 180 }, rate = 30, rot = { 0, 90 }, light = 1.2, dur = 1.4 },
		L { name = "GlitchLight", col = "#00ffd0", bright = 3, range = 12, dur = 1.4 },
	}, { loop = true }),
	-- 20
	preset("Mech Thruster", { "thruster", "mech", "loop" }, 2, {
		P { name = "Jet", tex = "fire", col = { "#ffffff", "#8ad0ff", "#3a5aff" }, trn = { 0, 0.5, 1 }, sz = { 0.8, 2.2 }, life = { 0.2, 0.5 }, spd = { 24, 40 }, sprd = { 6, 6 }, rate = 140, light = 1.6, off = { 0, -0.6, 0 }, dir = "Bottom", accel = { 0, -6, 0 }, dur = 2 },
		P { name = "Heat", tex = "spark", col = { "#ffffff", "#8ad0ff" }, sz = { 0.05, 0.2 }, life = { 0.4, 1 }, spd = { 10, 26 }, sprd = { 20, 20 }, rate = 30, light = 1.3, off = { 0, -0.8, 0 }, dur = 2 },
		L { name = "ThrusterLight", col = "#8ad0ff", bright = 4, range = 14, off = { 0, -0.8, 0 }, dur = 2 },
	}, { loop = true }),
	-- 21
	preset("Solar Flare", { "solar", "flare", "loop" }, 3.4, {
		M { name = "Sun", col = "#ffd76a", transparency = 0.15, size = { 3.4, 3.4, 3.4 }, material = "Neon", dur = 3.4 },
		P { name = "Flare", tex = "fire", col = { "#ffffff", "#ffd08a", "#ff5e00" }, trn = { 0.1, 0.7, 0.95 }, sz = { 1.4, 5 }, life = { 1, 2 }, spd = { 4, 12 }, sprd = { 180, 180 }, rate = 50, accel = { 0, 3, 0 }, shape = "Sphere", light = 1.6, dur = 3.4 },
		P { name = "Corona", tex = "glow", col = { "#ffffff", "#ffb347" }, trn = { 0.6, 0.9, 1 }, sz = { 4, 8 }, life = { 1.2, 2.2 }, spd = { 1, 4 }, sprd = { 180, 180 }, rate = 20, shape = "Sphere", light = 1.4, dur = 3.4 },
		L { name = "SunLight", col = "#ffd76a", bright = 8, range = 34, dur = 3.4 },
	}, { loop = true }),
	-- 22
	preset("Neutron Burst", { "neutron", "burst", "space" }, 1.4, {
		P { name = "Burst", tex = "glow", col = { "#ffffff", "#dff0ff", "#8ad0ff" }, trn = { 0, 0.3, 1 }, sz = { 2, 12 }, life = { 0.3, 0.7 }, spd = { 30, 60 }, sprd = { 180, 180 }, burst = 24, light = 1.8, dur = 0.9 },
		P { name = "Streaks", tex = "spark", col = { "#ffffff", "#bfe8ff" }, trn = { 0.1, 0.7, 1 }, sz = { 0.05, 0.2 }, life = { 0.5, 1.2 }, spd = { 60, 110 }, sprd = { 180, 180 }, burst = 50, orient = "VelocityParallel", light = 1.4, dur = 1.1 },
		L { name = "BurstLight", col = "#dff0ff", bright = 10, range = 34, dur = 0.5 },
	}),
	-- 23
	preset("Energy Ring", { "ring", "spin", "loop" }, 2.2, {
		M { name = "Ring", col = "#8af0ff", transparency = 0.5, size = { 3.4, 0.15, 3.4 }, material = "Neon", dur = 2.2 },
		P { name = "Rim", tex = "glow", col = { "#ffffff", "#8af0ff", "#2a6aff" }, trn = { 0.2, 0.8, 1 }, sz = { 0.4, 1.4 }, life = { 0.6, 1.2 }, spd = { 2, 8 }, sprd = { 4, 4 }, shape = "Cylinder", style = "Surface", partial = 0.2, rate = 60, light = 1.4, off = { 0, 0.3, 0 }, dur = 2.2 },
		P { name = "Motes", tex = "spark", col = { "#ffffff", "#8af0ff" }, sz = { 0.05, 0.2 }, life = { 0.6, 1.4 }, spd = { 1, 4 }, sprd = { 180, 180 }, rate = 20, light = 1.2, dur = 2.2 },
		A { name = "RingSpin", target = "rig", property = "spin", from = 0, to = 360, dur = 2.2, easing = "Linear" },
		L { name = "RingLight", col = "#8af0ff", bright = 3, range = 14, off = { 0, 0.3, 0 }, dur = 2.2 },
	}, { loop = true }),
	-- 24
	preset("Static Field", { "static", "field", "loop" }, 1.8, {
		P { name = "Static", tex = "electric", col = { "#ffffff", "#c8e0ff" }, trn = { 0.4, 0.9, 1 }, sz = { 0.1, 0.4 }, life = { 0.1, 0.35 }, spd = { 1, 6 }, sprd = { 180, 180 }, rate = 70, shape = "Sphere", rotspd = { -260, 260 }, light = 1.2, dur = 1.8 },
		P { name = "Crackle", tex = "spark", col = { "#ffffff", "#bcd8ff" }, sz = { 0.03, 0.14 }, life = { 0.2, 0.6 }, spd = { 2, 8 }, sprd = { 180, 180 }, rate = 40, light = 1.1, dur = 1.8 },
		L { name = "StaticLight", col = "#bcd8ff", bright = 2, range = 12, dur = 1.8 },
	}, { loop = true }),
}
