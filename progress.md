# Kitchen Madness - development progress

Tracks implementation status against [plans.md](plans.md). Update this file at the end of each phase or focused slice.

**Last updated:** Performance optimization pass

---

## Completed work summary

### Phase 2A - Foundation refactor

Done. The prototype was split into modular systems: `EventBus`, `HealthComponent`, `Arena`, `WaveManager`, `EnemySpawner`, `WeaponController`, and data resource types for enemies, weapons, drops, waves, and upgrades. `tools/codecheck.ps1` / `.sh` were added.

### Phase 2B - Enemies, guns, drops

Done. Added chaser, tank, and sprinter enemy archetypes; weighted wave spawning; data-driven pistol, shotgun, and orbit blade; XP orbs; health pickups; and loot spawning.

### Phase 2C - UI polish

Done. HUD reacts through `EventBus`, with floating damage text, XP bar, level label, improved HP bar, pickup feedback, timer pulse, and HP bars for tanky enemies.

### Phase 2D - XP and progression loop

Done. XP collection fills the bar, level-ups pause the run, and the player chooses one of three free stat upgrades.

### Phase 2E - Tests and codecheck

Done. GdUnit4 test coverage exists for core logic and integration boot/run state, and the full codecheck pipeline covers lint, format, headless boot, and tests when local tools are installed.

### Phase 3A - Gold and between-wave shop

Done. Enemies award data-driven gold, the HUD shows gold, wave completion opens a shop, purchases spend gold, and Continue starts the next wave.

### Phase 3B - Visual placeholders and wave ramp

Done. Projectile, pickup, and health sprites replaced placeholder circles; `wave_01` through `wave_03` were authored; and wave/spawner systems can reconfigure between waves.

### Phase 3C - Larger map and off-camera spawns

Done. Arena bounds expanded to `2640x1440`, the camera follows the player while preserving the original view size, and enemies spawn just outside the visible camera rectangle.

### Phase 3D - Visual review and spawn tuning

Done. Visual screenshots were captured, off-camera margin increased to 100px, wave caps/intervals were lowered for camera-ring spawning, and spawn position tests were updated.

### Phase 4A - Playable character roster

Done. Added `CharacterDefinition` resources for all 9 roster characters, a pre-run character select overlay (keyboard + mouse), `player.configure()` for sprite/stats/starting weapon, and tests for roster loading and configuration. Headless runs auto-select Chef.

### Phase 4B - Kitchen weapon roster

Done. Retired pistol, shotgun, and orbit blade. Added 8 kitchen `WeaponDefinition` resources with `WeaponRoster`, burst/boomerang/turret behaviors, per-character starter mapping, and tests.

### Phase 4C - Weapon-focused shop

Done. Shop generates 4 dynamic weapon offers per wave (add weapon, sharpen, speed up, extra projectile). Stat `UpgradeDefinition` resources are level-up only. Added `WeaponShopOffer`, `ShopDisplay`, per-weapon upgrade APIs on `WeaponController`, and tests asserting stat upgrades never appear in shop.

### Phase 4D - VFX pass

Done. Added `VfxLibrary` + pooled `VfxManager` listening to `enemy_killed` and `projectile_hit`. Enemies hide on death and burst with tinted `GPUParticles2D`. Projectiles get world-space trails, accent tints, and impact sparks. Each weapon `.tres` has `vfx_accent`. Style guide at `docs/vfx-style-guide.md`. Visual captures for projectile trails and enemy death. Unit tests for VFX library, manager, and projectile wiring.

### Phase 4E - Wave pacing and enemy density

Done. Wave 1–3 durations are 12s / 17s / 22s. Wave 1 is chaser-only with ~6 pests; wave 2 adds sprinters; wave 3 adds rare tanks. Spawn multipliers stay near 1.0× (no burst flooding). `WaveDefinition.resolve_duration()` adds +5s per wave after the authored roster. Enemies slow to 35% speed for 2s after player contact.

### Phase 5A - Critical damage system

Done. Added `crit_chance` and `crit_damage` to `CharacterDefinition` (base 5% chance, 150% damage). Player tracks crit stats with `increase_crit_chance()` and `increase_crit_damage()` methods. Weapons pass crit stats to projectiles via `set_crit_stats()`. Projectiles roll for crits on hit and emit `damage_dealt` with `is_crit=true`. Added two new level-up upgrades: "Precision" (+4% crit chance) and "Devastation" (+20% crit damage). Crit damage numbers display in yellow/gold via existing `FloatingTextManager`. Created `test_crit_system.gd` with 10 tests covering crit initialization, increases, caps, upgrades, and projectile crit behavior.

### Phase 5B - Enhanced damage number visuals

Done. `FloatingTextManager` now pools labels (32 pre-allocated) for better performance. Added `play_damage()` method to `FloatingText` with bounce/pop animation on all damage numbers. Crit numbers render at 1.5x scale with an extra pop effect (scales to 1.95x then back to 1.5x). Added `damage_number_color` field to `WeaponDefinition` for future per-weapon color customization. Updated tests in `test_floating_text_manager.gd` for pool validation.

### Phase 5C - Projectile visuals fix

Done. Removed `projectile_texture` from 6 weapon definitions so projectiles use default bolt sprites with VFX accent tinting. Kept `projectile_texture` on ladle boomerang (returning weapon visual).

### Phase 5D - Basic sound effects

Done. `AudioManager` autoload with 12 synthesized placeholder SFX at 70% master volume, pooled `AudioStreamPlayer` instances, and EventBus integration for combat, pickups, level-up, wave complete, and shop actions.

### Phase 5E - Statistics persistence

Done. `RunStatsPersistence` writes run summaries to `ignored/stats/stats_YYYY-MM-DD_HHMMSS.json`. One session file per game launch; runs append to a `runs` array. Each record includes character, weapons, level-up upgrades, final wave, level reached, aggregate kills/damage/gold, per-wave timing, and end reason (`death` or `quit`). `StatsPersistence` autoload listens to `metrics_run_ended`; `LevelUpManager` emits `upgrade_applied`. Quit saves via `NOTIFICATION_WM_CLOSE_REQUEST` in `game.gd`. Disabled in headless mode. Tests in `test_run_stats_persistence.gd`.

### Phase 5F - Melee weapons

Done. Added `WeaponType.MELEE` and melee fields (`melee_range`, `melee_arc_degrees`, `melee_knockback`) to `WeaponDefinition`. New `melee_weapon.gd` handles arc hit detection, crit rolls, swing VFX, and knockback. Kitchen knife: fast 50° stab at 46px range. Frying pan: slow 180° swing with 95px knockback. `BaseEnemy.apply_knockback()` added. Tests in `test_melee_weapon.gd`.

### Phase 6A - Enemy variety and swarm spawning

Done. `WaveDefinition` gained `swarm_size_min`, `swarm_size_max`, and `swarm_cluster_radius`. `EnemySpawner` spawns burst groups at a shared anchor with cluster jitter; elites always spawn solo. Added ant (tiny, fast chaser) and pantry moth (erratic darting) enemy types. `BalanceCalculator.estimate_wave_kills()` accounts for average swarm size. Tests in `test_spawn_table.gd`, `test_wave_pacing.gd`, and `test_enemy_variety.gd`.

### Post-6A tuning - Density, bounds, collisions

Done. Tripled swarm sizes and `max_enemies` caps (waves 1–3: swarms 3–6 / 6–12 / 9–18). Fixed off-map spawns and camera void by using `Arena.get_global_bounds()` and resetting arena origin in `game.tscn`. Camera and spawner share clamped focus via `EnemySpawner.set_camera_focus()`. Enemies no longer stack: `CollisionLayers` sets player/enemy masks and floating motion mode; collision shapes sync to `EnemyDefinition.radius`. Tests in `test_camera_bounds.gd` and `test_enemy_collision.gd`.

### Phase 4F - Balance metrics and tuning

Done. `BalanceMetrics` tracks per-wave combat/economy data; `BalanceCalculator` estimates DPS budgets; `WaveSummaryDisplay` shows end-of-wave debug summary. Balance model at `docs/balance-model.md`. Tests in `test_balance_calculator.gd` and `test_balance_metrics.gd`.

### Phase 6B - Shop UI overhaul

Done. Replaced 8 stacked text buttons with a 2×2 `ShopCard` grid showing weapon icons, type badges (NEW/SHARPEN/SPEED/EXTRA), coin prices, hotkey hints, tooltips, and accent-bordered cards. Shop panel uses gold accent styling. Grid keyboard nav: W/S between rows, A/D or arrows between columns. Tests in `test_shop_display.gd`.

### Performance optimization pass

Done. Added `optimizations.md` with the project's performance rules and Godot-specific guidance. Fixed the swarm cap bug where already-tripled wave `max_enemies` values were multiplied by 3 again in `EnemySpawner`; authored caps now use only the documented wave density curve. Enemies now cache their player target, use cheap off-screen movement with disabled render/collision detail outside the camera margin, and avoid per-hit timer allocation for flash feedback. VFX now skips off-screen effects, throttles death/impact particles per frame, reuses particle materials/curves/ramps, and runs lighter particle counts/fixed FPS. Enemy sprite imports are capped to 128px for runtime. Added `PerformanceSettings` autoload plus an in-game Settings overlay with selectable render scale using viewport stretch. Tests updated for render-scale settings and enemy detail toggling. `powershell -ExecutionPolicy Bypass -File .\tools\codecheck.ps1` passes.

---

## Active tasks

_None — see [plans.md](plans.md) for future roadmap._

## How to try it

1. Open the project in Godot 4.6+ and press **F5**.
2. Kill enemies to gain XP and gold.
3. Survive the wave to open the shop, then continue to the next wave.
4. Level up from XP orbs to choose free stat upgrades.
5. Run `.\tools\codecheck.ps1` before handoff.
6. Run tests only with `godot --headless --path . -s addons/gdUnit4/bin/GdUnitCmdTool.gd -a tests/ --ignoreHeadlessMode`.
