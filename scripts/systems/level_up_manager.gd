class_name LevelUpManager
extends Node

const DEFAULT_UPGRADE_PATHS: Array[String] = [
	"res://resources/upgrades/armor.tres",
	"res://resources/upgrades/max_health.tres",
	"res://resources/upgrades/attack_speed.tres",
	"res://resources/upgrades/damage.tres",
	"res://resources/upgrades/area.tres",
	"res://resources/upgrades/move_speed.tres",
	"res://resources/upgrades/luck.tres",
	"res://resources/upgrades/evasion.tres",
]

@export var upgrades: Array[Resource] = []
@export var choice_count := 3

var _player: Node
var _ui: Node
var _skill_runner: SkillRunner
var _entity_manager: EntityManager
var _can_resume := Callable()
var _pending_levels := 0
var _menu_open := false


func _ready() -> void:
	_load_default_upgrades()
	EventBus.level_up.connect(_on_level_up)


func configure(
	player: Node,
	ui: Node,
	can_resume: Callable = Callable(),
	skill_runner: SkillRunner = null,
	entity_manager: EntityManager = null
) -> void:
	_player = player
	_ui = ui
	_can_resume = can_resume
	_skill_runner = skill_runner
	_entity_manager = entity_manager

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


## Level-up choices come from a unified pool — stat upgrades plus skill and entity
## acquire/upgrade offers — selected with the same luck bias the shop uses, so a
## lucky player is more likely to be offered upgrades for content they already own.
func _pick_choices() -> Array[Resource]:
	var pool: Array = []
	pool.append_array(upgrades)
	pool.append_array(OfferCatalog.skill_offers(_skill_runner))
	pool.append_array(OfferCatalog.entity_offers(_entity_manager))

	var luck := 0.0
	if _player and _player.has_method("get_luck"):
		luck = float(_player.get_luck())

	var chosen: Array[Resource] = []
	for offer in OfferSelection.select(pool, choice_count, luck):
		chosen.append(offer as Resource)
	return chosen


func _can_resume_run() -> bool:
	return not _can_resume.is_valid() or _can_resume.call()


func _load_default_upgrades() -> void:
	if not upgrades.is_empty():
		return

	for path in DEFAULT_UPGRADE_PATHS:
		var upgrade := load(path) as Resource
		if upgrade:
			upgrades.append(upgrade)
