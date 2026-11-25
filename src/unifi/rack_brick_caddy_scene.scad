/* =====================================================
   Rack brick caddy — scene
   =====================================================
   Visual-only hero: the caddy in the bottom 2U at the back
   of the rack, with the three bricks standing in it, the
   power strip in the slot above and the Pro Max 16 PoE at
   the front. Simplified rack (slats, ledges, posts). PNG
   only — see build.py is_scene().
   ===================================================== */

include <rack_brick_caddy.scad>
part = "none";

rack_c  = "#b9bdc2";
depth   = 450;          // usable depth, back post to front post

// slats and ledges, bottom three slots
color(rack_c) for (s = [-1, 1]) mirror([s < 0 ? 1 : 0, 0, 0]) {
    translate([slat_x, 0, -20]) cube([2, depth, 160]);
    for (k = [0 : 3]) translate([slat_x - ledge_in, ledge_front, k * 48 - 1.65])
        cube([ledge_in, depth - 2 * ledge_front, 1.65]);
    for (y = [0, depth - 20]) translate([slat_x - 18, y, -20]) cube([20, 20, 160]);
}

// Pro Max 16 PoE at the front (the power strip in the slot above is
// left out so the bricks show)
color("#d9dadc") translate([-162.5, depth - 160, 48]) cube([325, 160, 43.7]);

// the bricks and the HDHomeRun
contents();

color("#2ab3c0") { half(-1); half(1); }

$vpt = [0, 140, 30];
$vpr = [48, 0, 335];
$vpd = 900;
