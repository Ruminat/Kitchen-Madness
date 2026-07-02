# Kitchen Madness - development progress

Tracks implementation status against [plans.md](plans.md). Update this file at the end of each phase or focused slice.

**Last updated:** Phase 8A — time-based survival level replaces waves · 282 tests green

---

## Unfinished

### Phase 8B — On-demand shop and upgrades

- [ ] Shop opens on **`E`** or bottom-right **Shop** button (`ShopManager.open_shop()` already exists)
- [ ] Level-ups bank an upgrade without opening the menu
- [ ] Upgrades open on **`Q`** or bottom-left **Upgrades** button
- [ ] HUD buttons + keyboard/mouse nav while paused

### Phase 8C — Weapon balance and 6-slot loadout

- [ ] Equal base-tier DPS across all weapons
- [ ] 6 weapon slots
- [ ] Shop: buy weapon upgrades for owned guns
- [ ] Sell owned weapons at 50% purchase price; block selling last gun

### Backlog (from optimizations.md)

- [ ] In-game profiler overlay (active/full-detail enemies, projectiles, particles, frame time)
- [ ] Pool enemies/projectiles if instantiation spikes appear in profiling
- [ ] Quality presets that also control particles and projectile trails

---

## Done

- [x] **Phases 1–4** — Core loop, enemies, XP, wave/shop flow, 9 characters, 8 weapons, VFX, balance metrics.
- [x] **Phase 5 (5A–5F)** — Crit system, damage numbers, projectile visuals, SFX, run stats JSON, melee weapons.
- [x] **Phase 6A** — Ant/moth enemies, burst swarms, cluster spawning.
- [x] **Post-6A tuning** — 3× density, global bounds, collision/camera fixes.
- [x] **Phase 6B** — Shop card grid, icons, tooltips, keyboard nav.
- [x] **Performance pass** — Off-screen culling, VFX throttling, render-scale settings, `optimizations.md`.
- [x] **Phase 7A** — Structured HUD, Grease currency, 5 fixed shop slots, reroll costs.
- [x] **Phase 7B** — World-space damage numbers at hit location.
- [x] **Phase 7C** — Combat balance from run stats (density, HP/damage scaling, upgrade potency).
- [x] **Phase 7D** — Music-forward mix, SFX distance falloff, per-sound volume trims.
- [x] **Phase 7E** — Idle squash/bob on player and enemy visuals.
- [x] **Phase 7F** — Economy/XP rebalance (drops, curve, wave-scaled shop prices).
- [x] **Settings overlay** — Pause-safe asset-backed settings menu, persisted config, E2E layout coverage.
- [x] **Test suite repair** — GdUnit/Godot 4.7 fixes.
- [x] **Phase 8A — Remove waves; time-based levels** — `LevelDefinition` + `LevelManager` replace `WaveDefinition` + `WaveManager`; level 1 is a single 10-minute survival run (`resources/levels/level_01.tres`); spawn rate ramps 1×→6× and the alive cap 24→140 over elapsed time; enemy HP +25%/min and contact damage +15%/min; HUD shows `SURVIVE MM:SS` countdown; timer end → “You Survived!” victory screen, death → game over; shop no longer auto-opens (public `ShopManager.open_shop()` awaits 8B) and prices scale +15% per elapsed minute; run stats record `time_survived`; 282 tests, 0 failures.

---

## How to try it

1. Open the project in Godot 4.7 and press **F5**.
2. Kill enemies to gain XP and Grease; level up from XP orbs to pick free stat upgrades.
3. Survive the 10-minute level timer to win — enemy pressure ramps continuously.
4. Run `./tools/codecheck.sh` (or `.\tools\codecheck.ps1` on Windows) before handoff.
5. Run tests only with `godot --headless --path . -s addons/gdUnit4/bin/GdUnitCmdTool.gd -a tests/ --ignoreHeadlessMode`.

_Note: the shop is temporarily unreachable in-game until Phase 8B wires the on-demand `E` key / Shop button to `ShopManager.open_shop()`._
