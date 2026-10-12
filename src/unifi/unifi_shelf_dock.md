# UniFi Shelf Docks — Assembly Notes

Organizers for Ubiquiti's **fixed Toolless Mini Rack Shelf** (UACC-Rack-Shelf-TL) in the
U-Rack-6U-TL. The steel shelf carries the load (rated 20 kg). These parts only keep each
machine in its spot. Small loose pins drop through each part into the shelf's
perforations so nothing slides.

The layout fits 3 Mac minis (M4), a GMKtec NucBox M8, a Geekom A9 Mega, a Minisforum
MS-A2 and three power bricks on one shelf, in two rows and with nothing stacked:

```
               front of rack
 ┌──────────┬──────────────────┬─────────┐
 │ bricks×3 │  Mac  Mac  Mac   │   M8    │   on edge, in docks
 │ (on edge)│  (on edge)       │(on edge)│
 │          │                  │         │
 ├──────────┴──── cable gap ───┴─────────┤
 │   A9 Mega (flat)   │  MS-A2 (flat)    │   front corners in guides,
 │                    │                  │   exhausts out the back
 └────────────────────┴──────────────────┘
               back of rack
```

The machines exhaust backward or upward. The Macs vent out the back into a ~118 mm gap. The
A9 Mega takes air in at the bottom and exhausts at the back. The MS-A2 vents top and
bottom and has ~90 mm clear above it.

## Parts

| Preset | Qty | What it is |
|---|---|---|
| `mac-mini-x3` | 1 | Dock for 3 Mac mini M4s on edge. 6 mm air gap between them. The back fins stop 28 mm short so the power button stays reachable. |
| `nucbox-m8` | 1 | Dock for the NucBox M8 on edge (65 mm thick). |
| `bricks-x3` | 1 | Dock for 3 power bricks on edge (~30 × 80 × 200 mm). The ends are open for the cords. |
| `corner-left` | 2 | Front-left corner guide for a machine lying flat. |
| `corner-right` | 2 | Front-right corner guide. |
| `pins` | 1 plate | 24 locating pins. You need 14: 2 per dock and 2 per corner guide. |
| `fit-test` | 1 | A short bar with two pin holes 30 mm apart, plus two pins. **Print this first.** |

Every part fits a 256 mm bed and prints flat side down with no supports.

## Fitting

1. Drop the `fit-test` bar on the shelf's perforated area with its pins in. Both pins
   should fall into holes and the bar shouldn't slide. If the pins are tight, lower
   `pin_d`. If they're sloppy, raise it.
2. Set each dock or guide in place and nudge it until its pins drop into holes. Every
   part's pins sit along one left-to-right row of holes, so any spot on the grid works.
3. Pins have to land in the **perforated area**, which is the middle ~382 × 318 mm,
   starting about 74 mm in from the front and back edges. The docks' pins are under their
   **back** fins so the front row can sit near the front edge.
4. Keep everything at least 15 mm back from the shelf's front edge. That leaves room for
   OCD panels across the front.

## Measurements used

| Feature | Value |
|---|---|
| Shelf | 453.8 × 460 mm, steel, rated 20 kg |
| Perforations | Ø3.5 holes in a 60° staggered grid. 6.0 mm apart along a row (left to right), rows 5.2 mm apart |
| Headroom (shelf floor to the gear above, with 3U free) | 141 mm |
| Mac mini M4 | 127 × 127 × 50 |
| NucBox M8 | 110 × 110 × 65 (measured) |
| A9 Mega | 171 × 171 × 71 |
| MS-A2 | 196 × 189 × 48 |
| Power bricks | ~200 × 80 × 30 (approximate). If yours differ, adjust `slot_w`/`dev_d` in the `bricks-x3` preset. |

The standing Macs are 127 + 3 mm tall, which leaves 11 mm of headroom.

## Tips

- The A9 Mega and MS-A2 have their fronts facing the Macs, so their power buttons are hard
  to reach. Turn on "power on after AC loss" in each BIOS, or use Wake-on-LAN.
- Print in PETG if the bricks run hot.
