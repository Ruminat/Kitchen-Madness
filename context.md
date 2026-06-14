# Project context

## Iteration rule

**Make sure there are no errors before finishing an iteration.**

Before considering a task done, verify the project runs cleanly:

- Fix all parser errors, script errors, and scene load failures
- Press **F5** in Godot (or run the main scene) and confirm the game starts without errors
- Do not hand off broken builds — resolve blockers in the same iteration when possible

## Game overview

Brotato-style top-down arena survivor roguelite in **Godot 4** (GDScript).

- **Phase 1:** Basic playable prototype (arena, player, enemies, auto-attack, wave timer, win/lose)
- **Long-term:** Cross-platform (Windows/macOS), lightweight, incremental features, eventual Steam

## Main scene

`res://scenes/main/game.tscn` (set in `project.godot`)

## Structure

```
scenes/
  main/game.tscn
  player/player.tscn
  enemy/enemy.tscn
  weapons/projectile_weapon.tscn
  projectiles/projectile.tscn
  ui/game_ui.tscn
scripts/
  game.gd, player.gd, enemy.gd, projectile_weapon.gd, projectile.gd, game_ui.gd, circle_visual.gd
```

## Controls

| Input | Action |
|---|---|
| WASD / Arrow keys | Move |
| R or Restart button | Restart after Game Over or Wave Complete |

## Not in scope yet

Shop, XP/level-ups, multiple weapons, character select, main menu, Steam, sound/music.
