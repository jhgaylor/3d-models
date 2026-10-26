# 3d-models

OpenSCAD source for 3D-printable models. Every `.scad` file builds to **STL** (for slicing), **3MF** (richer modern format), and a **PNG preview** (shown below). Builds run automatically in GitHub Actions: artifacts on every push, attached to GitHub Releases on version tags.

## Layout

```
src/
  boston/            # Boston relief-map rack lid (+ vendor/ OSM map data)
  mac_mini/          # Mac mini rack accessories
  puffco/            # Puffco accessories
  shapes/            # Plain plates, rings, puzzles
  unifi/             # UniFi Toolless Mini Rack panels and shelf docks
  */*.md             # Per-model assembly notes; */vendor/ = third-party data (see ATTRIBUTION.md)
build/               # Generated STL + 3MF (gitignored)
previews/            # Generated PNG renders (tracked in git so README renders on GitHub)
tools/build.py       # Build orchestrator (variants, parallelism, mtime-based rebuild)
tools/site.py        # Static site (GitHub Pages)
tools/boston_map.py  # Regenerates src/boston/vendor/boston_map.inc from OpenStreetMap
Makefile             # Thin wrapper: make / make clean / make list / make force
.github/workflows/   # CI: build, manifold check, artifact upload, release attach, Pages
```

## Variant matrix (parametric models)

Drop a sidecar `src/<name>.json` next to `src/<name>.scad` using OpenSCAD's customizer format. Each entry under `parameterSets` produces one output:

```
src/box.scad
src/box.json     →   build/box.small.stl + .3mf + previews/box.small.png
                     build/box.large.stl + .3mf + previews/box.large.png
```

No sidecar → a single output set: `build/<name>.{stl,3mf}` + `previews/<name>.png`.

The customizer JSON is what OpenSCAD's GUI saves when you "Add new parameter set" — so you can author presets visually and the build picks them up.

## Fresh machine setup

1. **Clone and get the tools**
   ```sh
   git clone git@github.com:jhgaylor/3d-models.git && cd 3d-models
   ```
   You need `python3` (3.10+), `make`, `git`, and the [`gh`](https://cli.github.com/) CLI if you'll cut releases.

2. **Install OpenSCAD *nightly*.** The 2021.01 stable release is CGAL-only and can't render the Boston lid in any reasonable time. The nightly's Manifold backend can. CI uses the nightly too.
   - **macOS:** `brew install --cask openscad@snapshot`, or download a snapshot from <https://openscad.org/downloads.html#snapshots>. The build auto-detects `/Applications/OpenSCAD.app`.
   - **Ubuntu 24.04:** OpenSCAD's official nightly apt repo, the same steps CI uses (see `.github/workflows/build-stl.yml`):
     ```sh
     repo=https://download.opensuse.org/repositories/home:/t-paul/xUbuntu_24.04
     sudo install -d -m 0755 /etc/apt/keyrings
     curl -fsSL "$repo/Release.key" | sudo gpg --dearmor -o /etc/apt/keyrings/openscad.gpg
     echo "deb [signed-by=/etc/apt/keyrings/openscad.gpg] $repo/ ./" | sudo tee /etc/apt/sources.list.d/openscad.list
     sudo apt-get update && sudo apt-get install -y openscad-nightly
     export OPENSCAD=openscad-nightly
     ```
   - **Check:** `openscad --help | grep -i manifold` should list the Manifold backend.

3. **Python packages (only for regenerating map data).** `tools/build.py` uses only the standard library. `tools/boston_map.py` needs `shapely`:
   ```sh
   python3 -m venv .venv && .venv/bin/pip install shapely
   .venv/bin/python tools/boston_map.py   # downloads OSM data into .cache/osm/ on first run
   ```

4. **Build:** `make JOBS=2` (see below). Check that `git status` shows no changes beyond what you expected.

## Local build

```
make             # build STL + 3MF + previews; regenerate README models section
make JOBS=2      # same, with at most 2 OpenSCAD processes at once
make force       # rebuild everything regardless of mtime
make list        # show planned targets (sources → outputs)
make clean       # wipe build/ and previews/*.png
```

The build only re-renders outputs whose sources (or `include`d files) changed.

**Watch memory on heavy models.** `make` defaults to one OpenSCAD process per CPU. The Boston lid's tiles each take a lot of RAM, and rendering all ten of its targets at once has exhausted a laptop. Use `make JOBS=2`, or render one target directly:

```
openscad --hardwarnings -o /tmp/tile.3mf -p src/boston/boston_lid.json -P tile-sw src/boston/boston_lid.scad
```

On macOS the build auto-detects `/Applications/OpenSCAD.app`. Elsewhere it uses `openscad` on `PATH`. Override with `OPENSCAD=/path/to/openscad make`.

Builds run with `--hardwarnings`: non-manifold geometry, unset variables, and other warnings fail the build instead of silently producing broken STLs.

Rendering can rewrite unrelated preview PNGs with byte-level churn. Before committing, revert any preview you didn't mean to change (`git checkout -- previews/<file>`).

## Workflow

1. Branch off `main` and commit there.
2. Open a PR. The **`build`** check must pass. The `terragucci/plan` check fails on every PR and is unrelated.
3. Squash-merge, then tag a release from `main`:
   ```sh
   git checkout main && git pull
   git tag -a v0.X.Y -m "v0.X.Y: what changed" && git push origin v0.X.Y
   ```
   CI attaches every STL + 3MF to the GitHub Release.

## Getting model files

- **Latest build:** Actions tab → most recent run → download the `models` artifact (contains all STL + 3MF).
- **Versioned release:** push a tag like `v0.1.0` — CI attaches every STL + 3MF to the GitHub Release.

```
git tag v0.1.0
git push origin v0.1.0
```

<!-- BEGIN MODELS -->

<img src="previews/boston_lid_scene.png" alt="assembly preview" width="100%">

<img src="previews/mini_claw_chain_scene.png" alt="assembly preview" width="100%">

<sub>Mac mini model by <a href="https://www.printables.com/model/1057608-mac-mini-m4">Satyr</a>, <a href="https://creativecommons.org/licenses/by/4.0/">CC BY 4.0</a>.</sub>

<img src="previews/puffco_jar_knife_caddy_scene.png" alt="assembly preview" width="100%">

<img src="previews/square_plate_puzzle_scene.png" alt="assembly preview" width="100%">

<img src="previews/unifi_ocd_panel_scene.png" alt="assembly preview" width="100%">

<img src="previews/unifi_shelf_dock_scene.png" alt="assembly preview" width="100%">

## Models

### Antenna

| | Model | Parts |
|---|---|---|
| <img src="previews/dipole_wall_sleeve.png" width="120"> | [`dipole_wall_sleeve`](src/antenna/dipole_wall_sleeve.scad) | — |

### Boston

| | Model | Parts |
|---|---|---|
| <img src="previews/boston_lid.tile-ne.png" width="120"> | [`boston_lid`](src/boston/boston_lid.scad) | `tile-ne` · `tile-nw` · `tile-se` · `tile-sw` · `tiles-keys` |

### Mac Mini

| | Model | Parts |
|---|---|---|
| <img src="previews/mini_claw_dovetail.pass-through.png" width="120"> | [`mini_claw_dovetail`](src/mac_mini/mini_claw_dovetail.scad) | `pass-through` · `plug` · `socket` |

### Puffco

| | Model | Parts |
|---|---|---|
| <img src="previews/puffco_jar_knife_caddy.carcass.png" width="120"> | [`puffco_jar_knife_caddy`](src/puffco/puffco_jar_knife_caddy.scad) | `carcass` · `deck` · `drawer` · `lid` |
| <img src="previews/puffco_knife_jar_tray.lid.png" width="120"> | [`puffco_knife_jar_tray`](src/puffco/puffco_knife_jar_tray.scad) | `lid` · `tray` |
| <img src="previews/puffco_modular_tray.bucket.png" width="120"> | [`puffco_modular_tray`](src/puffco/puffco_modular_tray.scad) | `bucket` · `dock` · `knife_jar` · `lid` |

### Shapes

| | Model | Parts |
|---|---|---|
| <img src="previews/band.png" width="120"> | [`band`](src/shapes/band.scad) | — |
| <img src="previews/irregular_pentagon_plate.png" width="120"> | [`irregular_pentagon_plate`](src/shapes/irregular_pentagon_plate.scad) | — |
| <img src="previews/pentagon_plate.png" width="120"> | [`pentagon_plate`](src/shapes/pentagon_plate.scad) | — |
| <img src="previews/square_plate.png" width="120"> | [`square_plate`](src/shapes/square_plate.scad) | — |
| <img src="previews/square_plate_puzzle.back-left.png" width="120"> | [`square_plate_puzzle`](src/shapes/square_plate_puzzle.scad) | `back-left` · `back-right` · `front-left` · `front-right` |
| <img src="previews/trapezoid_plate.png" width="120"> | [`trapezoid_plate`](src/shapes/trapezoid_plate.scad) | — |

### Unifi

| | Model | Parts |
|---|---|---|
| <img src="previews/unifi_ocd_panel.blank-1u-left.png" width="120"> | [`unifi_ocd_panel`](src/unifi/unifi_ocd_panel.scad) | `blank-1u-left` · `blank-1u-right` · `blank-2u-left` · `blank-2u-right` · `fit-test` · `passthrough-1u-left` · `passthrough-1u-right` · `splice` · `vented-1u-left` · `vented-1u-right` · `vented-2u-left` · `vented-2u-right` |
| <img src="previews/unifi_shelf_dock.bricks-x3.png" width="120"> | [`unifi_shelf_dock`](src/unifi/unifi_shelf_dock.scad) | `bricks-x3` · `corner-left` · `corner-right` · `fit-test` · `mac-mini-x3` · `nucbox-m8` · `pins` |

<!-- END MODELS -->
