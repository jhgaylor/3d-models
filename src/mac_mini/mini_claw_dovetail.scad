// "Plus"-shaped claw that drops onto a Mac mini M4 (127x127x50mm).
// Four fingers wrap ~15mm down each side. The +X arm carries a trapezoidal
// dovetail tongue integrated into the plate; the -X arm extension carries
// a matching socket cut through the plate. Two prints chain end-to-end by
// dropping the second print straight down onto its mini — its socket
// envelops the first print's tongue as it descends.
//
// The top face is completely flat (no upward protrusions). Print with
// the plate top on the bed and the fingers pointing up.

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
fit_gap         = 0.3;

// 2D outline (top view) of the plate, including the +X tongue and the -X
// socket-host extension, with the trapezoidal socket cavity subtracted.
// Linear-extruding this once gives both the flat top and the through-hole.
module claw_outline_2d() {
    difference() {
        union() {
            square([outer_span, arm_width], center = true);
            square([arm_width, outer_span], center = true);
            // +X tongue: narrow at the attached base, widens out to the tip
            translate([finger_outer, 0])
                polygon([
                    [0,               -dovetail_narrow/2],
                    [0,                dovetail_narrow/2],
                    [dovetail_length,  dovetail_wide/2],
                    [dovetail_length, -dovetail_wide/2],
                ]);
            // -X socket host: arm-width slab extending past the -X finger
            translate([-finger_outer - dovetail_length, -arm_width/2])
                square([dovetail_length, arm_width]);
        }
        // Socket cavity, mirroring the tongue trapezoid (+ fit_gap). Wide
        // edge faces the gap so it captures the neighboring print's wide
        // tongue tip; narrows toward the outer end of the extension.
        translate([-finger_outer, 0])
            polygon([
                [0,                -(dovetail_wide   + fit_gap)/2],
                [0,                 (dovetail_wide   + fit_gap)/2],
                [-dovetail_length,  (dovetail_narrow + fit_gap)/2],
                [-dovetail_length, -(dovetail_narrow + fit_gap)/2],
            ]);
    }
}

module finger(cx, cy, sx, sy) {
    translate([cx, cy, -finger_height])
        cube([sx, sy, finger_height + plate_thickness]);
}

union() {
    linear_extrude(plate_thickness)
        claw_outline_2d();
    finger( finger_inner,  -arm_width/2,   finger_thickness, arm_width);
    finger(-finger_outer,  -arm_width/2,   finger_thickness, arm_width);
    finger(-arm_width/2,    finger_inner,  arm_width,        finger_thickness);
    finger(-arm_width/2,   -finger_outer,  arm_width,        finger_thickness);
}
