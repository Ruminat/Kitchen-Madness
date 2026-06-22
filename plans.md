# Kitchen Madness - development plan

Roadmap for **Kitchen Madness**, a top-down roguelite arena survivor in Godot 4.

See also: [context.md](context.md) for current project state and iteration rules, [progress.md](progress.md) for task status, and [game-setting.md](game-setting.md) for theme and content direction.

---

## North star

**Data-driven content, thin scenes, testable logic, readable chaos.**

Designers should add characters, enemies, weapons, drops, waves, and upgrades through `.tres` resources and focused scenes, not by hardcoding individual content into gameplay systems.

Every player-facing action must support both mouse and keyboard. WASD and arrow keys are always interchangeable for movement and menus.

---

## Active roadmap

### Phase 5A - Critical damage system

**Goal:** Add critical hits that deal bonus damage based on a crit chance stat.

| Task | Details |
|---|---|
| Crit stat | Add `crit_chance` and `crit_damage` to player stats (base 5% chance, 150% damage) |
| Crit calculation | Modify damage calculation to roll for crits and apply multiplier |
| Upgrade support | Add level-up upgrades for crit chance and crit damage |
| Visual feedback | Show yellow crit numbers when crits occur |
| Tests | Cover crit roll probability and damage multiplier |

---

### Phase 5B - Enhanced damage number visuals

**Goal:** Make damage numbers more readable and satisfying, with special treatment for crits.

| Task | Details |
|---|---|
| Crit number style | Crit damage numbers should be larger (1.5x scale) and yellow/gold color |
| Normal number polish | Add slight bounce/pop animation to all damage numbers |
| Number pooling | Pool floating text objects if instantiation becomes expensive |
| Configurable styling | Allow weapon definitions to specify damage number color accent |
| Tests | Verify crit numbers render with correct styling |

---

### Phase 5C - Projectile visuals fix

**Goal:** Fix the bug where gun weapons are shooting themselves as projectiles instead of just particles.

| Task | Details |
|---|---|
| Bug investigation | Find why gun sprite is being launched as projectile |
| Projectile cleanup | Ensure only the projectile scene (not the weapon sprite) is instantiated |
| Particle-only option | For spray/cone weapons, use particle effects without physical projectiles |
| Visual review | Capture screenshots of fixed projectiles in action |
| Tests | Verify projectile instantiation uses correct scene |

---

### Phase 5D - Basic sound effects

**Goal:** Add foundational audio feedback for core gameplay actions.

| Task | Details |
|---|---|
| Sound research | Find free SFX from sources like OpenGameArt, Freesound, or itch.io |
| Core sounds needed | Enemy hit, enemy death, player hurt, shoot (per weapon type), level up, wave complete, shop buy, pickup collect |
| Audio manager | Simple `AudioManager` autoload for playing one-shot SFX |
| Volume control | Master volume setting (can be simple for now) |
| Integration | Hook sounds to EventBus or direct calls at action points |

---

### Phase 5E - Statistics persistence

**Goal:** Store run statistics to disk so AI can analyze and help balance the game.

| Task | Details |
|---|---|
| Stats folder | Use `./ignored/stats/` for JSON stat files |
| Run summary format | JSON with: character, weapons, upgrades, final wave, total kills, total damage dealt/taken, gold earned, time per wave, level reached |
| Save timing | Write stats after run ends (death or quit) |
| File naming | Timestamp-based filenames like `stats_2025-01-15_143022.json` |
| Append mode | Add to existing file or create new per session |

---

### Phase 5F - Melee weapons

**Goal:** Add true melee weapons that damage enemies in close range without creating projectiles.

| Task | Details |
|---|---|
| Melee weapon type | New `WeaponType.MELEE` in `WeaponDefinition` |
| Kitchen knife | First melee weapon - fast stab with short forward arc |
| Frying pan | Slow swing with knockback in 180-degree frontal arc |
| Hit detection | Area query or raycast to find enemies in weapon range/arc |
| Visual feedback | Swing animation/trail effect on attack |
| Range stat | Add `melee_range` to define attack distance |
| Arc/angle | Define sweep angle for cone-based melee attacks |
| Tests | Cover melee hit detection and damage application |

---

### Phase 6A - Enemy variety and swarm spawning

**Goal:** Add more enemy types and spawn them in swarms rather than individually.

| Task | Details |
|---|---|
| Enemy roster expansion | Add more kitchen pest enemies (see game-setting.md for ideas) |
| Swarm spawn system | Spawn enemies in groups of 3-8 instead of one-by-one |
| Swarm timing | Burst spawns with brief cooldowns between swarms |
| Wave swarm density | More enemies per wave with swarm-based pacing |
| New enemy types | Consider: flies (fast, fragile), ants (small swarms), pantry moths (erratic movement) |
| Enemy variants | Add "greasy", "mutant", or "angry" variants with slight visual/stat differences |
| Tests | Verify swarm spawning and enemy variety |

---

### Phase 6B - Shop UI overhaul

**Goal:** Improve the shop UI with better structure, icons, spacing, and visual polish.

| Task | Details |
|---|---|
| Layout structure | Better organized grid or card-based layout |
| Weapon icons | Display weapon sprites/icons in shop cards |
| Price display | Clearer gold cost with coin icon |
| Rarity indicators | Visual distinction for weapon tiers/qualities |
| Card styling | Background panels, borders, hover states |
| Spacing | Proper padding between elements, less cramped feel |
| Selection highlight | Clearer keyboard/mouse selection indicator |
| Description tooltips | Optional: hover for weapon description/stats |
| Keyboard shortcuts | Show key hints (1-4) more prominently |
| Tests | Verify shop UI layout and interaction remain functional |

---

## Definition of done

Every iteration should end with:

1. No parser/script errors; Godot opens cleanly and F5 smoke test works.
2. `.	oolscodecheck.ps1` passes when local tools are available.
3. New content remains data-driven through resources and focused scenes.
4. UI continues to support mouse and keyboard.
5. `progress.md` is updated with a short outcome summary.

---

## Completed roadmap summary

**Phases 1-4 completed:** Core architecture (EventBus, HealthComponent, WaveManager, WeaponController), content loop (enemies, XP, drops, level-ups), wave/shop flow (gold, between-wave shop, multi-wave), visual polish (sprites, camera, VFX), character roster (9 kitchen creatures), kitchen weapons (8 themed weapons replacing generics), weapon-focused shop, VFX pass (particles, trails, death bursts), wave pacing (12s→17s→22s progression), and balance metrics (DPS calculator, runtime tracking, end-of-wave summary display).

