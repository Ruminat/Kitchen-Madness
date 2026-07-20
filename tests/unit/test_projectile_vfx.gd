# GdUnit generated TestSuite
extends GdUnitTestSuite

const PROJECTILE_SCENE := preload("res://scenes/projectiles/projectile.tscn")


class MockEnemy:
	extends Node2D

	func take_damage(_amount: int) -> void:
		pass


func test_set_visual_size_scales_sprite_to_target_width() -> void:
	var projectile: Area2D = auto_free(PROJECTILE_SCENE.instantiate()) as Area2D
	add_child(projectile)
	await _wait_ready(projectile)

	projectile.set_visual_size(24.0)

	var sprite := projectile.get_node("Visual/Sprite") as Sprite2D
	var rendered_width := float(sprite.texture.get_width()) * sprite.scale.x
	assert_float(rendered_width).is_equal_approx(24.0, 0.01)


func test_setup_adds_trail_and_tints_sprite() -> void:
	var projectile: Area2D = auto_free(PROJECTILE_SCENE.instantiate()) as Area2D
	add_child(projectile)
	projectile.setup(Vector2.RIGHT, Rect2(-100, -100, 200, 200), 10, 400.0, 1.0, null, Color.CYAN)
	await _wait_ready(projectile)

	assert_object(projectile.get_node_or_null("Trail")).is_not_null()
	var sprite := projectile.get_node("Visual/Sprite") as Sprite2D
	assert_object(sprite.modulate).is_not_equal(Color.WHITE)


func test_hit_emits_projectile_hit_signal() -> void:
	var projectile: Area2D = auto_free(PROJECTILE_SCENE.instantiate()) as Area2D
	add_child(projectile)
	projectile.setup(Vector2.UP, Rect2(-100, -100, 200, 200), 12, 400.0, 1.0, null, Color.MAGENTA)
	await _wait_ready(projectile)

	var hit := {"count": 0}
	EventBus.projectile_hit.connect(
		func(_world_pos: Vector2, _direction: Vector2, _accent: Color) -> void: hit.count += 1
	)

	var enemy := MockEnemy.new()
	enemy.add_to_group("enemies")
	add_child(enemy)

	projectile._on_body_entered(enemy)
	assert_int(hit.count).is_equal(1)


func _wait_ready(node: Node) -> void:
	if not node.is_node_ready():
		await node.ready
