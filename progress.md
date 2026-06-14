# Development progress

Tracks implementation status against [plans.md](plans.md). Update this file at the end of each phase.

**Last updated:** Phase 2B started (enemies)

---

## Phase 2A — Foundation refactor ✅

**Goal:** Structure that supports many enemies/guns without rewriting `game.gd` every time. Phase 1 gameplay unchanged.

| Task | Status | Notes |
|---|---|---|
| EventBus autoload | ✅ Done | `scripts/autoload/event_bus.gd` |
| HealthComponent | ✅ Done | Player + all enemies |
| Arena scene | ✅ Done | `scenes/arena/arena.tscn` with `get_bounds()` |
| Split `game.gd` | ✅ Done | `WaveManager` + `EnemySpawner` |
| WeaponController | ✅ Done | Pistol from `WeaponDefinition` |
| Resource types | ✅ Done | Enemy/Weapon/Drop/Wave + starter `.tres` |
| `tools/codecheck.ps1` | ✅ Done | Lint/format/boot/tests (skips if tools missing) |

**Definition of done:** Phase 1 gameplay works; no visible behavior change; `codecheck` passes.

---

## Phase 2B — Enemies, guns, drops 🔄

| Task | Status | Notes |
|---|---|---|
| `base_enemy.gd` + 3 archetypes | ✅ Done | Chaser, Tank, Sprinter scenes + `.tres` |
| `WaveDefinition` weighted spawns | ✅ Done | `wave_01.tres` — weights 5/2/3 |
| Shotgun + orbit blade weapons | ⬜ Not started | |
| XP orbs + `DropDefinition` | ⬜ Not started | |
| Pistol migrated to data-driven | ✅ Done | Completed in 2A |

---

## Phase 2C — UI polish

| Task | Status | Notes |
|---|---|---|
| HUD listens to EventBus only | ✅ Done | Completed in 2A refactor |
| Floating damage numbers | ⬜ Not started | `damage_dealt` signal ready |
| XP bar + level label | ⬜ Not started | |
| Improved HP bar styling | ⬜ Not started | |
| Pickup feedback text | ⬜ Not started | |

---

## Phase 2D — XP and progression loop

| Task | Status | Notes |
|---|---|---|
| XP system | ⬜ Not started | Orbs → bar fill |
| Level-up picker | ⬜ Not started | 1 of 3 upgrades overlay |
| Upgrade definitions | ⬜ Not started | Damage, speed, HP, etc. |

---

## Phase 2E — Tests and codecheck

| Task | Status | Notes |
|---|---|---|
| GdUnit4 or GUT addon | ⬜ Not started | |
| Unit tests (wave, spawn, XP, health) | ⬜ Not started | |
| Integration test (game boot) | ⬜ Not started | |
| Full `codecheck` pipeline | 🔄 Partial | Smoke script exists; needs Godot + gdtoolkit on PATH |
| Pre-commit hook (optional) | ⬜ Not started | |

---

## Changelog

### Phase 2B (in progress)

- Added 3 enemy archetypes: Chaser (red), Tank (dark red, slow/tanky), Sprinter (orange, zigzag)
- `wave_01.tres` spawns weighted mix of all three types
- Per-enemy contact damage (Tank hits harder)

### Phase 2A

- Added `progress.md`, EventBus, HealthComponent, Arena scene
- Split `game.gd` into WaveManager + EnemySpawner
- WeaponController + data-driven pistol
- Resource definition scripts and starter `.tres` files
- UI wired through EventBus (no direct gameplay → UI calls)
- `tools/codecheck.ps1` / `codecheck.sh`

## How to try it

1. Open project in Godot 4.6+ and press **F5**
2. Survive the 30-second wave — enemies now include red Chasers, large dark-red Tanks, and fast orange Sprinters
3. Run `.\tools\codecheck.ps1` before handoff (install `gdtoolkit` + add Godot to PATH for full checks)
