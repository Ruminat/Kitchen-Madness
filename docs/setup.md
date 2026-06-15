# Setup

## Prerequisites

- [Godot 4.6+](https://godotengine.org/download) (Standard build, not .NET)
- Git (optional, for version control)
- Cursor or VS Code for script editing

## Run the Game

1. Clone or download this repo.
2. Open Godot -> **Import** -> select the folder containing `project.godot`.
3. Press **F5** or click the Play button to run the main scene.

The game starts immediately. There is no main menu yet.

## Controls

| Input | Action |
|---|---|
| **WASD** / **Arrow keys** | Move |
| **W/S** or **Up/Down** | Navigate level-up / shop menus |
| **1-3** / **Enter** | Pick level-up upgrade |
| **1-8** / **Enter** | Buy in shop, Enter to continue |
| **R** or **Restart** | Restart after Game Over |

## Cursor + Godot

Use Cursor for scripts and Godot for scenes, playtesting, inspector work, import settings, and collision layers.

### Install Godot

Download Godot 4.6+ from [godotengine.org/download](https://godotengine.org/download).

On Windows, a typical install path is:

```text
C:\Users\<you>\AppData\Local\Programs\Godot\Godot_v4.x.exe
```

Add Godot to your PATH, or note the full path for Cursor.

### Install the Godot Extension in Cursor

1. Open this project folder in Cursor.
2. Open Extensions (`Ctrl+Shift+X`).
3. Search for **Godot Tools** by georgewfraser and install it.
4. Reload Cursor if prompted.

This gives you GDScript syntax highlighting, snippets, and scene/script navigation.

### Point Cursor at Godot

Create `.vscode/settings.json` locally. This folder is gitignored and should stay local:

```json
{
  "godotTools.editorPath.godot4": "C:/path/to/Godot_v4.6.exe"
}
```

Or set `"godot4"` if Godot is on your PATH.

In Godot, you can also set **Editor -> Editor Settings -> DotNet / External Tools** so double-clicking scripts opens Cursor.

## Daily Workflow

Edit `.gd` files in Cursor, switch to Godot for scene work and playtesting, then press **F5** for a smoke test.
