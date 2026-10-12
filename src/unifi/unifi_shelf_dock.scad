/* =====================================================
   UniFi Toolless Mini Rack Shelf — device docks
   =====================================================
   Organizers that sit on Ubiquiti's fixed Toolless Mini
   Rack Shelf (UACC-Rack-Shelf-TL). The steel shelf carries
   the load (rated 20 kg). These parts only keep things in
   place:

     dock    a ladder frame with slotted fins that holds
             devices standing on edge (Mac minis, a
             NucBox, power bricks)
     corner  L guides (left and right) that locate the
             front corners of a device lying flat (A9 Mega,
             MS-A2)
     pins    loose locating pins. Each drops through a
             counterbored hole in a part and into the
             shelf's perforations so the part can't slide.

   Shelf perforations (measured): Ø3.5 holes in a 60°
   staggered grid, 6.0 mm apart along a row (left–right),
   rows 5.2 mm apart. All of a part's pin holes sit on one
   row, a multiple of 6 mm apart, so they always line up
   with the holes and a slightly off row spacing doesn't
   add up.

   The perforated field is the middle ~382 × 318 mm of the
   shelf (about 74 mm in from the front and back edges).
   The pins have to land inside it.

   Coordinates: X across, Y back from the front of the
   device, Z up from the shelf top.
   ===================================================== */

$fa = 2;
$fs = 0.4;

/* ── Selection (set by presets) ─────────────────────── */
part = "dock";      // [dock, corner_left, corner_right, pins, fit_test, none]

/* ── Dock ───────────────────────────────────────────── */
slots     = 3;      // devices side by side
slot_w    = 51;     // device thickness + clearance
dev_d     = 127;    // device depth (front to back)
div_t     = 6;      // divider between devices (= air gap between them)
fin_h     = 40;     // fin height above the floor
fin_len   = 16;     // fin length along the device
fin_front = 8;      // front fins start this far behind the device front
back_keep = 28;     // back fins stop this far short of the device back
                    // (Mac mini M4: keeps the power button reachable)

/* ── Corner guide ───────────────────────────────────── */
corner_arm = 40;
corner_h   = 12;    // wall height above the shelf
flange_w   = 12;    // outward base flange carrying the pin holes

/* ── Shared ─────────────────────────────────────────── */
base_t   = 3;       // floor bars, rails and flanges
wall_t   = 3;       // outer walls
lead     = 2;       // lead-in chamfer at the top of each slot

/* ── Shelf + pins ───────────────────────────────────── */
hole_pitch = 6.0;   // along a perforation row
row_pitch  = 5.2;   // between rows (60° stagger)
pin_d      = 3.1;   // into Ø3.5 shelf holes
pin_hole   = 3.4;   // through the part
pin_head_d = 6.2;
pin_head_t = 1.2;
cbore_d    = 6.8;
cbore_t    = 1.4;
peg_len    = 2.0;   // how far a pin pokes below the part
pin_count  = 24;    // pins per plate

/* ── Derived ────────────────────────────────────────── */
// Scenes `include` this file and set these per dock.
$slots     = slots;
$slot_w    = slot_w;
$dev_d     = dev_d;
$div_t     = div_t;
$fin_h     = fin_h;
$back_keep = back_keep;

eps = 0.01;
function dock_w()    = 2 * wall_t + $slots * $slot_w + ($slots - 1) * $div_t;
function bar_front() = [fin_front, fin_front + fin_len];
function bar_back()  = [$dev_d - $back_keep - fin_len, $dev_d - $back_keep];

// x of slot i's left edge, with the dock's left outer face at x = 0
function slot_x(i) = wall_t + i * ($slot_w + $div_t);
function slot_c(i) = slot_x(i) + $slot_w / 2;

// Pin holes: in the outer slots' floors, on the back bar (the front
// bar is often outside the perforated field), snapped so they're a
// whole number of hole pitches apart.
function dock_pin_xs() =
    let(a = $slots == 1 ? slot_c(0) - 2 * hole_pitch : slot_c(0),
        b = $slots == 1 ? slot_c(0) + 2 * hole_pitch : slot_c($slots - 1))
    [a, a + hole_pitch * round((b - a) / hole_pitch)];
function dock_pin_y() = (bar_back()[0] + bar_back()[1]) / 2;

/* ── Pin hole (counterbored from the top) ───────────── */
module pin_hole_at(x, y) {
    translate([x, y, -1]) cylinder(d = pin_hole, h = base_t + 2);
    translate([x, y, base_t - cbore_t]) cylinder(d = cbore_d, h = cbore_t + 1);
}

/* ── Dock ───────────────────────────────────────────── */

module dock() {
    w_all = dock_w();
    walls = concat(
        [[0, wall_t]],
        [for (i = [0 : $slots - 2]) [slot_x(i) + $slot_w, $div_t]],
        [[w_all - wall_t, wall_t]]);
    difference() {
        union() {
            for (bar = [bar_front(), bar_back()]) {
                // floor bar the devices stand on
                translate([0, bar[0], 0]) cube([w_all, fin_len, base_t]);
                // fins
                for (w = walls)
                    translate([w[0], bar[0], 0]) cube([w[1], fin_len, base_t + $fin_h]);
            }
            // rails tie the two bars together under every wall
            for (w = walls)
                translate([w[0], bar_front()[0], 0])
                    cube([w[1], bar_back()[1] - bar_front()[0], base_t]);
        }
        // lead-in at the top of every slot
        for (i = [0 : $slots - 1])
            translate([slot_x(i), -1, base_t + $fin_h])
                rotate([-90, 0, 0]) linear_extrude($dev_d + 2)
                    polygon([[-lead, -eps], [$slot_w + lead, -eps], [$slot_w, lead], [0, lead]]);
        for (x = dock_pin_xs()) pin_hole_at(x, dock_pin_y());
    }
}

/* ── Corner guide ───────────────────────────────────── */
// Locates a front corner of a device lying flat. Device corner at
// the origin, device in +X/+Y (a left-front corner; mirror it for
// the right). The pin flange sticks out in front, where there's room
// between the rows, so the side wall adds only wall_t + clearance
// and two machines can sit close together.

corner_pin_at = [12, 12 + 2 * hole_pitch];   // along the front arm

module corner() {
    difference() {
        union() {
            // walls
            translate([-wall_t, -wall_t, 0]) cube([corner_arm + wall_t, wall_t, base_t + corner_h]);
            translate([-wall_t, -wall_t, 0]) cube([wall_t, corner_arm + wall_t, base_t + corner_h]);
            // front flange
            translate([-wall_t, -wall_t - flange_w, 0]) cube([corner_arm + wall_t, flange_w + eps, base_t]);
        }
        for (p = corner_pin_at) pin_hole_at(p, -wall_t - flange_w / 2);
    }
}

/* ── Pin ────────────────────────────────────────────── */
// Head down on the bed. Head sits in the counterbore, and the shaft
// goes through the part and into a shelf hole.

module pin() {
    shaft = base_t - cbore_t + peg_len;
    cylinder(d = pin_head_d, h = pin_head_t);
    translate([0, 0, pin_head_t - eps]) {
        cylinder(d = pin_d, h = shaft - 0.5 + eps);
        translate([0, 0, shaft - 0.5]) cylinder(d1 = pin_d, d2 = pin_d - 1, h = 0.5);
    }
}

module pins_plate() {
    cols = 6;
    for (i = [0 : pin_count - 1])
        translate([(i % cols) * 9, floor(i / cols) * 9, 0]) pin();
}

/* ── Fit test ───────────────────────────────────────── */
// A bar with two pin holes 5 pitches apart, plus two pins.
// Drop it on the shelf: both pins should fall into holes.

module fit_test() {
    span = 5 * hole_pitch;
    difference() {
        translate([-8, -7, 0]) cube([span + 16, 14, base_t]);
        pin_hole_at(0, 0);
        pin_hole_at(span, 0);
    }
    for (i = [0, 1]) translate([span / 2 + (i - 0.5) * 10, 16, 0]) pin();
}

/* ── Print layouts ──────────────────────────────────── */

if (part == "dock") {
    translate([-dock_w() / 2, -dev_d / 2, 0]) dock();
} else if (part == "corner_left") {
    corner();
} else if (part == "corner_right") {
    mirror([1, 0, 0]) corner();
} else if (part == "pins") {
    pins_plate();
} else if (part == "fit_test") {
    fit_test();
}
