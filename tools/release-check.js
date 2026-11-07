#!/usr/bin/env node
/*
 * Confirms the plugin's update check against the real GitHub API.
 *
 * Fetches the same two URLs the plugin fetches, then executes the real
 * src/Core/Updater.lua through the mock harness with those responses injected.
 * Use it after publishing a release to prove installed plugins will see it:
 *
 *   npm run release:check
 *   npm run release:check -- --expect-version 1.0.1 --expect-update
 *   npm run release:check -- --require-release
 */
"use strict";

const fs = require("fs");
const path = require("path");
const { spawnSync } = require("child_process");

const ROOT = path.resolve(__dirname, "..");
const SRC = path.join(ROOT, "src");
const BUNDLE = path.join(ROOT, "dist", "live-check.lua");

const MODULES = ["Core/Util", "Core/Format", "Core/Signals", "Core/Version", "Core/Updater"];

function fail(message) {
  console.error("release:check: " + message);
  process.exit(1);
}

function luaSource(relative) {
  return fs.readFileSync(path.join(SRC, relative + ".lua"), "utf8");
}

function luaConstant(source, name) {
  const match = source.match(new RegExp(name + '\\s*=\\s*"([^"]+)"'));
  return match ? match[1] : null;
}

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

async function get(url) {
  try {
    const response = await fetch(url, {
      headers: {
        "User-Agent": "vfx-studio-release-check",
        Accept: "application/json",
      },
    });
    const body = await response.text();
    return { ok: response.ok, status: response.status, body };
  } catch (error) {
    return { ok: false, status: 0, body: "", error: String(error && error.message ? error.message : error) };
  }
}

function luaResponse(url, result) {
  if (result.body.includes("]=====]")) {
    fail("response body contains the bundle terminator");
  }
  return `\t[${JSON.stringify(url)}] = { Success = ${result.ok ? "true" : "false"}, StatusCode = ${result.status}, Body = [=====[\n${result.body}\n]=====] },`;
}

async function main() {
  const args = process.argv.slice(2);
  const expectVersion = (args.find((arg) => arg.startsWith("--expect-version=")) || "").split("=")[1];
  const expectUpdate = args.includes("--expect-update");
  const requireRelease = args.includes("--require-release");

  const versionSource = luaSource("Core/Version");
  const apiUrl = luaConstant(versionSource, "Version.API_URL");
  const fallbackUrl = luaConstant(versionSource, "Version.FALLBACK_MANIFEST_URL");
  if (!apiUrl || !fallbackUrl) fail("could not read the URLs from src/Core/Version.lua");

  console.log("release:check: installed build " + (luaConstant(versionSource, "Version.VERSION") || "?"));
  console.log("  GET " + apiUrl);
  const api = await get(apiUrl);
  console.log("    -> HTTP " + (api.status || "network error") + (api.error ? " (" + api.error + ")" : ""));

  console.log("  GET " + fallbackUrl);
  const fallback = await get(fallbackUrl);
  console.log("    -> HTTP " + (fallback.status || "network error") + (fallback.error ? " (" + fallback.error + ")" : ""));

  const entries = MODULES.map((key) => {
    const info = key.split("/").pop();
    const name = key.endsWith("/init") ? key.split("/")[key.split("/").length - 2] : info;
    return `\t{ path = ${JSON.stringify(key)}, name = ${JSON.stringify(name)}, class = "ModuleScript", source = [======[\n${luaSource(key)}\n]======] },`;
  });

  const httpEntries = [];
  if (api.status !== 404) httpEntries.push(luaResponse(apiUrl, api));
  if (fallback.status !== 404) httpEntries.push(luaResponse(fallbackUrl, fallback));

  const mock = fs.readFileSync(path.join(ROOT, "tools", "mock.lua"), "utf8");
  const live = fs.readFileSync(path.join(ROOT, "tools", "live.lua"), "utf8");

  fs.mkdirSync(path.dirname(BUNDLE), { recursive: true });
  fs.writeFileSync(
    BUNDLE,
    `local FILES = {\n${entries.join("\n")}\n}\n\nLIVE_HTTP = {\n${httpEntries.join("\n")}\n}\n\n${mock}\n${live}`,
    "utf8"
  );

  const interpreter = findInterpreter();
  if (!interpreter) fail("luau interpreter not found; set LUAU_BIN or install to /tmp/luau");

  const run = spawnSync(interpreter, [BUNDLE], { encoding: "utf8", timeout: 120000 });
  if (run.stderr) process.stderr.write(run.stderr);
  if (run.status !== 0) fail("the updater run failed (exit " + run.status + ")");

  const output = {};
  for (const line of String(run.stdout).split("\n")) {
    const index = line.indexOf("=");
    if (index > 0) output[line.slice(0, index).trim()] = line.slice(index + 1).trim();
  }

  const installed = output.INSTALLED || "?";
  const latest = output.LATEST || "-";
  const source = output.SOURCE || (output.STATE === "error" ? "unreachable" : "none");
  const update = output.UPDATE === "true";

  console.log("\nWhat the in-Studio update panel shows:");
  console.log("  installed:  v" + String(installed).replace(/^v/, ""));
  console.log("  latest:     " + (latest === "-" ? "-" : "v" + String(latest).replace(/^v/, "") + " (" + source + ")"));
  console.log("  update:     " + (update ? "available" : "up to date"));
  if (output.MANIFEST) console.log("  manifest:   " + output.MANIFEST);
  if (output.STATE === "error") console.log("  status:     error - " + (output.ERROR || "unknown"));

  let failed = false;
  if (requireRelease && source !== "release") {
    console.error("\nrelease:check: expected a published GitHub release, but the check used '" + source + "'. Push a v* tag and wait for the Release workflow.");
    failed = true;
  }
  if (expectVersion && String(latest).replace(/^v/, "") !== String(expectVersion).replace(/^v/, "")) {
    console.error("\nrelease:check: expected latest " + expectVersion + ", got " + latest);
    failed = true;
  }
  if (expectUpdate && !update) {
    console.error("\nrelease:check: expected an available update, but the installed build is already current.");
    failed = true;
  }

  if (failed) process.exit(1);
  console.log("\nrelease:check: OK");
}

main().catch((error) => fail(String(error && error.stack ? error.stack : error)));
