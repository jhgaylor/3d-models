#!/usr/bin/env python3
"""Build every src/*.scad into STL + 3MF + PNG preview.

Variant matrix: a sidecar `src/<name>.json` with OpenSCAD customizer
`parameterSets` produces one output per preset, named `<name>.<preset>.<ext>`.
No sidecar => single output `<name>.<ext>`.

`--hardwarnings` is on, so non-manifold geometry fails the build.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor, as_completed
from dataclasses import dataclass
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "src"
BUILD = ROOT / "build"
PREVIEW = ROOT / "previews"
README = ROOT / "README.md"
IMG_SIZE = "1024,768"
COLORSCHEME = "Tomorrow"
README_BEGIN = "<!-- BEGIN MODELS -->"
README_END = "<!-- END MODELS -->"


def find_openscad() -> str:
    env = os.environ.get("OPENSCAD")
    if env:
        return env
    on_path = shutil.which("openscad")
    if on_path:
        return on_path
    mac_app = "/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD"
    if Path(mac_app).exists():
        return mac_app
    sys.exit("error: openscad not found. Set $OPENSCAD or install it.")


OPENSCAD = find_openscad()


@dataclass(frozen=True)
class Target:
    scad: Path           # source file
    preset: str | None   # preset name or None
    preset_file: Path | None
    ext: str             # stl | 3mf | png
    out: Path            # absolute output path

    @property
    def label(self) -> str:
        name = self.scad.stem + (f".{self.preset}" if self.preset else "")
        return f"{name}.{self.ext}"


def is_scene(scad: Path) -> bool:
    # Scenes are assembly/hero renders, not printable parts: PNG only.
    return scad.stem.endswith("_scene")


def variants_for(scad: Path) -> list[tuple[str | None, Path | None]]:
    sidecar = scad.with_suffix(".json")
    if not sidecar.exists():
        return [(None, None)]
    data = json.loads(sidecar.read_text())
    presets = list(data.get("parameterSets", {}).keys())
    if not presets:
        return [(None, None)]
    return [(p, sidecar) for p in presets]


def plan_targets() -> list[Target]:
    targets: list[Target] = []
    for scad in sorted(SRC.rglob("*.scad")):
        exts = (("png", PREVIEW),) if is_scene(scad) else \
               (("stl", BUILD), ("3mf", BUILD), ("png", PREVIEW))
        for preset, sidecar in variants_for(scad):
            name = scad.stem + (f".{preset}" if preset else "")
            for ext, out_dir in exts:
                targets.append(Target(
                    scad=scad,
                    preset=preset,
                    preset_file=sidecar,
                    ext=ext,
                    out=out_dir / f"{name}.{ext}",
                ))
    return targets


_USE_INCLUDE_RE = re.compile(r'^\s*(?:use|include)\s*<([^>]+)>', re.MULTILINE)
_deps_cache: dict[Path, frozenset[Path]] = {}


def collect_scad_deps(scad: Path) -> frozenset[Path]:
    # Return the file plus every .scad it transitively use<>/include<>'s.
    # Seeding the cache with {self} before recursing breaks any cycles.
    scad = scad.resolve()
    cached = _deps_cache.get(scad)
    if cached is not None:
        return cached
    _deps_cache[scad] = frozenset({scad})
    deps: set[Path] = {scad}
    try:
        text = scad.read_text()
    except OSError:
        return _deps_cache[scad]
    for m in _USE_INCLUDE_RE.finditer(text):
        dep = (scad.parent / m.group(1)).resolve()
        if dep.exists():
            deps |= collect_scad_deps(dep)
    result = frozenset(deps)
    _deps_cache[scad] = result
    return result


def needs_rebuild(t: Target) -> bool:
    if not t.out.exists():
        return True
    out_mtime = t.out.stat().st_mtime
    deps: set[Path] = set(collect_scad_deps(t.scad))
    if t.preset_file:
        deps.add(t.preset_file)
    return any(d.stat().st_mtime > out_mtime for d in deps)


def build_one(t: Target) -> tuple[Target, bool, str]:
    t.out.parent.mkdir(parents=True, exist_ok=True)
    cmd = [OPENSCAD, "--hardwarnings", "-o", str(t.out)]
    if t.ext == "png":
        cmd += [f"--imgsize={IMG_SIZE}", f"--colorscheme={COLORSCHEME}"]
    if t.preset:
        cmd += ["-p", str(t.preset_file), "-P", t.preset]
    cmd.append(str(t.scad))
    res = subprocess.run(cmd, capture_output=True, text=True)
    ok = res.returncode == 0
    msg = res.stderr if not ok else ""
    return t, ok, msg


def render_models_section(targets: list[Target]) -> str:
    # Group PNG targets by source .scad, then by subfolder of src/
    by_scad: dict[Path, list[Target]] = {}
    for t in targets:
        if t.ext != "png" or is_scene(t.scad):
            continue
        by_scad.setdefault(t.scad, []).append(t)

    # Group scad files by their immediate parent folder name (relative to SRC)
    by_folder: dict[str, list[Path]] = {}
    for scad in sorted(by_scad):
        folder = scad.parent.relative_to(SRC).as_posix()  # "." or "mac_mini" etc.
        by_folder.setdefault(folder, []).append(scad)

    lines: list[str] = ["", "## Models", ""]
    for folder in sorted(by_folder):
        heading = folder if folder != "." else "misc"
        lines.append(f"### {heading.replace('_', ' ').title()}")
        lines.append("")
        lines.append("| | Model | Parts |")
        lines.append("|---|---|---|")
        for scad in sorted(by_folder[folder]):
            name = scad.stem
            rel_src = scad.relative_to(ROOT).as_posix()
            previews = sorted(by_scad[scad], key=lambda t: t.preset or "")
            # Use first preview as the thumbnail
            thumb_path = previews[0].out.relative_to(ROOT).as_posix()
            thumb = f'<img src="{thumb_path}" width="120">'
            # Parts column: dash for single, backtick-joined list for variants
            has_variants = any(t.preset for t in previews)
            if has_variants:
                parts = " · ".join(f"`{t.preset}`" for t in previews)
            else:
                parts = "—"
            lines.append(f"| {thumb} | [`{name}`]({rel_src}) | {parts} |")
        lines.append("")
    return "\n".join(lines)


def update_readme(targets: list[Target]) -> bool:
    if not README.exists():
        return False
    text = README.read_text()
    if README_BEGIN not in text or README_END not in text:
        return False
    pre, _, rest = text.partition(README_BEGIN)
    _, _, post = rest.partition(README_END)
    section = render_models_section(targets)
    new = f"{pre}{README_BEGIN}\n{section}\n{README_END}{post}"
    if new != text:
        README.write_text(new)
        return True
    return False


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--jobs", "-j", type=int, default=os.cpu_count() or 1)
    ap.add_argument("--force", action="store_true", help="rebuild everything")
    ap.add_argument("--list", action="store_true", help="show planned targets and exit")
    args = ap.parse_args()

    targets = plan_targets()
    if args.list:
        for t in targets:
            print(t.out.relative_to(ROOT), "<-", t.scad.relative_to(ROOT),
                  f"[{t.preset}]" if t.preset else "")
        return 0

    todo = [t for t in targets if args.force or needs_rebuild(t)]
    print(f"openscad: {OPENSCAD}")
    print(f"targets: {len(targets)} total, {len(todo)} to build")

    failed: list[tuple[Target, str]] = []
    with ThreadPoolExecutor(max_workers=args.jobs) as ex:
        futures = {ex.submit(build_one, t): t for t in todo}
        for fut in as_completed(futures):
            t, ok, msg = fut.result()
            status = "ok " if ok else "FAIL"
            print(f"  {status}  {t.out.relative_to(ROOT)}")
            if not ok:
                failed.append((t, msg))

    if failed:
        print(f"\n{len(failed)} target(s) failed:", file=sys.stderr)
        for t, msg in failed:
            print(f"--- {t.label} ---\n{msg}", file=sys.stderr)
        return 1

    if update_readme(targets):
        print("readme: Models section updated")
    return 0


if __name__ == "__main__":
    sys.exit(main())
