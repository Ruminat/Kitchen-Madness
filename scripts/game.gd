extends Node2D

@export var wave_definition: WaveDefinition

var is_wave_complete := false
var is_game_over := false

@onready var arena: Arena = $Arena
@onready var player: CharacterBody2D = $Player
@onready var enemy_container: Node2D = $EnemyContainer
@onready var projectile_container: Node2D = $ProjectileContainer
@onready var wave_manager: WaveManager = $WaveManager
@onready var enemy_spawner: EnemySpawner = $EnemySpawner
@onready var ui: CanvasLayer = $UI


func _ready() -> void:
	var bounds := arena.get_bounds()
	var wave := wave_definition if wave_definition else WaveDefinition.new()

	player.setup(bounds, projectile_container)
	wave_manager.configure(wave)
	enemy_spawner.configure(wave, enemy_container, bounds)

	EventBus.wave_completed.connect(_on_wave_completed)
	EventBus.player_died.connect(_on_player_died)


func _unhandled_input(event: InputEvent) -> void:
	if not is_game_over and not is_wave_complete:
		return
	if event.is_action_pressed("restart"):
		get_tree().reload_current_scene()


func _on_wave_completed() -> void:
	is_wave_complete = true
	enemy_spawner.stop()
	ui.show_wave_complete()


func _on_player_died() -> void:
	is_game_over = true
	enemy_spawner.stop()
	wave_manager.pause()
	ui.show_game_over()
