// Rail grid alignment system for 3 M4 Mac minis on a UniFi rack shelf.
//
// Two long rails span front and rear. Four flat dividers slot into notches
// cut into the long rail lips, one at each slot boundary (outer edges + gaps
// between minis). The notch locks each divider against side-to-side movement;
// the long rails constrain it fore-aft. Once minis are seated from above, the
// assembly is fully captured.
//
// Parts (see build variants):
//   long_rail — print 2  (front + rear; rear rotates 180° around Z at install)
//   divider   — print n_minis + 1 = 4  (two outer ends + two inner gaps)
//
// Assembly order:
//   1. Place both long rails.
//   2. Drop dividers into the notches from above.
//   3. Slide minis in from the top.
//
// Material: PETG recommended. Print: flat side down, no supports.

use <mac_mini.scad>

/* [Mac mini dimensions — keep in sync with mac_mini.scad] */
mini_w = 127;
mini_d = 127;
mini_h = 50;

/* [Fit] */
clearance = 0.5;  // gap around each mini (mm)
n_minis   = 3;

/* [Rail geometry] */
wall_t    = 3;    // wall/lip thickness (mm)
lip_h     = 14;   // lip height
base_w    = 8;    // base flange width
base_t    = 2;    // base flange thickness
notch_d   = 5;    // notch depth from top of lip — locks divider in place
notch_fit = 0.2;  // extra width clearance for easy insertion

/* [Build] */
part = "long_rail";  // [long_rail, divider]

/* [Preview] */
show_minis = false;

$fn = 64;

// — derived —————————————————————————————————————————————————
slot_w   = mini_w + 2 * clearance;
// Rail alternates: wall_t | slot_w | wall_t | slot_w | wall_t | slot_w | wall_t
long_len = n_minis * slot_w + (n_minis + 1) * wall_t;
// Divider length spans between the two long rail lip inner faces
div_len  = mini_d + 2 * clearance;

// ————————————————————————————————————————————————————————————
// long_rail()
// L-profile with notches cut at each divider position.
// Notch i is at x = i * (slot_w + wall_t), i = 0 .. n_minis.
// ————————————————————————————————————————————————————————————
module long_rail() {
    difference() {
        union() {
            // Base flange
            cube([long_len, base_w + wall_t, base_t]);
            // Lip — inner face at y = base_w + wall_t
            translate([0, base_w, 0])
                cube([long_len, wall_t, lip_h]);
        }
        // Notches — open at top, cut through full lip depth (y)
        for (i = [0:n_minis]) {
            nx = i * (slot_w + wall_t);
            translate([nx - notch_fit/2, base_w - 0.01, lip_h - notch_d])
                cube([wall_t + notch_fit, wall_t + 0.02, notch_d + 0.01]);
        }
    }
}

// ————————————————————————————————————————————————————————————
// divider()
// Flat wall that drops into long rail notches from above.
// Top notch_d mm of the wall keys into the long rail lip; the rest
// hangs to the shelf below. Base flange keeps it self-standing during assembly.
// Print 4 (= n_minis + 1). Lay flat: base flange down. No supports.
// ————————————————————————————————————————————————————————————
module divider() {
    div_flange = 4;  // base flange extension each side of wall
    union() {
        // Vertical wall
        cube([wall_t, div_len, lip_h]);
        // Base flange for self-standing stability before minis are loaded
        translate([-div_flange, 0, 0])
            cube([wall_t + 2 * div_flange, div_len, base_t]);
    }
}

if (part == "long_rail") long_rail();
if (part == "divider")   divider();

if (show_minis) {
    // Ghost minis
    for (i = [0:n_minis-1]) {
        translate([wall_t + clearance + i * (slot_w + wall_t),
                   base_w + wall_t + clearance,
                   base_t])
            %mac_mini();
    }
    // Ghost dividers in their notch positions
    for (i = [0:n_minis]) {
        translate([i * (slot_w + wall_t), base_w + wall_t, 0])
            %divider();
    }
}
