# Kitchen Madness — project context

**Kitchen Madness** — top-down arena survivor roguelite (Godot 4). History: [progress.md](progress.md). Roadmap: [plans.md](plans.md).

## Current status

**Latest: Phase 9 — UI Design System** — token-driven UI. `DesignSystem` (`scripts/ui/design_system.gd`) is the single source of truth for palette, spacing (4px base), radii, borders, a modular type scale, and elevation; all UI style files consume it (no hardcoded colors/sizes). Docs: [docs/ui-design-system.md](docs/ui-design-system.md).

**Prior: Phase 8C** — all tier-1 weapons at equal DPS (~36), 6 weapon slots, shop buy/sell/upgrade economy.

**Loop:** character select → survive the 10-minute level while pressure ramps → level-ups bank upgrade picks (open on demand) → shop to buy/upgrade/sell weapons anytime. Survive → win, die → lose. SFX + run stats to `ignored/stats/`.

**Content:** 9 characters · 8 weapons (2 melee), DPS-balanced tier-1 · 5 enemy types · `2640×1440` arena · crit · VFX · pooled world-space damage numbers · idle squash bob · settings overlay.

**Next: open** — roadmap 8A–8C + UI design system done; pick from the optimizations backlog or add a new phase in [plans.md](plans.md).

---

## Iteration rule

1. No parser errors · **F5** smoke test
2. `./tools/codecheck.sh` (gdlint + gdformat + boot + tests)
3. Update [progress.md](progress.md) after a phase/slice
4. Never commit `.vscode/`

**Godot 4.7** · `gdtoolkit` on PATH (mac: `~/Library/Python/3.12/bin`, Godot: `~/Downloads/Godot.app/Contents/MacOS`).

---

## Architecture (patterns to keep)

| Pattern | Where |
|---|---|
| **DesignSystem (UI tokens)** | `scripts/ui/design_system.gd` (`DS`) — palette, `SPACE_*` (4px base), `RADIUS_*`, `BORDER_*`, `FONT_SIZE_*` (modular 1.2), `ELEVATION`, `Rarity`; builders `stylebox/shadowed/padded/style_label`. `HudTheme` composes tokens; every UI file consumes them, no raw literals. Docs: `docs/ui-design-system.md` |
| **EventBus** | `scripts/autoload/event_bus.gd` — `level_time_changed(elapsed, remaining)`, `level_completed`, metrics signals |
| **LevelDefinition** | `scripts/data/level_definition.gd` — duration, spawn curve (`spawn_multiplier_start/end/curve`), cap ramp (`max_enemies_start/end`), swarm fields; statics `resolve_enemy_health/contact_damage(base, elapsed_seconds)` = +25%/+15% per minute |
| **LevelManager** | Counts elapsed up to `duration`; emits `level_time_changed`; on timeout emits `level_completed` (= victory) |
| **EnemySpawner** | Weighted swarms, off-camera bands, `set_camera_focus()`; interval = `spawn_interval / multiplier(progress)`; alive cap lerps with progress; enemies get `configure_for_time(def, elapsed)` |
| **Arena.get_global_bounds()** | Player, camera, spawner all use world-space bounds |
| **CollisionLayers** | Player mask = wall+enemy; enemy mask = wall+enemy+player; `MOTION_MODE_FLOATING` |
| **BaseEnemy** | Contact slow · knockback · collision radius from `EnemyDefinition` · time-scaled HP/damage |
| **MeleeWeapon** | Arc hits · crit · knockback via `.tres` fields |
| **GoldSystem / ShopManager** | `open_shop()` on-demand (`ui.shop_open_requested`); prices +15%/elapsed minute via `scaled_cost_for_time()`; `SELL_WEAPON` offers refund 50% of tracked purchase price (`_weapon_purchase_price`), blocked at last gun |
| **Weapon DPS parity** | `BalanceCalculator.single_target_dps(weapon)` is type-aware (projectile/burst = dmg·pellets/rate, orbit = dmg·pellets·orbit_speed/τ, melee = dmg/rate, boomerang = 2·dmg/rate, turret = dmg·(dur/tfr)/rate); all tier-1 weapons ≈ `BASE_DPS_TARGET` (36) ±12%. Each `.tres` must set correct `weapon_type` |
| **LevelUpManager** | Level-ups bank pending picks (`EventBus.upgrades_pending_changed`); `open_upgrades()` (via `ui.upgrades_open_requested`) shows 1-of-3 stat upgrades; chains remaining pending before unpausing |
| **HudActionBar** | `scripts/ui/hud_action_bar.gd` + `hud_action_button.gd` — bottom-corner Upgrades/Shop buttons; built by `game_ui` beneath the modal overlays; Upgrades badge = pending count |
| **FloatingTextManager** | UI `Control` on `CanvasLayer`; world anchor + per-frame canvas sync |
| **Crit** | Player → `WeaponController.sync_all_crit_stats()` → weapons |
| **AudioManager** | Music-forward mix; `play_sfx_at(name, world_pos)` distance falloff; "victory" jingle on `level_completed` |
| **IdleSquash** | `scripts/components/idle_squash.gd` on `Visual` Node2D |

**Main scene:** `res://scenes/main/game.tscn` (node `LevelManager`, export `level_definition = level_01.tres`)

**Gotchas:** Contact damage = distance check in `player.gd`. UI = `PROCESS_MODE_ALWAYS`. Integration tests: assert after `EventBus` emits — don't `await` timers after pausing the tree. After renaming/adding `class_name` scripts, run `godot --headless --import` once to refresh the class cache. Metrics still use "wave" naming internally (`start_wave(1, …)` = the whole level).

---

## Controls (mouse OR keyboard)

| Context | Keyboard |
|---|---|
| Move | WASD / arrows |
| Character select | W/S · 1–9 · Enter |
| Open upgrades / shop | **Q** upgrades · **E** shop (or HUD buttons) |
| Level-up | W/S · 1/2/3 · Enter |
| Shop | W/S · 1–5 buy · R reroll · Enter continue |
| Game over / victory | R / Enter |
| Settings | Esc |

---

## Key paths

```
scripts/systems/     enemy_spawner.gd, level_manager.gd, shop_manager.gd
scripts/enemies/     base_enemy.gd, moth_enemy.gd
scripts/data/        level_definition.gd, collision_layers.gd
resources/levels/    level_01.tres (10 min, full enemy roster, 1×→6× spawn ramp)
resources/enemies/   chaser, sprinter, tank, ant, moth
tests/               unit + integration (GdUnit4) — 303 tests
tools/codecheck.sh   (codecheck.ps1 on Windows)
```

---

## Dev workflow

```bash
./tools/codecheck.sh
godot --headless --path . -s addons/gdUnit4/bin/GdUnitCmdTool.gd -a tests/ --ignoreHeadlessMode
```

**New chat:** [progress.md](progress.md) → [plans.md](plans.md) → `scripts/game.gd` → `event_bus.gd` → `level_definition.gd`
