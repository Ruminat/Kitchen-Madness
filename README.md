# Brotato Clone

A lightweight top-down arena survivor roguelite built in **Godot 4** with **GDScript**. Survive waves of enemies, auto-attack with weapons, and stay inside the arena.

Inspired by [Brotato](https://store.steampowered.com/app/1942280/Brotato/) (also made in Godot), but this is an original project — placeholder art, incremental features, eventual cross-platform / Steam release.

**Current status:** Phase 2A foundation complete; Phase 2B in progress — 3 enemy types, data-driven weapons/waves. See [progress.md](progress.md).

---

## Getting started

### Prerequisites

- [Godot 4.6+](https://godotengine.org/download) (Standard build, not .NET)
- Git (optional, for version control)

### Run the game

1. Clone or download this repo.
2. Open Godot → **Import** → select the folder containing `project.godot`.
3. Press **F5** (or click the Play button) to run the main scene.

That's it — the game starts immediately (no main menu yet).

### Controls

| Input | Action |
|---|---|
| **WASD** / **Arrow keys** | Move |
| **R** or **Restart** button | Restart after Game Over or Wave Complete |

---

## Cursor + Godot setup

Use [Cursor](https://cursor.com/) (or VS Code) for editing scripts and vibe-coding with AI, and Godot for scenes, playtesting, and the inspector.

### 1. Install Godot

Download Godot 4.6+ from [godotengine.org/download](https://godotengine.org/download).

On Windows, a typical install path is:

```
C:\Users\<you>\AppData\Local\Programs\Godot\Godot_v4.x.exe
```

Add Godot to your PATH, or note the full path for the next step.

### 2. Install the Godot extension in Cursor

1. Open this project folder in Cursor.
2. Open Extensions (`Ctrl+Shift+X`).
3. Search for **Godot Tools** (by georgewfraser) and install it.
4. Reload Cursor if prompted.

This gives you GDScript syntax highlighting, `@onready` / signal snippets, and scene/script navigation.

### 3. Point Cursor at your Godot binary

This repo includes `.vscode/settings.json`. Update the Godot path if needed:

```json
{
  "godotTools.editorPath.godot4": "C:/path/to/Godot_v4.6.exe"
}
```

Or set `"godot4"` if Godot is on your PATH.

**Tip:** In the Godot editor, go to **Editor → Editor Settings → DotNet / External Tools** and set **External Editor** to Cursor/VS Code if you want double-clicking a script in Godot to open it in Cursor.

### 4. Open the project in Godot (for scenes & playtest)

Cursor is great for scripts; Godot is still required for:

- Editing `.tscn` scene files visually
- Running the game (**F5**)
- Inspector, signals, and collision layers

Workflow: edit `.gd` files in Cursor → switch to Godot → **F5** to playtest.

### 5. Optional: lint & format GDScript from the terminal

For stricter code quality (planned in Phase 2 — see [plans.md](plans.md)):

```bash
pip install gdtoolkit
gdlint scripts/
gdformat scripts/
```

---

## Project layout

```
scenes/
  main/game.tscn       Main scene (arena, spawner, wave logic)
  player/              Player + weapon
  enemy/               Enemy
  weapons/             Auto-attack weapons
  projectiles/         Projectiles
  ui/                  HUD and overlays
scripts/               GDScript for all of the above
context.md             Agent/dev context and iteration rules
plans.md               Roadmap for Phase 2+
```

---

## Version control notes

- **Commit** `.uid` files alongside scripts — Godot 4.4+ uses them for stable resource references.
- **Ignore** `.godot/` — editor cache (already in `.gitignore`).

---

## Roadmap

See [plans.md](plans.md) for the full development plan:

- Phase 2A: Architecture refactor (EventBus, components, data-driven content)
- Phase 2B: Multiple enemies, weapons, and drops
- Phase 2C: UI polish (damage numbers, XP bar, etc.)
- Phase 2D: XP and level-ups
- Phase 2E: Tests and `codecheck` command

---

## License

Not set yet — solo indie project.
