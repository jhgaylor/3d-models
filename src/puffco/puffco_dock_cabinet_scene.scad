/* =====================================================
   Puffco Peak dock cabinet — assembly scene
   =====================================================
   Visual-only hero: the cabinet with its left door folded
   most of the way back (270° fold-back demonstrated) and
   the right door swung ajar so you can see inside.
   PNG only — see build.py is_scene().
   ===================================================== */

use <puffco_dock_cabinet.scad>

// Mirror of the constants we need to position things (kept in sync by hand).
ew           = 129;
ed           = 137;
wall_h       = 213;
wall         = 3;
door_th      = 4;
hinge_off    = 5;
hinge_axis_x = -hinge_off;
hinge_axis_y = -door_th/2;

// Swing a door about its vertical hinge axis. ang < 0 folds the left
// door back toward the side wall (toward 270°).
module swing_left(ang) {
    translate([hinge_axis_x, hinge_axis_y, 0])
        rotate([0, 0, ang])
            translate([-hinge_axis_x, -hinge_axis_y, 0])
                children();
}

color("#9aa0a6") cab_body();
color("#c4c8cc") translate([0, 0, wall_h]) cab_roof();

// Left door folded back ~250° against the side wall
color("#7e57c2") swing_left(-250) door_left();

// Right door (mirror of the left) swung ajar ~110°
color("#7e57c2")
    translate([ew, 0, 0]) mirror([1, 0, 0])
        swing_left(-110) door_left();

// Camera — three-quarter view from front-above
$vpt = [ew/2, ed/2, wall_h/2];
$vpr = [68, 0, 28];
$vpd = 720;
