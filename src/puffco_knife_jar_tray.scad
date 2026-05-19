/* =====================================================
   Puffco Hot Knife (041879) + 2× Square Jar Tray & Lid
   =====================================================
   part = "tray" | "lid"  (set via parameterSets JSON)

   Knife   : rectangular prism, ~12×12 mm × 133 mm
   Jars    : 42×42 mm footprint, 24 mm tall (with lid)
   Magnets : 4× neodymium disc 6 mm ø × 3 mm thick
             Standard N52 6×3 mm discs are ideal.
             Press-fit into pockets. When assembling the
             lid, ensure each magnet opposes the polarity
             of its counterpart in the tray (they should
             attract, not repel).

   Tray exterior : 141 × 68 × 9 mm
   Lid  exterior : 141 × 68 × 5 mm
   Knife above rim : ~6 mm   → easy middle-body grip
   Jars  above rim : ~18 mm  → easily pinched over rim
   ===================================================== */

$fn = 64;

/* ── Part selector (overridden by parameterSets) ─────── */
part = "tray";   // "tray" | "lid"

/* ── Structure ───────────────────────────────────────── */
tol  = 1.0;
wall = 3.0;
flr  = 3.0;
id   = 6.0;          // interior slot depth → items protrude above rim
ez   = flr + id;     // 9 mm tray height

/* ── Knife slot (rectangular — matches flat-faced body) ─ */
kl     = 133 + 2*tol;   // 135 mm – along X
kw     = 12  + 2*tol;   // 14  mm – across Y
kSlotY = kw + 2;         // 16  mm – Y footprint with wiggle room

/* ── Jar slots ───────────────────────────────────────── */
jw      = 42 + tol;   // 43 mm – square footprint
jar_gap = 12;          // gap between the two jar slots

/* ── Interior / exterior ─────────────────────────────── */
ix = kl;                       // 135 mm – knife drives X
iy = jw + wall + kSlotY;       //  62 mm

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
   Four pockets, 2 on each side of the jar section, placed
   in the solid margin strips that flank the jar slots.     */
mag_d  = 6.2;   // pocket ø  (0.2 mm press-fit clearance)
mag_h  = 3.2;   // pocket depth (magnet + 0.2 mm clearance)

// X centres: middle of each margin strip
mag_lx = wall + jMarX / 2;
mag_rx = j2x + jw + jMarX / 2;

// Y centres: 28 % and 72 % of the jar slot depth
mag_fy = wall + jw * 0.28;
mag_by = wall + jw * 0.72;

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

        // Knife slot – rear, full interior X, rectangular
        translate([kx0, ky0, flr])
            rpocket(ix, kSlotY, id + 1, r = 2);

        // Magnet pockets – recessed into top face
        for (m = magnets)
            translate([m[0], m[1], ez - mag_h])
                cylinder(d = mag_d, h = mag_h + 1);
    }
}

/* ── Lid ─────────────────────────────────────────────── */
lid_h = 5.0;   // thick enough for 3.2 mm pocket + 1.8 mm cap

module make_lid() {
    difference() {
        rbox(ex, ey, lid_h, r = 3);

        // Magnet pockets – recessed into bottom face
        // (same XY positions; opposite polarity to tray magnets)
        for (m = magnets)
            translate([m[0], m[1], -1])
                cylinder(d = mag_d, h = mag_h + 1);
    }
}

/* ── Render ──────────────────────────────────────────── */
if (part == "tray") make_tray();
if (part == "lid")  make_lid();

/* ── Console summary ─────────────────────────────────── */
echo(str("Part            : ", part));
echo(str("Exterior (XY)   : ", ex, " × ", ey, " mm"));
echo(str("Tray height     : ", ez, " mm"));
echo(str("Lid  height     : ", lid_h, " mm"));
echo(str("Jar gap         : ", jar_gap, " mm"));
echo(str("Knife above rim : ~", 12 - id, " mm"));
echo(str("Jars  above rim : ~", 24 - id, " mm"));
echo("Magnet spec     : 4× neodymium disc 6 mm ø × 3 mm thick");
