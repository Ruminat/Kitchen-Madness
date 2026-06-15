# Adding Visuals

This guide explains how to replace the current placeholder art (colored circles and rectangles) with real sprites, backgrounds, and weapon graphics in this Godot 4 project.

---

## Current visual system

The game uses a minimal placeholder setup so gameplay can be built first:

| Element | Scene | How it looks today |
|---|---|---|
| **Arena** | `scenes/arena/arena.tscn` | `ColorRect` nodes for background, floor, and walls |
| **Player** | `scenes/player/player.tscn` | Green circle via `scripts/circle_visual.gd` |
| **Enemies** | `scenes/enemy/*.tscn` | Colored circles; size/color set per enemy type |
| **Projectiles** | `scenes/projectiles/projectile.tscn` | Small yellow circle |
| **Guns** | (none yet) | Weapons are invisible logic nodes on the player |

Every character and projectile has a child node named **`Visual`**. Gameplay scripts reference it for rotation, hit flashes, and invincibility effects:

- `scripts/player.gd` — rotates `Visual` with movement, flashes alpha when invincible
- `scripts/enemies/base_enemy.gd` — rotates `Visual` toward movement, flashes red on hit
- `scripts/projectile.gd` — rotates with fire direction

**Keep the node named `Visual`** when swapping to sprites so existing code keeps working.

---

## Recommended asset folder layout

Create an `assets/` folder at the project root (Godot will auto-import anything inside `res://`):

```
assets/
  backgrounds/
    arena_floor.png          # 880×480 or tileable texture
    arena_walls.png          # optional wall strip / border art
  characters/
    player/
      player_idle.png        # 32×32 or 64×64
      player_walk.png        # optional sprite sheet
    enemies/
      chaser.png
      tank.png
      sprinter.png
  weapons/
    pistol.png
    shotgun.png
    orbit_blade.png
  projectiles/
    bullet.png
    pellet.png
  vfx/
    hit_flash.png            # optional
    muzzle_flash.png         # optional
```

Commit image files and their `.import` sidecars (Godot generates these on first import). Do **not** commit `.godot/` (already gitignored).

---

## Art specs (top-down survivor style)

These numbers match the current arena and collision sizes:

| Asset | Suggested size | Notes |
|---|---|---|
| Arena background | **880 × 480** px (or tileable) | Matches `Arena.arena_size` in `scripts/arena.gd` |
| Player sprite | **28–32** px wide | Collision radius is 14 |
| Chaser enemy | **24** px | Radius 12 |
| Tank enemy | **36** px | Radius 18 |
| Sprinter enemy | **18** px | Radius 9 |
| Bullet | **8–12** px | Collision radius 5 |
| Gun overlay | **16–24** px | Sits on player, points at target |

**Style tips:**

- Top-down view — draw characters as if seen from above (simple blob/silhouette shapes work well for arena survivors).
- Use a limited palette (8–16 colors) so everything feels cohesive.
- Leave a little transparent padding around sprites so rotation does not clip corners.
- Pixel art: set import **Filter** to **Nearest** (see below).

---

## Godot import settings (2D sprites)

After dropping PNG/WebP files into `assets/`:

1. Select the image in Godot's **FileSystem** dock.
2. In the **Import** tab:
   - **Compress → Mode:** `Lossless` (pixel art) or `VRAM Compressed` (larger painted art)
   - **Process → Filter:** `Off` for pixel art, `On` for smooth painted art
   - **Process → Mipmaps:** `Off` for 2D UI/game sprites
3. Click **Reimport**.

For sprite sheets, set **Region** slicing in an `AtlasTexture` or use `AnimatedSprite2D` frames.

---

## Step 1 — Replace the player circle with a sprite

### In the Godot editor

1. Open `scenes/player/player.tscn`.
2. Select the **Visual** node (currently a `Node2D` with `circle_visual.gd`).
3. **Remove** the `circle_visual.gd` script from Visual.
4. Add a **Sprite2D** as a child of Visual (or replace Visual's type):
   - Rename the sprite child to something like `Sprite` if you keep Visual as a wrapper `Node2D`.
   - Set **Texture** to your player image.
   - Set **Offset** so the sprite center matches the character center (usually `(0, 0)` if art is centered).
5. Press **F5** — the player should still move and rotate.

### Why keep the Visual wrapper?

`player.gd` does `$Visual` rotation and modulate. A structure like this works well:

```
Player (CharacterBody2D)
  Visual (Node2D)          ← scripts target this
    Sprite (Sprite2D)      ← actual artwork
  CollisionShape2D
  ...
```

Rotation on `Visual` spins the whole sprite. Invincibility flicker (`modulate.a`) still applies.

### Optional: swap circle_visual for a reusable sprite script

If you want data-driven textures later, you can extend or replace `circle_visual.gd` with a small script that sets a `Sprite2D` texture instead of drawing a circle. The existing `set_color()` hook in `base_enemy.gd` can tint sprites via `modulate` instead.

---

## Step 2 — Add enemy sprites

Enemies come in three scenes, each with its own `.tres` definition:

| Enemy | Scene | Definition |
|---|---|---|
| Chaser | `scenes/enemy/enemy.tscn` | `resources/enemies/chaser.tres` |
| Tank | `scenes/enemy/tank_enemy.tscn` | `resources/enemies/tank.tres` |
| Sprinter | `scenes/enemy/sprinter_enemy.tscn` | `resources/enemies/sprinter.tres` |

### Per-enemy scene (simplest)

For each enemy scene:

1. Open the scene (e.g. `tank_enemy.tscn`).
2. Under **Visual**, remove `circle_visual.gd` and add a **Sprite2D** with the matching texture.
3. Scale the sprite so it roughly matches the `CircleShape2D` radius (double the radius ≈ diameter).
4. Run the game — spawner uses definitions that point at these scenes.

### Data-driven tinting (optional)

`EnemyDefinition` already has `color` and `radius` fields (`scripts/data/enemy_definition.gd`). `base_enemy.gd` applies them in `_apply_visual()`:

- **Circle mode:** changes fill color and redraws.
- **Sprite mode:** use `visual.modulate = enemy_definition.color` for a tint, or ignore `color` if each enemy has unique art.

To drive **which texture** from data, add a field to `EnemyDefinition`:

```gdscript
@export var texture: Texture2D
```

Then in `_apply_visual()`, assign it to the child `Sprite2D`. That lets you add new enemy types without new scenes — only a new `.tres` file.

---

## Step 3 — Projectile sprites

1. Open `scenes/projectiles/projectile.tscn`.
2. Replace the circle under **Visual** with a **Sprite2D** (bullet texture).
3. `projectile.gd` already sets `rotation` from fire direction — bullets will point the right way.

For shotgun pellets, duplicate the scene as `pellet.tscn` with a smaller sprite and reference it from a new `WeaponDefinition`.

---

## Step 4 — Arena backgrounds

Open `scenes/arena/arena.tscn`. The play area is **880 × 480**, centered at `(0, 0)`.

### Option A — Single background image (easiest)

1. Delete or hide the **FloorGrid** `ColorRect` (optional flat overlay).
2. Select **Background** `ColorRect` → change type to **Sprite2D** (or add a `Sprite2D` sibling):
   - Texture: your floor art (880×480).
   - Position `(0, 0)`, centered.
3. Keep **Walls** collision as-is — only swap wall `ColorRect` visuals for wall textures if you want.

### Option B — Tileable floor (more flexible)

1. Add a **TileMapLayer** (Godot 4) or **TileMap** node under Arena.
2. Paint a repeating floor with a tileset from a tile sheet.
3. Hide the old `ColorRect` backgrounds.

### Option C — Parallax layers (coolest)

For depth (distant ruins, fog, stars):

1. Add a **ParallaxBackground** as a child of Arena (or Game).
2. Add **ParallaxLayer** children with different **Motion Scale** values (e.g. `0.2` for far, `0.5` for mid).
3. Put **Sprite2D** or **ColorRect** textures on each layer.

Walls should stay aligned with `get_bounds()` from `scripts/arena.gd` — background art is cosmetic; collision sizes in the scene define gameplay bounds.

---

## Step 5 — Gun / weapon visuals

Weapons are currently invisible `Node2D` nodes created by `WeaponController` (`scripts/weapons/weapon_controller.gd`). There is no gun graphic yet — adding one is optional but makes combat feel much better.

### Simple approach: one gun sprite on the player

1. In `player.tscn`, add under **WeaponController** (or Visual):
   ```
   WeaponController (Node2D)
     GunSprite (Sprite2D)
   ```
2. Assign `pistol.png` to **GunSprite**.
3. Position the sprite so it looks like it is held to the side (e.g. offset `(8, 0)`).
4. In `projectile_weapon.gd` inside `_fire_at()`, after computing `direction`, rotate the gun:
   ```gdscript
   rotation = direction.angle()
   ```
   `WeaponController` is already a `Node2D`, so rotating it points the gun at the nearest enemy.

### Multiple weapons, different looks

- Add `@export var sprite: Texture2D` to `WeaponDefinition` (`scripts/data/weapon_definition.gd`).
- When `add_weapon()` runs, spawn a child `Sprite2D` on that weapon node and set its texture from the definition.
- Pistol, shotgun, and orbit blade can each have distinct art without new player scenes.

### Orbit blade

For melee-style orbit weapons, add 2–4 small blade sprites as children of the weapon node and rotate them in `_process()` around the player — no projectile texture needed.

---

## Step 6 — Animation (optional)

Static sprites are enough for a first pass. When you want walk cycles or idle bob:

1. Replace **Sprite2D** with **AnimatedSprite2D**.
2. Create a **SpriteFrames** resource (`*.tres`) with your animation frames.
3. In `player.gd` `_physics_process`, play `"walk"` when `input_dir.length_squared() > 0.01`, else `"idle"`.

Enemies can use a single frame plus rotation (already handled) or a simple 2-frame wobble animation.

---

## Effects already wired up (don't break these)

| Effect | Where | What it uses |
|---|---|---|
| Face movement direction | `player.gd`, `base_enemy.gd` | `visual.rotation` |
| Invincibility blink | `player.gd` | `visual.modulate.a` |
| Hit flash | `base_enemy.gd` | `visual.modulate` briefly red |
| Bullet direction | `projectile.gd` | root `rotation` |

All of these work on **any** `CanvasItem` under `Visual` (Sprite2D, AnimatedSprite2D, etc.) because modulate and rotation inherit to children.

---

## Quick checklist

- [ ] Create `assets/` folders and add PNG/WebP art
- [ ] Configure import settings (Nearest filter for pixel art)
- [ ] Player: `Sprite2D` under `Visual` in `player.tscn`
- [ ] Enemies: per-scene sprites in `scenes/enemy/*.tscn`
- [ ] Projectiles: sprite in `projectile.tscn`
- [ ] Arena: `Sprite2D` or `TileMap` in `arena.tscn`
- [ ] Guns: `Sprite2D` on `WeaponController`, rotate toward target
- [ ] **F5** — no errors, gameplay unchanged
- [ ] Run `./tools/codecheck.ps1` — scripts still pass lint/format

---

## Where to get art

Free/CC0-friendly starting points:

- [Kenney](https://kenney.nl/assets) — top-down packs, bullets, tiles
- [OpenGameArt.org](https://opengameart.org/) — search "top down shooter"
- [itch.io](https://itch.io/game-assets/free) — many pixel survivor asset packs

For a unique look, sketch simple shapes in [Aseprite](https://www.aseprite.org/), [LibreSprite](https://libresprite.github.io/), or [Piskel](https://www.piskelapp.com/) (free, browser-based).

---

## Troubleshooting

| Problem | Likely cause | Fix |
|---|---|---|
| Sprite off-center when rotating | Art pivot not centered | Re-export with centered canvas, or adjust Sprite2D **Offset** |
| Blurry pixel art | Linear filtering | Import → Filter → Off (Nearest) |
| Hit flash does nothing | Modulate on wrong node | Ensure `Visual` is the node referenced in scripts |
| Enemy wrong size | Sprite not scaled to radius | Match sprite width ≈ `2 ×` collision radius |
| Background doesn't fill arena | Wrong dimensions | Use 880×480 or scale sprite to `arena_size` |
| Gun doesn't point at enemies | Weapon node not rotated | Set `rotation` in `_fire_at()` on the weapon `Node2D` |

---

## Next steps

Once static art is in place, consider:

- **Muzzle flash** — short-lived `Sprite2D` spawned in `_fire_at()`
- **Death particles** — GPUParticles2D or a few fading sprites in `base_enemy.gd` on `died`
- **Screen shake** — small `Camera2D` offset on player hit
- **UI theme** — style `scenes/ui/game_ui.tscn` to match the arena palette

The gameplay systems (health, waves, weapons, spawning) do not need changes for a visual upgrade — only scenes and optional texture fields on data resources.
