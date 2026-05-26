/* =====================================================
   Puffco Peak dock cabinet — French front doors
   =====================================================
   part = "body" | "door" | "roof"  (set via JSON)

   A standalone home for the Peak Pro on its dock that
   REPLACES the tall lift-off lid. Instead of clearing
   ~220 mm overhead to remove a box, you swing two front
   doors open. Each door is hinged at a front corner and
   folds a full 270° back flat against the side wall.

   The fold-back trick: each hinge axis sits OUTBOARD of
   the front corner, in the door's mid-thickness plane
   (Y = -door_th/2). The whole hinge + leaf therefore
   lives in front of the box (Y < 0) and never fouls the
   walls as it wraps around to the side.

   Doors latch shut on a pair of 6 mm × 3 mm neodymium
   discs at the centre meeting stiles (one per door,
   opposite polarity — same magnet spec as the trays).

   Hinge pin: 3 mm steel rod / length of filament dropped
   down the barrel after assembly (bore = 3.2 mm).

   Interior envelope (from the modular-tray lid):
     123 (W) × 131 (D) × 210 (H) mm  — Peak Pro + dock
   ===================================================== */

$fn = 64;

/* ── Part selector (overridden by parameterSets) ─────── */
part = "body";   // [body, door, roof]

/* ── Structure ───────────────────────────────────────── */
tol      = 1.0;
wall     = 3.0;
flr      = 3.0;

iw       = 123;            // interior width  (X)
idp      = 131;            // interior depth  (Y)
ih       = 210;            // interior height (Z)

ew       = iw + 2*wall;    // 129 — exterior width
ed       = idp + 2*wall;   // 137 — exterior depth
wall_h   = flr + ih;       // 213 — top of side/back walls
lintel_h = 14;             // front top rail tying the side walls together

/* ── Dock well (Peak base sits here) ─────────────────── */
dock_d    = 116;           // matches modular-tray dock pocket
dock_h    = 30;            // well depth above the floor
cable_w   = 60;
cable_h   = 25;
dock_cx   = ew/2;
dock_cy   = wall + idp/2;

/* ── Doors ───────────────────────────────────────────── */
door_th    = 4.0;          // leaf thickness
center_gap = 1.5;          // total clearance where the two leaves meet
leaf_x0    = 0;            // inner edge of the left leaf (covers the side wall face)
leaf_x1    = ew/2 - center_gap/2;   // meeting edge near centre

/* ── Hinge (vertical barrel, offset axis) ────────────── */
hinge_d     = 7.0;         // knuckle outer diameter
pin_d       = 3.2;         // pin bore (3 mm rod + clearance)
hinge_gap   = 0.6;         // axial gap between interleaved knuckles
hinge_n     = 9;           // knuckle segments up the height (alternating)
hinge_off   = 5.0;         // axis offset outboard of the front corner (-X)
hinge_axis_x = -hinge_off;             // left door axis X  (mirror for right)
hinge_axis_y = -door_th/2;             // axis in the leaf mid-plane

/* ── Magnets : 6 × 3 mm neodymium discs ──────────────── */
mag_d = 6.2;   // pocket ø  (press-fit clearance)
mag_h = 3.2;   // pocket depth
mag_z = [wall_h*0.30, wall_h*0.70];   // two catches up the meeting stile

/* ── Style ───────────────────────────────────────────── */
rib_spacing = 10;
rib_width   = 1.2;
rib_depth   = 0.6;
rib_margin  = 10;

/* ── Helpers ─────────────────────────────────────────── */
module rbox(w, l, h, r = 3) {
    hull()
        for (dx = [r, w - r], dy = [r, l - r])
            translate([dx, dy, 0]) cylinder(r = r, h = h);
}

// Vertical groove pattern on a face running along X (constant Y).
module ribs_x_face(x_min, x_max, face_y, dir, h) {
    n = max(2, floor((x_max - x_min - 2*rib_margin) / rib_spacing) + 1);
    span = (n - 1) * rib_spacing;
    x_start = (x_min + x_max) / 2 - span / 2;
    for (i = [0 : n - 1])
        translate([x_start + i * rib_spacing - rib_width/2,
                   dir > 0 ? face_y - 0.01 : face_y - rib_depth,
                   -0.01])
            cube([rib_width, rib_depth + 0.01, h + 0.02]);
}

// Vertical groove pattern on a face running along Y (constant X).
module ribs_y_face(y_min, y_max, face_x, dir, h) {
    n = max(2, floor((y_max - y_min - 2*rib_margin) / rib_spacing) + 1);
    span = (n - 1) * rib_spacing;
    y_start = (y_min + y_max) / 2 - span / 2;
    for (i = [0 : n - 1])
        translate([dir > 0 ? face_x - 0.01 : face_x - rib_depth,
                   y_start + i * rib_spacing - rib_width/2,
                   -0.01])
            cube([rib_depth + 0.01, rib_width, h + 0.02]);
}

// One half of the interleaved barrel, centred on the local Z axis.
// role 0 → even segments (frame side); role 1 → odd segments (door side).
module hinge_barrel(role) {
    seg = wall_h / hinge_n;
    for (i = [0 : hinge_n - 1])
        if (i % 2 == role)
            translate([0, 0, i*seg + hinge_gap/2])
                difference() {
                    cylinder(d = hinge_d, h = seg - hinge_gap);
                    translate([0, 0, -1])
                        cylinder(d = pin_d, h = seg + 2);
                }
}

// Frame-side knuckles for the LEFT door + a web tying them into the
// left wall. Axis at (hinge_axis_x, hinge_axis_y).
module frame_hinge_left() {
    translate([hinge_axis_x, hinge_axis_y, 0]) hinge_barrel(0);
    // Web: bridges the barrel (Y around the axis) back into the wall (Y >= 0).
    seg = wall_h / hinge_n;
    for (i = [0 : hinge_n - 1])
        if (i % 2 == 0)
            translate([hinge_axis_x, hinge_axis_y - 1.6, i*seg + hinge_gap/2])
                cube([wall - hinge_axis_x + 0.01, 3.2, seg - hinge_gap]);
}

/* ── Body ────────────────────────────────────────────── */
module cab_body() {
    difference() {
        union() {
            // Floor
            rbox(ew, ed, flr, r = 3);
            // Left + right side walls (full height)
            cube([wall, ed, wall_h]);
            translate([ew - wall, 0, 0]) cube([wall, ed, wall_h]);
            // Back wall
            translate([0, ed - wall, 0]) cube([ew, wall, wall_h]);
            // Front top lintel — ties the side walls together
            translate([0, 0, wall_h - lintel_h]) cube([ew, wall, lintel_h]);
            // Hinge knuckles at both front corners
            frame_hinge_left();
            translate([ew, 0, 0]) mirror([1, 0, 0]) frame_hinge_left();
        }
        // Dock well
        translate([dock_cx, dock_cy, flr])
            cylinder(d = dock_d, h = dock_h + 1);
        // Cable cutout — back of the well, out through the rear wall
        cable_y0 = dock_cy + dock_d/2 - 1;
        translate([dock_cx - cable_w/2, cable_y0, flr])
            cube([cable_w, ed - cable_y0 + 1, cable_h]);
        // Exterior ribs — side walls + back wall
        ribs_y_face(0, ed, 0,  +1, wall_h);
        ribs_y_face(0, ed, ew, -1, wall_h);
        ribs_x_face(0, ew, ed, -1, wall_h);
    }
}

/* ── Door (left leaf) ────────────────────────────────── */
module door_left() {
    seg = wall_h / hinge_n;
    difference() {
        union() {
            // Leaf
            translate([leaf_x0, -door_th, 0])
                cube([leaf_x1 - leaf_x0, door_th, wall_h]);
            // Door-side knuckles
            translate([hinge_axis_x, hinge_axis_y, 0]) hinge_barrel(1);
            // Webs tying the knuckles to the leaf (odd segments, kept in front
            // of the box at Y < 0 so they clear the wall)
            for (i = [0 : hinge_n - 1])
                if (i % 2 == 1)
                    translate([hinge_axis_x, -door_th, i*seg + hinge_gap/2])
                        cube([leaf_x0 - hinge_axis_x + 0.5, door_th, seg - hinge_gap]);
        }
        // Magnet catches in the meeting stile (drilled in from the centre edge)
        for (z = mag_z)
            translate([leaf_x1 + 0.01, -door_th/2, z])
                rotate([0, -90, 0])
                    cylinder(d = mag_d, h = mag_h + 0.6);
        // Finger scallop on the outer face near the meeting edge
        translate([leaf_x1 - 12, -door_th - 6, wall_h*0.42])
            cylinder(r = 8, h = wall_h*0.16);
        // Ribs on the leaf's outer face
        ribs_x_face(leaf_x0, leaf_x1, -door_th, +1, wall_h);
    }
}

/* ── Roof (drop-on cap) ──────────────────────────────── */
module cab_roof() {
    lip = 10;
    union() {
        rbox(ew, ed, wall, r = 3);
        // Registration lip dropping into the top opening
        translate([wall + 0.4, wall + 0.4, -lip])
            cube([iw - 0.8, idp - 0.8, lip + 0.01]);
    }
}

/* ── Render ──────────────────────────────────────────── */
if (part == "body") cab_body();
if (part == "door") door_left();
if (part == "roof") cab_roof();

/* ── Summary ─────────────────────────────────────────── */
echo(str("Part            : ", part));
echo(str("Exterior        : ", ew, " × ", ed, " × ", wall_h + wall, " mm"));
echo(str("Interior        : ", iw, " × ", idp, " × ", ih, " mm"));
echo(str("Leaf            : ", leaf_x1 - leaf_x0, " × ", door_th, " × ", wall_h, " mm"));
echo("Hinge pin       : 3 mm steel rod / filament, bore 3.2 mm");
echo("Magnets         : 4× 6 mm ø × 3 mm disc (2 per door, centre stiles)");
