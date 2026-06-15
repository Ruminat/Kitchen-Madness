# Kitchen Madness

A top-down arena survivor roguelite built in **Godot 4** with **GDScript**. Fight through kitchen-themed waves, collect upgrades, spend gold between rounds, and survive the madness.

Genre kin to games like [Brotato](https://store.steampowered.com/app/1942280/Brotato/) — original project, own art and mechanics, targeting eventual cross-platform / Steam release.

**Current status:** Phase 3A complete (gold, shop, multi-wave loop, 8-stat upgrades). See [progress.md](progress.md) and [context.md](context.md).

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
| **W/S** or **↑/↓** | Navigate level-up / shop menus |
| **1–3** / **Enter** | Pick level-up upgrade |
| **1–8** / **Enter** | Buy in shop · Enter to continue |
| **R** or **Restart** | Restart after Game Over |

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

Create `.vscode/settings.json` locally (this folder is **gitignored** — never commit it):

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

### Run tests

Requires Godot 4.5+ on PATH (same binary used for F5):

```powershell
# Full check (lint + boot + tests)
.\tools\codecheck.ps1

# Tests only
godot --headless --path . -s --remote-debug tcp://127.0.0.1:0 res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a tests/ --ignoreHeadlessMode
```

Test suites live in `tests/unit/` (logic) and `tests/integration/` (scene boot + pause-on-end).

### Git hooks (master branch)

Install once after clone — runs `codecheck` before each commit on `master`:

```powershell
.\tools\install-git-hooks.ps1
```

On other branches the hook is skipped.

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
- **Never commit** `.vscode/` — local editor settings only.

---

## Roadmap

See [plans.md](plans.md) for the full development plan (Phases 2A–3A complete; wave scaling and art pass next).

---

## License

Not set yet — solo indie project.
