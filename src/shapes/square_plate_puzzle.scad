/* =====================================================
   Square Plate — split for gluing (solid)
   =====================================================
   A 14.5" square plate too big for the bed, split into a
   grid of tiles that superglue back together.

   Joint styles (`joint`):
     lap    — half-lap (default). Each seam edge is stepped
              to half thickness over a strip and neighbours
              overlap like shingles: both faces flat, a wide
              flat glue strip, and the step self-aligns.
     knobs  — straight butt seam with jigsaw knobs.

   Overall side : 14.5 in  (368.3 mm)
   Thickness    : 1/8 in   (  3.175 mm)
   Grid         : 2 × 2 → tiles are 7.25 in (184.15 mm)
                  square, ~190 mm max with lap lips.

   Each tile is a preset in square_plate_puzzle.json
   (tile_col / tile_row).

   Half-lap tiles alternate in a checkerboard: front-left
   and back-right have their lips on the bottom layer,
   the other two on the top. Every tile is exported lips-
   down, so all of them print flat with no supports —
   flip the front-right / back-left tiles back over when
   assembling.
   ===================================================== */

$fa = 2;
$fs = 0.5;

in = 25.4;   // mm per inch

/* ── Tile selection (set by presets) ─────────────────── */
tile_col = 0;   // 0 = left (-X)
tile_row = 0;   // 0 = front (-Y)

/* ── Joint ───────────────────────────────────────────── */
joint = "lap";   // [lap, knobs]

/* ── Dimensions (inches) ─────────────────────────────── */
side_in      = 14.5;     // assembled square edge length
thickness_in = 1/8;      // plate thickness

/* ── Grid ────────────────────────────────────────────── */
cols = 2;
rows = 2;

/* ── Half-lap (mm) ───────────────────────────────────── */
lap_width    = 12;       // overlap strip width across the seam
lap_gap      = 0.2;      // total gap at each lap step (glue line)

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
L  = lap_width / 2;
G  = lap_gap / 2;

/* ── Half-lap ────────────────────────────────────────── */

// Checkerboard: "even" tiles have lips on the bottom layer.
function lips_low(i, j) = (i + j) % 2 == 0;

// Does tile (i, j) reach past its seams on this layer (0 = bottom)?
function extends(i, j, layer) = lips_low(i, j) == (layer == 0);

// Tile (i, j) on one layer, in assembled coordinates. Internal edges
// sit lap_width/2 past the seam where the tile extends, lap_width/2
// short of it where it doesn't, less half the glue gap either way.
module lap_layer_2d(i, j, layer) {
    e  = extends(i, j, layer) ? L : -L;
    x0 = i > 0        ? i * TW - e + G       : 0;
    x1 = i < cols - 1 ? (i + 1) * TW + e - G : S;
    y0 = j > 0        ? j * TH - e + G       : 0;
    y1 = j < rows - 1 ? (j + 1) * TH + e - G : S;
    difference() {
        translate([x0, y0]) square([x1 - x0, y1 - y0]);
        // Where seams cross, the two diagonal tiles that extend on this
        // layer both cover the centre square; the front one (lower row)
        // keeps it and the other is notched.
        if (extends(i, j, layer))
            for (cx = [max(i, 1) : min(i + 1, cols - 1)],
                 cy = [max(j, 1) : min(j + 1, rows - 1)])
                if (j == cy)   // tile is in the back row of this crossing
                    translate([cx * TW, cy * TH])
                        square(lap_width + lap_gap, center = true);
    }
}

module lap_tile(i, j) {
    linear_extrude(height = Z / 2) lap_layer_2d(i, j, 0);
    translate([0, 0, Z / 2])
        linear_extrude(height = Z / 2) lap_layer_2d(i, j, 1);
}

/* ── Jigsaw knobs ────────────────────────────────────── */

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

// Tile (i, j) outline in assembled coordinates.
module knob_tile_2d(i, j) {
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

/* ── Tiles ───────────────────────────────────────────── */

// Tile (i, j) in assembled position, sitting on Z = 0.
module tile(i, j) {
    if (joint == "lap") lap_tile(i, j);
    else linear_extrude(height = Z) knob_tile_2d(i, j);
}

// Selected tile, centred on X/Y for printing. Half-lap tiles with
// top-layer lips are flipped so the lips print on the bed.
flip = joint == "lap" && !lips_low(tile_col, tile_row);
translate([0, 0, flip ? Z : 0])
    rotate([flip ? 180 : 0, 0, 0])
        translate([-(tile_col + 0.5) * TW, -(tile_row + 0.5) * TH, 0])
            tile(tile_col, tile_row);
