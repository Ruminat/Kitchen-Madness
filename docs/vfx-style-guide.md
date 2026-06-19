# VFX style guide — Kitchen Madness

Lightweight 2D combat feedback for a crowded arena. Effects should read at a glance and fade cleanly.

## Principles

- Use `GPUParticles2D` with low `amount` (6–12), short `lifetime` (0.2–0.4s), and alpha fades on color ramps.
- One-shot bursts call `restart()` and return to a pool via the `finished` signal.
- Projectile trails use `local_coords = false` so streaks stay in world space behind fast shots.
- Tint from data: enemy `color` for death bursts, weapon `vfx_accent` for trails and impacts.

## Effect vocabulary

| Effect | Look | When |
|---|---|---|
| Death burst | Radial crumbs/smoke puff tinted to enemy color | `EventBus.enemy_killed` |
| Impact spark | Short directional spark along hit vector | `EventBus.projectile_hit` |
| Projectile trail | Faint streak behind moving shots | Child of projectile scenes |
| Hit flash | Brief red modulate on enemy sprite | Existing `BaseEnemy._flash_hit` |

## Weapon accents

| Weapon | Accent | Notes |
|---|---|---|
| Pepper grinder gun | Warm pepper gold | Default ranged trail |
| Boiling soup splash | Orange broth | Wider burst pellets |
| Onion ring blade | Pale green | Orbit blade hits |
| Kitchen knife | Cool silver | Fast stab spark |
| Frying pan | Iron gray | Heavy knockback hit |
| Garlic bomb | Pale violet puff | Radial burst |
| Ladle boomerang | Bronze | Return-path trail |
| Toaster turret | Hot orange | Deployed turret shots |

## Performance

- `VfxManager` pools up to 12 death and 12 impact particle nodes.
- Visibility rects keep off-screen particles culled.
- Avoid stacking more than one burst per enemy death; hide the enemy sprite immediately on kill.
