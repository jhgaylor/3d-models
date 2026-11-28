# Rack Fan Lid — Assembly Notes

A lid for the top of the **UniFi Toolless Mini Rack** (U-Rack-6U-TL) with four 120 mm
slim fans hanging underneath, blowing up and out of the rack. It replaces the Boston
lid when you want airflow: the Boston lid is about 11% open, this one is grille nearly
everywhere over the opening.

Two styles, chosen with `style`:

- **`skeleton`** (default): only the plastic that does a job. That's the border over the
  rack's rails, a square round each fan carrying its clip sockets, and the two seam bars
  the keys bridge. Add a tie from each fan to the bars and the border, and a pad for the
  controller. Everything else, fans included, is open. It's the quickest print and
  uses the least filament. Set `skel_guard = true` to keep the vane grille over each fan
  as a finger and cable guard.
  - The open areas next to the fans let air in from the room as well as out. With the
    fans running, some of what they move is room air pulled down through the openings
    rather than hot air from the bay. If the bay runs warmer than you'd like, the `art`
    style is the fix: it's mostly solid away from the fans.
- **`art`**: the original lid, described below.

The `art` style:

- **Fan grilles:** each fan gets a swept-vane grille: a solid hub over the motor, three
  rings, and seven curved vanes.
- **A halftone picture:** the rest of the opening is a picture made of vent holes. Each
  hole is 2.0 to 4.3 mm across, depending on how dark the picture is at that spot, and
  the lightest areas get no hole at all. Up close it's a vent; from across the room it's
  a picture. Pick one with `art` (see [The pictures](#the-pictures)):
  - **`wood`** (default): grain lines that bunch and curve around the four fans like
    grain around knots.
  - **`waves`**: rippling stripes, Bridget Riley style.
  - **`ripples`**: rings spreading from each fan, interfering where they meet.
  - **`skyline`**: Boston from OpenStreetMap heights. It reads poorly at this
    resolution and is kept for reference.
  - **`hex`**: a plain hex field.
- **Still vents:** over the rack opening, on top of the four grilles, wood opens about
  177 cm², waves about 240 and ripples about 254. The plain hex field opens about 234.
- **Same footprint as the Boston lid:** same handle notches and four tiles. The bowtie
  keys are the same shape in new places. The top face is flat and one colour; all the
  fan hardware is underneath.

```
              back of rack
     ┌────────────────┐ ═handle═ ┌────────────────┐
     │  ══════╲      └──┐    ┌──┘       ╱══════   │
     │  ═══ ( fan ) ══════════════ ( fan ) ═══    │   wood grain: dark lines are big
     │  ══════╱  ═══════════════  ╲══════         │   holes, pale bands solid
     │  ══════╲  ═══════════════  ╱══════         │
     │  ═══ ( fan ) ══════════════ ( fan ) ═══ ▭  │   ▭ controller
     └─────────────────┘  ═══  └──────────────────┘
              front of rack
```

## Parts

| Preset | Qty | What it is |
|---|---|---|
| `tile-sw` | 1 | Front-left quarter |
| `tile-se` | 1 | Front-right quarter, with the controller recess |
| `tile-nw` | 1 | Back-left quarter |
| `tile-ne` | 1 | Back-right quarter |
| `clips` | 1 plate | 8 fan clips, 2 per fan |
| `keys` | 1 plate | 11 bowtie keys that join the tiles |
| `fit-test` | 1 | A socket and a short clip stub: print this first |

To buy: 4× **ARCTIC P12 Slim PWM PST** (120 × 120 × 15), a **Delinx 12V PWM fan
controller** (auto/manual, with temperature probe and 5-way hub), and a **12V 2A**
wall adapter with a 5.5 × 2.1 mm barrel plug.

## How the fans attach

No screws. Each fan is held by two clips, one on its left side and one on its right.

```
   lid  ════════╗ ▄▄▄▄ ╔═══════════      tab locked in its dovetail socket
                ║█▀▀▀▀█║                  (entry pocket is to its left)
   fan  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█
        ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█   ← leg flexes outward as the fan goes in
        ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█
                     ◣█   ← lip snaps under the fan
```

- Each clip has two dovetail tabs on its top edge.
- The lid's underside has a socket for each tab. A socket is a straight-walled entry
  pocket on the fan side, then a 45° dovetail channel that runs outward and stops.
- Once the fan is in, the clips can't slide back into the pockets. The snap force only
  pushes them harder into the closed ends of the channels.
- Short returns at each end of a clip stop the fan from sliding along it.

## Printing

- **Print `fit-test` first.** The tab should slide into the dovetail with light
  friction and stay put when you turn the piece over. If it's tight, raise `sock_g`
  (clearance per side, 0.2 mm). If it rattles, lower it.
- **Tiles:** plate side down, no supports. The sockets are cut into the bed face, and
  their ceilings are short bridges. Each tile is 249.6 × 229.9 mm and fits a 256 bed.
  The Boston lid's notes on the Bambu exclusion zone apply here too.
- **Clips:** they print lying on their outer face, so the leg flexes along its layers.
  No supports.
- **Colour:** pick something clearly lighter than the inside of your rack. The holes
  always read dark, so the picture is only as strong as the plate is light. Orange is
  the boldest on a silver rack, and a medium blue works too. Navy loses the picture,
  and cream looks washed out on silver.
- **Material:** PETG for everything. The lid spans about 400 mm in warm exhaust air, and
  the clip legs flex about 1.5 mm when the fan goes in, which PETG takes easily. PLA
  clips will probably work but are closer to their limit.
- **Settings:** 0.2 mm layers, 3 walls, 15% infill. Use 100% infill or 5 walls for the
  clips.

## Assembly

1. Lay the four tiles face down, butted together, and glue a key into each bowtie pocket
   across the seams (CA or epoxy). Let it cure flat.
2. **Clips:** for each clip, drop its two tabs into the entry pockets beside a fan
   position, with the leg on the fan side. Slide the clip outward, away from the fan,
   until it stops.
3. **Fans:** turn each fan so its cable leaves on a **front or back side**, not a left
   or right side, so the clip legs don't pinch it. Face the airflow arrow toward the lid
   (blowing up), then press the fan straight down between its two clips until both lips
   click.
4. **Wiring:** daisy-chain the four fans through their PST sockets and plug the chain
   into one output of the controller's hub. Stick the controller in the recess beside
   the front-right fan with its 3M pad.
5. **Temperature probe:** let it hang into the rack near the warmest gear, not next to
   the fans. A good start is fans on at 35 °C and full speed at 50 °C.
6. Turn the lid over and set it on the rack, notches over the handles.

To take a fan out, push both clip legs outward with a thumbnail and lift the fan away.

## The pictures

`tools/lid_halftone.py` writes `vendor/lid_halftone.inc`: a lattice of points (5.2 mm
pitch) with a darkness for each point in each picture. The lid turns darkness into a hole
size. Below `ht_skip` (0.15) there's no hole at all, which gives the picture real
highlights. The lid also decides which points may hold a hole at all. Holes stay out of:

- a ring round each grille and the clip sockets,
- the tile seams and the key pockets,
- the controller recess,
- the frame. The rails would show through a hole as bare metal, not the dark inside of
  the rack, so a solid border frames the picture.

Holes over the corners of each fan's frame don't vent, but they read dark like the rest,
so the picture runs right up to the grilles.

At this resolution (about 80 × 75 holes, much of it covered by grilles) a picture only
reads if every feature is at least 4–6 holes across (20–30 mm). That's why the skyline,
whose towers come out 2–3 holes wide, doesn't work, and why the patterns are drawn big.

```sh
python3 tools/lid_halftone.py            # rewrite vendor/lid_halftone.inc
python3 tools/lid_halftone.py --preview  # and build/lid_halftone_<name>.png
```

Each pattern is a few lines of math at the top of the script: grain spacing, wave
amplitude, ripple wavelength. The skyline needs the OpenStreetMap cache from
`tools/boston_map.py`. The hole sizes (`ht_dmin`, `ht_wall`, `ht_skip`) are in the lid.

## Clearance

The fans and clips hang 18.2 mm below the lid and the controller about 23 mm. Check
that the top piece of gear in the rack is at least that far below the top frame. The
clips sit outside the fans on the left and right, inside the rack opening.

## Measurements used

| Feature | Value |
|---|---|
| Rack top frame, outer | 499.2 × 459.7 (from Ubiquiti's 3D model, as for the Boston lid) |
| Rack opening | 419.4 × 399.0 |
| Fan (ARCTIC P12 Slim PWM PST) | 120 × 120 × 15 |
| Fan centres | ±104.85 across, ±99.75 front–back (centred in each quarter of the opening) |
| Controller (Delinx) | 76.5 × 24.5 × 22 |
| Halftone lattice | 5.2 mm pitch, holes 2.0–4.3 mm (0.9 mm thinnest wall) |
| Passive open area | over the opening: wood ~177 cm², waves ~240, ripples ~254, hex ~234 |

Skyline data © [OpenStreetMap contributors](https://www.openstreetmap.org/copyright),
available under the ODbL.
