#!/usr/bin/env node
/*
 * VFX Studio - .rbxmx packer
 * -------------------------------------------------------------
 * Packs `src/` into `dist/VFXStudio.rbxmx`, a model file that can be
 * dropped into the Roblox Studio Plugins folder or opened/dragged into a
 * place and turned into a Local Plugin.
 *
 * Layout rules (identical to Rojo's, so default.project.json works too):
 *   foo.lua         -> ModuleScript "foo"
 *   foo.server.lua  -> Script "foo"
 *   foo.client.lua  -> LocalScript "foo"
 *   dir/init.lua    -> ModuleScript "dir" (siblings become its children)
 *   dir/            -> Folder "dir"
 *
 * The entry point is src/Main.server.lua -> Script "Main" (RunContext Legacy,
 * which is the only context Roblox executes inside plugins).
 */
"use strict";

const fs = require("fs");
const path = require("path");

const ROOT = path.resolve(__dirname, "..");
const SRC = path.join(ROOT, "src");

const EXTENSIONS = [
  [".server.lua", "Script"],
  [".client.lua", "LocalScript"],
  [".lua", "ModuleScript"],
];

let referentCounter = 0;

function fail(message) {
  console.error("build: " + message);
  process.exit(1);
}

function xmlEscape(value) {
  return String(value).replace(/[&<>"']/g, (c) => ({
    "&": "&amp;",
    "<": "&lt;",
    ">": "&gt;",
    '"': "&quot;",
    "'": "&apos;",
  })[c]);
}

function cdata(source) {
  // A CDATA section cannot contain "]]>"; split it across two sections.
  return String(source).replace(/]]>/g, "]]]]><![CDATA[>");
}

function classify(fileName) {
  for (const [ext, kind] of EXTENSIONS) {
    if (fileName.endsWith(ext)) {
      return { kind, name: fileName.slice(0, -ext.length) };
    }
  }
  return null;
}

function buildNode(absPath, nameOverride) {
  const stat = fs.statSync(absPath);
  const baseName = nameOverride || path.basename(absPath);

  if (!stat.isDirectory()) {
    const info = classify(path.basename(absPath));
    if (!info) return null;
    return {
      kind: info.kind,
      name: nameOverride || info.name,
      source: fs.readFileSync(absPath, "utf8"),
      children: [],
    };
  }

  const entries = fs
    .readdirSync(absPath)
    .filter((entry) => !entry.startsWith("."))
    .sort((a, b) => a.localeCompare(b));

  const initEntry = entries.find((entry) => /^init\.(server|client)?\.?lua$/.test(entry));
  let kind = "Folder";
  let source = null;
  if (initEntry) {
    const info = classify(initEntry);
    kind = info.kind;
    source = fs.readFileSync(path.join(absPath, initEntry), "utf8");
  }

  const children = [];
  for (const entry of entries) {
    if (entry === initEntry) continue;
    const child = buildNode(path.join(absPath, entry));
    if (child) children.push(child);
  }

  return { kind, name: baseName, source, children };
}

function serialize(node, depth) {
  const indent = "\t".repeat(depth);
  const referent = "RBX" + referentCounter++;
  const lines = [];
  lines.push(`${indent}<Item class="${node.kind}" referent="${referent}">`);
  lines.push(`${indent}\t<Properties>`);
  lines.push(`${indent}\t\t<string name="Name">${xmlEscape(node.name)}</string>`);
  lines.push(`${indent}\t\t<bool name="Archivable">true</bool>`);
  if (node.source !== null && node.source !== undefined) {
    lines.push(
      `${indent}\t\t<ProtectedString name="Source"><![CDATA[${cdata(node.source)}]]></ProtectedString>`
    );
  }
  if (node.kind === "Script" || node.kind === "LocalScript") {
    lines.push(`${indent}\t\t<bool name="Disabled">false</bool>`);
    // Legacy (0) is required: Studio does not execute non-legacy RunContext
    // scripts inside plugin models.
    lines.push(`${indent}\t\t<token name="RunContext">0</token>`);
  }
  lines.push(`${indent}\t</Properties>`);
  for (const child of node.children) lines.push(serialize(child, depth + 1));
  lines.push(`${indent}</Item>`);
  return lines.join("\n");
}

function collectNames(node, seen) {
  const names = new Set();
  for (const child of node.children) {
    if (names.has(child.name)) {
      fail(`duplicate child name "${child.name}" inside "${node.name}"`);
    }
    names.add(child.name);
    collectNames(child, seen);
  }
  return seen;
}

function countScripts(node) {
  let total = node.kind === "ModuleScript" || node.kind === "Script" || node.kind === "LocalScript" ? 1 : 0;
  let lines = node.source ? node.source.split("\n").length : 0;
  for (const child of node.children) {
    const sub = countScripts(child);
    total += sub.total;
    lines += sub.lines;
  }
  return { total, lines };
}

function main() {
  if (!fs.existsSync(SRC)) fail("missing src directory");
  const args = process.argv.slice(2);
  const outIndex = args.indexOf("--out");
  const outPath = outIndex >= 0 ? path.resolve(args[outIndex + 1]) : path.join(ROOT, "dist", "VFXStudio.rbxmx");

  const root = {
    kind: "Folder",
    name: "VFXStudio",
    source: null,
    children: [],
  };

  const entries = fs
    .readdirSync(SRC)
    .filter((entry) => !entry.startsWith("."))
    .sort((a, b) => a.localeCompare(b));

  for (const entry of entries) {
    const child = buildNode(path.join(SRC, entry), entry === "Main.server.lua" ? "Main" : undefined);
    if (!child) fail(`unsupported source file: ${entry}`);
    root.children.push(child);
  }

  const mainScript = root.children.find((c) => c.name === "Main");
  if (!mainScript) fail("src/Main.server.lua is required");
  if (mainScript.kind !== "Script") fail("src/Main.server.lua must be a Script");

  collectNames(root, new Set());

  const xml = [
    '<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4">',
    "\t<Meta name=\"ExplicitAutoJoints\">true</Meta>",
    serialize(root, 1),
    "</roblox>",
    "",
  ].join("\n");

  fs.mkdirSync(path.dirname(outPath), { recursive: true });
  fs.writeFileSync(outPath, xml, "utf8");

  const stats = countScripts(root);
  const size = (fs.statSync(outPath).size / 1024).toFixed(1);
  console.log(`built ${path.relative(ROOT, outPath)} (${size} KiB)`);
  console.log(`  scripts: ${stats.total}  lines: ${stats.lines}`);
}

main();
