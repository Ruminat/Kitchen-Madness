# Kitchen Madness — project context

**Kitchen Madness** — top-down arena survivor roguelite (Godot 4). History: [progress.md](progress.md). Roadmap: [plans.md](plans.md).

## Current status

**Latest: Phase 8A** — waves removed; level 1 is a single **10-minute survival run** (survive → win, die → lose).

**Loop:** character select → survive the level timer while pressure ramps → level-ups grant stat/crit upgrades. SFX + run stats to `ignored/stats/`.

**Content:** 9 characters · 8 weapons (2 melee) · 5 enemy types · `2640×1440` arena · crit · VFX · pooled world-space damage numbers · idle squash bob · settings overlay.

**Next: Phase 8B** — on-demand shop (`E`) and banked upgrades (`Q`). `ShopManager.open_shop()` already exists but nothing calls it yet — the shop is unreachable in-game until 8B.

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
| **EventBus** | `scripts/autoload/event_bus.gd` — `level_time_changed(elapsed, remaining)`, `level_completed`, metrics signals |
| **LevelDefinition** | `scripts/data/level_definition.gd` — duration, spawn curve (`spawn_multiplier_start/end/curve`), cap ramp (`max_enemies_start/end`), swarm fields; statics `resolve_enemy_health/contact_damage(base, elapsed_seconds)` = +25%/+15% per minute |
| **LevelManager** | Counts elapsed up to `duration`; emits `level_time_changed`; on timeout emits `level_completed` (= victory) |
| **EnemySpawner** | Weighted swarms, off-camera bands, `set_camera_focus()`; interval = `spawn_interval / multiplier(progress)`; alive cap lerps with progress; enemies get `configure_for_time(def, elapsed)` |
| **Arena.get_global_bounds()** | Player, camera, spawner all use world-space bounds |
| **CollisionLayers** | Player mask = wall+enemy; enemy mask = wall+enemy+player; `MOTION_MODE_FLOATING` |
| **BaseEnemy** | Contact slow · knockback · collision radius from `EnemyDefinition` · time-scaled HP/damage |
| **MeleeWeapon** | Arc hits · crit · knockback via `.tres` fields |
| **GoldSystem / ShopManager** | `open_shop()` is on-demand only (no auto-open); prices +15%/elapsed minute via `scaled_cost_for_time()` |
| **LevelUpManager** | 1-of-3 stat upgrades only |
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
| Level-up | W/S · 1/2/3 · Enter |
| Shop (unreachable until 8B) | W/S · 1–5 buy · R reroll · Enter continue |
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
tests/               unit + integration (GdUnit4) — 282 tests
tools/codecheck.sh   (codecheck.ps1 on Windows)
```

---

## Dev workflow

```bash
./tools/codecheck.sh
godot --headless --path . -s addons/gdUnit4/bin/GdUnitCmdTool.gd -a tests/ --ignoreHeadlessMode
```

**New chat:** [progress.md](progress.md) → [plans.md](plans.md) → `scripts/game.gd` → `event_bus.gd` → `level_definition.gd`
