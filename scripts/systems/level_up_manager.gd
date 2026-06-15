class_name LevelUpManager
extends Node

const DEFAULT_UPGRADE_PATHS: Array[String] = [
	"res://resources/upgrades/max_health.tres",
	"res://resources/upgrades/armor.tres",
	"res://resources/upgrades/damage_boost.tres",
	"res://resources/upgrades/attack_speed.tres",
	"res://resources/upgrades/speed_boost.tres",
	"res://resources/upgrades/luck.tres",
	"res://resources/upgrades/pickup_range.tres",
	"res://resources/upgrades/xp_gain.tres",
]

@export var upgrades: Array[Resource] = []
@export var choice_count := 3
@export var delay_seconds := 0.5

var _player: Node
var _ui: Node
var _can_resume := Callable()
var _pending_levels := 0
var _waiting_for_choice := false


func _ready() -> void:
	_load_default_upgrades()
	EventBus.level_up.connect(_on_level_up)


func configure(player: Node, ui: Node, can_resume: Callable = Callable()) -> void:
	_player = player
	_ui = ui
	_can_resume = can_resume

	if _ui and _ui.has_signal("upgrade_selected"):
		_ui.upgrade_selected.connect(_on_upgrade_selected)


func _on_level_up(_level: int) -> void:
	_pending_levels += 1
	if not _waiting_for_choice:
		_show_next_choice()


func _show_next_choice() -> void:
	if _pending_levels <= 0 or _ui == null:
		return

	_waiting_for_choice = true
	if delay_seconds > 0.0:
		await get_tree().create_timer(delay_seconds).timeout

	if not _can_resume_run():
		_waiting_for_choice = false
		return

	get_tree().paused = true
	if _ui.has_method("show_level_up_options"):
		_ui.show_level_up_options(_pick_choices())


func _on_upgrade_selected(upgrade: Resource) -> void:
	if not _waiting_for_choice or upgrade == null:
		return

	if upgrade.has_method("apply"):
		upgrade.apply(_player)
	_pending_levels -= 1
	_waiting_for_choice = false

	if _ui and _ui.has_method("hide_level_up_options"):
		_ui.hide_level_up_options()

	if not _can_resume_run():
		return

	get_tree().paused = false
	if _pending_levels > 0:
		_show_next_choice()


func _pick_choices() -> Array[Resource]:
	var pool := upgrades.duplicate()
	pool.shuffle()

	var candidate_count := choice_count
	if _player and _player.has_method("get_luck"):
		candidate_count += mini(_player.get_luck() / 10, 2)
	candidate_count = mini(candidate_count, pool.size())

	var candidates: Array[Resource] = []
	for index in candidate_count:
		candidates.append(pool[index])

	candidates.sort_custom(_sort_upgrades_by_amount_desc)
	return candidates.slice(0, choice_count)


func _sort_upgrades_by_amount_desc(a: Resource, b: Resource) -> bool:
	return float(a.get("amount")) > float(b.get("amount"))


func _can_resume_run() -> bool:
	return not _can_resume.is_valid() or _can_resume.call()


func _load_default_upgrades() -> void:
	if not upgrades.is_empty():
		return

	for path in DEFAULT_UPGRADE_PATHS:
		var upgrade := load(path) as Resource
		if upgrade:
			upgrades.append(upgrade)
