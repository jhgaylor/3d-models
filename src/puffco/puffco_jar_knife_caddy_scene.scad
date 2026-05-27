/* =====================================================
   Puffco Jar + Knife Caddy — assembly scene
   =====================================================
   Visual-only hero: lid flipped open on its rear hinge,
   drawer pulled out the front. PNG only — see build.py
   is_scene().
   ===================================================== */

use <puffco_jar_knife_caddy.scad>

// Constants mirrored from the model (kept in sync by hand).
ex           = 141;
ey           = 68;
base_h       = 35;
lid_h        = 23;
hinge_axis_y = ey + 1.5;
hinge_axis_z = base_h;

// Swing the lid about its rear hinge axis (negative = open).
module open_lid(ang) {
    translate([0, hinge_axis_y, hinge_axis_z])
        rotate([ang, 0, 0])
            translate([0, -hinge_axis_y, -hinge_axis_z])
                children();
}

color("#9aa0a6") make_carcass();
color("#b0b6bb") make_deck();
// Drawer pulled out the front
color("#7e57c2") translate([0, -34, 0]) make_drawer();
// Lid flipped open ~105°
color("#c4c8cc") open_lid(-105) make_lid();

// Camera — three-quarter view from front-above
$vpt = [ex/2, ey/2, base_h/2];
$vpr = [66, 0, 28];
$vpd = 540;
