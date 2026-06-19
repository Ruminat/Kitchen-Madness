# Kitchen Madness - development progress

Tracks implementation status against [plans.md](plans.md). Update this file at the end of each phase or focused slice.

**Last updated:** Phase 4C weapon-focused shop

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

---

## Active tasks

### Phase 4D - VFX pass

**Goal:** Add satisfying visual effects so enemies and projectiles no longer feel flat or instant.

Research summary:

- Godot recommends `GPUParticles2D` for most 2D particle effects.
- One-shot effects should use `restart()` on reuse and clean up or return to pool via `finished`.
- Particle counts should stay low; use scale/color curves, alpha fades, and visibility rects for readability/performance.
- Projectile trails may need global-space particles so trails stay behind fast-moving projectiles.

| Task | Status | Notes |
|---|---|---|
| Write VFX style guide | Planned | Kitchen-themed crumbs, sparks, smoke, pepper clouds, soup splashes |
| Add enemy death effect | Planned | Enemies should burst/fade instead of instantly disappearing |
| Improve projectile visuals | Planned | Add trails, impact sparks, and clearer silhouettes |
| Add weapon-specific effects | Planned | Keep effects readable during swarms |
| Add VFX spawner/pooling if needed | Planned | Pool frequent death/projectile effects once counts rise |
| Capture visual tests | Planned | Compare surrounded player, projectiles, enemy death, and upgrade/shop views |

---

### Phase 4E - Wave pacing and enemy density

**Goal:** Start with short waves and ramp length/density while keeping enemies weaker and more numerous.

| Task | Status | Notes |
|---|---|---|
| Add wave duration progression | Planned | Wave 1 around 10-15 seconds, then about +5 seconds per wave initially |
| Increase enemy density | Planned | More enemies on screen, with lower individual HP/damage as needed |
| Retune enemy stats | Planned | Favor many simple pests over a few durable enemies |
| Update wave resources | Planned | Apply pacing to `wave_01.tres` onward |
| Add tests | Planned | Cover duration progression, spawn caps, and authored wave selection |

---

### Phase 4F - Balance metrics and tuning

**Goal:** Begin balancing around measured DPS, XP, gold, and wave pressure.

| Task | Status | Notes |
|---|---|---|
| Create balance model doc | Planned | Track target DPS, XP/wave, gold/wave, enemy HP budget, and time-to-level |
| Add runtime metrics | Planned | Kills, gold, XP, damage dealt, damage taken, weapon contribution |
| Show end-of-wave debug summary | Planned | Use for playtest tuning before building final UI |
| Estimate weapon DPS from data | Planned | Compare theoretical DPS to observed playtest metrics |
| Compare characters/weapons | Planned | Check that starter choices are distinct but not obviously dominant |
| Add deterministic balance tests | Planned | Cover DPS formulas, XP/gold budgets, and wave-duration targets |

---

## How to try it

1. Open the project in Godot 4.6+ and press **F5**.
2. Kill enemies to gain XP and gold.
3. Survive the wave to open the shop, then continue to the next wave.
4. Level up from XP orbs to choose free stat upgrades.
5. Run `.\tools\codecheck.ps1` before handoff.
6. Run tests only with `godot --headless --path . -s addons/gdUnit4/bin/GdUnitCmdTool.gd -a tests/ --ignoreHeadlessMode`.
