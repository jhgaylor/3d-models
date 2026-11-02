/* =====================================================
   Pasta bin (cabinet corner)
   =====================================================
   An open-top bin for the corner of the cabinet between the
   left wall and the canned goods. It holds 3-5 one-pound
   boxes or bags of pasta (about 7.5 x 3 x 1.75 in each),
   standing upright and filed front to back.

   Measured:
     slot          4.5 wide (left wall to the can) x 11 deep
                   x 10 5/8 tall (in)

   The side walls slope down from the back to a low front, so
   you can see the labels and pull one out. The back wall is
   full height, so nothing tips over the back. Set `lanes` above
   1 to add front-to-back dividers.

   The bed limits the depth to 250 mm (9.84 in), which leaves
   about 1 in free at the front of the 11 in shelf.

   The side walls, back and floor are cut with a honeycomb to
   save plastic. Only whole hexagons are cut, with a solid
   border round each panel. The wall hexagons stand point-up,
   so every hole edge is 60° off the bed and prints without
   supports.

   Print it as modelled: floor on the bed, open top up. There
   are no overhangs.

   Coordinates: X across (centred), Y front to back (front at
   Y = 0), Z up from the shelf.
   ===================================================== */

in = 25.4;   // mm per inch

/* ── Slot (measured, inches) ────────────────────────── */
slot_w_in = 4.5;
slot_d_in = 11;
slot_h_in = 10 + 5/8;

/* ── Bin (inches) ───────────────────────────────────── */
side_gap_in = 1/8;    // total, so it slides in between wall and can
depth_in    = 9.75;   // fits a 256 mm bed
back_h_in   = 6;      // side walls at the back
front_h_in  = 2;      // side walls at the front
lanes       = 1;      // 1 = open bin, more = dividers front to back

/* ── Plastic (mm) ───────────────────────────────────── */
wall  = 2;
floor_t = 2;
honeycomb = true;
hex_r      = 12;   // hexagon circumradius
hex_web    = 3;    // plastic between hexagons
hex_border = 6;    // solid rim round each panel

/* ── Derived (mm) ───────────────────────────────────── */
W  = (slot_w_in - side_gap_in) * in;
D  = depth_in * in;
HB = back_h_in * in;
HF = front_h_in * in;

assert(D <= slot_d_in * in, "bin is deeper than the shelf");
assert(HB <= slot_h_in * in, "bin is taller than the slot");
assert(D <= 250, "bin won't fit a 256 mm bed");

eps = 0.01;

// side profile in the Y-Z plane: low front, sloping up to the back
module profile() {
    polygon([[0, 0], [D, 0], [D, HB], [0, HF]]);
}

// 2D point-up hexagons filling [0,w] x [0,h], keeping only those
// whose corners all pass inside(x, y)
function hex_corners(c) = [for (a = [30 : 60 : 330]) c + hex_r * [cos(a), sin(a)]];

module hex_cells(w, h, inside) {
    px = sqrt(3) * hex_r + hex_web;
    py = 1.5 * hex_r + hex_web * sqrt(3) / 2;
    for (j = [0 : ceil(h / py)], i = [0 : ceil(w / px)]) {
        c = [i * px + (j % 2) * px / 2, j * py];
        if (len([for (v = hex_corners(c)) if (!inside(v[0], v[1])) 1]) == 0)
            translate(c) rotate(30) circle(r = hex_r, $fn = 6);
    }
}

// hexagons for a side wall or divider, in profile coordinates
module side_cells() {
    b = hex_border;
    top = function(y) HF + (HB - HF) * y / D;
    hex_cells(D, HB, function(x, z)
        x >= b && x <= D - b && z >= floor_t + b && z <= top(x) - b);
}

module panel_cells(w, h, b) {
    hex_cells(w, h, function(x, y) x >= b && x <= w - b && y >= b && y <= h - b);
}

module pasta_bin() {
    lane_w = (W - (lanes + 1) * wall) / lanes;
    // one solid with the lanes cut out, so the walls, floor and
    // lip never meet face to face
    difference() {
        translate([-W / 2, 0, 0]) rotate([90, 0, 90])
            linear_extrude(W) profile();
        for (i = [0 : lanes - 1])
            translate([-W / 2 + wall + i * (lane_w + wall), wall, floor_t])
                cube([lane_w, D - 2 * wall, HB]);
        if (honeycomb) {
            for (i = [0 : lanes])
                translate([-W / 2 + i * (lane_w + wall) - eps, 0, 0])
                    rotate([90, 0, 90]) linear_extrude(wall + 2 * eps) side_cells();
            // back wall, seen from the front
            translate([-W / 2, D + eps, 0]) rotate([90, 0, 0])
                linear_extrude(wall + 2 * eps)
                    panel_cells(W, HB, wall + hex_border);
            // floor
            translate([-W / 2, 0, -eps])
                linear_extrude(floor_t + 2 * eps)
                    panel_cells(W, D, wall + hex_border);
        }
    }
}

pasta_bin();
