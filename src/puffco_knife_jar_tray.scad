/* =====================================================
   Puffco Hot Knife (041879) + 2× Square Jar Tray & Lid
   =====================================================
   part = "tray" | "lid"  (set via parameterSets JSON)

   Knife   : rectangular prism, ~12×12 mm × 133 mm
   Jars    : 42×42 mm footprint, 24 mm tall (with lid)
   Magnets : 4× neodymium disc 6 mm ø × 3 mm thick
             See src/puffco_knife_jar_tray.md for assembly.

   Tray exterior : 141 × 68 ×  9 mm
   Lid  exterior : 141 × 68 × 23 mm  (box that fits over loaded tray)

   Lid interior recesses:
     Jars  → 20 mm deep (18 mm protrusion + 2 mm clearance)
     Knife →  8 mm deep ( 6 mm protrusion + 2 mm clearance)
   ===================================================== */

$fn = 64;

/* ── Part selector (overridden by parameterSets) ─────── */
part = "tray";   // "tray" | "lid"

/* ── Structure ───────────────────────────────────────── */
tol  = 1.0;
wall = 3.0;
flr  = 3.0;
id   = 6.0;       // tray slot depth — items protrude above rim
ez   = flr + id;  // 9 mm tray height

/* ── Knife slot (rectangular — matches flat-faced body) ─ */
kl     = 133 + 2*tol;   // 135 mm – along X
kw     = 12  + 2*tol;   // 14  mm – across Y
kSlotY = kw + 2;         // 16  mm – Y footprint with wiggle room

/* ── Jar slots ───────────────────────────────────────── */
jw      = 42 + tol;   // 43 mm – square footprint
jar_gap = 12;          // gap between the two jar slots

/* ── Interior / exterior ─────────────────────────────── */
ix = kl;                      // 135 mm – knife drives X
iy = jw + wall + kSlotY;      //  62 mm

ex = ix + 2*wall;   // 141 mm
ey = iy + 2*wall;   //  68 mm

/* ── Slot positions (world coords) ───────────────────────
   Jars at front (small Y), knife slot at rear (large Y).  */
jSecY = wall;
jarsW = 2*jw + jar_gap;
jMarX = (ix - jarsW) / 2;   // solid margin beside each jar column
j1x   = wall + jMarX;
j2x   = j1x + jw + jar_gap;

ky0 = wall + jw + wall;
kx0 = wall;

/* ── Magnets : 6 × 3 mm neodymium discs ─────────────────
   Four pockets, 2 on each side of the jar section, in the
   solid margin strips flanking the jar slots.
   See src/puffco_knife_jar_tray.md for assembly details.   */
mag_d = 6.2;   // pocket ø  (0.2 mm press-fit clearance)
mag_h = 3.2;   // pocket depth (magnet + 0.2 mm clearance)

mag_lx = wall + jMarX / 2;       // X centre of left margin strip
mag_rx = j2x + jw + jMarX / 2;   // X centre of right margin strip
mag_fy = wall + jw * 0.28;       // Y at ~28 % of jar section depth
mag_by = wall + jw * 0.72;       // Y at ~72 % of jar section depth

magnets = [
    [mag_lx, mag_fy],
    [mag_lx, mag_by],
    [mag_rx, mag_fy],
    [mag_rx, mag_by],
];

/* ── Helpers ─────────────────────────────────────────── */
module rpocket(w, l, d, r = 2) {
    hull()
        for (dx = [r, w - r], dy = [r, l - r])
            translate([dx, dy, 0]) cylinder(r = r, h = d);
}

module rbox(w, l, h, r = 3) {
    hull()
        for (dx = [r, w - r], dy = [r, l - r])
            translate([dx, dy, 0]) cylinder(r = r, h = h);
}

/* ── Tray ────────────────────────────────────────────── */
module make_tray() {
    difference() {
        rbox(ex, ey, ez, r = 3);

        // Jar slot 1 – front left
        translate([j1x, jSecY, flr])
            rpocket(jw, jw, id + 1, r = 2);

        // Jar slot 2 – front right
        translate([j2x, jSecY, flr])
            rpocket(jw, jw, id + 1, r = 2);

        // Knife slot – rear, rectangular, full interior X
        translate([kx0, ky0, flr])
            rpocket(ix, kSlotY, id + 1, r = 2);

        // Magnet pockets – recessed into top face
        for (m = magnets)
            translate([m[0], m[1], ez - mag_h])
                cylinder(d = mag_d, h = mag_h + 1);
    }
}

/* ── Lid ─────────────────────────────────────────────────
   Box-style cover. Sits on the tray's top rim and encloses
   all items. Internal recesses nest over protruding items.
   Magnets in the bottom face align with the tray's pockets. */
jar_protrusion   = 24 - id;   // 18 mm — jars above tray rim
knife_protrusion = 12 - id;   //  6 mm — knife above tray rim
jar_clr          = 2;         // clearance above jars
knife_clr        = 2;         // clearance above knife

jar_recess   = jar_protrusion   + jar_clr;    // 20 mm from lid bottom
knife_recess = knife_protrusion + knife_clr;  //  8 mm from lid bottom

lid_top = 3.0;                        // top plate thickness
lid_h   = lid_top + jar_recess;       // 23 mm total lid height

module make_lid() {
    difference() {
        rbox(ex, ey, lid_h, r = 3);

        // Jar recess 1 – open from bottom, 20 mm deep
        translate([j1x, jSecY, -1])
            rpocket(jw, jw, jar_recess + 1, r = 2);

        // Jar recess 2 – open from bottom, 20 mm deep
        translate([j2x, jSecY, -1])
            rpocket(jw, jw, jar_recess + 1, r = 2);

        // Knife recess – open from bottom, 8 mm deep
        translate([kx0, ky0, -1])
            rpocket(ix, kSlotY, knife_recess + 1, r = 2);

        // Magnet pockets – recessed into bottom face, same XY as tray
        for (m = magnets)
            translate([m[0], m[1], -1])
                cylinder(d = mag_d, h = mag_h + 1);
    }
}

/* ── Render ──────────────────────────────────────────── */
if (part == "tray") make_tray();
if (part == "lid")  make_lid();

/* ── Console summary ─────────────────────────────────── */
echo(str("Part              : ", part));
echo(str("Tray exterior     : ", ex, " × ", ey, " × ", ez, " mm"));
echo(str("Lid  exterior     : ", ex, " × ", ey, " × ", lid_h, " mm"));
echo(str("Jar gap           : ", jar_gap, " mm"));
echo(str("Knife above rim   : ~", knife_protrusion, " mm"));
echo(str("Jars  above rim   : ~", jar_protrusion,   " mm"));
echo(str("Lid jar recess    : ", jar_recess,   " mm deep"));
echo(str("Lid knife recess  : ", knife_recess, " mm deep"));
echo("Magnet spec       : 4× neodymium disc 6 mm ø × 3 mm thick");
