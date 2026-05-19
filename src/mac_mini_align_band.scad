// Two-piece perimeter band for 3 M4 Mac minis on a UniFi rack shelf.
//
// front_bar: U-shaped piece — registers the front face of all three minis
//            and wraps around both outer sides for the full depth. Think of it
//            as a three-sided frame. Slide minis in from the top.
// rear_bar:  Straight bar — registers the rear face only. Slide it in last
//            (from the top or front) once the minis are seated in the front_bar.
//
// Together the two pieces form a closed rectangular perimeter. No fasteners —
// the weight of the minis holds everything in place on the rack shelf.
//
// Parts (see build variants):
//   front_bar — print 1
//   rear_bar  — print 1  (also usable as a standalone front/rear rail)
//
// Material: PETG recommended. Print: flat side down, no supports.
// Note: front_bar is ~400mm long; ensure your bed fits it in one piece,
// or split it along the centreline and glue.

use <mac_mini.scad>

/* [Mac mini dimensions — keep in sync with mac_mini.scad] */
mini_w = 127;
mini_d = 127;
mini_h = 50;

/* [Fit] */
clearance = 0.5;  // gap around each mini (mm)
n_minis   = 3;

/* [Band geometry] */
wall_t = 3;   // wall/lip thickness (mm)
lip_h  = 14;  // lip height
base_w = 8;   // base flange width
base_t = 2;   // base flange thickness

/* [Build] */
part = "front_bar";  // [front_bar, rear_bar]

/* [Preview] */
show_minis = false;

$fn = 64;

// — derived —————————————————————————————————————————————————
slot_w      = mini_w + 2 * clearance;
band_len    = n_minis * slot_w + 2 * wall_t;    // full bar length
inner_depth = mini_d + 2 * clearance;           // distance between lip faces

// ————————————————————————————————————————————————————————————
// front_bar()
// U-shaped: front lip + two full-depth side walls.
// Origin: bottom-front-left.  +x = right,  +y = toward rear,  +z = up.
// Lip inner face at y = base_w + wall_t.
// Side cap inner faces at x = wall_t (left) and x = band_len - wall_t (right).
// ————————————————————————————————————————————————————————————
module front_bar() {
    union() {
        // Base flange under front lip
        cube([band_len, base_w + wall_t, base_t]);

        // Front lip
        translate([0, base_w, 0])
            cube([band_len, wall_t, lip_h]);

        // Left side cap — full depth, closes off left outer mini
        translate([0, base_w + wall_t, 0])
            cube([wall_t, inner_depth + wall_t, lip_h]);

        // Right side cap
        translate([band_len - wall_t, base_w + wall_t, 0])
            cube([wall_t, inner_depth + wall_t, lip_h]);
    }
}

// ————————————————————————————————————————————————————————————
// rear_bar()
// Straight L-profile — just the rear lip, no side caps.
// Slides in from the top (or front) after minis are seated in the front_bar.
// Rotate 180° around Z at install so its base extends toward the rack rear.
// ————————————————————————————————————————————————————————————
module rear_bar() {
    union() {
        // Base flange
        cube([band_len, base_w + wall_t, base_t]);
        // Lip
        translate([0, base_w, 0])
            cube([band_len, wall_t, lip_h]);
    }
}

if (part == "front_bar") front_bar();
if (part == "rear_bar")  rear_bar();

if (show_minis) {
    for (i = [0:n_minis-1]) {
        translate([wall_t + clearance + i * slot_w,
                   base_w + wall_t + clearance,
                   base_t])
            %mac_mini();
    }
}
