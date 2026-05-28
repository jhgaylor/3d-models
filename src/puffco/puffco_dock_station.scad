/* =====================================================
   Puffco Peak dock station — one tray, one cloche lid
   =====================================================
   part = "tray" | "lid"  (set via parameterSets JSON)

   Everything in one low tray:
     • Peak charging dock well   (back-left)
     • q-tip bucket well         (back-right)
     • 2× square jars            (front, centred)
     • hot knife                 (front, behind the jars)

   The lid drops over the whole tray. It is low (~51 mm)
   over the jars / knife / bucket, but rises into a tall
   tower over the dock corner so the Peak can stay docked
   and charging inside it. Cable exits the back, lid on
   or off.

   Footprint is set by the two big tubs (Ø116 dock +
   Ø124 bucket side-by-side) — ~250 × 195 mm is the floor.
   Tray is 35 mm at the back, 9 mm at the front; the lid
   tower is ~221 mm so a docked Peak Pro clears.

   Measure your own parts and tweak the ITEMS block.
   ===================================================== */

$fn = 64;

/* ── Part selector (overridden by parameterSets) ─────── */
part = "tray";   // [tray, lid]

/* ── Structure ───────────────────────────────────────── */
tol  = 1.0;
wall = 3.0;
flr  = 3.0;

/* ── ITEMS — measure & tweak ─────────────────────────── */
knife_l   = 133;   // hot knife length (along X)
knife_w   = 12;    // hot knife cross-section
jar_w     = 42;    // square jar footprint
jar_h     = 24;    // jar height incl. its own cap
jar_gap   = 12;    // gap between the two jars
dock_d    = 116;   // Peak charging-dock well Ø (incl. clearance)
bucket_d  = 124;   // q-tip bucket well Ø (incl. clearance)
bucket_h  = 40;    // short q-tip tub height
peak_tower_h = 215; // interior height above the floor for a docked Peak Pro

/* ── Well depths ─────────────────────────────────────── */
acc_depth    = 6;   // jar + knife pockets — items protrude above the rim
dock_depth   = 32;  // dock well (cradles the Peak base / charge puck)
bucket_depth = 32;  // bucket well — short tub protrudes ~8 mm to grab

/* ── Derived item slots ──────────────────────────────── */
kl     = knife_l + 2*tol;   // 135
kw     = knife_w + 2*tol;   // 14
kSlotY = kw + 2;            // 16
jw     = jar_w + tol;       // 43

/* ── Tray heights ────────────────────────────────────── */
front_h = flr + acc_depth;    //  9 — jar/knife band
back_h  = flr + dock_depth;   // 35 — dock/bucket band

/* ── Footprint: two tubs side-by-side drive the size ─── */
web       = 4;                                  // solid wall between the two tubs
dock_cx   = wall + dock_d/2;                    //  61 — back-left
bucket_cx = dock_cx + dock_d/2 + web + bucket_d/2;  // 185 — back-right
ex        = bucket_cx + bucket_d/2 + wall;      // 250

/* front band (Y): wall · jars · gap · knife · then a step up to the tubs */
jSecY   = wall;                                 //   3 — jars start
step_y  = wall + jw + 3 + kSlotY;               //  65 — front band depth / step line
circ_cy = step_y + 3 + bucket_d/2;              // 130 — both tub centres
ey      = circ_cy + bucket_d/2 + wall;          // 195

/* jars centred in X; knife centred behind them */
jarsW = 2*jw + jar_gap;                          // 98
j1x   = (ex - jarsW) / 2;                        // 76
j2x   = j1x + jw + jar_gap;                      // 131
kx0   = (ex - kl) / 2;                            // 57.5
ky0   = wall + jw + 3;                            // 49

/* ── Cable relief (out the back, behind the dock) ────── */
cable_w = 60;
cable_h = 25;

/* ── Lid (cloche: low cover + tall dock tower) ───────── */
lid_gap  = 0.4;                          // clearance around the tray, per side
lid_ex   = ex + 2*lid_gap + 2*wall;      // 256.8
lid_ey   = ey + 2*lid_gap + 2*wall;      // 201.8
lid_in_w = ex + 2*lid_gap;               // 250.8 — interior over the tray
lid_in_l = ey + 2*lid_gap;               // 195.8

// Size the low roof to clear the tallest item under it. Each item sits on a
// well floor (z = flr) and pokes up by (height − well depth) above its rim;
// the bucket (short tub in a 32 mm well) ends up the tallest.
low_clear    = 5;                                       // headroom under the low roof
bucket_above = (back_h  - bucket_depth) + bucket_h;     // 35-32+40 = 43 — tub top above floor
jar_above    = (front_h - acc_depth)    + jar_h;        //  9- 6+24 = 27 — jar top above floor
low_ceiling  = max(bucket_above, jar_above) + low_clear; // 48
low_ext_h    = low_ceiling + wall;                       // 51

tower_inner_top = flr + peak_tower_h;             // 218
tower_ext_h     = tower_inner_top + wall;         // 221

/* tower sits in the back-left corner, over the dock */
dock_lx  = wall + lid_gap + dock_cx;     //  64.4 — dock centre in lid frame
tower_x0 = 0;
tower_y0 = 70;                            // front face of the tower
tower_w  = 128;                           // covers the dock + clearance
tower_l  = lid_ey - tower_y0;             // 131.8 — back to the rear wall

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
// Vertical grooves on a face running along X (constant Y). dir +1: body in +Y.
module ribs_x_face(x_min, x_max, face_y, dir, h) {
    n = max(2, floor((x_max - x_min - 2*rib_margin) / rib_spacing) + 1);
    span = (n - 1) * rib_spacing;
    x_start = (x_min + x_max) / 2 - span / 2;
    for (i = [0 : n - 1])
        translate([x_start + i * rib_spacing - rib_width/2,
                   dir > 0 ? face_y - 0.01 : face_y - rib_depth, -0.01])
            cube([rib_width, rib_depth + 0.01, h + 0.02]);
}
// Vertical grooves on a face running along Y (constant X). dir +1: body in +X.
module ribs_y_face(y_min, y_max, face_x, dir, h) {
    n = max(2, floor((y_max - y_min - 2*rib_margin) / rib_spacing) + 1);
    span = (n - 1) * rib_spacing;
    y_start = (y_min + y_max) / 2 - span / 2;
    for (i = [0 : n - 1])
        translate([dir > 0 ? face_x - 0.01 : face_x - rib_depth,
                   y_start + i * rib_spacing - rib_width/2, -0.01])
            cube([rib_depth + 0.01, rib_width, h + 0.02]);
}

/* ── Tray ────────────────────────────────────────────── */
module make_tray() {
    difference() {
        rbox(ex, ey, back_h, r = 3);

        // Step the front band down to front_h (jars + knife sit low)
        translate([-1, -1, front_h])
            cube([ex + 2, step_y + 1, back_h]);

        // Jar pockets (front, centred)
        translate([j1x, jSecY, flr]) rpocket(jw, jw, acc_depth + 1, r = 2);
        translate([j2x, jSecY, flr]) rpocket(jw, jw, acc_depth + 1, r = 2);

        // Knife slot (front, behind the jars)
        translate([kx0, ky0, flr]) rpocket(kl, kSlotY, acc_depth + 1, r = 2);

        // Dock well (back-left) + bucket well (back-right)
        translate([dock_cx,   circ_cy, flr]) cylinder(d = dock_d,   h = dock_depth   + 1);
        translate([bucket_cx, circ_cy, flr]) cylinder(d = bucket_d, h = bucket_depth + 1);

        // Cable relief — slot through the back wall behind the dock
        translate([dock_cx - cable_w/2, circ_cy, flr])
            cube([cable_w, ey - circ_cy + 1, cable_h]);

        // Exterior ribs (grooves clip to whatever material exists, so the
        // stepped side faces are fine with a single full-height pass)
        ribs_x_face(0, ex, 0,  +1, front_h);   // front face (low)
        ribs_x_face(0, ex, ey, -1, back_h);    // back face
        ribs_y_face(0, ey, 0,  +1, back_h);    // left face
        ribs_y_face(0, ey, ex, -1, back_h);    // right face
    }
}

/* ── Lid (cloche) ────────────────────────────────────── */
module make_lid() {
    difference() {
        union() {
            rbox(lid_ex, lid_ey, low_ext_h, r = 3);                 // low shell
            translate([tower_x0, tower_y0, 0])                      // dock tower
                rbox(tower_w, tower_l, tower_ext_h, r = 3);
        }
        // Lower interior — full footprint, open bottom, up to the low ceiling
        translate([wall, wall, -1])
            rbox(lid_in_w, lid_in_l, low_ceiling + 1, r = 2);
        // Tower interior — narrows above the low ceiling, up to the tower top
        translate([tower_x0 + wall, tower_y0 + wall, -1])
            rbox(tower_w - 2*wall, tower_l - 2*wall, tower_inner_top + 1, r = 2);
        // Cable notch — back skirt, behind the dock, aligned with the tray slot
        translate([dock_lx - cable_w/2, lid_ey - wall - 1, 0])
            cube([cable_w, wall + 2, cable_h]);

        // Exterior ribs — tall on the back-left tower faces, low elsewhere
        ribs_y_face(0, lid_ey, 0,      +1, tower_ext_h);   // left  (tall over tower)
        ribs_x_face(0, lid_ex, lid_ey, -1, tower_ext_h);   // back  (tall over tower)
        ribs_y_face(0, lid_ey, lid_ex, -1, low_ext_h);     // right (low)
        ribs_x_face(0, lid_ex, 0,      +1, low_ext_h);     // front (low)
    }
}

/* ── Render ──────────────────────────────────────────── */
if (part == "tray") make_tray();
if (part == "lid")  make_lid();

/* ── Summary ─────────────────────────────────────────── */
echo(str("Part            : ", part));
echo(str("Tray footprint  : ", ex, " × ", ey, " mm  (front ", front_h, " / back ", back_h, " tall)"));
echo(str("Lid footprint   : ", lid_ex, " × ", lid_ey, " mm"));
echo(str("Low cover height: ", low_ext_h, " mm  (clears jars + ", bucket_above, " mm bucket)"));
echo(str("Dock tower      : ", tower_ext_h, " mm tall  → Peak stays docked & charging inside"));
echo(str("Cable           : ", cable_w, " × ", cable_h, " mm slot out the back, lid on or off"));
