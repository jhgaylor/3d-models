/* =====================================================
   Compute bay kit — UniFi Toolless Mini Rack
   =====================================================
   Parts for laying out the compute bay (the 3U on the fixed
   shelf, UACC-Rack-Shelf-TL) flat, in two rows with air
   between everything:

     front row  GMKtec M8 · two Mac mini M4 stacked on a
                riser · Mac mini M4
     back row   Geekom A9 Mega · Minisforum MS-A2

   The power bricks and the HDHomeRun live in the brick caddy
   at the bottom back of the rack (rack_brick_caddy.scad).

   Why this layout: the fan lid's fans and clips hang 18.2 mm
   into the bay, so under a fan there's about 122 mm, not
   141. An M8 on a bridge over the MS-A2 would stand 134 mm.
   Two minis stacked with a 10 mm gap stand 116 mm, and the
   freed spot takes the M8 flat. Also, the rack's side
   ledges stick 19.7 mm in at every 48 mm, so nothing taller
   than 46 mm may come within 22 mm of a side slat (the
   ledge plus a cable clip's spine): every device stays
   inside |x| ≤ 199.5.

   Parts:
     fin     spacer between two front-row devices (17 mm
             gap), pinned into the shelf's perforations
     deck    the riser's top: carries the upper Mac mini on
             two ribs under its foot, so the intake ring
             round the foot stays open; corner lips locate it
     post    four legs for the deck, standing outside the
             lower mini's corners
     clip    a cable clip that pushes onto a side ledge and
             holds a bundle in the 19.7 mm band between the
             ledge edge and the slat, out of the airflow
     pins    loose pins for the fins (the shelf's holes are
             Ø3.5 on a 6.0 × 5.2 staggered grid)

   Coordinates: X across the rack (centred), Y back from the
   front of the shelf, Z up from the shelf top.
   ===================================================== */

$fa = 2;
$fs = 0.4;

/* ── Selection (set by presets) ─────────────────────── */
part = "fins";      // [fins, deck, posts, clips, pins, fit_test, none]

/* ── Devices (mm: width × depth × height) ───────────── */
mini   = [127, 127, 50];      // Mac mini M4
m8     = [110, 110, 65];      // GMKtec NucBox M8
a9     = [171, 171, 71];      // Geekom A9 Mega
msa2   = [196, 189, 48];      // Minisforum MS-A2

/* ── Layout (bay frame) ─────────────────────────────── */
gap      = 17;                // between front-row devices (a fin's width + 1)
row_x0   = -71.5;             // left edge of the stacked minis
row_y    = 76;                // front row's front edge (inside the perforated field)
channel  = 26;                // air channel between the rows (the back row then
                              // ends 42 mm short of the shelf's back, clear of
                              // the AC Infinity, 38 mm deep)
back_gap = 30;                // between the A9 and the MS-A2
side_max = 199.5;             // nothing tall beyond this |x|

/* ── Fin ────────────────────────────────────────────── */
fin_w    = gap - 1;           // 16
fin_len  = 50;
fin_h    = 16;
fin_cham = 3;

/* ── Riser ──────────────────────────────────────────── */
riser_gap  = 10;              // lower mini top to deck underside
mini_clear = 1.0;             // per side, round the minis
post_w     = 8;
rail_w     = 8;
rail_h     = 4;
rib_w      = 8;
rib_h      = 6;               // ribs stand 2 mm proud of the rails
rib_x      = 26;              // ribs at ±26: under the M4's foot
lip_h      = 4;
lip_len    = 18;
lip_t      = 2.4;
peg_d      = 4.0;
peg_len    = 4;
peg_clear  = 0.2;

/* ── Ledge clip ─────────────────────────────────────── */
ledge_t     = 1.65;
ledge_in    = 19.7;           // ledge edge to slat
clip_v      = 12;             // clip thickness along the ledge
spine_t     = 2;
jaw_len     = 11;
jaw_t       = 2.4;
jaw_gap     = 1.75;           // ledge 1.65 + a little
bump        = 0.1;            // friction bump on the top jaw (0.25 printed tight)
hook_u      = 9.5;            // hook centre out from the ledge edge
hook_z      = -15;            // hook centre below the ledge top
hook_r      = 7;              // inner radius: a bundle up to ~14 mm
hook_wall   = 2;
hook_mouth  = 5;              // opening at the bottom, toward the wall

/* ── Shelf pins (same as unifi_shelf_dock) ──────────── */
hole_pitch = 6.0;
pin_d      = 3.1;
pin_hole   = 3.4;
pin_head_d = 6.2;
pin_head_t = 1.2;
cbore_d    = 6.8;
cbore_t    = 1.4;
pin_peg    = 2.0;             // how far a pin pokes below the part
pin_count  = 6;

eps = 0.01;

/* ── Derived layout ─────────────────────────────────── */
stack_x  = row_x0 + mini[0] / 2;                     // stacked minis' centre
m8_x     = row_x0 - gap - m8[0] / 2;
mini_x   = row_x0 + mini[0] + gap + mini[0] / 2;
fin_x    = [row_x0 - gap / 2, row_x0 + mini[0] + gap / 2];
back_y   = row_y + mini[1] + channel;
a9_x     = -side_max + a9[0] / 2 + 1;
msa2_x   = a9_x + a9[0] / 2 + back_gap + msa2[0] / 2;
deck_in  = mini[0] / 2 + mini_clear;                 // half-width inside the posts
deck_out = deck_in + post_w;
deck_z   = mini[2] + riser_gap;                      // deck underside
upper_z  = deck_z + rib_h;                           // where the upper mini sits

/* ── Fin ────────────────────────────────────────────── */
module fin() {
    difference() {
        hull() {
            translate([-fin_w / 2, 0, 0]) cube([fin_w, fin_len, fin_h - fin_cham]);
            translate([-fin_w / 2 + fin_cham, 0, 0]) cube([fin_w - 2 * fin_cham, fin_len, fin_h]);
        }
        // two pins on one perforation row, one hole pitch apart
        for (x = [-hole_pitch / 2, hole_pitch / 2]) translate([x, fin_len / 2, 0]) {
            translate([0, 0, -1]) cylinder(d = pin_hole, h = fin_h + 2);
            translate([0, 0, fin_h - cbore_t]) cylinder(d = cbore_d, h = cbore_t + 1);
        }
    }
}

/* ── Riser ──────────────────────────────────────────── */
// Deck, as printed: rails and ribs on the bed, lips up. In place it's
// the same way up (z = 0 here is the deck's underside).
module deck() {
    difference() {
        union() {
            // perimeter rails over the posts
            difference() {
                translate([-deck_out, -deck_out, 0]) cube([2 * deck_out, 2 * deck_out, rail_h]);
                translate([-deck_in, -deck_in, -1]) cube([2 * deck_in, 2 * deck_in, rail_h + 2]);
            }
            // two ribs under the upper mini's foot
            for (x = [-rib_x, rib_x]) translate([x - rib_w / 2, -deck_in - eps, 0])
                cube([rib_w, 2 * deck_in + 2 * eps, rib_h]);
            // corner lips locate the upper mini
            for (sx = [-1, 1], sy = [-1, 1]) mirror([sx < 0 ? 1 : 0, 0, 0]) mirror([0, sy < 0 ? 1 : 0, 0]) {
                translate([deck_in, deck_in - lip_len, 0]) cube([lip_t, lip_len, rib_h + lip_h]);
                translate([deck_in - lip_len, deck_in, 0]) cube([lip_len + lip_t, lip_t, rib_h + lip_h]);
            }
        }
        // sockets for the post pegs
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx * (deck_in + post_w / 2), sy * (deck_in + post_w / 2), -1])
                cylinder(d = peg_d + 2 * peg_clear, h = peg_len + 1.5);
    }
}

// A post, standing: it reaches the deck's underside and pegs into it.
module post() {
    translate([-post_w / 2, -post_w / 2, 0]) cube([post_w, post_w, deck_z]);
    translate([0, 0, deck_z - eps]) cylinder(d = peg_d, h = peg_len + eps);
}

/* ── Ledge clip ─────────────────────────────────────── */
// Profile in (u, z): u out from the ledge edge toward the slat, z up
// from the ledge top. Extruded clip_v along the ledge.
module clip_profile() {
    difference() {
        union() {
            // spine, just inside the ledge edge
            let(z0 = hook_z - hook_r - hook_wall, z1 = jaw_gap + jaw_t)
                translate([-spine_t, z0]) square([spine_t, z1 - z0]);
            // top jaw (over the ledge) with its friction bump
            translate([0, jaw_gap]) square([jaw_len, jaw_t]);
            translate([jaw_len - 3, jaw_gap - bump]) square([2, bump + eps]);
            // bottom jaw
            translate([0, -jaw_t]) square([jaw_len, jaw_t]);
            // hook ring
            translate([hook_u, hook_z]) circle(r = hook_r + hook_wall);
            // web from the spine to the ring
            translate([-spine_t, hook_z]) square([hook_u, hook_r + hook_wall]);
        }
        translate([hook_u, hook_z]) circle(r = hook_r);
        // mouth: open at the bottom, toward the wall, so a bundle pushes in
        translate([hook_u, hook_z]) rotate(-60) translate([0, -hook_mouth / 2]) square([hook_r + hook_wall + 1, hook_mouth]);
        // keep the ring clear of the slat
        translate([ledge_in - 0.8, -60]) square([10, 80]);
    }
}

module clip() { linear_extrude(clip_v) clip_profile(); }

/* ── Pins ───────────────────────────────────────────── */
module pin() {
    cylinder(d = pin_head_d, h = pin_head_t);
    cylinder(d = pin_d, h = fin_h - cbore_t + pin_peg);
}

/* ── Layout helpers (scenes include this file) ──────── */
module at_fins() {
    for (x = fin_x) for (y = [row_y + (mini[1] - fin_len) / 2]) translate([x, y, 0]) children();
}

module riser_in_place() {
    translate([stack_x, row_y + mini[1] / 2, 0]) {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx * (deck_in + post_w / 2), sy * (deck_in + post_w / 2), 0]) post();
        translate([0, 0, deck_z]) deck();
    }
}

/* ── Fit test ───────────────────────────────────────── */
module fit_test() {
    clip();
    // a slice of fin with both pin holes
    translate([30, 0, 0]) intersection() {
        translate([0, -fin_len / 2 + 10, 0]) fin();
        translate([-fin_w, -10, -1]) cube([2 * fin_w, 40, fin_h + 2]);
    }
    translate([55, 0, 0]) pin();
}

/* ── Output ─────────────────────────────────────────── */
if (part == "fins") {
    for (i = [0 : 1]) translate([i * (fin_w + 6), 0, 0]) fin();
} else if (part == "deck") {
    deck();
} else if (part == "posts") {
    for (i = [0 : 3]) translate([i * (post_w + 6), 0, 0]) post();
} else if (part == "clips") {
    for (i = [0 : 5]) translate([(i % 3) * 36, floor(i / 3) * 32, 0]) clip();
} else if (part == "pins") {
    for (i = [0 : pin_count - 1]) translate([i * (pin_head_d + 3), 0, 0]) pin();
} else if (part == "fit_test") {
    fit_test();
}
