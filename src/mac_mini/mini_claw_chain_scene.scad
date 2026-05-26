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

module mac() {
    color([0.26, 0.26, 0.29])
        translate([-mini_w/2, -mini_w/2, 0])
            cube([mini_w, mini_w, mini_h]);
}

chain = ["plug", "pass-through", "socket"];

for (i = [0 : len(chain) - 1])
    translate([i * chain_pitch, 0, 0]) {
        mac();
        color([0.93, 0.46, 0.13])
            translate([0, 0, mini_h])
                claw(chain[i]);
    }

// Hero camera — look at the middle Mac, tilt down for a 3/4 view.
$vpt = [chain_pitch, 0, 18];
$vpr = [62, 0, 22];
$vpd = 760;
