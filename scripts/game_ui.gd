extends CanvasLayer

const COLOR_TEXT := Color(0.92, 0.94, 0.97, 1.0)
const COLOR_MUTED := Color(0.62, 0.66, 0.74, 1.0)
const COLOR_PANEL := Color(0.07, 0.08, 0.11, 0.82)
const COLOR_BAR_BG := Color(0.14, 0.15, 0.19, 1.0)
const COLOR_BAR_FILL := Color(0.78, 0.22, 0.28, 1.0)
const COLOR_BAR_FILL_LOW := Color(0.95, 0.42, 0.18, 1.0)

@onready var hp_bar: ProgressBar = $HudPanel/MarginContainer/VBox/HPRow/HPBar
@onready var hp_value_label: Label = $HudPanel/MarginContainer/VBox/HPRow/HPValue
@onready var timer_label: Label = $HudPanel/MarginContainer/VBox/StatsRow/TimerLabel
@onready var kill_label: Label = $HudPanel/MarginContainer/VBox/StatsRow/KillLabel
@onready var hud_panel: PanelContainer = $HudPanel
@onready var overlay: ColorRect = $Overlay
@onready var overlay_label: Label = $Overlay/CenterContainer/VBox/OverlayLabel
@onready var restart_hint: Label = $Overlay/CenterContainer/VBox/RestartHint
@onready var restart_button: Button = $Overlay/CenterContainer/VBox/RestartButton

var _kills := 0
var _hp_fill_style: StyleBoxFlat


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_apply_hud_theme()
	overlay.visible = false
	restart_button.pressed.connect(_on_restart_pressed)

	EventBus.player_health_changed.connect(_on_player_health_changed)
	EventBus.wave_time_changed.connect(_on_wave_time_changed)
	EventBus.enemy_killed.connect(_on_enemy_killed)


func _apply_hud_theme() -> void:
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = COLOR_PANEL
	panel_style.set_corner_radius_all(8)
	panel_style.content_margin_left = 0
	panel_style.content_margin_top = 0
	panel_style.content_margin_right = 0
	panel_style.content_margin_bottom = 0
	hud_panel.add_theme_stylebox_override("panel", panel_style)

	var bar_bg := StyleBoxFlat.new()
	bar_bg.bg_color = COLOR_BAR_BG
	bar_bg.set_corner_radius_all(3)
	hp_bar.add_theme_stylebox_override("background", bar_bg)

	_hp_fill_style = StyleBoxFlat.new()
	_hp_fill_style.bg_color = COLOR_BAR_FILL
	_hp_fill_style.set_corner_radius_all(3)
	hp_bar.add_theme_stylebox_override("fill", _hp_fill_style)

	for label in [timer_label, kill_label, hp_value_label]:
		label.add_theme_color_override("font_color", COLOR_TEXT)
		label.add_theme_font_size_override("font_size", 14)

	restart_button.add_theme_font_size_override("font_size", 16)
	overlay_label.add_theme_font_size_override("font_size", 48)
	restart_hint.add_theme_color_override("font_color", COLOR_MUTED)
	restart_hint.add_theme_font_size_override("font_size", 18)


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
	hp_bar.max_value = maximum
	hp_bar.value = current
	hp_value_label.text = "%d / %d" % [current, maximum]

	var ratio := float(current) / float(maxi(maximum, 1))
	_hp_fill_style.bg_color = COLOR_BAR_FILL.lerp(COLOR_BAR_FILL_LOW, 1.0 - ratio)


func _on_wave_time_changed(seconds_remaining: float) -> void:
	var seconds := ceili(maxf(seconds_remaining, 0.0))
	timer_label.text = "%ds" % seconds
	timer_label.add_theme_color_override(
		"font_color",
		Color(0.95, 0.55, 0.35, 1.0) if seconds <= 10 else COLOR_TEXT
	)


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
