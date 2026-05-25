#!/usr/bin/env python3
"""Generate a static GitHub Pages site listing every model.

Reads the same target plan as build.py so the site stays in lockstep with
src/. Writes site/index.html plus a copy of previews/ for the page to load.
Download links point to assets on the latest GitHub Release.
"""

from __future__ import annotations

import argparse
import html
import os
import shutil
import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from build import ROOT, PREVIEW, plan_targets  # noqa: E402

SITE = ROOT / "site"

CSS = """\
:root { color-scheme: light dark; --max: 1100px; --gap: 24px; }
* { box-sizing: border-box; }
body { font: 15px/1.5 system-ui, -apple-system, sans-serif; max-width: var(--max);
       margin: 2rem auto; padding: 0 1rem; }
h1 { margin: 0 0 .25rem; }
h2 { margin: 2.5rem 0 1rem; font-size: 1.25rem; }
.lede { color: #666; margin: 0 0 2rem; }
.grid { display: grid; gap: var(--gap);
        grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); }
.card { border: 1px solid #0002; border-radius: 8px; overflow: hidden;
        display: flex; flex-direction: column; background: #fff; }
.card img { width: 100%; aspect-ratio: 4/3; object-fit: contain; background: #f5f5f5;
            display: block; }
.body { padding: 14px; display: flex; flex-direction: column; gap: 8px; flex: 1; }
.name { margin: 0; font: 600 15px/1.2 ui-monospace, monospace; word-break: break-all; }
.variant { font: 500 11px/1 ui-monospace, monospace; color: #fff; background: #4a7a5a;
           padding: 2px 7px; border-radius: 4px; white-space: nowrap; }
.meta { color: #666; font-size: 13px; }
.meta a { color: inherit; }
.dl { display: flex; flex-wrap: wrap; gap: 6px; align-items: center; }
.dl .label { font-size: 12px; color: #666; min-width: 70px; }
.dl a { font-size: 12px; padding: 3px 9px; border-radius: 4px; background: #eee;
        text-decoration: none; color: inherit; }
.dl a:hover { background: #ddd; }
.footer { margin: 3rem 0 1rem; color: #666; font-size: 13px; }
.footer code { background: #0001; padding: 1px 5px; border-radius: 3px; }
@media (prefers-color-scheme: dark) {
  body { background: #111; color: #eee; }
  .card { background: #1a1a1a; border-color: #fff2; }
  .card img { background: #222; }
  .meta, .footer { color: #aaa; }
  .dl .label { color: #aaa; }
  .dl a { background: #2a2a2a; }
  .dl a:hover { background: #3a3a3a; }
  .footer code { background: #fff1; }
}
"""


def detect_repo() -> str:
    env = os.environ.get("GITHUB_REPOSITORY")
    if env:
        return env
    try:
        url = subprocess.check_output(
            ["git", "config", "--get", "remote.origin.url"],
            cwd=ROOT, text=True, stderr=subprocess.DEVNULL,
        ).strip()
    except (subprocess.CalledProcessError, FileNotFoundError):
        return "owner/repo"
    if url.startswith("git@github.com:"):
        return url.removeprefix("git@github.com:").removesuffix(".git")
    if "github.com/" in url:
        return url.split("github.com/", 1)[1].removesuffix(".git")
    return "owner/repo"


def render(repo: str) -> str:
    targets = plan_targets()

    # Group by category (subfolder under src/), then by source stem.
    by_category: dict[str, dict[str, list]] = {}
    for t in targets:
        rel = t.scad.relative_to(ROOT / "src")
        category = rel.parts[0] if len(rel.parts) > 1 else "other"
        by_category.setdefault(category, {}).setdefault(t.scad.stem, []).append(t)

    release_base = f"https://github.com/{repo}/releases/latest/download"
    src_base = f"https://github.com/{repo}/blob/main"
    repo_name = repo.split("/")[-1]

    out: list[str] = []
    out.append("<!doctype html>")
    out.append('<html lang="en"><head><meta charset="utf-8">')
    out.append('<meta name="viewport" content="width=device-width, initial-scale=1">')
    out.append(f"<title>{html.escape(repo_name)} — models</title>")
    out.append(f"<style>{CSS}</style></head><body>")
    out.append(f"<h1>{html.escape(repo_name)}</h1>")
    out.append(
        f'<p class="lede">3D-printable models, generated from '
        f'<a href="https://github.com/{html.escape(repo)}">{html.escape(repo)}</a>. '
        f"Downloads link to the latest tagged release.</p>"
    )

    for category in sorted(by_category):
        label = category.replace("_", " ").title()
        out.append(f"<h2>{html.escape(label)}</h2>")
        out.append('<div class="grid">')
        for stem in sorted(by_category[category]):
            ts = by_category[category][stem]
            pngs = {t.preset: t for t in ts if t.ext == "png"}
            presets = sorted({t.preset for t in ts if t.preset is not None})

            src_rel = ts[0].scad.relative_to(ROOT).as_posix()
            src_url = f"{src_base}/{src_rel}"

            # One card per variant so every preset shows its own preview.
            for preset in (presets or [None]):
                preview = pngs.get(preset)
                base = f"{stem}.{preset}" if preset else stem
                alt = f"{stem} {preset}" if preset else stem

                out.append('<div class="card">')
                if preview:
                    preview_rel = preview.out.relative_to(ROOT).as_posix()
                    out.append(
                        f'<img src="{html.escape(preview_rel)}" alt="{html.escape(alt)} preview" loading="lazy">'
                    )
                out.append('<div class="body">')
                name_html = html.escape(stem)
                if preset:
                    name_html += f' <span class="variant">{html.escape(preset)}</span>'
                out.append(f'<h3 class="name">{name_html}</h3>')
                out.append(f'<div class="meta"><a href="{html.escape(src_url)}">view source</a></div>')
                out.append('<div class="dl">')
                out.append('<span class="label">download</span>')
                out.append(f'<a href="{release_base}/{base}.stl" download>stl</a>')
                out.append(f'<a href="{release_base}/{base}.3mf" download>3mf</a>')
                out.append("</div>")
                out.append("</div></div>")
        out.append("</div>")

    out.append(
        f'<p class="footer">Generated from <code>src/</code>. '
        f'Releases: <a href="https://github.com/{html.escape(repo)}/releases">all releases</a> · '
        f'<a href="https://github.com/{html.escape(repo)}/releases/latest">latest</a>.</p>'
    )
    out.append("</body></html>")
    return "\n".join(out)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--repo", default=None,
                    help="owner/repo for release links (default: auto-detect)")
    ap.add_argument("--out", default=str(SITE), help="output directory")
    args = ap.parse_args()

    repo = args.repo or detect_repo()
    out_dir = Path(args.out)
    out_dir.mkdir(parents=True, exist_ok=True)

    (out_dir / "index.html").write_text(render(repo))

    site_previews = out_dir / "previews"
    if site_previews.exists():
        shutil.rmtree(site_previews)
    site_previews.mkdir()
    for png in sorted(PREVIEW.glob("*.png")):
        shutil.copy2(png, site_previews / png.name)

    print(f"site: wrote {out_dir/'index.html'} "
          f"({len(list(site_previews.glob('*.png')))} previews, repo={repo})")
    return 0


if __name__ == "__main__":
    sys.exit(main())
