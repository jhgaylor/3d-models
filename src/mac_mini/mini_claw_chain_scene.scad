// Assembly preview (not printable): three Mac minis in a row, linked by a
// plug → pass-through → socket dovetail chain. Renders to a PNG only —
// build.py skips STL/3MF for *_scene.scad files.
//
// Reuses the real claw geometry from mini_claw_dovetail.scad (SCENE=true
// suppresses that file's single-part render so we can place claws ourselves).

SCENE = true;
include <mini_claw_dovetail.scad>

$fa = 2;
$fs = 0.5;

// Detailed Mac mini M4 mesh (see vendor/ATTRIBUTION.md). The STL imports
// upside-down (vent ring + power button on the up-face) with its footprint
// centred at (125, 105). Recentre it on the origin, flip it upright (180°
// about Y), and lift so the flat top lands at macmini_top with the claws
// sitting squarely on it. The port face (2× USB-C + jack) stays on -Y,
// toward the camera.
macmini_top = 49.72;
mac_back_y  = -63.38;   // Y of the port (back) face after centering

// Mac body, upright and centred, sitting on Z=0. The STL imports
// upside-down with an off-origin footprint, so: recentre XY, flip upright
// (180° about Y), then lift the flipped body (which lands at Z<0) onto Z=0.
module mac_solid() {
    translate([0, 0, macmini_top])
        rotate([0, 180, 0])
            translate([-125, -105, 0])
                import("vendor/macmini_m4.stl", convexity = 10);
}

module mac() {
    color([0.80, 0.81, 0.84]) mac_solid();
    // Darken the port interiors: a thin slab hugging the back face, minus the
    // body. Flat areas are fully inside the body (subtracted away); only the
    // recessed port pockets survive, so they read as dark.
    color([0.05, 0.05, 0.07])
        difference() {
            // Kept within the flat central back panel — overrunning onto the
            // rounded side/top edges would leave dark blocks where the body
            // curves forward, away from the slab.
            translate([-37, mac_back_y + 0.4, 11]) cube([74, 4, 28]);
            mac_solid();
        }
}

chain = ["plug", "pass-through", "socket"];

for (i = [0 : len(chain) - 1])
    translate([i * chain_pitch, 0, 0]) {
        mac();
        color([0.93, 0.46, 0.13])
            translate([0, 0, macmini_top])
                claw(chain[i]);
    }

// Hero camera — look at the middle Mac, tilt down for a 3/4 view.
$vpt = [chain_pitch, 0, 18];
$vpr = [62, 0, 22];
$vpd = 760;
