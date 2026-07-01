# GdUnit generated TestSuite
extends GdUnitTestSuite

const GAME_SCENE := preload("res://scenes/main/game.tscn")

const PANEL_SIZE := Vector2(900.0, 560.0)
const ROW_CENTER_Y_RATIOS := [0.3125, 0.441, 0.57, 0.698]
const LABEL_LEFT_MARGIN := 16.0
const BUTTON_BOTTOM_MARGIN := 8.0
const BUTTON_GROUP_CENTER_RATIO := 0.5
const TOLERANCE := 18.0
const STRICT_TOLERANCE := 1.0


func before() -> void:
	get_tree().paused = false


func after() -> void:
	get_tree().paused = false


func test_settings_button_opens_asset_backed_settings_overlay() -> void:
	var game: Node2D = auto_free(GAME_SCENE.instantiate())
	game.skip_character_select = true
	add_child(game)
	await _wait_ready(game)

	var ui := game.get_node("UI")
	var settings_button := ui.get_node("SettingsButton") as TextureButton
	settings_button.pressed.emit()
	await get_tree().process_frame

	var overlay := ui.get_node("SettingsOverlay") as CanvasItem
	var panel_art := (
		ui.get_node("SettingsOverlay/CenterContainer/PanelContainer/PanelArt") as TextureRect
	)

	assert_bool(overlay.visible).is_true()
	assert_bool(get_tree().paused).is_true()
	assert_object(settings_button.texture_normal).is_not_null()
	assert_object(panel_art.texture).is_not_null()


func test_escape_toggles_settings_overlay() -> void:
	var game: Node2D = auto_free(GAME_SCENE.instantiate())
	game.skip_character_select = true
	add_child(game)
	await _wait_ready(game)

	var ui := game.get_node("UI")
	ui._unhandled_input(_escape_event())
	await get_tree().process_frame

	assert_bool(ui.get_node("SettingsOverlay").visible).is_true()
	assert_bool(get_tree().paused).is_true()

	ui._unhandled_input(_escape_event())
	await get_tree().process_frame

	assert_bool(ui.get_node("SettingsOverlay").visible).is_false()
	assert_bool(get_tree().paused).is_false()


func test_settings_controls_align_to_panel_art_bands() -> void:
	var game: Node2D = auto_free(GAME_SCENE.instantiate())
	game.skip_character_select = true
	add_child(game)
	await _wait_ready(game)

	var ui := game.get_node("UI")
	ui._show_settings()
	await get_tree().process_frame

	var panel := ui.get_node("SettingsOverlay/CenterContainer/PanelContainer") as Control
	var panel_rect := panel.get_global_rect()
	assert_vector(panel_rect.size).is_equal_approx(PANEL_SIZE, Vector2(0.1, 0.1))

	var title_label := (
		ui.get_node("SettingsOverlay/CenterContainer/PanelContainer/SettingsContent/TitleLabel")
		as Label
	)
	assert_bool(title_label.visible).is_false()

	var rows := [
		ui.get_node("SettingsOverlay/CenterContainer/PanelContainer/SettingsContent/ResolutionRow"),
		ui.get_node(
			"SettingsOverlay/CenterContainer/PanelContainer/SettingsContent/MusicVolumeRow"
		),
		ui.get_node(
			"SettingsOverlay/CenterContainer/PanelContainer/SettingsContent/SoundVolumeRow"
		),
		ui.get_node("SettingsOverlay/CenterContainer/PanelContainer/SettingsContent/MuteRow"),
	]
	var row_backgrounds := [
		ui.get_node(
			"SettingsOverlay/CenterContainer/PanelContainer/SettingsContent/ResolutionRowBg"
		),
		ui.get_node(
			"SettingsOverlay/CenterContainer/PanelContainer/SettingsContent/MusicVolumeRowBg"
		),
		ui.get_node(
			"SettingsOverlay/CenterContainer/PanelContainer/SettingsContent/SoundVolumeRowBg"
		),
		ui.get_node("SettingsOverlay/CenterContainer/PanelContainer/SettingsContent/MuteRowBg"),
	]
	for index in rows.size():
		var row := rows[index] as Control
		var row_bg := row_backgrounds[index] as Control
		_assert_center_y_ratio(row, panel_rect, ROW_CENTER_Y_RATIOS[index])
		assert_bool(row_bg.get_global_rect().encloses(row.get_global_rect())).is_true()
		_assert_label_margin(row, row_bg)

	var apply_button := (
		ui.get_node("SettingsOverlay/CenterContainer/PanelContainer/SettingsContent/ApplyButton")
		as Control
	)
	var back_button := (
		ui.get_node("SettingsOverlay/CenterContainer/PanelContainer/SettingsContent/CloseButton")
		as Control
	)
	_assert_bottom_margin(apply_button, panel_rect)
	_assert_bottom_margin(back_button, panel_rect)
	_assert_button_group_centered(apply_button, back_button, panel_rect)


func _assert_center_y_ratio(control: Control, panel_rect: Rect2, expected_ratio: float) -> void:
	var center_y := control.get_global_rect().get_center().y
	var expected_y := panel_rect.position.y + panel_rect.size.y * expected_ratio
	assert_float(center_y).is_equal_approx(expected_y, TOLERANCE)


func _assert_label_margin(control: Control, row_bg: Control) -> void:
	var child := control.get_child(0) as Control
	assert_object(child).is_not_null()
	var actual_margin := child.get_global_rect().position.x - row_bg.get_global_rect().position.x
	assert_float(actual_margin).is_equal_approx(LABEL_LEFT_MARGIN, STRICT_TOLERANCE)


func _assert_bottom_margin(control: Control, panel_rect: Rect2) -> void:
	var actual_margin := panel_rect.end.y - control.get_global_rect().end.y
	assert_float(actual_margin).is_equal_approx(BUTTON_BOTTOM_MARGIN, STRICT_TOLERANCE)


func _assert_button_group_centered(
	left_button: Control, right_button: Control, panel_rect: Rect2
) -> void:
	var group_rect := left_button.get_global_rect().merge(right_button.get_global_rect())
	var expected_center_x := panel_rect.position.x + panel_rect.size.x * BUTTON_GROUP_CENTER_RATIO
	assert_float(group_rect.get_center().x).is_equal_approx(expected_center_x, STRICT_TOLERANCE)


func _escape_event() -> InputEventKey:
	var event := InputEventKey.new()
	event.keycode = KEY_ESCAPE
	event.pressed = true
	return event


func _wait_ready(node: Node) -> void:
	if not node.is_node_ready():
		await node.ready
	await get_tree().process_frame
