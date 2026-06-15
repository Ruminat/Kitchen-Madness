extends Node2D

@export var wave_definition: WaveDefinition
@export var wave_definitions: Array[WaveDefinition] = []
@export var health_drop: DropDefinition

var is_wave_complete := false
var is_game_over := false
var current_wave := 1
var _arena_bounds := Rect2()

@onready var arena: Arena = $Arena
@onready var camera: Camera2D = $Camera2D
@onready var player: CharacterBody2D = $Player
@onready var enemy_container: Node2D = $EnemyContainer
@onready var projectile_container: Node2D = $ProjectileContainer
@onready var pickup_container: Node2D = $PickupContainer
@onready var wave_manager: WaveManager = $WaveManager
@onready var enemy_spawner: EnemySpawner = $EnemySpawner
@onready var loot_spawner: LootSpawner = $LootSpawner
@onready var level_up_manager: Node = $LevelUpManager
@onready var gold_system: GoldSystem = $GoldSystem
@onready var shop_manager: ShopManager = $ShopManager
@onready var ui: CanvasLayer = $UI


func _ready() -> void:
	get_tree().paused = false

	_arena_bounds = arena.get_bounds()

	player.setup(_arena_bounds, projectile_container)
	_configure_current_wave()
	loot_spawner.configure(pickup_container, health_drop)
	if level_up_manager.has_method("configure"):
		level_up_manager.configure(player, ui, Callable(self, "is_run_active"))
	if shop_manager.has_method("configure"):
		shop_manager.configure(player, ui, gold_system, Callable(self, "start_next_wave"))

	EventBus.wave_completed.connect(_on_wave_completed)
	EventBus.wave_index_changed.emit(current_wave)
	EventBus.player_died.connect(_on_player_died)

	call_deferred("_fit_camera_to_arena")
	get_viewport().size_changed.connect(_fit_camera_to_arena)


func _fit_camera_to_arena() -> void:
	var bounds := arena.get_bounds()
	var viewport_size := get_viewport().get_visible_rect().size
	var zoom_factor := minf(
		viewport_size.x / bounds.size.x,
		viewport_size.y / bounds.size.y
	) * 0.94
	camera.zoom = Vector2.ONE * zoom_factor


func is_run_active() -> bool:
	return not is_game_over and not is_wave_complete


func _end_run() -> void:
	enemy_spawner.stop()
	wave_manager.pause()
	get_tree().paused = true


func _on_wave_completed() -> void:
	is_wave_complete = true
	_end_run()


func start_next_wave() -> void:
	is_wave_complete = false
	current_wave += 1
	_clear_wave_entities()
	EventBus.wave_index_changed.emit(current_wave)
	_configure_current_wave()
	get_tree().paused = false


func get_current_wave_definition() -> WaveDefinition:
	if not wave_definitions.is_empty():
		var index := mini(current_wave - 1, wave_definitions.size() - 1)
		return wave_definitions[index]
	if wave_definition:
		return wave_definition
	return WaveDefinition.new()


func _configure_current_wave() -> void:
	var wave := get_current_wave_definition()
	wave_manager.configure(wave)
	enemy_spawner.configure(wave, enemy_container, _arena_bounds)


func _clear_wave_entities() -> void:
	for child in enemy_container.get_children():
		child.queue_free()
	for child in pickup_container.get_children():
		child.queue_free()
	for child in projectile_container.get_children():
		child.queue_free()


func _on_player_died() -> void:
	is_game_over = true
	ui.show_game_over()
	_end_run()
