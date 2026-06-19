extends Node
## Global signal hub — gameplay emits, UI/systems listen.

signal damage_dealt(world_pos: Vector2, amount: int, is_crit: bool)
signal enemy_killed(enemy: Node, killer: Node)
signal projectile_hit(world_pos: Vector2, direction: Vector2, accent: Color)
signal player_health_changed(current: int, maximum: int)
signal player_died
signal xp_changed(current: int, to_next: int, level: int)
signal level_up(level: int)
signal pickup_collected(type: StringName, world_pos: Vector2, value: int)
signal wave_time_changed(seconds_remaining: float)
signal wave_completed
signal gold_changed(gold: int)
signal wave_index_changed(wave: int)
