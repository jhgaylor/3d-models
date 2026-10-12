/* =====================================================
   UniFi OCD Panel — assembly scene
   =====================================================
   Visual-only hero: the front of a Toolless Mini Rack
   (simplified from Ubiquiti's model — posts, side slats,
   ledges and pins) filled with panels, one pulled half
   out so the flange slot and pin read. PNG only — see
   build.py is_scene().
   ===================================================== */

include <unifi_ocd_panel.scad>
part = "none";

/* ── Rack mock (measured; see unifi_ocd_panel.md) ───── */
post_y    = front_proud;          // post front, behind the panel face
slat_x    = 444.38 / 2;           // slat inner face
slat_t    = 2;
slat_h    = 24.3;                 // slat plate height above the ledge underside
ledge_x   = 202.5;                // ledge inner edge
post_in   = 229.2;                // post short-leg inner face
post_out  = 249.2;
rack_d    = 160;                  // how much depth to draw
slots     = 6;

module rack_side(s) {
    mirror([s < 0 ? 1 : 0, 0, 0]) {
        // corner post: C-channel opening backwards
        translate([post_in, post_y, -40]) {
            cube([post_out - post_in, 2, 352]);               // front face
            cube([2, 15, 352]);                               // short leg
            translate([post_out - post_in - 2, 0, 0]) cube([2, 30, 352]);
        }
        for (k = [0 : slots - 1]) translate([0, 0, k * slot_pitch]) {
            // slat
            translate([slat_x, post_y + 5, -ledge_t]) cube([slat_t, rack_d, slat_h]);
            // ledge
            translate([ledge_x, post_y + ledge_front, -ledge_t])
                cube([slat_x - ledge_x + slat_t, rack_d - ledge_front + 5, ledge_t]);
            // pin
            translate([slat_x - 4.54, post_y + pin_setback, pin_z])
                rotate([0, 90, 0]) cylinder(d = pin_d, h = 4.6);
        }
    }
}

color("#7d848b") for (s = [-1, 1]) rack_side(s);

/* ── Panels ─────────────────────────────────────────── */
// [slot, units, style, pulled-out distance]
fill = [
    [0, 1, "blank",       0],
    [1, 2, "vented",      0],
    [3, 1, "passthrough", 55],
    [4, 1, "blank",       0],
    [5, 1, "vented",      0],
];

for (f = fill)
    let($units = f[1], $style = f[2])
        color("#eceef0")
            translate([0, -f[3], f[0] * slot_pitch])
                for (i = [0 : pieces - 1]) panel_piece(i);

// Camera — three-quarter view from front-right, a little above
$vpt = [40, 60, 140];
$vpr = [68, 0, 28];
$vpd = 1400;
