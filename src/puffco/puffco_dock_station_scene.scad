/* =====================================================
   Puffco Peak dock station — assembly scene
   =====================================================
   Hero: the loaded tray with the cloche lid lifted off
   above it, so the tall dock tower reads against the low
   cover. Item stand-ins (jars, knife, bucket, a docked
   Peak) show how it all packs. PNG only — see is_scene().
   ===================================================== */

use <puffco_dock_station.scad>

/* mirror the constants we need for placement */
flr        = 3;
ex         = 250;
ey         = 195;
back_h     = 35;
dock_cx    = 61;
bucket_cx  = 185;
circ_cy    = 130;
dock_depth = 32;
jw         = 43;
jar_h      = 24;
j1x        = 76;
j2x        = 131;
jSecY      = 3;
kx0        = 57.5;
ky0        = 49;
kl         = 135;
bucket_h   = 40;
wall       = 3;
lid_gap    = 0.4;

/* ── Tray + contents ─────────────────────────────────── */
color("#9aa0a6") make_tray();

// Two jars (sit in the front pockets, protrude above the rim)
color("#caa15a")
    for (jx = [j1x, j2x])
        translate([jx + 0.5, jSecY + 0.5, flr])
            cube([jw - 1, jw - 1, jar_h]);

// Hot knife (front, behind the jars)
color("#b0b4b8")
    translate([kx0 + 1, ky0 + 2, flr]) cube([133, 12, 12]);

// q-tip bucket (short tub in the back-right well)
color("#e8e4dc")
    translate([bucket_cx, circ_cy, flr]) cylinder(d = 120, h = bucket_h);

// Peak Pro stand-in, standing on the dock (back-left)
color("#3a3f44")
    translate([dock_cx, circ_cy, flr]) {
        cylinder(d = 100, h = 8);                       // dock puck
        translate([0, 0, 8]) cylinder(d1 = 96, d2 = 70, h = 150);  // body
        translate([0, 0, 158]) cylinder(d = 52, h = 17);           // carb cap
    }

/* ── Lid lifted off, above ───────────────────────────── */
color("#c4c8cc")
    translate([-(wall + lid_gap), -(wall + lid_gap), 150])
        make_lid();

/* ── Camera — three-quarter from front-above ─────────── */
$vpt = [ex/2, ey/2, 185];
$vpr = [68, 0, 25];
$vpd = 1250;
