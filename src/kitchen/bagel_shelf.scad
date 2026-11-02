/* =====================================================
   Bagel shelf (cabinet riser)
   =====================================================
   An H-shaped riser that stacks two bags of bagels in a
   kitchen cabinet. One bag lies on the cabinet floor between
   the legs and the other lies on the shelf. The legs carry on
   above the shelf as low side rails, so the top bag can't roll
   off sideways.

   Measured:
     bagel bag     9 long x 4.5 wide x 4.5 tall (in)
     cabinet       11 deep x 10 5/8 tall (in)

   Bags lie lengthwise front to back. With the default
   clearances the shelf top sits 5.1 in up and the top bag
   tops out around 9.6 in, which leaves about 1 in under the
   cabinet ceiling.

   Diamond windows in the legs save filament, and their 45°
   edges print without supports.

   Print it standing on its front face (depth along Z, the H
   lying flat on the bed). Every wall is vertical in that
   orientation, so it needs no supports. It's 241 mm tall, so
   it fits a 256 mm bed.

   Coordinates: X across (centred), Y front to back (front at
   Y = 0), Z up from the cabinet floor.
   ===================================================== */

in = 25.4;   // mm per inch

/* ── Bag & cabinet (measured, inches) ───────────────── */
bag_l_in   = 9;
bag_w_in   = 4.5;
bag_h_in   = 4.5;
cab_d_in   = 11;
cab_h_in   = 10 + 5/8;

/* ── Clearances (inches) ────────────────────────────── */
side_gap_in = 0.5;   // total, across the bag's width
top_gap_in  = 0.5;   // over the lower bag, under the shelf
depth_add_in = 0.5;  // shelf depth beyond the bag length

/* ── Plastic (mm) ───────────────────────────────────── */
wall    = 3;     // leg thickness
deck    = 3.5;   // shelf thickness
rail_h  = 25;    // leg height above the shelf top
window  = true;  // diamond windows in the legs
win_web = 8;     // solid web around and between windows

/* ── Derived (mm) ───────────────────────────────────── */
inner_w = (bag_w_in + side_gap_in) * in;          // between legs
depth   = (bag_l_in + depth_add_in) * in;
under_h = (bag_h_in + top_gap_in) * in;           // floor to shelf underside
outer_w = inner_w + 2 * wall;
total_h = under_h + deck + rail_h;

assert(depth <= cab_d_in * in, "shelf is deeper than the cabinet");
assert(under_h + deck + bag_h_in * in <= cab_h_in * in,
       "top bag won't fit under the cabinet ceiling");

eps = 0.01;

module leg() {
    difference() {
        cube([wall, depth, total_h]);
        if (window) {
            // a row of diamonds in the part below the shelf
            dh = under_h - 2 * win_web;           // diamond height
            n  = max(1, floor((depth - win_web) / (dh + win_web)));
            pitch = (depth - win_web) / n;
            // diamond length along Y. Y is up when printing, so this
            // stays >= dh to keep the edges at 45° or steeper
            dw = pitch - win_web;
            for (i = [0 : n - 1])
                translate([-eps, win_web + pitch * (i + 0.5) - win_web / 2,
                           win_web + dh / 2])
                    rotate([90, 0, 90])
                        linear_extrude(wall + 2 * eps)
                            polygon([[0, -dh / 2], [dw / 2, 0],
                                     [0, dh / 2], [-dw / 2, 0]]);
        }
    }
}

module bagel_shelf() {
    for (s = [-1, 1])
        translate([s < 0 ? -outer_w / 2 : inner_w / 2, 0, 0]) leg();
    translate([-inner_w / 2 - eps, 0, under_h])
        cube([inner_w + 2 * eps, depth, deck]);
}

// the two bags, for checking the fit in preview only
module bags_mock() {
    bw = bag_w_in * in; bl = bag_l_in * in; bh = bag_h_in * in;
    color("tan", 0.5) {
        translate([-bw / 2, (depth - bl) / 2, 0]) cube([bw, bl, bh]);
        translate([-bw / 2, (depth - bl) / 2, under_h + deck]) cube([bw, bl, bh]);
    }
}

bagel_shelf();
%bags_mock();
