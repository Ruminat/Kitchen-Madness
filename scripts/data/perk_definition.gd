class_name PerkDefinition
extends Resource
## A shop-bought perk. Bundles one or more stat effects; most target the player,
## while world effects (like enemy count) are broadcast on the EventBus so the
## relevant system reacts. Perks are repeatable/stackable buys.

## Effect name applied to the spawner's enemy-count multiplier rather than the player.
const ENEMY_COUNT_EFFECT := &"enemy_count_percent"

@export var id: String = ""
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var icon: Texture2D
@export var effects: Array[StatEffect] = []


## Apply every bundled effect. Player stats go through StatEffects; world effects
## are broadcast on the EventBus. Always succeeds (perks are always applicable).
func apply(player: Node) -> bool:
	for stat_effect in effects:
		if stat_effect == null:
			continue
		if stat_effect.effect == ENEMY_COUNT_EFFECT:
			EventBus.enemy_count_percent_added.emit(stat_effect.amount)
		else:
			StatEffects.apply_to_player(player, stat_effect.effect, stat_effect.amount)
	return true
