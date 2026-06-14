extends Node2D

@export var wave_definition: WaveDefinition

var is_wave_complete := false
var is_game_over := false

@onready var arena: Arena = $Arena
@onready var camera: Camera2D = $Camera2D
@onready var player: CharacterBody2D = $Player
@onready var enemy_container: Node2D = $EnemyContainer
@onready var projectile_container: Node2D = $ProjectileContainer
@onready var wave_manager: WaveManager = $WaveManager
@onready var enemy_spawner: EnemySpawner = $EnemySpawner
@onready var ui: CanvasLayer = $UI


func _ready() -> void:
	get_tree().paused = false

	var bounds := arena.get_bounds()
	var wave := wave_definition if wave_definition else WaveDefinition.new()

	player.setup(bounds, projectile_container)
	wave_manager.configure(wave)
	enemy_spawner.configure(wave, enemy_container, bounds)

	EventBus.wave_completed.connect(_on_wave_completed)
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
	ui.show_wave_complete()
	_end_run()


func _on_player_died() -> void:
	is_game_over = true
	ui.show_game_over()
	_end_run()
