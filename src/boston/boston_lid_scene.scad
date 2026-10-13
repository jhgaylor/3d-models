/* =====================================================
   Boston relief lid — scene
   =====================================================
   Visual-only hero: the lid seated on the top frame of
   the Toolless Mini Rack (simplified: the top rails and
   the two handles). PNG only — see build.py is_scene().
   ===================================================== */

include <boston_lid.scad>
part = "none";

rail_c = "#9aa0a6";
frame_t = 2;
open_w = 419.4;
open_d = 399.0;
bar_z  = 479;       // handle bar centre above the rail top (rack z 448)

// top frame, its top face at z = 0
color(rail_c) translate([0, 0, -frame_t]) linear_extrude(frame_t) difference() {
    square([top_w, top_d], center = true);
    square([open_w, open_d], center = true);
}
color(rail_c) translate([0, 0, -40]) linear_extrude(38) difference() {
    square([top_w, top_d], center = true);
    square([top_w - 4, top_d - 4], center = true);
}

// handles: two legs and a bar
color("#c8cbcf") for (s = [-1, 1]) translate([0, s * handle_y, 0]) {
    for (x = [-handle_x, handle_x]) translate([x, 0, 0]) cylinder(d = leg_d, h = bar_z - 448);
    translate([-handle_x, 0, bar_z - 448]) rotate([0, 90, 0]) cylinder(d = leg_d, h = 2 * handle_x);
    for (x = [-handle_x, handle_x]) translate([x, 0, bar_z - 448]) sphere(d = leg_d);
}

color("#d9d4c7") plate();
color("#4f6d8a") buildings();

$vpt = [0, 20, 0];
$vpr = [52, 0, 18];
$vpd = 1150;
