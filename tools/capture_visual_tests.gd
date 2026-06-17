extends SceneTree

const GAME_SCENE_PATH := "res://scenes/main/game.tscn"
const DEFAULT_OUTPUT_DIR := "visual-tests/screenshots"
const VIEWPORT_SIZE := Vector2i(1920, 1080)

const CHASER_DEFINITION_PATH := "res://resources/enemies/chaser.tres"
const SPRINTER_DEFINITION_PATH := "res://resources/enemies/sprinter.tres"
const TANK_DEFINITION_PATH := "res://resources/enemies/tank.tres"
const UPGRADE_PATHS: Array[String] = [
	"res://resources/upgrades/max_health.tres",
	"res://resources/upgrades/damage_boost.tres",
	"res://resources/upgrades/attack_speed.tres",
]

var _output_dir := DEFAULT_OUTPUT_DIR


func _initialize() -> void:
	_run()


func _run() -> void:
	_parse_args()
	root.size = VIEWPORT_SIZE
	seed(1)

	var output_path := ProjectSettings.globalize_path("res://%s" % _output_dir)
	var error := DirAccess.make_dir_recursive_absolute(output_path)
	if error != OK:
		push_error("Could not create visual test output dir: %s" % output_path)
		quit(1)
		return

	await _capture_player_surrounded(output_path)
	await _capture_off_camera_spawns(output_path)
	await _capture_upgrade_menu(output_path)
	await _capture_dead_screen(output_path)

	print("Visual screenshots saved to %s" % output_path)
	quit()


func _parse_args() -> void:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--output-dir="):
			_output_dir = argument.trim_prefix("--output-dir=").trim_prefix("res://")


func _capture_player_surrounded(output_path: String) -> void:
	var game := await _load_game()
	await _prepare_game_scene(game)
	_spawn_enemy_ring(game, 18)
	await _save_screenshot(output_path.path_join("player_surrounded.png"))
	await _unload_game(game)


func _capture_off_camera_spawns(output_path: String) -> void:
	var game := await _load_game()
	await _prepare_game_scene(game)

	var player := game.get_node("Player") as Node2D
	var arena := game.get_node("Arena")
	var offset := Vector2(880.0, 320.0)
	player.global_position = offset

	var camera := game.get_node("Camera2D") as Camera2D
	camera.global_position = offset
	camera.make_current()
	await process_frame

	_spawn_off_camera_enemies(game, arena.get_bounds(), camera)
	await _save_screenshot(output_path.path_join("off_camera_spawns.png"))
	await _unload_game(game)


func _spawn_off_camera_enemies(game: Node, bounds: Rect2, camera: Camera2D) -> void:
	var container := game.get_node("EnemyContainer")
	var player := game.get_node("Player") as Node2D
	var definitions := [
		load(CHASER_DEFINITION_PATH) as EnemyDefinition,
		load(SPRINTER_DEFINITION_PATH) as EnemyDefinition,
		load(TANK_DEFINITION_PATH) as EnemyDefinition,
	]
	var view_size := Vector2(
		float(VIEWPORT_SIZE.x) / maxf(camera.zoom.x, 0.01),
		float(VIEWPORT_SIZE.y) / maxf(camera.zoom.y, 0.01)
	)

	var spawner := game.get_node("EnemySpawner") as EnemySpawner
	spawner.set_camera_spawn_target(player, view_size)
	spawner.arena_bounds = bounds

	for index in 24:
		var definition: EnemyDefinition = definitions[index % definitions.size()]
		var enemy := definition.scene.instantiate() as CharacterBody2D
		container.add_child(enemy)
		var spawn_position := spawner._random_offscreen_position()
		enemy.global_position = spawn_position.move_toward(player.global_position, 55.0)
		if enemy.has_method("set_arena_bounds"):
			enemy.set_arena_bounds(bounds)
		if enemy.has_method("configure"):
			enemy.configure(definition)
		enemy.set_physics_process(false)


func _capture_upgrade_menu(output_path: String) -> void:
	var game := await _load_game()
	await _prepare_game_scene(game)
	_spawn_enemy_ring(game, 10)

	var ui := game.get_node("UI")
	if ui.has_method("show_level_up_options"):
		ui.show_level_up_options(_load_upgrades())
	paused = true

	await _save_screenshot(output_path.path_join("upgrade_menu.png"))
	await _unload_game(game)


func _capture_dead_screen(output_path: String) -> void:
	var game := await _load_game()
	await _prepare_game_scene(game)
	_spawn_enemy_ring(game, 14)

	game.set("is_game_over", true)
	var ui := game.get_node("UI")
	if ui.has_method("show_game_over"):
		ui.show_game_over()
	paused = true

	await _save_screenshot(output_path.path_join("dead_screen.png"))
	await _unload_game(game)


func _load_game() -> Node:
	paused = false
	var game_scene := load(GAME_SCENE_PATH) as PackedScene
	var game := game_scene.instantiate()
	root.add_child(game)
	_freeze_live_systems(game)
	await _settle_frames(2)
	return game


func _prepare_game_scene(game: Node) -> void:
	_freeze_live_systems(game)
	_clear_children(game.get_node("EnemyContainer"))
	_clear_children(game.get_node("ProjectileContainer"))
	_clear_children(game.get_node("PickupContainer"))

	await process_frame
	var camera := game.get_node("Camera2D") as Camera2D
	camera.global_position = Vector2.ZERO
	camera.make_current()


func _freeze_live_systems(game: Node) -> void:
	var spawner := game.get_node_or_null("EnemySpawner")
	if spawner and spawner.has_method("stop"):
		spawner.stop()

	var wave_manager := game.get_node_or_null("WaveManager")
	if wave_manager and wave_manager.has_method("pause"):
		wave_manager.pause()

	var player := game.get_node("Player") as Node2D
	player.global_position = Vector2.ZERO
	player.set_physics_process(false)

	if player.has_node("WeaponController"):
		var weapon_controller := player.get_node("WeaponController")
		weapon_controller.set_process(false)
		weapon_controller.set_physics_process(false)
		for weapon in weapon_controller.get_children():
			weapon.set_process(false)
			weapon.set_physics_process(false)


func _spawn_enemy_ring(game: Node, count: int) -> void:
	var container := game.get_node("EnemyContainer")
	var arena := game.get_node("Arena")
	var definitions := [
		load(CHASER_DEFINITION_PATH) as EnemyDefinition,
		load(SPRINTER_DEFINITION_PATH) as EnemyDefinition,
		load(TANK_DEFINITION_PATH) as EnemyDefinition,
	]

	for index in count:
		var definition: EnemyDefinition = definitions[index % definitions.size()]
		var enemy := definition.scene.instantiate() as CharacterBody2D
		container.add_child(enemy)
		var ring_direction := Vector2.RIGHT.rotated(TAU * float(index) / float(count))
		enemy.global_position = ring_direction * _ring_radius(index)
		if enemy.has_method("set_arena_bounds"):
			enemy.set_arena_bounds(arena.get_bounds())
		if enemy.has_method("configure"):
			enemy.configure(definition)
		enemy.set_physics_process(false)


func _ring_radius(index: int) -> float:
	if index % 3 == 0:
		return 118.0
	return 168.0


func _load_upgrades() -> Array[Resource]:
	var upgrades: Array[Resource] = []
	for path in UPGRADE_PATHS:
		var upgrade := load(path) as Resource
		if upgrade:
			upgrades.append(upgrade)
	return upgrades


func _clear_children(node: Node) -> void:
	for child in node.get_children():
		child.queue_free()


func _save_screenshot(path: String) -> void:
	await _settle_frames(3)
	RenderingServer.force_draw()
	await process_frame

	var image := root.get_texture().get_image()
	var error := image.save_png(path)
	if error != OK:
		push_error("Could not save visual screenshot: %s" % path)
		quit(1)
		return

	print("Saved %s" % path)


func _settle_frames(count: int) -> void:
	for _index in count:
		await process_frame


func _unload_game(game: Node) -> void:
	paused = false
	game.queue_free()
	await process_frame
