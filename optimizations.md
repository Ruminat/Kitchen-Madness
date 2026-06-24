# Kitchen Madness - optimization decisions

Performance is a game-feel feature. Kitchen Madness should support dense swarms, readable VFX, and future lightweight animations without making low-end devices melt.

## Current priorities

1. Profile first, then optimize the hottest path. Godot's CPU profiler and manual `Time.get_ticks_usec()` timing should guide future work before large rewrites.
2. Keep enemy count authored, not accidentally multiplied. Wave resources own `max_enemies`; systems may apply the documented wave density multiplier, but should not secretly triple caps again.
3. Simulate enemies at two detail levels. Enemies near the camera keep full `CharacterBody2D` collision and visuals. Far off-screen enemies keep chasing the player with cheap movement, no rendering, and no physics collision participation until they approach the camera again.
4. Cache per-enemy target references. Swarm-scale code must avoid scene-tree lookups inside every enemy's physics tick.
5. Keep sprites batch-friendly. Reuse the same enemy textures/materials, avoid per-enemy unique materials, and cap imported enemy sprite size to the largest size actually needed on screen.
6. Budget particles. Death bursts, impacts, and projectile trails should stay punchy, but VFX managers must skip off-screen effects, reuse particle nodes/materials, and cap bursts per frame.
7. Expose render scale. The settings UI should let players choose native, balanced, performance, or potato render scale. Default stays native unless we later decide onboarding should auto-detect hardware.
8. Leave room for animation. Basic sprite animations are allowed, but animated enemies should still share spritesheets/materials and respect off-screen detail culling.

## Godot-specific guidance used

- Godot's performance docs recommend finding bottlenecks with the built-in profiler before optimizing broadly.
- Godot's 2D renderer batches similar items, so repeated sprites/material reuse matters more than unique per-instance materials.
- Large transparent 2D quads still draw their transparent pixels; enemy source sprites should avoid oversized transparent padding and import at practical runtime size.
- `GPUParticles2D` is preferred for most particles, but low-end or GPU-bound devices can struggle with excessive particle counts, so gameplay VFX should be pooled and budgeted.
- Viewport stretch scale can reduce internal render resolution at runtime, which makes it a good user-facing low-end performance option.

## Future optimization backlog

- Add an in-game profiler overlay for active enemies, full-detail enemies, projectiles, particles spawned/skipped, and frame time.
- Pool enemies and projectiles if instantiation spikes show up in profiling.
- Convert very large mostly-transparent decorative 2D sprites to meshes, but avoid doing this for tiny enemy sprites unless profiling proves overdraw is significant.
- Add quality presets that also control particles and projectile trails, not just render scale.
- Consider server-level rendering or a data-oriented enemy swarm path only if the current node-based enemy architecture becomes the confirmed bottleneck.
