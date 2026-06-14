# Development progress

Tracks implementation status against [plans.md](plans.md). Update this file at the end of each phase.

**Last updated:** Phase 2C complete

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

## Phase 2B — Enemies, guns, drops ✅

| Task | Status | Notes |
|---|---|---|
| `base_enemy.gd` + 3 archetypes | ✅ Done | Chaser, Tank, Sprinter scenes + `.tres` |
| `WaveDefinition` weighted spawns | ✅ Done | `wave_01.tres` — weights 5/2/3 |
| Shotgun + orbit blade weapons | ✅ Done | Pellet spread + orbiting blades; player has all 3 |
| XP orbs + `DropDefinition` | ✅ Done | Small/large XP + 5% health drop via `LootSpawner` |
| Pistol migrated to data-driven | ✅ Done | Completed in 2A |

---

## Phase 2C — UI polish ✅

| Task | Status | Notes |
|---|---|---|
| HUD listens to EventBus only | ✅ Done | Completed in 2A refactor |
| Floating damage numbers | ✅ Done | `FloatingTextManager` on `damage_dealt` |
| XP bar + level label | ✅ Done | Bottom bar + `XpSystem` tracks orbs |
| Improved HP bar styling | ✅ Done | Smooth tween via `stat_bar.gd` |
| Pickup feedback text | ✅ Done | `+N XP` / `+N HP` floating text on collect |
| Wave timer pulse (<10s) | ✅ Done | Color + scale pulse |
| Tank enemy HP bars | ✅ Done | Thin bar above enemies with 50+ HP |

---

## Phase 2D — XP and progression loop

| Task | Status | Notes |
|---|---|---|
| XP system | ✅ Done | `XpSystem` added in 2C (orbs → bar fill, level-up signal) |
| Level-up picker | ⬜ Not started | 1 of 3 upgrades overlay |
| Upgrade definitions | ⬜ Not started | Damage, speed, HP, etc. |

---

## Phase 2E — Tests and codecheck

| Task | Status | Notes |
|---|---|---|
| GdUnit4 addon | ✅ Done | `addons/gdUnit4` |
| Unit tests (health, wave, spawn, arena) | ✅ Done | `tests/unit/` |
| Integration test (game run state) | ✅ Done | `tests/integration/` |
| `test_xp_system.gd` | ✅ Done | 7 cases |
| Full `codecheck` pipeline | ✅ Done | Lint + format + boot + GdUnit4 tests |
| Pre-commit hook (optional) | ✅ Done | `.githooks/pre-commit` on master via `install-git-hooks` |

---

## Changelog

### Phase 2C

- **Floating damage numbers** float up and fade on `damage_dealt`
- **Pickup feedback** shows `+N XP` / `+N HP` at collect position
- **XP bar** at bottom with level label; fills from orb pickups via `XpSystem`
- **Level-up flash** on XP bar when threshold reached (`level_up` signal)
- **HP bar** smooth tween + color shift at low health
- **Timer pulse** when under 10 seconds remaining
- **Tank HP bars** thin red bar above high-HP enemies
- `pickup_collected` now includes `world_pos` and `value`

### Phase 2B

- **Shotgun:** 5 pellets, 32° spread, short range (data-driven via `WeaponDefinition`)
- **Orbit blade:** 2 rotating blades around player with per-enemy hit cooldown
- **Drops:** Cyan XP orbs (small +5, large +20 from tanks), green health pickups (+15 HP, 5% chance)
- `LootSpawner` listens to `enemy_killed`, spawns drops from `EnemyDefinition.xp_drop`
- `BasePickup` with magnet pull toward player; health pickup heals via `HealthComponent`

### Phase 2E (started)

- Added GdUnit4 test framework and unit/integration tests
- Extracted `SpawnTable` for testable weighted enemy picks
- `WindowSetup` skipped in headless mode for CI/tests

- Fixed phantom contact damage (distance-based overlap check)
- Polished HUD: compact panel, thin HP bar, consistent typography
- Invulnerability reduced to 0.1s
- Window fills usable screen area (windowed); 1920×1080 viewport with camera zoom
- Borderless full-monitor window; pause tree when run ends (death / wave complete)

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
2. Kill enemies — damage numbers pop, XP orbs fill the bottom bar, health pickups show `+15 HP`
3. Watch tanks for overhead HP bars; timer pulses orange under 10s
4. Level up by collecting enough orbs — XP bar flashes
5. Run `.\tools\codecheck.ps1` before handoff (Godot on PATH + optional `pip install gdtoolkit`)
6. Run tests only: `godot --headless --path . -s addons/gdUnit4/bin/GdUnitCmdTool.gd --addons -a tests/`
