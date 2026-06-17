# game-setting.md

## Project

**Working title:** Kitchen Madness
**Alternate title:** Kitchen Survivors
**Genre:** top-down roguelite arena survivor
**Main references:** Brotato and Vampire Survivors

Kitchen Madness is a chaotic kitchen-themed survivor game.

The player controls a ridiculous round-bodied character and survives waves of pests, vermin, food hazards, and kitchen-related monsters.

The game should feel fast, readable, funny, weird, and slightly gritty.

The core fantasy is:

> Weird fantasy creatures forced to work in a kitchen during an endless disaster.

## Core Pillars

1. Readable chaos.
2. Funny but dangerous.
3. Kitchen theme everywhere.
4. Compact round characters.
5. Simple but satisfying progression.
6. Many enemies on screen.
7. Absurd food and kitchen weapons.
8. Fast iteration over complex simulation.

## Tone

The tone should be ridiculous first and gritty second.

The game is not horror.

The game is not cute mascot-style.

The game is not clean mobile-game fantasy.

Target mood:

* weird
* funny
* chaotic
* slightly dirty
* battle-worn
* absurd
* game-readable

Avoid:

* realistic gore
* horror faces
* excessive darkness
* childish pastel cuteness
* overdesigned fantasy lore
* realistic human proportions
* serious medieval fantasy tone

## Visual Style

The visual style sits between Brotato and Vampire Survivors.

Sprites should be compact and readable at small scale.

Rendering should be flat 2D with minimal shading.

Use very thin dark outlines for readability.

Colors should be medium saturation and slightly dirty.

Avoid neon-heavy colors, pastel softness, and washed-out palettes.

The game should look punchy during gameplay, even with many entities on screen.

## Camera

Top-down or slightly angled top-down view.

The camera should support arena-survivor gameplay.

Everything must be readable while moving quickly.

Sprites should not rely on tiny details to be understood.

## Playable Characters

Playable characters are weird kitchen-related creatures.

They should be memorable but not lore-heavy.

They should mostly be round-bodied or circle-shaped.

They should fit inside an invisible circle of equal diameter.

They should have no realistic anatomy.

Legs are optional.

If legs exist, they must be tiny and not break the round silhouette.

Arms can be small stubs.

Base character sprites should usually not include weapons.

Weapons should usually be separate assets.

Characters may include kitchen hints such as aprons, hats, stains, burn marks, dough folds, sauce marks, chef collars, or food-like materials.

Character ugliness target: 5–6 out of 10.

Allowed details:

* crooked tooth
* lazy eye
* black eye
* stitched scar
* burn mark
* dent
* torn ear
* cracked glasses
* greasy stain
* tired eyes

Avoid:

* exposed flesh
* open wounds
* body horror
* horror gore
* realistic injuries
* transparent holes inside the sprite

## Example Character Directions

* smug dough chef blob
* greasy goblin cook
* onion oracle
* burnt biscuit brute
* moldy mushroom baker
* tomato-sauce vampire
* pickle witch
* dumpling monk
* freezer gremlin
* cursed pantry worker
* exhausted soup spirit
* angry flour golem

## Enemies

Enemies should come from kitchen ecosystems and kitchen chaos.

Main enemy families:

* rats
* mice
* cockroaches
* ants
* flies
* mosquitoes
* spiders
* silverfish
* pantry moths
* weevils
* food contamination creatures
* mutant kitchen pests

Enemy variants can be:

* angry
* greasy
* armored
* elite
* mutant
* alien
* zombie-like
* overgrown
* chef-corrupted
* freezer-burned
* sauce-infected

Enemies should be hostile-looking but not disgusting horror.

They should be readable in swarms.

Small enemies need exaggerated silhouettes.

Large enemies need clear attack readability.

## Weapons

Weapons should be kitchen or food related.

Weapons should feel absurd but useful.

Examples:

* kitchen knife
* frying pan
* rolling pin
* spaghetti whip
* banana mine
* falling fridge
* garlic bomb
* boiling soup splash
* pepper grinder gun
* toaster turret
* onion ring blade
* blender blast
* cheese grater trap
* ladle boomerang
* meat tenderizer
* exploding dumpling
* hot oil puddle

Weapons should be separate assets where possible.

Weapon icons should be simple, punchy, and readable.

## Items and Upgrades

Items should follow kitchen logic.

Good item themes:

* spices
* sauces
* leftovers
* dirty dishes
* appliances
* chef clothing
* cursed ingredients
* cleaning supplies
* restaurant tools

Item names can be silly.

Effects should be simple to understand.

Prioritize combinations that create chaotic builds.

## World and Biomes

The game world is not only one kitchen.

The kitchen theme can expand into nearby food-related spaces.

Possible arenas:

* dirty restaurant kitchen
* luxury restaurant kitchen
* industrial freezer
* pantry
* food court
* food truck battlefield
* dumpster zone
* picnic forest
* desert picnic
* outdoor cooking area
* greasy storage room

Arenas should stay readable.

Floor textures should be subtle.

Backgrounds should not compete with enemies, items, or projectiles.

## Tile and Environment Rules

Tiles should be seamless when needed.

Top-down textures should be flat and low contrast.

Use subtle grime, crumbs, grease, cracks, or wear.

Avoid strong shadows.

Avoid large decorative props that block readability.

Avoid overly detailed floors.

## Asset Rules

All sprite exports should use transparent background unless explicitly making a tile or concept scene.

Do not use solid gray backgrounds for production sprites.

No shadows.

No glow.

No particles baked into base sprites.

No transparent holes inside character or enemy bodies.

The sprite itself should be a solid painted form.

Only the outer background should be transparent.

## Gameplay Feel

The player should quickly understand what is happening.

Movement should feel simple and responsive.

Combat should create escalating chaos.

Progression should make the player feel increasingly overpowered.

Runs should support weird builds and replayability.

The game should reward quick decisions.

Do not overcomplicate systems early.

## Design Bias

Prefer clear arcade systems over simulation.

Prefer readable jokes over deep lore.

Prefer strong silhouettes over detailed anatomy.

Prefer many simple enemies over a few complex enemies.

Prefer kitchen absurdity over generic fantasy.

Prefer fast prototyping over perfect architecture.

## Development Notes for Cursor

When generating code, keep systems modular.

Use data-driven definitions for characters, enemies, weapons, upgrades, and waves.

Avoid hardcoding individual content into gameplay logic.

Separate gameplay logic from visual assets.

Make it easy to add new weapons, enemies, and characters.

Use clear names and small files.

Prefer simple maintainable implementation over premature optimization.

The project should support rapid content iteration.

## Current Priority

The current priority is to establish the visual and gameplay foundation.

First focus areas:

1. playable character roster
2. enemy roster
3. basic movement
4. basic weapon system
5. wave spawning
6. XP and level-up flow
7. simple upgrade selection
8. one readable kitchen arena
9. reusable asset import pipeline

## One-Sentence Summary

Kitchen Madness is a Brotato × Vampire Survivors-style kitchen arena survivor about ridiculous round-bodied kitchen creatures fighting endless swarms of pests with absurd food and kitchen weapons.
