# Kitchen Madness - development progress

Tracks implementation status against [plans.md](plans.md). Update this file at the end of each phase or focused slice.

**Last updated:** Phase 8C — weapon DPS parity, 6 slots, sell mechanics · 303 tests green

---

## Unfinished

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
- [x] **Phase 8A — Remove waves; time-based levels** — `LevelDefinition` + `LevelManager` replace `WaveDefinition` + `WaveManager`; level 1 is a single 10-minute survival run (`resources/levels/level_01.tres`); spawn rate ramps 1×→6× and the alive cap 24→140 over elapsed time; enemy HP +25%/min and contact damage +15%/min; HUD shows `SURVIVE MM:SS` countdown; timer end → “You Survived!” victory screen, death → game over; shop no longer auto-opens (public `ShopManager.open_shop()`) and prices scale +15% per elapsed minute; run stats record `time_survived`.
- [x] **Phase 8B — On-demand shop and upgrades** — level-ups bank a pending upgrade (`EventBus.upgrades_pending_changed`) rather than interrupting the run; player opens the shop with **`E`** / bottom-right Shop button and banked upgrades with **`Q`** / bottom-left Upgrades button (badge shows pending count, disabled at 0); both pause and support mouse + keyboard; new `HudActionBar`/`HudActionButton` widgets render beneath the modal overlays; 291 tests, 0 failures.
- [x] **Phase 8C — Weapon balance and 6-slot loadout** — every tier-1 weapon tuned to ~36 single-target DPS (±12%), verified by the new type-aware `BalanceCalculator.single_target_dps()`; each weapon `.tres` now carries the correct `weapon_type`; 6-slot cap confirmed; shop can **sell** owned weapons for 50% of purchase price (`WeaponShopOffer.SELL_WEAPON`, `WeaponController.remove_weapon()`, per-weapon price tracking, starting weapon seeded at base cost), blocked at the last remaining gun; sell cards always affordable with a `+N` refund badge; 303 tests, 0 failures.

---

## How to try it

1. Open the project in Godot 4.7 and press **F5**.
2. Kill enemies to gain XP and Grease; each level-up banks an upgrade — open the picker with **`Q`** or the bottom-left Upgrades button.
3. Open the weapon shop anytime with **`E`** or the bottom-right Shop button (game pauses while either overlay is open).
4. Survive the 10-minute level timer to win — enemy pressure ramps continuously.
5. Run `./tools/codecheck.sh` (or `.\tools\codecheck.ps1` on Windows) before handoff.
6. Run tests only with `godot --headless --path . -s addons/gdUnit4/bin/GdUnitCmdTool.gd -a tests/ --ignoreHeadlessMode`.
