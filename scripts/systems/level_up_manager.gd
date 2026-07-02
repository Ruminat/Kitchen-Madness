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
	"res://resources/upgrades/crit_chance.tres",
	"res://resources/upgrades/crit_damage.tres",
]

@export var upgrades: Array[Resource] = []
@export var choice_count := 3

var _player: Node
var _ui: Node
var _can_resume := Callable()
var _pending_levels := 0
var _menu_open := false


func _ready() -> void:
	_load_default_upgrades()
	EventBus.level_up.connect(_on_level_up)


func configure(player: Node, ui: Node, can_resume: Callable = Callable()) -> void:
	_player = player
	_ui = ui
	_can_resume = can_resume

	if _ui and _ui.has_signal("upgrade_selected"):
		_ui.upgrade_selected.connect(_on_upgrade_selected)
	if _ui and _ui.has_signal("upgrades_open_requested"):
		_ui.upgrades_open_requested.connect(open_upgrades)
	EventBus.upgrades_pending_changed.emit(_pending_levels)


func has_pending() -> bool:
	return _pending_levels > 0


func pending_count() -> int:
	return _pending_levels


func _on_level_up(_level: int) -> void:
	## Level-ups bank an upgrade choice without interrupting the run.
	_pending_levels += 1
	EventBus.upgrades_pending_changed.emit(_pending_levels)


func open_upgrades() -> void:
	if _menu_open or _pending_levels <= 0 or _ui == null:
		return
	if not _can_resume_run():
		return

	_menu_open = true
	get_tree().paused = true
	if _ui.has_method("show_level_up_options"):
		_ui.show_level_up_options(_pick_choices())


func _on_upgrade_selected(upgrade: Resource) -> void:
	if not _menu_open or upgrade == null:
		return

	if upgrade.has_method("apply"):
		upgrade.apply(_player)
	if upgrade.get("id"):
		EventBus.upgrade_applied.emit(String(upgrade.id))
	_pending_levels -= 1
	EventBus.upgrades_pending_changed.emit(_pending_levels)

	if _pending_levels > 0:
		# Keep the overlay up (still paused) to spend the next banked choice.
		if _ui.has_method("show_level_up_options"):
			_ui.show_level_up_options(_pick_choices())
		return

	_menu_open = false
	if _ui.has_method("hide_level_up_options"):
		_ui.hide_level_up_options()

	if _can_resume_run():
		get_tree().paused = false


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
