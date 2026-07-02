extends SceneTree

const GAME_SCENE_PATH := "res://scenes/main/game.tscn"
const DEFAULT_OUTPUT_DIR := "visual-tests/screenshots"
const VIEWPORT_SIZE := Vector2i(1920, 1080)

const CHASER_DEFINITION_PATH := "res://resources/enemies/chaser.tres"
const SPRINTER_DEFINITION_PATH := "res://resources/enemies/sprinter.tres"
const TANK_DEFINITION_PATH := "res://resources/enemies/tank.tres"
const ANT_DEFINITION_PATH := "res://resources/enemies/ant.tres"
const MOTH_DEFINITION_PATH := "res://resources/enemies/moth.tres"

const UPGRADE_PATHS: Array[String] = [
	"res://resources/upgrades/max_health.tres",
	"res://resources/upgrades/damage_boost.tres",
	"res://resources/upgrades/attack_speed.tres",
]
const SHOWCASE_WEAPON_PATHS: Array[String] = [
	"res://resources/weapons/pepper_grinder_gun.tres",
	"res://resources/weapons/boiling_soup_splash.tres",
	"res://resources/weapons/garlic_bomb.tres",
	"res://resources/weapons/onion_ring_blade.tres",
	"res://resources/weapons/kitchen_knife.tres",
	"res://resources/weapons/ladle_boomerang.tres",
]
const PEPPER_GUN_PATH := "res://resources/weapons/pepper_grinder_gun.tres"

const COMBAT_ENEMY_COUNT := 48
const COMBAT_SIM_FRAMES := 16
const PROJECTILE_SETTLE_FRAMES := 10

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
	await _capture_projectile_trails(output_path)
	await _capture_enemy_death(output_path)
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
	await _stage_combat_snapshot(game)
	await _save_screenshot(output_path.path_join("player_surrounded.png"))
	await _unload_game(game)


func _stage_combat_snapshot(game: Node) -> void:
	_spawn_chaotic_enemies(game, COMBAT_ENEMY_COUNT)
	_equip_showcase_weapons(game)
	_set_combat_hud(game)

	_set_weapon_process_enabled(game, true)
	await _settle_frames(COMBAT_SIM_FRAMES)
	_set_weapon_process_enabled(game, false)
	_enable_weapon_visuals(game)

	for projectile in game.get_node("ProjectileContainer").get_children():
		projectile.set_physics_process(true)

	await _settle_frames(PROJECTILE_SETTLE_FRAMES)
	_spawn_extra_damage_numbers(game)
	_spawn_impact_vfx(game)
	_spawn_fan_projectiles(game, load(PEPPER_GUN_PATH) as WeaponDefinition, 10)
	_spawn_fan_projectiles(
		game, load("res://resources/weapons/garlic_bomb.tres") as WeaponDefinition, 8
	)
	_set_combat_hud(game)
	await _settle_frames(4)


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
	var definitions := _enemy_definitions()
	var view_size := Vector2(
		float(VIEWPORT_SIZE.x) / maxf(camera.zoom.x, 0.01),
		float(VIEWPORT_SIZE.y) / maxf(camera.zoom.y, 0.01)
	)

	var spawner := game.get_node("EnemySpawner") as EnemySpawner
	spawner.set_camera_spawn_target(player, view_size)
	spawner.arena_bounds = bounds

	for index in 28:
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


func _capture_projectile_trails(output_path: String) -> void:
	var game := await _load_game()
	await _prepare_game_scene(game)
	_spawn_chaotic_enemies(game, 24)
	_equip_showcase_weapons(game)
	_enable_weapon_visuals(game)
	_spawn_fan_projectiles(game, load(PEPPER_GUN_PATH) as WeaponDefinition, 14)
	_set_combat_hud(game)

	await _settle_frames(6)
	await _save_screenshot(output_path.path_join("projectile_trails.png"))
	await _unload_game(game)


func _capture_enemy_death(output_path: String) -> void:
	var game := await _load_game()
	await _prepare_game_scene(game)
	_spawn_chaotic_enemies(game, 16)
	_equip_showcase_weapons(game)
	_enable_weapon_visuals(game)
	_set_combat_hud(game)

	var container := game.get_node("EnemyContainer")
	var definition := load(CHASER_DEFINITION_PATH) as EnemyDefinition
	var enemy := definition.scene.instantiate() as CharacterBody2D
	container.add_child(enemy)
	enemy.global_position = Vector2(140.0, -20.0)
	if enemy.has_method("set_arena_bounds"):
		enemy.set_arena_bounds(game.get_node("Arena").get_bounds())
	if enemy.has_method("configure"):
		enemy.configure(definition)
	enemy.set_physics_process(false)

	if enemy.has_method("take_damage"):
		enemy.take_damage(definition.max_health)

	await _settle_frames(3)
	await _save_screenshot(output_path.path_join("enemy_death_burst.png"))
	await _unload_game(game)


func _capture_upgrade_menu(output_path: String) -> void:
	var game := await _load_game()
	await _prepare_game_scene(game)
	_spawn_chaotic_enemies(game, 22)
	_equip_showcase_weapons(game)
	_enable_weapon_visuals(game)
	_spawn_fan_projectiles(game, load(PEPPER_GUN_PATH) as WeaponDefinition, 8)
	_set_combat_hud(game)

	var ui := game.get_node("UI")
	if ui.has_method("show_level_up_options"):
		ui.show_level_up_options(_load_upgrades())
	paused = true

	await _save_screenshot(output_path.path_join("upgrade_menu.png"))
	await _unload_game(game)


func _capture_dead_screen(output_path: String) -> void:
	var game := await _load_game()
	await _prepare_game_scene(game)
	_spawn_chaotic_enemies(game, 30)
	_equip_showcase_weapons(game)
	_enable_weapon_visuals(game)
	_spawn_fan_projectiles(game, load(PEPPER_GUN_PATH) as WeaponDefinition, 10)
	_set_combat_hud(game, 0.0, 58, 18)

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
	game.set("skip_character_select", true)
	root.add_child(game)
	await _settle_frames(2)
	_dismiss_character_select(game)
	_freeze_live_systems(game)
	await _settle_frames(2)
	return game


func _dismiss_character_select(game: Node) -> void:
	var overlay := game.get_node_or_null("UI/CharacterSelectOverlay") as CanvasItem
	if overlay:
		overlay.visible = false
	paused = false


func _prepare_game_scene(game: Node) -> void:
	_dismiss_character_select(game)
	_freeze_live_systems(game)
	_clear_children(game.get_node("EnemyContainer"))
	_clear_children(game.get_node("ProjectileContainer"))
	_clear_children(game.get_node("PickupContainer"))
	_clear_children(game.get_node_or_null("VFXContainer"))

	await process_frame
	var camera := game.get_node("Camera2D") as Camera2D
	camera.global_position = Vector2.ZERO
	camera.make_current()


func _freeze_live_systems(game: Node) -> void:
	var spawner := game.get_node_or_null("EnemySpawner")
	if spawner and spawner.has_method("stop"):
		spawner.stop()

	var level_manager := game.get_node_or_null("LevelManager")
	if level_manager and level_manager.has_method("pause"):
		level_manager.pause()

	var player := game.get_node("Player") as Node2D
	player.global_position = Vector2.ZERO
	player.set_physics_process(false)

	_set_weapon_process_enabled(game, false)


func _set_weapon_process_enabled(game: Node, enabled: bool) -> void:
	var player := game.get_node("Player") as Node2D
	if not player.has_node("WeaponController"):
		return

	var weapon_controller := player.get_node("WeaponController")
	weapon_controller.set_process(enabled)
	weapon_controller.set_physics_process(false)
	for weapon in weapon_controller.get_children():
		weapon.set_process(enabled)
		weapon.set_physics_process(false)


func _enable_weapon_visuals(game: Node) -> void:
	var player := game.get_node("Player") as Node2D
	if not player.has_node("WeaponController"):
		return

	var weapon_controller := player.get_node("WeaponController") as WeaponController
	weapon_controller.set_process(true)
	for weapon in weapon_controller.get_children():
		weapon.set_process(false)
		if weapon.has_method("play_fire_feedback") and randf() > 0.45:
			weapon.play_fire_feedback()


func _equip_showcase_weapons(game: Node) -> void:
	var player := game.get_node("Player")
	var weapon_controller := player.get_node("WeaponController") as WeaponController
	var projectile_container := game.get_node("ProjectileContainer") as Node2D
	var bounds: Rect2 = game.get_node("Arena").get_bounds()

	weapon_controller.clear_weapons()
	weapon_controller.setup(projectile_container, bounds)
	for path in SHOWCASE_WEAPON_PATHS:
		weapon_controller.add_weapon(load(path) as WeaponDefinition)


func _event_bus() -> Node:
	return root.get_node_or_null("EventBus")


func _set_combat_hud(
	_game: Node,
	seconds_remaining: float = 7.0,
	kills: int = 38,
	grease: int = 127,
	current_hp: int = 68,
	max_hp: int = 100,
	xp_current: int = 42,
	xp_to_next: int = 80,
	level: int = 6
) -> void:
	var bus := _event_bus()
	if bus == null:
		return

	bus.level_time_changed.emit(600.0 - seconds_remaining, seconds_remaining)
	bus.gold_changed.emit(grease)
	bus.player_health_changed.emit(current_hp, max_hp)
	bus.xp_changed.emit(xp_current, xp_to_next, level)

	for _index in kills:
		bus.enemy_killed.emit(null, null)


func _spawn_chaotic_enemies(game: Node, count: int) -> void:
	var container := game.get_node("EnemyContainer")
	var arena := game.get_node("Arena")
	var definitions := _enemy_definitions()

	for index in count:
		var definition: EnemyDefinition = definitions[index % definitions.size()]
		var enemy := definition.scene.instantiate() as CharacterBody2D
		container.add_child(enemy)
		enemy.global_position = _chaotic_enemy_position(index, count)
		if enemy.has_method("set_arena_bounds"):
			enemy.set_arena_bounds(arena.get_bounds())
		if enemy.has_method("configure"):
			enemy.configure(definition)
		enemy.set_physics_process(false)


func _chaotic_enemy_position(index: int, total: int) -> Vector2:
	var ring_count := maxi(int(float(total) * 0.62), 1)
	if index < ring_count:
		var ring_direction := Vector2.RIGHT.rotated(TAU * float(index) / float(ring_count))
		var radius := 88.0 + 84.0 * float(index % 4) / 3.0
		return ring_direction * radius

	var cluster_index := index - ring_count
	var cluster_direction := Vector2.RIGHT.rotated(
		-PI * 0.75 + TAU * float(cluster_index % 9) / 9.0
	)
	var cluster_radius := 38.0 + 28.0 * float(cluster_index % 5)
	return cluster_direction * cluster_radius


func _spawn_fan_projectiles(game: Node, weapon_def: WeaponDefinition, count: int) -> void:
	var player := game.get_node("Player") as Node2D
	var projectile_container := game.get_node("ProjectileContainer") as Node2D
	var bounds: Rect2 = game.get_node("Arena").get_bounds()

	for index in count:
		var projectile := weapon_def.projectile_scene.instantiate()
		projectile_container.add_child(projectile)
		var angle := -PI * 0.55 + TAU * float(index) / float(count)
		var direction := Vector2.RIGHT.rotated(angle)
		var spawn_offset := direction * (28.0 + float(index % 4) * 18.0)
		projectile.global_position = player.global_position + spawn_offset
		if projectile.has_method("setup"):
			projectile.setup(
				direction,
				bounds,
				weapon_def.damage,
				weapon_def.projectile_speed,
				weapon_def.projectile_lifetime,
				weapon_def.projectile_texture,
				weapon_def.vfx_accent
			)
		projectile.set_physics_process(false)


func _spawn_extra_damage_numbers(game: Node) -> void:
	var bus := _event_bus()
	if bus == null:
		return

	var enemies := game.get_node("EnemyContainer").get_children()
	var amounts := [9, 14, 22, 18, 31, 12, 47, 16, 25, 38, 11, 29]
	for index in mini(enemies.size(), amounts.size()):
		var enemy := enemies[index] as Node2D
		if enemy == null:
			continue
		var is_crit := index % 3 == 0
		bus.damage_dealt.emit(enemy.global_position, amounts[index], is_crit)


func _spawn_impact_vfx(_game: Node) -> void:
	var bus := _event_bus()
	if bus == null:
		return

	var accents := [
		Color(0.85, 0.65, 0.25, 1.0),
		Color(1.0, 0.55, 0.15, 1.0),
		Color(0.75, 0.95, 0.55, 1.0),
		Color(0.95, 0.9, 1.0, 1.0),
	]
	var offsets := [
		Vector2(120.0, -40.0),
		Vector2(-95.0, 55.0),
		Vector2(60.0, 130.0),
		Vector2(-140.0, -70.0),
		Vector2(180.0, 30.0),
		Vector2(-30.0, -150.0),
	]

	for index in offsets.size():
		var direction: Vector2 = offsets[index].normalized()
		bus.projectile_hit.emit(offsets[index], direction, accents[index % accents.size()])


func _enemy_definitions() -> Array[EnemyDefinition]:
	return [
		load(CHASER_DEFINITION_PATH) as EnemyDefinition,
		load(SPRINTER_DEFINITION_PATH) as EnemyDefinition,
		load(TANK_DEFINITION_PATH) as EnemyDefinition,
		load(ANT_DEFINITION_PATH) as EnemyDefinition,
		load(MOTH_DEFINITION_PATH) as EnemyDefinition,
	]


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
