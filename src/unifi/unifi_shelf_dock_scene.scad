/* =====================================================
   UniFi Shelf Docks — layout scene
   =====================================================
   Visual-only hero: the fixed Toolless Mini Rack Shelf
   with its perforated field, the docks and corner guides,
   and stand-in blocks for the machines. Front row: power
   bricks, 3 Mac minis and a NucBox M8 on edge. Back row:
   the A9 Mega and MS-A2 lying flat, exhausting out the
   back. PNG only — see build.py is_scene().
   ===================================================== */

include <unifi_shelf_dock.scad>
part = "none";

/* ── Shelf (UACC-Rack-Shelf-TL) ─────────────────────── */
shelf_w = 453.8;
shelf_d = 460;
field   = [[-191, 74], [191, 392]];    // perforated area, y back from the front edge

// shelf-frame Y = back from the shelf's front edge
module shelf() {
    color("#9aa0a6") translate([-shelf_w / 2, 0, -1.5]) cube([shelf_w, shelf_d, 1.5]);
    color("#6f757b") translate([field[0][0] - 2, field[0][1] - 2, -1.49])
        cube([field[1][0] - field[0][0] + 4, field[1][1] - field[0][1] + 4, 1.5]);
    // oblong cutouts
    color("#2b2f33") for (x = [-139.6, 139.6], y = [39.2, 415.3])
        translate([x, y, -1.48]) hull() for (s = [-1, 1])
            translate([s * 15, 0, 0]) cylinder(d = 29, h = 1.5);
}

function in_field(x, y) = x > field[0][0] && x < field[1][0] && y > field[0][1] && y < field[1][1];

/* ── Stand-in machines ──────────────────────────────── */
module box(size, r = 6, c = "#c9ccd0") {
    color(c) hull() for (x = [r, size[0] - r], y = [r, size[1] - r])
        translate([x, y, 0]) cylinder(r = r, h = size[2]);
}

dock_c = "#2f7de1";
front_y = 15;
gap_y   = 260;   // back row front edge

// Dock placed with its left outer face at x, front of device at y.
module place_dock(x, y, s, w, d, dd, back) {
    let($slots = s, $slot_w = w, $dev_d = d, $div_t = dd, $back_keep = back,
        $fin_h = s == 1 ? 35 : 40) {
        translate([x, y, 0]) color(dock_c) dock();
        for (px = dock_pin_xs())
            echo(str("pin ", px + x, ", ", dock_pin_y() + y,
                     in_field(px + x, dock_pin_y() + y) ? "  in field" : "  OUTSIDE FIELD"));
    }
}

// bricks
bx = -205;
place_dock(bx, front_y, 3, 33, 200, 4, 8);
for (i = [0 : 2]) translate([bx + 3 + 1.5 + i * 37, front_y, 3]) box([30, 200, 80], 4, "#3a3d41");

// Mac minis
mx = -65;
place_dock(mx, front_y, 3, 51, 127, 6, 28);
for (i = [0 : 2]) translate([mx + 3 + 0.5 + i * 57, front_y, 3]) box([50, 127, 127], 10, "#d6d8db");

// NucBox M8
nx = 133;
place_dock(nx, front_y, 1, 66.5, 110, 4, 8);
translate([nx + 3 + 0.75, front_y, 3]) box([65, 110, 110], 8, "#4a4d52");

// back row, lying flat, front corners in corner guides
a9 = [-190.5, 171, 171, 71];     // x, w, d, h
ms = [-5.5, 196, 189, 48];
for (m = [a9, ms]) {
    translate([m[0], gap_y, 0]) {
        color(dock_c) {
            translate([-1, -1, 0]) corner();
            translate([m[1] + 1, -1, 0]) mirror([1, 0, 0]) corner();
        }
        box([m[1], m[2], m[3]], 8, "#55595e");
    }
    for (s = [0, 1], p = corner_pin_at) {
        px = m[0] + (s == 0 ? -1 + p : m[1] + 1 - p);
        py = gap_y - 1 - wall_t - flange_w / 2;
        echo(str("corner pin ", px, ", ", py, in_field(px, py) ? "  in field" : "  OUTSIDE FIELD"));
    }
}

shelf();

$vpt = [0, 230, 40];
$vpr = [55, 0, 20];
$vpd = 1250;
