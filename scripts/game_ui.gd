extends CanvasLayer

signal restart_requested

@onready var hp_bar: ProgressBar = $MarginContainer/VBox/HPBar
@onready var timer_label: Label = $MarginContainer/VBox/TimerLabel
@onready var kill_label: Label = $MarginContainer/VBox/KillLabel
@onready var overlay: ColorRect = $Overlay
@onready var overlay_label: Label = $Overlay/CenterContainer/VBox/OverlayLabel
@onready var restart_hint: Label = $Overlay/CenterContainer/VBox/RestartHint
@onready var restart_button: Button = $Overlay/CenterContainer/VBox/RestartButton


func _ready() -> void:
	overlay.visible = false
	restart_button.pressed.connect(_on_restart_pressed)


func _on_restart_pressed() -> void:
	restart_requested.emit()
	get_tree().reload_current_scene()


func update_health(current: int, maximum: int) -> void:
	hp_bar.max_value = maximum
	hp_bar.value = current


func update_timer(seconds_remaining: float) -> void:
	timer_label.text = "Time: %d" % ceili(max(seconds_remaining, 0.0))


func update_kills(kills: int) -> void:
	kill_label.text = "Kills: %d" % kills


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


func hide_overlay() -> void:
	overlay.visible = false
