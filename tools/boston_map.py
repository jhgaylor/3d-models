#!/usr/bin/env python3
"""Generate the Boston relief map data for src/boston/boston_lid.scad.

Pulls buildings, water, coastline and parks from OpenStreetMap (Overpass),
projects them to millimetres at SCALE, and writes polygon data that the lid
includes:

    map_cols   [[top_z, polys], ...]  buildings as disjoint columns, each
                                      rising from the plate top to top_z
    map_water  polys                  water (cut as a slotted grille)
    map_parks  polys                  parks (cut as a hole pattern)

A poly is a list of rings, outer first, then holes. Map frame: x east,
y north, mm, centred on (LAT0, LON0).

Neighbouring columns are kept COL_GAP apart (see columns()). Columns that
share a wall make a mesh that touches itself: OpenSCAD's union keeps the
two coincident walls as distinct vertices at the same place, and the STL
export (positions only) welds them into non-manifold edges. A gap this
small prints as nothing, but it keeps every column a separate, clean prism.

Raw Overpass responses are cached in .cache/osm/. Pass --refresh to
re-download. Needs shapely (pip install shapely).

Map data © OpenStreetMap contributors, ODbL.
"""

from __future__ import annotations

import argparse
import json
import math
import re
import time
import urllib.parse
import urllib.request
from pathlib import Path

from shapely import STRtree, set_precision
from shapely.geometry import LineString, Polygon, box
from shapely.ops import linemerge, polygonize, unary_union

ROOT = Path(__file__).resolve().parent.parent
CACHE = ROOT / ".cache" / "osm"
OUT = ROOT / "src" / "boston" / "vendor" / "boston_map.inc"

# ── Map frame ───────────────────────────────────────────
LAT0, LON0 = 42.3570, -71.0640   # centre: between the Common and downtown
SCALE = 7000                     # 1 mm on the lid = 7 m
V_EXAG = 1.5                     # vertical exaggeration
MAP_W, MAP_D = 499.2, 459.7      # lid footprint, mm (x east, y north)

# ── Heights ─────────────────────────────────────────────
DEFAULT_H = 10.0                 # m, when OSM has no height or levels
SMALL_H = 4.0                    # m, sheds/garages/etc. with no height
MAX_H = 260.0                    # m, clamp bad tags
MIN_Z = 0.8                      # mm, lowest building above the plate
Z_STEP = 0.2                     # mm, height quantum (a layer)

# ── Cleanup (mm) ────────────────────────────────────────
OPEN_R = 0.3                     # drop building slivers thinner than 2×
SIMPLIFY = 0.05
COL_GAP = 0.015                  # between neighbouring columns (see columns())
THIN_R = 0.002                   # drop bits of a column thinner than 2× after the inset
PREC = 0.001                     # output grid
SHORE = 1.0                      # solid rim inside water/park edges
SOLID_UNDER = 0.8                # solid plate this far around buildings
MIN_PARK = 100.0                 # mm², smaller parks stay solid

BBOX = "42.335,-71.095,42.379,-71.033"   # S,W,N,E — a bit beyond the frame
QUERIES = {
    "buildings": f'(way["building"]({BBOX});relation["building"]({BBOX});'
                 f'way["building:part"]({BBOX});relation["building:part"]({BBOX}););',
    "water": f"(way[natural=water]({BBOX});relation[natural=water]({BBOX}););",
    "coast": f"way[natural=coastline]({BBOX});",
    "parks": f"(way[leisure=park]({BBOX});relation[leisure=park]({BBOX}););",
}
# Park relations that aren't really parkland at this scale.
PARK_SKIP = {"Charles River Reservation", "Boston National Historical Park",
             "Charlestown Navy Yard"}
SMALL_KINDS = {"shed", "garage", "garages", "carport", "roof", "hut", "kiosk"}
ENDPOINTS = ["https://overpass-api.de/api/interpreter",
             "https://overpass.private.coffee/api/interpreter",
             "https://overpass.kumi.systems/api/interpreter"]

KX = 111320.0 * math.cos(math.radians(LAT0)) * 1000 / SCALE   # mm per degree
KY = 110950.0 * 1000 / SCALE


# ── Fetch ───────────────────────────────────────────────

def fetch(name: str, refresh: bool) -> list[dict]:
    path = CACHE / f"{name}.json"
    if path.exists() and not refresh:
        return json.loads(path.read_text())["elements"]
    q = f"[out:json][timeout:180];{QUERIES[name]}out geom;"
    data = urllib.parse.urlencode({"data": q}).encode()
    for attempt in range(6):
        url = ENDPOINTS[attempt % len(ENDPOINTS)]
        req = urllib.request.Request(url, data=data, headers={
            "User-Agent": "jhgaylor-3d-models/boston_map (relief lid)",
            "Accept": "application/json"})
        try:
            body = urllib.request.urlopen(req, timeout=300).read()
            els = json.loads(body)["elements"]
        except Exception as e:  # 429/504 are common: back off and rotate
            print(f"  {name}: {url} failed ({e}), retrying")
            time.sleep(10 * (attempt + 1))
            continue
        CACHE.mkdir(parents=True, exist_ok=True)
        path.write_bytes(body)
        return els
    raise SystemExit(f"could not fetch {name}")


# ── Geometry ────────────────────────────────────────────

def proj(p: dict) -> tuple[float, float]:
    return ((p["lon"] - LON0) * KX, (p["lat"] - LAT0) * KY)


def rings_to_polys(lines: list[list]) -> list[Polygon]:
    merged = linemerge([LineString(l) for l in lines if len(l) >= 2])
    return list(polygonize(merged))


def element_polys(e: dict) -> list[Polygon]:
    if e["type"] == "way":
        g = e.get("geometry") or []
        if len(g) < 4 or g[0] != g[-1]:
            return []
        p = Polygon([proj(q) for q in g]).buffer(0)
        return [p] if not p.is_empty else []
    outers, inners = [], []
    for m in e.get("members", []):
        if m["type"] == "way" and m.get("geometry"):
            pts = [proj(q) for q in m["geometry"] if q]
            (inners if m.get("role") == "inner" else outers).append(pts)
    if not outers:
        return []
    g = unary_union(rings_to_polys(outers))
    if inners:
        g = g.difference(unary_union(rings_to_polys(inners)))
    g = g.buffer(0)
    return [p for p in getattr(g, "geoms", [g]) if p.geom_type == "Polygon" and not p.is_empty]


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
    if h is None:
        kind = tags.get("building") or tags.get("building:part") or ""
        h = SMALL_H if kind in SMALL_KINDS else DEFAULT_H
    return min(h, MAX_H)


def polys_of(g) -> list[Polygon]:
    if g.is_empty:
        return []
    if g.geom_type == "Polygon":
        return [g]
    return [p for p in getattr(g, "geoms", []) for p in polys_of(p)]


def opening(g, r: float):
    return g.buffer(-r, join_style="mitre").buffer(r, join_style="mitre")


# ── Layers ──────────────────────────────────────────────

def buildings(els: list[dict], clip) -> list[tuple[float, Polygon]]:
    """(top_z mm, footprint) per building, outlines replaced by their parts."""
    outlines, parts = [], []
    for e in els:
        tags = e.get("tags", {})
        is_part = "building:part" in tags and "building" not in tags
        for p in element_polys(e):
            if p.intersects(clip):
                (parts if is_part else outlines).append((p, tags))
    # Simple 3D Buildings: an outline that has parts is drawn by its parts.
    part_pts = unary_union([p.representative_point() for p, _ in parts])
    keep = [(p, t) for p, t in outlines if not p.intersects(part_pts)]
    out = []
    for p, tags in keep + parts:
        z = max(MIN_Z, height_m(tags) * 1000 / SCALE * V_EXAG)
        out.append((round(z / Z_STEP) * Z_STEP, p.intersection(clip)))
    return out


def separate(g) -> list[Polygon]:
    """Pull a column in by half of COL_GAP so it never touches a neighbour.

    The lid extrudes each column and unions them. Where two columns of
    different heights share a wall, or a taller column sits in a notch of
    a lower one and touches its outline at a corner, the union leaves
    separate vertices at the same place (the solid touches itself there),
    and slicers read the STL as non-manifold. Insetting every column by
    COL_GAP / 2 makes them disjoint prisms, so the union is trivially
    clean. The gap is far below anything a printer resolves.

    The inset can leave hair-thin cusps where a hole nearly met the shell;
    an opening at THIN_R removes those, and snapping to PREC (the output
    grid) means the written coordinates are exactly what was checked."""
    g = g.buffer(-COL_GAP / 2, join_style="mitre")
    g = set_precision(opening(g, THIN_R), PREC)
    return [p for p in polys_of(g) if p.area > 0.05]


def columns(blds: list[tuple[float, Polygon]]) -> list[tuple[float, list[Polygon]]]:
    """Terrace the buildings into nested levels R_z (everything at least z
    tall), clean each level, then split into disjoint columns R_z minus the
    next level up, each pulled in by COL_GAP / 2 (see separate())."""
    by_z: dict[float, list[Polygon]] = {}
    for z, p in blds:
        by_z.setdefault(z, []).append(p)
    zs = sorted(by_z, reverse=True)
    levels, acc = [], None
    for z in zs:
        g = unary_union(by_z[z])
        acc = g if acc is None else acc.union(g)
        levels.append((z, acc))
    levels.reverse()                       # lowest first
    cleaned, below = [], None
    for z, g in levels:
        g = opening(g, OPEN_R).simplify(SIMPLIFY)
        if below is not None:
            g = g.intersection(below)      # keep the terraces nested
        cleaned.append((z, g))
        below = g
    cols = []
    for i, (z, g) in enumerate(cleaned):
        above = cleaned[i + 1][1] if i + 1 < len(cleaned) else None
        d = g.difference(above) if above is not None else g
        ps = separate(d.buffer(0))
        if ps:
            cols.append((round(z, 2), ps))
    return cols


def coast_sea(els: list[dict], frame) -> list[Polygon]:
    """Sea faces inside the frame. OSM coastline has land on its left."""
    lines = linemerge([LineString([proj(q) for q in e["geometry"]]) for e in els])
    clines = list(getattr(lines, "geoms", [lines]))
    noded = unary_union([c.intersection(frame.buffer(1)) for c in clines] + [frame.exterior])
    sea = []
    for face in polygonize(noded):
        rp = face.representative_point()
        c = min(clines, key=lambda c: c.distance(rp))
        s = c.project(rp)
        a, b = c.interpolate(max(s - 0.1, 0)), c.interpolate(min(s + 0.1, c.length))
        if (b.x - a.x) * (rp.y - a.y) - (b.y - a.y) * (rp.x - a.x) < 0:
            sea.append(face)
    return sea


# ── Output ──────────────────────────────────────────────

def fmt_ring(coords) -> str:
    pts = list(coords)[:-1]
    return "[" + ",".join(f"[{x:.3f},{y:.3f}]" for x, y in pts) + "]"


def fmt_polys(ps: list[Polygon]) -> str:
    out = []
    for p in ps:
        p = Polygon(p.exterior.coords, [i.coords for i in p.interiors])
        p = p if p.exterior.is_ccw else Polygon(p.exterior.coords[::-1], [i.coords for i in p.interiors])
        rings = [fmt_ring(p.exterior.coords)] + [fmt_ring(i.coords) for i in p.interiors]
        out.append("[" + ",".join(rings) + "]")
    return "[\n" + ",\n".join(out) + "\n]"


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--refresh", action="store_true", help="re-download from Overpass")
    args = ap.parse_args()

    frame = box(-MAP_W / 2, -MAP_D / 2, MAP_W / 2, MAP_D / 2)
    raw = {k: fetch(k, args.refresh) for k in QUERIES}

    blds = buildings(raw["buildings"], frame)
    cols = columns(blds)
    footprint = unary_union([p for _, ps in cols for p in ps])
    solid = footprint.buffer(SOLID_UNDER)

    water = unary_union([p for e in raw["water"] for p in element_polys(e)]
                        + coast_sea(raw["coast"], frame)).intersection(frame)
    water = opening(water, SHORE).buffer(-SHORE).difference(solid)

    parks = [p for e in raw["parks"]
             if e.get("tags", {}).get("name") not in PARK_SKIP
             for p in element_polys(e)]
    parks = unary_union(parks).intersection(frame).difference(water.buffer(SHORE))
    parks = parks.buffer(-SHORE).difference(solid)

    water_ps = [p.simplify(SIMPLIFY) for p in polys_of(water) if p.area > 4]
    park_ps = [p.simplify(SIMPLIFY) for p in polys_of(parks) if p.area > MIN_PARK]

    OUT.parent.mkdir(parents=True, exist_ok=True)
    with OUT.open("w") as f:
        f.write("// Generated by tools/boston_map.py. Do not edit.\n")
        f.write("// Map data © OpenStreetMap contributors, ODbL 1.0.\n")
        f.write(f"// Centre {LAT0}, {LON0}; 1:{SCALE}; vertical ×{V_EXAG}.\n\n")
        f.write(f"map_scale = {SCALE};\nmap_v_exag = {V_EXAG};\n")
        f.write(f"map_size = [{MAP_W}, {MAP_D}];\n\n")
        f.write(f"map_water = {fmt_polys(water_ps)};\n\n")
        f.write(f"map_parks = {fmt_polys(park_ps)};\n\n")
        f.write("map_cols = [\n")
        f.write(",\n".join(f"[{z}, {fmt_polys(ps)}]" for z, ps in cols))
        f.write("\n];\n")

    npts = sum(len(p.exterior.coords) + sum(len(i.coords) for i in p.interiors)
               for _, ps in cols for p in ps)
    print(f"{len(blds)} buildings → {len(cols)} columns, {npts} points; "
          f"{len(water_ps)} water, {len(park_ps)} park polys; "
          f"tallest {max(z for z, _ in cols):.1f} mm; "
          f"{OUT.relative_to(ROOT)} {OUT.stat().st_size / 1e6:.1f} MB")

    # The lid relies on the columns never touching (see separate()). Check
    # the written data: no two columns closer than half the gap, and no
    # level whose outline touches itself (a coordinate used twice).
    allp = [p for _, ps in cols for p in ps]
    a, b = STRtree(allp).query(allp, predicate="dwithin", distance=COL_GAP / 2)
    close = int((a < b).sum())
    pinched = 0
    for _, ps in cols:
        seen: set = set()
        for p in ps:
            for ring in [p.exterior, *p.interiors]:
                for c in list(ring.coords)[:-1]:
                    pinched += c in seen
                    seen.add(c)
    if close or pinched:
        raise SystemExit(f"columns touch: {close} pairs within {COL_GAP / 2} mm, "
                         f"{pinched} self-touching vertices")


if __name__ == "__main__":
    main()
