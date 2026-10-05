/* =====================================================
   Square Plate — split for gluing — assembly scene
   =====================================================
   Visual-only hero: the four tiles slightly exploded so
   the half-lap steps read. PNG only — see build.py
   is_scene().
   ===================================================== */

use <square_plate_puzzle.scad>

// Constants mirrored from the model (kept in sync by hand).
S    = 14.5 * 25.4;
cols = 2;
rows = 2;
gap  = 30;   // explode distance between tiles (> lap width)

colors = ["#9aa0a6", "#7e57c2", "#c4c8cc", "#b0b6bb"];

for (i = [0 : cols - 1], j = [0 : rows - 1])
    color(colors[(j * cols + i) % len(colors)])
        translate([i * gap, j * gap, 0])
            tile(i, j);

// Camera — three-quarter view from front-above
$vpt = [S/2 + gap/2, S/2 + gap/2, 0];
$vpr = [58, 0, 25];
$vpd = 1100;
