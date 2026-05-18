// Layout preview of 3 Mac mini cradles on the UniFi UACC-Rack-Shelf-TL.
// The shelf and minis render as %-ghosts (excluded from STL/3MF export);
// only the 3 cradle bodies appear in the build outputs.
//
// Purpose: visual fit-check at design time. For printing, use
// mac_mini_cradle.scad — print 3 individual cradles.

use <mac_mini.scad>
use <mac_mini_cradle.scad>

/* [UniFi UACC-Rack-Shelf-TL] */
shelf_w = 453.8;   // usable width
shelf_d = 460;     // depth
shelf_t = 2;       // ghost thickness (visualization only)

/* [Layout] */
mini_count = 3;
front_offset = 50; // distance from shelf front edge to cradle front face

// Match the cradle defaults — keep in sync with mac_mini_cradle.scad
cradle_w = 127 + 2*(0.5 + 3);  // mini_w + 2*(clearance + wall_thickness)

total_w  = mini_count * cradle_w;
margin_x = (shelf_w - total_w) / 2;

$fn = 64;

// Ghost shelf (excluded from STL via %)
%color("DimGray") translate([0, 0, -shelf_t])
    cube([shelf_w, shelf_d, shelf_t]);

for (i = [0 : mini_count - 1]) {
    translate([margin_x + i*cradle_w, front_offset, 0]) {
        // Cradle: solid, exported
        mac_mini_cradle();
        // Ghost mini: shows the fit but is excluded from STL
        translate([3 + 0.5, 3 + 0.5, 2])
            %mac_mini();
    }
}
