# PicoBattle

A [PICO-8](https://www.lexaloffle.com/pico-8.php) clone of **TravelBattle**, the pocket
Napoleonic board wargame by Andy Callan (Perry Miniatures).

Two armies of three brigades meet on a randomly generated battlefield. Combat is pure
dice — there are no hit points. **Destroy two of the enemy's three brigades to win.**

## Running it

Requires PICO-8. Drop the folder into your PICO-8 carts directory, then:

```
load tactic_test.p8
run
```

The cart `#include`s the `.lua` files beside it, so keep them together.

## Features

- **20×10 battlefield, randomly generated every game** — plains, forest, hills, towns and
  a connected road network, scrolling horizontally.
- **Six unit types**: Brigadier, Light Infantry, Elite Infantry, Light Cavalry, Heavy
  Cavalry and Artillery — each with its own movement, dice and quirks. Shape encodes type,
  colour encodes team, a corner pip encodes brigade.
- **Pre-battle draft**: compose each brigade from a shared unit pool and deploy it
  yourself, alternating with your opponent, then roll for initiative.
- **Three-phase turns**: Movement → Artillery → Combat.
- **Brigade cohesion** — units must stay chained to their Brigadier to move, so armies
  manoeuvre as formations rather than loose skirmishers.
- **Terrain that matters**: forest is foot-only and blocks line of sight, hills grant +1 in
  a fight and let guns see over everything, towns give defenders an extra die, roads add
  movement.
- **Squares, disorder and rout**: infantry can form square against cavalry, beaten units
  are shoved back toward their own lines and fight worse while disordered, and a unit with
  nowhere to retreat is destroyed.
- **Two modes**: hot-seat two-player, or one player against a CPU opponent.
- **Threat previews**: hover any enemy to see where it can move and what its guns cover.
- Single-level **undo** in the movement phase.
- Procedural graphics, sound effects, and two looping music tracks.

## Controls

| Button | Use |
|---|---|
| Arrows | Move cursor (and re-face a selected disordered unit) |
| 🅾️ | Confirm / select / advance phase (on the `next phase` button) / undo your last move |
| ❎ | Cancel selection |

Phases are advanced by moving the cursor onto the on-screen **`next phase`** button below
the board and pressing 🅾️.

## Documentation

**[HOW_TO_PLAY.md](HOW_TO_PLAY.md)** is the full player's rulebook — every unit, every
modifier and the exact combat maths. The cart also has a built-in quick-reference: press ❎
on the title screen.

## Layout

```
tactic_test.p8   cart: include list, title art, sound and music data
main.lua         game loop and state dispatch
unit.lua         unit prototypes and the six types
map.lua          map generation, terrain queries, movement/line-of-sight
board.lua        draft pool, deployment, turn and phase flow
input.lua        cursor and phase controls, move undo
combat.lua       dice, close combat, artillery, push/rally, win checks
fx.lua           particles and screen shake
draw.lua         screens, terrain, units, overlays, HUD
ai.lua           CPU opponent
_build.ps1       regenerates the baked title-screen art
```

## Credits

Based on *TravelBattle* by **Andy Callan**, published by **Perry Miniatures**. This is an
unofficial fan adaptation, made for love of the game.
