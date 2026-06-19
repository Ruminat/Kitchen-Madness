# Kitchen Madness — project context

Handoff doc for new chat sessions. **Kitchen Madness** — top-down arena survivor roguelite (Godot 4). Details: [progress.md](progress.md), roadmap: [plans.md](plans.md).

## Current status

**Phase 4C done** — between-wave shop is weapon-only (add weapon, +damage, +attack speed, +pellet upgrades). Stat upgrades remain level-up rewards only.

**Phase 4B done** — generic pistol/shotgun/orbit blade retired; 8 kitchen weapons via `.tres` + `WeaponRoster`.

**Visual pass:** Sprites for player (Chef default), enemies, arena floor, projectiles, XP orbs, and health pickups. 9-player roster from `assets/characters/Players.png` via grid splitter — see `docs/sprite-grid-splitter.md`, `docs/player-roster.md`.

**Loop:** 60s waves → shop → next wave. Pauses on level-up, shop, death. Spawns ramp 2×–8×; XP thresholds tuned slow.
**Map/camera:** Arena bounds are `2640x1440`; camera view targets old `880x480` play area and follows the player.

---

## Iteration rule

1. Zero parser/scene errors · **F5** smoke test
2. `.\tools\codecheck.ps1` must pass (gdlint + gdformat + boot + tests)
3. Update [progress.md](progress.md) after a phase/slice
4. For large visual/gameplay iterations, run `.\tools\capture-visuals.ps1` and inspect `visual-tests/screenshots/`

**Godot 4.6+** and `gdtoolkit` on PATH. Lint/format config: `.gdlintrc`, `.gdformatrc`. **Never commit `.vscode/`**.

---

## Architecture (keep these patterns)

| Pattern | Where |
|---|---|
| **EventBus** | `scripts/autoload/event_bus.gd` — gameplay emits, UI listens |
| **HealthComponent** | Shared HP + armor + i-frames (player: 0.1s) |
| **WaveManager / EnemySpawner** | Timer, weighted spawns, elite cap |
| **GoldSystem / ShopManager** | Kill gold → shop → `start_next_wave()` |
| **LevelUpManager** | 1-of-3 free upgrades from `UpgradeDefinition` |
| **Resource `.tres`** | Enemies, weapons, drops, waves, upgrades — add content without editing spawners |

**Main scene:** `res://scenes/main/game.tscn`

**Gotchas:** Contact damage = distance check in `player.gd` (not Area2D). UI = `PROCESS_MODE_ALWAYS`; don't set `WHEN_PAUSED` on Game root. `WindowSetup` skipped headless.

---

## Controls (mouse OR keyboard — always both)

| Context | Keyboard |
|---|---|
| Move | **WASD or arrows** (input actions, not raw keycodes) |
| Level-up | W/S or ↑/↓ · 1/2/3 or Enter |
| Shop | W/S or ↑/↓ · 1–8 or Enter buy · Enter continue |
| Game over | R or Enter |

`ui_up/down` also bind WASD in `project.godot`. Upgrade cards: emoji + accent via `scripts/ui/upgrade_display.gd`.

**Luck (balanced):** +1% gold/XP per point, +0.15% health drop chance (cap 22%), slightly better level-up rolls.

---

## Key paths

```
scripts/systems/   wave_manager, enemy_spawner, gold_system, shop_manager, level_up_manager, xp_system
scripts/ui/        game_ui.gd, upgrade_display.gd, floating_text_manager.gd
resources/upgrades/  max_health, armor, damage_boost, attack_speed, speed_boost, luck, pickup_range, xp_gain
resources/waves/   wave_01.tres
tests/             unit + integration (GdUnit4)
tools/codecheck.ps1 / .sh
```

Sprites / hurtboxes: [hitbox.md](hitbox.md)

---

## Dev workflow

```powershell
.\tools\codecheck.ps1
godot --headless --path . -s addons/gdUnit4/bin/GdUnitCmdTool.gd -a tests/ --ignoreHeadlessMode
```

Integration tests: assert synchronously after `EventBus` emits — don't `await` timers after pausing the tree.

---

## Next work

Phase 4D — VFX pass (enemy death bursts, projectile trails, weapon impact effects). Playtest weapon shop pricing and offer variety.

**Not in scope:** save/meta, main menu, multiple maps, Steam, audio.

---

## Read first in a new chat

1. [progress.md](progress.md) · 2. [plans.md](plans.md) · 3. `scripts/game.gd` · 4. `event_bus.gd` · 5. `wave_01.tres`
