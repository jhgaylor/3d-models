/* =====================================================
   Tray – Puffco Hot Knife (model 041879) + 2× Square Jars
   =====================================================
   Knife  : ~133 mm long, ~13 mm ø  (Puffco Hot Knife)
   Jars   : 42 × 42 mm, 24 mm deep (square, no lid)

   Layout (top view):
     [  knife channel – full width                    ]
     [ jar 1 (centered)  |  jar 2 (centered)          ]

   Exterior: 141 × 72 × 28 mm
   ===================================================== */

$fn = 64;

/* ── Tolerances & structure ─────────────────────────── */
tol  = 1.0;    // per-side fit tolerance (mm)
wall = 3.0;    // wall / divider thickness (mm)
flr  = 3.0;    // floor thickness (mm)

/* ── Knife slot dimensions ──────────────────────────── */
kl   = 133 + 2*tol;   // 135 mm  — slot runs along X
kw   = 13  + 2*tol;   // 15 mm   — slot width across Y
ksY  = kw + 5;        // 20 mm   — Y footprint of knife section (extra room to grab)

/* ── Jar slot dimensions ────────────────────────────── */
jw   = 42 + tol;      // 43 mm  — slot width/length (square)
jd   = 24 + tol;      // 25 mm  — slot depth

/* ── Interior depth (jars are the deepest item) ─────── */
id   = jd;            // 25 mm

/* ── Interior footprint ─────────────────────────────────
   X : driven by knife length  → 135 mm
   Y : knife section + divider + jar section
       = 20 + 3 + 43 = 66 mm
   ──────────────────────────────────────────────────── */
ix   = kl;                   // 135 mm
iy   = ksY + wall + jw;      //  66 mm

/* ── Exterior box ────────────────────────────────────── */
ex   = ix + 2*wall;   // 141 mm
ey   = iy + 2*wall;   //  72 mm
ez   = flr + id;      //  28 mm

/* ── Slot world-coordinate offsets ─────────────────────
   Knife section: Y = wall … wall+ksY
   Jar  section:  Y = wall+ksY+wall … ey-wall
   ──────────────────────────────────────────────────── */
kx0   = wall;
ky0   = wall;

jSecY = wall + ksY + wall;    //  26 mm from bottom edge

// Centre the two jars across the full interior X
jarsW  = 2*jw + wall;         //  89 mm  (two jars + one divider)
jMarX  = (ix - jarsW) / 2;   //  23 mm  margin each side
j1x    = wall + jMarX;        //  26 mm from left exterior edge
j2x    = j1x + jw + wall;     //  72 mm from left exterior edge

/* ── Finger hole diameters ──────────────────────────── */
kfh  = 13;    // knife finger hole ø — matches knife body ø
jfh  = 22;    // jar  finger hole ø

/* ── Helper: rounded-corner rectangular pocket ─────── */
module rpocket(w, l, d, r = 2.5) {
    hull()
        for (dx = [r, w - r], dy = [r, l - r])
            translate([dx, dy, 0])
                cylinder(r = r, h = d);
}

/* ── Corner rounding for outer body ─────────────────── */
module rounded_box(w, l, h, r = 3) {
    hull()
        for (dx = [r, w - r], dy = [r, l - r])
            translate([dx, dy, 0])
                cylinder(r = r, h = h);
}

/* ── Main tray ──────────────────────────────────────── */
difference() {

    // Outer body with slightly rounded corners
    rounded_box(ex, ey, ez, r = 3);

    // ── Knife channel ─────────────────────────────────
    // Runs the full interior X, shallow Y section at front
    translate([kx0, ky0, flr])
        rpocket(ix, ksY, id + 1, r = 2.5);

    // ── Jar slot 1 ────────────────────────────────────
    translate([j1x, jSecY, flr])
        rpocket(jw, jw, id + 1, r = 2.5);

    // ── Jar slot 2 ────────────────────────────────────
    translate([j2x, jSecY, flr])
        rpocket(jw, jw, id + 1, r = 2.5);

    // ── Finger hole – knife ───────────────────────────
    // Through-floor hole centred in knife slot
    // Lets you push the knife up / hook a fingertip under it
    translate([kx0 + ix/2, ky0 + ksY/2, -1])
        cylinder(d = kfh, h = flr + 2);

    // ── Finger hole – jar 1 ───────────────────────────
    translate([j1x + jw/2, jSecY + jw/2, -1])
        cylinder(d = jfh, h = flr + 2);

    // ── Finger hole – jar 2 ───────────────────────────
    translate([j2x + jw/2, jSecY + jw/2, -1])
        cylinder(d = jfh, h = flr + 2);
}

/* ── Dimensions echo (visible in console) ───────────── */
echo(str("Exterior: ", ex, " × ", ey, " × ", ez, " mm"));
echo(str("Knife slot: ", kl, " × ", ksY, " mm  depth: ", id, " mm"));
echo(str("Jar slots:  ", jw, " × ", jw, " mm  depth: ", id, " mm"));
echo(str("Jar finger hole ø: ", jfh, " mm"));
echo(str("Knife finger hole ø: ", kfh, " mm"));
