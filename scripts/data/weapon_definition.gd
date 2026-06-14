class_name WeaponDefinition
extends Resource

@export var id: String = ""
@export var weapon_script: Script
@export var damage: int = 15
@export var fire_rate: float = 0.45
@export var projectile_scene: PackedScene
@export var pellet_count: int = 1
@export var spread_degrees: float = 0.0
@export var projectile_speed: float = 480.0
@export var projectile_lifetime: float = 2.0
@export var orbit_radius: float = 60.0
@export var orbit_speed: float = 4.0
