# Kitchen Madness — project context

**Kitchen Madness** — top-down arena survivor roguelite (Godot 4). History: [progress.md](progress.md). Roadmap: [plans.md](plans.md).

## Current status

**Phase 7A done** · **Phase 7B done** — world-space damage numbers (labels live in game world, not UI canvas).

**Loop:** character select → swarm waves → weapon shop → repeat. Level-ups = stat/crit upgrades. SFX + run stats to `ignored/stats/`.

**Content:** 9 characters · 8 weapons (2 melee) · 5 enemy types · `2640×1440` arena · crit · VFX · pooled world-space damage numbers.

**Next:** Phase 7C (combat balance tuning from run stats).

---

## Iteration rule

1. No parser errors · **F5** smoke test
2. `.\tools\codecheck.ps1` (gdlint + gdformat + boot + tests)
3. Update [progress.md](progress.md) after a phase/slice
4. Never commit `.vscode/`

**Godot 4.6+** · `gdtoolkit` on PATH.

---

## Architecture (patterns to keep)

| Pattern | Where |
|---|---|
| **EventBus** | `scripts/autoload/event_bus.gd` |
| **WaveDefinition** | Swarm fields + `resolve_duration()` (+5s per wave after roster) + `resolve_density_multiplier()` (+20% enemies/wave) |
| **EnemySpawner** | Weighted swarms, off-camera bands, `set_camera_focus()` for clamped spawn ring |
| **Arena.get_global_bounds()** | Player, camera, spawner all use world-space bounds |
| **CollisionLayers** | Player mask = wall+enemy; enemy mask = wall+enemy+player; `MOTION_MODE_FLOATING` |
| **BaseEnemy** | Contact slow · knockback · collision radius from `EnemyDefinition` |
| **MeleeWeapon** | Arc hits · crit · knockback via `.tres` fields |
| **GoldSystem / ShopManager** | Between-wave weapon shop |
| **LevelUpManager** | 1-of-3 stat upgrades only |
| **FloatingTextManager** | UI `Control` on `CanvasLayer`; world anchor + per-frame canvas sync (true 36px screen text) |
| **Crit** | Player → `WeaponController.sync_all_crit_stats()` → weapons |

**Main scene:** `res://scenes/main/game.tscn`

**Gotchas:** Contact damage = distance check in `player.gd`. UI = `PROCESS_MODE_ALWAYS`. Integration tests: assert after `EventBus` emits — don't `await` timers after pausing the tree.

---

## Controls (mouse OR keyboard)

| Context | Keyboard |
|---|---|
| Move | WASD / arrows |
| Character select | W/S · 1–9 · Enter |
| Level-up | W/S · 1/2/3 · Enter |
| Shop | W/S · **1–4** buy · Enter continue |
| Game over | R / Enter |

---

## Key paths

```
scripts/systems/     enemy_spawner.gd, wave_manager.gd
scripts/enemies/     base_enemy.gd, moth_enemy.gd
scripts/data/        wave_definition.gd, collision_layers.gd
resources/waves/     wave_01–03 (swarm-tuned, 3× density)
resources/enemies/   chaser, sprinter, tank, ant, moth
tests/               unit + integration (GdUnit4)
tools/codecheck.ps1
```

---

## Dev workflow

```powershell
.\tools\codecheck.ps1
godot --headless --path . -s addons/gdUnit4/bin/GdUnitCmdTool.gd -a tests/ --ignoreHeadlessMode
```

**New chat:** [progress.md](progress.md) → [plans.md](plans.md) → `scripts/game.gd` → `event_bus.gd` → `wave_definition.gd`
