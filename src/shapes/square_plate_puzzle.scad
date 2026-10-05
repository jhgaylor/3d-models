/* =====================================================
   Square Plate — puzzle-split (solid)
   =====================================================
   A 14.5" square plate too big for the bed, split into a
   grid of tiles. Seams are zigzagged for extra glue
   surface (~1.8× a straight cut), with jigsaw knobs on
   flat lands to lock alignment. Print each tile, press
   the knobs together, and glue (CA or plastic cement on
   the seams).

   Overall side : 14.5 in  (368.3 mm)
   Thickness    : 1/8 in   (  3.175 mm)
   Grid         : 2 × 2 → tiles are 7.25 in (184.15 mm)
                  square, ~198 mm max with knobs.

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

/* ── Zigzag seam (mm) ────────────────────────────────── */
zig_pitch    = 8;        // target tooth pitch (fitted to the side)
zig_depth    = 6;        // peak-to-peak tooth depth
seam_gap     = 0.2;      // total gap across the zigzag (glue line)
knob_land    = 10;       // flat half-width around each knob

/* ── Derived (mm) ────────────────────────────────────── */
S  = side_in      * in;
Z  = thickness_in * in;
TW = S / cols;
TH = S / rows;
P  = S / round(S / zig_pitch);   // whole teeth along each seam
Q  = P / 4;                      // sample step: zero, peak, zero, trough

// Knob positions along an edge, as fractions of the tile edge.
function knob_fracs() = [for (k = [0 : knobs_per_edge - 1]) (k + 0.5) / knobs_per_edge];

// Flat lands along a seam: around each knob, and where the seams
// of the other direction cross (so their teeth don't collide).
// Edges snap outward to zero crossings, so the zigzag meets them flat.
function snap_land(c, w) = [floor((c - w) / (2 * Q)) * 2 * Q,
                            ceil ((c + w) / (2 * Q)) * 2 * Q];
function seam_lands(n, T) = concat(
    [for (j = [0 : n - 1], f = knob_fracs()) snap_land((j + f) * T, knob_land)],
    [for (j = [1 : n - 1]) snap_land(j * T, zig_depth)]);

function in_land(t, lands) = len([for (l = lands) if (t > l[0] - 0.01 && t < l[1] + 0.01) 1]) > 0;

// Zigzag offset across the seam at sample k (t = k * Q).
function zig(k, lands) =
    in_land(k * Q, lands) ? 0 : [0, zig_depth / 2, 0, -zig_depth / 2][k % 4];

// Seam profile as [along, across] points, padded past both ends.
function seam_pts(lands) = concat(
    [[-1, 0]],
    [for (k = [0 : round(S / Q)]) [k * Q, zig(k, lands)]],
    [[S + 1, 0]]);

// Region on the low side (-across) of a seam at `pos`, pulled back
// by half the glue gap. `hi = true` gives the high side instead.
module seam_side(pos, n, T, hi) {
    pts = seam_pts(seam_lands(n, T));
    g = hi ? seam_gap / 2 : -seam_gap / 2;
    far = hi ? S + 1 : -1;
    polygon(concat(
        [for (p = pts) [p[0], pos + g + p[1]]],
        [[S + 1, far], [-1, far]]));
}

// Swap X/Y so a seam profile built along X runs along Y.
module along_y() { multmatrix([[0, 1, 0, 0], [1, 0, 0, 0], [0, 0, 1, 0]]) children(); }

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

// Tile (i, j) body between its four seams (outer edges are straight).
module tile_cell(i, j) {
    intersection() {
        // Vertical seams run along Y, so build them along X and swap.
        // Missing seams fall back to the full square: an empty child
        // would empty the whole intersection.
        if (i > 0)        along_y() seam_side(i * TW, rows, TH, true);
        else              square([S, S]);
        if (i < cols - 1) along_y() seam_side((i + 1) * TW, rows, TH, false);
        else              square([S, S]);
        if (j > 0)        seam_side(j * TH, cols, TW, true);
        else              square([S, S]);
        if (j < rows - 1) seam_side((j + 1) * TH, cols, TW, false);
        else              square([S, S]);
    }
}

// Tile (i, j) outline in assembled (global) coordinates,
// square spanning [0, S] × [0, S].
module tile_2d(i, j) {
    intersection() {
        square([S, S]);
        difference() {
            union() {
                tile_cell(i, j);
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
