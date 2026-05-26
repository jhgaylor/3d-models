#!/usr/bin/env python3
"""Generate a static GitHub Pages site.

Reads the same target plan as build.py so the site stays in lockstep with
src/. Writes:
  site/index.html        — hero banner + a grid of project cards (one per model)
  site/<stem>.html       — per-project detail page (variants + downloads)
  site/previews/*.png    — copied previews the pages load

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
from build import ROOT, PREVIEW, plan_targets, is_scene  # noqa: E402

SITE = ROOT / "site"

ICON_MAIL = (
    '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" '
    'stroke-width="2" stroke-linecap="round" stroke-linejoin="round">'
    '<rect x="2" y="4" width="20" height="16" rx="2"/><path d="m2 7 10 6 10-6"/></svg>'
)
ICON_GITHUB = (
    '<svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor">'
    '<path d="M12 .5C5.37.5 0 5.78 0 12.29c0 5.21 3.44 9.63 8.21 11.19.6.11.82-.25.82-.56 '
    '0-.28-.01-1.02-.02-2-3.34.71-4.04-1.58-4.04-1.58-.55-1.37-1.34-1.74-1.34-1.74-1.09-.73.08-.72.08-.72 '
    '1.2.08 1.84 1.21 1.84 1.21 1.07 1.8 2.81 1.28 3.5.98.11-.76.42-1.28.76-1.57-2.67-.3-5.47-1.31-5.47-5.83 '
    '0-1.29.47-2.34 1.24-3.17-.12-.3-.54-1.52.12-3.16 0 0 1.01-.32 3.3 1.21a11.6 11.6 0 0 1 3-.4c1.02 0 '
    '2.05.13 3 .4 2.29-1.53 3.3-1.21 3.3-1.21.66 1.64.24 2.86.12 3.16.77.83 1.24 1.88 1.24 3.17 0 4.53-2.81 '
    '5.53-5.49 5.82.43.37.81 1.1.81 2.22 0 1.6-.01 2.89-.01 3.28 0 .31.21.68.83.56C20.56 21.91 24 17.5 24 '
    '12.29 24 5.78 18.63.5 12 .5Z"/></svg>'
)

CSS = """\
:root { color-scheme: light dark; --max: 1100px; --gap: 24px;
        --accent: #2563eb; --accent-dark: #1e40af; }
* { box-sizing: border-box; }
body { font: 15px/1.5 ui-sans-serif, system-ui, -apple-system, sans-serif;
       max-width: var(--max); margin: 2rem auto; padding: 0 1rem; }
a { color: inherit; }
h1 { margin: 0 0 .25rem; }
h2 { margin: 2.5rem 0 1rem; font-size: 1.25rem; }
.back { display: inline-block; margin: 0 0 1.5rem; color: #666; font-size: 14px;
        text-decoration: none; }
.back:hover { color: inherit; }
.intro { background: linear-gradient(135deg, #eef2ff, #f9fafb);
         border: 1px solid #0001; border-radius: 16px; padding: 2.25rem 2rem;
         margin: 0 0 2.75rem; }
.eyebrow { color: var(--accent); font-weight: 600; font-size: 13px;
           letter-spacing: .05em; text-transform: uppercase; margin: 0 0 .5rem; }
.intro h1 { font-size: clamp(1.6rem, 4vw, 2.3rem); line-height: 1.1; margin: 0 0 .75rem;
            letter-spacing: -.01em; }
.bio { color: #444; margin: 0 0 1.4rem; max-width: 62ch; }
.cta { display: flex; flex-wrap: wrap; gap: 10px; }
.btn { display: inline-block; padding: 9px 17px; border-radius: 9px; font-size: 14px;
       font-weight: 500; text-decoration: none; border: 1px solid #0002; background: #fff; }
.btn:hover { border-color: #0004; }
.btn.primary { background: var(--accent); color: #fff; border-color: var(--accent); }
.btn.primary:hover { background: var(--accent-dark); }
.btn.icon { padding: 8px; line-height: 0; display: inline-flex; align-items: center; }
.btn svg { display: block; }
.hero { width: 100%; aspect-ratio: 4/3; object-fit: contain; background: #f5f5f5;
        border: 1px solid #0002; border-radius: 10px; margin: 0 0 .5rem; display: block; }
.credit { color: #888; font-size: 12px; margin: 0 0 2.5rem; }
.grid { display: grid; gap: var(--gap);
        grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); }
.card { border: 1px solid #0002; border-radius: 8px; overflow: hidden;
        display: flex; flex-direction: column; background: #fff; }
.card img { width: 100%; aspect-ratio: 4/3; object-fit: contain; background: #f5f5f5;
            display: block; }
a.card { text-decoration: none; transition: transform .08s ease, box-shadow .08s ease; }
a.card:hover { transform: translateY(-2px); box-shadow: 0 6px 20px #0002; }
.body { padding: 14px; display: flex; flex-direction: column; gap: 8px; flex: 1; }
.name { margin: 0; font: 600 15px/1.2 ui-monospace, monospace; word-break: break-all; }
.variant { font: 500 11px/1 ui-monospace, monospace; color: #fff; background: #4a7a5a;
           padding: 2px 7px; border-radius: 4px; white-space: nowrap; }
.meta { color: #666; font-size: 13px; }
.tag { font-size: 12px; color: #777; }
.dl { display: flex; flex-wrap: wrap; gap: 6px; align-items: center; }
.dl .label { font-size: 12px; color: #666; min-width: 70px; }
.dl a { font-size: 12px; padding: 3px 9px; border-radius: 4px; background: #eee;
        text-decoration: none; }
.dl a:hover { background: #ddd; }
.footer { margin: 3rem 0 1rem; color: #666; font-size: 13px; }
.footer code { background: #0001; padding: 1px 5px; border-radius: 3px; }
@media (prefers-color-scheme: dark) {
  body { background: #111; color: #eee; }
  .intro { background: linear-gradient(135deg, #16213e, #14161c); border-color: #fff2; }
  .bio { color: #bbb; }
  .btn { background: #1a1a1a; border-color: #fff2; }
  .btn.primary { background: var(--accent); border-color: var(--accent); color: #fff; }
  .card { background: #1a1a1a; border-color: #fff2; }
  .card img { background: #222; }
  .meta, .footer, .tag { color: #aaa; }
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


def collect_projects(targets: list, scenes: list) -> list[dict]:
    """One project per source .scad (scenes excluded), with its variants.

    A scene render in the same category becomes that project's hero image
    (card thumbnail + detail-page banner) instead of a variant preview.
    """
    scene_by_cat: dict[str, object] = {}
    for s in scenes:
        rel = s.scad.relative_to(ROOT / "src")
        cat = rel.parts[0] if len(rel.parts) > 1 else "other"
        scene_by_cat.setdefault(cat, s)

    grouped: dict[tuple, list] = {}
    for t in targets:
        if is_scene(t.scad):
            continue
        rel = t.scad.relative_to(ROOT / "src")
        category = rel.parts[0] if len(rel.parts) > 1 else "other"
        grouped.setdefault((category, t.scad.stem, t.scad), []).append(t)

    projects: list[dict] = []
    for (category, stem, scad), ts in grouped.items():
        pngs = {t.preset: t for t in ts if t.ext == "png"}
        presets = sorted(p for p in pngs if p is not None)
        variants = ([(p, pngs[p]) for p in presets]
                    if presets else [(None, pngs.get(None))])
        scene = scene_by_cat.get(category)
        projects.append({
            "stem": stem,
            "category": category,
            "src_rel": scad.relative_to(ROOT).as_posix(),
            "variants": variants,
            "scene": scene,
            "thumb": scene or variants[0][1],
            "page": f"{stem}.html",
        })
    return sorted(projects, key=lambda p: (p["category"], p["stem"]))


def page(title: str, body: list[str]) -> str:
    out = [
        "<!doctype html>",
        '<html lang="en"><head><meta charset="utf-8">',
        '<meta name="viewport" content="width=device-width, initial-scale=1">',
        f"<title>{html.escape(title)}</title>",
        f"<style>{CSS}</style></head><body>",
    ]
    out += body
    out.append("</body></html>")
    return "\n".join(out)


def footer(repo: str) -> str:
    return (
        f'<p class="footer">Generated from <code>src/</code>. '
        f'Releases: <a href="https://github.com/{html.escape(repo)}/releases">all releases</a> · '
        f'<a href="https://github.com/{html.escape(repo)}/releases/latest">latest</a>.<br>'
        f'Mac mini model by '
        f'<a href="https://www.printables.com/model/1057608-mac-mini-m4">Satyr</a> '
        f'(<a href="https://creativecommons.org/licenses/by/4.0/">CC BY 4.0</a>).</p>'
    )


def hero_intro(repo: str) -> str:
    # Personal hero, styled after jakegaylor.com (blue-600 accent, builder voice).
    return (
        '<div class="intro">'
        '<p class="eyebrow">Jake Gaylor</p>'
        '<h1>I build things — software, teams, and the occasional 3D print.</h1>'
        '<p class="bio">Technical cofounder and platform engineer with 15+ years '
        'shipping products and scaling engineering orgs. This is my workshop for '
        'parametric 3D-printable models: every part is generated from OpenSCAD '
        'source, auto-built in CI, and released as STL&nbsp;+&nbsp;3MF. '
        'Browse a project, grab the files, remix away.</p>'
        '<div class="cta">'
        '<a class="btn primary" href="https://jakegaylor.com">Learn more about me</a>'
        '<a class="btn" href="https://jakegaylor.com/resume/">Resume</a>'
        '<a class="btn" href="sms:+17204533994">Text me</a>'
        '<a class="btn icon" href="mailto:jhgaylor@gmail.com" title="Email me" aria-label="Email me">'
        f'{ICON_MAIL}</a>'
        f'<a class="btn icon" href="https://github.com/{html.escape(repo)}" title="GitHub" aria-label="GitHub">'
        f'{ICON_GITHUB}</a>'
        '</div></div>'
    )


def render_index(repo: str, projects: list[dict]) -> str:
    repo_name = repo.split("/")[-1]
    body: list[str] = []
    body.append(hero_intro(repo))

    by_category: dict[str, list[dict]] = {}
    for p in projects:
        by_category.setdefault(p["category"], []).append(p)

    for category in sorted(by_category):
        label = category.replace("_", " ").title()
        body.append(f"<h2>{html.escape(label)}</h2>")
        body.append('<div class="grid">')
        for p in by_category[category]:
            thumb = p["thumb"]
            n = len(p["variants"])
            tag = f"{n} parts" if n > 1 and p["variants"][0][0] else "single part"
            body.append(f'<a class="card" href="{html.escape(p["page"])}">')
            if thumb:
                thumb_rel = thumb.out.relative_to(ROOT).as_posix()
                body.append(
                    f'<img src="{html.escape(thumb_rel)}" '
                    f'alt="{html.escape(p["stem"])}" loading="lazy">'
                )
            body.append('<div class="body">')
            body.append(f'<h3 class="name">{html.escape(p["stem"])}</h3>')
            body.append(f'<div class="tag">{html.escape(tag)}</div>')
            body.append("</div></a>")
        body.append("</div>")

    body.append(footer(repo))
    return page("Jake Gaylor · 3D-printable models", body)


def render_detail(repo: str, project: dict) -> str:
    repo_name = repo.split("/")[-1]
    release_base = f"https://github.com/{repo}/releases/latest/download"
    src_url = f"https://github.com/{repo}/blob/main/{project['src_rel']}"
    stem = project["stem"]

    body: list[str] = []
    body.append('<a class="back" href="index.html">&larr; all projects</a>')
    body.append(f"<h1>{html.escape(stem)}</h1>")
    body.append(
        f'<p class="meta">{html.escape(project["category"].replace("_", " "))} · '
        f'<a href="{html.escape(src_url)}">view source</a></p>'
    )

    scene = project.get("scene")
    if scene:
        scene_rel = scene.out.relative_to(ROOT).as_posix()
        body.append(
            f'<img class="hero" src="{html.escape(scene_rel)}" '
            f'alt="{html.escape(stem)} assembled" loading="lazy">'
        )

    body.append('<div class="grid">')
    for preset, preview in project["variants"]:
        base = f"{stem}.{preset}" if preset else stem
        alt = f"{stem} {preset}" if preset else stem
        body.append('<div class="card">')
        if preview:
            preview_rel = preview.out.relative_to(ROOT).as_posix()
            body.append(
                f'<img src="{html.escape(preview_rel)}" '
                f'alt="{html.escape(alt)} preview" loading="lazy">'
            )
        body.append('<div class="body">')
        if preset:
            body.append(f'<h3 class="name"><span class="variant">{html.escape(preset)}</span></h3>')
        body.append('<div class="dl">')
        body.append('<span class="label">download</span>')
        body.append(f'<a href="{release_base}/{base}.stl" download>stl</a>')
        body.append(f'<a href="{release_base}/{base}.3mf" download>3mf</a>')
        body.append("</div>")
        body.append("</div></div>")
    body.append("</div>")

    body.append(footer(repo))
    return page(f"{stem} — {repo_name}", body)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--repo", default=None,
                    help="owner/repo for release links (default: auto-detect)")
    ap.add_argument("--out", default=str(SITE), help="output directory")
    args = ap.parse_args()

    repo = args.repo or detect_repo()
    out_dir = Path(args.out)
    out_dir.mkdir(parents=True, exist_ok=True)

    targets = plan_targets()
    scenes = sorted(
        (t for t in targets if t.ext == "png" and is_scene(t.scad)),
        key=lambda t: t.out.name,
    )
    projects = collect_projects(targets, scenes)

    (out_dir / "index.html").write_text(render_index(repo, projects))
    for p in projects:
        (out_dir / p["page"]).write_text(render_detail(repo, p))

    site_previews = out_dir / "previews"
    if site_previews.exists():
        shutil.rmtree(site_previews)
    site_previews.mkdir()
    for png in sorted(PREVIEW.glob("*.png")):
        shutil.copy2(png, site_previews / png.name)

    print(f"site: wrote index + {len(projects)} project pages "
          f"({len(list(site_previews.glob('*.png')))} previews, repo={repo})")
    return 0


if __name__ == "__main__":
    sys.exit(main())
