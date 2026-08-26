/* =====================================================
   Trapezoid Plate (solid)
   =====================================================
   Isosceles trapezoid, extruded to a flat solid plate.
   Dimensions are specified in inches and converted to mm.

   Height (bottom edge → top edge) : 4.5 in  (114.3 mm)
   Bottom edge length              : 4.6 in  (116.84 mm)
   Top edge length                 : 2.6 in  ( 66.04 mm)
   Thickness                       : 1/8 in  (  3.175 mm)

   Prints flat on the bed, no supports.
   ===================================================== */

in = 25.4;   // mm per inch

/* ── Dimensions (inches) ─────────────────────────────── */
height_in    = 4.5;      // bottom edge to top edge
bottom_in    = 4.6;      // bottom edge length
top_in       = 2.6;      // top edge length
thickness_in = 1/8;      // plate thickness

/* ── Derived (mm) ────────────────────────────────────── */
H = height_in    * in;
B = bottom_in    * in;
T = top_in       * in;
Z = thickness_in * in;

module trapezoid_plate() {
    // Centered on X so the shape is symmetric; bottom edge on Y = 0.
    linear_extrude(height = Z)
        polygon([
            [-B/2, 0],
            [ B/2, 0],
            [ T/2, H],
            [-T/2, H],
        ]);
}

trapezoid_plate();
