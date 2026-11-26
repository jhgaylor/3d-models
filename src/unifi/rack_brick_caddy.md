# Rack Brick Caddy — Assembly Notes

A tray for the bottom 2U at the back of the **UniFi Toolless Mini Rack** (U-Rack-6U-TL).
It holds the compute machines' three power bricks, so they're out of the compute bay.

- **The bricks stand on edge,** long side front to back, so their big faces are vertical
  and the heat rises straight off them.
- **The tray touches as little of them as it can.** Each brick sits in a notch in three
  thin cross beams, and those notch walls are the only contact with its faces. There's no
  floor, so air comes up from underneath.
- **The bricks are spread across the rack,** with 40+ mm between neighbours.
- **AC ends face the back** of the rack, toward the power strip in the slot above. The DC
  leads leave the front ends and go up to the compute bay.

```
        back of rack (you slide the tray in from here)
   ┃skid┃ ═══╪═══════╪══════════════╪══════════════╪══════ ┃skid┃  ← back beam, with brick stops
   ┃    ┃    █basil  █ fireball                    █ geek    ┃    ┃
   ┃    ┃ ═══╪═══════╪═════════  ◁▷ ═══════════════╪══════ ┃    ┃  ← dovetail joint at the centre
   ┃    ┃    █       █                             █         ┃    ┃
   ┃    ┃ ═══╪═══════╪══════════════╪══════════════╪══════ ┃    ┃
        toward the front (the Pro Max 16 PoE is in this slot)
```

The **HDHomeRun** (FLEX 4K, 86 × 86 × 20 mm per
[SiliconDust](https://info.hdhomerun.com/info/flex)) lies flat on top of the back two
beams, between fireball and geek, next to the switch it plugs into. Four low corner
guides and a back stop hold it. If yours is a different model, change `hdhr` at the top
of the `.scad`.

## Parts

| Preset | Qty | What it is |
|---|---|---|
| `left` | 1 | Left half, with the dovetail tabs |
| `right` | 1 | Right half, with the sockets |
| `fit-test` | 1 | The pin end of a skid, plus one joint: print this first |

Each half is about 231 × 188 × 30 mm and prints flat, beams down. No supports: the pin
channel on the outside of each skid is a 4.6 mm bridge.

| Brick | Size (h × l × t) | Where it stands |
|---|---|---|
| basil | 80 × 175 × 41 | left of centre |
| fireball | 54 × 96 × 24 | left of centre, next to basil |
| geek | 76 × 165 × 26.5 | right of centre |

## How it fits the rack

- **The skids ride on the ledges.** Like any UniFi gear, the tray slides in between the side
  slats and sits on the bottom slot's ledges.
- **The side thumbscrew stops and locks it.** The rack's side "pin" is a spring-loaded M4
  thumbscrew. A channel in the outside of each skid lets its tip ride in as the tray slides in
  from the back, and the tray stops where the channel ends. Then push the screw in and turn
  it: it taps its own thread into a 3.2 mm hole at the channel's end. If PETG threads strip,
  set `screw_d = 5.6` and use an M4 heat-set insert.
- **Only the skids reach the ledges.** Everything else stays inside the ledges' edges, so the
  2U tray passes the middle ledge.
- **Heights:** the skids are 16 mm tall, well under the middle ledge. The bricks top out
  88 mm above the ledge, under the power strip in the slot above (2U clear: 94.4 mm).
- **Depth:** the tray reaches 200 mm in from the back post, and the bricks' DC ends about
  25 mm further. The front of the same slots is the Pro Max 16 PoE, 160 mm deep, out of
  about 450 mm.

The ledge and pin numbers are the ones measured for the OCD panels
(`unifi_ocd_panel.md`). **They were measured at the front posts. This tray assumes the back
posts mirror them:** a pin 42.4 mm in from the back post face and 9 mm above the ledge. The
fit-test checks the channel. Also check by eye that the bottom slot has a pin at the back.

## Printing

- **Print `fit-test` first.**
  - The skid piece should sit on the ledge and slide onto the thumbscrew until it stops.
    Then push the screw in and turn it. It should bite and hold the skid without stripping.
  - The joint pieces should drop together by hand with no wobble. If the joint is tight,
    raise `tab_clear` (0.1 mm per side; 0.2 was loose).
- **Material:** PETG. The bricks run hot, so PLA will slowly sag under them.
- **Settings:** 0.2 mm layers, 3 walls, 20% infill. Beams down, no supports.

## Assembly

1. Drop the left half's tabs into the right half's sockets.
2. Slide the tray in from the back of the rack on the bottom slot's ledges until both side
   pins stop it.
3. Push each side's thumbscrew in and screw it into its skid.
4. Stand the bricks in their notches, pushed back against the stops on the back beam.
   Each brick's AC end faces the back. Lay the HDHomeRun between its guides.
5. Plug the AC leads into the strip above. Run the DC leads up the side of the rack to the
   compute bay.

To swap a brick for a different one, edit the `bricks` list at the top of the `.scad`
(height, length, thickness and x position) and re-render. The notches follow.

## Measurements used

| Feature | Value |
|---|---|
| Slat to slat | 444.4 mm |
| Ledge | 1.65 mm sheet, 19.7 mm in from the slat, starts 10.9 mm in from the post face |
| Side pin | Ø 3.98, 9 mm above the ledge, 42.4 mm in from the post face, 4.5 mm proud of the slat |
| Slot pitch | 48 mm (2U clear: 94.4 mm) |
| Rack usable depth | about 450 mm (retailer spec) |
| USW Pro Max 16 PoE | 325.1 × 160 × 43.7 mm ([Ubiquiti tech specs](https://techspecs.ui.com/unifi/switching/usw-pro-max-16-poe)) |
| UDM Pro | 442.4 × 285.6 × 43.7 mm ([Ubiquiti tech specs](https://techspecs.ui.com/unifi/cloud-gateways/udm-pro)) |
