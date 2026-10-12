/* =====================================================
   Regular Pentagon Plate (solid)
   =====================================================
   Regular pentagon, extruded to a flat solid plate.
   Dimensions are specified in inches and converted to mm.

   Side length : 2.363 in  (60.0202 mm)
   Thickness   : 1/8 in    ( 3.1750 mm)

   Prints flat on the bed, no supports.
   ===================================================== */

in = 25.4;   // mm per inch

/* ── Dimensions (inches) ────────────────────────────── */
side_in      = 2.363;    // length of each of the five sides
thickness_in = 1/8;      // plate thickness

/* ── Derived (mm) ───────────────────────────────── */
S = side_in      * in;
Z = thickness_in * in;
R = S / (2 * sin(180 / 5));  // circumradius

module pentagon_plate() {
    // Centered on X/Y, point-up with a flat bottom edge, sitting on Z = 0.
    linear_extrude(height = Z)
        polygon([
            for (i = [0 : 4])
                [R * cos(90 + i * 360 / 5),
                 R * sin(90 + i * 360 / 5)]
        ]);
}

pentagon_plate();
