// "Plus"-shaped claw that drops onto a Mac mini M4 (127x127x50mm).
// Four fingers wrap ~15mm down each side. The +X arm tip carries a vertical
// dovetail tongue; the -X arm tip carries a matching socket. Two prints
// chain end-to-end: print A's +X tongue drops into print B's -X socket.

$fa = 2;
$fs = 0.5;

// === Mac mini M4 ===
mini_w = 127;

// === Claw ===
arm_width        = 30;
plate_thickness  = 3;
finger_height    = 15;
finger_thickness = 3;
side_clearance   = 0.5;

inner_span   = mini_w + 2 * side_clearance;
outer_span   = inner_span + 2 * finger_thickness;
finger_inner = inner_span / 2;
finger_outer = outer_span / 2;

// === Dovetail ===
dovetail_length = 12;
dovetail_narrow = 14;
dovetail_wide   = 22;
dovetail_height = 6;
fit_gap         = 0.3;

module claw_body() {
    union() {
        linear_extrude(plate_thickness)
            union() {
                square([outer_span, arm_width], center = true);
                square([arm_width, outer_span], center = true);
            }
        // +X finger
        translate([finger_inner, -arm_width/2, -finger_height])
            cube([finger_thickness, arm_width, finger_height + plate_thickness]);
        // -X finger
        translate([-finger_outer, -arm_width/2, -finger_height])
            cube([finger_thickness, arm_width, finger_height + plate_thickness]);
        // +Y finger
        translate([-arm_width/2, finger_inner, -finger_height])
            cube([arm_width, finger_thickness, finger_height + plate_thickness]);
        // -Y finger
        translate([-arm_width/2, -finger_outer, -finger_height])
            cube([arm_width, finger_thickness, finger_height + plate_thickness]);
    }
}

module tongue() {
    // narrow at attached base (x=0), widens out toward tip (x=+dovetail_length)
    translate([finger_outer, 0, plate_thickness])
        linear_extrude(dovetail_height)
            polygon([
                [0,               -dovetail_narrow/2],
                [0,                dovetail_narrow/2],
                [dovetail_length,  dovetail_wide/2],
                [dovetail_length, -dovetail_wide/2],
            ]);
}

module socket() {
    // host block extending outward from -X finger, with trapezoidal cavity:
    // wide at gap-facing edge, narrowing toward the outer tip.
    difference() {
        translate([-finger_outer - dovetail_length, -arm_width/2, plate_thickness])
            cube([dovetail_length, arm_width, dovetail_height]);
        translate([-finger_outer, 0, plate_thickness - 0.01])
            linear_extrude(dovetail_height + 0.02)
                polygon([
                    [0,                -(dovetail_wide   + fit_gap)/2],
                    [0,                 (dovetail_wide   + fit_gap)/2],
                    [-dovetail_length,  (dovetail_narrow + fit_gap)/2],
                    [-dovetail_length, -(dovetail_narrow + fit_gap)/2],
                ]);
    }
}

union() {
    claw_body();
    tongue();
    socket();
}
