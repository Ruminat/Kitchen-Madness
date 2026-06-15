extends CanvasLayer

signal upgrade_selected(upgrade: Resource)
signal shop_purchase_requested(upgrade: Resource)
signal shop_continue_requested

const COLOR_TEXT := Color(0.92, 0.94, 0.97, 1.0)
const COLOR_MUTED := Color(0.62, 0.66, 0.74, 1.0)
const COLOR_GOLD := Color(0.95, 0.82, 0.35, 1.0)
const COLOR_PANEL := Color(0.07, 0.08, 0.11, 0.82)
const COLOR_BAR_BG := Color(0.14, 0.15, 0.19, 1.0)
const COLOR_BAR_FILL := Color(0.78, 0.22, 0.28, 1.0)
const COLOR_BAR_FILL_LOW := Color(0.95, 0.42, 0.18, 1.0)
const COLOR_XP_FILL := Color(0.28, 0.62, 0.95, 1.0)
const COLOR_XP_FLASH := Color(0.55, 0.88, 1.0, 1.0)
const COLOR_LEVEL_UP_ACCENT := Color(0.55, 0.88, 1.0, 1.0)

@onready var hp_bar: ProgressBar = $HudPanel/MarginContainer/VBox/HPRow/HPBar
@onready var hp_value_label: Label = $HudPanel/MarginContainer/VBox/HPRow/HPValue
@onready var timer_label: Label = $HudPanel/MarginContainer/VBox/StatsRow/TimerLabel
@onready var kill_label: Label = $HudPanel/MarginContainer/VBox/StatsRow/KillLabel
@onready var gold_label: Label = $HudPanel/MarginContainer/VBox/StatsRow/GoldLabel
@onready var hud_panel: PanelContainer = $HudPanel
@onready var xp_panel: PanelContainer = $XpPanel
@onready var xp_bar: ProgressBar = $XpPanel/MarginContainer/HBox/XpBar
@onready var level_label: Label = $XpPanel/MarginContainer/HBox/LevelLabel
@onready var overlay: ColorRect = $Overlay
@onready var overlay_label: Label = $Overlay/CenterContainer/VBox/OverlayLabel
@onready var restart_hint: Label = $Overlay/CenterContainer/VBox/RestartHint
@onready var restart_button: Button = $Overlay/CenterContainer/VBox/RestartButton
@onready var level_up_overlay: ColorRect = $LevelUpOverlay
@onready var level_up_panel: PanelContainer = $LevelUpOverlay/CenterContainer/PanelContainer
@onready var level_up_title_label: Label = $LevelUpOverlay/CenterContainer/PanelContainer/MarginContainer/VBox/TitleLabel
@onready var level_up_hint_label: Label = $LevelUpOverlay/CenterContainer/PanelContainer/MarginContainer/VBox/HintLabel
@onready var upgrade_button_1: Button = $LevelUpOverlay/CenterContainer/PanelContainer/MarginContainer/VBox/UpgradeChoices/UpgradeButton1
@onready var upgrade_button_2: Button = $LevelUpOverlay/CenterContainer/PanelContainer/MarginContainer/VBox/UpgradeChoices/UpgradeButton2
@onready var upgrade_button_3: Button = $LevelUpOverlay/CenterContainer/PanelContainer/MarginContainer/VBox/UpgradeChoices/UpgradeButton3
@onready var shop_overlay: ColorRect = $ShopOverlay
@onready var shop_panel: PanelContainer = $ShopOverlay/CenterContainer/PanelContainer
@onready var shop_title_label: Label = $ShopOverlay/CenterContainer/PanelContainer/MarginContainer/VBox/TitleLabel
@onready var shop_gold_label: Label = $ShopOverlay/CenterContainer/PanelContainer/MarginContainer/VBox/GoldLabel
@onready var shop_button_1: Button = $ShopOverlay/CenterContainer/PanelContainer/MarginContainer/VBox/ShopButton1
@onready var shop_button_2: Button = $ShopOverlay/CenterContainer/PanelContainer/MarginContainer/VBox/ShopButton2
@onready var shop_button_3: Button = $ShopOverlay/CenterContainer/PanelContainer/MarginContainer/VBox/ShopButton3
@onready var shop_button_4: Button = $ShopOverlay/CenterContainer/PanelContainer/MarginContainer/VBox/ShopButton4
@onready var shop_button_5: Button = $ShopOverlay/CenterContainer/PanelContainer/MarginContainer/VBox/ShopButton5
@onready var shop_button_6: Button = $ShopOverlay/CenterContainer/PanelContainer/MarginContainer/VBox/ShopButton6
@onready var shop_button_7: Button = $ShopOverlay/CenterContainer/PanelContainer/MarginContainer/VBox/ShopButton7
@onready var shop_button_8: Button = $ShopOverlay/CenterContainer/PanelContainer/MarginContainer/VBox/ShopButton8
@onready var shop_continue_button: Button = $ShopOverlay/CenterContainer/PanelContainer/MarginContainer/VBox/ContinueButton

var _kills := 0
var _current_wave := 1
var _current_gold := 0
var _timer_pulse_tween: Tween
var _xp_flash_tween: Tween
var _upgrade_buttons: Array[Button] = []
var _upgrade_choices: Array[Resource] = []
var _shop_buttons: Array[Button] = []
var _shop_upgrades: Array[Resource] = []


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_upgrade_buttons = [upgrade_button_1, upgrade_button_2, upgrade_button_3]
	_shop_buttons = [
		shop_button_1, shop_button_2, shop_button_3, shop_button_4,
		shop_button_5, shop_button_6, shop_button_7, shop_button_8,
	]
	_apply_hud_theme()
	overlay.visible = false
	level_up_overlay.visible = false
	shop_overlay.visible = false
	restart_button.pressed.connect(_on_restart_pressed)
	shop_continue_button.pressed.connect(_on_shop_continue_pressed)
	for index in _upgrade_buttons.size():
		_upgrade_buttons[index].pressed.connect(_on_upgrade_button_pressed.bind(index))
	for index in _shop_buttons.size():
		_shop_buttons[index].pressed.connect(_on_shop_button_pressed.bind(index))

	EventBus.player_health_changed.connect(_on_player_health_changed)
	EventBus.wave_time_changed.connect(_on_wave_time_changed)
	EventBus.enemy_killed.connect(_on_enemy_killed)
	EventBus.xp_changed.connect(_on_xp_changed)
	EventBus.level_up.connect(_on_level_up)
	EventBus.gold_changed.connect(_on_gold_changed)
	EventBus.wave_index_changed.connect(_on_wave_index_changed)


func _apply_hud_theme() -> void:
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = COLOR_PANEL
	panel_style.set_corner_radius_all(8)
	hud_panel.add_theme_stylebox_override("panel", panel_style)
	xp_panel.add_theme_stylebox_override("panel", panel_style)
	level_up_panel.add_theme_stylebox_override("panel", _make_overlay_panel_style(COLOR_LEVEL_UP_ACCENT))
	shop_panel.add_theme_stylebox_override("panel", panel_style)

	hp_bar.set_script(load("res://scripts/ui/stat_bar.gd"))
	hp_bar.setup_bar(COLOR_BAR_BG, COLOR_BAR_FILL, 8.0)
	xp_bar.set_script(load("res://scripts/ui/stat_bar.gd"))
	xp_bar.setup_bar(COLOR_BAR_BG, COLOR_XP_FILL, 8.0)

	for label in [timer_label, kill_label, hp_value_label, level_label, gold_label]:
		label.add_theme_color_override("font_color", COLOR_TEXT)
		label.add_theme_font_size_override("font_size", 14)

	gold_label.add_theme_color_override("font_color", COLOR_GOLD)
	shop_gold_label.add_theme_color_override("font_color", COLOR_GOLD)

	restart_button.add_theme_font_size_override("font_size", 16)
	shop_continue_button.add_theme_font_size_override("font_size", 16)
	overlay_label.add_theme_font_size_override("font_size", 48)
	restart_hint.add_theme_color_override("font_color", COLOR_MUTED)
	restart_hint.add_theme_font_size_override("font_size", 18)

	for button in _upgrade_buttons:
		button.add_theme_font_size_override("font_size", 17)
	for button in _shop_buttons:
		button.add_theme_font_size_override("font_size", 16)

	level_up_title_label.add_theme_color_override("font_color", COLOR_LEVEL_UP_ACCENT)
	level_up_hint_label.add_theme_color_override("font_color", COLOR_MUTED)
	level_up_hint_label.add_theme_font_size_override("font_size", 14)


func _make_overlay_panel_style(accent: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.07, 0.1, 0.96)
	style.border_width_top = 3
	style.border_color = accent
	style.set_corner_radius_all(14)
	style.content_margin_left = 4
	style.content_margin_right = 4
	style.content_margin_top = 4
	style.content_margin_bottom = 4
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.45)
	style.shadow_size = 12
	return style


func _on_restart_pressed() -> void:
	var tree := get_tree()
	if tree == null:
		return

	tree.paused = false
	tree.reload_current_scene()


func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.is_pressed() or event.echo:
		return

	if level_up_overlay.visible:
		if _handle_level_up_keyboard(event as InputEventKey):
			_mark_input_handled()
		return

	if shop_overlay.visible:
		if _handle_shop_keyboard(event as InputEventKey):
			_mark_input_handled()
		return

	if not overlay.visible:
		return

	if event.is_action_pressed("restart") or event.is_action_pressed("ui_accept"):
		_mark_input_handled()
		_on_restart_pressed()


func _mark_input_handled() -> void:
	var viewport := get_viewport()
	if viewport:
		viewport.set_input_as_handled()


func _handle_level_up_keyboard(event: InputEventKey) -> bool:
	var index := _number_key_index(event)
	if index >= 0 and index < _upgrade_choices.size():
		_on_upgrade_button_pressed(index)
		return true

	if event.is_action_pressed("move_up") or event.is_action_pressed("ui_up"):
		_navigate_button_focus(_upgrade_buttons, -1)
		return true

	if event.is_action_pressed("move_down") or event.is_action_pressed("ui_down"):
		_navigate_button_focus(_upgrade_buttons, 1)
		return true

	if event.is_action_pressed("ui_accept"):
		var focused_index := _focused_button_index(_upgrade_buttons)
		if focused_index >= 0:
			_on_upgrade_button_pressed(focused_index)
			return true

	return false


func _handle_shop_keyboard(event: InputEventKey) -> bool:
	var index := _number_key_index(event)
	if index >= 0:
		if index >= _shop_upgrades.size():
			return false
		var button := _shop_buttons[index]
		if not button.visible or button.disabled:
			return false
		_on_shop_button_pressed(index)
		return true

	if event.is_action_pressed("move_up") or event.is_action_pressed("ui_up"):
		_navigate_button_focus(_shop_buttons, -1)
		return true

	if event.is_action_pressed("move_down") or event.is_action_pressed("ui_down"):
		_navigate_button_focus(_shop_buttons, 1)
		return true

	if event.is_action_pressed("ui_accept"):
		if shop_continue_button.has_focus():
			_on_shop_continue_pressed()
			return true

		var focused_index := _focused_button_index(_shop_buttons)
		if focused_index >= 0:
			var button := _shop_buttons[focused_index]
			if button.visible and not button.disabled:
				_on_shop_button_pressed(focused_index)
				return true

		_on_shop_continue_pressed()
		return true

	return false


func _navigate_button_focus(buttons: Array[Button], direction: int) -> void:
	var current := _focused_button_index(buttons)
	if current < 0:
		_focus_first_visible_button(buttons)
		return

	var next := current + direction
	while next >= 0 and next < buttons.size():
		var button := buttons[next]
		if button.visible and not button.disabled:
			button.grab_focus()
			return
		next += direction


func _focused_button_index(buttons: Array[Button]) -> int:
	for index in buttons.size():
		if buttons[index].has_focus():
			return index
	return -1


func _number_key_index(event: InputEventKey) -> int:
	match event.keycode:
		KEY_1, KEY_KP_1:
			return 0
		KEY_2, KEY_KP_2:
			return 1
		KEY_3, KEY_KP_3:
			return 2
		KEY_4, KEY_KP_4:
			return 3
		KEY_5, KEY_KP_5:
			return 4
		KEY_6, KEY_KP_6:
			return 5
		KEY_7, KEY_KP_7:
			return 6
		KEY_8, KEY_KP_8:
			return 7
	return -1


func _on_player_health_changed(current: int, maximum: int) -> void:
	hp_bar.set_value_smooth(float(current), float(maximum))
	hp_value_label.text = "%d / %d" % [current, maximum]

	var ratio := float(current) / float(maxi(maximum, 1))
	hp_bar.set_fill_color(COLOR_BAR_FILL.lerp(COLOR_BAR_FILL_LOW, 1.0 - ratio))


func _on_xp_changed(current: int, to_next: int, level: int) -> void:
	xp_bar.set_value_smooth(float(current), float(maxi(to_next, 1)))
	level_label.text = "Lv %d" % level


func _on_level_up(_level: int) -> void:
	if _xp_flash_tween:
		_xp_flash_tween.kill()
	xp_bar.set_fill_color(COLOR_XP_FLASH)
	_xp_flash_tween = create_tween()
	_xp_flash_tween.tween_property(xp_bar, "modulate", Color(1.4, 1.4, 1.4, 1.0), 0.08)
	_xp_flash_tween.tween_property(xp_bar, "modulate", Color.WHITE, 0.25)
	_xp_flash_tween.tween_callback(func() -> void: xp_bar.set_fill_color(COLOR_XP_FILL))


func _on_wave_time_changed(seconds_remaining: float) -> void:
	var seconds := ceili(maxf(seconds_remaining, 0.0))
	timer_label.text = "W%d · %ds" % [_current_wave, seconds]

	var urgent := seconds <= 10
	timer_label.add_theme_color_override(
		"font_color",
		Color(0.95, 0.55, 0.35, 1.0) if urgent else COLOR_TEXT
	)
	_update_timer_pulse(urgent)


func _update_timer_pulse(urgent: bool) -> void:
	if not urgent:
		if _timer_pulse_tween:
			_timer_pulse_tween.kill()
			_timer_pulse_tween = null
		timer_label.scale = Vector2.ONE
		return

	if _timer_pulse_tween:
		return

	_timer_pulse_tween = create_tween().set_loops()
	_timer_pulse_tween.tween_property(timer_label, "scale", Vector2(1.08, 1.08), 0.35)
	_timer_pulse_tween.tween_property(timer_label, "scale", Vector2.ONE, 0.35)


func _on_enemy_killed(_enemy: Node, _killer: Node) -> void:
	_kills += 1
	kill_label.text = "%d kills" % _kills


func _on_gold_changed(gold: int) -> void:
	_current_gold = gold
	gold_label.text = "%d gold" % gold


func _on_wave_index_changed(wave: int) -> void:
	_current_wave = wave
	shop_title_label.text = "Wave %d Complete — Shop" % wave


func show_wave_complete() -> void:
	overlay.visible = true
	overlay_label.text = "Wave Complete!"
	restart_hint.text = "Press R to play again"
	restart_hint.visible = true
	restart_button.visible = true


func show_game_over() -> void:
	overlay.visible = true
	overlay_label.text = "Game Over"
	restart_hint.text = "Press R or Enter to restart"
	restart_hint.visible = true
	restart_button.visible = true
	restart_button.grab_focus()


func show_level_up_options(upgrades: Array[Resource]) -> void:
	_upgrade_choices = upgrades
	level_up_overlay.visible = true
	level_up_title_label.text = "⭐  Level Up!"
	level_up_hint_label.text = "W/S or ↑/↓ navigate  ·  1/2/3 or Enter pick  ·  Click to choose"

	for index in _upgrade_buttons.size():
		var button := _upgrade_buttons[index]
		var has_choice := index < _upgrade_choices.size()
		button.visible = has_choice
		button.disabled = not has_choice
		if has_choice:
			var upgrade: Resource = _upgrade_choices[index]
			button.text = UpgradeDisplay.format_card_text(upgrade, "[%d]" % (index + 1))
			UpgradeDisplay.apply_card_style(button, upgrade)

	_focus_first_visible_button(_upgrade_buttons)


func hide_level_up_options() -> void:
	level_up_overlay.visible = false
	_upgrade_choices.clear()


func show_shop(upgrades: Array[Resource], gold: int) -> void:
	_shop_upgrades = upgrades
	_current_gold = gold
	shop_overlay.visible = true
	_update_shop_buttons()
	shop_continue_button.grab_focus()


func update_shop_gold(gold: int) -> void:
	_current_gold = gold
	_update_shop_buttons()


func hide_shop() -> void:
	shop_overlay.visible = false
	_shop_upgrades.clear()


func _update_shop_buttons() -> void:
	shop_gold_label.text = "%d gold available" % _current_gold

	for index in _shop_buttons.size():
		var button := _shop_buttons[index]
		var has_upgrade := index < _shop_upgrades.size()
		button.visible = has_upgrade
		if not has_upgrade:
			button.disabled = true
			continue

		var upgrade: Resource = _shop_upgrades[index]
		var cost := int(upgrade.get("gold_cost"))
		var can_afford := _current_gold >= cost
		button.disabled = not can_afford
		button.text = UpgradeDisplay.format_card_text(upgrade, "— %d gold" % cost)
		UpgradeDisplay.apply_card_style(button, upgrade)


func _on_shop_button_pressed(index: int) -> void:
	if index < 0 or index >= _shop_upgrades.size():
		return

	shop_purchase_requested.emit(_shop_upgrades[index])


func _on_shop_continue_pressed() -> void:
	shop_continue_requested.emit()


func _on_upgrade_button_pressed(index: int) -> void:
	if index < 0 or index >= _upgrade_choices.size():
		return

	upgrade_selected.emit(_upgrade_choices[index])


func _focus_first_visible_button(buttons: Array[Button]) -> void:
	for button in buttons:
		if button.visible and not button.disabled:
			button.grab_focus()
			return
