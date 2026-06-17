# Hitbox guide — complex player sprites

How to handle collision and damage for characters whose **visual silhouette** does not match a simple circle or rectangle.

---

## Core idea: separate visuals from gameplay

Players read the **sprite**. The game runs on **hitboxes**.

Those two shapes should be related but not identical. A tall hat, wide frying pan, or flowing cape are cosmetic; the hurtbox should usually track the **body** (torso + feet), not every pixel of the art.

This project already follows that split:

| Layer | What it does | Chef today |
|---|---|---|
| **Visual** | `Visual/Sprite` in `player.tscn` — rotates, flickers on i-frames | 256×256 roster sprite, scaled down |
| **Wall collision** | `CollisionShape2D` circle, radius 14 | Same circle as before |
| **Contact damage** | Distance check in `player.gd` using `BODY_RADIUS` (14) | Same circle as before |

Nothing in gameplay needs to match decorative parts that extend beyond the body.

---

## Why complex sprites are awkward

Some player silhouettes have parts that fight a one-size-fits-all box:

```
        ┌─────────────┐
        │  chef hat   │  ← tall, wider than body; empty air inside
        └──────┬──────┘
           ┌───┴───┐
           │ torso │      ┌──────────┐
           └───┬───┘      │ frying   │  ← weapon reach, not “body”
               │          │   pan    │
             ┌─┴─┐        └──────────┘
             │feet│
             └────┘
```

| Region | Gameplay question |
|---|---|
| **Hat** | Should enemies damage you if they touch the fluffy top? Usually **no** — feels unfair when the hat is mostly empty space. |
| **Torso / feet** | Should enemies damage you here? **Yes** — this is the character. |
| **Frying pan** | Should enemies damage you if they only touch the pan? Usually **no** for the player hurtbox. Later, the pan could be its **own attack hitbox** (melee swipe). |

---

## Options (simple → complex)

### 1. Circle hurtbox on the body (recommended for now)

**What:** Keep `BODY_RADIUS = 14` centered on the feet/torso. Sprite can be larger and offset so feet sit on the node origin.

**Pros:** Matches current code (`player.gd`, `ArenaClamp`, enemy contact checks). Fast, predictable, easy to tune. Same approach many top-down arena survivors use for simple blob characters.

**Cons:** Hat and pan stick out past the circle — purely visual; no gameplay effect.

**When to use:** First real sprite swap, survivor-likes, anything with fast enemies and distance-based contact damage.

**Tuning the player sprite:**

- Pivot the sprite so **feet / shadow** align with the `Player` node `(0, 0)` — done via `Sprite2D.offset`.
- Scale so the **torso** is roughly 28–32 px wide (≈ `2 × BODY_RADIUS`), even if the hat and pan extend further.
- Enable **Visible Collision Shapes** in Godot (Debug menu) and run F5 to confirm the green circle sits on the belly/feet, not on the hat or pan.

---

### 2. Capsule or rounded rectangle (body only)

**What:** Replace the circle with a `CapsuleShape2D` or small `RectangleShape2D` that covers torso height but not hat width.

**Pros:** Slightly more accurate for tall humanoid sprites. Still cheap to test (one shape).

**Cons:** Requires updating `BODY_RADIUS` usage — today it is a single radius constant used for arena clamp, contact damage, and possibly tests. You would introduce something like `BODY_HALF_WIDTH` / `BODY_HALF_HEIGHT` or a shared `get_hurtbox_radius()` helper.

**When to use:** When a circle feels too wide (tank enemies) or too short (tall characters) after playtesting.

---

### 3. Compound hurtbox (multiple shapes)

**What:** Several `CollisionShape2D` or `Area2D` children — e.g. circle for torso, smaller circle for head. All count as “player hurt.”

**Pros:** Closer to the art for characters with a clear head + body.

**Cons:** Contact damage in `player.gd` is **distance-to-point**, not shape overlap. You would need to refactor to `Area2D` overlap or test distance to multiple sample points. More work, more edge cases.

**When to use:** Fighting games, precise action games — usually overkill for a horde survivor.

---

### 4. Separate hurtbox vs weapon hitbox (frying pan)

**What:** Two independent regions on the same character:

```
Player (CharacterBody2D)
  HurtboxArea (Area2D)     ← player can take damage
  PanHitbox (Area2D)       ← optional; damages enemies only
  Visual/Sprite
```

**Pros:** Pan can smack enemies without making the player easier to hit. Matches the fantasy of “holding a weapon out.”

**Cons:** Two systems to maintain; pan rotates with `Visual`, so the weapon box spins too (often desirable, but needs thought).

**When to use:** Melee-focused characters, chef melee upgrades, slap-stick pan attacks.

**Not needed yet** — the player still uses pistol / shotgun / orbit blades from `WeaponController`.

---

### 5. Pixel-perfect / polygon hitbox

**What:** `ConvexPolygonShape2D` or `CollisionPolygon2D` traced from the sprite outline.

**Pros:** Matches art exactly.

**Cons:** Expensive to author, breaks when art changes, feels unfair in fast horde combat (hat brim snags enemies), rotation makes polygons harder to reason about.

**When to use:** Rarely in survivor-likes. Better for slow tactical games or static obstacles.

---

## Recommendation for this project

| Decision | Choice |
|---|---|
| **Player hurtbox** | Keep **circle, radius 14**, centered on body/feet |
| **Sprite** | Full player art; scale + offset so body/feet sit near node origin |
| **Hat / pan** | **Cosmetic only** until playtesting says otherwise |
| **Contact damage** | Keep distance check in `player.gd` — do **not** switch to `Area2D body_entered` (phantom hits were a known bug; see `context.md`) |
| **Future pan melee** | Add a separate `Area2D` attack box on the pan, not expand the hurtbox |

---

## Practical workflow in Godot

1. **Drop in sprite** under `Visual` (keep that node name — `player.gd` rotates and modulates it).
2. **Set pivot** — `Sprite2D.offset` so feet sit on `(0, 0)`.
3. **Scale** — torso width ≈ `2 ×` collision radius; hat and pan may extend past.
4. **Debug draw** — Debug → Visible Collision Shapes; verify circle vs sprite.
5. **Playtest** — if hits feel early/late, nudge **radius** (gameplay), not the art (visual).
6. **Art pass** — export PNG with **transparent** background so oversized source canvases do not show as squares in-game.

### If contact feels wrong after swapping art

| Symptom | Fix |
|---|---|
| Enemies hit before they touch the body | **Shrink** `BODY_RADIUS` (gameplay), not the sprite |
| Enemies pass through the body | **Grow** `BODY_RADIUS` slightly |
| Player clips arena walls too early | `BODY_RADIUS` is used in `ArenaClamp` — same constant |
| Hat seems to block bullets | Bullets use their own collision; hat is visual-only unless you add a `StaticBody2D` (don’t) |

---

## Enemies use the same rule

Enemies still use `circle_visual.gd` placeholders with per-type radius in their scenes. When you replace them with sprites:

- Match **sprite scale** to `get_collision_radius()` in `base_enemy.gd`.
- Tint / flash still goes through `Visual.modulate` — same pattern as the player.

---

## Summary

For Chef and most survivor-style characters: **draw the whole character, collide with a small circle on the body.** Defer compound shapes and weapon boxes until a feature needs them. Tune fairness with `BODY_RADIUS`, not by chasing the outer pixels of hats, weapons, antennas, or accessories.
