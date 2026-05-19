// Single Mac mini cradle for the UniFi Toolless Rack Shelf
// (UACC-Rack-Shelf-TL, 453.8mm usable width). Print one per mini.
//
// Three cradles butt up side-by-side on the shelf with ~18mm of slack
// at each outer edge. No joinery — gravity, the rack rails, and the
// weight of the minis themselves keep everything aligned.
//
// Orient each mini with the port face toward the REAR of the rack.
// Cables drape over the low rear wall.
//
// Material: PETG recommended. PLA softens around 60°C and Mac mini
// bottoms can sit in the 50-55°C range under sustained load.
//
// Print: floor down on the bed. No supports needed (front/rear walls
// are short; side walls have no overhangs). 3 perimeters, 20% infill.

use <mac_mini.scad>

/* [Mac mini dimensions — keep in sync with mac_mini.scad] */
mini_w = 127;
mini_d = 127;
mini_h = 50;

/* [Cradle fit] */
clearance       = 0.5;   // gap between mini and pocket walls (mm)
wall_thickness  = 3;
floor_thickness = 2;
floor_flange    = 3;     // perimeter floor rim width; central area is open vent

/* [Wall heights — measured from top of floor plate] */
side_wall_height  = 30;  // tall, main lateral retention
front_wall_height = 12;  // low, keeps mini's front face / LED visible
rear_wall_height  = 12;  // low, cables drape over

$fn = 64;

module mac_mini_cradle() {
    pw = mini_w + 2*clearance;
    pd = mini_d + 2*clearance;
    ow = pw + 2*wall_thickness;
    od = pd + 2*wall_thickness;

    difference() {
        union() {
            // Floor plate
            cube([ow, od, floor_thickness]);

            // Side walls (left, right)
            cube([wall_thickness, od, floor_thickness + side_wall_height]);
            translate([ow - wall_thickness, 0, 0])
                cube([wall_thickness, od, floor_thickness + side_wall_height]);

            // Front wall (low)
            cube([ow, wall_thickness, floor_thickness + front_wall_height]);

            // Rear wall (low)
            translate([0, od - wall_thickness, 0])
                cube([ow, wall_thickness, floor_thickness + rear_wall_height]);
        }

        // Mini-shaped pocket cut from the wall mass
        translate([wall_thickness, wall_thickness, floor_thickness])
            mac_mini_cutout(clearance);

        // Central airflow opening in the floor (mini's bottom intake)
        translate([wall_thickness + floor_flange,
                  wall_thickness + floor_flange,
                  -0.5])
            cube([pw - 2*floor_flange,
                  pd - 2*floor_flange,
                  floor_thickness + 1]);
    }
}

mac_mini_cradle();
