// Example model — a parametric rounded box.
// Replace this with your own designs.

box_w = 40;
box_d = 30;
box_h = 20;
radius = 3;
$fn = 64;

module rounded_box(w, d, h, r) {
    hull() {
        for (x = [r, w - r], y = [r, d - r], z = [r, h - r])
            translate([x, y, z]) sphere(r);
    }
}

rounded_box(box_w, box_d, box_h, radius);
