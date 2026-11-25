/* =====================================================
   Rack brick caddy — UniFi Toolless Mini Rack
   =====================================================
   A tray that slides into the bottom 2U of the U-Rack-6U-TL
   from the back and holds the compute machines' power
   bricks, so they're out of the compute bay:

     basil     80 × 175 × 41
     geek      76 × 165 × 26.5
     fireball  54 ×  96 × 24     (height × length × thickness,
                                  as they stand in the tray)

   and the HDHomeRun, lying flat on top of the beams next to
   the switch it plugs into.

   The bricks run hot, so the tray touches as little of them
   as it can:
     - each brick stands on edge, long axis front to back,
       so its two big faces are vertical and the hot air
       rises off them like a chimney,
     - it sits in a notch in each of three thin cross beams;
       the notch walls are the only contact with its faces
       (22 mm tall, 8 mm long, three per side),
     - there's no floor: air comes up from below, between
       the beams,
     - the bricks are spread across the rack with 40+ mm
       between them.
   The AC end of each brick faces the back of the rack,
   where the power strip is; the DC lead leaves the front
   end and goes up to the compute bay.

   The tray rides on the bottom slot's ledges like any
   UniFi gear: a skid on each side sits on the ledge, and a
   channel in its outer face catches that slot's side pin,
   which stops the tray at the right depth. It's 442 mm
   wide, too wide for a 256 bed, so it prints as two halves
   that drop together with dovetail tabs at the centre.

   Room (from Ubiquiti's specs and our rack measurements,
   see unifi_ocd_panel.md):
     - 2U clear height is 94.4 mm (46.4 + 48); the bricks top
       out at 88, under the power strip in the next slot up.
     - Between the skids the tray stays clear of the middle
       ledge (|x| < 202.5); the skids stay under it (16 tall).
     - The tray reaches 200 mm in from the back post; the
       bottom slots' front gear is the Pro Max 16 PoE, 160 mm
       deep, out of ~450 mm.

   Coordinates: X across the rack (centred), Y in from the
   back post face, Z up from the bottom slot's ledge top.
   ===================================================== */

$fa = 2;
$fs = 0.4;

/* ── Selection (set by presets) ─────────────────────── */
part = "left";      // [left, right, fit_test, assembled, none]

/* ── Rack (measured; same numbers as unifi_ocd_panel.scad) ── */
slat_x      = 444.4 / 2;   // slat inner face
ledge_in    = 19.7;        // ledge sticks in this far from the slat
ledge_front = 10.92;       // ledge starts this far behind the post face
pin_d       = 3.98;
pin_z       = 9.0;         // above the ledge top
pin_setback = 42.37;       // behind the post face
pin_reach   = 4.5;         // in from the slat
mid_ledge_z = 48 - 1.65;   // underside of the middle ledge (2U up: 94.35)

/* ── Bricks: [name, height, length, thickness, x centre] ── */
bricks = [
    ["basil",    80,   175, 41,   -140],
    ["fireball", 54,    96, 24,    -60],
    ["geek",     76,   165, 26.5,  100],
];
brick_clear = 0.6;          // per side, in the notches

/* ── HDHomeRun (FLEX 4K: 86 × 86 × 20, per SiliconDust) ── */
// Lies flat across the back two beams, between fireball and geek, next
// to the switch it plugs into. Four low corner guides and a back stop.
hdhr      = [86, 86, 20];   // width (x), depth (y), height
hdhr_x    = 20;             // centre
hdhr_clear = 0.8;
guide_h   = 5;
guide_t   = 3;

/* ── Tray ───────────────────────────────────────────── */
side_gap  = 0.6;            // skid to slat
skid_w    = 18.6;           // skid width (sits on the ledge)
skid_h    = 16;             // stays well under the middle ledge
y0        = 12;             // tray's back end (behind the ledge start)
y1        = 200;            // tray's front end
beam_y    = [24, 105, 180]; // cross beam centres
beam_w    = 8;              // along Y
beam_h    = 30;
seat_z    = 8;              // notch floor: where the bricks stand
lip_t     = 2;              // brick stop on the back beam
lip_h     = 6;
lead      = 2;              // lead-in chamfer at the top of each notch
rail_w    = 8;              // inner rails, either side of the seam
rail_h    = 8;

/* ── Pin channel ────────────────────────────────────── */
chan_w    = 4.6;            // pin 3.98 + clearance
chan_deep = pin_reach + 0.5;
chan_lead = 1.5;            // flare at the open end

/* ── Centre joint (dovetail tabs, drop together) ────── */
tab_neck  = 6;
tab_head  = 11;
tab_len   = 9;
tab_clear = 0.2;
pad_w     = 20;             // beams widen to this at the seam

/* ── Derived ────────────────────────────────────────── */
skid_out = slat_x - side_gap;      // 221.6
skid_in  = skid_out - skid_w;      // 203.0
eps = 0.01;

/* ── Pieces ─────────────────────────────────────────── */
module skid(s) {
    mirror([s < 0 ? 1 : 0, 0, 0]) difference() {
        translate([skid_in, y0, 0]) cube([skid_w, y1 - y0, skid_h]);
        // channel for the side pin: open at the front end (the tray's
        // leading end as it slides in), closed where the pin stops it
        hull() {
            translate([skid_out - chan_deep, pin_setback, pin_z])
                rotate([0, 90, 0]) cylinder(d = chan_w, h = chan_deep + 1);
            translate([skid_out - chan_deep, y1 + 1, pin_z - chan_w / 2])
                cube([chan_deep + 1, eps, chan_w]);
        }
        // flare at the mouth
        translate([skid_out - chan_deep, y1, pin_z])
            hull() {
                translate([0, -chan_lead, -chan_w / 2]) cube([chan_deep + 1, eps, chan_w]);
                translate([0, eps, -chan_w / 2 - chan_lead]) cube([chan_deep + 1, eps, chan_w + 2 * chan_lead]);
            }
    }
}

// One cross beam, with a notch for each brick. The back beam keeps a
// thin lip at its back face: the bricks butt against it.
module beam(yc, back = false) {
    difference() {
        union() {
            translate([-skid_in - 1, yc - beam_w / 2, 0]) cube([2 * skid_in + 2, beam_w, beam_h]);
            translate([-14, yc - pad_w / 2, 0]) cube([28, pad_w, beam_h]);
        }
        for (b = bricks) let(w = b[3] + 2 * brick_clear, y_cut = back ? yc - beam_w / 2 + lip_t : yc - beam_w / 2 - 1)
            translate([b[4], 0, 0]) {
                translate([-w / 2, y_cut, seat_z]) cube([w, beam_w + 2, beam_h]);
                if (back) translate([-w / 2, yc - beam_w / 2 - 1, seat_z + lip_h]) cube([w, beam_w + 2, beam_h]);
                // lead-in
                translate([0, yc - beam_w / 2 - 1, beam_h]) rotate([-90, 0, 0])
                    linear_extrude(beam_w + 2)
                        // ends just inside the notch, so it never shares an
                        // edge with the notch walls (issue #16)
                        polygon([[-w / 2 - lead, -eps], [w / 2 + lead, -eps],
                                 [w / 2 - 0.05, lead + 0.05], [-w / 2 + 0.05, lead + 0.05]]);
            }
    }
}

// Corner guides on the beam tops; the HDHomeRun's back rests against a
// stop on the back beam. Its front hangs past the middle beam a little.
module hdhr_guides() {
    w = hdhr[0] + 2 * hdhr_clear;
    for (yb = [beam_y[0], beam_y[1]], s = [-1, 1])
        translate([hdhr_x + s * (w / 2 + guide_t / 2) - guide_t / 2, yb - beam_w / 2, beam_h - eps])
            cube([guide_t, beam_w, guide_h]);
    // back stop, in two pieces so it stays clear of the centre joint
    for (r = [[hdhr_x - w / 2 - guide_t, -14], [14, hdhr_x + w / 2 + guide_t]])
        translate([r[0], beam_y[0] - beam_w / 2, beam_h - eps]) cube([r[1] - r[0], guide_t, guide_h]);
}

module frame() {
    hdhr_guides();
    for (s = [-1, 1]) skid(s);
    for (i = [0 : len(beam_y) - 1]) beam(beam_y[i], i == 0);
    // inner rails tie each half's beams together, clear of the seam
    for (s = [-1, 1]) translate([s > 0 ? 4 : -4 - rail_w, beam_y[0], 0])
        cube([rail_w, beam_y[len(beam_y) - 1] - beam_y[0], rail_h]);
}

module tab(yc, grow = 0) {
    translate([0, yc, -1]) linear_extrude(beam_h + 2)
        offset(delta = grow) polygon([[-1, -tab_neck / 2], [tab_len, -tab_head / 2],
                                      [tab_len, tab_head / 2], [-1, tab_neck / 2]]);
}

module half(s) {
    if (s < 0) {
        intersection() { frame(); translate([-300, -10, -10]) cube([300, 300, 100]); }
        intersection() { frame(); for (y = beam_y) tab(y); }
    } else {
        difference() {
            intersection() { frame(); translate([0, -10, -10]) cube([300, 300, 100]); }
            for (y = beam_y) tab(y, tab_clear);
        }
    }
}

// The last 60 mm of a skid with its pin stop, plus one joint, to check
// the fit before printing the halves.
module fit_test() {
    intersection() {
        skid(1);
        translate([skid_in - 1, y0, -1]) cube([skid_w + 2, pin_setback + 18 - y0, skid_h + 2]);
    }
    translate([0, 70, 0]) intersection() {
        half(-1);
        translate([-20, beam_y[1] - pad_w / 2 - 1, -1]) cube([40, pad_w + 2, beam_h + 2]);
    }
    translate([40, 70, 0]) intersection() {
        half(1);
        translate([-1, beam_y[1] - pad_w / 2 - 1, -1]) cube([21, pad_w + 2, beam_h + 2]);
    }
}

// The bricks and the HDHomeRun as plain boxes, in place (for scenes).
module contents() {
    color("#2a2a2a") for (b = bricks)
        translate([b[4] - b[3] / 2, beam_y[0] - beam_w / 2 + lip_t, seat_z]) cube([b[3], b[2], b[1]]);
    color("#151515") translate([hdhr_x - hdhr[0] / 2, beam_y[0] - beam_w / 2 + guide_t, beam_h])
        cube([hdhr[0], hdhr[1], hdhr[2]]);
}

/* ── Output ─────────────────────────────────────────── */
if (part == "left") {
    translate([skid_out, 0, 0]) half(-1);
} else if (part == "right") {
    half(1);
} else if (part == "fit_test") {
    translate([-skid_in, 0, 0]) fit_test();
} else if (part == "assembled") {
    half(-1);
    half(1);
}
