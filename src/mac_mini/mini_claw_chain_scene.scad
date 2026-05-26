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

mini_vr = 10;     // vertical corner radius (the Mac's signature rounded sides)
mini_er = 2.5;    // top/bottom edge round

// Rounded-corner aluminium body, centred in XY, sitting on Z=0.
module mac_body() {
    translate([0, 0, mini_er])
        minkowski() {
            linear_extrude(mini_h - 2*mini_er)
                offset(r = mini_vr - mini_er)
                    square([mini_w - 2*mini_vr, mini_w - 2*mini_vr], center = true);
            sphere(r = mini_er, $fn = 20);
        }
}

// Vertical USB-C pill: width w × height h, recessed into the -Y face by t.
module usb_c(t, w = 3.3, h = 8) {
    rotate([-90, 0, 0])
        linear_extrude(t)
            offset(r = w/2) square([0.01, h - w], center = true);
}

// Front I/O on the -Y face — M4 layout, left → right:
//   2× USB-C (vertical), power LED, headphone jack.
io_z = 24;
module front_io(t) {
    translate([0, -mini_w/2, io_z]) {
        translate([-27, 0, 0]) usb_c(t);
        translate([-14, 0, 0]) usb_c(t);
        translate([ 28, 0, 0]) rotate([-90, 0, 0]) cylinder(d = 4, h = t);   // headphone jack
    }
}

module mac() {
    difference() {
        color([0.60, 0.61, 0.64]) mac_body();   // brushed-aluminium silver
        front_io(4.1);                            // recess the ports
    }
    color([0.06, 0.06, 0.08])                     // dark port faces, inset in the recess
        translate([0, 1.2, 0]) front_io(2.4);
    color([0.85, 0.90, 0.85])                     // power LED — small bright dot
        translate([17, -mini_w/2 + 0.3, io_z]) rotate([-90, 0, 0]) cylinder(d = 1.6, h = 0.6);
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
