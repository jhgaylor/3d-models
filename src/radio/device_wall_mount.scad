/* =====================================================
   Device wall mount (slide-in channel)
   =====================================================
   A slide-in channel for a small boxy radio gadget, stuck to
   the wall with a Command strip. The device stands on end and
   drops in from the top. It rests on two small corner ledges
   and is held against the plate by lips along the front edges.

   Devices (measured, width x length x thickness):
     airspy-r2     41 x 54 x 25. SMA antenna on one end, USB on
                   the other
     sms-modem     46 x 90 x 15. USB-A plug out the bottom
                   middle, antenna out the top centre

   Each device's connectors are on its two short ends. Both
   ends of the channel are open, and the ledges only cover the
   outer 5 mm of the bottom end, so plugs and antennas centred
   on those ends clear everything. Push the device down while
   you plug in its bottom end, since nothing stops it lifting
   out the top.

   The back plate runs above the channel when the device is
   short, so there's always room for a medium Command strip
   (19 x 70) standing upright. Most of the front face is open
   so LEDs show.

   Print it standing up, ledges on the bed. Every wall is
   vertical, so it needs no supports.

   Coordinates: X across (centred), Y out from the wall (plate
   front face at Y = 0), Z up from the bottom of the channel.
   ===================================================== */

/* ── Device (measured; presets in the .json) ───────────── */
dev_w = 41;   // across, flat against the wall
dev_l = 54;   // up the wall, connector end to connector end
dev_t = 25;   // out from the wall

/* ── Mount ──────────────────────────────────────────── */
clear   = 0.3;   // per side around the case
wall    = 2.4;
plate_t = 3;     // back plate / Command strip plate
strip_l = 70;    // medium Command strip, standing upright
lip     = 4;     // front lips reach this far over the face
ledge   = 5;     // corner ledges reach this far under the case
ledge_t = 2;
chan_drop = 6;   // channel walls end this far under the case top

/* ── Derived ────────────────────────────────────────── */
pw = dev_w + 2 * clear;            // pocket
pd = dev_t + 2 * clear;
ow = pw + 2 * wall;               // outside width
chan_h = ledge_t + dev_l - chan_drop;
plate_h = max(chan_h, strip_l + 6);

eps = 0.01;

// One solid with the pocket cut out. Unioning the plate, walls
// and ledges as separate blocks leaves duplicate vertices where
// their faces line up.
module mount() {
    difference() {
        // side view: plate up the back, channel at the bottom
        translate([-ow / 2, 0, 0]) rotate([90, 0, 90]) linear_extrude(ow)
            polygon(plate_h > chan_h
                ? [[-plate_t, 0], [pd + wall, 0], [pd + wall, chan_h],
                   [0, chan_h], [0, plate_h], [-plate_t, plate_h]]
                : [[-plate_t, 0], [pd + wall, 0], [pd + wall, chan_h],
                   [-plate_t, chan_h]]);
        // pocket, above the ledges
        translate([-pw / 2, 0, ledge_t]) cube([pw, pd, plate_h]);
        // open bottom between the ledges
        translate([-pw / 2 + ledge, 0, -1]) cube([pw - 2 * ledge, pd, ledge_t + 2]);
        // open front between the lips
        translate([-pw / 2 + lip, pd - 1, -1]) cube([pw - 2 * lip, wall + 2, chan_h + 2]);
    }
}

// the device, for checking the fit in preview only
module dev_mock() {
    color("dimgray")
        translate([-dev_w / 2, clear, ledge_t]) cube([dev_w, dev_t, dev_l]);
}

mount();
%dev_mock();
