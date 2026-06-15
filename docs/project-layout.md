# Project Layout

## Main Folders

```text
scenes/
  main/game.tscn       Main scene: arena, player, spawner, wave logic
  arena/               Arena bounds, floor, walls, background
  player/              Player scene and weapon controller
  enemy/               Enemy scenes
  projectiles/         Projectile scenes
  pickups/             XP and health pickup scenes
  ui/                  HUD and overlays
scripts/
  autoload/            Global event bus and startup helpers
  components/          Shared health, clamp, health-bar logic
  data/                Resource definitions
  enemies/             Enemy behavior scripts
  pickups/             Pickup logic
  systems/             Wave, spawn, XP, gold, shop, level-up systems
  ui/                  HUD formatting and UI helpers
  weapons/             Weapon controller and weapon behavior
resources/
  enemies/             Enemy definitions and spawn entries
  drops/               Drop definitions
  upgrades/            Upgrade definitions
  waves/               Wave definitions
tools/                 Codecheck, screenshot capture, sprite tools
tests/                 GdUnit unit and integration tests
visual-tests/          Generated visual regression screenshots
```

## Key Files

- `context.md` - current project state and iteration rules for AI/dev handoff
- `plans.md` - roadmap and phase plan
- `progress.md` - implementation progress log
- `project.godot` - Godot project configuration

## Version Control Notes

- Commit `.uid` files alongside scripts. Godot 4.4+ uses them for stable resource references.
- Commit generated `visual-tests/screenshots/*.png` when you want visual progress snapshots in history.
- Ignore `.godot/`; it is editor cache.
- Never commit `.vscode/`; local editor settings only.
