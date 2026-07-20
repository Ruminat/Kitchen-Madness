class_name StatUnits
extends RefCounted
## Central conversion between design units (see docs/stats.md) and engine units.
##
## Designers author distances in "area units" (10 area = one player radius) and
## speeds in area/second (base move speed 30). The engine works in pixels; one
## documented factor maps between the two so no magic numbers scatter across the
## codebase. Keeping speed and distance on the same factor keeps the spec's
## identities consistent: 1 move speed = 1 area/second, and 30 speed == 220 px/s.

## Base move speed shared by every player, in design units (docs/stats.md).
const BASE_MOVE_SPEED_UNITS := 30.0
## Engine pixels/second the base move speed corresponds to (historical engine value).
const BASE_MOVE_SPEED_PIXELS := 220.0
## One area unit in engine pixels. Derived so the identities above hold.
const PIXELS_PER_AREA_UNIT := BASE_MOVE_SPEED_PIXELS / BASE_MOVE_SPEED_UNITS

## Fraction of damage removed per point of armor (tunable balance value, docs/stats.md).
const ARMOR_REDUCTION_PER_POINT := 0.05
## Clamp on armor's damage multiplier so full immunity (or runaway negative-armor
## damage) can never happen.
const MIN_DAMAGE_MULTIPLIER := 0.2
const MAX_DAMAGE_MULTIPLIER := 2.0


## Convert a design-unit distance (area / attack range) into engine pixels.
static func area_to_pixels(area_units: float) -> float:
	return area_units * PIXELS_PER_AREA_UNIT


## Convert a design-unit speed (area/second) into engine pixels/second.
static func speed_to_pixels(speed_units: float) -> float:
	return speed_units * PIXELS_PER_AREA_UNIT


## Multiplier applied to incoming damage for a given armor total. Positive armor
## reduces damage, negative armor (e.g. the "crazy one" perk) increases it.
static func armor_damage_multiplier(armor_points: int) -> float:
	var raw := 1.0 - ARMOR_REDUCTION_PER_POINT * float(armor_points)
	return clampf(raw, MIN_DAMAGE_MULTIPLIER, MAX_DAMAGE_MULTIPLIER)


## Apply armor to a raw damage amount. Any positive hit still deals at least 1.
static func apply_armor(amount: int, armor_points: int) -> int:
	if amount <= 0:
		return amount
	return maxi(roundi(float(amount) * armor_damage_multiplier(armor_points)), 1)
