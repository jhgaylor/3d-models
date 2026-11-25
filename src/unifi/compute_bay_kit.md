# Compute Bay Kit — Assembly Notes

Parts for laying out the compute bay of the **UniFi Toolless Mini Rack** (the 3U on the
fixed shelf) flat, in two rows, with air between everything. It's one of three pieces of
a cooling plan for a bay that was running too hot:

1. **This kit:** everything in the bay lies flat, with gaps and a channel for air.
2. **[Brick caddy](rack_brick_caddy.md):** the three power bricks and the HDHomeRun move
   out of the bay, to the bottom 2U at the back.
3. **[Fan lid](rack_fan_lid.md):** four fans on top pull the hot air straight up, along
   with the AC Infinity exhausting out the back.

```
             back of the bay  (AC Infinity exhaust)
     ┌────────────────────────────────────────────┐
     │  [ Geekom A9 Mega ]      [ Minisforum MS-A2 ]│
     │                                             │
     │  ~~~~~~~~~~~~~~ 26 mm air channel ~~~~~~~~~  │
     │  [ M8 ] ▮ [ mini over mini ] ▮ [ mini ]      │   ▮ fins (17 mm gaps)
     └────────────────────────────────────────────┘
             front of the bay  (teal OCD panels)
```

## Why this layout

- **Headroom under the fans.** The fan lid's fans and clips hang 18.2 mm into the bay, so
  under a fan there's about 122 mm, not the full 141.
  - An M8 on a bridge over the MS-A2 would stand 134 mm tall. It doesn't fit.
  - Two Mac minis stacked with a 10 mm gap stand 116 mm. The stack sits mostly in the
    fan-free column down the middle, and the M8 lies flat in the freed spot.
- **The side ledges.** The rack's side ledges stick 19.7 mm in from the slats every
  48 mm, and the cable clips' spines add 2 mm. Anything taller than 46 mm has to stay
  inside 199.5 mm of the centre line. Every device here does.
- **The AC Infinity.** It's 38 mm deep at the back of the bay. The back row ends 42 mm
  short of the shelf's back edge.
- **Airflow.** Air comes in through the front panels and runs between the devices and
  through the channel between the rows. It leaves up through the lid fans and out
  through the AC Infinity.
- **Mac mini intake.** Each M4 Mac mini takes air in around the foot on its underside.
  Lying flat on the perforated shelf, or on the riser's ribs (which only touch it under
  the foot), that ring stays open.

## Parts

| Preset | Qty | What it is |
|---|---|---|
| `fins` | 1 plate (2) | Spacers that keep a 17 mm gap between front-row devices, pinned to the shelf |
| `riser-deck` | 1 | Carries the upper Mac mini 10 mm above the lower one |
| `riser-posts` | 1 plate (4) | Legs for the deck, outside the lower mini's corners |
| `clips` | 1 plate (6) | Cable clips that push onto the side ledges |
| `pins` | 1 plate (6) | Loose pins for the fins |
| `fit-test` | 1 | A clip, a fin slice with its pin holes, and a pin: print this first |

## Printing

- **Print `fit-test` first.**
  - Push the clip onto a side ledge. It should snap on with light force and stay put.
    The friction bump is `bump` (0.25 mm). Lower it if the clip is too tight.
  - Drop the pin through the fin slice into the shelf's holes. It should go in easily.
- **Settings:** PETG, 0.2 mm layers, 3 walls, 20% infill. No supports anywhere.
  - The deck prints rails down, lips up.
  - The posts print standing.
  - The clips print lying on their profile.

## Assembly

1. **Clear the bay.** The bricks and the HDHomeRun go to the [brick caddy](rack_brick_caddy.md).
2. **Front row, left to right:** the M8, the lower Mac mini, then the third mini. Leave
   about 17 mm between them, about 76 mm back from the shelf's front edge.
3. **Fins:** set one in each gap, halfway back, and drop two pins through it into the
   shelf's holes. The fins sit on the 6 mm hole grid, so each gap lands within about
   1.5 mm of 17.
4. **Riser:** stand a post outside each corner of the middle mini. Press the deck onto
   the posts' pegs, then set the second mini on the deck between its corner lips.
5. **Back row:** the A9 Mega on the left and the MS-A2 on the right, 30 mm apart, with
   their backs 42 mm short of the shelf's back edge. That leaves a 26 mm channel behind
   the front row.
6. **Cables:** push clips onto the side ledges where the bundles run, and lay the
   cables in the clips' rings along the walls. Keep the channel and the gaps clear.

The outer minis aren't held on their outer sides. They can creep a few mm toward the
walls, but they can't reach the ledges.

## Measurements used

| Item | Size (w × d × h, mm) |
|---|---|
| Mac mini M4 | 127 × 127 × 50 |
| GMKtec NucBox M8 | 110 × 110 × 65 (measured) |
| Geekom A9 Mega | 171 × 171 × 71 |
| Minisforum MS-A2 | 196 × 189 × 48 |
| Shelf headroom | 141 to the top frame; about 122 under the lid's fans |
| Shelf perforations | Ø 3.5, 6.0 mm along a row, rows 5.2 mm apart (staggered), middle ~382 × 318 |
| Side ledge | 1.65 mm sheet, 19.7 mm in from the slat, every 48 mm |
| AC Infinity CLOUDPLATE T7 | 2U, 38 mm deep ([AC Infinity](https://acinfinity.com/cloudplate-t7-quiet-rack-cooling-fan-system-2u-exhaust/)) |
