# Kitchen Madness — project context

Handoff doc for new chat sessions. **Kitchen Madness** — top-down arena survivor roguelite (Godot 4). Details: [progress.md](progress.md), roadmap: [plans.md](plans.md).

## Current status

**Phase 3A done** — gold on kill, between-wave shop, multi-wave loop, 8-stat upgrades (HP/armor/damage/attack speed/move speed/luck/pickup range/XP), elite cap (max 2 tanks alive), dual mouse+keyboard UI.

**Visual pass (ongoing):** Sprites for player (Sprout), enemies, arena floor. Projectiles/pickups still circle placeholders. Player roster + grid splitter in `tools/` — see `docs/sprite-grid-splitter.md`.

**Loop:** 60s waves → shop → next wave. Pauses on level-up, shop, death. Spawns ramp 2×–8×; XP thresholds tuned slow.

---

## Iteration rule

1. Zero parser/scene errors · **F5** smoke test
2. `.\tools\codecheck.ps1` must pass
3. Update [progress.md](progress.md) after a phase/slice

**Godot 4.6+** on PATH. Optional: `pip install gdtoolkit`. **Never commit `.vscode/`** — local editor settings only (see `.gitignore`).

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
tools/codecheck.ps1
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

1. Sprite placeholders (projectiles, pickups) + transparent PNG exports
2. Per-wave difficulty / multiple `WaveDefinition` resources

**Not in scope:** save/meta, main menu, multiple maps, Steam, audio.

---

## Read first in a new chat

1. [progress.md](progress.md) · 2. [plans.md](plans.md) · 3. `scripts/game.gd` · 4. `event_bus.gd` · 5. `wave_01.tres`
