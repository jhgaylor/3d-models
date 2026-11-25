/* =====================================================
   Rack fan lid — scene
   =====================================================
   Visual-only hero: the wood-grain halftone lid on the
   rack's top frame (simplified rails and handles), the
   four fans and their clips underneath. PNG only — see build.py
   is_scene().
   ===================================================== */

include <rack_fan_lid.scad>
part = "none";

rail_c = "#b9bdc2";   // the rack is brushed aluminium
lid_c  = "#e8742a";   // orange; "#2f7fd0" for blue. Not navy: the holes vanish
frame_t = 2;
bar_z  = 31;        // handle bar centre above the rail top

color(rail_c) translate([0, 0, -frame_t]) linear_extrude(frame_t) difference() {
    square([top_w, top_d], center = true);
    square([open_w, open_d], center = true);
}
color(rail_c) translate([0, 0, -40]) linear_extrude(38) difference() {
    square([top_w, top_d], center = true);
    square([top_w - 4, top_d - 4], center = true);
}

// the gear inside: dark, so the holes read dark, as they do on the rack
color("#1c1d20") translate([0, 0, -39]) cube([top_w - 6, top_d - 6, 2], center = true);

color("#c8cbcf") for (s = [-1, 1]) translate([0, s * handle_y, 0]) {
    for (x = [-handle_x, handle_x]) translate([x, 0, 0]) cylinder(d = leg_d, h = bar_z);
    translate([-handle_x, 0, bar_z]) rotate([0, 90, 0]) cylinder(d = leg_d, h = 2 * handle_x);
    for (x = [-handle_x, handle_x]) translate([x, 0, bar_z]) sphere(d = leg_d);
}

// P12 Slim: frame, hub and blades, enough to read through the grille
module fan() {
    color("#2b2b2b") translate([0, 0, -fan_t]) difference() {
        translate([-fan_w / 2, -fan_w / 2, 0]) cube([fan_w, fan_w, fan_t]);
        translate([0, 0, -1]) cylinder(r = 58, h = fan_t + 2, $fn = 96);
    }
    color("#3a3a3a") translate([0, 0, -fan_t + 2]) cylinder(r = 20, h = fan_t - 3);
    color("#444") for (i = [0 : 8]) rotate(i * 40)
        translate([0, 0, -fan_t / 2 - 1]) rotate([0, 0, 0])
            linear_extrude(3, twist = -25) translate([19, -6]) square([37, 12]);
}

for (c = fan_at) translate([c[0], c[1], 0]) fan();
color("#3a3a3a") at_clips() clip();
color(lid_c) plate();

$vpt = [0, 10, -10];
$vpr = [52, 0, 18];
$vpd = 1150;
