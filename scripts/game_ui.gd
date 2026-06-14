extends CanvasLayer

signal upgrade_selected(upgrade: Resource)

const COLOR_TEXT := Color(0.92, 0.94, 0.97, 1.0)
const COLOR_MUTED := Color(0.62, 0.66, 0.74, 1.0)
const COLOR_PANEL := Color(0.07, 0.08, 0.11, 0.82)
const COLOR_BAR_BG := Color(0.14, 0.15, 0.19, 1.0)
const COLOR_BAR_FILL := Color(0.78, 0.22, 0.28, 1.0)
const COLOR_BAR_FILL_LOW := Color(0.95, 0.42, 0.18, 1.0)
const COLOR_XP_FILL := Color(0.28, 0.62, 0.95, 1.0)
const COLOR_XP_FLASH := Color(0.55, 0.88, 1.0, 1.0)

@onready var hp_bar: ProgressBar = $HudPanel/MarginContainer/VBox/HPRow/HPBar
@onready var hp_value_label: Label = $HudPanel/MarginContainer/VBox/HPRow/HPValue
@onready var timer_label: Label = $HudPanel/MarginContainer/VBox/StatsRow/TimerLabel
@onready var kill_label: Label = $HudPanel/MarginContainer/VBox/StatsRow/KillLabel
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
@onready var upgrade_button_1: Button = $LevelUpOverlay/CenterContainer/PanelContainer/MarginContainer/VBox/UpgradeButton1
@onready var upgrade_button_2: Button = $LevelUpOverlay/CenterContainer/PanelContainer/MarginContainer/VBox/UpgradeButton2
@onready var upgrade_button_3: Button = $LevelUpOverlay/CenterContainer/PanelContainer/MarginContainer/VBox/UpgradeButton3

var _kills := 0
var _timer_pulse_tween: Tween
var _xp_flash_tween: Tween
var _upgrade_buttons: Array[Button] = []
var _upgrade_choices: Array[Resource] = []


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_upgrade_buttons = [upgrade_button_1, upgrade_button_2, upgrade_button_3]
	_apply_hud_theme()
	overlay.visible = false
	level_up_overlay.visible = false
	restart_button.pressed.connect(_on_restart_pressed)
	for index in _upgrade_buttons.size():
		_upgrade_buttons[index].pressed.connect(_on_upgrade_button_pressed.bind(index))

	EventBus.player_health_changed.connect(_on_player_health_changed)
	EventBus.wave_time_changed.connect(_on_wave_time_changed)
	EventBus.enemy_killed.connect(_on_enemy_killed)
	EventBus.xp_changed.connect(_on_xp_changed)
	EventBus.level_up.connect(_on_level_up)


func _apply_hud_theme() -> void:
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = COLOR_PANEL
	panel_style.set_corner_radius_all(8)
	hud_panel.add_theme_stylebox_override("panel", panel_style)
	xp_panel.add_theme_stylebox_override("panel", panel_style)
	level_up_panel.add_theme_stylebox_override("panel", panel_style)

	hp_bar.set_script(load("res://scripts/ui/stat_bar.gd"))
	hp_bar.setup_bar(COLOR_BAR_BG, COLOR_BAR_FILL, 8.0)
	xp_bar.set_script(load("res://scripts/ui/stat_bar.gd"))
	xp_bar.setup_bar(COLOR_BAR_BG, COLOR_XP_FILL, 8.0)

	for label in [timer_label, kill_label, hp_value_label, level_label]:
		label.add_theme_color_override("font_color", COLOR_TEXT)
		label.add_theme_font_size_override("font_size", 14)

	restart_button.add_theme_font_size_override("font_size", 16)
	overlay_label.add_theme_font_size_override("font_size", 48)
	restart_hint.add_theme_color_override("font_color", COLOR_MUTED)
	restart_hint.add_theme_font_size_override("font_size", 18)

	for button in _upgrade_buttons:
		button.add_theme_font_size_override("font_size", 16)


func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _unhandled_input(event: InputEvent) -> void:
	if not overlay.visible:
		return
	if event.is_action_pressed("restart"):
		get_tree().paused = false
		get_tree().reload_current_scene()


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
	timer_label.text = "%ds" % seconds

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


func show_wave_complete() -> void:
	overlay.visible = true
	overlay_label.text = "Wave Complete!"
	restart_hint.text = "Press R to play again"
	restart_hint.visible = true
	restart_button.visible = true


func show_game_over() -> void:
	overlay.visible = true
	overlay_label.text = "Game Over"
	restart_hint.text = "Press R to restart"
	restart_hint.visible = true
	restart_button.visible = true


func show_level_up_options(upgrades: Array[Resource]) -> void:
	_upgrade_choices = upgrades
	level_up_overlay.visible = true

	for index in _upgrade_buttons.size():
		var button := _upgrade_buttons[index]
		var has_choice := index < _upgrade_choices.size()
		button.visible = has_choice
		button.disabled = not has_choice
		if has_choice:
			var upgrade: Resource = _upgrade_choices[index]
			button.text = "%s\n%s" % [upgrade.get("title"), upgrade.get("description")]


func hide_level_up_options() -> void:
	level_up_overlay.visible = false
	_upgrade_choices.clear()


func _on_upgrade_button_pressed(index: int) -> void:
	if index < 0 or index >= _upgrade_choices.size():
		return

	upgrade_selected.emit(_upgrade_choices[index])
