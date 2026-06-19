extends Node2D

@export var wave_definition: WaveDefinition
@export var wave_definitions: Array[WaveDefinition] = []
@export var health_drop: DropDefinition
@export var starting_character: CharacterDefinition
@export var skip_character_select := false

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
@onready var vfx_container: Node2D = $VFXContainer
@onready var wave_manager: WaveManager = $WaveManager
@onready var enemy_spawner: EnemySpawner = $EnemySpawner
@onready var loot_spawner: LootSpawner = $LootSpawner
@onready var level_up_manager: Node = $LevelUpManager
@onready var gold_system: GoldSystem = $GoldSystem
@onready var shop_manager: ShopManager = $ShopManager
@onready var vfx_manager: VfxManager = $VfxManager
@onready var ui: CanvasLayer = $UI


func _ready() -> void:
	get_tree().paused = false

	_arena_bounds = arena.get_bounds()
	await _apply_starting_character()
	player.setup(_arena_bounds, projectile_container)
	_fit_camera_to_play_area()
	_follow_player_camera()
	_configure_current_wave()
	loot_spawner.configure(pickup_container, health_drop)
	vfx_manager.configure(vfx_container)
	if level_up_manager.has_method("configure"):
		level_up_manager.configure(player, ui, Callable(self, "is_run_active"))
	if shop_manager.has_method("configure"):
		shop_manager.configure(player, ui, gold_system, Callable(self, "start_next_wave"))

	EventBus.wave_completed.connect(_on_wave_completed)
	EventBus.wave_index_changed.emit(current_wave)
	EventBus.player_died.connect(_on_player_died)

	get_viewport().size_changed.connect(_on_viewport_size_changed)


func _process(_delta: float) -> void:
	_follow_player_camera()


func _fit_camera_to_play_area() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	var zoom_factor := (
		minf(
			viewport_size.x / Arena.DEFAULT_VIEW_SIZE.x, viewport_size.y / Arena.DEFAULT_VIEW_SIZE.y
		)
		* 0.94
	)
	camera.zoom = Vector2.ONE * zoom_factor


func _on_viewport_size_changed() -> void:
	_fit_camera_to_play_area()
	_follow_player_camera()
	enemy_spawner.set_camera_view_size(_get_camera_world_view_size())


func _follow_player_camera() -> void:
	if player == null or camera == null:
		return

	camera.global_position = _clamp_camera_position(player.global_position)


func _clamp_camera_position(target_position: Vector2) -> Vector2:
	var half_view := _get_camera_world_view_size() * 0.5
	return Vector2(
		_clamp_axis_to_bounds(
			target_position.x, _arena_bounds.position.x, _arena_bounds.end.x, half_view.x
		),
		_clamp_axis_to_bounds(
			target_position.y, _arena_bounds.position.y, _arena_bounds.end.y, half_view.y
		)
	)


func _clamp_axis_to_bounds(value: float, minimum: float, maximum: float, half_view: float) -> float:
	if maximum - minimum <= half_view * 2.0:
		return (minimum + maximum) * 0.5
	return clampf(value, minimum + half_view, maximum - half_view)


func _get_camera_world_view_size() -> Vector2:
	var viewport_size := get_viewport().get_visible_rect().size
	return Vector2(
		viewport_size.x / maxf(camera.zoom.x, 0.01), viewport_size.y / maxf(camera.zoom.y, 0.01)
	)


func is_run_active() -> bool:
	return not is_game_over and not is_wave_complete


func _apply_starting_character() -> void:
	var character := starting_character
	if character == null and not _should_auto_start_character():
		get_tree().paused = true
		character = await ui.request_character_selection(CharacterRoster.load_roster())
	if character == null:
		character = CharacterRoster.get_default()
	player.configure(character)
	if get_tree().paused and not is_game_over and not is_wave_complete:
		get_tree().paused = false


func _should_auto_start_character() -> bool:
	return skip_character_select or DisplayServer.get_name() == "headless"


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
	enemy_spawner.set_camera_spawn_target(player, _get_camera_world_view_size())
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
