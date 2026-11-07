#!/usr/bin/env node
/*
 * Headless test run.
 *
 * Bundles the real modules into one Luau program (sources are embedded and
 * `require(script.Parent.X)` resolves through a mocked instance tree), then
 * executes tools/mock.lua followed by tools/tests.lua with the standalone Luau
 * interpreter. The generated bundle lands in dist/harness.lua (git-ignored).
 */
"use strict";

const fs = require("fs");
const path = require("path");
const { spawnSync } = require("child_process");

const ROOT = path.resolve(__dirname, "..");
const SRC = path.join(ROOT, "src");
const MOCK = path.join(ROOT, "tools", "mock.lua");
const API = path.join(ROOT, "tools", "api-props.lua");
const TESTS = path.join(ROOT, "tools", "tests.lua");
const OUT_DIR = path.join(ROOT, "dist");
const BUNDLE = path.join(OUT_DIR, "harness.lua");

const ORDER = [
  "Core/Util",
  "Core/Format",
  "Core/Theme",
  "Core/Assets",
  "Presets/DSL",
  "Presets/Explosions",
  "Presets/Fire",
  "Presets/Smoke",
  "Presets/Lightning",
  "Presets/Magic",
  "Presets/Auras",
  "Presets/Trails",
  "Presets/Particles",
  "Presets/Impacts",
  "Presets/Weapons",
  "Presets/Portals",
  "Presets/Weather",
  "Presets/Energy",
  "Presets/Environmental",
  "Presets/init",
  "Core/Signals",
  "Core/History",
  "Core/Compiler",
  "Core/Performance",
  "Core/Decompiler",
  "Core/ScriptGenerator",	"Core/Exporter",
	"Core/Player",
	"Core/Store",
	"Core/Version",
	"Core/Updater",
	"UI/Kit",
	"UI/AssetsPanel",
	"UI/ExportDialog",
	"UI/UpdateDialog",
	"UI/Library",
	"UI/Preview",
	"UI/Timeline",
	"UI/Inspector",
	"UI/App",
];

function findInterpreter() {
  const candidates = [];
  if (process.env.LUAU_BIN) candidates.push(path.join(process.env.LUAU_BIN, "luau"));
  if (process.env.LUAU) candidates.push(process.env.LUAU);
  candidates.push("/tmp/luau/luau", path.join(ROOT, "tools", "bin", "luau"));
  for (const candidate of candidates) {
    if (fs.existsSync(candidate)) return candidate;
  }
  const which = spawnSync("which", ["luau"], { encoding: "utf8" });
  if (which.status === 0 && which.stdout.trim()) return which.stdout.trim();
  return null;
}

function classify(key) {
  if (key.endsWith("init")) {
    const parts = key.split("/");
    return { name: parts[parts.length - 2], className: "ModuleScript" };
  }
  return { name: key.split("/")[key.split("/").length - 1], className: "ModuleScript" };
}

function buildBundle() {
  const entries = [];
  for (const key of ORDER) {
    const file = path.join(SRC, key + ".lua");
    if (!fs.existsSync(file)) {
      console.error(`test: missing module ${key}`);
      process.exit(1);
    }
    const source = fs.readFileSync(file, "utf8");
    if (source.includes("]======]")) {
      console.error(`test: ${key} contains the bundle's long-bracket terminator`);
      process.exit(1);
    }
    const info = classify(key);
    entries.push(
      `\t{ path = ${JSON.stringify(key)}, name = ${JSON.stringify(info.name)}, class = ${JSON.stringify(info.className)}, source = [======[\n${source}\n]======] },`
    );
  }

  if (!fs.existsSync(API)) {
    console.error("test: missing tools/api-props.lua - run `node tools/api-dump.js`");
    process.exit(1);
  }
  const support =
    fs.readFileSync(API, "utf8") + "\n" +
    fs.readFileSync(MOCK, "utf8") + "\n" +
    fs.readFileSync(TESTS, "utf8");
  fs.mkdirSync(OUT_DIR, { recursive: true });
  fs.writeFileSync(BUNDLE, `local FILES = {\n${entries.join("\n")}\n}\n\n${support}`, "utf8");
  return BUNDLE;
}

const interpreter = findInterpreter();
if (!interpreter) {
  console.error("test: luau interpreter not found.");
  console.error("  Download luau-ubuntu.zip from https://github.com/luau-lang/luau/releases");
  console.error("  and set LUAU_BIN=/path/to/folder (expects luau and luau-compile).");
  process.exit(1);
}

const bundle = buildBundle();
const result = spawnSync(interpreter, [bundle], { encoding: "utf8", timeout: 240000 });

if (result.stdout) process.stdout.write(result.stdout);
if (result.stderr) process.stderr.write(result.stderr);

if (result.status !== 0) {
  console.error(`\ntest: FAILED (exit ${result.status})`);
  process.exit(result.status || 1);
}

if (!String(result.stdout).includes("HARNESS OK")) {
  console.error("\ntest: harness did not report success");
  process.exit(1);
}

console.log("test: all checks passed");
