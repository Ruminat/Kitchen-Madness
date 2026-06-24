# Kitchen Madness - development progress

Tracks implementation status against [plans.md](plans.md). Update this file at the end of each phase or focused slice.

**Last updated:** Phase 7A HUD, Grease, and shop layout

---

## Active tasks

### Phase 7B - World-space damage numbers

Pending. Damage numbers should stick to world position where they appear, not follow the player/camera.

### Phase 7C - Combat balance tuning from run statistics

Pending. Use persisted stats to curb combat snowballing (player too strong after a few waves).

### Phase 7F - Economy and XP rebalance

Pending. Lower XP/Grease drop rates; target ~1–2 affordable shop purchases per wave; scale shop prices with wave number; let higher enemy counts partially restore total income without per-kill flooding.

### Phase 7D - Audio mix and distance falloff

Pending. Louder music, quieter SFX, distance attenuation, quieter player hurt sound.

### Phase 7E - Idle squash animations

Pending. Research Godot/Brotato-style approach first, then add simple ~1s squash idle to player and enemies.

---

## How to try it

1. Open the project in Godot 4.6+ and press **F5**.
2. Kill enemies to gain XP and Grease.
3. Survive the wave to open the shop (5 fixed slots, R to reroll), then continue to the next wave.
4. Level up from XP orbs to choose free stat upgrades.
5. Run `.\tools\codecheck.ps1` before handoff.
6. Run tests only with `godot --headless --path . -s addons/gdUnit4/bin/GdUnitCmdTool.gd -a tests/ --ignoreHeadlessMode`.

---

## Completed work summary

### Phase 2A - Foundation refactor

Modular systems: EventBus, HealthComponent, Arena, WaveManager, EnemySpawner, WeaponController, data resources, codecheck scripts.

### Phase 2B - Enemies, guns, drops

Chaser/tank/sprinter enemies, weighted spawning, pistol/shotgun/orbit blade, XP orbs, health pickups, loot.

### Phase 2C - UI polish

EventBus-driven HUD, floating damage text, XP bar, level label, HP bar, pickup feedback, timer pulse.

### Phase 2D - XP and progression loop

XP bar, level-up pause, 1-of-3 stat upgrade choice.

### Phase 2E - Tests and codecheck

GdUnit4 coverage + lint/format/boot/test pipeline.

### Phase 3A - Gold and between-wave shop

Enemy gold rewards, HUD display, between-wave shop, Continue flow.

### Phase 3B - Visual placeholders and wave ramp

Sprite placeholders replaced, wave_01–03 authored, spawner reconfiguration.

### Phase 3C - Larger map and off-camera spawns

2640×1440 arena, camera follow, off-camera spawn ring.

### Phase 3D - Visual review and spawn tuning

Screenshots, 100px spawn margin, tuned caps/intervals.

### Phase 4A - Playable character roster

9 `CharacterDefinition` resources, character select overlay, `player.configure()`, tests.

### Phase 4B - Kitchen weapon roster

8 kitchen weapons, WeaponRoster, burst/boomerang/turret behaviors, starter mapping.

### Phase 4C - Weapon-focused shop

4 dynamic weapon offers, level-up-only stat upgrades, WeaponShopOffer/ShopDisplay.

### Phase 4D - VFX pass

VfxLibrary + pooled VfxManager, death bursts, projectile trails, impact sparks.

### Phase 4E - Wave pacing and enemy density

12s/17s/22s waves, contact slow, +5s per wave after roster.

### Phase 4F - Balance metrics and tuning

BalanceMetrics, BalanceCalculator, WaveSummaryDisplay, balance model doc.

### Phase 5A - Critical damage system

Crit stats, projectile crit rolls, Precision/Devastation upgrades, yellow crit numbers.

### Phase 5B - Enhanced damage number visuals

Pooled labels, bounce/pop, 1.5× crit scale, weapon color field.

### Phase 5C - Projectile visuals fix

Default bolt sprites + VFX tint; ladle keeps projectile texture.

### Phase 5D - Basic sound effects

AudioManager autoload, 12 placeholder SFX, EventBus integration.

### Phase 5E - Statistics persistence

Run summaries to `ignored/stats/` JSON, quit-save, headless disabled.

### Phase 5F - Melee weapons

Kitchen knife + frying pan, arc hits, knockback, swing VFX.

### Phase 6A - Enemy variety and swarm spawning

Ant/moth enemies, burst swarms, cluster radius, balance estimates.

### Post-6A tuning - Density, bounds, collisions

3× density, global bounds, camera/spawner clamp, no enemy stacking.

### Phase 6B - Shop UI overhaul

2×2 ShopCard grid, icons, badges, tooltips, keyboard nav.

### Performance optimization pass

Off-screen culling, VFX throttling, render-scale settings, swarm cap fix, `optimizations.md`.

### Phase 7A - HUD, Grease currency, shop layout

Structured HUD (HP bar + value, wave timer, kills, Grease label, bottom XP panel). Grease rebrand in player-facing UI. Shop: 5 fixed slots in a row, sold cards stay in place, reroll with escalating cost (6 + 4× reroll count). Enemy sprite imports restored to full size (`size_limit=0`). Tests updated for 5-offer shop and Grease formatting.
