#!/usr/bin/env node
/*
 * Packages the built plugin for release.
 *
 * Produces `dist/VFXStudio.zip` containing:
 *   VFXStudio.rbxmx   the local plugin model
 *   INSTALL.txt       what it is and how to install it
 *
 * A .rbxmx alone is all Studio needs, but a zip is what people expect from a
 * release page and it keeps the install notes next to the file. The archive is
 * written with Node's zlib only - no dependency - and is deterministic (fixed
 * timestamps, sorted entries), so identical sources always produce an identical
 * zip. Every entry is read back and compared after writing.
 */
"use strict";

const fs = require("fs");
const path = require("path");
const zlib = require("zlib");

const ROOT = path.resolve(__dirname, "..");
const SRC = path.join(ROOT, "src");
const DIST = path.join(ROOT, "dist");
const MODEL = path.join(DIST, "VFXStudio.rbxmx");
const OUT = path.join(DIST, "VFXStudio.zip");

function fail(message) {
  console.error("package: " + message);
  process.exit(1);
}

// ---------------------------------------------------------------------------
// crc32

const CRC_TABLE = (() => {
  const table = new Int32Array(256);
  for (let index = 0; index < 256; index++) {
    let value = index;
    for (let bit = 0; bit < 8; bit++) {
      value = value & 1 ? 0xedb88320 ^ (value >>> 1) : value >>> 1;
    }
    table[index] = value;
  }
  return table;
})();

function crc32(buffer) {
  let crc = -1;
  for (let index = 0; index < buffer.length; index++) {
    crc = (crc >>> 8) ^ CRC_TABLE[(crc ^ buffer[index]) & 0xff];
  }
  return (crc ^ -1) >>> 0;
}

// ---------------------------------------------------------------------------
// zip writer
// ---------------------------------------------------------------------------

const DOS_TIME = 0;
const DOS_DATE = 0x21; // 1980-01-01, the earliest representable date

function writeArchive(entries) {
  const localParts = [];
  const centralParts = [];
  let offset = 0;

  for (const entry of entries) {
    const name = Buffer.from(entry.name, "utf8");
    const data = Buffer.from(entry.data, "utf8");
    const deflated = zlib.deflateRawSync(data, { level: 9 });
    const useDeflate = deflated.length < data.length;
    const payload = useDeflate ? deflated : data;
    const method = useDeflate ? 8 : 0;
    const checksum = crc32(data);

    const local = Buffer.alloc(30);
    local.writeUInt32LE(0x04034b50, 0); // local file header
    local.writeUInt16LE(20, 4); // version needed to extract
    local.writeUInt16LE(0x0800, 6); // UTF-8 name
    local.writeUInt16LE(method, 8);
    local.writeUInt16LE(DOS_TIME, 10);
    local.writeUInt16LE(DOS_DATE, 12);
    local.writeUInt32LE(checksum, 14);
    local.writeUInt32LE(payload.length, 18);
    local.writeUInt32LE(data.length, 22);
    local.writeUInt16LE(name.length, 26);
    local.writeUInt16LE(0, 28); // extra field length
    localParts.push(local, name, payload);

    const central = Buffer.alloc(46);
    central.writeUInt32LE(0x02014b50, 0); // central directory header
    central.writeUInt16LE(20, 4); // version made by
    central.writeUInt16LE(20, 6); // version needed
    central.writeUInt16LE(0x0800, 8);
    central.writeUInt16LE(method, 10);
    central.writeUInt16LE(DOS_TIME, 12);
    central.writeUInt16LE(DOS_DATE, 14);
    central.writeUInt32LE(checksum, 16);
    central.writeUInt32LE(payload.length, 20);
    central.writeUInt32LE(data.length, 24);
    central.writeUInt16LE(name.length, 28);
    central.writeUInt16LE(0, 30); // extra
    central.writeUInt16LE(0, 32); // comment
    central.writeUInt16LE(0, 34); // disk number
    central.writeUInt16LE(0, 36); // internal attributes
    central.writeUInt32LE(0, 38); // external attributes
    central.writeUInt32LE(offset, 42); // local header offset
    centralParts.push(central, name);

    offset += local.length + name.length + payload.length;
  }

  const central = Buffer.concat(centralParts);
  const end = Buffer.alloc(22);
  end.writeUInt32LE(0x06054b50, 0);
  end.writeUInt16LE(0, 4); // this disk
  end.writeUInt16LE(0, 6); // disk with the central directory
  end.writeUInt16LE(entries.length, 8);
  end.writeUInt16LE(entries.length, 10);
  end.writeUInt32LE(central.length, 12);
  end.writeUInt32LE(offset, 16);
  end.writeUInt16LE(0, 20); // comment length

  return Buffer.concat([...localParts, central, end]);
}

// ---------------------------------------------------------------------------
// zip reader (self-check)
// ---------------------------------------------------------------------------

function readArchive(buffer) {
  const endOffset = buffer.length - 22;
  if (endOffset < 0 || buffer.readUInt32LE(endOffset) !== 0x06054b50) {
    fail("the written archive has no end-of-central-directory record");
  }
  const count = buffer.readUInt16LE(endOffset + 10);
  let cursor = buffer.readUInt32LE(endOffset + 16);
  const entries = [];

  for (let index = 0; index < count; index++) {
    if (buffer.readUInt32LE(cursor) !== 0x02014b50) fail("corrupt central directory entry");
    const method = buffer.readUInt16LE(cursor + 10);
    const checksum = buffer.readUInt32LE(cursor + 16);
    const compressedSize = buffer.readUInt32LE(cursor + 20);
    const size = buffer.readUInt32LE(cursor + 24);
    const nameLength = buffer.readUInt16LE(cursor + 28);
    const extraLength = buffer.readUInt16LE(cursor + 30);
    const commentLength = buffer.readUInt16LE(cursor + 32);
    const localOffset = buffer.readUInt32LE(cursor + 42);
    const name = buffer.toString("utf8", cursor + 46, cursor + 46 + nameLength);

    if (buffer.readUInt32LE(localOffset) !== 0x04034b50) fail(`corrupt local header for ${name}`);
    const localNameLength = buffer.readUInt16LE(localOffset + 26);
    const localExtraLength = buffer.readUInt16LE(localOffset + 28);
    const start = localOffset + 30 + localNameLength + localExtraLength;
    const payload = buffer.subarray(start, start + compressedSize);
    const data = method === 8 ? zlib.inflateRawSync(payload) : Buffer.from(payload);

    if (data.length !== size) fail(`${name}: size mismatch`);
    if (crc32(data) !== checksum) fail(`${name}: CRC mismatch`);

    entries.push({ name, data });
    cursor += 46 + nameLength + extraLength + commentLength;
  }
  return entries;
}

// ---------------------------------------------------------------------------
// install notes
// ---------------------------------------------------------------------------

function versionFromLua() {
  const source = fs.readFileSync(path.join(SRC, "Core", "Version.lua"), "utf8");
  const match = source.match(/Version\.VERSION\s*=\s*"([^"]+)"/);
  if (!match) fail("could not read Version.VERSION from src/Core/Version.lua");
  return match[1];
}

function installNotes(version) {
  return [
    `VFX Studio v${version}`,
    "=".repeat(`VFX Studio v${version}`.length),
    "",
    "VFXStudio.rbxmx is the whole plugin: a Folder containing the entry Script,",
    "the Core modules, the preset library and the editor UI.",
    "",
    "Install",
    "-------",
    "1. Open Roblox Studio and the place you want the plugin in.",
    "2. Plugins tab -> \"Plugins Folder\" button. Explorer/Finder opens.",
    "3. Copy VFXStudio.rbxmx into that folder.",
    "4. Restart Studio. Open the Plugins tab and click VFX Studio.",
    "",
    "Alternative without the folder: drag VFXStudio.rbxmx into the Explorer of",
    "any place, right-click the VFXStudio folder and choose \"Save as Local",
    "Plugin\", then restart Studio.",
    "",
    "Updating",
    "--------",
    "The plugin updates itself from GitHub releases: click the version chip in",
    "the top bar, press \"Check for updates\", then \"Update now\" (it swaps the",
    "running editor without a restart) and \"Save plugin file\" to keep it.",
    "",
    "Releases: https://github.com/itriedcoding/VFX/releases",
    "Source:   https://github.com/itriedcoding/VFX",
    "",
  ].join("\n");
}

// ---------------------------------------------------------------------------
// main
// ---------------------------------------------------------------------------

function main() {
  const args = process.argv.slice(2);
  const outIndex = args.indexOf("--out");
  const outPath = outIndex >= 0 ? path.resolve(args[outIndex + 1]) : OUT;

  if (!fs.existsSync(MODEL)) {
    fail("missing dist/VFXStudio.rbxmx - run `npm run build` (or `node tools/build-rbxmx.js`) first");
  }

  const model = fs.readFileSync(MODEL, "utf8");
  if (!model.includes("<roblox") || !model.includes('<Item class="Script"')) {
    fail("dist/VFXStudio.rbxmx does not look like a plugin model");
  }
  if (!model.includes('<string name="Name">Main</string>')) {
    fail("dist/VFXStudio.rbxmx has no Main script");
  }

  const version = versionFromLua();
  const entries = [
    { name: "INSTALL.txt", data: installNotes(version) },
    { name: "VFXStudio.rbxmx", data: model },
  ];

  const archive = writeArchive(entries);

  // Read the archive back and compare every byte before anything ships.
  const written = readArchive(archive);
  if (written.length !== entries.length) fail("the archive lost entries");
  for (const entry of entries) {
    const stored = written.find((item) => item.name === entry.name);
    if (!stored) fail(`the archive is missing ${entry.name}`);
    if (!stored.data.equals(Buffer.from(entry.data, "utf8"))) fail(`${entry.name} did not round-trip`);
  }

  fs.mkdirSync(path.dirname(outPath), { recursive: true });
  fs.writeFileSync(outPath, archive);

  const size = (archive.length / 1024).toFixed(1);
  const modelKiB = (Buffer.byteLength(model, "utf8") / 1024).toFixed(1);
  console.log(`packaged ${path.relative(ROOT, outPath)} (${size} KiB)`);
  console.log(`  contents: VFXStudio.rbxmx (${modelKiB} KiB), INSTALL.txt, version ${version}`);
}

main();
