# Kitchen Madness — project context

**Kitchen Madness** — top-down arena survivor roguelite (Godot 4). Full history: [progress.md](progress.md). Roadmap: [plans.md](plans.md).

## Current status

**Phase 5D done.** Projectile visuals fixed (weapons no longer shoot themselves as sprites). AudioManager with 12 synthesized SFX (70% volume), pooled players, EventBus integration.

**Playable loop:** character select → waves (3x enemies) → weapon shop → repeat. Level-ups = stat + crit upgrades. SFX for combat, pickups, level-up, wave complete.

**Content:** 9 characters, 8 kitchen weapons, VFX, HUD, `2640×1440` arena, camera follow, crit system, pooled damage numbers, basic audio.

**Next:** Phase 5E — Statistics persistence, Phase 5F — Melee weapons, Phase 6A — Enemy variety & swarm spawning, Phase 6B — Shop UI overhaul.

**Not in scope:** save/meta, main menu, multiple maps, Steam.

---

## Iteration rule

1. Zero parser/scene errors · **F5** smoke test
2. `\.\tools\codecheck.ps1` must pass (gdlint + gdformat + boot + tests)
3. Update [progress.md](progress.md) after a phase/slice
4. Large visual iterations: `.\tools\capture-visuals.ps1` → `visual-tests/screenshots/`

**Godot 4.6+**, `gdtoolkit` on PATH. **Never commit `.vscode/`**.

---

## Architecture (keep these patterns)

| Pattern | Where |
|---|---|
| **EventBus** | `scripts/autoload/event_bus.gd` — gameplay emits, UI listens |
| **AudioManager** | `scripts/autoload/audio_manager.gd` — pooled SFX players, synthesized placeholders |
| **VfxManager** | Pooled death bursts + impact sparks |
| **FloatingTextManager** | Pooled damage number labels (32 pre-allocated) |
| **WaveDefinition.resolve_duration** | Wave 4+ adds +5s per wave beyond authored roster |
| **BaseEnemy.apply_contact_slow** | 2s slow on player contact (35% speed) |
| **WaveManager / EnemySpawner** | Timer, weighted spawns, camera-ring spawns |
| **GoldSystem / ShopManager** | Kill gold → weapon shop → `start_next_wave()` |
| **LevelUpManager** | 1-of-3 free stat picks from `UpgradeDefinition` |
| **Crit system** | `Player` → `WeaponController.sync_all_crit_stats()` → weapons → projectiles |

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
scripts/autoload/    event_bus.gd, audio_manager.gd
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
