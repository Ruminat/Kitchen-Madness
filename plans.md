# Kitchen Madness - development plan

Roadmap for **Kitchen Madness**, a top-down roguelite arena survivor in Godot 4.

See also: [context.md](context.md) for current project state and iteration rules, [progress.md](progress.md) for task status, and [game-setting.md](game-setting.md) for theme and content direction.

---

## North star

**Data-driven content, thin scenes, testable logic, readable chaos.**

Designers should add characters, enemies, weapons, drops, waves, and upgrades through `.tres` resources and focused scenes, not by hardcoding individual content into gameplay systems.

Every player-facing action must support both mouse and keyboard. WASD and arrow keys are always interchangeable for movement and menus.

---

## Completed roadmap summary

### Phase 2 - Core architecture

The prototype was refactored into modular systems: `EventBus`, `HealthComponent`, `Arena`, `WaveManager`, `EnemySpawner`, `WeaponController`, and data resources for enemies, weapons, drops, waves, and upgrades. The first automated checks and GdUnit4 tests were added.

### Phase 2 - Content and progression loop

The game gained enemy archetypes, weighted wave spawning, multiple weapon behaviors, XP orbs, health pickups, floating feedback, HUD polish, level-up choices, and free stat upgrades.

### Phase 3 - Wave/shop loop and presentation

Gold, between-wave shop, multi-wave flow, visual sprites, larger arena, following camera, off-camera spawning, visual capture tooling, and spawn-density tuning are in place. Current combat loop is playable through repeated waves.

---

## Active roadmap

### Phase 4A - Playable character roster

**Goal:** Let the player choose between multiple kitchen-creature characters, each with distinct base stats and a unique starting weapon.

| Task | Details |
|---|---|
| Character data resource | Add `CharacterDefinition` with id, display name, sprite, base stats, starting weapon, and short description |
| Character select UI | Add a simple pre-run character picker with mouse and keyboard support |
| Runtime character loading | Apply selected character sprite/stats/starting weapon when a run starts |
| Starting weapon rules | Ensure every character owns exactly one starting weapon by default |
| Tests | Cover character definition loading, default selection, and starting weapon assignment |

Initial roster should reuse the existing 9-character sprite sheet: Chef, Goblin, Onion, Cookie, Mushroom, Vampire, Witch, Dumpling, and Snowman.

---

### Phase 4B - Kitchen weapon roster

**Goal:** Remove the current generic weapons and replace them with kitchen-themed weapons from [game-setting.md](game-setting.md).

Current weapons to replace: pistol, shotgun, orbit blade.

Candidate first roster:

| Weapon | Role |
|---|---|
| Pepper grinder gun | Baseline ranged weapon, replaces pistol |
| Boiling soup splash | Short-range cone or splash, replaces shotgun |
| Onion ring blade | Orbiting melee weapon, replaces orbit blade |
| Kitchen knife | Fast single-target stab/throw option |
| Frying pan | Slow knockback weapon |
| Garlic bomb | Area burst weapon |
| Ladle boomerang | Returning projectile weapon |
| Toaster turret | Temporary deployable weapon |

| Task | Details |
|---|---|
| Weapon audit | Find every current weapon resource, scene, test, UI label, and starting loadout reference |
| Remove generic weapons | Delete or retire pistol/shotgun/orbit blade resources and references |
| Implement first kitchen weapons | Add data resources, icons/placeholders, behavior scenes/scripts as needed |
| Assign character starters | Map each playable character to a kitchen-themed starting weapon |
| Tests | Update weapon controller, projectile, shop, and character tests to use new weapon ids |

---

### Phase 4C - Shop becomes weapon upgrade shop

**Goal:** After each wave, the shop should offer weapons and weapon upgrades only. Stat upgrades belong only to level-up rewards.

| Task | Details |
|---|---|
| Split upgrade pools | Separate level-up stat upgrades from shop weapon offers |
| Weapon offer model | Define shop offers for adding a new weapon, improving an owned weapon, or upgrading weapon rarity/level |
| Shop UI copy | Rename/clarify shop labels so players understand it is weapon-focused |
| Pricing and availability | Make early shop offers affordable and avoid duplicate unusable offers |
| Tests | Cover shop pool filtering so stat upgrades never appear in shop |

---

### Phase 4D - VFX pass for game feel

**Goal:** Make combat more satisfying with lightweight, readable effects for enemy death, hits, projectiles, pickups, and weapon impacts.

Research notes from Godot 4 VFX references:

- Prefer `GPUParticles2D` for most 2D bursts and trails; use `CPUParticles2D` only when physics interpolation or low-end compatibility requires it.
- Use one-shot particle scenes for enemy death bursts and impact sparks; call `restart()` on reuse and clean up via the `finished` signal.
- Keep particle `amount` low, use scale/color curves to create density, and set visibility rects so off-screen particles are culled.
- Fade alpha to 0 at the end of each color ramp to avoid harsh popping.
- For projectile trails, use global-space trails where needed so particles remain behind the projectile instead of sticking to it.
- Pool frequently spawned VFX once enemy count and projectile count increase.

Useful references:

- Godot docs: <https://docs.godotengine.org/en/stable/tutorials/2d/particle_systems_2d.html>
- Godot `GPUParticles2D`: <https://docs.godotengine.org/en/stable/classes/class_gpuparticles2d.html>
- GPUParticles2D practical guide: <https://uhiyama-lab.com/en/notes/godot/gpu-particles2d-effects>

| Task | Details |
|---|---|
| VFX style guide | Define readable kitchen-themed bursts, smoke, crumbs, sparks, soup splashes, and pepper clouds |
| Enemy death effect | Replace instant disappearance with a short death burst/fade effect |
| Projectile polish | Add trails, impact sparks, and stronger silhouettes for weapon projectiles |
| Weapon-specific effects | Give kitchen weapons distinct effects without cluttering the screen |
| VFX manager/pooling | Add a small effect spawner/pool if direct instantiation becomes noisy or expensive |
| Visual tests | Capture before/after screenshots for surrounded player, projectiles, and enemy death moments |

---

### Phase 4E - Wave pacing and enemy density

**Goal:** Make early waves shorter and denser, then ramp duration and danger over time.

Target pacing:

- Wave 1 should last about 10-15 seconds.
- Each next wave should become longer, roughly +5 seconds per wave at first.
- Enemy count should increase, but individual enemies should generally be weaker.
- The game should lean toward many readable enemies instead of a few durable enemies.

| Task | Details |
|---|---|
| Wave duration formula | Add authored or formula-based durations starting near 10-15 seconds |
| Density retune | Increase spawn frequency/caps while lowering early enemy HP/contact damage where needed |
| Enemy stat pass | Rebalance chaser/sprinter/tank equivalents into weaker swarm-friendly pests |
| Wave resource update | Update `wave_01.tres` onward to follow the new pacing |
| Tests | Cover duration progression, spawn caps, and wave-definition selection |

---

### Phase 4F - Balance metrics and tuning

**Goal:** Start balancing by measuring the run economy and combat power instead of tuning only by feel.

Track these stats per character, weapon, and wave:

- Current weapon DPS and practical DPS against swarms
- Enemy HP budget per wave
- Expected XP per wave
- Expected gold per wave
- Kills per minute
- Time to level
- Shop purchasing power per wave
- Damage taken pressure by enemy mix

| Task | Details |
|---|---|
| Balance model doc | Create a simple balance sheet or markdown table for target stats by wave |
| Runtime metrics | Add lightweight counters for kills, gold, XP, damage dealt, damage taken, and weapon contribution |
| Debug summary | Print or display end-of-wave metrics for playtests |
| Weapon DPS estimates | Calculate theoretical DPS from `WeaponDefinition` values and compare with observed metrics |
| Character comparisons | Compare starting characters/weapons so no default pick is clearly dominant |
| Tests | Cover deterministic calculations for DPS, XP/gold budgets, and wave-duration targets |

---

## Definition of done

Every iteration should end with:

1. No parser/script errors; Godot opens cleanly and F5 smoke test works.
2. `.\tools\codecheck.ps1` passes when local tools are available.
3. New content remains data-driven through resources and focused scenes.
4. UI continues to support mouse and keyboard.
5. `progress.md` is updated with a short outcome summary.

