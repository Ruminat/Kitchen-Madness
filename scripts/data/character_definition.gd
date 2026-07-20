class_name CharacterDefinition
extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var sprite: Texture2D
@export var max_health: int = 100
## Base move speed in design units (docs/stats.md). Converted to engine pixels via StatUnits.
@export var move_speed: float = 30.0
## Armor points (flat). Each point reduces incoming damage — see StatUnits.
@export var armor: int = 0
## Global outgoing-damage modifier (e.g. -0.12 = -12%). 0 = unmodified.
@export var damage_mult: float = 0.0
## Global attack-speed modifier (e.g. 0.18 = +18%). 0 = unmodified.
@export var attack_speed_mult: float = 0.0
## Crit-chance modifier added on top of the player's base crit chance (e.g. 0.24 = +24%).
@export_range(0.0, 1.0) var crit_chance: float = 0.0
@export_range(1.0, 5.0) var crit_damage: float = 1.5
## Luck modifier (e.g. 0.12 = +12%). Boosts drops and duplicate shop offers (docs/stats.md).
@export var luck: float = 0.0
## Evasion chance (0-1). Chance to take no damage while still triggering i-frames.
@export_range(0.0, 1.0) var evasion: float = 0.0
@export var starting_weapon: WeaponDefinition


func apply_to_player(player: Node) -> void:
	if player == null:
		return

	if player.has_method("configure"):
		player.configure(self)
