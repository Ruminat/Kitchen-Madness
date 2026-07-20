# Game Art Generation Guide

## Goal

This project uses AI-generated art as a starting point for game assets.

The goal is not to blindly use raw AI output.

The goal is to create clean, readable, consistent, production-ready 2D assets for **Kitchen Madness**.

The biggest risks are:

* fake transparent backgrounds
* blurry small details
* inconsistent style
* inconsistent scale
* bad sprite isolation
* artifacts around silhouettes
* low-quality output from large asset grids

## Core Art Direction

Kitchen Madness is a top-down roguelite arena survivor inspired by **Brotato** and **Vampire Survivors**.

The art should feel:

* weird
* funny
* kitchen-themed
* slightly gritty
* readable at small scale
* not childish
* not horror
* not realistic

Use:

* flat 2D rendering
* compact silhouettes
* thin dark outlines
* medium saturation
* slightly dirty colors
* minimal shading
* clear shapes

Avoid:

* realistic rendering
* detailed painterly illustrations
* cute mascot style
* horror gore
* visual noise
* overcomplicated designs

## Important Rule

Do not treat AI-generated images as final assets automatically.

Every generated asset should go through validation and cleanup before being imported into the game.

## Do Not Generate Production Assets as Grids

Large grids are useful for brainstorming only.

They are bad for final production assets.

Avoid using 3×3 grids for final sprites because they usually cause:

* lower detail per asset
* inconsistent spacing
* inconsistent scale
* mixed quality
* worse silhouettes
* more background artifacts
* harder extraction
* worse transparency
* less control over each asset

Use grids only for:

* mood exploration
* roster ideas
* comparing concepts
* early visual direction

For final assets, generate **one asset at a time**.

## Recommended Workflow

Use this pipeline:

1. Generate rough concepts in batches.
2. Pick the best designs.
3. Regenerate selected assets individually.
4. Use a controlled background.
5. Remove background with a script.
6. Clean edges.
7. Crop and pad consistently.
8. Downscale and inspect at gameplay size.
9. Save as production PNG.
10. Register the asset in the project.

## Best Background Strategy

AI transparent background is unreliable.

It often creates fake checkerboard transparency or a transparent-looking background that is actually opaque.

Do not rely on AI to generate alpha transparency.

Preferred strategy:

* generate the asset on a flat, solid, high-contrast background
* use a background color that is not used in the asset
* remove that background with a script
* clean edge pixels
* export real PNG alpha

Recommended background colors:

* pure green: `#00FF00`
* pure magenta: `#FF00FF`
* pure cyan: `#00FFFF`

Use only one background color per generation.

Avoid gradients, shadows, glow, floor, cards, frames, panels, or texture behind the asset.

## Background Removal Rules

When removing the background:

* remove pixels close to the chosen key color
* remove semi-key-colored edge pixels
* avoid leaving green/magenta/cyan outlines
* preserve dark sprite outlines
* preserve internal colors
* do not remove holes inside the sprite unless intentional
* output true alpha PNG

After removal, inspect the asset on:

* black background
* white background
* game floor background
* checkerboard background

## Better Alternative: Mask-Based Cleanup

For higher quality, use a mask-based workflow.

Generate or extract:

* RGB image
* binary alpha mask
* cleaned transparent PNG

The mask should separate sprite from background.

Then apply slight edge cleanup:

* remove color spill
* feather alpha by 0.5–1px only if needed
* do not blur the whole sprite
* preserve crisp pixel readability

## Sprite Size Targets

Use larger generation sizes, then downscale.

Do not generate directly at tiny size.

Recommended source sizes:

* characters: 512×512 or 768×768
* weapons/items: 512×512
* UI icons: 512×512
* logo/favicon source: 1024×1024
* tiles: 512×512 or 1024×1024

Recommended game import sizes:

* small characters: 64×64 or 96×96
* small weapons: 64×64 or 96×96
* UI icons: 64×64, 128×128, 256×256
* favicon: 16×16, 32×32, 48×48, 64×64
* tiles: engine-dependent, usually 256×256 or 512×512

Always inspect assets at the final in-game size.

## Character Asset Rules

Characters should be:

* round-bodied
* compact
* readable
* funny
* kitchen-related
* same visual scale
* same camera angle
* no realistic anatomy
* no long legs
* no weapons baked into the base sprite

Allowed details:

* chef hats
* aprons
* sauce stains
* burn marks
* crooked tooth
* lazy eye
* black eye
* stitched scar
* tired expression
* greasy marks

Avoid:

* tiny unreadable details
* transparent holes inside the body
* realistic human proportions
* horror wounds
* long weapons in hand
* thin complex limbs

## Weapon Asset Rules

Weapons should be:

* separate from characters
* readable as icons
* kitchen-themed
* slightly ridiculous
* clear in silhouette
* similar visual scale
* simple enough for small size

Good weapon examples:

* kitchen knife
* frying pan
* rolling pin
* spaghetti whip
* banana mine
* garlic bomb
* pepper grinder gun
* toaster turret
* ladle boomerang
* blender blast

## Enemy Asset Rules

Enemies should be kitchen pests or kitchen hazards.

Good enemy families:

* rats
* mice
* cockroaches
* ants
* flies
* mosquitoes
* spiders
* pantry moths
* silverfish
* mutant food contamination

Enemies should be readable in swarms.

Avoid realistic disgusting insect detail.

Make them stylized, compact, and game-readable.

## Tiles and Backgrounds

Tiles are different from sprites.

For tiles, do not use transparent background.

Tiles should be:

* seamless
* low contrast
* top-down
* subtle
* readable under gameplay chaos

Avoid:

* high detail
* strong shadows
* large props
* visual noise
* high contrast checker patterns

## Prompt Strategy

Use short, strict prompts.

Do not overexplain transparency.

Overexplaining transparency can make the generator draw fake transparency.

For final sprites, use wording like:

* "single isolated game sprite"
* "flat solid green background"
* "no shadows"
* "no glow"
* "no floor"
* "no panel"
* "no frame"
* "centered"
* "clear silhouette"
* "production game asset"

Avoid wording like:

* "checkerboard transparency"
* "transparent-looking"
* "PNG transparency effect"
* "alpha grid"
* "background should look transparent"

## Good Single Character Prompt Template

Generate one isolated playable character sprite for Kitchen Madness, a top-down roguelite arena survivor inspired by Brotato and Vampire Survivors.

Character:
[CHARACTER NAME AND SHORT DESCRIPTION]

Style:

* flat 2D game art
* top-down or slightly angled top-down view
* compact round-bodied character
* readable at small size
* weird, ridiculous, kitchen-themed
* slightly gritty, not horror
* thin dark outline
* medium saturation
* minimal shading

Format:

* single centered sprite
* flat solid green background `#00FF00`
* no shadow
* no glow
* no floor
* no frame
* no UI
* no text
* no weapon in hands

The character should have a clear silhouette and work as a small in-game player sprite.

## Good Single Weapon Prompt Template

Generate one isolated weapon sprite for Kitchen Madness, a top-down roguelite arena survivor inspired by Brotato and Vampire Survivors.

Weapon:
[WEAPON NAME AND SHORT DESCRIPTION]

Style:

* flat 2D game art
* top-down or slightly angled top-down view
* readable at small size
* weird, ridiculous, kitchen-themed
* slightly gritty, not horror
* thin dark outline
* medium saturation
* minimal shading

Format:

* single centered sprite
* flat solid magenta background `#FF00FF`
* no shadow
* no glow
* no floor
* no frame
* no UI
* no text

The weapon should have a clear silhouette and work as a small in-game item or attack sprite.

## Good Enemy Prompt Template

Generate one isolated enemy sprite for Kitchen Madness, a top-down roguelite arena survivor inspired by Brotato and Vampire Survivors.

Enemy:
[ENEMY NAME AND SHORT DESCRIPTION]

Style:

* flat 2D game art
* top-down or slightly angled top-down view
* compact readable shape
* kitchen pest or kitchen hazard
* funny but dangerous
* slightly gritty, not horror
* thin dark outline
* medium saturation
* minimal shading

Format:

* single centered sprite
* flat solid cyan background `#00FFFF`
* no shadow
* no glow
* no floor
* no frame
* no UI
* no text

The enemy should be readable in large swarms.

## Asset Validation Checklist

Before accepting an asset:

* background is real alpha after processing
* no colored edge spill
* no fake transparency
* no unwanted shadow
* no unwanted glow
* no floor or platform
* no text
* no UI frame
* silhouette is readable at 64px
* silhouette is still readable at 32px if needed
* style matches existing assets
* scale matches similar assets
* outline thickness is consistent
* colors work on the game floor
* asset does not become muddy when downscaled

## Suggested Codex Tasks

Codex should help by creating scripts and tooling, not by trusting raw assets.

Recommended tools to build:

1. `scripts/remove-background.ts`
2. `scripts/trim-transparent-padding.ts`
3. `scripts/add-consistent-padding.ts`
4. `scripts/downscale-assets.ts`
5. `scripts/validate-alpha.ts`
6. `scripts/generate-contact-sheet.ts`
7. `scripts/preview-assets.ts`

## Background Removal Script Requirements

The script should:

* accept input PNG/JPG/WebP
* accept background key color
* accept tolerance value
* remove matching background pixels
* reduce color spill near edges
* preserve dark outlines
* export PNG with real alpha
* optionally trim transparent padding
* optionally add fixed padding
* optionally resize to target size

Example CLI:

```bash
pnpm art:remove-bg \
  --input ignored/raw-art/chef-blobbo.png \
  --output assets/characters/chef-blobbo.png \
  --key "#00FF00" \
  --tolerance 40 \
  --trim \
  --padding 8 \
  --size 96
```

## Contact Sheet Script Requirements

The script should create preview sheets for review.

Each contact sheet should show assets on:

* transparent checkerboard
* black background
* white background
* real game floor background

This makes alpha artifacts obvious.

## Asset Folder Structure

Recommended structure:

```text
assets/
  characters/
    raw/
    processed/
    final/
  enemies/
    raw/
    processed/
    final/
  weapons/
    raw/
    processed/
    final/
  items/
    raw/
    processed/
    final/
  ui/
    raw/
    processed/
    final/
  tiles/
    raw/
    final/
```

Raw AI outputs should not be imported directly into the game.

Only `final` assets should be used by gameplay code.

## Naming Rules

Use stable kebab-case names.

Examples:

```text
chef-blobbo.png
grease-goblin.png
burnt-pan.png
spaghetti-lash.png
banana-mine.png
angry-roach.png
freezer-rat.png
```

Avoid names like:

```text
image1.png
final-final.png
new-character.png
generated-asset.png
```

## Final Rule

AI generation is for concept and base rendering.

Production quality comes from:

* generating assets individually
* using controlled backgrounds
* removing backgrounds with scripts
* validating transparency
* downscaling carefully
* checking assets in the actual game

Do not sacrifice asset quality for generation speed.
