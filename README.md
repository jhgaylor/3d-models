# 3d-models

OpenSCAD source for 3D-printable models. STL files are built automatically by GitHub Actions on every push and attached to GitHub Releases when you push a version tag.

## Layout

```
src/                 # OpenSCAD source (.scad) — one file per model
build/               # Generated STLs (gitignored)
Makefile             # Builds every src/*.scad → build/*.stl
.github/workflows/   # CI: builds STLs, uploads artifacts, attaches to releases
```

Add new models by dropping a `.scad` file under `src/`. Subdirectories are preserved in `build/`.

## Local build

Install OpenSCAD (https://openscad.org/downloads.html), then:

```
make            # builds all STLs into build/
make clean      # removes build/
make list       # shows discovered sources and outputs
```

The Makefile auto-detects `/Applications/OpenSCAD.app` on macOS. On Linux it uses the `openscad` binary on `PATH`. Override with `make OPENSCAD=/path/to/openscad`.

## Getting STL files

- **Latest build:** Actions tab → most recent run → download the `stl-files` artifact.
- **Versioned release:** push a tag like `v0.1.0` — the workflow attaches every STL to the GitHub Release.

```
git tag v0.1.0
git push origin v0.1.0
```
