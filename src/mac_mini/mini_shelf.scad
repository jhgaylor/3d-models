// Layout preview of the full Mac mini shelf assembly on the UniFi
// UACC-Rack-Shelf-TL. Renders three cradles + three rear units
// (drive tray + comb + channel) with ghost minis and ghost drives
// for fit-checking.
//
// STL/3MF outputs contain the printable parts (cradles + rear units);
// the shelf, minis, and drives use % so they're excluded from export.

use <mac_mini.scad>
use <mac_mini_cradle.scad>
use <mac_mini_rear.scad>

/* [UniFi UACC-Rack-Shelf-TL] */
shelf_w = 453.8;
shelf_d = 460;
shelf_t = 2;

/* [Layout] */
mini_count = 3;
front_offset = 30;   // distance from shelf front to cradle front face
cradle_to_rear_gap = 5;

// Match the cradle defaults — keep in sync with mac_mini_cradle.scad
cradle_w = 127 + 2*(0.5 + 3);
cradle_d = cradle_w;  // square
cradle_floor = 2;

// Match mac_mini_rear.scad
rear_w = cradle_w;
rear_drive_w = 50;
rear_drive_l = 100;
rear_drive_x = (rear_w - rear_drive_w) / 2;
rear_drive_y = 8;

total_w  = mini_count * cradle_w;
margin_x = (shelf_w - total_w) / 2;

$fn = 64;

// Ghost shelf
%color("DimGray") translate([0, 0, -shelf_t])
    cube([shelf_w, shelf_d, shelf_t]);

for (i = [0 : mini_count - 1]) {
    translate([margin_x + i*cradle_w, 0, 0]) {
        // Cradle (printable)
        translate([0, front_offset, 0])
            mac_mini_cradle();

        // Ghost mini
        translate([3 + 0.5, front_offset + 3 + 0.5, cradle_floor])
            %mac_mini();

        // Rear unit (printable)
        translate([0, front_offset + cradle_d + cradle_to_rear_gap, 0])
            mac_mini_rear();

        // Ghost drive sitting in the rear unit's pocket
        translate([rear_drive_x,
                  front_offset + cradle_d + cradle_to_rear_gap + rear_drive_y,
                  cradle_floor])
            %color("DarkSlateGray") cube([50, 100, 12]);
    }
}
