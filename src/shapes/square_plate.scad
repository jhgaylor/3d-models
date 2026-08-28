/* =====================================================
   Square Plate (solid)
   =====================================================
   Flat square plate, extruded to a solid slab.
   Dimensions are specified in inches and converted to mm.

   Side length : 4.5 in  (114.3 mm)
   Thickness   : 1/8 in  (  3.175 mm)

   Prints flat on the bed, no supports.
   ===================================================== */

in = 25.4;   // mm per inch

/* ── Dimensions (inches) ─────────────────────────────── */
side_in      = 4.5;      // square edge length
thickness_in = 1/8;      // plate thickness

/* ── Derived (mm) ────────────────────────────────────── */
S = side_in      * in;
Z = thickness_in * in;

module square_plate() {
    // Centered on X/Y, sitting on Z = 0.
    linear_extrude(height = Z)
        square([S, S], center = true);
}

square_plate();
