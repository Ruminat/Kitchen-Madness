# Kitchen Madness - development progress

Tracks implementation status against [plans.md](plans.md). Update this file at the end of each phase or focused slice.

**Last updated:** Clean asset-backed settings menu · codecheck green

---

## Unfinished

### Phase 8A — Remove waves; time-based levels

- [ ] Remove wave transitions and wave-index-driven shop/end flow
- [ ] Level 1 = 10-minute fixed timer; survive → win, death → lose
- [ ] Scale enemy spawns/density over elapsed time instead of wave number
- [ ] HUD shows level time remaining; win/lose screens replace wave continue

### Phase 8B — On-demand shop and upgrades

- [ ] Shop opens on **`E`** or bottom-right **Shop** button (not after waves)
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
- [x] **Settings overlay** — Pause-safe asset-backed settings menu with clean generated background, generated button plates, deterministic row/control margins, audio/render options, persisted config, and E2E layout coverage.
- [x] **Test suite repair** — 270 tests, 0 failures; GdUnit/Godot 4.7 fixes.

---

## How to try it

1. Open the project in Godot 4.7 and press **F5**.
2. Kill enemies to gain XP and Grease.
3. Survive the wave to open the shop (5 fixed slots, R to reroll), then continue to the next wave.
4. Level up from XP orbs to choose free stat upgrades.
5. Run `.\tools\codecheck.ps1` before handoff.
6. Run tests only with `godot --headless --path . -s addons/gdUnit4/bin/GdUnitCmdTool.gd -a tests/ --ignoreHeadlessMode`.

_Note: Phase 8 will replace waves with a 10-minute survival level and on-demand shop (`E`) / upgrades (`Q`) buttons._
