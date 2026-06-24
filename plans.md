# Kitchen Madness - development plan

Roadmap for **Kitchen Madness**, a top-down roguelite arena survivor in Godot 4.

See also: [context.md](context.md) for current project state and iteration rules, [progress.md](progress.md) for task status, and [game-setting.md](game-setting.md) for theme and content direction.

---

## North star

**Data-driven content, thin scenes, testable logic, readable chaos.**

Designers should add characters, enemies, weapons, drops, waves, and upgrades through `.tres` resources and focused scenes, not by hardcoding individual content into gameplay systems.

Every player-facing action must support both mouse and keyboard. WASD and arrow keys are always interchangeable for movement and menus.

---

## Active roadmap

### Phase 7B - World-space damage numbers

**Goal:** Damage numbers stay where they appear in the world instead of following the camera/player.

| Task | Details |
|---|---|
| World positioning | Spawn floating text in world space (or convert screen position once at spawn) so numbers remain at the hit location |
| Camera independence | Ensure numbers do not re-anchor to the player or HUD each frame |
| Pooling | Keep existing `FloatingTextManager` pool; only change coordinate handling |
| Tests | Verify spawn position uses world/global coordinates |

**Done:** Manager is a `Node2D` child of `Game`; labels use world coordinates directly.

---

### Phase 7C - Combat balance tuning from run statistics

**Goal:** Use persisted run stats to reduce combat snowballing — the player becomes overpowered too quickly after a few waves.

| Task | Details |
|---|---|
| Analyze stats | Review `ignored/stats/` JSON for DPS, kills, damage taken, and wave timing curves |
| Enemy scaling | Tune wave density, enemy HP/damage, or spawn pacing based on findings |
| Upgrade potency | Adjust level-up upgrade values if they outpace enemy growth |
| Validation | Compare predicted DPS (`BalanceCalculator`) vs. actual metrics after changes |
| Tests | Update balance calculator / wave pacing tests if formulas change |

**Done:** 10% density growth on spawn interval only; smaller swarms; wave HP/damage scaling; +5% combat upgrades; calculator/metrics fixes.

---

### Phase 7F - Economy and XP rebalance

**Goal:** Tighten Grease and XP income so each shop visit supports ~1–2 purchases, not clearing the whole board. Scale shop prices with wave number; let higher enemy counts restore total income without restoring today's per-kill flood.

| Task | Details |
|---|---|
| Drop probability | Lower XP orb and Grease drop rates significantly (data-driven via enemy/drop `.tres` or spawn logic) |
| Shop affordability target | Tune so a typical wave earns enough Grease for **1–2 shop items**, not all 5 slots + rerolls |
| Wave-scaled prices | Increase shop offer costs each wave (extend or replace early-wave discount in `ShopManager._scaled_cost`) |
| Volume compensation | Later waves spawn more enemies; total Grease/XP per wave may rise from kill count while **per-enemy** drop rate stays low |
| XP pacing | Slow level-ups to match — fewer orbs, lower XP per orb, or higher XP-to-level curve |
| Stats validation | Compare `ignored/stats/` Grease earned, shop spend, and levels per wave before/after |
| Tests | Update gold/XP/drop and shop cost tests; add affordability estimate if useful |

**Done:** 40% XP / 50% Grease drops, smaller orbs, 240+65 XP curve, +15%/wave shop costs, affordability helper.

---

### Phase 7D - Audio mix and distance falloff

**Goal:** Music should dominate the mix; SFX should be quieter overall and attenuate with distance.

| Task | Details |
|---|---|
| Music louder | Raise music bus volume relative to SFX |
| Distance falloff | Attenuate one-shot SFX by distance from player (e.g. far projectile hits) |
| Player hurt | Make player damage sound ~2× quieter; replace placeholder if a better clip is available |
| Volume hierarchy | Music > gameplay SFX > ambient/distant hits |
| Tests | Smoke-test `AudioManager` volume and falloff helpers if added |

---

### Phase 7E - Idle squash animations (Brotato-style)

**Goal:** Simple idle motion so player and enemies feel alive, not like static sprites.

| Task | Details |
|---|---|
| Research | Study Brotato-style idle motion and Godot best practices (child `Sprite2D` + `AnimationPlayer`/`Tween`, or shader; avoid fighting physics/collision transforms) |
| Shared component | Reusable idle bob/squash script or scene (e.g. ~1s vertical squash cycle) |
| Player + enemies | Apply to player sprite and enemy sprites without affecting collision shapes |
| Performance | Keep off-screen enemies on cheap/no animation path if needed |
| Tests | Optional unit test for animation component setup |

---

## Definition of done

Every iteration should end with:

1. No parser/script errors; Godot opens cleanly and F5 smoke test works.
2. `.\tools\codecheck.ps1` passes when local tools are available.
3. New content remains data-driven through resources and focused scenes.
4. UI continues to support mouse and keyboard.
5. `progress.md` is updated with a short outcome summary.

---

## Completed roadmap summary

**Phases 1–4:** Core architecture (EventBus, HealthComponent, WaveManager, WeaponController), content loop (enemies, XP, drops, level-ups), wave/shop flow, visual polish, 9 characters, 8 kitchen weapons, weapon-focused shop, VFX pass, wave pacing, balance metrics.

**Phase 5A — Critical damage:** Crit chance/damage stats, roll on hit, level-up upgrades, yellow crit numbers, tests.

**Phase 5B — Damage number visuals:** Pooled labels, bounce/pop animation, 1.5× crit scale, per-weapon color field.

**Phase 5C — Projectile visuals fix:** Removed weapon textures from projectile defs; default bolt + VFX tint.

**Phase 5D — Basic sound effects:** `AudioManager` autoload, synthesized SFX, EventBus hooks.

**Phase 5E — Statistics persistence:** Run summaries to `ignored/stats/` as timestamped JSON.

**Phase 5F — Melee weapons:** Kitchen knife + frying pan with arc hits, knockback, swing VFX.

**Phase 6A — Enemy variety & swarms:** Ant/moth enemies, burst swarm spawning, cluster radius, tests.

**Post-6A tuning:** 3× wave density, global arena bounds, enemy/player collisions, camera clamp.

**Phase 6B — Shop UI overhaul:** 2×2 card grid with icons, badges, tooltips, keyboard nav.

**Performance optimization pass:** Off-screen enemy/VFX culling, particle throttling, render-scale settings, swarm cap fix, `optimizations.md`.

**Phase 7A — HUD, Grease currency, shop layout:** Structured HUD panels (HP, wave timer, XP, Grease), Grease rebrand in UI text, 5 fixed shop slots with sold-state (no reflow), reroll with escalating cost, restored enemy sprite import sizes.
