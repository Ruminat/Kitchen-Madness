# Kitchen Madness - development progress

Tracks implementation status against [plans.md](plans.md). Update this file at the end of each phase or focused slice.

**Last updated:** The Great Rework — R1–R8 complete (stat foundation, 3-char roster, 3 weapons, 8 upgrades, perks, skills, entities, unified luck-biased acquisition). 383 tests, 0 failures.

---

## Unfinished

### Backlog (from optimizations.md)

- [ ] In-game profiler overlay (active/full-detail enemies, projectiles, particles, frame time)
- [ ] Pool enemies/projectiles if instantiation spikes appear in profiling
- [ ] Quality presets that also control particles and projectile trails

---

## Done

- [x] **The Great Rework (R0–R8)** — full content reset for fun; quality over quantity. See [plans.md](plans.md) and [GAME_DESIGN.md](GAME_DESIGN.md). **383 tests, 0 failures, 0 orphans; codecheck green; clean headless boot + gameplay smoke.**
  - **R0 — Design & docs** — player bios/stats, `docs/stats.md`, base circle template, roadmap.
  - **R1 — Stat foundation** — `StatUnits` (single design-unit↔pixel/move-speed factor `220/30`); `CharacterDefinition` gains `armor`/`damage_mult`/`attack_speed_mult`/`evasion` + %-based `luck`/`crit_chance`; `HealthComponent` armor as % reduction (`StatUnits.apply_armor`, tunable 5%/pt, clamped), evasion negation + shared i-frames, `take_damage()` returns applied damage; `WeaponController` global damage/fire-rate/area multipliers that new weapons inherit; player area/evasion/HP%/signed-move-speed mutators. Tests: `test_stat_units`, armor/evasion in `test_health_component`, `test_weapon_modifiers`, `test_player_stats`.
  - **R2 — Player roster reset** — removed 9 old characters + sprites/grid sheet; added **The Newbie / Mr. Barret / Natsumi** (`resources/characters/*.tres`, rework sprites, design-unit move speed). Character select adapts to 3 (mouse + keyboard); detail readout via `CharacterSelectDisplay`.
  - **R3 — Weapon reset** — removed 6 old weapons + unused weapon-type scripts/boomerang scene; **Kitchen Knife / Frying Pan / Rotten Tomato** authored in design units (`WeaponDefinition.area`/`attack_range`); melee reach from `area`×area-mult; ranged range-gated targeting + tomato splash (`Projectile.set_splash_radius`); `BalanceCalculator.BASE_DPS_TARGET` re-baselined 36→32.
  - **R4 — Level-upgrade reset** — 8 upgrades (Armor +1, HP +5%, Attack speed +10%, Damage +10%, Area +5%, Move speed +5%, Luck +5%, Evasion +4%) wired to R1 via shared `StatEffects`; generated icons on the level-up cards.
  - **R5 — Perks** — data-driven `PerkDefinition` (bundled `StatEffect` list): Bring me more (+5% enemies via `EventBus.enemy_count_percent_added` → spawner `count_multiplier`), The crazy one (−2 armor, +10% atk spd), Getting fatty (−3% move, +1 armor). Integrated into the shop as `PerkShopOffer`.
  - **R6 — Skills** — `SkillDefinition` + `SkillRunner` ticking independently: Heavy Fridge (falling AoE), Wraith of Cooking God (multi-hit lightning), Garlic Stench (player aura); per-level scaling + max levels; player Damage/Area apply to skills; acquired/upgraded via shop.
  - **R7 — Pets/structures/traps** — `EntityDefinition` + `EntityManager` + `EntityCombat`: Nasty Cat (pet, chases + swipes, immune), Bean Shooter (structure, sniper), Banana Mine (trap spawner, per-level scaling). Own scenes/scripts, distinct from weapons; acquired via shop.
  - **R8 — Acquisition & integration** — unified offer model (`OfferCatalog`) and **luck-biased selection (`OfferSelection`)** applied across the shop *and* level-up so Luck favors "double-down" (owned) upgrades everywhere; skills/entities now also acquirable on level-up; cost-tiered economy (weapon 12 < perk 14 < skill 18 < entity 20, all time-scaled).
- [x] **Shop robustness fix** — stale/invalid offers no longer burn Grease or misfire. `WeaponShopOffer.apply()` now rejects weapon upgrades (damage/attack-speed/pellet) whose target weapon isn't owned (full refund instead of a silent no-op), and `ShopManager._invalidate_stale_offers()` greys out any still-open offer that no longer applies after a buy/sell (add-weapon now owned or at the 6-slot cap; upgrade/sell for a weapon no longer in the loadout). New `test_shop_offer_validity` suite plus `WeaponShopOffer` ownership-guard tests; 330 tests, 0 failures.
- [x] **Phase 9 — UI design system** — new `DesignSystem` (`scripts/ui/design_system.gd`, alias `DS`) is the single source of truth for the interface: palette (ink/parchment/metal/brass + semantic accents + 5 rarity hues), 4px spacing scale, radius/border scales, a modular type scale (base 16, ratio 1.2) mapped to roles, elevation presets, and tiny builders (`stylebox/shadowed/padded/style_label`). Every UI style file (`hud_theme`, `shop_display`, `shop_card`, `upgrade_display`, `hud_action_bar/button`, `weapon_belt`) now composes tokens instead of hardcoding colors/sizes; level-up + shop upgrade cards unified onto the warm parchment language. Documented in `docs/ui-design-system.md`; 19 new tests (`test_design_system`, `test_hud_theme`) cover scale monotonicity, contrast, rarity, and that composed styles source their values from tokens. 322 tests, 0 failures.
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
