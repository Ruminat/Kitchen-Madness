class_name DesignSystem
extends RefCounted
## Kitchen Madness UI design system — the single source of truth for every
## color, spacing, radius, border weight, type-scale step, and elevation the
## HUD and menus draw with. No UI script should hardcode a raw color or size;
## it names a token here instead. See docs/ui-design-system.md for the rationale
## behind each scale. Everything is derived, nothing is accidental.

## Rarity tiers, ordered common -> legendary. Drives the colored ribbon and
## border on offer/upgrade cards.
enum Rarity { COMMON, UNCOMMON, RARE, EPIC, LEGENDARY }

# --- Palette: ink & text -------------------------------------------------
## Warm near-black. Text and the thin outline that keeps everything readable.
const INK := Color(0.11, 0.075, 0.045, 1.0)
const INK_STRONG := Color(0.05, 0.035, 0.025, 1.0)
const INK_PRESSED := Color(0.18, 0.1, 0.04, 1.0)
## Parchment-tinted light text for use on dark (metal / ink) surfaces.
const INK_ON_DARK := Color(0.93, 0.88, 0.76, 1.0)
const TEXT := INK
const TEXT_MUTED := Color(0.38, 0.28, 0.18, 1.0)
const TEXT_DISABLED := Color(0.37, 0.31, 0.24, 1.0)
const TEXT_INVERSE := INK_ON_DARK

# --- Palette: surfaces ---------------------------------------------------
## Parchment — the paper card surface, four tints on one warm-tan hue.
const PARCHMENT := Color(0.78, 0.67, 0.46, 1.0)
const PARCHMENT_LIGHT := Color(0.86, 0.76, 0.55, 1.0)
const PARCHMENT_FOCUS := Color(0.9, 0.8, 0.58, 1.0)
const PARCHMENT_DARK := Color(0.5, 0.39, 0.26, 1.0)
const PARCHMENT_DEEP := Color(0.48, 0.37, 0.23, 1.0)
const PARCHMENT_SUNK := Color(0.62, 0.51, 0.34, 1.0)
## Metal — dark trays such as the shop panel.
const METAL := Color(0.16, 0.15, 0.13, 0.94)
const METAL_EDGE := Color(0.45, 0.42, 0.35, 1.0)
## Brass — the warm top HUD bar tint.
const BRASS := Color(0.69, 0.58, 0.39, 0.94)
const BRASS_EDGE := Color(0.12, 0.085, 0.05, 0.98)

# --- Palette: semantic accents -------------------------------------------
const GREASE := Color(0.98, 0.72, 0.13, 1.0)  # currency / gold
const GREASE_DIM := Color(0.46, 0.34, 0.16, 1.0)
const BLOOD := Color(0.78, 0.12, 0.08, 1.0)  # HP / danger
const BLOOD_TROUGH := Color(0.18, 0.12, 0.07, 1.0)  # bar backgrounds
const HERB := Color(0.37, 0.66, 0.21, 1.0)  # level-up / positive
const TEAL := Color(0.28, 0.49, 0.46, 1.0)  # settings / neutral-cool

# --- Palette: rarity -----------------------------------------------------
const RARITY_COMMON := Color(0.62, 0.56, 0.44, 1.0)
const RARITY_UNCOMMON := Color(0.45, 0.66, 0.28, 1.0)
const RARITY_RARE := Color(0.28, 0.52, 0.78, 1.0)
const RARITY_EPIC := Color(0.62, 0.36, 0.72, 1.0)
const RARITY_LEGENDARY := Color(0.9, 0.62, 0.16, 1.0)

# --- Spacing scale (4 px base, doubling then +8 steps) -------------------
const SPACE_XS := 4
const SPACE_SM := 8
const SPACE_MD := 12
const SPACE_LG := 16
const SPACE_XL := 24
const SPACE_XXL := 32

# --- Radius scale --------------------------------------------------------
const RADIUS_SM := 4
const RADIUS_MD := 6
const RADIUS_LG := 10

# --- Border weights ------------------------------------------------------
const BORDER_HAIRLINE := 2
const BORDER_THIN := 3
const BORDER_THICK := 5

# --- Type scale (modular: base 16, ratio 1.2, rounded to the pixel) ------
const FONT_SIZE_CAPTION := 13
const FONT_SIZE_LABEL := 16
const FONT_SIZE_BODY := 19
const FONT_SIZE_SUBHEADING := 23
const FONT_SIZE_HEADING := 28
const FONT_SIZE_TITLE := 33
const FONT_SIZE_DISPLAY := 40
const FONT_SIZE_HERO := 48

# --- Fonts by role -------------------------------------------------------
const FONT_DISPLAY := preload("res://assets/fonts/bangers.ttf")  # punchy titles
const FONT_BODY := preload("res://assets/fonts/jersey15.ttf")  # readable body
const FONT_VALUE := preload("res://assets/fonts/noto_sans_black.ttf")  # big numerics
const FONT_LABEL := preload("res://assets/fonts/noto_sans_semibold.ttf")  # small labels

# --- Elevation (drop-shadow presets, low -> high) ------------------------
const ELEVATION := [
	{"size": 0, "offset": Vector2.ZERO, "color": Color(0, 0, 0, 0)},
	{"size": 5, "offset": Vector2(2, 3), "color": Color(0.08, 0.055, 0.035, 0.45)},
	{"size": 9, "offset": Vector2(3, 5), "color": Color(0.05, 0.035, 0.02, 0.55)},
	{"size": 12, "offset": Vector2(4, 7), "color": Color(0.0, 0.0, 0.0, 0.65)},
]


## Ribbon/border color for a rarity tier.
static func rarity_color(rarity: int) -> Color:
	match rarity:
		Rarity.UNCOMMON:
			return RARITY_UNCOMMON
		Rarity.RARE:
			return RARITY_RARE
		Rarity.EPIC:
			return RARITY_EPIC
		Rarity.LEGENDARY:
			return RARITY_LEGENDARY
		_:
			return RARITY_COMMON


## Upper-case ribbon label for a rarity tier.
static func rarity_label(rarity: int) -> String:
	match rarity:
		Rarity.UNCOMMON:
			return "UNCOMMON"
		Rarity.RARE:
			return "RARE"
		Rarity.EPIC:
			return "EPIC"
		Rarity.LEGENDARY:
			return "LEGENDARY"
		_:
			return "COMMON"


## Build a flat panel/button surface from tokens. Every StyleBoxFlat in the UI
## should originate here so borders, radii, and shadows stay consistent.
static func stylebox(
	bg: Color,
	border_color: Color,
	border_width: int = BORDER_THIN,
	radius: int = RADIUS_MD,
	elevation: int = 0
) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.border_color = border_color
	style.set_corner_radius_all(radius)
	return shadowed(style, elevation)


## Apply an elevation preset's drop shadow to an existing style. Returns the
## same style for chaining.
static func shadowed(style: StyleBoxFlat, elevation: int) -> StyleBoxFlat:
	var preset: Dictionary = ELEVATION[clampi(elevation, 0, ELEVATION.size() - 1)]
	style.shadow_size = preset.size
	style.shadow_offset = preset.offset
	style.shadow_color = preset.color
	return style


## Set symmetric horizontal/vertical content padding on a style. Returns the
## same style for chaining.
static func padded(style: StyleBoxFlat, horizontal: int, vertical: int) -> StyleBoxFlat:
	style.content_margin_left = horizontal
	style.content_margin_right = horizontal
	style.content_margin_top = vertical
	style.content_margin_bottom = vertical
	return style


## Apply a font role + size + color to a label in one call.
static func style_label(label: Label, font: FontFile, size: int, color: Color) -> void:
	label.add_theme_font_override("font", font)
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
