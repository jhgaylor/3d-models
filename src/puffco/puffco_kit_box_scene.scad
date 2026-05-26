/* =====================================================
   Puffco kit box — assembly scene
   =====================================================
   Hero: the full-kit carry box opened up. Left door
   folded back against the side, right door ajar, the
   knife/jar caddy seated on its dovetails at the rear,
   and the roof lifted off above to show the handle.
   PNG only — see build.py is_scene().
   ===================================================== */

use <puffco_kit_box.scad>

ew           = 256;
ed           = 206;
wall_h       = 218;
wall         = 3;
door_th      = 4;
hinge_off    = 5;
hinge_axis_x = -hinge_off;
hinge_axis_y = -door_th/2;

module swing_left(ang) {
    translate([hinge_axis_x, hinge_axis_y, 0])
        rotate([0, 0, ang])
            translate([-hinge_axis_x, -hinge_axis_y, 0])
                children();
}

color("#9aa0a6") cab_body();
color("#8d6e63") cab_caddy();                       // seated on its dovetails

// Roof lifted off above, to show the handle
color("#c4c8cc") translate([0, 0, wall_h + 70]) cab_roof();

// Left door folded back ~250°, right door ajar ~105°
color("#7e57c2") swing_left(-250) cab_door();
color("#7e57c2")
    translate([ew, 0, 0]) mirror([1, 0, 0])
        swing_left(-105) cab_door();

// Camera — three-quarter from front-above
$vpt = [ew/2, ed/2, wall_h/2];
$vpr = [66, 0, 27];
$vpd = 900;
