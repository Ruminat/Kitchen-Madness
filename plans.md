# Kitchen Madness - development plan

Roadmap for the **Kitchen Madness**, a top-down roguelite arena survivor in Godot 4.

See also: [context.md](context.md) for current project state and iteration rules, [progress.md](progress.md) for task status, and [game-setting.md](game-setting.md) for theme and content direction.

---

## North star

**Data-driven content, thin scenes, testable logic, readable chaos.**

Designers should add characters, enemies, weapons, drops, levels, and upgrades through `.tres` resources and focused scenes, not by hardcoding individual content into gameplay systems.

Every player-facing action must support both mouse and keyboard. WASD and arrow keys are always interchangeable for movement and menus.

---

## Active roadmap

### Phase 8C — Weapon balance and 6-slot loadout

**Goal:** Equal base weapon DPS, six weapon slots, and full buy/sell/upgrade shop economy.

| Task | Details |
|---|---|
| Base DPS parity | Tune all weapons so **basic (tier-1) versions deal equal DPS** — adjust damage, fire rate, projectile count, and melee cadence in `.tres` |
| Six weapon slots | Expand loadout from current cap to **6 simultaneous weapons** |
| Shop upgrades | Player can buy **weapon tier upgrades** for owned guns in the shop (existing or extended offer types) |
| Sell weapons | Player can sell owned weapons for **50% of purchase price** |
| Last-gun rule | **Cannot sell** the last weapon remaining in the loadout |
| Tests | DPS parity checks via `BalanceCalculator`; sell price; sell blocked at 1 weapon; 6-slot equip limits |

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
