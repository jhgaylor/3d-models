#!/usr/bin/env python3
"""Generate the halftone pictures for src/unifi/rack_fan_lid.scad.

Each picture is a darkness value on the lid's hole lattice:

    ht_pitch     lattice pitch, mm
    ht_<name>    [[x, y, v], ...]   v in 0..1: 0 = lightest (no hole, or the
                                    smallest), 1 = darkest (biggest hole)

for name in wood, waves, ripples and skyline. The lid turns v into a hole
diameter and decides which lattice points may hold a hole at all (fans,
clips, seams, keys and the controller stay solid), so this script knows
nothing about the lid beyond its footprint and the fan centres.

The pictures (each feature is at least 4-6 holes across, or it won't
read at this resolution):

  wood     grain lines that bunch and curve round the four fans like
           grain round knots: the streamlines of flow past four
           cylinders, with a little irregularity
  waves    Bridget Riley-style stripes that ripple harder toward the
           middle
  ripples  rings spreading from each fan, interfering where they meet
  skyline  Boston seen from the Riverway, from OpenStreetMap building
           heights (needs .cache/osm/buildings.json from
           tools/boston_map.py; skipped without it)

    python3 tools/lid_halftone.py            # writes src/unifi/vendor/lid_halftone.inc
    python3 tools/lid_halftone.py --preview  # also build/lid_halftone_<name>.png

Standard library only (the preview needs Pillow).

Map data (skyline) © OpenStreetMap contributors, ODbL.
"""

from __future__ import annotations

import argparse
import json
import math
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CACHE = ROOT / ".cache" / "osm" / "buildings.json"
OUT = ROOT / "src" / "unifi" / "vendor" / "lid_halftone.inc"

# ── Lid ─────────────────────────────────────────────────
LID_W, LID_D = 499.2, 459.7       # mm, x across, y front→back
PITCH = 5.2                       # hole lattice pitch, mm (hex lattice)
HORIZON_Y = 22.0                  # mm; the y-seam keys sit in the river just below it

# ── Camera ──────────────────────────────────────────────
# Standing west of Back Bay (by the Riverway), looking east-north-east.
# From here the Pru, the Hancock and the Financial District stack up
# into one dense cluster, which is what fits between the fans.
EYE = (42.3395, -71.1100)         # lat, lon
LOOK = (42.3530, -71.0600)        # point at the centre of the picture
NEAR = 300.0                      # m, ignore anything closer
X_SCALE = 0.62                    # mm per (m / km of distance): width
Y_SCALE = 1.48                    # mm per (m / km of distance): height
X_SHIFT = 0.0                     # mm, slide the picture sideways
MIN_H = 8.0                       # m, ignore sheds and kiosks

# ── Tone ────────────────────────────────────────────────
SKY_TOP, SKY_HORIZON = 0.02, 0.22     # sky darkness, high up and at the horizon
NEAR_V, FAR_V = 1.0, 0.42              # building darkness, nearest and farthest
NEAR_D, FAR_D = 1500.0, 5000.0         # m, where that fade starts and ends
WATER_V, REFLECT_V = 0.14, 0.92        # river, and the skyline reflected in it

KX = 111320.0 * math.cos(math.radians(EYE[0]))
KY = 110540.0


def parse_len(s: str | None) -> float | None:
    if not s:
        return None
    m = re.match(r"^\s*([0-9]+(?:[.,][0-9]+)?)\s*(m|ft|')?", s.lower())
    if not m:
        return None
    v = float(m.group(1).replace(",", "."))
    return v * 0.3048 if m.group(2) in ("ft", "'") else v


def height_m(tags: dict) -> float:
    h = parse_len(tags.get("height"))
    if h is None:
        lv = parse_len(tags.get("building:levels"))
        if lv is not None:
            h = (lv + (parse_len(tags.get("roof:levels")) or 0)) * 3.3 + 1.0
    return min(h if h is not None else 10.0, 260.0)


def points(e: dict) -> list[tuple[float, float]]:
    if e["type"] == "way":
        g = e.get("geometry") or []
    else:
        g = [q for m in e.get("members", []) if m.get("role") != "inner"
             for q in (m.get("geometry") or []) if q]
    return [((q["lon"] - EYE[1]) * KX, (q["lat"] - EYE[0]) * KY) for q in g]


def camera():
    fx, fy = (LOOK[1] - EYE[1]) * KX, (LOOK[0] - EYE[0]) * KY
    n = math.hypot(fx, fy)
    return fx / n, fy / n


def project(els: list[dict]):
    """Each building as (depth m, x0 mm, x1 mm, top mm above the horizon)."""
    fx, fy = camera()
    rx, ry = fy, -fx                       # right-hand vector
    out = []
    for e in els:
        tags = e.get("tags") or {}
        h = height_m(tags)
        if h < MIN_H:
            continue
        pts = points(e)
        if len(pts) < 3:
            continue
        depth = [px * fx + py * fy for px, py in pts]
        dmin = min(depth)
        if dmin < NEAR:
            continue
        xs = [(px * rx + py * ry) / d * 1000 * X_SCALE + X_SHIFT
              for (px, py), d in zip(pts, depth)]
        top = h / dmin * 1000 * Y_SCALE
        out.append((dmin, min(xs), max(xs), top, tags.get("name")))
    return out


def render(blds):
    """Darkness at any point of the lid, as a function."""
    blds = sorted(blds, key=lambda b: -b[0])       # far first
    # 0.5 mm columns: for each, a list of (top, value) bands, painted far→near
    res = 0.5
    ncol = int(LID_W / res) + 1
    cols: list[list[tuple[float, float]]] = [[] for _ in range(ncol)]
    for d, x0, x1, top, _ in blds:
        t = min(1.0, max(0.0, (d - NEAR_D) / (FAR_D - NEAR_D)))
        v = NEAR_V + (FAR_V - NEAR_V) * t
        i0 = max(0, int((x0 + LID_W / 2) / res))
        i1 = min(ncol - 1, int((x1 + LID_W / 2) / res))
        for i in range(i0, i1 + 1):
            cols[i].append((top, v))

    def sky_or_city(x: float, h: float) -> float:
        i = int((x + LID_W / 2) / res)
        if 0 <= i < ncol:
            # the nearest building covering this height wins: bands are in
            # far→near order, so take the last one that reaches up to h
            for top, v in reversed(cols[i]):
                if h <= top:
                    return v
        return None

    def value(x: float, y: float) -> float:
        h = y - HORIZON_Y
        if h >= 0:
            c = sky_or_city(x, h)
            if c is not None:
                return c
            return SKY_HORIZON + (SKY_TOP - SKY_HORIZON) * min(1.0, h / 180) ** 0.6
        # river: the skyline reflected, squashed and broken into ripples
        dd = -h
        band = 0.5 + 0.5 * math.sin(dd * 1.25 + 0.6 * math.sin(x * 0.07))
        r = sky_or_city(x + 1.2 * math.sin(dd * 0.8), dd * 1.6)
        fade = max(0.0, 1 - dd / 230)
        if r is not None:
            return WATER_V + (REFLECT_V * r - WATER_V) * fade * (0.55 + 0.45 * band)
        return WATER_V + 0.08 * band * fade

    return value


def lattice():
    row = PITCH * math.sqrt(3) / 2
    ny = int(LID_D / 2 / row) + 1
    nx = int(LID_W / 2 / PITCH) + 1
    for j in range(-ny, ny + 1):
        off = PITCH / 2 if j % 2 else 0
        for i in range(-nx, nx + 1):
            yield i * PITCH + off, j * row


# ── Patterns ────────────────────────────────────────────
FAN_CX, FAN_CY = 419.4 / 4, 399.0 / 4
FANS = [(sx * FAN_CX, sy * FAN_CY) for sx in (-1, 1) for sy in (-1, 1)]


def clamp(v: float) -> float:
    return max(0.0, min(1.0, v))


def wood(x: float, y: float) -> float:
    # grain = streamlines of flow past four cylinders (the fans), warped
    a = 66.0
    psi = y
    for kx, ky in FANS:
        dx, dy = x - kx, y - ky
        psi -= a * a * dy / (dx * dx + dy * dy + 1e-6)
    psi += 7 * math.sin(x / 61 + 1.3) + 4 * math.sin(x / 23 + y / 90) + 2.5 * math.sin(x / 9.0 + 0.4)
    lam = 24.0 + 4 * math.sin(psi / 61)          # ring spacing wanders a little
    ph = (psi / lam) % 1.0
    v = math.exp(-((ph - 0.5) / 0.2) ** 2)       # dark latewood line, pale earlywood
    return clamp(0.92 * v + 0.04 * math.sin(x / 7) ** 2)


def waves(x: float, y: float) -> float:
    amp = 4 + 16 * math.exp(-(x / 170) ** 2)
    yy = y + amp * math.sin(2 * math.pi * x / 95 + y / 140)
    return clamp(0.5 + 0.5 * math.tanh(3 * math.sin(2 * math.pi * yy / 26.0)))


def ripples(x: float, y: float) -> float:
    s = 0.0
    for kx, ky in FANS:
        r = math.hypot(x - kx, y - ky)
        s += math.cos(2 * math.pi * (r - 60) / 34.0) / (1 + r / 160)
    return clamp(0.5 + 0.55 * math.tanh(1.6 * s))


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--preview", action="store_true")
    args = ap.parse_args()
    pts = [(x, y) for x, y in lattice() if abs(x) < LID_W / 2 and abs(y) < LID_D / 2]
    fields = {"wood": wood, "waves": waves, "ripples": ripples}
    if CACHE.exists():
        els = json.loads(CACHE.read_text())["elements"]
        fields["skyline"] = render(project(els))
    else:
        print(f"{CACHE} is missing: skipping the skyline (run tools/boston_map.py to download it)")
    OUT.parent.mkdir(parents=True, exist_ok=True)
    with OUT.open("w") as f:
        f.write("// Generated by tools/lid_halftone.py. Do not edit.\n")
        f.write("// Skyline map data (c) OpenStreetMap contributors, ODbL.\n")
        f.write(f"ht_pitch = {PITCH};\n")
        for name in ("wood", "waves", "ripples", "skyline"):
            fn = fields.get(name)
            rows = [] if fn is None else [f"[{x:.2f},{y:.2f},{fn(x, y):.3f}]" for x, y in pts]
            f.write(f"ht_{name} = [\n" + ",\n".join(rows) + "\n];\n")
    print(f"wrote {OUT.relative_to(ROOT)}: {len(pts)} lattice points x {len(fields)} pictures")
    if args.preview:
        from PIL import Image, ImageDraw
        s = 3
        for name, fn in fields.items():
            im = Image.new("L", (int(LID_W * s), int(LID_D * s)), 235)
            dr = ImageDraw.Draw(im)
            for x, y in pts:
                v = fn(x, y)
                if v < 0.15:
                    continue
                r = (2.0 + (4.3 - 2.0) * v) / 2 * s
                cx, cy = (x + LID_W / 2) * s, (LID_D / 2 - y) * s
                dr.ellipse([cx - r, cy - r, cx + r, cy + r], fill=30)
            for cx, cy in FANS:
                dr.ellipse([(cx - 58.5 + LID_W / 2) * s, (LID_D / 2 - cy - 58.5) * s,
                            (cx + 58.5 + LID_W / 2) * s, (LID_D / 2 - cy + 58.5) * s], fill=90)
            p = ROOT / "build" / f"lid_halftone_{name}.png"
            p.parent.mkdir(exist_ok=True)
            im.save(p)
            print(f"wrote {p.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
