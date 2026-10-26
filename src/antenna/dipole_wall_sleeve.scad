/* =====================================================
   Dipole antenna wall sleeve
   =====================================================
   An open-top pocket for the black hinge block of a
   telescoping dipole (two chrome rods, coax out the front,
   stepped round stub underneath). The block drops in
   rods-up, the stub passes through a hole in the floor, and
   a tall back plate takes a Command strip on the wall.

   Block (measured):
     body          40 wide x 14 deep x 18 tall: 11 mm straight,
                   then angled corners down to a flat bottom
     raised piece  18 x 12 x 1 on top, between the rods
     stubs         Ø13.5 then Ø10.5, 20 mm together below the
                   block (38 total); the split between them
                   is a guess from the photos
     screws        Torx heads front, nuts back, 1 mm proud.
                   They are also the rod hinges. Positions are
                   from the photos: ~14.6 mm either side of
                   centre, ~4.5 mm below the top
     cable         Ø3.5, out the front face roughly centred,
                   bottom edge 14 mm below the top

   Sleeve:
     - front/back walls stop 2 mm under the block top so it's
       easy to grab, with open-top slots for the screw heads
       (they also key it side to side)
     - front wall has an open-top slot for the cable
     - side walls are low so the rods can still fold out flat
     - the back plate runs down behind the stub, long enough
       for a medium Command strip (19 x 70) standing upright

   Print it lying on the back plate (wall side down). Nothing
   overhangs except the floor hole, which is a teardrop.

   Coordinates: X across (centred), Y toward the wall
   (block centred on Y = 0), Z up from the floor top (block
   bottom).
   ===================================================== */

$fa = 2;
$fs = 0.4;

/* ── Block (measured) ───────────────────────────────── */
blk_w      = 40;
blk_d      = 14;
blk_h      = 18;
blk_rect_h = 11;    // straight part before the angled corners
blk_bot_w  = 22;    // flat bottom width (estimated; not load-bearing)
stub1_d    = 13.5;
stub1_h    = 8;     // estimated
stub2_d    = 10.5;
stub2_h    = 12;    // estimated
screw_x    = 14.6;  // either side of centre (from photos)
screw_z    = 4.5;   // below the block top (from photos)
screw_head = 6;     // head / nut size, generous
screw_out  = 1;
cable_d    = 3.5;
cable_bot  = 14;    // cable bottom edge below the block top
cable_x    = 0;     // looks centred in the photos

/* ── Sleeve ─────────────────────────────────────────── */
clear       = 0.3;  // per side around the block
wall        = 2.4;
floor_t     = 3;
wall_drop   = 2;    // front/back walls end this far under the block top
side_drop   = 10;   // side walls end this far under the block top
screw_slot  = screw_head + 1;
cable_slot  = 8;    // wide, since the cable position is from photos
stub_clear  = 0.4;  // per side through the floor
plate_t     = 3;    // back wall / Command strip plate
plate_h     = 76;   // overall, top of walls down
gusset_t    = 2.4;
gusset_h    = 16;

/* ── Derived ────────────────────────────────────────── */
pw    = blk_w + 2 * clear;           // pocket
pd    = blk_d + 2 * clear;
ow    = pw + 2 * wall;               // outside width
wall_h = blk_h - wall_drop;          // above the floor top
side_h = blk_h - side_drop;
y_front = -pd / 2 - wall;
y_back  =  pd / 2;                   // plate front face
eps   = 0.01;

module teardrop_hole(d, h) {
    // axis Z; the point faces -Y, which is up when printed on the plate
    linear_extrude(h) hull() {
        circle(d = d);
        translate([0, -d / 2 / sin(45) ]) square(0.01, center = true);
    }
}

module sleeve() {
    difference() {
        union() {
            // floor
            translate([-ow / 2, y_front, -floor_t])
                cube([ow, y_back - y_front, floor_t]);
            // front wall
            translate([-ow / 2, y_front, -floor_t])
                cube([ow, wall, floor_t + wall_h]);
            // side walls
            for (s = [-1, 1])
                translate([s > 0 ? pw / 2 : -ow / 2, y_front, -floor_t])
                    cube([wall, y_back - y_front, floor_t + side_h]);
            // back plate: back wall above the floor, strip plate below
            translate([-ow / 2, y_back, wall_h - plate_h])
                cube([ow, plate_t, plate_h]);
            // gussets under the floor, at the side walls
            for (s = [-1, 1])
                translate([s * (ow / 2 - gusset_t / 2) - gusset_t / 2, y_back + eps, -floor_t])
                    rotate([0, 90, 0]) linear_extrude(gusset_t)
                        polygon([[0, 0], [0, y_front - y_back], [gusset_h, 0]]);
        }
        // stub hole
        translate([0, 0, -floor_t - 1])
            teardrop_hole(stub1_d + 2 * stub_clear, floor_t + 2);
        // screw-head slots, front and back walls
        for (s = [-1, 1], y = [y_front - 1, y_back - 1])
            translate([s * screw_x - screw_slot / 2, y, blk_h - screw_z - screw_slot / 2])
                cube([screw_slot, wall + 2, blk_h]);
        // cable slot, front wall
        translate([cable_x - cable_slot / 2, y_front - 1, blk_h - cable_bot - 0.5])
            cube([cable_slot, wall + 2, blk_h]);
    }
}

// the antenna block, for checking the fit in preview only
module block_mock() {
    color("black") {
        hull() {
            translate([-blk_w / 2, -blk_d / 2, blk_h - blk_rect_h])
                cube([blk_w, blk_d, blk_rect_h]);
            translate([-blk_bot_w / 2, -blk_d / 2, 0])
                cube([blk_bot_w, blk_d, eps]);
        }
        translate([-9, -6, blk_h]) cube([18, 12, 1]);
        translate([0, 0, -stub1_h]) cylinder(d = stub1_d, h = stub1_h);
        translate([0, 0, -stub1_h - stub2_h]) cylinder(d = stub2_d, h = stub2_h);
        for (s = [-1, 1])
            translate([s * screw_x, 0, blk_h - screw_z])
                rotate([90, 0, 0]) cylinder(d = 5, h = blk_d + 2 * screw_out, center = true);
        translate([cable_x, -blk_d / 2, blk_h - cable_bot + cable_d / 2])
            rotate([90, 0, 0]) cylinder(d = cable_d, h = 20);
    }
}

sleeve();
%block_mock();
