/* =====================================================
   Boston relief lid — UniFi Toolless Mini Rack
   =====================================================
   A lid for the top of the U-Rack-6U-TL, shaped as a
   top-down 3D map of central Boston: Cambridge and the
   Charles at the top left, Back Bay and the Pru at the
   bottom left, Beacon Hill, the Common, downtown and the
   North End in the middle, Fort Point and the harbour on
   the right. North is +Y.

   The water is cut through as a slotted grille and the
   parks as a field of round holes, so the rack can still
   breathe through the lid.

   The lid lies on the rack's flat top frame. Each end has
   a notch for the handle, and the corners of the notch
   hug the handle's two legs. That's what keeps the lid
   from sliding, so nothing hangs below the plate and
   every tile prints flat with no supports.

   Too big for a 256 bed, so it splits into four tiles
   along X = 0 and Y = 0. Bowtie keys glue into pockets
   in the underside across the seams.

   Rack top (measured from Ubiquiti's 3D model of the
   U-Rack-6U-TL):
     frame outer        499.2 (across) × 459.7 (front–back)
     opening            419.4 × 399.0
     rails              40 wide on the sides, 30 on the
                        handle ends; flat sheet on top
     handle legs        Ø8, at X = ±60, 214.9 from the
                        centre toward each end

   Map: tools/boston_map.py, from OpenStreetMap.
   Map data © OpenStreetMap contributors, ODbL.

   The buildings are disjoint columns, each extruded from
   just inside the plate to its own height. The map data
   keeps neighbouring columns 0.015 mm apart on purpose:
   columns that share a wall give a union that touches
   itself, which slicers read from the STL as non-manifold
   edges (issue #16). The gap prints as nothing.

   Coordinates: X across the rack (map east), Y front to
   back (map north), Z up from the rack top.
   ===================================================== */

include <vendor/boston_map.inc>

$fn = 16;

/* ── Selection (set by presets) ─────────────────────── */
part = "tile";      // [tile, keys, assembled, none]
tile = "sw";        // [sw, se, nw, ne]

/* ── Rack top (measured) ────────────────────────────── */
top_w    = 499.2;   // across the rack
top_d    = 459.7;   // front to back
handle_x = 60;      // handle legs at X = ±handle_x
handle_y = 214.9;   // and Y = ±handle_y
leg_d    = 8;

/* ── Lid ────────────────────────────────────────────── */
plate_t     = 4.0;
corner_r    = 6;
notch_clear = 1.0;  // around each handle leg
grip_y      = 200;  // hand room under the handle, cut back to here
grip_x      = handle_x - leg_d / 2 - 3.5;   // leaves a tab inside each leg
edge_keep   = 3;    // solid border: no grille this close to an edge
seam_keep   = 3;    // or this close to a seam

/* ── Grille ─────────────────────────────────────────── */
// Water: east–west slots, tied every slot_len, staggered row to row.
slot_w   = 2.2;
rib_w    = 1.6;
slot_len = 24;
tie_w    = 2.0;
// Parks: round holes on a hex grid.
hole_d     = 2.4;
hole_pitch = 4.2;

/* ── Keys ───────────────────────────────────────────── */
key_len   = 26;     // across the seam
key_end   = 14;     // width at the ends
key_waist = 7;
key_t     = 2.0;
key_clear = 0.15;   // per side, in the pocket
key_depth = key_t + 0.2;
// [x, y, along]: along = "x" for a key across the X = 0 seam
key_at = concat(
    [for (y = [-150, -50, 50, 150]) [0, y, "x"]],
    [for (x = [-215, -130, -40, 40, 130, 215]) [x, 0, "y"]]);

/* ── Derived ────────────────────────────────────────── */
notch_x = handle_x + leg_d / 2 + notch_clear;
notch_y = handle_y - leg_d / 2 - notch_clear;
eps = 0.01;

/* ── Map data helpers ───────────────────────────────── */
// A poly is [outer, hole, hole, ...].
function ring_starts(p, i = 0, n = 0) =
    i == len(p) ? [] : concat([n], ring_starts(p, i + 1, n + len(p[i])));

module poly(p) {
    s = ring_starts(p);
    polygon(points = [for (r = p) each r],
            paths = [for (i = [0 : len(p) - 1]) [for (j = [0 : len(p[i]) - 1]) s[i] + j]]);
}

module polys(ps) { for (p = ps) poly(p); }

function bounds(ps) =
    let(pts = [for (p = ps) each p[0]])
    [[min([for (q = pts) q[0]]), min([for (q = pts) q[1]])],
     [max([for (q = pts) q[0]]), max([for (q = pts) q[1]])]];

/* ── Outline ────────────────────────────────────────── */
module outline() {
    offset(r = 1.5) offset(delta = -1.5)
    difference() {
        offset(r = corner_r) offset(delta = -corner_r)
            square([top_w, top_d], center = true);
        for (m = [0, 1]) mirror([0, m]) {
            // the legs sit in the notch corners
            translate([-notch_x, notch_y]) square([2 * notch_x, top_d]);
            // hand room between the legs
            translate([-grip_x, grip_y]) square([2 * grip_x, top_d]);
        }
    }
}

/* ── Keys ───────────────────────────────────────────── */
module key_shape(grow = 0) {
    offset(delta = grow)
    polygon([[-key_len / 2, -key_end / 2], [0, -key_waist / 2], [key_len / 2, -key_end / 2],
             [key_len / 2, key_end / 2], [0, key_waist / 2], [-key_len / 2, key_end / 2]]);
}

module at_keys() {
    for (k = key_at) translate([k[0], k[1]]) rotate(k[2] == "x" ? 0 : 90) children();
}

/* ── Grille ─────────────────────────────────────────── */
module water_slots() {
    b = bounds(map_water);
    pitch = slot_w + rib_w;
    for (j = [floor(b[0][1] / pitch) : ceil(b[1][1] / pitch)]) {
        off = (j % 2) * slot_len / 2;
        for (i = [floor((b[0][0] - off) / slot_len) - 1 : ceil((b[1][0] - off) / slot_len)])
            translate([i * slot_len + off + tie_w / 2, j * pitch - slot_w / 2])
                square([slot_len - tie_w, slot_w]);
    }
}

module park_holes() {
    b = bounds(map_parks);
    row = hole_pitch * sqrt(3) / 2;
    for (j = [floor(b[0][1] / row) : ceil(b[1][1] / row)]) {
        off = (j % 2) * hole_pitch / 2;
        for (i = [floor(b[0][0] / hole_pitch) - 1 : ceil(b[1][0] / hole_pitch)])
            translate([i * hole_pitch + off, j * row]) circle(d = hole_d);
    }
}

// Where the grille isn't allowed: near the edges, the seams and the keys.
module keep_solid() {
    difference() {
        square([top_w + 2, top_d + 2], center = true);
        offset(delta = -edge_keep) outline();
    }
    square([2 * seam_keep, top_d + 2], center = true);
    square([top_w + 2, 2 * seam_keep], center = true);
    at_keys() key_shape(seam_keep);
}

module grille() {
    difference() {
        union() {
            intersection() { polys(map_water); water_slots(); }
            intersection() { polys(map_parks); park_holes(); }
        }
        keep_solid();
    }
}

/* ── Lid ────────────────────────────────────────────── */
module plate() {
    difference() {
        linear_extrude(plate_t) difference() { outline(); grille(); }
        translate([0, 0, -eps]) linear_extrude(key_depth + eps)
            at_keys() key_shape(key_clear);
    }
}

// One prism per column. The columns never touch each other (see the
// header), so this union only has to cut them into the plate.
module buildings() {
    translate([0, 0, plate_t - eps])
        for (c = map_cols)
            linear_extrude(c[0] + eps) intersection() {
                offset(delta = -1) outline();
                polys(c[1]);
            }
}

module lid() { plate(); buildings(); }

/* ── Tiles ──────────────────────────────────────────── */
// Quadrant box for a tile: sw = west + south (front left).
function tile_sign(t) = [t == "se" || t == "ne" ? 1 : -1, t == "nw" || t == "ne" ? 1 : -1];

module tile(t) {
    s = tile_sign(t);
    intersection() {
        lid();
        translate([s[0] > 0 ? 0 : -top_w, s[1] > 0 ? 0 : -top_d, -1]) cube([top_w, top_d, 200]);
    }
}

module keys_plate() {
    n = len(key_at);
    for (i = [0 : n - 1])
        translate([(i % 5) * (key_len + 4), floor(i / 5) * (key_end + 4)])
            linear_extrude(key_t) key_shape();
}

/* ── Print layouts ──────────────────────────────────── */
if (part == "tile") {
    s = tile_sign(tile);
    // centred on the origin, plate down on the bed
    translate([-s[0] * top_w / 4, -s[1] * top_d / 4, 0]) tile(tile);
} else if (part == "keys") {
    keys_plate();
} else if (part == "assembled") {
    lid();
}
