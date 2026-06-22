class_name WeaponDefinition
extends Resource

enum WeaponType { PROJECTILE, ORBIT, BURST, BOOMERANG, TURRET, MELEE }

@export var id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var icon: Texture2D
@export var weapon_type: WeaponType = WeaponType.PROJECTILE
@export var weapon_script: Script
@export var damage: int = 15
@export var fire_rate: float = 0.45
@export var projectile_scene: PackedScene
@export var projectile_texture: Texture2D
@export var pellet_count: int = 1
@export var spread_degrees: float = 0.0
@export var projectile_speed: float = 480.0
@export var projectile_lifetime: float = 2.0
@export var orbit_radius: float = 60.0
@export var orbit_speed: float = 4.0
@export var turret_duration: float = 5.0
@export var turret_fire_rate: float = 0.5
@export var melee_range: float = 48.0
@export var melee_arc_degrees: float = 60.0
@export var melee_knockback: float = 0.0
@export var vfx_accent: Color = Color(0.95, 0.82, 0.45, 1.0)
@export var damage_number_color: Color = Color(0, 0, 0, 0)  ## Zero alpha = use default colors
