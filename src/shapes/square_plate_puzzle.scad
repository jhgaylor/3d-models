/* =====================================================
   Square Plate — puzzle-split (solid)
   =====================================================
   A 14.5" square plate too big for the bed, split into a
   grid of tiles joined by jigsaw knobs. Print each tile,
   press the knobs together, and glue (CA or plastic
   cement on the seams).

   Overall side : 14.5 in  (368.3 mm)
   Thickness    : 1/8 in   (  3.175 mm)
   Grid         : 2 × 2 → tiles are 7.25 in (184.15 mm)
                  square, ~197 mm max with knobs.

   Each tile is a preset in square_plate_puzzle.json
   (tile_col / tile_row). Knobs always point +X / +Y, so
   the front-left tile is all knobs and the back-right
   tile is all sockets.

   Prints flat on the bed, no supports.
   ===================================================== */

$fa = 2;
$fs = 0.5;

in = 25.4;   // mm per inch

/* ── Tile selection (set by presets) ─────────────────── */
tile_col = 0;   // 0 = left (-X)
tile_row = 0;   // 0 = front (-Y)

/* ── Dimensions (inches) ─────────────────────────────── */
side_in      = 14.5;     // assembled square edge length
thickness_in = 1/8;      // plate thickness

/* ── Grid ────────────────────────────────────────────── */
cols = 2;
rows = 2;

/* ── Jigsaw knob (mm) ────────────────────────────────── */
knob_d       = 16;       // head diameter
knob_reach   = 14;       // how far the head sticks past the seam
neck_w       = 9;        // neck width (narrower than head = lock)
knobs_per_edge = 2;      // knobs along each tile edge
clearance    = 0.15;     // per-side gap between knob and socket

/* ── Derived (mm) ────────────────────────────────────── */
S  = side_in      * in;
Z  = thickness_in * in;
TW = S / cols;
TH = S / rows;

// Knob positions along an edge, as fractions of the tile edge.
function knob_fracs() = [for (k = [0 : knobs_per_edge - 1]) (k + 0.5) / knobs_per_edge];

// One knob on the seam at the origin, pointing +X.
module knob_2d() {
    head_c = knob_reach - knob_d / 2;
    translate([head_c, 0]) circle(d = knob_d);
    // Neck starts slightly behind the seam so it fuses with the tile.
    translate([-1, -neck_w / 2]) square([head_c + 1, neck_w]);
}

// Knobs owned by tile (i, j): on its +X edge and +Y edge.
module owned_knobs(i, j) {
    if (i < cols - 1)
        for (f = knob_fracs())
            translate([(i + 1) * TW, (j + f) * TH]) knob_2d();
    if (j < rows - 1)
        for (f = knob_fracs())
            translate([(i + f) * TW, (j + 1) * TH]) rotate(90) knob_2d();
}

// Tile (i, j) outline in assembled (global) coordinates,
// square spanning [0, S] × [0, S].
module tile_2d(i, j) {
    intersection() {
        square([S, S]);
        difference() {
            union() {
                translate([i * TW, j * TH]) square([TW, TH]);
                owned_knobs(i, j);
            }
            // Sockets for the neighbours' knobs, opened up by clearance.
            offset(delta = clearance) {
                if (i > 0) owned_knobs(i - 1, j);
                if (j > 0) owned_knobs(i, j - 1);
            }
        }
    }
}

// Tile (i, j) in assembled position, sitting on Z = 0.
module tile(i, j) {
    linear_extrude(height = Z) tile_2d(i, j);
}

// Selected tile, centred on X/Y for printing.
translate([-(tile_col + 0.5) * TW, -(tile_row + 0.5) * TH, 0])
    tile(tile_col, tile_row);
