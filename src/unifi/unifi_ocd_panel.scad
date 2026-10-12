/* =====================================================
   UniFi Toolless Mini Rack — OCD Panel (earless)
   =====================================================
   Filler panels for the UniFi Toolless Mini Rack
   (U-Rack-6U-TL). That rack has no 19" rails, so the usual
   eared blanks don't fit. Like Ubiquiti's own OCD panels
   (UACC-Rack-Panel-*), these are a U-channel with no ears:
   a front face plus two side flanges that slide in between
   the rack's side slats, sit on a slot's ledge, and catch
   that slot's side pin in a slot in each flange.

   Rack geometry (measured from Ubiquiti's 3D model of the
   U-Rack-6U-TL; see unifi_ocd_panel.md):
     slot pitch       48 mm (not EIA 44.45)
     slat-to-slat     444.4 mm clear
     side pin         Ø4, 9 mm above the ledge top,
                      42.4 mm behind the post front,
                      sticks 4.5 mm in from the slat
     ledge            1.65 mm sheet, 19.7 mm in from the
                      slat, ends 10.9 mm behind the post
                      front

   Panel (matches Ubiquiti's: 442.4 wide, 63.5 deep,
   43.7 / 87.4 tall). Too wide for most beds, so it splits
   into `pieces` that butt together and are glued with
   L-shaped splices tucked into pockets in the top and
   bottom returns.

   A small detent spring in each pin slot clicks over the
   pin as the panel seats, so it can't creep forward.

   Coordinates (assembled): X across (centred), Y back
   from the front face, Z up from the ledge top.
   ===================================================== */

$fa = 2;
$fs = 0.4;

/* ── Selection (set by presets) ─────────────────────── */
part   = "panel";   // [panel, splice, fit_test, assembled, none]
style  = "blank";   // [blank, vented, passthrough]
units  = 1;         // rack slots tall: 1 or 2
piece  = 0;         // which piece of the split panel (0 = left)

/* ── Split ──────────────────────────────────────────── */
pieces    = 2;      // 1 = one piece (needs a ~450 mm bed)
seam_gap  = 0.1;    // per side, at each butt seam

/* ── Rack (measured) ────────────────────────────────── */
slot_pitch   = 48;
pin_d        = 3.98;
pin_z        = 9.0;     // pin centre above the ledge top
pin_setback  = 42.37;   // pin centre behind the post front
ledge_t      = 1.65;
ledge_front  = 10.92;   // ledge front edge behind the post front

/* ── Panel ──────────────────────────────────────────── */
W           = 442.4;    // overall width (rack clear: 444.4)
D           = 63.5;     // overall depth
U_H         = 43.7;     // height per unit (UniFi 1U gear)
front_proud = 1.0;      // face sits this far proud of the posts
face_t      = 3.0;
flange_t    = 2.4;      // side flanges
return_t    = 2.4;      // top/bottom returns
return_d    = 10;       // returns, measured from the front
chamfer     = 0.8;      // front edge chamfer

/* ── Pin slot + detent ──────────────────────────────── */
slot_w      = 4.6;      // pin 3.98 + clearance
lead_in     = 1.2;      // chamfer at the slot mouth
bump_h      = 0.7;      // detent bump height (pin rides 0.3 over the floor)
spring_t    = 1.6;      // detent beam thickness
spring_len  = 10;       // detent beam length (cantilever)
relief_w    = 1.0;      // cut that frees the beam

/* ── Splice ─────────────────────────────────────────── */
splice_len  = 40;
splice_t    = 1.6;
splice_drop = 6;        // leg down the back of the face
pocket_d    = 0.8;      // pocket depth into face / return
splice_clr  = 0.15;

/* ── Styles ─────────────────────────────────────────── */
vent_w      = 3;
vent_pitch  = 6;
vent_margin = 12;       // keep vents this far off the seams
vent_edge   = 24;       // ...and off the side flanges
pass_w      = 400;      // pass-through opening (Ubiquiti brush panel)
pass_h_1u   = 24;

/* ── Derived ────────────────────────────────────────── */
// Scenes `include` this file and set $units / $style per panel.
$units = units;
$style = style;
function ph() = $units * U_H;
eps   = 0.01;
pin_y = front_proud + pin_setback;        // pin centre, from the face
seams = [for (k = [1 : pieces - 1]) -W/2 + k * W / pieces];
splice_xs = seams;

/* ── Body ───────────────────────────────────────────── */

module face_slab() {
    hull() {
        translate([-W/2 + chamfer, 0, chamfer])
            cube([W - 2*chamfer, eps, ph() - 2*chamfer]);
        translate([-W/2, chamfer, 0]) cube([W, face_t - chamfer, ph()]);
    }
}

module channel() {
    face_slab();
    // side flanges
    for (s = [-1, 1])
        translate([s > 0 ? W/2 - flange_t : -W/2, face_t - eps, 0])
            cube([flange_t, D - face_t + eps, ph()]);
    // top / bottom returns
    for (z = [0, ph() - return_t])
        translate([-W/2, face_t - eps, z])
            cube([W, return_d - face_t + eps, return_t]);
}

/* ── Pin slot with detent, in the YZ plane of a flange ─ */
// 2D in (y, z): y back from the face, z up from the ledge.

module pin_slot_2d(zc) {
    r  = slot_w / 2;
    zb = zc - r;                     // slot floor
    // the slot, open to the back edge, round end on the pin
    translate([pin_y, zc]) circle(r = r);
    translate([pin_y, zb]) square([D - pin_y + 1, slot_w]);
    // lead-in at the mouth
    translate([D, zc])
        polygon([[1, -r - lead_in], [1, r + lead_in], [-lead_in, r], [-lead_in, -r]]);
    // detent: cantilever beam under the slot floor, rooted at the
    // back, free just behind the seated pin
    tip = pin_y + r + 0.3;
    translate([tip, zb - spring_t - relief_w]) square([spring_len, relief_w]);
    translate([tip, zb - spring_t - relief_w]) square([relief_w, spring_t + relief_w + eps]);
}

module bump_2d(zc) {
    // rides on the beam's free end, pokes up into the slot
    translate([pin_y + slot_w/2 + 0.3 + relief_w + 1.2, zc - slot_w/2])
        scale([1.6, 1]) circle(r = bump_h);
}

// Notch that lets a 2U flange pass over the middle ledge.
module ledge_notch_2d(k) {
    z0 = k * slot_pitch;
    y0 = front_proud + ledge_front - 0.5;
    translate([y0, z0 - ledge_t - 0.5]) square([D - y0 + 1, ledge_t + 1.0]);
}

module flange_cuts() {
    for (s = [-1, 1])
        translate([s * W/2, 0, 0]) rotate([90, 0, 90])
            // straddle the outer face: the right flange lies inside it
            // (-X), the left flange outside it (+X)
            translate([0, 0, -flange_t - 1]) linear_extrude(2 * flange_t + 2)
                difference() {
                    union() {
                        for (k = [0 : $units - 1]) pin_slot_2d(k * slot_pitch + pin_z);
                        for (k = [1 : $units - 1]) ledge_notch_2d(k);
                    }
                    for (k = [0 : $units - 1]) bump_2d(k * slot_pitch + pin_z);
                }
}

/* ── Face styles ────────────────────────────────────── */

function near_seam(x, m) = len([for (s = seams) if (abs(x - s) < m) 1]) > 0;

module vent_cuts() {
    vh = ph() - 2 * (return_t + 9);
    n  = floor((W - 2 * vent_edge) / vent_pitch);
    x0 = -(n - 1) * vent_pitch / 2;
    for (i = [0 : n - 1]) {
        x = x0 + i * vent_pitch;
        if (!near_seam(x, vent_margin))
            translate([x, -1, ph()/2]) rotate([-90, 0, 0])
                hull() for (z = [-1, 1])
                    translate([0, z * (vh - vent_w) / 2, 0])
                        cylinder(d = vent_w, h = face_t + 2);
    }
}

module pass_cut() {
    oh = $units == 1 ? pass_h_1u : ph() - 2 * (return_t + 8);
    translate([0, -1, ph()/2]) rotate([-90, 0, 0])
        hull() for (x = [-1, 1])
            translate([x * (pass_w - oh) / 2, 0, 0]) cylinder(d = oh, h = face_t + 2);
}

/* ── Splice (L-bar, glued across a seam) ────────────── */
// Top splice in assembled position, centred on x = 0.
module splice_top(clr = 0) {
    zt = ph() - return_t + pocket_d;      // top of leg in the return pocket
    translate([-splice_len/2 - clr, face_t - pocket_d - clr, zt - splice_t - clr])
        cube([splice_len + 2*clr, return_d - 0.5 - (face_t - pocket_d) + 2*clr, splice_t + 2*clr]);
    translate([-splice_len/2 - clr, face_t - pocket_d - clr, zt - splice_t - splice_drop - clr])
        cube([splice_len + 2*clr, splice_t + 2*clr, splice_t + splice_drop + 2*clr]);
}

module splice_at(x, clr = 0) {
    translate([x, 0, 0]) {
        splice_top(clr);
        translate([0, 0, ph()]) mirror([0, 0, 1]) splice_top(clr);
    }
}

/* ── Assembled panel and pieces ─────────────────────── */

module panel_full() {
    difference() {
        channel();
        flange_cuts();
        if ($style == "vented")      vent_cuts();
        if ($style == "passthrough") pass_cut();
        for (x = splice_xs) splice_at(x, splice_clr);
    }
}

module piece_range(i) {
    x0 = i == 0          ? -W/2 - 1 : seams[i - 1] + seam_gap;
    x1 = i == pieces - 1 ?  W/2 + 1 : seams[i]     - seam_gap;
    translate([x0, -1, -1]) cube([x1 - x0, D + 2, ph() + 2]);
}

module panel_piece(i) {
    intersection() { panel_full(); piece_range(i); }
}

/* ── Print layouts ──────────────────────────────────── */

// Face down on the bed; flanges and returns stand up.
module face_down() { rotate([90, 0, 0]) children(); }

if (part == "panel") {
    // centre the piece on the bed
    cx = -W/2 + (piece + 0.5) * W / pieces;
    face_down() translate([-cx, 0, -ph()/2]) panel_piece(piece);
} else if (part == "splice") {
    // short leg flat on the bed, long leg standing
    translate([0, 0, -(face_t - pocket_d)]) rotate([90, 0, 0]) splice_top();
} else if (part == "fit_test") {
    // the right-hand end of the panel: flange, slot, detent, a bit of face
    w = 30;
    face_down() translate([-(W/2 - w/2), 0, -ph()/2])
        intersection() {
            panel_full();
            translate([W/2 - w, -1, -1]) cube([w + 1, D + 2, ph() + 2]);
        }
} else if (part == "assembled") {
    // assembled (for checking)
    for (i = [0 : pieces - 1]) panel_piece(i);
    for (x = splice_xs) splice_at(x);
}
