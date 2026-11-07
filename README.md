# VFX Studio

A professional visual-effects editor for Roblox Studio: **324 hand-authored presets** across 14 categories, a live 3D stage, a timeline, a full property inspector with gradient and curve editors, a texture manager, a performance analyser, and one-click export to real instances with a generated controller script.

Everything the plugin advertises is implemented with real Roblox instances and real properties. There are no placeholder buttons, no mock panels and no fake preset names: the library is validated at load time, and the whole data path is exercised by an automated headless test suite.

---

## Install

The built plugin model is committed at [`dist/VFXStudio.rbxmx`](dist/VFXStudio.rbxmx).

**Local plugin (recommended)**

1. In Studio, go to **Plugins → Plugins Folder** (or **Save as Local Plugin** from the model).
2. Copy `dist/VFXStudio.rbxmx` into that folder.
3. Restart Studio. A **VFX Studio** button appears in the **Plugins** tab.

**As a local plugin from a place**

1. Drag `dist/VFXStudio.rbxmx` into the Explorer of any place.
2. Right-click the `VFXStudio` folder → **Save as Local Plugin**.
3. Restart Studio.

**From source with Rojo**

```bash
rojo build default.project.json -o VFXStudio.rbxmx
```

The project file mirrors the same layout as the bundled packer, so either route produces the same tree.

> The entry point is `Script "Main"` with **RunContext = Legacy**. Roblox only executes legacy scripts inside plugins; a non-legacy context would silently do nothing.

---

## Quick start

1. Click **VFX Studio** in the Plugins tab.
2. Pick an effect in the library — search by name, tag or category, or star your favourites.
3. It compiles into the viewport immediately and starts playing.
4. Drag to orbit, scroll to zoom, tweak fields in the inspector and drag bars in the timeline.
5. Press **Export**, choose a destination, and the effect, its controller ModuleScript and its README land in the place as one undoable step.

Keyboard: `Space` play/pause, `R` restart, `Del` remove the selected component, `Ctrl+Z` / `Ctrl+Y` undo/redo, `Ctrl+D` duplicate.

---

## The preset library

324 presets, 14 categories, 355 tags, 1001 components in total.

| Category | What is in it |
| --- | --- |
| Explosions | fireballs, shockwaves, debris, plasma, arcane detonations |
| Fire | campfires, torches, flamethrowers, fire walls, phoenix rises |
| Smoke | plumes, steam, dust clouds, tear gas, volcanic ash |
| Lightning | strikes, forks, chain lightning, tesla coils, EMP pulses |
| Magic | sparkles, rune circles, summons, hexes, crystal shards |
| Auras | looping character auras: golden, frost, shadow, cosmic, rage |
| Trails | sword swings, speed trails, ribbons, comet tails |
| Particles | spark fountains, bubbles, confetti, waterfalls, ambient motes |
| Impacts | bullet hits, sparks, splinters, shield blocks, craters |
| Weapons | muzzle flashes, shotgun blasts, plasma cannons, railguns |
| Portals | rifts, summoning gates, void portals, warp rings |
| Weather | rain, thunderstorms, blizzards, tornadoes, meteor showers, sandstorms |
| Energy | beams, orbs, charges, shields, plasma streams |
| Environmental | ambience: dust motes, fireflies, falling leaves, geothermal vents |

Each preset stores only JSON-safe values: hex colours, `{time, value}` keypoint arrays and `{min, max}` ranges. The compiler turns those into `ColorSequence`, `NumberSequence`, `NumberRange`, `Vector2`, `Vector3` and enums. The full spec is also written to a `VFXSpec` attribute on the exported model, so it can be re-imported losslessly.

---

## The editor

**Library (left)** — category list with live counts, instant search across names/tags/descriptions, favourites, your own saved presets, paged result grid (24 at a time so 300+ presets stay instant), and thumbnails generated from the effect's real texture and palette.

**Stage (centre)** — a `ViewportFrame` + `WorldModel` running the compiled instances. Particles, beams, trails and point lights all render and animate. Orbit with the mouse, wheel or buttons to zoom, four lighting setups (Studio dark, Night, Daylight, Void), play/pause, restart, 0.25×–2× speed, loop, and a live performance chip.

**Timeline (bottom)** — one row per component with a draggable bar. Drag the body to retime it, drag either edge to resize its emission window, click a row to select it. The playhead follows playback, and the effect duration is editable with a *Fit* helper.

**Inspector (right)**

- **Properties** — effect name, save-as-preset, import, reset; the component stack with drag-to-reorder, duplicate and delete; and every real property of the selected component: rate, lifetime, speed, spread, acceleration, drag, rotation, spin, size/opacity curves, colour, light emission/influence, emitter shape/style/in-out/direction, orientation, squash, ZOffset, velocity inheritance, locking, wind, texture, beam width/curve/segments/brightness/texture mode, trail lifetime/width, light colour/brightness/range/shadows, mesh-part size/material/shape/spin/float, and motion-track property/target/easing/repeat/reverse.
- **Curves** — a real gradient editor with draggable colour stops, HSV picker (saturation/value square + hue strip), hex input and eight craft palettes; plus opacity and size curve editors where you click to add keys and drag them in two dimensions.
- **Cost** — grade, score, concurrent-particle estimate, burst peak, per-type counts, texture counts and a prioritised issue list with concrete fixes, plus *Optimise effect* and *Analyse selection*.

**Assets (modal)** — the texture catalogue (three engine-shipped textures plus documented sample assets), add-by-id, import textures from the current selection, per-asset validation through `ContentProvider:PreloadAsync`, and removal of your own entries. Added textures persist with your plugin settings.

**Export (modal)** — destination, model name, controller toggle, pre-flight checks, the full generated controller source and a usage snippet. Export inserts a Model containing the rig, attachments, emitters/beams/trails/lights, a `VFXController` ModuleScript and a README marker, all inside a `ChangeHistoryService` recording so one undo removes it.

**Import** — select an existing effect in the Explorer and press *Import*: models exported by VFX Studio are restored from their `VFXSpec` attribute, third-party effects are reconstructed from real emitter/beam/trail/light properties and become editable, savable presets.

---

## Generated controller

Every export writes a self-contained ModuleScript:

```lua
local VFX = require(ReplicatedStorage.VFXPresets.InfernoCore)

local handle = VFX.play(CFrame.new(0, 5, 0)) -- clones the model into workspace
handle:Play()
handle:Pause() -- stop emitting, let live particles fade
handle:Destroy()

VFX.attach(workspace.SomePart) -- follows a part every heartbeat
VFX.playOnce()                 -- fire and forget
```

The controller embeds the effect timeline and reproduces the editor's semantics: start windows, durations, bursts with repeats, looping, and tween tracks (spin, float, brightness, transparency, scale). The test suite compiles every generated controller as Luau to guarantee it is valid source.

---

## Architecture

```
src/
  Main.server.lua          plugin entry: toolbar, dock widget, lifecycle
  Core/
    Util, Theme, Format    helpers, design tokens, datatype conversion
    Signals, History       event bus, spec undo stack + Studio recordings
    Assets                  texture catalogue + validation
    Compiler                spec -> instances, and live reconcile
    Player                  timeline runtime used by the preview
    Performance             budget analysis + optimisation
    Decompiler              instances -> editable spec
    ScriptGenerator         generates the exported controller
    Exporter                model export, .rbxm save, undo integration
    Store                   working spec, selection, favourites, custom presets
  Presets/
    DSL.lua                 compact authoring layer
    init.lua                indexing, validation, search
    <14 category files>     the 324 presets
  UI/
    Kit                     widget toolkit (sliders, dropdowns, toggles, drag)
    App                     shell, layout, resizers, toasts, modals, shortcuts
    Library, Preview, Timeline, Inspector, AssetsPanel, ExportDialog
tools/
  build-rbxmx.js            packs src/ into dist/VFXStudio.rbxmx
  check-luau.js             compiles every source file
  test.js + harness.lua     headless mock-Roblox test suite
```

Design notes:

- **Two undo systems.** Spec edits use an in-memory snapshot stack; anything that touches the DataModel (export, insert, replace) uses `ChangeHistoryService` recordings, so Studio's own Ctrl+Z behaves correctly.
- **Preview is the same code path as export.** The viewport runs `Compiler` + `Player`; the generated controller mirrors `Player`'s semantics. There is no separate "preview-only" renderer.
- **Textures are deliberate.** Three `rbxasset://` textures ship with every client; the rest are documented sample assets. Flipbook layouts are left as `None` because Roblox requires a 1024×1024 texture for them, and guessing at asset ids would produce invisible or broken particles.
- **Failures are visible.** Every property write is guarded, panels are created inside `pcall`, compile errors surface in the viewport, and an unstartable plugin shows the actual error instead of a dead button.

---

## Developing

```bash
npm run check    # luau-compile every file in src/
npm run build    # dist/VFXStudio.rbxmx
npm run test     # headless verification harness
npm run verify   # all three
```

`check` and `test` look for `luau` / `luau-compile` on `PATH`, then `/tmp/luau`, then `tools/bin`. Point `LUAU_BIN` at the folder containing them to override. Binaries: [luau-lang/luau releases](https://github.com/luau-lang/luau/releases) (`luau-ubuntu.zip`).

The harness embeds every module into one Luau program and provides a mock Roblox API whose instances **reject writes to properties that do not exist on that class** — the check that keeps the compiler honest. It verifies 5,231 assertions:

- 324 presets load with zero validation errors, unique ids, unique names, non-empty tags and descriptions
- every preset compiles to the expected instance count and round-trips through the `VFXSpec` attribute
- every generated controller is valid Luau
- 24 effects decompile from raw properties and recompile
- performance scores are in range; store undo/redo, favourites, custom presets and JSON persistence survive a reload
- export produces a parented model with controller, README and spec attribute
- zero engine-level warnings during the entire run

Latest run: `38 Luau files compiled cleanly`, `324 presets (1001 components) with zero property errors`, `5231 checks passed, 0 failures`.

---

## Limitations

- **The UI has not been exercised inside Roblox Studio.** It compiles, the editor's data path is fully tested headlessly, and every panel is built from documented APIs — but the final visual/interaction pass (hover states, dock resizing, DPI) needs a human in Studio. Treat the first open as a beta check.
- Sample marketplace textures must be owned by the experience using them; the asset manager flags failures, and the three `rbxasset://` textures are always safe.
- `ViewportFrame` rendering is hardware-dependent on very low-end machines; the performance panel estimates particle load rather than measuring frame time.
- Generated controllers are plain Luau and assume the exported model stays parented where the `require` path says it is.

## License

MIT.
