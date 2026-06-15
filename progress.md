# Kitchen Madness — development progress

Tracks implementation status against [plans.md](plans.md). Update this file at the end of each phase.

**Last updated:** gdtoolkit lint/format config

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

## Phase 2D — XP and progression loop ✅

| Task | Status | Notes |
|---|---|---|
| XP system | ✅ Done | `XpSystem` added in 2C (orbs → bar fill, level-up signal) |
| Level-up picker | ✅ Done | Pauses after level-up, shows 1 of 3 upgrade choices |
| Upgrade definitions | ✅ Done | Damage, speed, max HP, orbit blade resources |

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

## Phase 3A — Gold and between-wave shop ✅

| Task | Status | Notes |
|---|---|---|
| Gold on enemy kill | ✅ Done | `EnemyDefinition.gold_reward`; chaser 1 / sprinter 2 / tank 3 |
| `GoldSystem` | ✅ Done | Tracks balance, emits `gold_changed` |
| Shop overlay | ✅ Done | Buy upgrades with gold after wave complete |
| `ShopManager` | ✅ Done | Reuses `UpgradeDefinition` + `gold_cost` |
| Multi-wave loop | ✅ Done | Continue clears arena and starts next wave |
| Gold HUD | ✅ Done | Gold label + wave prefix on timer (`W1 · 45s`) |
| Unit tests | ✅ Done | `test_gold_system.gd`, `test_shop_manager.gd` |

---

## Phase 3B — Visual placeholders and wave ramp ✅

| Task | Status | Notes |
|---|---|---|
| Projectile sprite | ✅ Done | `assets/effects/projectile_bolt.png` in `projectile.tscn` |
| Pickup sprites | ✅ Done | XP gem + health cross replace circle placeholders |
| Multiple waves | ✅ Done | `wave_01` → `wave_03`; later waves reuse final authored wave |
| Wave reconfiguration | ✅ Done | `WaveManager` + `EnemySpawner` support new definitions between waves |
| Tests | ✅ Done | Visual scene tests, wave sequence tests, spawner timer reuse |

---

## Phase 3C — Larger map and off-camera spawns ✅

| Task | Status | Notes |
|---|---|---|
| 3x arena | ✅ Done | Arena bounds now `2640x1440` from `Arena.DEFAULT_VIEW_SIZE * 3` |
| Following camera | ✅ Done | Camera keeps old 1x view, follows player, clamps to map edges |
| Off-camera spawns | ✅ Done | Enemies pick spawn bands just outside the current camera rect |
| Tests | ✅ Done | Arena size, off-camera spawn positions, fallback spawning |

---

## Changelog

### Tooling

- Added root `.gdlintrc` and `.gdformatrc` so gdtoolkit uses consistent lint/format rules
- Fixed `codecheck.ps1` and `codecheck.sh` to pass explicit GDScript paths instead of fragile globs
- Updated the pre-commit hook to run on `main` as well as `master`
- Ran `gdformat` across checked GDScript paths and fixed lint issues surfaced by gdtoolkit

### Phase 3C

- **Map:** expanded arena geometry, walls, and tiled floor to 3x the original play area
- **Camera:** zoom now targets the original 1x view size and follows the player across the larger map
- **Spawns:** `EnemySpawner` uses the player/camera view to place enemies just outside the visible area, falling back to arena edges when needed
- **Tests:** added coverage for 3x arena bounds and off-camera spawn placement

### Phase 3B

- **Visuals:** projectile, XP orb, and health pickup scenes now use transparent PNG sprites under `Visual/Sprite`
- **Waves:** added `wave_02.tres` and `wave_03.tres` with faster spawn intervals, higher caps, and tougher enemy weights
- **Loop:** starting the next wave reconfigures `WaveManager` and `EnemySpawner` with the current authored wave; beyond wave 3 keeps using wave 3
- **Tests:** raw GdUnit suite fixed/expanded to cover new visuals, authored wave selection, spawner timer reuse, elite-cap metadata stubs, and current luck/XP math

### Visual art tooling

- Split the generated 3x3 player grid into named sprites: Milo, Nova, Sprout, Pickle, Brutus, Thorn, Stitch, Granite, Rusty
- Set **Sprout** as the current main player in `scenes/player/player.tscn` and halved the player sprite scale
- Added a reusable Godot grid splitter for generated character sheets (`tools/grid_sprite_splitter.gd`)
- Added a CLI wrapper (`tools/split_grid_sprites.gd`) with grid size, output size, padding, naming, background tolerance, and transparency options
- Added `docs/sprite-grid-splitter.md`, `docs/player-roster.md`, and GdUnit coverage for centering, uneven grids, roster loading, and edge-connected background removal

---

### Phase 3A (tuning)

- **Elite cap:** max 2 elite (tank) enemies alive at once; spawner falls back to non-elite picks when cap is hit
- **Keyboard UI:** level-up `1`/`2`/`3`, shop `1`–`8` + `Enter`, game over `R`/`Enter`; dual-input rule added to `plans.md` and `context.md`
- **WASD ↔ arrows:** documented as fully interchangeable; movement always via input actions
- **Upgrade overhaul:** HP, armor, damage, attack speed, move speed, luck, pickup range, XP gain (orbit blade upgrade removed)

### Phase 3A

- **Gold:** enemies award gold on kill (data-driven via `EnemyDefinition.gold_reward`)
- **Shop:** wave complete opens a shop instead of a restart screen; buy upgrades with gold, then Continue to the next wave
- **Multi-wave:** `game.gd` tracks wave number, clears leftover entities, resets `WaveManager` + `EnemySpawner`
- **Upgrades:** `UpgradeDefinition.gold_cost` added (level-up picks remain free)
- **HUD:** gold counter in top panel; timer shows `W{n} · {seconds}s`

### Phase 2D

- **Level-up picker:** after XP fills the bar, gameplay pauses briefly and offers 3 upgrades
- **Upgrade definitions:** data resources for +10% damage, +10% speed, +20 max HP, +1 orbit blade
- `LevelUpManager` queues level-ups, applies selected upgrades, and resumes active runs
- Runtime weapon definitions are duplicated before upgrades modify damage or orbit blade counts

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
2. Kill enemies — gold accumulates in the HUD (1/2/3 per enemy type)
3. Survive the wave — shop opens; spend gold on upgrades, click **Continue** for wave 2
4. Level up from XP orbs — picker still pauses mid-wave (free upgrades)
5. Die — Game Over overlay with Restart (unchanged)
6. Run `.\tools\codecheck.ps1` before handoff (Godot on PATH + optional `pip install gdtoolkit`)
7. Run tests only: `godot --headless --path . -s addons/gdUnit4/bin/GdUnitCmdTool.gd -a tests/ --ignoreHeadlessMode`
