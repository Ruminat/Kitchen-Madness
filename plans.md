# Kitchen Madness - development plan

Roadmap for the **Kitchen Madness**, a top-down roguelite arena survivor in Godot 4.

See also: [context.md](context.md) for current project state and iteration rules, [progress.md](progress.md) for task status, and [game-setting.md](game-setting.md) for theme and content direction.

---

## North star

**Data-driven content, thin scenes, testable logic, readable chaos.**

Designers should add characters, enemies, weapons, drops, levels, and upgrades through `.tres` resources and focused scenes, not by hardcoding individual content into gameplay systems.

Every player-facing action must support both mouse and keyboard. WASD and arrow keys are always interchangeable for movement and menus.

---

## Active roadmap — The Great Rework (R-series) — ✅ COMPLETE

**Status: R0–R8 all complete** (383 tests, 0 failures; codecheck green). See
[progress.md](progress.md) for the per-phase outcome summary.

The current build is technically complete but **not fun**: content was added by
volume, not by design. This roadmap deletes most of that content and rebuilds around
a small, hand-tuned, fully data-driven core — **quality over quantity**. See
[GAME_DESIGN.md](GAME_DESIGN.md) for the originating design brief, [docs/stats.md](docs/stats.md)
for the stat spec, and [docs/players/index.md](docs/players/index.md) for the roster.

Everything below stays true to the North star: new content is authored through
`.tres` resources and focused scenes, never hardcoded into systems.

### Guiding decisions

- **Reset, don't extend.** Old characters, weapons, and level upgrades are removed
  wholesale and replaced with the small curated sets below.
- **Five content categories**, three of them brand new:
  1. **Weapons** — attached to the player (exists, reworked).
  2. **Level upgrades** — chosen on level-up (exists, reworked).
  3. **Perks** — bought in the shop (new).
  4. **Skills** — autonomous effects, *not* attached to the player (new).
  5. **Pets / structures / traps** — autonomous entities, *not* attached to the
     player (new).
- **Design units, not pixels.** All distances are authored in "area units"
  (10 area = player radius) and speeds in area/second (see [docs/stats.md](docs/stats.md)).
  Implementation converts design units → engine units through a single documented
  factor. Base move speed in design units is `30`; the engine's current `220`
  becomes that factor's job, not scattered magic numbers.

### R0 — Design & docs *(this pass)*

- [x] Player bios + stats: `docs/players/{TheNewbie,MrBarret,Natsumi}.md` + `index.md`.
- [x] Stat spec: `docs/stats.md` (units, armor, evasion, luck, area, attack range).
- [x] Base circle template `assets/base/PlayerCircle.png` (256×256 RGBA) — every
      player is generated one-at-a-time from this, never as a grid sheet.
- [x] plans.md / progress.md updated to this roadmap.

### R1 — Stat foundation ✅

Extend the stat model so the new characters, upgrades, and perks have something to
modify. Do this first — everything else depends on it.

- Add to `CharacterDefinition` (and the player runtime): `armor` (points),
  `damage_mult` (%), `attack_speed_mult` (%), `evasion` (%); change `luck` and
  `crit_chance` to the percentage-modifier model from [docs/stats.md](docs/stats.md).
- Introduce the **area-unit → pixels** and **move-speed → engine** conversion in one
  place (e.g. a `StatUnits`/balance constant). Base move speed `30` design units.
- Apply `armor` (% damage reduction) and `evasion` (chance to negate a hit while
  still granting i-frames) in the player damage path.
- Tests: armor reduction, evasion negation + i-frames, modifier stacking.

### R2 — Player roster reset (3 characters) ✅

- Remove the 9 old character `.tres` and their sprites; add **The Newbie**,
  **Mr. Barret**, **Natsumi** with the stats from `docs/players/`.
- Generate each sprite individually from `assets/base/PlayerCircle.png` (transparent
  bg, 256×256), then retire the grid-splitter path for players. Update
  `docs/player-roster.md`.
- Character-select UI adapts to 3 entries (keyboard + mouse still required).

### R3 — Weapon reset (3 weapons) ✅

Remove all 8 current weapons; add these, authored in design units (attack speed as
seconds/attack, area & range in area units):

| Weapon | Type | Rate | Damage | Area | Range |
|---|---|---|---|---|---|
| Kitchen Knife | melee | 0.8s | 25 | 20 | 10 |
| Frying Pan | melee | 1.9s | 60 | 25 | 15 |
| Rotten Tomato | ranged (tomato projectile) | 1.2s | 40 | 5 | 80 |

- Map design-unit fields onto `WeaponDefinition`; re-point each character's
  `starting_weapon`. Re-baseline `BalanceCalculator` on the new numbers.

### R4 — Level-upgrade reset (8 upgrades) ✅

Replace the current upgrade `.tres` with: `Armor +1`, `HP +5%`, `Attack speed +10%`,
`Damage +10%`, `Area +5%`, `Move speed +5%`, `Luck +5%`, `Evasion +4%`. Each wires to
the R1 stat model. Level-up picker still offers 1-of-3, mouse + keyboard.

### R5 — Perks (shop content, new) ✅

New content type bought in the shop:

| Perk | Effect |
|---|---|
| Bring me more | +5% enemies |
| The crazy one | −2 armor, +10% attack speed |
| Getting fatty | −3% move speed, +1 armor |

- "Bring me more" feeds the spawner's count multiplier. Integrate perks into
  `ShopManager` offers alongside weapons.

### R6 — Skills (autonomous, new) ✅

Player-independent effects with per-level scaling and max levels:

| Skill | Cadence | Damage | Area | Per level | Max |
|---|---|---|---|---|---|
| Heavy Fridge | falls / 3s on a random enemy | 60 | 60 | +10% dmg, +5% area | 6 |
| Wraith of Cooking God | fires / 6s, lightning on some enemies | 300 | 10 | +10% dmg, +1 hit | 5 |
| Garlic Stench | aura ticks / 0.2s around player | 10 | 30 | +10% faster ticks, +15% area | 6 |

- Build a `SkillDefinition` + a skill runner that ticks independently of the weapon
  system. Acquisition & upgrades flow through shop / level-up (respecting Luck's
  duplicate-offer rule).

### R7 — Pets / structures / traps (autonomous entities, new) ✅

Non-weapon entities. Start with one of each:

| Entity | Kind | Rate | Damage | Area | Range | Move | Notes |
|---|---|---|---|---|---|---|---|
| Nasty Cat | pet | 1.0s | 40 | 20 | 10 | 30 | fights; immune to all damage |
| Bean Shooter | structure | 0.5s | 50 | — (single target) | 240 | — | can't move |
| Banana Mine | trap | spawn /2s | 50 | 40 | — | — | spawns 30–240 from player; per level +10% dmg, +20% spawn rate, +10% area, max 6 |

- Add an `EntityDefinition`/spawner for autonomous allies distinct from weapons.

### R8 — Acquisition & integration polish ✅

- Unify how weapons / skills / pets / structures / traps / perks appear in the shop
  and level-up flows; make Luck's "offer a duplicate you already own" rule apply
  across all upgradeable categories.
- Rebalance pressure/economy against the new roster and re-green the test suite.

---

## Definition of done

Every iteration should end with:

1. No parser/script errors; Godot opens cleanly and F5 smoke test works.
2. `.\tools\codecheck.ps1` passes when local tools are available.
3. New content remains data-driven through resources and focused scenes.
4. UI continues to support mouse and keyboard.
5. `progress.md` is updated with a short outcome summary.

---

## Completed roadmap summary

**Phases 1–4:** Core architecture (EventBus, HealthComponent, WaveManager, WeaponController), content loop (enemies, XP, drops, level-ups), wave/shop flow, visual polish, 9 characters, 8 kitchen weapons, weapon-focused shop, VFX pass, wave pacing, balance metrics.

**Phase 5A — Critical damage:** Crit chance/damage stats, roll on hit, level-up upgrades, yellow crit numbers, tests.

**Phase 5B — Damage number visuals:** Pooled labels, bounce/pop animation, 1.5× crit scale, per-weapon color field.

**Phase 5C — Projectile visuals fix:** Removed weapon textures from projectile defs; default bolt + VFX tint.

**Phase 5D — Basic sound effects:** `AudioManager` autoload, synthesized SFX, EventBus hooks.

**Phase 5E — Statistics persistence:** Run summaries to `ignored/stats/` as timestamped JSON.

**Phase 5F — Melee weapons:** Kitchen knife + frying pan with arc hits, knockback, swing VFX.

**Phase 6A — Enemy variety & swarms:** Ant/moth enemies, burst swarm spawning, cluster radius, tests.

**Post-6A tuning:** 3× wave density, global arena bounds, enemy/player collisions, camera clamp.

**Phase 6B — Shop UI overhaul:** 2×2 card grid with icons, badges, tooltips, keyboard nav.

**Performance optimization pass:** Off-screen enemy/VFX culling, particle throttling, render-scale settings, swarm cap fix, `optimizations.md`.

**Phase 7A — HUD, Grease currency, shop layout:** Structured HUD panels, Grease rebrand, 5 fixed shop slots with sold-state, escalating reroll cost.

**Phase 7B — World-space damage numbers:** `FloatingTextManager` as world `Node2D`; labels stay at hit location; pooling unchanged.

**Phase 7C — Combat balance tuning:** 10% density growth (interval-only), smaller swarms, wave-scaled enemy HP/damage, +5% combat upgrades, calculator/metrics fixes.

**Phase 7D — Audio mix and distance falloff:** Music-forward defaults; `play_sfx_at()` distance falloff; per-sound trims; player hurt quieter.

**Phase 7E — Idle squash animations:** Reusable `IdleSquash` component on player/enemy `Visual` nodes; collision untouched.

**Phase 7F — Economy and XP rebalance:** Lower drop rates, 240+65 XP curve, +15%/wave shop costs, affordability helper.

**Settings overlay:** Pause-safe settings menu (resolution, audio, mute), persisted config, E2E layout coverage.

**Test suite repair:** 270 tests green; fixed stale references, GdUnit/Godot 4.7 coroutine issues, orphan cleanup.

**Phase 8A — Remove waves; time-based levels:** `LevelDefinition`/`LevelManager` replace `WaveDefinition`/`WaveManager`; single 10-minute survival level (`level_01.tres`) with continuous spawn-rate/cap ramps and per-minute enemy HP/damage scaling; survive → victory screen, death → game over; shop no longer auto-opens (on-demand hook `ShopManager.open_shop()` ready for 8B); shop prices scale per elapsed minute; 282 tests green.

**Phase 8B — On-demand shop and upgrades:** level-ups bank a pending choice (`EventBus.upgrades_pending_changed`) instead of auto-opening; player opens the shop with **`E`** / bottom-right Shop button and banked upgrades with **`Q`** / bottom-left Upgrades button (shows pending count, disabled at 0); both overlays pause and support mouse + keyboard; HUD action bar (`hud_action_bar.gd` + `hud_action_button.gd`) sits beneath modal overlays; 291 tests green.

**Phase 8C — Weapon balance and 6-slot loadout:** all 8 tier-1 weapons tuned to equal single-target DPS (~36, within ±12%) verified by `BalanceCalculator.single_target_dps()` (type-aware: projectile/burst/orbit/melee/boomerang/turret); correct `weapon_type` set on every `.tres`; 6-slot cap confirmed (`WeaponController.MAX_WEAPONS = 6`); shop gains `SELL_WEAPON` offers refunding 50% of purchase price (`ShopManager` tracks per-weapon paid price, starting weapon seeded at base cost), blocked when only one weapon remains; sell cards always affordable with a `+N` refund badge; 303 tests green.

**Phase 9 — UI design system:** introduced `DesignSystem` (`scripts/ui/design_system.gd`) as the single source of truth for the interface — palette, 4px spacing scale, radius/border scales, a modular type scale (base 16, ratio 1.2), elevation presets, rarity tiers, and builders (`stylebox/shadowed/padded/style_label`). Refactored every UI style file to compose tokens instead of hardcoded values, unified level-up/shop upgrade cards onto the parchment language, documented the system in `docs/ui-design-system.md`, and added `test_design_system` + `test_hud_theme`; 322 tests green.
