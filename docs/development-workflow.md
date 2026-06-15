# Development Workflow

## Code Checks

Run the full project check before handoff:

```powershell
.\tools\codecheck.ps1
```

This script runs optional GDScript lint/format checks when `gdtoolkit` is installed, boots Godot headless, and runs the GdUnit test suite.

Install optional GDScript tooling with:

```bash
pip install gdtoolkit
```

## Tests

Tests require Godot 4.5+ on PATH.

```powershell
godot --headless --path . -s --remote-debug tcp://127.0.0.1:0 res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a tests/ --ignoreHeadlessMode
```

Test suites live in `tests/unit/` for logic and `tests/integration/` for scene boot and pause-on-end checks.

## Visual Screenshots

For larger visual/gameplay iterations, generate Playwright-style screenshots from the real Godot game scene:

```powershell
.\tools\capture-visuals.ps1
```

The command writes PNGs to `visual-tests/screenshots/`:

- `player_surrounded.png`
- `upgrade_menu.png`
- `dead_screen.png`

Use this if you want to compare progress after large changes to `plans.md` or gameplay visuals.

You can also try the same capture flow without opening a game window:

```powershell
.\tools\capture-visuals.ps1 -Headless
```

## Git Hooks

Install once after clone:

```powershell
.\tools\install-git-hooks.ps1
```

The hook runs `codecheck` before each commit on `master`. On other branches the hook is skipped.
