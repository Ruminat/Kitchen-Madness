class_name ShopManager
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

var _player: Node
var _ui: Node
var _gold_system: GoldSystem
var _on_continue := Callable()
var _shop_open := false


func _ready() -> void:
	_load_default_upgrades()
	EventBus.wave_completed.connect(_on_wave_completed)


func configure(
	player: Node,
	ui: Node,
	gold_system: GoldSystem,
	on_continue: Callable = Callable()
) -> void:
	_player = player
	_ui = ui
	_gold_system = gold_system
	_on_continue = on_continue

	if _ui and _ui.has_signal("shop_purchase_requested"):
		_ui.shop_purchase_requested.connect(_on_shop_purchase)
	if _ui and _ui.has_signal("shop_continue_requested"):
		_ui.shop_continue_requested.connect(_on_shop_continue)


func _on_wave_completed() -> void:
	_shop_open = true
	get_tree().paused = true
	if _ui and _ui.has_method("show_shop"):
		_ui.show_shop(upgrades, _current_gold())


func _on_shop_purchase(upgrade: Resource) -> void:
	if not _shop_open or upgrade == null or _gold_system == null:
		return

	var cost := int(upgrade.get("gold_cost"))
	if not _gold_system.spend_gold(cost):
		return

	if upgrade.has_method("apply"):
		upgrade.apply(_player)

	if _ui and _ui.has_method("update_shop_gold"):
		_ui.update_shop_gold(_current_gold())


func _on_shop_continue() -> void:
	if not _shop_open:
		return

	_shop_open = false
	if _ui and _ui.has_method("hide_shop"):
		_ui.hide_shop()

	if _on_continue.is_valid():
		_on_continue.call()


func _current_gold() -> int:
	if _gold_system:
		return _gold_system.gold
	return 0


func _load_default_upgrades() -> void:
	if not upgrades.is_empty():
		return

	for path in DEFAULT_UPGRADE_PATHS:
		var upgrade := load(path) as Resource
		if upgrade:
			upgrades.append(upgrade)
