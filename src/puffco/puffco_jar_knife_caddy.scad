/* =====================================================
   Puffco Jar + Knife Caddy — flip-top lid & qtip drawer
   =====================================================
   A standalone desk caddy (NOT part of the modular tray
   system). Four printed parts, selected via parameterSets:

     part = "carcass" | "deck" | "drawer" | "lid"

   Layout (front → back, bottom → top):
     • Bottom  : a pull-out DRAWER for cotton swabs / qtips
     • Middle  : the DECK — a drop-in tray seating 2 jars
                 (front) and the hot knife (rear)
     • Lid     : a flip-top cover hinged at the rear on a
                 3 mm pin; magnet-latched at the front

   Items (shared with puffco_knife_jar_tray):
     Knife   : ~133 × 12 mm  (model 041879)
     Jars    : 42 × 42 mm footprint, 24 mm tall (with lid)
     Magnets : 4× neodymium disc 6 mm ø × 3 mm thick
     Pin     : 1× 3 mm steel rod / filament, ~125 mm

   Footprint : 141 × 68 mm  (matches the original tray)
   ===================================================== */

$fn = 64;

/* ── Part selector (overridden by parameterSets) ─────── */
part = "carcass";   // [carcass, deck, drawer, lid]

/* ── Structure ───────────────────────────────────────── */
tol  = 1.0;     // fit tolerance around items
wall = 3.0;     // carcass / lid wall
flr  = 3.0;     // carcass bottom floor
clr  = 0.4;     // sliding & drop-in clearance

/* ── Items (same as the original knife + jar tray) ───── */
kl       = 133 + 2*tol;   // 135 — knife slot length (X)
kw       = 12  + 2*tol;   // 14  — knife slot width
kSlotY   = kw + 2;        // 16  — knife Y footprint
jw       = 42  + tol;     // 43  — square jar footprint
jar_gap  = 12;            // gap between the two jars
jar_tall = 24;            // jar height (with its own lid)
knife_tall = 12;          // knife body height

/* ── Deck (jar/knife tray) interior + exterior ───────── */
ix = kl;                   // 135 — knife drives interior X
iy = jw + wall + kSlotY;   //  62 — jars + wall + knife (Y)
ex = ix + 2*wall;          // 141 — exterior width
ey = iy + 2*wall;          //  68 — exterior depth

deck_id  = 6;                  // slot depth — items protrude above the rim
deck_flr = 3;                  // slot floor
deck_h   = deck_flr + deck_id; //   9 — deck plate thickness

/* ── Stack heights ───────────────────────────────────── */
cav_h   = 23;                  // drawer cavity height (Z)
ledge_z = flr + cav_h;         //  26 — top of drawer cavity / deck rests here
base_h  = ledge_z + deck_h;    //  35 — carcass rim & lid parting plane
ledge_w = 4;                   // side shelf the deck rests on

/* ── Slot positions (world coords, jars front / knife rear) */
jSecY  = wall;
jarsW  = 2*jw + jar_gap;            // 98
jMarX  = (ix - jarsW) / 2;          // 18.5 — solid margin beside the jars
j1x    = wall + jMarX;              // 21.5
j2x    = j1x + jw + jar_gap;        // 76.5
ky0    = wall + jw + wall;          // 49 — knife slot Y start
kx0    = wall;                      //  3 — knife slot X start

/* ── Magnets : 6 × 3 mm neodymium discs ──────────────────
   Two per side, in the solid margins flanking the jars —
   reuses the proven positions from puffco_knife_jar_tray.
   Deck pockets open up; lid pockets open down; they meet
   on the parting plane (z = base_h).                       */
mag_d  = 6.2;   // pocket ø  (0.2 mm press-fit clearance)
mag_h  = 3.2;   // pocket depth
mag_lx = wall + jMarX/2;          // 12.25
mag_rx = j2x + jw + jMarX/2;      // 128.75
mag_cy = wall + jw/2;             // 24.5
magnets = [ [mag_lx, mag_cy], [mag_rx, mag_cy] ];

/* ── Flip-top hinge (horizontal barrel along X, rear) ──── */
hinge_d      = 8.0;          // knuckle outer diameter
pin_d        = 3.2;          // pin bore (3 mm rod + clearance)
hinge_gap    = 0.6;          // axial gap between interleaved knuckles
hinge_n      = 7;            // segments (ends land on the carcass)
hinge_axis_y = ey + 1.5;     // just outboard of the back wall
hinge_axis_z = base_h;       // on the parting plane
hinge_x0     = 18;
hinge_x1     = ex - 18;      // 123

/* ── Lid recesses ────────────────────────────────────── */
jar_protr    = jar_tall   - deck_id;   // 18 — jars above the deck rim
knife_protr  = knife_tall - deck_id;   //  6 — knife above the deck rim
jar_clr      = 2;
knife_clr    = 2;
jar_recess   = jar_protr   + jar_clr;  // 20 — lid recess depth over jars
knife_recess = knife_protr + knife_clr;//  8 — lid recess depth over knife
lid_top      = 3.0;                    // top plate thickness
lid_h        = lid_top + jar_recess;   // 23 — total lid height

/* ── Drawer ──────────────────────────────────────────── */
dwall    = 2.0;             // drawer wall
dflr     = 2.0;             // drawer floor
flange_th = 3.0;            // front face thickness (sits proud of the body)

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

// Interleaved barrel knuckles along X at the rear axis.
// role 0 → carcass segments (also the two ends); role 1 → lid segments.
module hinge_knuckles(role) {
    seg = (hinge_x1 - hinge_x0) / hinge_n;
    for (i = [0 : hinge_n - 1])
        if (i % 2 == role)
            translate([hinge_x0 + i*seg + hinge_gap/2, hinge_axis_y, hinge_axis_z])
                rotate([0, 90, 0])
                    difference() {
                        cylinder(d = hinge_d, h = seg - hinge_gap);
                        translate([0, 0, -1]) cylinder(d = pin_d, h = seg + 2);
                    }
}

/* ── Carcass ─────────────────────────────────────────────
   Body of the caddy: floor, two side walls, back wall, an
   open front (drawer) and open top (deck drops in). The
   drawer cavity is narrower than the deck recess, leaving a
   4 mm shelf each side for the deck to rest on. Rear hinge
   knuckles (role 0) fuse to the back wall.                  */
module make_carcass() {
    difference() {
        union() {
            rbox(ex, ey, base_h, r = 3);
            hinge_knuckles(0);
        }
        // Drawer cavity — narrower, open at the front
        translate([wall + ledge_w, -1, flr])
            cube([ix - 2*ledge_w, (ey - wall) + 1, cav_h]);

        // Deck recess — wider, open at the front; deck sits on the shelves
        translate([wall, -1, ledge_z])
            cube([ix, (ey - wall) + 1, deck_h + 1]);

        // Trim the hinge bore line clean (knuckles already bored)
    }
}

/* ── Deck (drop-in jar + knife tray) ──────────────────────
   Rests on the carcass side shelves; its top is flush with
   the carcass rim. The knife channel runs the full width —
   the carcass side walls close its ends. Pockets sit at the
   same world coords as puffco_knife_jar_tray.               */
module make_deck() {
    difference() {
        translate([wall + clr, 0, ledge_z])
            cube([ix - 2*clr, (ey - wall) - clr, deck_h]);

        // Jar slot 1 — front left
        translate([j1x, jSecY, ledge_z + deck_flr])
            rpocket(jw, jw, deck_id + 1, r = 2);
        // Jar slot 2 — front right
        translate([j2x, jSecY, ledge_z + deck_flr])
            rpocket(jw, jw, deck_id + 1, r = 2);
        // Knife channel — rear, open ends (carcass walls cap it)
        translate([wall - 2, ky0, ledge_z + deck_flr])
            rpocket(ix + 4, kSlotY, deck_id + 1, r = 2);

        // Magnet pockets — open up toward the lid
        for (m = magnets)
            translate([m[0], m[1], base_h - mag_h])
                cylinder(d = mag_d, h = mag_h + 1);
    }
}

/* ── Drawer (qtip drawer) ────────────────────────────────
   Slides into the carcass from the front. A full-width
   flange closes the opening and carries a finger scallop.   */
module make_drawer() {
    bx0 = wall + ledge_w + clr;          // body left  (inside the cavity)
    bx1 = ex - wall - ledge_w - clr;     // body right
    bw  = bx1 - bx0;
    bd  = (ey - wall) - clr;             // body depth (front y=0 → back)
    bh  = cav_h - clr;                   // body height

    union() {
        // Tray body — floor + back/side walls, open top, front closed by flange
        difference() {
            translate([bx0, 0, flr]) cube([bw, bd, bh]);
            // hollow interior (leaves dwall on sides + back, dflr on bottom)
            translate([bx0 + dwall, -1, flr + dflr])
                cube([bw - 2*dwall, bd - dwall + 1, bh]);
        }
        // Front flange — proud of the body, covers the opening
        difference() {
            translate([wall - 1, -flange_th, 0])
                cube([ex - 2*wall + 2, flange_th, ledge_z]);
            // Finger scallop along the top edge of the flange
            translate([ex/2, -flange_th - 1, ledge_z + 6])
                rotate([-90, 0, 0])
                    cylinder(r = 11, h = flange_th + 2);
        }
    }
}

/* ── Lid (flip-top) ──────────────────────────────────────
   Box cover hinged at the rear (role 1 knuckles). Internal
   recesses nest over the protruding jars/knife. Magnet
   pockets in the bottom rim meet the deck's. Modelled in the
   closed position; print it upside-down (open face up).     */
module make_lid() {
    difference() {
        union() {
            translate([0, 0, base_h]) rbox(ex, ey, lid_h, r = 3);
            hinge_knuckles(1);
        }
        // Jar recesses — open downward from the rim
        translate([j1x, jSecY, base_h - 1]) rpocket(jw, jw, jar_recess + 1, r = 2);
        translate([j2x, jSecY, base_h - 1]) rpocket(jw, jw, jar_recess + 1, r = 2);
        // Knife recess — open downward from the rim
        translate([kx0, ky0, base_h - 1]) rpocket(ix, kSlotY, knife_recess + 1, r = 2);
        // Magnet pockets — open down toward the deck
        for (m = magnets)
            translate([m[0], m[1], base_h - 1])
                cylinder(d = mag_d, h = mag_h + 1);
    }
}

/* ── Render ──────────────────────────────────────────── */
if (part == "carcass") make_carcass();
if (part == "deck")    make_deck();
if (part == "drawer")  make_drawer();
if (part == "lid")     make_lid();

/* ── Console summary ─────────────────────────────────── */
echo(str("Part            : ", part));
echo(str("Footprint       : ", ex, " × ", ey, " mm"));
echo(str("Carcass height  : ", base_h, " mm (rim)"));
echo(str("Closed height   : ", base_h + lid_h, " mm (+ ~", hinge_d/2, " mm hinge at rear)"));
echo(str("Drawer interior : ~", ex - 2*wall - 2*ledge_w - 2*clr - 2*dwall,
         " × ", (ey - wall) - clr - dwall, " × ", cav_h - clr - dflr, " mm"));
echo("Hinge pin       : 1× 3 mm rod / filament, bore 3.2 mm");
echo("Magnets         : 4× 6 mm ø × 3 mm disc (2 deck, 2 lid)");
