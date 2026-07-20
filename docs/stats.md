# Stats

The design source-of-truth for every gameplay stat in Kitchen Madness. This is a
**design spec**, written in game-design units, not engine units. When this file
changes, the code should be updated to match it.

> Note on units: this document uses abstract "design units" (see
> [Measurement units](#measurement-units)). The engine currently stores some values
> in pixels (e.g. `move_speed = 220`). Implementation is responsible for converting
> between design units here and engine units via a single documented factor, so this
> file stays the human-readable source of truth.

---

## Measurement units

Distances (**area** and **attack range**) are all measured relative to the player's
size:

- **10 area = the player's radius.**
- So **20 area = the player's diameter** (one whole player across).
- **100 area = 5 player diameters.**

**Area** — the radius or distance an effect or weapon covers. An "area of 60" reaches
out 60 area units (6 player-radii) from its center.

**Attack range** — the maximum distance from which something (a weapon, pet, skill,
structure, trap, …) can pick and hit a target. Uses the same units as area.

**Move speed** — how fast an entity travels, measured in **area units per second**.
`1` move speed = 1 area per second; `100` move speed = 100 area per second. The player
and most entities have a base move speed of **30**.

---

## Player stats

### Health (HP)

Total damage the entity can take before dying. Flat value (e.g. 90, 120). Percentage
upgrades (e.g. `HP +5%`) scale the current maximum.

### Armor

Reduces **all** incoming damage by a percentage. Measured in **points** (e.g.
`Armor +1`, or `−2 armor` from a perk). Each point of armor removes a fixed
percentage of damage taken.

> Tunable: the damage-reduction percentage per armor point is a balance value to be
> defined in the balance model, not fixed here.

### Damage

A global multiplier on the damage dealt by the player's weapons and (unless stated
otherwise) their skills, pets, structures, and traps. Expressed as a percentage
modifier (e.g. `−12%`, `+24%`). `0%` means unmodified base damage.

### Attack speed

A global multiplier on how often the player's weapons attack. Expressed as a
percentage modifier (e.g. `+18%`). Higher attack speed = more attacks per second =
shorter time between attacks.

### Crit chance

The probability that an attack deals a critical hit. Expressed as a percentage
modifier added on top of a base chance (e.g. `+24%`).

### Crit damage

The damage multiplier applied when an attack crits (e.g. a critical hit for 1.5×
damage). Separate from crit chance.

### Luck

Increases the chance of good things happening. Specifically, luck raises the chance
of:

- being **offered an item in the shop that you already own** (e.g. rolling a "Heavy
  Fridge" upgrade when you already have "Heavy Fridge"), so you can double down on a
  build;
- an enemy **dropping EXP or Grease** on death.

Expressed as a percentage modifier (e.g. `+12%`).

### Evasion

The chance to completely **evade an enemy attack**. On a successful evade, the player
takes **no damage** but still gets the brief invulnerability window they would have
gotten from actually being hit (so the same i-frame behavior, just without the
damage). Expressed as a percentage (e.g. `+4%`).

### Move speed

See [Measurement units](#measurement-units). Base **30** for all players; upgrades and
perks modify it (e.g. `Move speed +5%`, `−3% move speed`).

---

## Base player stats

Every player starts from this shared baseline, then applies their own modifiers:

| Stat | Base |
|---|---|
| Move speed | 30 |
| Armor | 0 |

Health, damage, attack speed, crit chance, luck, and evasion are set per character.
See [players/index.md](players/index.md).

---

## Stat summary

| Stat | Unit | Meaning |
|---|---|---|
| Health (HP) | flat | Damage taken before dying |
| Armor | points | % damage reduction per point |
| Damage | % modifier | Global outgoing-damage multiplier |
| Attack speed | % modifier | Global attack-rate multiplier |
| Crit chance | % modifier | Probability of a critical hit |
| Crit damage | ×multiplier | Damage multiplier on a crit |
| Luck | % modifier | More duplicate shop offers + more EXP/Grease drops |
| Evasion | % | Chance to take no damage (still triggers i-frames) |
| Move speed | area/sec | Travel speed; base 30 |
| Area | area units | Radius/size of an effect (10 = player radius) |
| Attack range | area units | Max distance to hit a target |
