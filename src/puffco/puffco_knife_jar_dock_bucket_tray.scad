/* =====================================================
   Puffco Hot Knife + 2× Jars + Power Dock + Trash Bucket
   =====================================================
   Single-piece tray (no lid) that holds:
     - Puffco Hot Knife        — 133 × 12 × 12 mm
     - 2× square jars          — 42 × 42 × 24 mm (lidded)
     - Puffco Power Dock       — 114 mm dia × 54 mm tall
                                 (saddle dip at 34 mm)
     - Trash bucket cylinder   — 122 mm dia × 83 mm tall

   Front section (9 mm tall)  : jars + knife slot.
   Rear riser   (33 mm tall)  : dock pocket on the left,
                                bucket pocket on the right.
   Cable cutout passes through the rear wall centred on
   the dock so the USB cable can stay plugged in.

   The dock pocket is offset ~9.5 mm to the left of the
   front-section centre so the whole tray fits a 256 mm
   print bed (with the bucket pocket also packed inside).

   Exterior : 249 × 195 × 33 mm
   ===================================================== */

$fn = 96;

/* ── Structure ───────────────────────────────────────── */
tol  = 1.0;
wall = 3.0;
flr  = 3.0;

/* ── Knife/jar section (matches puffco_knife_jar_tray) ─ */
id     = 6.0;                  // knife/jar slot depth
ez_a   = flr + id;             // 9 mm — front-section height

kl     = 133 + 2*tol;          // 135 mm — knife slot length (X)
kw     = 12  + 2*tol;          // 14  mm — knife slot width (Y)
kSlotY = kw + 2;               // 16  mm — Y footprint w/ wiggle

jw      = 42 + tol;            // 43 mm — jar slot edge
jar_gap = 12;                  //         gap between jars

/* ── Dock pocket ─────────────────────────────────────── */
dock_d   = 114 + 2*tol;        // 116 mm — pocket diameter
saddle_h = 34;                 //  34 mm — top of dock's saddle dip
ez_dock  = flr + saddle_h - 4; //  33 mm — riser top, 4 mm under dip

cable_w  = 60;                 // 60 mm — cable cutout width
cable_h  = 25;                 // 25 mm — cable cutout height

/* ── Bucket pocket ───────────────────────────────────── */
bucket_d = 122 + 2*tol;        // 124 mm — pocket diameter
                                //          walls share the dock's 30 mm
                                //          (bucket sticks ~53 mm above rim)

/* ── Layout ──────────────────────────────────────────── */
ix       = kl;                            // 135 mm — knife drive
ex_front = ix + 2*wall;                   // 141 mm — front-section width

// X layout (rear riser, left → right):
//   wall(3)               outer left wall
//   dock_d(116)           dock pocket
//   wall(3)               wall between pockets (min thickness)
//   bucket_d(124)         bucket pocket
//   wall(3)               outer right wall
dock_cx   = wall + dock_d / 2;                            //  61 mm
bucket_cx = dock_cx + dock_d/2 + wall + bucket_d/2;       // 184 mm
ex        = bucket_cx + bucket_d/2 + wall;                // 249 mm

// Y layout (front → back):
//   wall(3) jw(43) wall(3) kSlotY(16)            = ey_a = 65   (front)
//   wall(3) bucket_d(124) wall(3)                = ey_b = 130  (rear)
ey_a = wall + jw + wall + kSlotY;         //  65 mm
ey_b = wall + bucket_d + wall;            // 130 mm — paced by larger pocket
ey   = ey_a + ey_b;                       // 195 mm

// Pocket centres (Y)
pocket_cy = ey_a + ey_b / 2;              // 130 mm — both pockets share Y

// Jar X positions (within the front section, X=0..ex_front)
jarsW = 2*jw + jar_gap;        // 98 mm
jMarX = (ix - jarsW) / 2;      // 18.5 mm side margin
j1x   = wall + jMarX;
j2x   = j1x + jw + jar_gap;

jSecY = wall;                  // jars start
ky0   = wall + jw + wall;      // knife slot start

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

/* ── Body ────────────────────────────────────────────── */
module body() {
    union() {
        // Front section (knife + jars), low — only spans the left 141 mm
        rbox(ex_front, ey_a, ez_a, r = 3);

        // Rear riser (dock + bucket), tall — full width
        translate([0, ey_a, 0])
            rbox(ex, ey_b, ez_dock, r = 3);
    }
}

module tray() {
    difference() {
        body();

        // Jar slot 1 — front left
        translate([j1x, jSecY, flr])
            rpocket(jw, jw, id + 1, r = 2);

        // Jar slot 2 — front right
        translate([j2x, jSecY, flr])
            rpocket(jw, jw, id + 1, r = 2);

        // Knife slot — back of front section, full interior X
        translate([wall, ky0, flr])
            rpocket(ix, kSlotY, id + 1, r = 2);

        // Dock pocket — circular well, left side of rear riser
        translate([dock_cx, pocket_cy, flr])
            cylinder(d = dock_d, h = ez_dock - flr + 1);

        // Bucket pocket — circular well, right side of rear riser
        translate([bucket_cx, pocket_cy, flr])
            cylinder(d = bucket_d, h = ez_dock - flr + 1);

        // Cable cutout — through the rear wall, centred on dock
        translate([dock_cx - cable_w/2, ey - wall - 1, flr])
            cube([cable_w, wall + 2, cable_h]);
    }
}

/* ── Render ──────────────────────────────────────────── */
tray();

/* ── Summary ─────────────────────────────────────────── */
echo(str("Exterior      : ", ex, " × ", ey, " × ", ez_dock, " mm"));
echo(str("Front section : ", ex_front, " × ", ey_a, " × ", ez_a, " mm"));
echo(str("Dock pocket   : ", dock_d,   " mm dia × ", ez_dock - flr, " mm deep"));
echo(str("Bucket pocket : ", bucket_d, " mm dia × ", ez_dock - flr, " mm deep"));
echo(str("Cable cutout  : ", cable_w, " × ", cable_h, " mm, centred on dock"));
