// Parametric reference model of the M4 Mac mini (2024 redesign).
//
// Use this when designing fixtures, racks, or shelves. The shape is a
// rounded prism that captures the external envelope accurately. Two
// modules:
//
//   mac_mini()                  — visual reference (true outer dimensions)
//   mac_mini_cutout(clearance)  — same shape, oversized for negative-space
//                                 cutouts (the volume your enclosure must
//                                 leave empty around a mini)
//
// Coordinate system: origin at the front-left-bottom corner.
//   +X = right (looking at the front)
//   +Y = back  (away from front face)
//   +Z = up
//
// To use in another .scad:
//   use <mac_mini.scad>
//   mac_mini();
//   translate([-5,-5,-5]) #mac_mini_cutout(5);  // visualize clearance

/* [Mac mini dimensions (Apple M4, 2024)] */
mini_w = 127;       // width, mm  (5.0 in)
mini_d = 127;       // depth, mm  (5.0 in)
mini_h = 50;        // height, mm (2.0 in)
corner_r = 4;       // edge fillet radius, mm

/* [Detail toggles] */
show_logo  = true;  // recessed Apple-logo circle on top (orientation cue)
show_ports = true;  // rear port silhouette (orientation cue, not for cable fit)
show_led   = true;  // front power LED dot

/* [Render quality] */
$fn = 64;

module mac_mini() {
    difference() {
        _rounded_block(mini_w, mini_d, mini_h, corner_r);
        if (show_logo)  _top_logo();
        if (show_ports) _rear_ports();
        if (show_led)   _front_led();
    }
}

module mac_mini_cutout(clearance = 1.0) {
    // No surface details — just an oversized envelope. Use as a negative
    // when carving slots in a shelf or rack.
    translate([-clearance, -clearance, -clearance])
        _rounded_block(
            mini_w + 2*clearance,
            mini_d + 2*clearance,
            mini_h + 2*clearance,
            corner_r + clearance
        );
}

// ---- internals ----------------------------------------------------------

module _rounded_block(w, d, h, r) {
    hull() {
        for (x = [r, w - r], y = [r, d - r], z = [r, h - r])
            translate([x, y, z]) sphere(r);
    }
}

module _top_logo() {
    // Apple logo is ~30 mm wide, ~0.3 mm recessed on the actual product.
    // Modeled here as a plain disc so the orientation reads at a glance.
    logo_r = 15;
    logo_depth = 0.5;
    translate([mini_w/2, mini_d/2, mini_h - logo_depth + 0.01])
        cylinder(h = logo_depth + 0.02, r = logo_r);
}

module _rear_ports() {
    // Schematic port band on the rear face: power, ethernet, HDMI, 3x USB-C.
    // Dimensions approximate — meant for visual orientation, not cable fit.
    port_z   = 15;   // height of port centerline above bottom
    port_h   = 12;   // band height
    band_d   = 1.0;  // recess depth into rear face
    band_w   = mini_w - 30;
    translate([(mini_w - band_w)/2, mini_d - band_d + 0.01, port_z - port_h/2])
        cube([band_w, band_d + 0.02, port_h]);
}

module _front_led() {
    led_r = 1.0;
    led_depth = 0.3;
    translate([mini_w/2, -0.01, 6])
        rotate([-90, 0, 0])
            cylinder(h = led_depth + 0.02, r = led_r);
}

// Default top-level render: a single mini.
mac_mini();
