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
@onready var balance_metrics: BalanceMetrics = BalanceMetrics.new()


func _ready() -> void:
	add_child(balance_metrics)
	get_tree().paused = false

	_arena_bounds = arena.get_global_bounds()
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

	_connect_metrics_signals()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_save_run_on_quit()


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

	var clamped_position := _clamp_camera_position(player.global_position)
	camera.global_position = clamped_position
	enemy_spawner.set_camera_focus(clamped_position)


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
	var character: CharacterDefinition = starting_character
	if character == null and not _should_auto_start_character():
		get_tree().paused = true
		character = await ui.request_character_selection(CharacterRoster.load_roster())
	if character == null:
		character = CharacterRoster.get_default()
	player.configure(character)
	_start_metrics_tracking()
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
	_end_wave_metrics()
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
	var duration := WaveDefinition.resolve_duration(
		wave, current_wave, maxi(wave_definitions.size(), 1)
	)
	wave_manager.configure(wave, duration)
	enemy_spawner.set_camera_spawn_target(player, _get_camera_world_view_size())
	enemy_spawner.configure(wave, enemy_container, _arena_bounds, current_wave)
	_start_wave_metrics()


func _clear_wave_entities() -> void:
	for child in enemy_container.get_children():
		child.queue_free()
	for child in pickup_container.get_children():
		child.queue_free()
	for child in projectile_container.get_children():
		child.queue_free()


func _on_player_died() -> void:
	is_game_over = true
	balance_metrics.end_run(false)
	_emit_run_ended_metrics("death")
	ui.show_game_over()
	_end_run()


func _connect_metrics_signals() -> void:
	EventBus.metrics_damage_dealt.connect(_on_metrics_damage_dealt)
	EventBus.metrics_damage_taken.connect(_on_metrics_damage_taken)
	EventBus.metrics_gold_earned.connect(_on_metrics_gold_earned)
	EventBus.enemy_killed.connect(_on_enemy_killed_metrics)
	EventBus.pickup_collected.connect(_on_pickup_collected_metrics)

	balance_metrics.metrics_report_ready.connect(_on_wave_metrics_ready)


func _on_metrics_damage_dealt(amount: int, weapon_id: String) -> void:
	balance_metrics.record_damage_dealt(amount, weapon_id)


func _on_metrics_damage_taken(amount: int) -> void:
	balance_metrics.record_damage_taken(amount)


func _on_metrics_gold_earned(amount: int) -> void:
	balance_metrics.record_gold_earned(amount)


func _on_enemy_killed_metrics(enemy: Node, _killer: Node) -> void:
	var enemy_type := &"unknown"
	if enemy and "definition" in enemy and enemy.definition != null:
		enemy_type = StringName(enemy.definition.id)
	balance_metrics.record_kill(enemy_type)


func _on_pickup_collected_metrics(type: StringName, _world_pos: Vector2, value: int) -> void:
	if type == &"health":
		balance_metrics.record_health_pickup()
	elif type.begins_with(&"xp"):
		balance_metrics.record_xp_collected(value)


func _on_wave_metrics_ready(report: Dictionary) -> void:
	print(
		(
			"Wave %d Metrics: DPS=%.1f, Kills=%d, Damage Dealt=%d, Damage Taken=%d, XP=%d, Gold=%d"
			% [
				report.get("wave_number", 0),
				report.get("effective_dps", 0.0),
				report.get("total_kills", 0),
				report.get("damage_dealt", 0),
				report.get("damage_taken", 0),
				report.get("xp_collected", 0),
				report.get("gold_earned", 0)
			]
		)
	)
	EventBus.metrics_wave_ended.emit(report)


func _emit_run_ended_metrics(end_reason: String = "unknown") -> void:
	var summary := balance_metrics.get_run_summary()
	summary["final_wave"] = current_wave
	summary["level_reached"] = _get_player_level()
	summary["weapons"] = _get_player_weapon_ids()
	summary["end_reason"] = end_reason
	EventBus.metrics_run_ended.emit(summary)


func _save_run_on_quit() -> void:
	if is_game_over or not balance_metrics.is_tracking():
		return

	if balance_metrics.get_current_wave_summary().has("wave_number"):
		_end_wave_metrics()

	balance_metrics.end_run(false)
	_emit_run_ended_metrics("quit")


func _get_player_level() -> int:
	var xp_system := $XpSystem as XpSystem
	return 1 if xp_system == null else xp_system.level


func _get_player_weapon_ids() -> Array[String]:
	if player == null or player.weapon_controller == null:
		return []
	return player.weapon_controller.get_owned_weapon_ids()


func _start_metrics_tracking() -> void:
	var character: CharacterDefinition = player.get_character()
	var character_id := character.id if character else "unknown"
	balance_metrics.start_run(character_id)
	EventBus.metrics_run_started.emit(character_id)


func _start_wave_metrics() -> void:
	var xp_system := $XpSystem as XpSystem
	var player_level := 1 if xp_system == null else xp_system.level
	balance_metrics.start_wave(current_wave, player_level)
	EventBus.metrics_wave_started.emit(current_wave, player_level)


func _end_wave_metrics() -> void:
	var xp_system := $XpSystem as XpSystem
	var player_level := 1 if xp_system == null else xp_system.level
	balance_metrics.end_wave(player_level)
