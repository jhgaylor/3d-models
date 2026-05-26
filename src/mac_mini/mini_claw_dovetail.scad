// "Plus"-shaped claw that drops onto a Mac mini M4 (127x127x50mm).
// The plug and socket variants have four fingers wrapping ~15mm down
// each side of the Mac. The pass-through variant drops the two fingers
// on the dovetail (X) axis and pulls those dovetails inward — its
// plug/socket neighbours constrain that axis through the dovetails.
// It keeps the front/back (Y) fingers, since nothing else holds the
// cross-stack axis. This shrinks the gap between Macs along the chain
// from ~19mm to ~4mm per joint.
//
// Variants (see mini_claw_dovetail.json):
//   pass-through — tongue on +X, socket on -X. No fingers. Must sit
//                  between a plug and a socket (or another pass-through
//                  with at least one finger'd neighbour upstream).
//   plug         — tongue only, with fingers. Use at the chain's -X end.
//   socket       — socket only, with fingers. Use at the chain's +X end.
//
// Two prints chain end-to-end by dropping the second print straight
// down — its socket envelops the first print's tongue as it descends.
// The top face is completely flat (no upward protrusions). Print with
// the plate top on the bed and the fingers pointing up.

$fa = 2;
$fs = 0.5;

// === Variant ===
mode = "pass-through"; // [pass-through, plug, socket]

// === Mac mini M4 ===
mini_w = 127;
mini_h = 50;

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

// X arm carries the dovetails. Plug/socket extend to the finger position;
// pass-through pulls in so the neighbour's finger still clears this Mac by
// side_clearance.
//   neighbour_finger_outer (in world) = -pt_arm_half - dovetail_length + finger_thickness
//   set ≤ -mini_w/2 - side_clearance  →  pt_arm_half ≥ 52
pt_arm_half = 52;

// === Dovetail ===
dovetail_length = 12;
dovetail_narrow = 14;
dovetail_wide   = 22;
fit_gap         = 0.3;

// Spacing between adjacent claw (and Mac) centres along the chain.
// plug tongue tip = +finger_outer + dovetail_length; pass-through socket
// opening = -pt_arm_half. They meet, so centres sit this far apart.
chain_pitch = finger_outer + dovetail_length + pt_arm_half;  // 131

// 2D outline (top view) of the plate, plus the optional +X tongue and the
// optional -X socket-host extension with cavity subtracted. Linear-extruding
// this once gives both the flat top and the through-hole.
module claw_outline_2d(m) {
    has_tongue    = (m == "pass-through") || (m == "plug");
    has_socket    = (m == "pass-through") || (m == "socket");
    has_x_fingers = (m != "pass-through");
    arm_half_x    = has_x_fingers ? finger_outer : pt_arm_half;
    arm_half_y    = finger_outer;
    difference() {
        union() {
            square([2*arm_half_x, arm_width], center = true);
            square([arm_width, 2*arm_half_y], center = true);
            if (has_tongue)
                // narrow at the attached base, widens out to the tip
                translate([arm_half_x, 0])
                    polygon([
                        [0,               -dovetail_narrow/2],
                        [0,                dovetail_narrow/2],
                        [dovetail_length,  dovetail_wide/2],
                        [dovetail_length, -dovetail_wide/2],
                    ]);
            if (has_socket)
                // arm-width slab extending past the -X arm; cavity cut below
                translate([-arm_half_x - dovetail_length, -arm_width/2])
                    square([dovetail_length, arm_width]);
        }
        if (has_socket)
            // Cavity mirrors the tongue trapezoid + fit_gap. Wide edge faces
            // the gap to capture the neighbor's wide tongue tip; narrows
            // toward the outer end of the extension.
            translate([-arm_half_x, 0])
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

module claw(m) {
    has_x_fingers = (m != "pass-through");
    union() {
        linear_extrude(plate_thickness)
            claw_outline_2d(m);
        // Front/back (Y-axis) fingers — grip the cross-stack axis on every variant.
        finger(-arm_width/2,    finger_inner,  arm_width,        finger_thickness);
        finger(-arm_width/2,   -finger_outer,  arm_width,        finger_thickness);
        // Left/right (X-axis) fingers — plug/socket only; pass-through relies on
        // its neighbours' dovetails to hold this axis.
        if (has_x_fingers) {
            finger( finger_inner,  -arm_width/2,   finger_thickness, arm_width);
            finger(-finger_outer,  -arm_width/2,   finger_thickness, arm_width);
        }
    }
}

// Render the single part unless a scene file is driving this (it sets SCENE).
if (is_undef(SCENE)) claw(mode);
