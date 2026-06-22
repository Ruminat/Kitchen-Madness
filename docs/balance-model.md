# Kitchen Madness - Balance Model

Target stats and formulas for balancing combat power, economy, and wave pressure.

---

## Core Time Targets

| Metric | Target | Notes |
|--------|--------|-------|
| Wave 1 Duration | 12s | Fast intro, learn controls |
| Wave 2 Duration | 17s | +5s, introduce sprinters |
| Wave 3 Duration | 22s | +5s, introduce tanks |
| Wave N Duration | 12 + 5×N (capped) | Linear growth per wave |
| Time to Level 2 | ~1 wave | First level-up from wave 1 XP |
| Time to Level 3 | ~1.5 waves | Slows slightly as XP scales |

---

## Weapon DPS Model

### DPS Formula

```
base_dps = damage × pellet_count / fire_rate
effective_dps = base_dps × hit_rate × target_factor
```

Where:
- `hit_rate`: % of projectiles that hit (0.3-0.9 based on weapon type)
- `target_factor`: 1.0 for single-target, up to 2.5 for multi-target weapons vs swarms

### Weapon Targets

| Weapon | Base DPS | Hit Rate | Swarm Factor | Effective DPS | Role |
|--------|----------|----------|--------------|---------------|------|
| Pepper Grinder Gun | 33 | 0.70 | 1.0 | 23 | Reliable baseline |
| Kitchen Knife | 75 | 0.65 | 1.0 | 49 | High single-target |
| Frying Pan | 40 | 0.55 | 1.3 | 29 | Knockback utility |
| Boiling Soup Splash | 44 | 0.50 | 2.0 | 44 | Cone burst |
| Garlic Bomb | 80 | 0.40 | 2.5 | 80 | Area burst |
| Onion Ring Blade | 22 | 0.90 | 1.5 | 30 | Orbiting melee |
| Ladle Boomerang | 38 | 0.60 | 1.2 | 27 | Returning control |
| Toaster Turret | 20 | 0.85 | 1.0 | 17 | Deployable backup |

### Starter Character DPS

| Character | Starting Weapon | Base DPS |
|-----------|-----------------|----------|
| Chef | Kitchen Knife | 49 |
| Goblin | Pepper Grinder Gun | 23 |
| Onion | Onion Ring Blade | 30 |
| Cookie | Frying Pan | 29 |
| Mushroom | Garlic Bomb | 80 |
| Vampire | Kitchen Knife | 49 |
| Witch | Ladle Boomerang | 27 |
| Dumpling | Boiling Soup Splash | 44 |
| Snowman | Toaster Turret | 17 |

---

## Enemy HP Budget

### Enemy Stats

| Enemy Type | HP | Contact Damage | XP | Gold | Role |
|------------|----|----------------|----|------|------|
| Chaser | 25 | 8 | 10 | 1 | Standard swarm |
| Sprinter | 20 | 6 | 8 | 1 | Fast, fragile |
| Tank | 80 | 15 | 30 | 3 | Durable threat |

### Wave HP Budget

Formula: Expected total HP spawned per wave.

```
wave_hp_budget = duration × spawn_rate × avg_hp_per_enemy × spawn_multiplier
```

| Wave | Duration | Spawn Rate | HP Budget | Target Kills |
|------|----------|------------|-----------|--------------|
| 1 | 12s | 1.0/s | ~300 | ~12 chasers |
| 2 | 17s | 1.1/s | ~450 | ~15 mixed |
| 3 | 22s | 1.2/s | ~650 | ~18 mixed |

---

## Economy Model

### XP Economy

| Source | Amount | Notes |
|--------|--------|-------|
| Chaser kill | 10 XP | Base enemy |
| Sprinter kill | 8 XP | Fast but less XP |
| Tank kill | 30 XP | Elite reward |
| XP to Level 2 | 200 XP | Base requirement |
| XP to Level 3 | 250 XP | +50 per level |

Expected XP per wave (Wave 1): ~120 XP (12 kills × 10 XP)
Expected levels per run (5 waves): 3-4 levels

### Gold Economy

| Source | Amount | Notes |
|--------|--------|-------|
| Chaser kill | 1 gold | Base |
| Sprinter kill | 1 gold | Same base |
| Tank kill | 3 gold | Elite bonus |
| Luck bonus | +1% per luck | Diminishing returns |

Expected gold per wave (Wave 1): ~12 gold
Shop weapon offer cost range: 10-30 gold (early), 30-60 gold (late)

---

## Damage Pressure Model

### Player Survivability

| Metric | Base Value | Scaling |
|--------|------------|---------|
| Player HP | 100 | +20 per max_health upgrade |
| Contact damage taken | 8-15 | Per enemy type |
| I-frames after hit | 0.5s | Prevents chain damage |
| Health pickup heal | 25 | 15% drop chance on kill |

### Expected Damage Taken Per Wave

| Wave | Enemies | Hits Expected | Damage Range |
|------|---------|---------------|--------------|
| 1 | ~12 | 2-3 | 16-24 |
| 2 | ~15 | 3-4 | 20-35 |
| 3 | ~18 | 4-5 | 30-50 |

Target: Player should survive 3-4 waves without health upgrades on skilled play.

---

## Upgrade Impact

| Upgrade | Effect | DPS Impact | Survivability |
|---------|--------|------------|---------------|
| Sharpen (+20% dmg) | ×1.2 damage | +20% | None |
| Speed Up (+15% atk) | ×1.15 fire rate | +15% | None |
| Extra Pellet | +1 pellet | +25-100% | None |
| Max Health +20 | +20 HP | None | +20% |
| Armor +1 | -1 damage taken | None | +10-15% |
| Move Speed +8% | Faster dodge | Indirect | +avoidance |

---

## Character Balance Checklist

- [ ] Chef: Average stats, reliable knife starter
- [ ] Goblin: Fast, low HP, ranged pepper starter
- [ ] Onion: Tanky, orbit melee starter
- [ ] Cookie: Medium, knockback utility starter
- [ ] Mushroom: High burst damage, fragile
- [ ] Vampire: High lifesteal potential via damage
- [ ] Witch: Balanced, control via boomerang
- [ ] Dumpling: Area damage focus
- [ ] Snowman: Defensive, deployable backup

---

## Runtime Metrics to Track

Per wave, capture:
- Total kills (per enemy type)
- Total damage dealt (per weapon)
- Total damage taken
- Total XP collected
- Total gold earned
- Time to complete wave
- Player level at end

Compare actual vs. predicted to tune.

---

## Tuning Process

1. Run 5-wave test with each character
2. Record all metrics
3. Compare to targets in this document
4. Adjust weapon damage, fire rate, or enemy HP in 10% increments
5. Re-test and compare variance
6. Iterate until all characters feel viable
