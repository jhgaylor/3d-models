/* =====================================================
   Tray v2 – Puffco Hot Knife (model 041879) + 2× Square Jars
   =====================================================
   Knife : rectangular prism, ~12×12 mm cross-section, 133 mm long
           (cap always on; sits flat, button-face up)
   Jars  : 42×42 mm footprint, 24 mm tall with lid

   Design intent
   ─────────────
   • Shallow tray (9 mm total) so items protrude well above the rim —
     no finger-scoop cutouts needed because 9 mm walls can't block a hand.
   • Knife slot 6 mm deep → knife sticks up ~6 mm, easy middle-body grip.
   • Jar slots 6 mm deep  → jars stick up 18 mm, trivially pinched from
     any side over the low rim.
   • Rectangular knife slot matches the knife's actual flat-faced profile.

   Exterior: 141 × 68 × 9 mm
   ===================================================== */

$fn = 64;

/* ── Fit & structure ─────────────────────────────────── */
tol  = 1.0;   // per-side clearance (mm)
wall = 3.0;   // wall / divider thickness (mm)
flr  = 3.0;   // floor thickness (mm)
id   = 6.0;   // interior slot depth (mm) — drives tray height
ez   = flr + id;   // 9 mm total tray height

/* ── Knife slot ─────────────────────────────────────────
   Knife cross-section ~12×12 mm; slot is rectangular to
   match its flat faces. The 6 mm depth leaves ~6 mm proud
   of the rim — enough to grip at the body's mid-point.    */
kl    = 133 + 2*tol;   // 135 mm – slot length, along X
kw    = 12  + 2*tol;   // 14  mm – slot width,  along Y
kSlotY = kw + 2;       // 16  mm – Y footprint (little extra room)

/* ── Jar slots ───────────────────────────────────────── */
jw   = 42 + tol;       // 43 mm – square footprint with tolerance

/* ── Interior footprint ─────────────────────────────────
   X : knife length drives it  →  135 mm
   Y : jars (front) + divider + knife slot (rear)
       = 43 + 3 + 16 = 62 mm
   ──────────────────────────────────────────────────── */
ix = kl;                        // 135 mm
iy = jw + wall + kSlotY;        //  62 mm

/* ── Exterior box ────────────────────────────────────── */
ex = ix + 2*wall;   // 141 mm
ey = iy + 2*wall;   //  68 mm

/* ── Slot positions (world coords) ──────────────────────
   Jars : front (small-Y side), centred in X
   Knife: rear  (large-Y side), full interior X
   ──────────────────────────────────────────────────── */
jSecY = wall;                    //  3 mm – jar slots start here

jarsW  = 2*jw + wall;           // 89 mm – two jars + one divider
jMarX  = (ix - jarsW) / 2;     // 23 mm – X margin each side
j1x    = wall + jMarX;          // 26 mm
j2x    = j1x + jw + wall;       // 72 mm

ky0   = wall + jw + wall;       // 49 mm – knife slot starts here
kx0   = wall;                   //  3 mm

/* ── Helpers ─────────────────────────────────────────── */

// Rounded-corner rectangular pocket (cut from above)
module rpocket(w, l, d, r = 2) {
    hull()
        for (dx = [r, w - r], dy = [r, l - r])
            translate([dx, dy, 0]) cylinder(r = r, h = d);
}

// Rounded-corner solid box (outer body)
module rbox(w, l, h, r = 3) {
    hull()
        for (dx = [r, w - r], dy = [r, l - r])
            translate([dx, dy, 0]) cylinder(r = r, h = h);
}

/* ── Tray ────────────────────────────────────────────── */
difference() {
    rbox(ex, ey, ez, r = 3);

    // ── Jar slot 1 (front-left, centred in X) ─────────
    translate([j1x, jSecY, flr])
        rpocket(jw, jw, id + 1, r = 2);

    // ── Jar slot 2 (front-right, centred in X) ────────
    translate([j2x, jSecY, flr])
        rpocket(jw, jw, id + 1, r = 2);

    // ── Knife slot (rear, rectangular, full interior X) ─
    translate([kx0, ky0, flr])
        rpocket(ix, kSlotY, id + 1, r = 2);
}

/* ── Console summary ─────────────────────────────────── */
echo(str("Exterior        : ", ex, " × ", ey, " × ", ez, " mm"));
echo(str("Knife slot      : ", kl, " × ", kSlotY, " mm, ", id, " mm deep"));
echo(str("Jar slots       : ", jw, " × ", jw,  " mm, ", id, " mm deep"));
echo(str("Knife above rim : ~", 12 - id, " mm"));
echo(str("Jars above rim  : ~", 24 - id, " mm"));
