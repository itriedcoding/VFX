#!/usr/bin/env node
/*
 * Directories are walked in a deterministic order and every `.lua` file is
 * parsed by luau-compile. Catches syntax errors without Roblox Studio.
 */
"use strict";

const fs = require("fs");
const path = require("path");
const { spawnSync } = require("child_process");

const ROOT = path.resolve(__dirname, "..");
const SRC = path.join(ROOT, "src");

function findCompiler() {
  const candidates = [];
  if (process.env.LUAU_BIN) candidates.push(path.join(process.env.LUAU_BIN, "luau-compile"));
  if (process.env.LUAU_COMPILE) candidates.push(process.env.LUAU_COMPILE);
  candidates.push("/tmp/luau/luau-compile", path.join(ROOT, "tools", "bin", "luau-compile"));
  for (const candidate of candidates) {
    if (fs.existsSync(candidate)) return candidate;
  }
  const which = spawnSync("which", ["luau-compile"], { encoding: "utf8" });
  if (which.status === 0 && which.stdout.trim()) return which.stdout.trim();
  return null;
}

function walk(dir, out = []) {
  for (const entry of fs.readdirSync(dir, { withFileTypes: true }).sort((a, b) => a.name.localeCompare(b.name))) {
    if (entry.name.startsWith(".")) continue;
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) walk(full, out);
    else if (entry.name.endsWith(".lua")) out.push(full);
  }
  return out;
}

const compiler = findCompiler();
if (!compiler) {
  console.error("check: luau-compile not found.");
  console.error("  Download it from https://github.com/luau-lang/luau/releases (luau-ubuntu.zip)");
  console.error("  and either put it on PATH, set LUAU_BIN=/path/to/folder, or install to /tmp/luau.");
  process.exit(1);
}

const files = walk(SRC);
let failures = 0;

for (const file of files) {
  const result = spawnSync(compiler, ["-O0", file], { encoding: "utf8" });
  if (result.status !== 0) {
    failures += 1;
    const relative = path.relative(ROOT, file);
    const output = (result.stderr || result.stdout || "").trim();
    console.error(`FAIL ${relative}`);
    if (output) console.error(output);
  }
}

if (failures > 0) {
  console.error(`\ncheck: ${failures} file(s) failed to compile`);
  process.exit(1);
}

console.log(`check: ${files.length} Luau files compiled cleanly`);
