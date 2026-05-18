// Per-column rear unit: drive tray + cable comb + rear channel segment.
//
// One of these sits directly behind each Mac mini cradle on the UniFi
// UACC-Rack-Shelf-TL. The three units butt together side-by-side; their
// rear channels form a continuous trough across the back of the shelf.
//
// Layout (looking down, mini's port-side at top):
//
//     ┌──────────────────────────────┐  ← front, faces mini cradle
//     │   ░ corner    corner ░       │
//     │      ┌──────────────┐        │
//     │      │              │        │  ← drive sits in this pocket
//     │      │   NVMe enc   │        │     (open on top, registered
//     │      │  100×50×12mm │        │      by 4 corner posts)
//     │      │              │        │
//     │      └──────────────┘        │
//     │   ░ corner    corner ░       │
//     ├──╨╨╨──╨╨╨──╨╨╨──╨╨╨──────────┤  ← slotted comb wall (3 slots)
//     │                              │
//     │       rear channel           │  ← open trough, butts to neighbors
//     │       (open ends butt-join)  │     across all 3 columns
//     │                              │
//     └──────────────────────────────┘  ← rear, cables drape off back edge
//
// Cable paths: power + ethernet exit mini, route alongside the drive
// (~35mm gap on each side), pass through slots in the comb wall, drop
// into the channel, exit out either open end to the rack's cable path.
// USB cable from mini's rear Thunderbolt loops short to the drive.

use <mac_mini.scad>

/* [Cradle width — keep in sync with mac_mini_cradle.scad] */
mini_w        = 127;
mini_d        = 127;
clearance     = 0.5;
wall_thickness = 3;

/* [Drive (compact NVMe enclosure)] */
drive_w = 50;      // width  (x-axis)
drive_l = 100;     // length (y-axis, USB-C port faces front)
drive_h = 12;      // height
drive_pocket_clearance = 1.0;

/* [Unit dimensions] */
front_margin    = 8;    // drive tray front margin
between_margin  = 5;    // gap between drive rear and slot wall
channel_depth   = 55;   // depth of rear channel section
floor_thickness = 2;
side_wall_height = 17;
slot_wall_thickness = 3;
slot_wall_height = 30;
back_wall_height = 17;

/* [Drive registration posts] */
post_size = 5;
post_height = 8;

/* [Cable comb] */
slot_count = 3;
slot_width = 7;
slot_depth = 18;     // from top of wall down

$fn = 64;

// Outer width matches the cradle so the units stack tidily
unit_w = mini_w + 2*(clearance + wall_thickness);

// Drive pocket origin (front-left corner of the drive itself)
drive_x = (unit_w - drive_w) / 2;
drive_y = front_margin;

// Slotted comb wall is positioned just behind the drive
slot_wall_y = drive_y + drive_l + between_margin;
unit_d = slot_wall_y + slot_wall_thickness + channel_depth;

module mac_mini_rear() {
    difference() {
        union() {
            _shell();
            _drive_corner_posts();
        }
        _slot_cutouts();
    }
}

module _shell() {
    // Floor plate
    cube([unit_w, unit_d, floor_thickness]);

    // Outer side walls (full depth)
    cube([wall_thickness, unit_d, floor_thickness + side_wall_height]);
    translate([unit_w - wall_thickness, 0, 0])
        cube([wall_thickness, unit_d, floor_thickness + side_wall_height]);

    // Slotted comb wall (slots cut later in _slot_cutouts)
    translate([0, slot_wall_y, 0])
        cube([unit_w, slot_wall_thickness, floor_thickness + slot_wall_height]);

    // Back wall (rear of channel)
    translate([0, unit_d - wall_thickness, 0])
        cube([unit_w, wall_thickness, floor_thickness + back_wall_height]);
}

module _drive_corner_posts() {
    // Four posts that register the drive's position. Drive drops in
    // from above and is bracketed by the posts; bus-powered NVMe
    // enclosures are light enough that this is plenty of retention.
    px = drive_pocket_clearance;
    for (xs = [drive_x - post_size - px, drive_x + drive_w + px])
        for (ys = [drive_y - post_size - px, drive_y + drive_l + px])
            translate([xs, ys, floor_thickness])
                cube([post_size, post_size, post_height]);
}

module _slot_cutouts() {
    // Evenly distributed slots cut from the top of the comb wall.
    span = unit_w - 2*wall_thickness;
    pitch = span / slot_count;
    for (i = [0 : slot_count - 1]) {
        cx = wall_thickness + pitch*(i + 0.5);
        translate([cx - slot_width/2,
                  slot_wall_y - 0.01,
                  floor_thickness + slot_wall_height - slot_depth])
            _slot_shape();
    }
}

module _slot_shape() {
    // Rectangle topped by a rounded bottom (hull of a rectangle and
    // a half-circle inverted — keyhole bottom is friendlier on cables).
    hull() {
        cube([slot_width, slot_wall_thickness + 0.02, slot_depth - slot_width/2]);
        translate([slot_width/2, 0, slot_depth - slot_width/2])
            rotate([-90, 0, 0])
                cylinder(h = slot_wall_thickness + 0.02, r = slot_width/2);
    }
}

mac_mini_rear();
