/* =====================================================
   Band (plain ring)
   =====================================================
   A thin cylindrical band.

   Inner diameter : 120 mm
   Height         : 3/4 in (19.05 mm)
   Wall           : 2.0 mm. That's 5 perimeters with a 0.4 mm
                    nozzle, so it prints solid wall-only. At this
                    diameter it holds its round without being
                    rigid. 1.6 mm is the practical minimum; go
                    up to 2.4–3 mm if it needs to resist squeezing.

   Prints standing on its edge, no supports. Small chamfers
   on both edges keep it from feeling sharp and hide
   elephant's foot.
   ===================================================== */

$fn = 360;

/* ── Dimensions (mm) ────────────────────────────────── */
id      = 120;
height  = 0.75 * 25.4;
wall    = 2.0;
chamfer = 0.4;

/* ── Derived ────────────────────────────────────────── */
ri = id / 2;
ro = ri + wall;
c  = chamfer;

module band() {
    rotate_extrude()
        polygon([
            [ri + c, 0], [ro - c, 0], [ro, c],
            [ro, height - c], [ro - c, height], [ri + c, height],
            [ri, height - c], [ri, c],
        ]);
}

band();
