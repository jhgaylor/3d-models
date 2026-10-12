/* =====================================================
   Irregular Pentagon Plate (solid)
   =====================================================
   Symmetric five-sided plate based on the supplied sketch.
   Dimensions are specified in inches and converted to mm.

   Upper sides        : 4.327 in  (109.9058 mm), each
   Lower sides        : 2.409 in  ( 61.1886 mm), each
   Bottom edge        : 2.255 in  ( 57.2770 mm)
   Bottom angles      : 126 degrees
   Thickness          : 1/8 in    (  3.1750 mm)

   The dimension rounding produces upper and apex angles of
   107.998 and 72.004 degrees, respectively (shown as 108 and
   72 degrees in the sketch).

   Prints flat on the bed, no supports.
   ===================================================== */

in = 25.4;   // mm per inch

/* ── Dimensions (inches/degrees) ────────────────── */
upper_side_in = 4.327;
lower_side_in = 2.409;
bottom_in     = 2.255;
bottom_angle  = 126;
thickness_in  = 1/8;

/* ── Derived (mm) ───────────────────────────────── */
U = upper_side_in * in;
L = lower_side_in * in;
B = bottom_in     * in;
Z = thickness_in  * in;

lower_rise_angle = 180 - bottom_angle;
shoulder_x = B/2 + L * cos(lower_rise_angle);
shoulder_y =       L * sin(lower_rise_angle);
apex_y = shoulder_y + sqrt(U*U - shoulder_x*shoulder_x);

module irregular_pentagon_plate() {
    // Symmetric on X, bottom edge on Y = 0, sitting on Z = 0.
    linear_extrude(height = Z)
        polygon([
            [-B/2,         0],
            [ B/2,         0],
            [ shoulder_x,  shoulder_y],
            [ 0,           apex_y],
            [-shoulder_x,  shoulder_y],
        ]);
}

irregular_pentagon_plate();
