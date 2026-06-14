extends Node2D

const WAVE_DURATION := 30.0
const SPAWN_INTERVAL := 1.4
const MAX_ENEMIES := 40
const ARENA_SIZE := Vector2(880.0, 480.0)

@export var enemy_scene: PackedScene

var arena_bounds := Rect2()
var wave_time_remaining := WAVE_DURATION
var kills := 0
var is_wave_complete := false
var is_game_over := false

@onready var player: CharacterBody2D = $Player
@onready var enemy_container: Node2D = $EnemyContainer
@onready var ui: CanvasLayer = $UI
@onready var spawn_timer: Timer = $SpawnTimer
@onready var weapon: Node2D = $Player/ProjectileWeapon


func _ready() -> void:
	arena_bounds = Rect2(-ARENA_SIZE * 0.5, ARENA_SIZE)

	player.set_arena_bounds(arena_bounds)
	player.health_changed.connect(ui.update_health)
	player.died.connect(_on_player_died)
	ui.update_health(player.health, player.MAX_HEALTH)
	ui.update_kills(kills)
	ui.update_timer(wave_time_remaining)

	weapon.set_arena_bounds(arena_bounds)

	spawn_timer.wait_time = SPAWN_INTERVAL
	spawn_timer.timeout.connect(_spawn_enemy)
	spawn_timer.start()

	_spawn_enemy()


func _process(delta: float) -> void:
	if is_game_over or is_wave_complete:
		return

	wave_time_remaining -= delta
	ui.update_timer(wave_time_remaining)

	if wave_time_remaining <= 0.0:
		_complete_wave()


func _unhandled_input(event: InputEvent) -> void:
	if not is_game_over and not is_wave_complete:
		return
	if event.is_action_pressed("restart"):
		get_tree().reload_current_scene()


func _spawn_enemy() -> void:
	if is_game_over or is_wave_complete:
		return
	if enemy_container.get_child_count() >= MAX_ENEMIES:
		return

	var enemy := enemy_scene.instantiate() as CharacterBody2D
	enemy.global_position = _random_edge_position()
	enemy.set_arena_bounds(arena_bounds)
	enemy.died.connect(_on_enemy_died)
	enemy_container.add_child(enemy)


func _random_edge_position() -> Vector2:
	var side := randi() % 4
	var margin := 20.0
	var bounds := arena_bounds

	match side:
		0:
			return Vector2(
				randf_range(bounds.position.x + margin, bounds.end.x - margin),
				bounds.position.y + margin
			)
		1:
			return Vector2(
				randf_range(bounds.position.x + margin, bounds.end.x - margin),
				bounds.end.y - margin
			)
		2:
			return Vector2(
				bounds.position.x + margin,
				randf_range(bounds.position.y + margin, bounds.end.y - margin)
			)
		_:
			return Vector2(
				bounds.end.x - margin,
				randf_range(bounds.position.y + margin, bounds.end.y - margin)
			)


func _on_enemy_died(_enemy: CharacterBody2D) -> void:
	kills += 1
	ui.update_kills(kills)


func _complete_wave() -> void:
	is_wave_complete = true
	spawn_timer.stop()
	ui.show_wave_complete()


func _on_player_died() -> void:
	is_game_over = true
	spawn_timer.stop()
	ui.show_game_over()
