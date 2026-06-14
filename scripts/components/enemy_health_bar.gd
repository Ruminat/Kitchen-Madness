extends Node2D

const BAR_WIDTH := 30.0
const BAR_HEIGHT := 3.0
const Y_OFFSET := -26.0

var _health: HealthComponent


func _ready() -> void:
	_health = get_parent().get_node_or_null("HealthComponent") as HealthComponent
	if _health:
		_health.health_changed.connect(_on_health_changed)
	queue_redraw()


func _on_health_changed(_current: int, _maximum: int) -> void:
	queue_redraw()


func _draw() -> void:
	if _health == null or not _health.is_alive():
		return

	var ratio := float(_health.current_health) / float(maxi(_health.max_health, 1))
	var origin := Vector2(-BAR_WIDTH * 0.5, Y_OFFSET)
	draw_rect(Rect2(origin, Vector2(BAR_WIDTH, BAR_HEIGHT)), Color(0.08, 0.08, 0.1, 0.85))
	draw_rect(Rect2(origin, Vector2(BAR_WIDTH * ratio, BAR_HEIGHT)), Color(0.82, 0.22, 0.24, 0.95))
