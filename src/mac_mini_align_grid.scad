// Rail grid alignment system for 3 M4 Mac minis on a UniFi rack shelf.
//
// Two long rails span the full width of all three minis (front and rear).
// Six short rails run fore-aft, two per mini, defining each mini's lateral slot.
// Adjacent minis share the gap between them — place two short rails back-to-back
// in that gap (base faces touching). The outer short rails sit at the rack edges.
//
// Parts (see build variants):
//   long_rail  — print 2  (one front, one rear; rear rotates 180° around Z)
//   short_rail — print 6  (two per mini: one per side; inner pairs sit back-to-back)
//
// Assembly order:
//   1. Place both long rails at front and rear of the mini group.
//   2. Drop short rails into the gaps between (and outside) the minis.
//   3. Slide minis into their slots from the top.
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
wall_t = 3;   // wall/lip thickness (mm)
lip_h  = 14;  // lip height
base_w = 8;   // base flange width
base_t = 2;   // base flange thickness

/* [Build] */
part = "long_rail";  // [long_rail, short_rail]

/* [Preview] */
show_minis = false;

$fn = 64;

// — derived —————————————————————————————————————————————————
slot_w     = mini_w + 2 * clearance;
long_len   = n_minis * slot_w + 2 * wall_t;  // full span incl. outer walls
short_len  = mini_d + 2 * clearance;         // fits between long rail lip faces

// ————————————————————————————————————————————————————————————
// long_rail()
// Simple L-profile spanning all three minis.
// Short rails handle outer lateral containment; no end caps needed here.
// ————————————————————————————————————————————————————————————
module long_rail() {
    union() {
        // Base flange
        cube([long_len, base_w + wall_t, base_t]);
        // Lip — inner face at y = base_w + wall_t
        translate([0, base_w, 0])
            cube([long_len, wall_t, lip_h]);
    }
}

// ————————————————————————————————————————————————————————————
// short_rail()
// L-profile oriented fore-aft. Base extends in +x, lip faces -x (toward mini).
// For the left side of a mini: rotate 180° around Z at install time.
// Inner pairs (between adjacent minis) sit base-to-base, taking up 2×wall_t.
// ————————————————————————————————————————————————————————————
module short_rail() {
    union() {
        // Base flange
        cube([base_w + wall_t, short_len, base_t]);
        // Lip — inner face at x = wall_t
        cube([wall_t, short_len, lip_h]);
    }
}

if (part == "long_rail")  long_rail();
if (part == "short_rail") short_rail();

if (show_minis) {
    for (i = [0:n_minis-1]) {
        translate([wall_t + clearance + i * slot_w,
                   base_w + wall_t + clearance,
                   base_t])
            %mac_mini();
    }
}
