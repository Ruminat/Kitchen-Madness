# Kitchen Madness — project context

Handoff doc for new chat sessions. **Kitchen Madness** — top-down arena survivor roguelite (Godot 4). Full history: [progress.md](progress.md). Roadmap: [plans.md](plans.md).

## Current status

**Phase 4E done.** Short early waves (12s → 17s → 22s), denser spawns, weaker swarm pests. Enemies slow for 2s after hitting the player.

**Playable loop:** character select → waves → weapon shop → repeat. Level-ups = stat upgrades; shop = weapon offers only.

**Content:** 9 characters, 8 kitchen weapons, combat VFX, HUD, `2640×1440` arena, following camera, off-camera spawns.

**Next:** Phase 4F — balance metrics and tuning.

**Not in scope:** save/meta, main menu, multiple maps, Steam, audio.

---

## Iteration rule

1. Zero parser/scene errors · **F5** smoke test
2. `.\tools\codecheck.ps1` must pass (gdlint + gdformat + boot + tests)
3. Update [progress.md](progress.md) after a phase/slice
4. Large visual iterations: `.\tools\capture-visuals.ps1` → `visual-tests/screenshots/`

**Godot 4.6+**, `gdtoolkit` on PATH. **Never commit `.vscode/`**.

---

## Architecture (keep these patterns)

| Pattern | Where |
|---|---|
| **EventBus** | `scripts/autoload/event_bus.gd` — gameplay emits, UI listens |
| **VfxManager** | Pooled death bursts + impact sparks |
| **WaveDefinition.resolve_duration** | Wave 4+ adds +5s per wave beyond authored roster |
| **BaseEnemy.apply_contact_slow** | 2s slow on player contact (35% speed) |
| **WaveManager / EnemySpawner** | Timer, weighted spawns, camera-ring spawns |
| **GoldSystem / ShopManager** | Kill gold → weapon shop → `start_next_wave()` |
| **LevelUpManager** | 1-of-3 free stat picks from `UpgradeDefinition` |

**Main scene:** `res://scenes/main/game.tscn`

**Gotchas:** Contact damage = distance check in `player.gd`. UI = `PROCESS_MODE_ALWAYS`. Integration tests: assert after `EventBus` emits — don't `await` timers after pausing the tree.

---

## Controls (mouse OR keyboard — always both)

| Context | Keyboard |
|---|---|
| Move | **WASD or arrows** |
| Character select | W/S or ↑/↓ · 1–9 or Enter |
| Level-up | W/S or ↑/↓ · 1/2/3 or Enter |
| Weapon shop | W/S or ↑/↓ · **1–4** or Enter buy · Enter continue |
| Game over | R or Enter |

---

## Key paths

```
scripts/systems/     wave_manager, enemy_spawner, vfx_manager
resources/waves/     wave_01 (12s) through wave_03 (22s)
resources/enemies/   weaker chaser/sprinter/tank pests
tests/               unit + integration (GdUnit4)
tools/codecheck.ps1
```

---

## Dev workflow

```powershell
.\tools\codecheck.ps1
godot --headless --path . -s addons/gdUnit4/bin/GdUnitCmdTool.gd -a tests/ --ignoreHeadlessMode
```

---

## Read first in a new chat

1. [progress.md](progress.md) · 2. [plans.md](plans.md) · 3. `scripts/game.gd` · 4. `event_bus.gd` · 5. `wave_definition.gd`
