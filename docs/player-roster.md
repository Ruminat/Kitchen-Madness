# Player Roster

The starting roster is a curated set of **three** hand-tuned characters — quality over
quantity (see [players/index.md](players/index.md) and **plans.md → R2**). Each sprite is
generated **one at a time** from [assets/base/PlayerCircle.png](../assets/base/PlayerCircle.png),
never from a grid sheet, so every character shares an almost identical round silhouette while
looking distinct.

| Character | Sprite | Fantasy |
|---|---|---|
| The Newbie | `assets/rework/characters/the-newbie.png` | Fragile late-bloomer — fast, crit-heavy, lucky |
| Mr. Barret | `assets/rework/characters/mr-barret.png` | Tanky heavy hitter — high HP + damage |
| Natsumi | `assets/rework/characters/natsumi.png` | Balanced all-rounder — good at everything |

Default / headless character: **The Newbie** (`CharacterRoster.DEFAULT_CHARACTER_PATH`).

Character resources live at `resources/characters/{the_newbie,mr_barret,natsumi}.tres`
(see `CharacterDefinition` in `scripts/data/character_definition.gd`). Stats are authored in
design units and percentage modifiers — see [stats.md](stats.md) and
[players/*.md](players/) for each character's full stat block and story.

The generic grid splitter (`tools/grid_sprite_splitter.gd`) remains for other assets, but the
player-generation path no longer uses a 3×3 sheet.
