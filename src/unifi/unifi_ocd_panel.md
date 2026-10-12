# UniFi OCD Panel — Assembly Notes

Earless filler panels for the **UniFi Toolless Mini Rack** (U-Rack-6U-TL). That rack
has no 19" rails or cage-nut holes, so ordinary eared blanks don't fit. These work the
way Ubiquiti's own OCD panels (UACC-Rack-Panel-*) do. Each panel is a U-channel that
slides in between the side slats, rests on a slot's ledge, and catches that slot's
side pin.

```
   post ─┐                                   ┌─ post
         │▌ face ─────────────────────────── ▐│
         │▌                                  ▐│   ← side flanges ride inside the slats
         │▌◄ pin slot      (top view)        ▐│
              ↑ slides in from the front, the pin clicks into the slot
```

## Parts

Every panel prints as **two halves** (each about 221 mm wide) plus **two splices**.

| Preset | What it is |
|---|---|
| `blank-1u-*`, `blank-2u-*` | Solid face |
| `vented-1u-*`, `vented-2u-*` | Vertical slot vents (kept clear of the seam and flanges) |
| `passthrough-1u-*` | 400 × 24 mm cable opening (the size of Ubiquiti's brush panel, without the brush) |
| `splice` | L-bar glued across the seam in the top and bottom returns. You need **2 per panel**. |
| `fit-test` | The last 30 mm of a 1U panel (flange, pin slot and detent). **Print this first.** |

To print one piece on a ~450 mm bed, set `pieces = 1`. To split into thirds for small
beds like the A1 mini, set `pieces = 3` and print with `piece = 0/1/2`.

## Fitting

1. Line the panel up with an empty slot and slide it straight back. The flanges
   pass inside the slats and the bottom edge rides on the ledge.
2. The rack's pin enters the open slot at the back of each flange. Near the end of
   travel it rides over a small sprung bump and **clicks** into its seat. The face then
   stands 1 mm proud of the posts.
3. To remove it, pull it straight forward.

2U panels have a notch in each flange so they pass over the middle ledge. They catch
both pins.

## Print settings

| Setting | Recommendation |
|---|---|
| Orientation | As exported. Face down, with the flanges standing up. |
| Supports | None |
| Layer height | 0.2 mm |
| Walls | 3+ (so the flanges and detent beams come out solid) |
| Material | PLA/PETG |

Glue the two halves face down on a flat surface. Put CA glue on the butt seam and
press a splice into the pockets at the top and at the bottom.

## Rack measurements

These were measured from Ubiquiti's published 3D model of the U-Rack-6U-TL (the GLB
on the store page). The panel is in the panel's frame, with Z = 0 at a ledge top.

| Feature | Value |
|---|---|
| Slot pitch | **48.0 mm** (not EIA 44.45) |
| Clear width, slat to slat | 444.4 mm |
| Post short-leg opening | 458.4 mm |
| Ledge | 1.65 mm sheet. Sticks 19.7 mm in from the slat. Its front edge is 10.9 mm behind the post front. Runs the full depth. |
| Clear height under the next ledge | 46.4 mm |
| Side pin | Ø 3.98 mm. 9.0 mm above the ledge top. 42.4 mm behind the post front. Sticks 4.5 mm in from the slat. |
| Ubiquiti OCD panel | 442.4 W × 63.5 D × 43.7 H (1U) / 87.4 H (2U) |

Tolerance knobs (top of the .scad): `slot_w`, `bump_h`, `W`, `front_proud`,
`splice_clr`. If the fit test is tight or loose, adjust these before printing full
panels.
