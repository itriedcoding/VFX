#!/usr/bin/env node
/*
 * Generates dist/manifest.json - the payload the in-Studio updater downloads.
 * It carries the real source of every module, so an update can hot-swap the
 * running plugin without a restart.
 *
 * Fails if src/Core/Version.lua and package.json disagree, so a release can
 * never advertise a stale version.
 */
"use strict";

const fs = require("fs");
const path = require("path");

const ROOT = path.resolve(__dirname, "..");
const SRC = path.join(ROOT, "src");
const OUT = path.join(ROOT, "dist", "manifest.json");
const pkg = require(path.join(ROOT, "package.json"));

function fail(message) {
  console.error("manifest: " + message);
  process.exit(1);
}

function classify(fileName) {
  if (fileName.endsWith(".server.lua")) return { className: "Script", name: fileName.slice(0, -".server.lua".length) };
  if (fileName.endsWith(".client.lua")) return { className: "LocalScript", name: fileName.slice(0, -".client.lua".length) };
  if (fileName.endsWith(".lua")) return { className: "ModuleScript", name: fileName.slice(0, -".lua".length) };
  return null;
}

function versionFromLua() {
  const file = path.join(SRC, "Core", "Version.lua");
  const source = fs.readFileSync(file, "utf8");
  const match = source.match(/Version\.VERSION\s*=\s*"([^"]+)"/);
  if (!match) fail("could not read Version.VERSION from src/Core/Version.lua");
  return match[1];
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

const luaVersion = versionFromLua();
if (luaVersion !== pkg.version) {
  fail(`version mismatch: package.json is ${pkg.version}, Version.lua is ${luaVersion}`);
}

const files = [];
let total = 0;

for (const absolute of walk(SRC)) {
  const relative = path.relative(SRC, absolute).replace(/\\/g, "/");
  const base = path.basename(absolute);
  const info = classify(base);
  if (!info) continue;

  const dir = path.dirname(relative);
  if (info.className === "LocalScript") {
    fail(`LocalScripts are not supported by the updater: ${relative}`);
  }

  // Directories keep their name; `dir/init.lua` becomes the module for `dir`.
  const isInit = base.startsWith("init.");
  const segments = dir === "." ? [] : dir.split("/");
  if (!isInit) segments.push(base.slice(0, -".lua".length).replace(/\.(server|client)$/, ""));

  const modulePath = segments.join("/");
  const name = isInit ? (dir === "." ? "init" : path.basename(dir)) : info.name;

  const source = fs.readFileSync(absolute, "utf8");
  total += Buffer.byteLength(source, "utf8");

  files.push({ path: modulePath, name, class: info.className, source });
}

if (files.length === 0) fail("no modules found");
if (files.length > 400) fail(`too many modules (${files.length})`);
if (total > 8 * 1024 * 1024) fail(`manifest is too large (${total} bytes)`);

files.sort((a, b) => a.path.localeCompare(b.path));

fs.mkdirSync(path.dirname(OUT), { recursive: true });
fs.writeFileSync(
  OUT,
  JSON.stringify(
    {
      version: luaVersion,
      generatedAt: new Date().toISOString(),
      files,
    },
    null,
    0
  ),
  "utf8"
);

console.log(`manifest: ${files.length} modules, ${(total / 1024).toFixed(1)} KiB, version ${luaVersion} -> dist/manifest.json`);
