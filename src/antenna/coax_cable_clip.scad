/* =====================================================
   Coax cable clip
   =====================================================
   A snap-in clip for the coax hanging off the ClearStream
   Flex antenna. Stick it to the wall a few inches below the
   antenna, so the cable's weight hangs on the clip and doesn't
   peel the antenna's bottom edge off the wall.

   Cable (measured): Ø5

   The clip opens away from the wall with a flared mouth a bit
   narrower than the cable. Push the cable in and the ring
   flexes and snaps round it. The plate takes a small Command
   strip (16 x 46).

   Print it standing on end, with the ring's cross-section on
   the bed. The whole part is a straight extrusion, so there's
   nothing to overhang.

   Coordinates: X across (centred), Y out from the wall (plate
   front face at Y = 0), Z along the cable.
   ===================================================== */

$fa = 2;
$fs = 0.4;

/* ── Cable (measured) ───────────────────────────────── */
cable_d = 5;

/* ── Clip ───────────────────────────────────────────── */
clear   = 0.15;  // per side inside the ring
ring_t  = 1.8;   // ring wall
mouth   = 4.0;   // opening, narrower than the cable so it snaps
flare   = 1.5;   // lead-in each side at the outer edge
clip_l  = 16;    // ring length along the cable
plate_w = 20;
plate_l = 48;    // fits a small Command strip
plate_t = 2.5;

/* ── Derived ────────────────────────────────────────── */
ri = cable_d / 2 + clear;
ro = ri + ring_t;
cy = ro - 0.5;   // ring centre; the ring sinks 0.5 into the plate

assert(mouth < cable_d, "mouth must be narrower than the cable to snap");

module ring_2d() {
    difference() {
        translate([0, cy]) circle(r = ro);
        translate([0, cy]) circle(r = ri);
        // mouth, flaring out toward the open side
        polygon([[-mouth / 2, cy], [mouth / 2, cy],
                 [mouth / 2 + flare, cy + ro + 1], [-mouth / 2 - flare, cy + ro + 1]]);
    }
}

module clip() {
    translate([-plate_w / 2, -plate_t, 0]) cube([plate_w, plate_t, plate_l]);
    linear_extrude(clip_l) ring_2d();
}

clip();
