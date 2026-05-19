// Front/rear alignment rails for 3 M4 Mac minis on a UniFi rack shelf.
//
// Two identical L-profile rails — one at the front edge, one at the rear.
// Each rail registers all three minis fore-aft and, via end caps, prevents
// the outer minis from sliding sideways. The middle mini is held laterally
// by the two outer minis pressing against it.
//
// Print two copies. For the rear rail, rotate 180° around Z so the base
// extends toward the back of the rack and the lip still faces the minis.
//
// Material: PETG recommended (same reason as the cradles — heat soak).
// Print: flat side down, no supports needed.

use <mac_mini.scad>

/* [Mac mini dimensions — keep in sync with mac_mini.scad] */
mini_w = 127;  // x — left/right per mini
mini_d = 127;  // y — front/back
mini_h = 50;   // z — height

/* [Fit] */
clearance = 0.5;  // gap around each mini (mm)
n_minis   = 3;    // minis side by side

/* [Rail geometry] */
wall_t    = 3;   // wall/lip thickness (mm)
lip_h     = 14;  // lip height — enough to register against the mini face
base_w    = 8;   // base flange width, extends away from mini
base_t    = 2;   // base flange thickness
end_cap_d = 20;  // end cap depth alongside outer mini side

/* [Preview] */
show_minis = false;  // show ghost minis for layout verification (not printed)

$fn = 64;

// — derived —————————————————————————————————————————————————
slot_w   = mini_w + 2 * clearance;         // x-span per mini slot
rail_len = n_minis * slot_w + 2 * wall_t;  // total length incl. end cap walls

// ————————————————————————————————————————————————————————————
// alignment_rail()
//
// Origin: bottom-front-left corner of the base.
// +x = along rail length, +y = toward mini (base extends in -y from lip),
// +z = up.
//
// The lip's inner face (facing the mini) is at y = base_w + wall_t.
// Minis sit at x = wall_t + clearance + i*slot_w,  y = base_w + wall_t + clearance.
// ————————————————————————————————————————————————————————————
module alignment_rail() {
    union() {
        // Base flange — lies flat on shelf
        cube([rail_len, base_w + wall_t, base_t]);

        // Lip — registers against mini face
        translate([0, base_w, 0])
            cube([rail_len, wall_t, lip_h]);

        // Left end cap — catches left side of the first mini
        translate([0, base_w + wall_t, 0])
            cube([wall_t, end_cap_d, lip_h]);

        // Right end cap — catches right side of the last mini
        translate([rail_len - wall_t, base_w + wall_t, 0])
            cube([wall_t, end_cap_d, lip_h]);
    }
}

alignment_rail();

if (show_minis) {
    for (i = [0:n_minis-1]) {
        translate([wall_t + clearance + i * slot_w,
                   base_w + wall_t + clearance,
                   base_t])
            %mac_mini();
    }
}
