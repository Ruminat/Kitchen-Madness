# Kitchen Madness — project context

Handoff doc for new chat sessions. **Kitchen Madness** — top-down arena survivor roguelite (Godot 4). Full history: [progress.md](progress.md). Roadmap: [plans.md](plans.md).

## Current status

**Phase 4C done.** Playable loop: character select → waves → **weapon shop** → repeat. Level-ups give **stat upgrades only**; shop gives **weapon offers only** (add weapon, +damage, +attack speed, +pellet).

**Content in place:**
- 9 playable characters (`CharacterDefinition` + pre-run picker; headless auto-selects Chef)
- 8 kitchen weapons (`WeaponRoster`, `.tres` in `resources/weapons/`)
- Enemies, XP/gold, level-up, HUD, larger arena (`2640×1440`), following camera, off-camera spawns

**Next:** Phase 4D — VFX pass (death bursts, projectile trails, impacts).

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
| **HealthComponent** | Shared HP + armor + i-frames (player: 0.1s) |
| **WaveManager / EnemySpawner** | Timer, weighted spawns, camera-ring spawns |
| **GoldSystem / ShopManager** | Kill gold → dynamic `WeaponShopOffer` shop → `start_next_wave()` |
| **LevelUpManager** | 1-of-3 free stat picks from `UpgradeDefinition` (not shop) |
| **WeaponController** | Starting + extra weapons; per-weapon upgrade APIs |
| **Resource `.tres`** | Characters, enemies, weapons, drops, waves, upgrades |

**Main scene:** `res://scenes/main/game.tscn`

**Gotchas:** Contact damage = distance check in `player.gd`. UI = `PROCESS_MODE_ALWAYS`. `WindowSetup` skipped headless. Integration tests: assert after `EventBus` emits — don't `await` timers after pausing the tree.

---

## Controls (mouse OR keyboard — always both)

| Context | Keyboard |
|---|---|
| Move | **WASD or arrows** |
| Character select | W/S or ↑/↓ · 1–9 or Enter |
| Level-up | W/S or ↑/↓ · 1/2/3 or Enter |
| Weapon shop | W/S or ↑/↓ · **1–4** or Enter buy · Enter continue |
| Game over | R or Enter |

Level-up cards: `scripts/ui/upgrade_display.gd`. Shop cards: `scripts/ui/shop_display.gd`.

**Luck:** +1% gold/XP per point, +0.15% health drop (cap 22%), slightly better level-up rolls.

---

## Key paths

```
scripts/systems/     wave_manager, enemy_spawner, gold_system, shop_manager, level_up_manager
scripts/data/        character_definition, weapon_definition, weapon_roster, weapon_shop_offer
scripts/weapons/     weapon_controller, projectile_weapon, burst/boomerang/turret weapons
resources/characters/  9 roster .tres
resources/weapons/     8 kitchen weapon .tres
resources/upgrades/    stat upgrades (level-up pool only)
tests/                 unit + integration (GdUnit4)
tools/codecheck.ps1
```

Sprites / hurtboxes: [hitbox.md](hitbox.md) · Player grid: [docs/player-roster.md](docs/player-roster.md)

---

## Dev workflow

```powershell
.\tools\codecheck.ps1
godot --headless --path . -s addons/gdUnit4/bin/GdUnitCmdTool.gd -a tests/ --ignoreHeadlessMode
```

---

## Read first in a new chat

1. [progress.md](progress.md) · 2. [plans.md](plans.md) · 3. `scripts/game.gd` · 4. `event_bus.gd` · 5. `shop_manager.gd`
