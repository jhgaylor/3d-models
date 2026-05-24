// "Plus"-shaped claw that drops onto a Mac mini M4 (127x127x50mm).
// Four fingers wrap ~15mm down each side. The +X arm tip carries a flexible
// snap-post with a barb; the -X arm tip carries a thru-hole receiver tab.
// Two prints chain end-to-end: print A's +X post snaps up through print B's
// -X receiver hole as print B is lowered onto its mini.

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

// === Hook latch ===
post_thick    = 2.4;   // X thickness of the flexible post
post_width    = 14;    // Y width of the post
post_height   = 12;    // Z height above plate
barb_protrude = 1.2;   // how far the barb sticks out past post_thick
barb_height   = 3;     // Z height of the barb ramp
tab_reach     = 12;    // how far the receiver tab extends past the finger
tab_thickness = plate_thickness;  // same as plate for cleanliness
fit_gap       = 0.4;   // clearance around post in the receiver hole

module claw_body() {
    union() {
        linear_extrude(plate_thickness)
            union() {
                square([outer_span, arm_width], center = true);
                square([arm_width, outer_span], center = true);
            }
        translate([finger_inner, -arm_width/2, -finger_height])
            cube([finger_thickness, arm_width, finger_height + plate_thickness]);
        translate([-finger_outer, -arm_width/2, -finger_height])
            cube([finger_thickness, arm_width, finger_height + plate_thickness]);
        translate([-arm_width/2, finger_inner, -finger_height])
            cube([arm_width, finger_thickness, finger_height + plate_thickness]);
        translate([-arm_width/2, -finger_outer, -finger_height])
            cube([arm_width, finger_thickness, finger_height + plate_thickness]);
    }
}

// Vertical flexible post on the +X arm, just outside the +X finger.
// Barb on +X face at the top: slope on top (insertion ramp), flat on bottom
// (retention face that catches the receiver tab against upward pull).
module snap_post() {
    post_x = finger_outer;
    cube_base = [post_x, -post_width/2, 0];
    translate(cube_base)
        cube([post_thick, post_width, plate_thickness + post_height]);
    // Triangular prism barb. Bottom face is flat (retention); top face slopes
    // from tip back to the post face (insertion ramp).
    x0 = post_x + post_thick;
    z0 = plate_thickness + post_height - barb_height;
    polyhedron(
        points = [
            [x0,                  -post_width/2, z0             ],
            [x0 + barb_protrude,  -post_width/2, z0             ],
            [x0,                  -post_width/2, z0 + barb_height],
            [x0,                   post_width/2, z0             ],
            [x0 + barb_protrude,   post_width/2, z0             ],
            [x0,                   post_width/2, z0 + barb_height],
        ],
        faces = [
            [0, 1, 2],
            [3, 5, 4],
            [0, 2, 5, 3],
            [0, 3, 4, 1],
            [1, 4, 5, 2],
        ]);
}

// Receiver tab on -X arm: extends outward past the -X finger with a thru-hole.
// As the mating print descends, its post (from another claw) enters this hole
// from below; the barb flexes through and snaps above the tab.
module receiver_tab() {
    // tab x range in this print's frame: [-finger_outer - tab_reach, -finger_outer]
    difference() {
        translate([-finger_outer - tab_reach, -arm_width/2, plate_thickness - tab_thickness])
            cube([tab_reach, arm_width, tab_thickness]);
        // thru-hole sized for post + barb_protrude + clearance
        hole_x = -finger_outer - tab_reach + (tab_reach - (post_thick + barb_protrude + fit_gap))/2;
        translate([hole_x, -(post_width + fit_gap)/2, plate_thickness - tab_thickness - 0.1])
            cube([post_thick + barb_protrude + fit_gap,
                  post_width + fit_gap,
                  tab_thickness + 0.2]);
    }
}

union() {
    claw_body();
    snap_post();
    receiver_tab();
}
