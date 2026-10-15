#!/usr/bin/env python3
"""Check a 3MF from build/ for mesh problems slicers complain about.

    python3 tools/check_3mf.py build/boston_lid.tile-sw.3mf

Reports, per file:
  edges     how many edges are shared by 2 faces (good) vs anything else
            (open or non-manifold edges)
  touching  groups of distinct vertices at the same position. The 3MF
            can be manifold and still have these: places where the solid
            touches itself. STL stores only positions, so a slicer welds
            them and reports non-manifold edges.

Exit status is 1 if anything is wrong. Standard library only.
"""

import re
import sys
import zipfile
from collections import Counter


def check(path: str) -> bool:
    z = zipfile.ZipFile(path)
    model = next(n for n in z.namelist() if n.endswith(".model"))
    xml = z.read(model).decode()
    verts = re.findall(r'<vertex x="([^"]+)" y="([^"]+)" z="([^"]+)"', xml)
    tris = re.findall(r'<triangle v1="(\d+)" v2="(\d+)" v3="(\d+)"', xml)
    edges = Counter()
    for t in tris:
        a, b, c = map(int, t)
        for e in ((a, b), (b, c), (c, a)):
            edges[tuple(sorted(e))] += 1
    uses = Counter(edges.values())
    positions = Counter(verts)
    touching = sum(1 for n in positions.values() if n > 1)
    ok = set(uses) == {2} and touching == 0
    print(f"{path}: {len(verts)} verts, {len(tris)} tris, "
          f"edge uses {dict(sorted(uses.items()))}, touching {touching} "
          f"-> {'OK' if ok else 'PROBLEM'}")
    return ok


if __name__ == "__main__":
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    results = [check(p) for p in sys.argv[1:]]
    sys.exit(0 if all(results) else 1)
