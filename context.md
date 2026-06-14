# Project context

Handoff doc for new chat sessions. See [progress.md](progress.md) for task-level status and [plans.md](plans.md) for the full roadmap.

## Current status (as of last session)

**Phase 2A complete.** **Phase 2B complete.** **Phase 2C complete.** **Phase 2D next** (level-up picker). **Phase 2E mostly done** (GdUnit4 + codecheck + pre-commit hook).

Playable loop: 30s wave, 3 enemy types, pistol + shotgun + orbit blades, XP orbs + health drops, floating damage/pickup text, XP bar with level-ups, compact HUD, win/lose overlay. Game **pauses** on death or wave complete (only R / Restart works).

Latest commit on `master`: `c873b19` — tests, git hooks, polish fixes. Not pushed.

---

## Iteration rule

**Make sure there are no errors before finishing an iteration.**

1. Fix all parser/script/scene errors
2. Press **F5** — game starts, movement/shooting/enemies work, end screens freeze gameplay
3. Run `./tools/codecheck.ps1` (Windows) or `./tools/codecheck.sh` (macOS/Linux) — must pass
4. Update [progress.md](progress.md) if you finish a phase or meaningful slice

**Godot 4.6+** required. **Godot must be on PATH** (`godot` — user has 4.6.3). Optional: `pip install gdtoolkit` for lint/format in codecheck.

---

## Game overview

Brotato-style top-down arena survivor roguelite in **Godot 4** (GDScript).

- **Done:** Arena, player, weighted enemy spawns, pistol/shotgun/orbit blades, wave timer, HUD + XP bar, floating combat text, win/lose + pause, XP orbs + health drops
- **Next (plans):** Level-up picker (1 of 3 upgrades)
- **Long-term:** Shop, multiple maps, Steam

## Main scene

`res://scenes/main/game.tscn`

---

## Architecture (important patterns)

| Pattern | Where | Notes |
|---|---|---|
| **EventBus** autoload | `scripts/autoload/event_bus.gd` | Gameplay emits; UI listens. No direct `ui.update_*()` from gameplay. |
| **HealthComponent** | player + enemies | Shared HP, i-frames. Player i-frames: **0.1s**. |
| **WaveManager / EnemySpawner** | `scripts/systems/` | Wave timer + weighted spawns from `WaveDefinition`. |
| **WeaponController** | on player | Loads weapons from `WeaponDefinition` `.tres`. |
| **SpawnTable** | `scripts/systems/spawn_table.gd` | Weighted enemy pick (unit-tested). |
| **XpSystem** | `scripts/systems/xp_system.gd` | Listens to `pickup_collected`; emits `xp_changed` / `level_up`. |
| **FloatingTextManager** | `scripts/ui/floating_text_manager.gd` | Damage + pickup feedback via EventBus. |
| **Resource definitions** | `scripts/data/*.gd` + `resources/` | Add content via `.tres`, not by editing spawner logic. |

**Run end:** `game.gd` sets `get_tree().paused = true`. UI uses `PROCESS_MODE_ALWAYS` so Restart/R still work. Do **not** set `PROCESS_MODE_WHEN_PAUSED` on the Game root (breaks normal play).

**Contact damage:** Distance-based overlap in `player.gd` (not Area2D `body_entered` — caused phantom hits).

**Window:** `WindowSetup` autoload — borderless full monitor on boot. Skipped in headless (tests/CI).

**Camera:** `game.gd` zooms to fit arena on viewport resize.

---

## Autoloads

| Name | Script |
|---|---|
| EventBus | `scripts/autoload/event_bus.gd` |
| WindowSetup | `scripts/autoload/window_setup.gd` |

---

## Project layout

```
scenes/
  main/game.tscn
  arena/arena.tscn
  player/player.tscn
  enemy/enemy.tscn, tank_enemy.tscn, sprinter_enemy.tscn
  projectiles/projectile.tscn
  ui/game_ui.tscn
scripts/
  autoload/          event_bus.gd, window_setup.gd
  components/        health_component.gd, arena_clamp.gd, enemy_health_bar.gd
  data/              enemy/weapon/drop/wave definitions
  enemies/           base_enemy.gd, chaser_enemy.gd, sprinter_enemy.gd
  pickups/           base_pickup.gd, health_pickup.gd
  systems/           wave_manager.gd, enemy_spawner.gd, spawn_table.gd, loot_spawner.gd, xp_system.gd
  ui/                floating_text.gd, floating_text_manager.gd, stat_bar.gd
  weapons/           weapon_controller.gd, base_weapon.gd, projectile_weapon.gd, orbit_weapon.gd
  game.gd, player.gd, projectile.gd, game_ui.gd, circle_visual.gd, arena.gd
resources/
  enemies/           chaser, tank, sprinter + spawn entries
  weapons/           pistol.tres, shotgun.tres, orbit_blade.tres
  drops/             xp_orb_small.tres, xp_orb_large.tres, health_pickup.tres
  waves/             wave_01.tres
tests/
  unit/              health, wave, spawn, arena, xp
  integration/       game boot + pause-on-end
addons/gdUnit4/      test framework
tools/
  codecheck.ps1, codecheck.sh
  install-git-hooks.ps1, install-git-hooks.sh
.githooks/pre-commit   runs codecheck on master only
docs/                  adding-visuals guide
progress.md            task checklist
plans.md               full roadmap
```

---

## Controls

| Input | Action |
|---|---|
| WASD / Arrow keys | Move |
| R or Restart button | Restart after Game Over or Wave Complete |

---

## Dev workflow

```powershell
# Full check (lint if gdtoolkit installed + headless boot + 33 tests)
.\tools\codecheck.ps1

# Tests only
godot --headless --path . -s --remote-debug tcp://127.0.0.1:0 res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a tests/ --ignoreHeadlessMode

# Install git hook (once per clone) — runs codecheck before commits on master
.\tools\install-git-hooks.ps1
```

**Tests:** 33 cases, 9 suites. Integration tests must not `await` timers after pausing the tree — assert synchronously after `EventBus` emits.

**Strict typing:** Godot 4.6 + GdUnit4 treat inference warnings as errors. Use explicit types on `auto_free()` results and typed arrays.

---

## Recommended next work (from plans.md)

1. **Phase 2D:** Level-up picker overlay (1 of 3 upgrades), upgrade definitions

Vertical slices: each step playable + `codecheck` green + update `progress.md`.

---

## Not in scope yet

Shop, multiple maps, save/meta, main menu, Steam, sound/music.

---

## Key files to read first in a new chat

1. [plans.md](plans.md) — roadmap
2. [progress.md](progress.md) — what's done
3. `scripts/game.gd` — run lifecycle, pause on end
4. `scripts/autoload/event_bus.gd` — signal contracts
5. `resources/waves/wave_01.tres` — current wave/enemy weights
