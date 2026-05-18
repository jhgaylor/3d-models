// Example parametric rounded box.
//
// Parameters are exposed to OpenSCAD's Customizer (and the build's variant
// matrix via src/example.json). Replace this file with your own designs.

/* [Box dimensions] */
box_w = 40;  // [10:200]
box_d = 30;  // [10:200]
box_h = 20;  // [5:100]

/* [Detail] */
radius = 3;  // [1:10]

$fn = 64;

module rounded_box(w, d, h, r) {
    hull() {
        for (x = [r, w - r], y = [r, d - r], z = [r, h - r])
            translate([x, y, z]) sphere(r);
    }
}

rounded_box(box_w, box_d, box_h, radius);
