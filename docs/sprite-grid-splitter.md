# Sprite Grid Splitter

Use `tools/split_grid_sprites.gd` to turn generated character sheets into centered individual PNG sprites.

The splitter works in two steps:

1. Cut the source image into a grid.
2. For each cell, flood-fill the edge-connected background, crop the remaining character pixels, scale them to fit the requested output size, and paste them centered on a transparent canvas.

Because the background removal starts from the cell edges, black/dark details inside a character are preserved instead of being erased just because they are close to the background color.

## Basic Usage

From the project root:

```powershell
godot --headless --path . -s res://tools/split_grid_sprites.gd -- --input "C:\path\to\players.png" --output-dir "assets\characters\player_candidates" --grid 3x3 --output-size 256x256 --padding 18
```

For a non-square sheet, use any grid size:

```powershell
godot --headless --path . -s res://tools/split_grid_sprites.gd -- --input "C:\path\to\enemies.png" --output-dir "assets\characters\enemy_candidates" --grid 4x2 --pattern "{stem}_r{row}_c{col}.png"
```

## Useful Options

- `--grid CxR`: Grid columns and rows, for example `3x3`.
- `--output-size WxH`: Final sprite canvas size. A single number like `256` means `256x256`.
- `--padding N`: Empty pixels around the centered character after scaling.
- `--pattern PATTERN`: Output file naming. Tokens are `{stem}`, `{index}`, `{index0}`, `{row}`, `{row0}`, `{col}`, `{col0}`.
- `--names CSV`: Optional comma-separated names in grid order. Use with `{name}` in `--pattern`.
- `--background-color #RRGGBB`: Override automatic corner sampling. Useful when cell corners contain noise.
- `--background-tolerance N`: Increase if background remnants remain; decrease if outlines get eaten. Start around `0.05` to `0.12`.
- `--keep-background`: Keep each cell background instead of exporting transparency.
- `--no-upscale`: Keep small characters at original scale.

## Suggested Workflow

1. Generate a grid with clear spacing between characters.
2. Split once with `--background-tolerance 0.08`.
3. Inspect the output folder.
4. If black edges remain, raise tolerance slightly.
5. If outlines disappear, lower tolerance or regenerate with more spacing.
6. Move the best PNGs into `assets/characters/player/` or `assets/characters/enemies/` and let Godot create `.import` sidecars.

For named player rosters:

```powershell
godot --headless --path . -s res://tools/split_grid_sprites.gd -- --input "C:\path\to\players.png" --output-dir "assets\characters\player" --grid 3x3 --output-size 256x256 --padding 18 --names "milo,nova,sprout,pickle,brutus,thorn,stitch,granite,rusty" --pattern "{name}.png"
```
