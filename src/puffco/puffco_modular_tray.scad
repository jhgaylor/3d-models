/* =====================================================
   Puffco modular tray — 3 dovetailed pieces
   =====================================================
   parameterSets: knife_jar | dock | bucket

   Each piece prints separately. They join via two
   drop-down dovetails:

     knife_jar  →  dock  (tongue on knife_jar's +Y face,
                          socket cut into dock's -Y face,
                          9 mm tall; cavity closed at top
                          so no visible slot from above)

     dock       →  bucket (tongue on dock's +X face,
                           socket cut into bucket's -X face,
                           30 mm tall with a 3 mm cap above
                           the cavity)

   Assembly: place one piece flat on the bed. Lift the
   neighbouring piece up, align its socket above the
   tongue, and lower straight down. The trapezoidal
   barbs lock the joint against lateral pull-out.

   Assembled exterior : 252 × 195 × 33 mm
   ===================================================== */

$fn = 96;

/* ── Part selector (overridden by parameterSets) ─────── */
part = "knife_jar";   // [knife_jar, dock, bucket]

/* ── Common structure ────────────────────────────────── */
tol  = 1.0;
wall = 3.0;
flr  = 3.0;

/* ── Knife/jar dimensions ────────────────────────────── */
id     = 6.0;
ez_a   = flr + id;             // 9
kl     = 133 + 2*tol;          // 135
kw     = 12  + 2*tol;          // 14
kSlotY = kw + 2;               // 16
jw      = 42 + tol;            // 43
jar_gap = 12;

/* ── Dock dimensions ─────────────────────────────────── */
dock_d   = 114 + 2*tol;        // 116
saddle_h = 34;
ez_dock  = flr + saddle_h - 4; // 33
cable_w  = 60;
cable_h  = 25;

/* ── Bucket dimensions ───────────────────────────────── */
bucket_d = 122 + 2*tol;        // 124

/* ── X layout ────────────────────────────────────────── */
ix       = kl;                            // 135
ex_front = ix + 2*wall;                   // 141 — knife/jar piece width

dock_cx         = wall + dock_d/2;        //  61 — dock pocket centre
seam_x          = wall + dock_d + wall;   // 122 — split between dock and bucket pieces
ex_dock_piece   = seam_x;                 // 122 — dock piece width
bucket_local_cx = wall + bucket_d/2;      //  65 — bucket pocket centre within bucket piece
bucket_cx       = seam_x + bucket_local_cx; // 187 — bucket pocket centre in world
ex_bucket_piece = wall + bucket_d + wall; // 130 — bucket piece width
ex              = seam_x + ex_bucket_piece; // 252 — assembled total width

/* ── Y layout ────────────────────────────────────────── */
ey_a = wall + jw + wall + kSlotY;         //  65 — knife/jar piece depth
ey_b = wall + bucket_d + wall;            // 130 — dock/bucket piece depth
ey   = ey_a + ey_b;                       // 195 — assembled total depth

pocket_cy = ey_a + ey_b/2;                // 130 — both dock + bucket pockets share Y

/* ── Knife/jar slot positions ────────────────────────── */
jarsW = 2*jw + jar_gap;
jMarX = (ix - jarsW) / 2;
j1x   = wall + jMarX;
j2x   = j1x + jw + jar_gap;
jSecY = wall;
ky0   = wall + jw + wall;

/* ── Dovetail (matches mac_mini convention) ──────────── */
dt_length = 12;
dt_narrow = 14;   // base (parent side)
dt_wide   = 22;   // tip (barb side)
dt_gap    = 0.3;

// Knife/jar ↔ dock: tongue on knife/jar's +Y face
dt_kj_cx  = 15;             // X centre — well left of the dock pocket
dt_kj_zh  = ez_a;           // 9 mm — matches knife/jar height

// Dock ↔ bucket: tongue on dock's +X face
dt_db_cy  = 181;            // Y centre — near rear, clear of bucket pocket at the tongue tip
dt_db_zh  = ez_dock - 3;    // 30 mm — leaves a 3 mm cap above the bucket-side socket

/* ── Helpers ─────────────────────────────────────────── */
module rpocket(w, l, d, r = 2) {
    hull()
        for (dx = [r, w - r], dy = [r, l - r])
            translate([dx, dy, 0]) cylinder(r = r, h = d);
}

module rbox(w, l, h, r = 3) {
    hull()
        for (dx = [r, w - r], dy = [r, l - r])
            translate([dx, dy, 0]) cylinder(r = r, h = h);
}

// 2D trapezoid: narrow at base (origin), wide at tip (+X by len)
module dt_trapezoid(w_narrow, w_wide, len) {
    polygon([
        [0,    -w_narrow/2],
        [0,     w_narrow/2],
        [len,   w_wide/2],
        [len,  -w_wide/2],
    ]);
}

module dt_tongue_2d() {
    dt_trapezoid(dt_narrow, dt_wide, dt_length);
}

module dt_socket_2d() {
    dt_trapezoid(dt_narrow + dt_gap, dt_wide + dt_gap, dt_length);
}

/* ── Knife/jar piece ─────────────────────────────────── */
module part_knife_jar() {
    difference() {
        union() {
            rbox(ex_front, ey_a, ez_a, r = 3);
            // Tongue on +Y face — base at Y = ey_a, widens out to Y = ey_a + 12
            translate([dt_kj_cx, ey_a, 0])
                rotate([0, 0, 90])
                    linear_extrude(dt_kj_zh)
                        dt_tongue_2d();
        }
        // Jar 1
        translate([j1x, jSecY, flr])
            rpocket(jw, jw, id + 1, r = 2);
        // Jar 2
        translate([j2x, jSecY, flr])
            rpocket(jw, jw, id + 1, r = 2);
        // Knife
        translate([wall, ky0, flr])
            rpocket(ix, kSlotY, id + 1, r = 2);
    }
}

/* ── Dock piece ──────────────────────────────────────── */
module part_dock() {
    difference() {
        union() {
            // Body — X = 0..seam_x, Y = ey_a..ey
            translate([0, ey_a, 0])
                rbox(ex_dock_piece, ey_b, ez_dock, r = 3);
            // Tongue on +X face — base at X = seam_x, widens out to X = seam_x + 12
            translate([seam_x, dt_db_cy, 0])
                linear_extrude(dt_db_zh)
                    dt_tongue_2d();
        }
        // Dock pocket
        translate([dock_cx, pocket_cy, flr])
            cylinder(d = dock_d, h = ez_dock - flr + 1);
        // Cable cutout — from the back of the dock pocket through the rear wall
        cable_y0 = pocket_cy + dock_d/2 - 1;
        cable_y1 = ey + 1;
        translate([dock_cx - cable_w/2, cable_y0, flr])
            cube([cable_w, cable_y1 - cable_y0, cable_h]);
        // Socket on -Y face — cavity cut into the dock body, closed at top (Z = dt_kj_zh)
        translate([dt_kj_cx, ey_a, 0])
            rotate([0, 0, 90])
                linear_extrude(dt_kj_zh + 0.01)
                    dt_socket_2d();
    }
}

/* ── Bucket piece ────────────────────────────────────── */
module part_bucket() {
    difference() {
        // Body — X = seam_x..ex, Y = ey_a..ey
        translate([seam_x, ey_a, 0])
            rbox(ex_bucket_piece, ey_b, ez_dock, r = 3);
        // Bucket pocket
        translate([bucket_cx, pocket_cy, flr])
            cylinder(d = bucket_d, h = ez_dock - flr + 1);
        // Socket on -X face — cavity, closed at Z = dt_db_zh (3 mm cap above)
        translate([seam_x, dt_db_cy, 0])
            linear_extrude(dt_db_zh + 0.01)
                dt_socket_2d();
    }
}

/* ── Render ──────────────────────────────────────────── */
if (part == "knife_jar") part_knife_jar();
if (part == "dock")      part_dock();
if (part == "bucket")    part_bucket();

/* ── Summary ─────────────────────────────────────────── */
echo(str("Part            : ", part));
echo(str("Assembled total : ", ex, " × ", ey, " × ", ez_dock, " mm"));
echo(str("Knife/jar piece : ", ex_front, " × ", ey_a, " × ", ez_a, " mm"));
echo(str("Dock piece      : ", ex_dock_piece, " × ", ey_b, " × ", ez_dock, " mm"));
echo(str("Bucket piece    : ", ex_bucket_piece, " × ", ey_b, " × ", ez_dock, " mm"));
