# Kitchen Madness - development progress

Tracks implementation status against [plans.md](plans.md). Update this file at the end of each phase or focused slice.

**Last updated:** Phase 7E idle squash animations · suite 273 tests green

---

## Unfinished

_Active roadmap (7A–7F) complete. Next work is open — see backlog or add a new phase in [plans.md](plans.md)._

### Backlog (from optimizations.md)

- [ ] In-game profiler overlay (active/full-detail enemies, projectiles, particles, frame time)
- [ ] Pool enemies/projectiles if instantiation spikes appear in profiling
- [ ] Quality presets that also control particles and projectile trails

---

## Done

- [x] **Phase 2A - Foundation refactor** — EventBus, HealthComponent, Arena, WaveManager, EnemySpawner, WeaponController, data resources, codecheck.
- [x] **Phase 2B - Enemies, guns, drops** — chaser/tank/sprinter, weighted spawning, pistol/shotgun/orbit blade, XP orbs, health/loot.
- [x] **Phase 2C - UI polish** — EventBus HUD, floating damage text, XP bar, HP bar, pickup feedback, timer pulse.
- [x] **Phase 2D - XP and progression loop** — XP bar, level-up pause, 1-of-3 stat upgrades.
- [x] **Phase 2E - Tests and codecheck** — GdUnit4 coverage + lint/format/boot/test pipeline.
- [x] **Phase 3A - Gold and between-wave shop** — gold rewards, HUD display, shop, Continue flow.
- [x] **Phase 3B - Visual placeholders and wave ramp** — sprites, wave_01–03, spawner reconfiguration.
- [x] **Phase 3C - Larger map and off-camera spawns** — 2640×1440 arena, camera follow, off-camera spawn ring.
- [x] **Phase 3D - Visual review and spawn tuning** — screenshots, 100px spawn margin, tuned caps/intervals.
- [x] **Phase 4A - Playable character roster** — 9 `CharacterDefinition`s, select overlay, `player.configure()`, tests.
- [x] **Phase 4B - Kitchen weapon roster** — 8 weapons, WeaponRoster, burst/boomerang/turret, starter mapping.
- [x] **Phase 4C - Weapon-focused shop** — dynamic weapon offers, level-up-only stat upgrades, WeaponShopOffer/ShopDisplay.
- [x] **Phase 4D - VFX pass** — VfxLibrary + pooled VfxManager, death bursts, projectile trails, impact sparks.
- [x] **Phase 4E - Wave pacing and enemy density** — 12s/17s/22s waves, contact slow, +5s per wave after roster.
- [x] **Phase 4F - Balance metrics and tuning** — BalanceMetrics, BalanceCalculator, WaveSummaryDisplay, balance model doc.
- [x] **Phase 5A - Critical damage system** — crit stats, projectile crit rolls, Precision/Devastation upgrades, yellow crit numbers.
- [x] **Phase 5B - Enhanced damage number visuals** — pooled labels, bounce/pop, 1.5× crit scale, weapon color field.
- [x] **Phase 5C - Projectile visuals fix** — default bolt sprites + VFX tint; ladle keeps projectile texture.
- [x] **Phase 5D - Basic sound effects** — AudioManager autoload, 12 placeholder SFX, EventBus integration.
- [x] **Phase 5E - Statistics persistence** — run summaries to `ignored/stats/` JSON, quit-save, headless disabled.
- [x] **Phase 5F - Melee weapons** — kitchen knife + frying pan, arc hits, knockback, swing VFX.
- [x] **Phase 6A - Enemy variety and swarm spawning** — ant/moth, burst swarms, cluster radius, balance estimates.
- [x] **Post-6A tuning** — 3× density, global bounds, camera/spawner clamp, no enemy stacking.
- [x] **Phase 6B - Shop UI overhaul** — ShopCard grid, icons, badges, tooltips, keyboard nav.
- [x] **Performance optimization pass** — off-screen culling, VFX throttling, render-scale settings, swarm cap fix, `optimizations.md`.
- [x] **Phase 7A - HUD, Grease currency, shop layout** — structured HUD, Grease rebrand, 5 fixed shop slots with sold-state, escalating reroll cost, restored enemy sprite imports.
- [x] **Phase 7B - World-space damage numbers** — `FloatingTextManager` as world `Node2D`; labels anchored at hit `world_pos`; pooling unchanged.
- [x] **Phase 7C - Combat balance tuning** — 10% density growth (interval-only), smaller swarms, wave-scaled enemy HP/damage (+12%/+8%), +5% combat upgrades, calculator/metrics fixes.
- [x] **Phase 7F - Economy and XP rebalance** — 40% XP / 50% Grease drops, smaller orbs, 240+65 XP curve, +15%/wave shop prices, `estimate_wave_affordability()`.
- [x] **Phase 7D - Audio mix and distance falloff** — music-forward defaults (music 0.7 / SFX 0.32), one-shot SFX distance falloff from the player via `play_sfx_at()` (enemy hit/death), per-sound trims with player hurt at 0.5×, volume + falloff tests.
- [x] **Phase 7E - Idle squash animations** — reusable `IdleSquash` component (volume-preserving squash + bob on the `Visual` node), attached in `base_enemy`/`player`; leaves body/collision untouched, skips hidden off-screen targets, id-desynced; component tests.
- [x] **Test suite repair** — fixed the missing-`panel_style` parse error, `pepper_grinder_gun` UID references, `clear_weapons()` deferred-free bug, and a batch of stale/pre-existing broken tests (GdUnit API, Godot 4.7 coroutine handling, RNG determinism, orphan cleanup). Suite: 270 tests, 0 failures, 0 orphans.

---

## How to try it

1. Open the project in Godot 4.7 and press **F5**.
2. Kill enemies to gain XP and Grease.
3. Survive the wave to open the shop (5 fixed slots, R to reroll), then continue to the next wave.
4. Level up from XP orbs to choose free stat upgrades.
5. Run `.\tools\codecheck.ps1` before handoff.
6. Run tests only with `godot --headless --path . -s addons/gdUnit4/bin/GdUnitCmdTool.gd -a tests/ --ignoreHeadlessMode`.
