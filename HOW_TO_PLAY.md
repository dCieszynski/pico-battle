# PicoBattle — How to Play

A complete player's rulebook for **PicoBattle**, a PICO-8 clone of the *TravelBattle*
Napoleonic board wargame. This document explains everything a player needs: the goal, the
units, setup, the turn sequence, and the exact combat maths. (For how the cart is *built*,
see the source files.)

---

## 1. The Goal

Two armies of **three brigades** face off on a small Napoleonic battlefield. Combat is
**dice-based — there are no hit points**. You win the moment you **completely destroy two
of the enemy's three brigades**.

A brigade is destroyed when its **last fighter is lost**; its Brigadier is then removed with
it. So you don't have to kill all 15 enemy units — you only need to break **2 of their 3
brigades** (8 fighters, if each broken brigade had 4 left, plus their leaders — but in
practice far fewer, since focusing fire on one brigade at a time wins fastest).

---

## 2. Game Modes

Chosen on the **title screen** (use ↑/↓ to toggle, press 🅾️ to start):

- **2 players — hot-seat** (default): players share one device and alternate turns. A
  "pass the device" screen appears between turns so neither player sees the other set up
  their move mid-turn.
- **1 player — vs CPU**: you are **Player 1**; the computer plays **Player 2**. The CPU
  drafts and deploys randomly, then plays each phase with simple heuristics (it focus-fires
  the enemy's weakest brigade, takes favourable fights, and fires the easiest artillery
  shots).

Press ❎ on the title screen for the built-in **how-to-play** pages (a quick summary; this
document is the full version).

---

## 3. The Battlefield

- The map is **20 tiles wide × 10 tiles tall**, randomly generated every game. It is wider
  than the screen, so the view **scrolls horizontally** to keep your cursor in view.
- Player 1 deploys along the **top two rows**; Player 2 along the **bottom two rows**. The
  armies face each other vertically.
- Each tile is one of five terrain types.

### Terrain effects

| Terrain | Passable by | Effect |
|---|---|---|
| **Plains** | all | Open ground, no effect. |
| **Forest** | **foot only** (infantry/guard) | Blocks artillery line-of-sight. Cavalry **attacking a unit that is in** forest fights at **−1**. Cavalry and artillery **cannot enter**. |
| **Hill** | all | Blocks artillery LOS — **but a gun standing on a hill sees over everything** (unobstructed fire). Foot/cavalry **standing on** a hill fight at **+1**. Cavalry **attacking a unit on** a hill fights at **−1**. |
| **Town** | all | Blocks artillery LOS. A unit **defending on** a town rolls **one extra die** (the attacker gets no town die). |
| **Road** | all | **+1 movement** if a unit both **starts and ends** its move on road tiles. Roads connect the towns in a network. |

---

## 4. The Units

Each army has **15 units**: **3 brigades of 5**, where every brigade is **1 Brigadier + 4
fighters**. There are six unit types.

### How to read a unit on screen

Three independent visual channels — never mix them up:

- **Shape = unit type** (see table below).
- **Colour = team** — Player 1 is **cyan**, Player 2 is **red**.
- **Corner pip = brigade** — brigade 1 = **white**, brigade 2 = **yellow**, brigade 3 =
  **orange**.

A small **white arrow** shows which way a unit faces. **Red corner pips** mark a unit that
is **shaken/rattled** (disordered — see §9). A unit that has **already acted** this phase is
dimmed to grey.

### Unit table

| Type | Shape | Move | Key traits |
|---|---|---|---|
| **Brigadier** | Circle + cross | 2 | **Cannot fight.** Immune to direct kills, but **dies with his brigade** when its last fighter falls. Leads the brigade (see Cohesion, §6). Shoved off the map → his brigade is **immobilised**. |
| **Infantry** (light) | Filled circle | 1 | Can form **Square** (defensive anti-cavalry formation). |
| **Guard Infantry** (elite) | Ringed circle | 1 | **Re-rolls** in combat; **rallies more easily**; **survives** an artillery "eliminate" result of 5; can form Square. |
| **Light Cavalry** | Diamond outline | 2 | **Bonus die** when charging non-Square foot. |
| **Heavy Cavalry** | Filled diamond | 2 | **Re-rolls** in combat **and** gets the cavalry bonus die. |
| **Artillery** | Square + dot | 1 | **Move OR fire** each turn (never both). Long-range gun. **Helpless in melee** (−2 vs foot, −3 vs cavalry). |

> **Re-roll** units roll an extra die and keep the best. **Bonus-die** situations add
> further dice, again keeping the best (see §8).

---

## 5. Setup — the Brigade Draft

Before the battle, players **alternate** building and placing brigades, one at a time
(P1, P2, P1, P2, P1, P2) until all six brigades are down. Each brigade is handled in two
sub-phases:

### 5a. Compose (draft the 4 fighters)

Each brigade gets a Brigadier automatically; you choose its **4 fighters** from a shared
per-player pool:

| Fighter pool (per player) | Available |
|---|---|
| Light Infantry | 4 |
| Guard (Elite) Infantry | 2 |
| Artillery | 2 |
| Light Cavalry | 2 |
| Heavy Cavalry | 2 |
| *(Brigadiers)* | *3, automatic — one per brigade* |

That's **12 fighters total**, exactly enough for three brigades of four. The pool empties
as you draft, so your **third brigade is forced to whatever remains** — plan your first two
brigades accordingly.

**Compose controls:** ↑/↓ pick a unit type · → add one · 🅾️ remove one · you must reach
**4/4** before confirming with 🅾️. Press ❎ to **hide the draft box and inspect the map**
(←/→ scroll; 🅾️/❎ brings the box back).

### 5b. Place (deploy the brigade)

The drafted brigade deploys as a **3-wide × 2-deep block** along your edge. Slide it
left/right and confirm. You cannot place a block where it would **strand** a brigade you
still have to deploy.

**Place controls:** ←/→ slide the block · 🅾️ place it · ❎ go back to re-compose.

### 5c. Initiative

When all six brigades are placed, each player rolls 1d6 (re-rolling ties). The **higher
roll takes the first turn**.

---

## 6. Your Turn

A turn runs through **three phases, in order**:

```
MOVE  →  FIRE (artillery)  →  FIGHT (close combat)
```

You advance from one phase to the next yourself (see Controls). **Fire and Fight are
optional** — you may skip straight through them. When you end the Fight phase, your turn is
over and play passes to your opponent.

### Brigade Cohesion (important!)

At the **start of your turn**, a non-Brigadier may move **only if it is connected to its own
Brigadier** through an unbroken chain of same-brigade units (counting all 8 directions,
diagonals included). If a unit is cut off from its Brigadier, it **cannot move that turn**
(it can still fight and fire). Keep your brigades **clustered around their leader**.

If a **Brigadier is shoved off the map**, his whole brigade permanently **fails cohesion and
can never move again** (its fighters may still fight and fire).

---

## 7. Controls

| Input | Action |
|---|---|
| **Arrows** | Move the cursor. (Also re-face a selected **rattled** unit in place.) |
| **🅾️ (Z / C)** | Select a unit · confirm an action · **advance to the next phase** (when the cursor is on the next-phase button) · **undo your last move** (point the cursor at the unit you just moved and press 🅾️). |
| **❎ (X / V)** | Cancel the current selection. |

### Advancing phases — the "next phase" button

There is a **`next phase` button** drawn just **below the board**. To advance:

1. Press **↓** until the cursor steps **off the bottom of the board onto the button** — it
   lights up solid with a white border.
2. Press **🅾️** to move to the next phase (Move → Fire → Fight → end of turn).
3. Press **↑** to step back up onto the board.

### Undo (Move phase only)

Made a move you regret? **Point the cursor at the unit you just moved and press 🅾️** — it
snaps back to where it started (position, facing, and Square state restored). Only the
**most recent** move can be undone, and only **during the Move phase of the same turn**.
Combat and artillery results **cannot** be undone (they involve dice).

---

## 8. Movement (Move phase)

- Movement is **8-directional**; a diagonal step costs the same as an orthogonal step.
- A unit may move up to its **Move allowance** (Infantry/Guard/Artillery = 1; Brigadier/
  Cavalry = 2).
- **Road bonus:** **+1 step** if the unit **starts on a road and the extra step also ends on
  a road**.
- Valid destinations are highlighted (cyan tile outlines). You cannot move **through or onto
  an occupied tile**, and **only foot units may enter forest**.
- **Artillery moves OR fires** — if a gun moves, it cannot fire this turn, and vice-versa.
- **Forming Square:** select an Infantry/Guard unit and confirm **without moving** (press 🅾️
  on its own tile) to toggle **Square** formation. A unit in Square **cannot move** but gains
  a powerful defensive bonus against cavalry (§9). Toggle again to leave Square.

### Threat previews (free, no selection needed)

- **Hover an enemy unit** to see where it could move next turn (its reach outlined in red).
- **Hover any artillery piece** (yours or the enemy's) to see its firing reach (orange
  centre-dots). Hovering an enemy gun shows both its move reach *and* its fire range at once.

---

## 9. Artillery (Fire phase)

Artillery is your long-range answer. In the Fire phase, select a gun that **has not moved**
and choose a target.

- **Lines of fire:** a gun fires along the **8 cardinal/diagonal lines** only.
- **Range:** up to **6 tiles**.
- **Line of sight:** forest, hill, town, **and any unit** block the line beyond themselves.
  - **High ground:** a gun **standing on a hill** has **unobstructed** LOS — terrain and
    units no longer block its lines, so it can hit *any* enemy along each line out to range 6.
- A gun **cannot fire while adjacent to an enemy** (it's tied up in melee), hill or not.

### To-hit (roll 1d6)

| Distance to target | Hits on |
|---|---|
| 6 | **6** |
| 5 | **5 or 6** |
| 1–4 | **4, 5, or 6** |

### Effect on a hit (roll 1d6) — vs a normal unit

| Roll | Result |
|---|---|
| 1–3 | No effect |
| 4 | **Disrupt** — the unit is turned around and becomes shaken (rattled next turn). |
| 5 | **Eliminated** *(Guard Infantry survives this)* |
| 6 | **Eliminated** |

### Effect on a hit — vs a Brigadier (he can't be killed directly)

| Roll | Result |
|---|---|
| 1–3 | No effect |
| 4 | **Disrupt** (can't move next turn) |
| 5 | **Pushed back 1 tile** (not disrupted — still free to act) |
| 6 | **Pushed back 2 tiles** |

A Brigadier shoved **off the map** is gone, and his brigade is immobilised.

---

## 10. Close Combat (Fight phase)

Close combat is **optional and player-initiated**. In the Fight phase, select one of your
units that is **adjacent (8 directions) to an enemy** and choose which adjacent foe to
attack. (Brigadiers cannot attack.) Ending the phase fights nothing — it just ends your turn.

### The roll

Both sides roll **1d6**. Re-roll units and bonus-die situations roll **extra dice and keep
the best one**. Add the situational modifiers below to each side's result, then compare.

### Bonus dice (keep best of extra dice)

- **Cavalry vs non-Square foot:** the **attacking cavalry** gets a bonus die.
- **Square foot vs Cavalry:** the **defending square** gets a bonus die.
- **Defending on a Town:** the **defender** gets a bonus die (stacks with Square).
- **Guard / Heavy Cavalry** always re-roll (their built-in extra die).

### Score modifiers (added to the die result; they stack)

| Situation | Modifier |
|---|---|
| Unit is **shaken** (just pushed, during the enemy's turn) | **−3** |
| Unit is **rattled** (the disorder carried into its own turn) | **−2** |
| **Artillery** caught in melee, vs a foot enemy | **−2** |
| **Artillery** caught in melee, vs a cavalry enemy | **−3** |
| Infantry/Cavalry fighting **while standing on a hill** | **+1** |
| **Cavalry attacker** whose target stands on a hill **or** in forest | **−1** |

### Resolving the result

Compare the two final scores. The lower score is the **loser**, and the margin
`diff = |attacker − defender|` decides the outcome:

| `diff` | Outcome for the loser |
|---|---|
| **0** | Stalemate — nobody moves. |
| **1 or 2** | **Pushed back 1 tile** and disordered. |
| **3 or more** | **Eliminated.** |

> Because disorder is a hefty penalty, a **shaken** unit that loses again the same turn —
> *even a tie* — can hit `diff ≥ 3` and be **destroyed**. Disordered units are fully
> killable; there is no protection.

### The push-back

- The loser is always pushed **one tile toward its own deploy edge** (P1 retreats **up**,
  P2 retreats **down**) — *not* simply away from the attacker — and is **turned to face that
  way**. Any pushed unit becomes **shaken** (→ rattled next turn).
- **Chain push:** a friendly unit directly behind the loser is shoved along too.
- **No room to retreat = destroyed.** A non-Brigadier that cannot fall back — blocked by an
  enemy, impassable terrain, or a friendly that itself can't clear — is **eliminated**
  instead of holding. (A pinned **Brigadier** simply stays put; he is never killed in
  combat.)
- **Pushed off the board edge → Rally roll:** roll 1d6. **Guard and Artillery rally on 3+**,
  everyone else on **4+**. Fail, and the unit is lost.

### Fighting a Brigadier

Brigadiers **never roll dice**. Attacking one simply **shoves him**: **cavalry push him 2
tiles, infantry/artillery push him 1 tile** (no disrupt — he's free next turn). He can't be
killed in combat, but a shove **off the map** removes him and immobilises his brigade.

---

## 11. Disorder: Shaken & Rattled

Getting pushed (by combat or an artillery disrupt) leaves a unit **disordered**:

1. **Shaken** — applied immediately, during the **enemy's** turn. The unit fights at **−3**.
2. **Rattled** — on the unit's **own next turn**, the shaken state eases to **−2**, but the
   unit **may only re-face** that turn (no moving, attacking, or firing). At the start of
   that turn it is **auto-turned to face back toward the threat** (you can still re-face it
   manually with the arrows).

So a disrupted unit loses a turn of action and fights weakly until it recovers — keep
pressing a shaken enemy to finish it.

---

## 12. Winning

You win the instant **two of the enemy's three brigades are destroyed**. A brigade dies when
its **last fighter** is eliminated (its Brigadier goes down with it). The result is checked
after every combat and every artillery shot — you'll always see the deciding blow before the
victory screen.

---

## 13. Strategy Tips

- **Keep brigades together.** Cohesion is checked from the Brigadier outward; a straggler
  that loses contact can't move. Advance as a cluster, leader in the middle.
- **Concentrate force.** Breaking **two** brigades wins — gang up and wipe out one brigade at
  a time rather than spreading damage across all three.
- **Use cavalry on the open field**, but not into rough ground: charging a unit on a hill or
  in forest costs you −1, and charging a formed **Square** hands the defender a bonus die.
- **Form Square** with infantry when cavalry threatens — it flips the cavalry's advantage
  into a defender's bonus die.
- **Hold the high ground.** Standing on a hill is **+1** in melee, and a gun on a hill fires
  over everything.
- **Defend in towns.** The extra defender die makes town garrisons very tough to dislodge.
- **Soften before you strike.** Artillery (or a first combat) that leaves an enemy
  **shaken** sets up an easy kill — a disordered unit that loses again, even on a tie, is
  destroyed.
- **Protect your Brigadiers.** They can't be killed outright, but losing a brigade's
  fighters kills the leader too — and a Brigadier shoved off the map freezes his whole
  brigade.
- **Don't forget undo.** Mis-stepped in the Move phase? Point at the unit and press 🅾️ to
  take it back (same turn, last move only).

---

## 14. Quick Reference

**Turn:** Move → Fire → Fight → (pass). Fire & Fight are optional.

**Advance a phase:** cursor ↓ onto the `next phase` button, press 🅾️.
**Undo last move:** 🅾️ on the unit you just moved (Move phase).
**Cancel selection:** ❎.

**Move allowance:** Foot & Artillery 1 · Brigadier & Cavalry 2 · Road +1 (start & end on road).

**Artillery to-hit:** dist 6 → 6 · dist 5 → 5+ · dist ≤4 → 4+. Range 6, 8 lines, LOS blocked
by terrain/units (a gun on a hill ignores blocking).

**Artillery effect:** 1–3 none · 4 disrupt · 5 kill (Guard lives) · 6 kill.

**Combat:** both roll 1d6 (+ bonus dice, keep best; + modifiers). Loser by margin:
0 stalemate · 1–2 push 1 · 3+ killed. No retreat room → killed. Off-board → rally (Guard/Arty
3+, else 4+).

**Disorder:** shaken −3 (enemy turn) → rattled −2 (own turn, re-face only).

**Win:** destroy 2 of 3 enemy brigades.
