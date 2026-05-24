/* =====================================================
   Puffco Hot Knife (041879) + 2× Jars + Power Dock Tray
   =====================================================
   Single-piece tray (no lid) that holds:
     - Puffco Hot Knife        — 133 × 12 × 12 mm
     - 2× square jars          — 42 × 42 × 24 mm (lidded)
     - Puffco Power Dock       — 114 mm dia × 54 mm tall
                                 (saddle dip at 34 mm)

   Knife/jar geometry mirrors puffco_knife_jar_tray.scad
   so this tray prints with the same item fit. The dock
   sits in a circular pocket behind the knife slot; a
   slot through the rear wall lets the USB cable plug
   into the dock while it's seated in the tray.

   Exterior : 141 × 187 × 33 mm
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
kw     = 12  + 2*tol;          // 14  mm — knife slot width  (Y)
kSlotY = kw + 2;               // 16  mm — Y footprint w/ wiggle

jw      = 42 + tol;            // 43 mm — jar slot edge
jar_gap = 12;                  //         gap between the two jars

/* ── Dock pocket ─────────────────────────────────────── */
dock_d   = 114 + 2*tol;        // 116 mm — pocket diameter
saddle_h = 34;                 //  34 mm — top of dock's saddle dip
ez_dock  = flr + saddle_h - 4; //  33 mm — wall top, 4 mm under the dip

cable_w  = 60;                 // 60 mm — cable cutout width
cable_h  = 25;                 // 25 mm — cable cutout height
                                //         (clears USB-A + USB-C row)

/* ── Layout ──────────────────────────────────────────── */
ix     = kl;                   // 135 mm — interior X drive
ex     = ix + 2*wall;          // 141 mm — exterior X

// Y layout (front → back):
//   wall(3)              outer front wall
//   jw(43)               jar section
//   wall(3)              divider between jars and knife
//   kSlotY(16)           knife slot
//   wall(3)              divider between knife and dock pocket
//   dock_d(116)          dock pocket
//   wall(3)              outer back wall
ey_a = wall + jw + wall + kSlotY;   //  65 mm — base of dock riser
ey_b = wall + dock_d + wall;        // 122 mm — dock-section depth
ey   = ey_a + ey_b;                 // 187 mm — exterior Y

// Jar X positions (matches puffco_knife_jar_tray layout)
jarsW = 2*jw + jar_gap;        // 98 mm
jMarX = (ix - jarsW) / 2;      // 18.5 mm side margin
j1x   = wall + jMarX;
j2x   = j1x + jw + jar_gap;

jSecY = wall;                  // jars start
ky0   = wall + jw + wall;      // knife slot start

// Dock pocket centre (3 mm clearance to the divider + back walls)
dock_cx = ex / 2;
dock_cy = ey_a + wall + dock_d / 2;

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
        // Low full-footprint base — knife/jar pockets live here
        rbox(ex, ey, ez_a, r = 3);

        // Rear riser — extra wall height around the dock pocket
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

        // Knife slot — rear of front section, full interior X
        translate([wall, ky0, flr])
            rpocket(ix, kSlotY, id + 1, r = 2);

        // Dock pocket — circular well inside the rear riser
        translate([dock_cx, dock_cy, flr])
            cylinder(d = dock_d, h = ez_dock - flr + 1);

        // Cable cutout — through the rear wall, centred on dock
        translate([dock_cx - cable_w/2, ey - wall - 1, flr])
            cube([cable_w, wall + 2, cable_h]);
    }
}

/* ── Render ──────────────────────────────────────────── */
tray();

/* ── Summary ─────────────────────────────────────────── */
echo(str("Exterior      : ", ex, " × ", ey, " × ", ez_dock, " mm"));
echo(str("Front section : ", ex, " × ", ey_a, " × ", ez_a, " mm"));
echo(str("Dock pocket   : ", dock_d, " mm dia × ", ez_dock - flr, " mm deep"));
echo(str("Cable cutout  : ", cable_w, " × ", cable_h, " mm, centred on dock"));
