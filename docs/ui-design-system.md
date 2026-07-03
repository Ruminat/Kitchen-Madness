# Kitchen Madness — UI Design System

The single source of truth for the game's interface is
[`scripts/ui/design_system.gd`](../scripts/ui/design_system.gd) (`class_name DesignSystem`,
aliased `DS` in consumer files). **No UI script hardcodes a raw color or size** — it names a
token. Everything below is derived from a small set of scales, so nothing on screen is accidental.

Layering:

- **`DesignSystem`** — tokens (palette, spacing, radii, borders, type scale, elevation) + tiny
  style builders (`stylebox`, `shadowed`, `padded`, `style_label`) and rarity helpers.
- **`HudTheme`** — composes tokens into the concrete StyleBoxes each HUD/menu widget needs.
- **Component scripts** (`ShopCard`, `ShopDisplay`, `UpgradeDisplay`, `WeaponBelt`,
  `HudActionBar`…) — pull tokens/builders; they never invent values.

---

## Color palette

Warm, grimy-kitchen. One dark ink for all text/outlines; parchment for paper surfaces; metal for
dark trays; brass for the top bar; semantic accents for meaning; five rarity hues for card ribbons.

| Group | Tokens | Use |
|---|---|---|
| Ink / text | `INK` `INK_STRONG` `INK_PRESSED` `INK_ON_DARK` · `TEXT` `TEXT_MUTED` `TEXT_DISABLED` `TEXT_INVERSE` | Text and thin outlines |
| Parchment | `PARCHMENT` `PARCHMENT_LIGHT` `PARCHMENT_FOCUS` `PARCHMENT_DARK` `PARCHMENT_DEEP` `PARCHMENT_SUNK` | Card / paper surfaces + interaction states |
| Metal | `METAL` `METAL_EDGE` | Dark trays (shop panel) |
| Brass | `BRASS` `BRASS_EDGE` | Top HUD bar |
| Accents | `GREASE` `GREASE_DIM` (currency) · `BLOOD` `BLOOD_TROUGH` (HP/danger) · `HERB` (positive) · `TEAL` (settings) | Semantic meaning |
| Rarity | `RARITY_COMMON` `RARITY_UNCOMMON` `RARITY_RARE` `RARITY_EPIC` `RARITY_LEGENDARY` | Card ribbons / borders |

Interaction states are **derived**, not hand-picked: `accent.lightened(0.12)` on hover,
`0.25` on focus, `accent.darkened(0.15)` on pressed — paired with the parchment tint ladder.

Invariant (tested): `TEXT` luminance sits ≥ 0.25 below every light surface, so labels stay legible.

---

## Spacing scale — 4 px base

`SPACE_XS 4 · SPACE_SM 8 · SPACE_MD 12 · SPACE_LG 16 · SPACE_XL 24 · SPACE_XXL 32`

Every gap, margin, and content padding is one of these six. All are multiples of 4 and strictly
increasing (tested).

## Radius scale

`RADIUS_SM 4` (chips, insets) · `RADIUS_MD 6` (buttons, panels) · `RADIUS_LG 10` (big trays).

## Border weights

`BORDER_HAIRLINE 2` (fields) · `BORDER_THIN 3` (buttons, cards) · `BORDER_THICK 5` (modals, trays).

## Type scale — modular, base 16, ratio 1.2

Rounded to the pixel and mapped to roles:

| Role | px | Font |
|---|---|---|
| `FONT_SIZE_CAPTION` | 13 | hints |
| `FONT_SIZE_LABEL` | 16 | small labels / ribbons |
| `FONT_SIZE_BODY` | 19 | body copy, HUD readouts |
| `FONT_SIZE_SUBHEADING` | 23 | card titles, action buttons |
| `FONT_SIZE_HEADING` | 28 | — |
| `FONT_SIZE_TITLE` | 33 | overlay titles |
| `FONT_SIZE_DISPLAY` | 40 | — |
| `FONT_SIZE_HERO` | 48 | grease counter, win/lose banner |

Fonts by role: `FONT_DISPLAY` (Bangers, punchy titles) · `FONT_BODY` (Jersey 15, readable body) ·
`FONT_VALUE` (Noto Sans Black, big numerics) · `FONT_LABEL` (Noto Sans SemiBold, small labels).

## Elevation

`ELEVATION[0..3]` — flat → subtle → card → tray. Each preset is `{size, offset, color}`; applied
via `DS.shadowed(style, level)`. Higher level ⇒ larger, darker shadow (tested, and clamped).

---

## Builders

```gdscript
# A flat surface from tokens (borders symmetric, corners uniform, optional shadow):
DS.stylebox(bg, border_color, border_width := BORDER_THIN, radius := RADIUS_MD, elevation := 0)
DS.shadowed(style, level)            # apply an elevation preset, returns style
DS.padded(style, horizontal, vertical)   # symmetric content margins, returns style
DS.style_label(label, font, size, color) # font + size + color in one call
DS.rarity_color(tier) / DS.rarity_label(tier)   # Rarity enum -> Color / "UNCOMMON"
```

## Adding a component

1. Reach only for tokens and the builders above — never a literal color/size.
2. If a value truly isn't in a scale (a fixed card dimension), name it a `const` on the component
   (see `ShopCard.CARD_MIN_SIZE` / `ICON_AREA_HEIGHT`) so it's intentional and reusable.
3. Add a test asserting your styles come from tokens (see
   [`tests/unit/test_hud_theme.gd`](../tests/unit/test_hud_theme.gd)).
