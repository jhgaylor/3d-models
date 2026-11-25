/* =====================================================
   Compute bay kit — scene: the whole rack, reorganized
   =====================================================
   Visual-only hero of the cooling plan, with the fan lid
   lifted off so the bay shows:
     - compute bay: M8, two Mac minis on the riser and one
       more in front; A9 Mega and MS-A2 behind, with an air
       channel between the rows; fins between the front-row
       devices; cable clips on the side ledges,
     - the brick caddy with the bricks and the HDHomeRun in
       the bottom 2U at the back,
     - the UDM Pro and the Pro Max 16 PoE at the front, the
       power strip and the AC Infinity exhaust at the back.
   Simplified rack. PNG only — see build.py is_scene().

   Frame: X across (centred), Y from the front of the rack
   to the back, Z up from the bottom slot's ledge top.
   ===================================================== */

include <compute_bay_kit.scad>
use <rack_brick_caddy.scad>
use <rack_fan_lid.scad>
part = "none";

rack_d   = 459.7;
slot     = 48;
shelf_z  = 3 * slot + 3;     // shelf floor: the bay's bottom ledge + the shelf sheet
top_z    = 6 * slot;         // top frame: the lid sits here
lift     = 300;              // the lid, lifted off

frame_c  = "#b9bdc2";
teal     = "#2ab3c0";
silver   = "#c9ccd1";
black    = "#1d1e21";

// ── rack: posts, top and bottom frames, ledges ──
color(frame_c) {
    for (sx = [-1, 1], y = [0, rack_d - 20]) translate([sx > 0 ? 222.2 : -242.2, y, -40]) cube([20, 20, top_z + 40]);
    for (z = [-40, top_z - 3]) difference() {
        translate([-249.6, 0, z]) cube([499.2, rack_d, 3]);
        translate([-209.7, 30, z - 1]) cube([419.4, rack_d - 60, 5]);
    }
    for (sx = [-1, 1], k = [0 : 5]) mirror([sx < 0 ? 1 : 0, 0, 0])
        translate([202.5, 11, k * slot - 1.65]) cube([19.7, rack_d - 22, 1.65]);
}
// the shelf
color("#a7abb0") translate([-226.9, 0, shelf_z - 3]) cube([453.8, rack_d, 3]);

// ── front gear and back gear in the bottom 3U ──
color(silver) translate([-162.5, 0, slot]) cube([325, 160, 43.7]);             // Pro Max 16 PoE
color(teal)   translate([-221.2, 0, slot]) cube([58, 120, 43.7]);              // its blue box + brick
color(silver) translate([-221.2, 0, 2 * slot]) cube([442.4, 285.6, 43.7]);     // UDM Pro
color(black)  translate([-221.2, rack_d - 190, 2 * slot]) cube([442.4, 190, 43.7]);  // power strip
color(teal)   translate([-221.2, 0, 0]) cube([442.4, 4, 43.7]);                // OCD blank, U1 front

// ── brick caddy, bricks and HDHomeRun, from the back ──
translate([0, rack_d, 0]) mirror([0, 1, 0]) {
    color(teal) { half(-1); half(1); }
    contents();
}

// ── compute bay ──
translate([0, 3, shelf_z]) {
    // front row
    color(black)  translate([m8_x - m8[0] / 2, row_y, 0]) cube(m8);
    for (z = [0, upper_z]) color(silver) translate([stack_x - mini[0] / 2, row_y, z]) cube(mini);
    color(silver) translate([mini_x - mini[0] / 2, row_y, 0]) cube(mini);
    // back row
    color(silver) translate([a9_x - a9[0] / 2, back_y, 0]) cube(a9);
    color(black)  translate([msa2_x - msa2[0] / 2, back_y, 0]) cube(msa2);
    // kit
    color(teal) { at_fins() fin(); riser_in_place(); }
    // cable clips on the first ledge above the shelf, both sides
    color(teal) for (sx = [-1, 1], y = [60, 200, 340]) mirror([sx < 0 ? 1 : 0, 0, 0])
        multmatrix([[1, 0, 0, 202.5], [0, 0, 1, y], [0, 1, 0, slot - 3], [0, 0, 0, 1]]) clip();
}
// teal OCD panels on the bay front, and the AC Infinity at its back
color(teal)  translate([-221.2, -4, 3 * slot]) cube([442.4, 4, 3 * slot - 4]);
color(black) translate([-241.3, rack_d - 38, 4 * slot + 4]) cube([482.6, 38, 88.9]);

// ── fan lid, lifted ──
translate([0, rack_d / 2, top_z + lift]) {
    color("#e8742a") plate();
    for (sx = [-1, 1], sy = [-1, 1]) color("#222")
        translate([sx * 419.4 / 4 - 60, sy * 399 / 4 - 60, -15]) cube([120, 120, 15]);
}

$vpt = [0, 230, 230];
$vpr = [46, 0, 28];
$vpd = 2100;
