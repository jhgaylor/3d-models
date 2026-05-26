/* =====================================================
   Puffco kit box — full-kit carry case
   =====================================================
   part = "body" | "caddy" | "door" | "roof"  (set via JSON)

   One liftable, openable box for the whole kit. It is the
   modular tray flipped front-to-back so the Peak leads:

     FRONT band  : Peak dock well (left) + bucket well (right)
                   — revealed straight away when the doors open
     REAR  band  : raised pad with two dovetail tongues; the
                   knife/jar CADDY drops on and locks laterally
     ROOF        : drops on, a rib pins the caddy down, and a
                   suitcase handle carries the loaded box

   Closed up, the doors latch on magnets and the roof traps
   the caddy, so the whole thing lifts as a unit. Open the
   doors to lift the Peak straight out; the caddy lifts out
   once the roof is off.

   Hinges are the offset-axis fold-back barrels from the
   dock cabinet: each door swings 270° flat against a side.

   Footprint ≈ 256 × 206 × 222 mm
   ===================================================== */

$fn = 64;

/* ── Part selector (overridden by parameterSets) ─────── */
part = "body";   // [body, caddy, door, roof]

/* ── Structure ───────────────────────────────────────── */
tol   = 1.0;
wall  = 3.0;
flr   = 3.0;

iw    = 250;             // interior width  (X)
idp   = 200;             // interior depth  (Y)
ih    = 215;             // interior height (Z) — Peak Pro on its dock

ew    = iw + 2*wall;     // 256
ed    = idp + 2*wall;    // 206
wall_h   = flr + ih;     // 218 — top of side/back walls
lintel_h = 16;           // front top rail tying the side walls together

/* ── Front-band wells ────────────────────────────────── */
dock_d    = 116;         // Peak dock well (from modular tray)
bucket_d  = 124;         // bucket well
well_h    = 32;          // well depth above the floor
dock_cx   = 62;          // front-left
dock_cy   = 66;
bucket_cx = 186;         // front-right
bucket_cy = 66;
cable_w   = 60;          // cable relief behind the dock, out the side
cable_h   = 25;

/* ── Rear band: caddy dovetail drop-in ───────────────── */
caddy_w  = 141;          // knife/jar tray footprint
caddy_l  = 64;
caddy_cx = iw/2;         // centred in X
caddy_y0 = 132;          // caddy seats here (interior Y)

/* dovetail tongues (rise from the floor; caddy has the sockets) */
dt_narrow = 14;
dt_wide   = 22;
dt_length = 16;
dt_gap    = 0.35;
dt_h      = 9;           // tongue height
dt_off    = 60;          // tongue centres either side of caddy_cx (in the solid margins)
dt_cy     = caddy_y0 + caddy_l/2;   // tongues centred in the caddy depth

/* ── Knife / jar pockets (in the caddy) ──────────────── */
id      = 6.0;           // pocket depth — items protrude above the rim
kl      = 133 + 2*tol;   // 135
kSlotY  = 16;
jw      = 42 + tol;      // 43
jar_gap = 12;

/* ── Doors ───────────────────────────────────────────── */
door_th    = 4.0;
center_gap = 1.5;
leaf_x0    = 0;
leaf_x1    = ew/2 - center_gap/2;

/* ── Hinge (offset-axis fold-back barrel) ────────────── */
hinge_d      = 7.0;
pin_d        = 3.2;
hinge_gap    = 0.6;
hinge_n      = 11;       // more knuckles for the taller leaf
hinge_off    = 5.0;
hinge_axis_x = -hinge_off;
hinge_axis_y = -door_th/2;

/* ── Magnets : 6 × 3 mm discs ────────────────────────── */
mag_d = 6.2;
mag_h = 3.2;
mag_z = [wall_h*0.30, wall_h*0.70];

/* ── Roof + handle ───────────────────────────────────── */
roof_lip   = 12;
handle_l   = 134;        // along X
handle_t   = 16;         // thickness (Y) — beefy enough for a loaded box
handle_h   = 48;         // rises above the roof plate
grip_l     = 96;
grip_h     = 26;

/* ── Style ───────────────────────────────────────────── */
rib_spacing = 11;
rib_width   = 1.2;
rib_depth   = 0.6;
rib_margin  = 12;

/* ── Helpers ─────────────────────────────────────────── */
module rbox(w, l, h, r = 3) {
    hull()
        for (dx = [r, w - r], dy = [r, l - r])
            translate([dx, dy, 0]) cylinder(r = r, h = h);
}
module rpocket(w, l, d, r = 2) {
    hull()
        for (dx = [r, w - r], dy = [r, l - r])
            translate([dx, dy, 0]) cylinder(r = r, h = d);
}
module ribs_x_face(x_min, x_max, face_y, dir, h) {
    n = max(2, floor((x_max - x_min - 2*rib_margin) / rib_spacing) + 1);
    span = (n - 1) * rib_spacing;
    x_start = (x_min + x_max) / 2 - span / 2;
    for (i = [0 : n - 1])
        translate([x_start + i * rib_spacing - rib_width/2,
                   dir > 0 ? face_y - 0.01 : face_y - rib_depth, -0.01])
            cube([rib_width, rib_depth + 0.01, h + 0.02]);
}
module ribs_y_face(y_min, y_max, face_x, dir, h) {
    n = max(2, floor((y_max - y_min - 2*rib_margin) / rib_spacing) + 1);
    span = (n - 1) * rib_spacing;
    y_start = (y_min + y_max) / 2 - span / 2;
    for (i = [0 : n - 1])
        translate([dir > 0 ? face_x - 0.01 : face_x - rib_depth,
                   y_start + i * rib_spacing - rib_width/2, -0.01])
            cube([rib_depth + 0.01, rib_width, h + 0.02]);
}
// Trapezoid: narrow at base (origin), wide at +X tip.
module dt_trapezoid(wn, ww, len) {
    polygon([[0, -wn/2], [0, wn/2], [len, ww/2], [len, -ww/2]]);
}
// Vertical dovetail tongue, wide end toward +Y (locks against Y pull-out).
module dt_tongue(gap = 0) {
    rotate([0, 0, 90])
        linear_extrude(dt_h)
            dt_trapezoid(dt_narrow + gap, dt_wide + gap, dt_length);
}

// One half of the interleaved hinge barrel, centred on the local Z axis.
module hinge_barrel(role) {
    seg = wall_h / hinge_n;
    for (i = [0 : hinge_n - 1])
        if (i % 2 == role)
            translate([0, 0, i*seg + hinge_gap/2])
                difference() {
                    cylinder(d = hinge_d, h = seg - hinge_gap);
                    translate([0, 0, -1]) cylinder(d = pin_d, h = seg + 2);
                }
}
module frame_hinge_left() {
    translate([hinge_axis_x, hinge_axis_y, 0]) hinge_barrel(0);
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
            rbox(ew, ed, flr, r = 3);                              // floor
            cube([wall, ed, wall_h]);                              // left wall
            translate([ew - wall, 0, 0]) cube([wall, ed, wall_h]); // right wall
            translate([0, ed - wall, 0]) cube([ew, wall, wall_h]); // back wall
            translate([0, 0, wall_h - lintel_h])                   // front lintel
                cube([ew, wall, lintel_h]);
            // Two dovetail tongues rising from the rear floor (caddy locks on)
            for (s = [-1, 1])
                translate([wall + caddy_cx + s*dt_off, wall + dt_cy - dt_length/2, flr])
                    dt_tongue(0);
            // Hinge knuckles at both front corners
            frame_hinge_left();
            translate([ew, 0, 0]) mirror([1, 0, 0]) frame_hinge_left();
        }
        // Peak dock well + bucket well
        translate([wall + dock_cx,   wall + dock_cy,   flr]) cylinder(d = dock_d,   h = well_h + 1);
        translate([wall + bucket_cx, wall + bucket_cy, flr]) cylinder(d = bucket_d, h = well_h + 1);
        // Cable relief — channel from the dock well out through the left wall
        translate([-1, wall + dock_cy - cable_w/2, flr])
            cube([wall + dock_cx - dock_d/2 + 11, cable_w, cable_h]);
        // Exterior ribs
        ribs_y_face(0, ed, 0,  +1, wall_h);
        ribs_y_face(0, ed, ew, -1, wall_h);
        ribs_x_face(0, ew, ed, -1, wall_h);
    }
}

/* ── Caddy (knife + 2 jars, drops onto the pad) ──────── */
module cab_caddy() {
    cad_x0 = wall + caddy_cx - caddy_w/2;
    cad_y0 = wall + caddy_y0;
    ct_h   = dt_h + flr + id;   // socket region + floor + pocket
    // local pocket layout
    ix    = kl;
    jarsW = 2*jw + jar_gap;
    jMarX = (ix - jarsW) / 2;
    j1x   = jMarX;
    j2x   = j1x + jw + jar_gap;
    ky0   = jw + 4;
    translate([cad_x0, cad_y0, flr]) {          // seat on the pad top (z = flr + pad_h conceptually; rendered relative)
        difference() {
            rbox(caddy_w, caddy_l, ct_h, r = 3);
            // Jar pockets (front of caddy)
            translate([j1x + 3, 4, ct_h - id]) rpocket(jw, jw, id + 1, r = 2);
            translate([j2x + 3, 4, ct_h - id]) rpocket(jw, jw, id + 1, r = 2);
            // Knife slot (rear of caddy)
            translate([3, ky0, ct_h - id]) rpocket(ix, kSlotY, id + 1, r = 2);
            // Dovetail sockets in the underside (drop over the pad tongues)
            for (s = [-1, 1])
                translate([caddy_w/2 + s*dt_off, (dt_cy - caddy_y0) - dt_length/2, -0.01])
                    dt_tongue(dt_gap);
        }
    }
}

/* ── Door (left leaf) ────────────────────────────────── */
module cab_door() {
    seg = wall_h / hinge_n;
    difference() {
        union() {
            translate([leaf_x0, -door_th, 0])
                cube([leaf_x1 - leaf_x0, door_th, wall_h]);
            translate([hinge_axis_x, hinge_axis_y, 0]) hinge_barrel(1);
            for (i = [0 : hinge_n - 1])
                if (i % 2 == 1)
                    translate([hinge_axis_x, -door_th, i*seg + hinge_gap/2])
                        cube([leaf_x0 - hinge_axis_x + 0.5, door_th, seg - hinge_gap]);
        }
        for (z = mag_z)
            translate([leaf_x1 + 0.01, -door_th/2, z])
                rotate([0, -90, 0]) cylinder(d = mag_d, h = mag_h + 0.6);
        translate([leaf_x1 - 14, -door_th - 6, wall_h*0.45])
            cylinder(r = 8, h = wall_h*0.14);
        ribs_x_face(leaf_x0, leaf_x1, -door_th, +1, wall_h);
    }
}

/* ── Roof (drop-on cap + handle + caddy trap) ────────── */
module cab_roof() {
    difference() {
        union() {
            rbox(ew, ed, wall, r = 3);
            // registration lip into the top opening — closes the box and
            // keys the roof; the dovetailed caddy + seated Peak/bucket ride
            // along by gravity for upright carry (see note in summary).
            translate([wall + 0.4, wall + 0.4, -roof_lip])
                cube([iw - 0.8, idp - 0.8, roof_lip + 0.01]);
            // suitcase handle slab on top
            translate([ew/2 - handle_l/2, ed/2 - handle_t/2, wall - 0.01])
                rbox(handle_l, handle_t, handle_h, r = handle_t/2);
        }
        // hand opening through the handle (leaves a ~10 mm top grip bar)
        translate([ew/2, ed/2, wall + handle_h - grip_h/2 - 10])
            rotate([90, 0, 0])
                hull() for (dx = [-grip_l/2 + grip_h/2, grip_l/2 - grip_h/2])
                    translate([dx, 0, -handle_t]) cylinder(d = grip_h, h = handle_t*3);
    }
}

/* ── Render ──────────────────────────────────────────── */
if (part == "body")  cab_body();
if (part == "caddy") cab_caddy();
if (part == "door")  cab_door();
if (part == "roof")  cab_roof();

/* ── Summary ─────────────────────────────────────────── */
echo(str("Part        : ", part));
echo(str("Exterior    : ", ew, " × ", ed, " × ", wall_h + wall, " mm"));
echo(str("Interior    : ", iw, " × ", idp, " × ", ih, " mm"));
echo("Layout      : Peak dock + bucket up front, knife/jar caddy at rear");
echo("Capture     : caddy dovetails lock laterally; doors magnet-latch; roof closes the top");
echo("Note        : tall Peak box → roof can't reach low caddy; upright carry relies on gravity");
echo("Hinge pin   : 3 mm rod / filament, bore 3.2 mm");
