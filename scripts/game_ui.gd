extends CanvasLayer

@onready var hp_bar: ProgressBar = $MarginContainer/VBox/HPBar
@onready var timer_label: Label = $MarginContainer/VBox/TimerLabel
@onready var kill_label: Label = $MarginContainer/VBox/KillLabel
@onready var overlay: ColorRect = $Overlay
@onready var overlay_label: Label = $Overlay/CenterContainer/VBox/OverlayLabel
@onready var restart_hint: Label = $Overlay/CenterContainer/VBox/RestartHint
@onready var restart_button: Button = $Overlay/CenterContainer/VBox/RestartButton

var _kills := 0


func _ready() -> void:
	overlay.visible = false
	restart_button.pressed.connect(_on_restart_pressed)

	EventBus.player_health_changed.connect(_on_player_health_changed)
	EventBus.wave_time_changed.connect(_on_wave_time_changed)
	EventBus.enemy_killed.connect(_on_enemy_killed)


func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()


func _on_player_health_changed(current: int, maximum: int) -> void:
	hp_bar.max_value = maximum
	hp_bar.value = current


func _on_wave_time_changed(seconds_remaining: float) -> void:
	timer_label.text = "Time: %d" % ceili(maxf(seconds_remaining, 0.0))


func _on_enemy_killed(_enemy: Node, _killer: Node) -> void:
	_kills += 1
	kill_label.text = "Kills: %d" % _kills


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
