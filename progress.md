# Kitchen Madness - development progress

Tracks implementation status against [plans.md](plans.md). Update this file at the end of each phase or focused slice.

**Last updated:** Phase 5D basic sound effects

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

---

## Active tasks

### Phase 5C - Projectile visuals fix

**Goal:** Fix the bug where gun weapons are shooting themselves as projectiles instead of just particles.

| Task | Status | Notes |
|---|---|---|
| Bug investigation | Done | Root cause: weapon definitions set `projectile_texture` to the weapon icon, causing full weapon sprite to appear as projectile |
| Projectile cleanup | Done | Removed `projectile_texture` from weapon definitions (6 files); projectiles now use default bolt texture with VFX accent tinting |
| Ladle boomerang | Kept | Kept `projectile_texture` for ladle_boomerang - returning weapon makes sense to show full sprite |
| Visual review | Done | Projectiles now render as small bolt sprites tinted with weapon's `vfx_accent` color |
| Tests | Done | No new tests needed - existing projectile tests verify instantiation works correctly |

**Fix applied to:**
- `pepper_grinder_gun.tres`
- `kitchen_knife.tres`
- `frying_pan.tres`
- `garlic_bomb.tres`
- `boiling_soup_splash.tres`
- `toaster_turret.tres`

**Preserved:**
- `ladle_boomerang.tres` (kept projectile_texture for returning weapon visual)

---

### Phase 5D - Basic sound effects

**Goal:** Add foundational audio feedback for core gameplay actions.

| Task | Status | Notes |
|---|---|---|
| Sound system | Done | Created `AudioManager` autoload with synthesized placeholder SFX |
| Core sounds | Done | 12 sounds: enemy hit/death, player hurt, shoot (3 types), level up, wave complete, shop buy, pickup (xp/health/gold), weapon upgrade |
| Audio manager | Done | Pool of 16 AudioStreamPlayers for one-shot SFX with automatic recycling |
| Volume control | Done | Master volume property with linear-to-dB conversion |
| Integration | Done | EventBus signals hooked (damage, kills, health, level up, wave complete, pickups, gold changes) |
| Weapon sounds | Done | Projectile, burst, boomerang, and turret weapons all trigger shoot sounds |
| Placeholder generation | Done | Procedural beeps, noise bursts, and arpeggios using AudioStreamWAV |

**Sounds implemented:**
- **Gameplay:** enemy_hit, enemy_death, player_hurt, level_up, wave_complete
- **Weapons:** shoot_default, shoot_shotgun (burst), shoot_boomerang, shoot_turret
- **Economy:** shop_buy, pickup_xp, pickup_health, pickup_gold, weapon_upgrade

**To replace with real SFX:** Add `.wav` files to `assets/audio/sfx/` matching the paths in `SFX_PATHS` constant.

---

### Phase 4F - Balance metrics and tuning

**Goal:** Begin balancing around measured DPS, XP, gold, and wave pressure.

| Task | Status | Notes |
|---|---|---|
| Create balance model doc | Done | `docs/balance-model.md` with targets for DPS, XP/wave, gold/wave, HP budget, time-to-level |
| Add runtime metrics | Done | `BalanceMetrics` class tracks kills, damage dealt/taken, XP, gold, weapon contribution per wave |
| Show end-of-wave debug summary | Done | `WaveSummaryDisplay` shows wave metrics on completion (press ENTER/ESC to continue) |
| Estimate weapon DPS from data | Done | `BalanceCalculator` class computes theoretical DPS, XP/gold budgets, wave HP budgets |
| Compare characters/weapons | Done | Balance model includes DPS comparison table for all 9 characters and 8 weapons |
| Add deterministic balance tests | Done | `test_balance_calculator.gd` and `test_balance_metrics.gd` cover calculations |

---

## How to try it

1. Open the project in Godot 4.6+ and press **F5**.
2. Kill enemies to gain XP and gold.
3. Survive the wave to open the shop, then continue to the next wave.
4. Level up from XP orbs to choose free stat upgrades.
5. Run `.\tools\codecheck.ps1` before handoff.
6. Run tests only with `godot --headless --path . -s addons/gdUnit4/bin/GdUnitCmdTool.gd -a tests/ --ignoreHeadlessMode`.
