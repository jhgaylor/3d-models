# CLAUDE.md

OpenSCAD models that build to STL, 3MF and PNG. See README.md for the layout, the fresh-machine setup and the build commands.

## Building
- OpenSCAD must be a **nightly** build with the Manifold backend. 2021.01 can't render `src/boston/`. On macOS it's at `/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD` and is usually not on PATH; `tools/build.py` finds it anyway.
- **Never run a full parallel build on a laptop.** Use `make JOBS=2`, or render a single target with `-p <json> -P <preset>`. The Boston lid tiles have run the machine out of memory before.
- Builds use `--hardwarnings`. Any warning fails a printable part.
- After `make`, revert preview PNGs you didn't mean to change (`git checkout -- previews/<file>`). Rendering rewrites some of them byte for byte.
- `python3 tools/check_3mf.py build/<file>.3mf` reports self-touching geometry that slicers call non-manifold, even when OpenSCAD reports the mesh as manifold. The Boston lid tiles must show `touching 0`; `tools/boston_map.py` keeps building columns 0.015 mm apart to guarantee that (issue #16).

## Conventions
- Each model is a `src/<group>/<name>.scad` with a header comment explaining the design and its measured dimensions. Presets go in `<name>.json` (customizer `parameterSets`), assembly notes in `<name>.md`, and a hero render in `<name>_scene.scad` (PNG only).
- Third-party data goes in `src/<group>/vendor/` with an `ATTRIBUTION.md`, using a non-`.scad` extension (for example `.inc`) so the build doesn't treat it as a model.
- Measurements of the UniFi rack come from Ubiquiti's store GLB. Reuse the constants already in the `.scad` files rather than re-deriving them.

## Shipping (only when asked)
1. Branch off `main`, commit, push, `gh pr create`.
2. Wait for the **`build`** check. `terragucci/plan` fails on every PR; ignore it.
3. `gh pr merge <n> --squash --delete-branch`, then `git checkout main && git pull`.
4. `git tag -a vX.Y.Z -m "..." && git push origin vX.Y.Z`. Watch the run, then confirm the assets with `gh release view vX.Y.Z`.
