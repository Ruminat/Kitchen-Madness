class_name WaveDefinition
extends Resource

@export var duration: float = 30.0
@export var spawn_interval: float = 1.4
@export var max_enemies: int = 40
@export var enemy_weights: Array[EnemySpawnEntry] = []
@export var fallback_enemy_scene: PackedScene
